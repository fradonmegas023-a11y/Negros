-- NEGROS initial Supabase schema
-- Run this entire file in Supabase Dashboard > SQL Editor.
-- Never put a Supabase service_role key in the Android app.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null check (char_length(username) between 3 and 24),
  display_name text not null default 'NEGROS member',
  bio text not null default '' check (char_length(bio) <= 280),
  avatar_url text,
  cover_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  post_type text not null default 'post' check (post_type in ('post','debate','question','podcast','event')),
  topic text not null default 'Society',
  body text not null check (char_length(body) between 1 and 10000),
  media_url text,
  visibility text not null default 'public' check (visibility in ('public','followers','private')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists posts_created_at_idx on public.posts(created_at desc);
create index if not exists posts_author_id_idx on public.posts(author_id);

create table if not exists public.post_likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  parent_comment_id uuid references public.comments(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 5000),
  created_at timestamptz not null default now()
);
create index if not exists comments_post_created_idx on public.comments(post_id, created_at);

create table if not exists public.post_bookmarks (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.post_reposts (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.polls (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null unique references public.posts(id) on delete cascade,
  closes_at timestamptz,
  allow_multiple boolean not null default false
);

create table if not exists public.poll_options (
  id uuid primary key default gen_random_uuid(),
  poll_id uuid not null references public.polls(id) on delete cascade,
  option_text text not null check (char_length(option_text) between 1 and 180),
  sort_order integer not null default 0
);

create table if not exists public.poll_votes (
  poll_id uuid not null references public.polls(id) on delete cascade,
  option_id uuid not null references public.poll_options(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (poll_id, option_id, user_id)
);

create table if not exists public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  followed_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followed_id),
  check (follower_id <> followed_id)
);

create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null check (char_length(name) between 3 and 70),
  slug text unique not null,
  description text not null default '' check (char_length(description) <= 1000),
  category text not null default 'General',
  is_private boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.posts add column if not exists community_id uuid references public.communities(id) on delete set null;

create table if not exists public.community_members (
  community_id uuid not null references public.communities(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  member_role text not null default 'member' check (member_role in ('member','moderator','admin')),
  joined_at timestamptz not null default now(),
  primary key (community_id, user_id)
);

create table if not exists public.debates (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 8 and 240),
  description text not null default '',
  topic text not null default 'Society',
  status text not null default 'open' check (status in ('open','closed','archived')),
  created_at timestamptz not null default now(),
  closes_at timestamptz
);

create table if not exists public.debate_arguments (
  id uuid primary key default gen_random_uuid(),
  debate_id uuid not null references public.debates(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  position text not null check (position in ('for','against','neutral')),
  body text not null check (char_length(body) between 1 and 5000),
  created_at timestamptz not null default now()
);

create table if not exists public.debate_votes (
  debate_id uuid not null references public.debates(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  position text not null check (position in ('for','against','neutral')),
  created_at timestamptz not null default now(),
  primary key (debate_id, user_id)
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 8 and 300),
  details text not null default '',
  topic text not null default 'General',
  is_anonymous boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 5000),
  is_accepted boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.answer_votes (
  answer_id uuid not null references public.answers(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (answer_id, user_id)
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  is_group boolean not null default false,
  title text,
  created_by uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (conversation_id, user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 10000),
  attachment_url text,
  created_at timestamptz not null default now(),
  read_at timestamptz
);
create index if not exists messages_conversation_created_idx on public.messages(conversation_id, created_at);

create table if not exists public.podcasts (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 3 and 120),
  description text not null default '',
  cover_url text,
  category text not null default 'Society',
  created_at timestamptz not null default now()
);

create table if not exists public.podcast_episodes (
  id uuid primary key default gen_random_uuid(),
  podcast_id uuid not null references public.podcasts(id) on delete cascade,
  title text not null check (char_length(title) between 3 and 180),
  description text not null default '',
  audio_url text not null,
  duration_seconds integer check (duration_seconds is null or duration_seconds >= 0),
  published_at timestamptz not null default now()
);

create table if not exists public.podcast_subscriptions (
  podcast_id uuid not null references public.podcasts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (podcast_id, user_id)
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 3 and 160),
  description text not null default '',
  starts_at timestamptz not null,
  ends_at timestamptz,
  location_text text,
  is_online boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.event_attendees (
  event_id uuid not null references public.events(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  attendance_status text not null default 'going' check (attendance_status in ('going','interested','not_going')),
  created_at timestamptz not null default now(),
  primary key (event_id, user_id)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  notification_type text not null,
  entity_id uuid,
  body text not null default '',
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.content_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type text not null check (target_type in ('post','comment','profile','message','community','debate')),
  target_id uuid not null,
  reason text not null check (char_length(reason) between 3 and 1000),
  status text not null default 'open' check (status in ('open','reviewing','actioned','dismissed')),
  created_at timestamptz not null default now()
);

-- Privileged role assignments and moderation audit records are intentionally
-- inaccessible to ordinary client roles. Manage them through trusted server tools.
create table if not exists public.platform_roles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  role text not null check (role in ('moderator','admin','owner')),
  granted_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.moderation_actions (
  id uuid primary key default gen_random_uuid(),
  moderator_id uuid not null references public.profiles(id) on delete restrict,
  target_type text not null,
  target_id uuid not null,
  action text not null check (action in ('warning','content_limited','content_removed','account_suspended','account_restored','report_dismissed')),
  reason text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.user_blocks (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

-- Create a profile when a new Auth user registers.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    'member_' || substr(new.id::text, 1, 12),
    coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), 'NEGROS member')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Enable RLS everywhere that contains user or social data.
do $$
declare t text;
begin
  foreach t in array array[
    'profiles','posts','post_likes','comments','post_bookmarks','post_reposts','polls','poll_options','poll_votes','follows','communities','community_members',
    'debates','debate_arguments','debate_votes','questions','answers','answer_votes',
    'conversations','conversation_members','messages','podcasts','podcast_episodes',
    'podcast_subscriptions','events','event_attendees','notifications','content_reports','platform_roles','moderation_actions','user_blocks'
  ] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Profiles: public read, owner update.
drop policy if exists profiles_public_read on public.profiles;
create policy profiles_public_read on public.profiles for select to anon, authenticated using (true);
drop policy if exists profiles_owner_update on public.profiles;
create policy profiles_owner_update on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Public discussion content. Users may only create/edit/delete their own records.
drop policy if exists posts_public_read on public.posts;
create policy posts_public_read on public.posts for select to anon, authenticated
using (
  author_id = auth.uid()
  or (
    visibility = 'public'
    and (
      community_id is null
      or exists (
        select 1 from public.communities c
        where c.id = community_id
          and (not c.is_private or exists (
            select 1 from public.community_members m
            where m.community_id = c.id and m.user_id = auth.uid()
          ))
      )
    )
  )
);
drop policy if exists posts_owner_insert on public.posts;
create policy posts_owner_insert on public.posts for insert to authenticated
with check (
  author_id = auth.uid()
  and (community_id is null or exists (
    select 1 from public.communities c
    where c.id = community_id
      and (not c.is_private or exists (
        select 1 from public.community_members m
        where m.community_id = c.id and m.user_id = auth.uid()
      ))
  ))
);
drop policy if exists posts_owner_update on public.posts;
create policy posts_owner_update on public.posts for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
drop policy if exists posts_owner_delete on public.posts;
create policy posts_owner_delete on public.posts for delete to authenticated using (author_id = auth.uid());

-- Likes, comments and follows.
create policy likes_read on public.post_likes for select to anon, authenticated
using (exists (select 1 from public.posts p where p.id = post_id));
create policy likes_self_insert on public.post_likes for insert to authenticated
with check (user_id = auth.uid() and exists (select 1 from public.posts p where p.id = post_id));
create policy likes_self_delete on public.post_likes for delete to authenticated using (user_id = auth.uid());
create policy bookmarks_owner_read on public.post_bookmarks for select to authenticated using (user_id = auth.uid());
create policy bookmarks_owner_insert on public.post_bookmarks for insert to authenticated with check (user_id = auth.uid());
create policy bookmarks_owner_delete on public.post_bookmarks for delete to authenticated using (user_id = auth.uid());
create policy reposts_read on public.post_reposts for select to anon, authenticated
using (exists (select 1 from public.posts p where p.id = post_id));
create policy reposts_owner_insert on public.post_reposts for insert to authenticated
with check (user_id = auth.uid() and exists (select 1 from public.posts p where p.id = post_id));
create policy reposts_owner_delete on public.post_reposts for delete to authenticated using (user_id = auth.uid());
create policy polls_read on public.polls for select to anon, authenticated
using (exists (select 1 from public.posts p where p.id = post_id));
create policy polls_create on public.polls for insert to authenticated with check (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid()));
create policy polls_owner_update on public.polls for update to authenticated using (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid())) with check (exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid()));
create policy poll_options_read on public.poll_options for select to anon, authenticated
using (exists (select 1 from public.polls po join public.posts p on p.id = po.post_id where po.id = poll_id));
create policy poll_options_create on public.poll_options for insert to authenticated with check (exists (select 1 from public.polls po join public.posts p on p.id = po.post_id where po.id = poll_id and p.author_id = auth.uid()));
create policy poll_votes_read on public.poll_votes for select to anon, authenticated
using (exists (select 1 from public.posts p join public.polls po on po.post_id = p.id where po.id = poll_id));
create policy poll_votes_self_insert on public.poll_votes for insert to authenticated with check (user_id = auth.uid() and exists (select 1 from public.poll_options o where o.id = option_id and o.poll_id = poll_id));
create policy poll_votes_self_delete on public.poll_votes for delete to authenticated using (user_id = auth.uid());
create policy comments_read on public.comments for select to anon, authenticated
using (exists (select 1 from public.posts p where p.id = post_id));
create policy comments_self_insert on public.comments for insert to authenticated
with check (author_id = auth.uid() and exists (select 1 from public.posts p where p.id = post_id));
create policy comments_self_update on public.comments for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy comments_self_delete on public.comments for delete to authenticated using (author_id = auth.uid());
create policy follows_read on public.follows for select to anon, authenticated using (true);
create policy follows_self_insert on public.follows for insert to authenticated with check (follower_id = auth.uid());
create policy follows_self_delete on public.follows for delete to authenticated using (follower_id = auth.uid());

-- Communities.
create policy communities_read on public.communities for select to anon, authenticated using (not is_private or owner_id = auth.uid() or exists (select 1 from public.community_members m where m.community_id = id and m.user_id = auth.uid()));
create policy communities_create on public.communities for insert to authenticated with check (owner_id = auth.uid());
create policy communities_owner_update on public.communities for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy communities_owner_delete on public.communities for delete to authenticated using (owner_id = auth.uid());
create policy community_members_read on public.community_members for select to authenticated using (true);
create policy community_members_join on public.community_members for insert to authenticated
with check (user_id = auth.uid() and exists (select 1 from public.communities c where c.id = community_id and (not c.is_private or c.owner_id = auth.uid())));
create policy community_members_leave on public.community_members for delete to authenticated using (user_id = auth.uid());

-- Debate and Q&A content.
create policy debates_read on public.debates for select to anon, authenticated using (true);
create policy debates_create on public.debates for insert to authenticated with check (host_id = auth.uid());
create policy debates_owner_update on public.debates for update to authenticated using (host_id = auth.uid()) with check (host_id = auth.uid());
create policy debates_owner_delete on public.debates for delete to authenticated using (host_id = auth.uid());
create policy debate_arguments_read on public.debate_arguments for select to anon, authenticated using (true);
create policy debate_arguments_insert on public.debate_arguments for insert to authenticated with check (author_id = auth.uid());
create policy debate_arguments_delete on public.debate_arguments for delete to authenticated using (author_id = auth.uid());
create policy debate_votes_read on public.debate_votes for select to anon, authenticated using (true);
create policy debate_votes_self_insert on public.debate_votes for insert to authenticated with check (user_id = auth.uid());
create policy debate_votes_self_update on public.debate_votes for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy questions_read on public.questions for select to anon, authenticated using (true);
create policy questions_insert on public.questions for insert to authenticated with check (author_id = auth.uid());
create policy questions_owner_update on public.questions for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy questions_owner_delete on public.questions for delete to authenticated using (author_id = auth.uid());
create policy answers_read on public.answers for select to anon, authenticated using (true);
create policy answers_insert on public.answers for insert to authenticated with check (author_id = auth.uid());
create policy answers_owner_update on public.answers for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy answers_owner_delete on public.answers for delete to authenticated using (author_id = auth.uid());
create policy answer_votes_read on public.answer_votes for select to anon, authenticated using (true);
create policy answer_votes_self_insert on public.answer_votes for insert to authenticated with check (user_id = auth.uid());
create policy answer_votes_self_delete on public.answer_votes for delete to authenticated using (user_id = auth.uid());

-- Private conversations. Security-definer helpers avoid recursive RLS policies
-- when checking membership in conversation_members itself.
create or replace function public.is_conversation_member(target_conversation uuid, target_user uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.conversation_members m where m.conversation_id = target_conversation and m.user_id = target_user); $$;
create or replace function public.is_conversation_creator(target_conversation uuid, target_user uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.conversations c where c.id = target_conversation and c.created_by = target_user); $$;
revoke all on function public.is_conversation_member(uuid, uuid) from public;
revoke all on function public.is_conversation_creator(uuid, uuid) from public;
grant execute on function public.is_conversation_member(uuid, uuid) to authenticated;
grant execute on function public.is_conversation_creator(uuid, uuid) to authenticated;

create policy conversations_member_read on public.conversations for select to authenticated
using (public.is_conversation_member(id, auth.uid()));
create policy conversations_create on public.conversations for insert to authenticated with check (created_by = auth.uid());
create policy conversation_members_read on public.conversation_members for select to authenticated
using (public.is_conversation_member(conversation_id, auth.uid()));
create policy conversation_members_add on public.conversation_members for insert to authenticated
with check (user_id = auth.uid() or public.is_conversation_creator(conversation_id, auth.uid()));
create policy conversation_members_leave on public.conversation_members for delete to authenticated using (user_id = auth.uid());
create policy messages_member_read on public.messages for select to authenticated
using (public.is_conversation_member(conversation_id, auth.uid()));
create policy messages_member_send on public.messages for insert to authenticated
with check (sender_id = auth.uid() and public.is_conversation_member(conversation_id, auth.uid()));
create policy messages_sender_delete on public.messages for delete to authenticated using (sender_id = auth.uid());

-- Podcasts and events.
create policy podcasts_read on public.podcasts for select to anon, authenticated using (true);
create policy podcasts_create on public.podcasts for insert to authenticated with check (creator_id = auth.uid());
create policy podcasts_owner_update on public.podcasts for update to authenticated using (creator_id = auth.uid()) with check (creator_id = auth.uid());
create policy podcasts_owner_delete on public.podcasts for delete to authenticated using (creator_id = auth.uid());
create policy episodes_read on public.podcast_episodes for select to anon, authenticated using (true);
create policy episodes_creator_insert on public.podcast_episodes for insert to authenticated with check (exists (select 1 from public.podcasts p where p.id = podcast_id and p.creator_id = auth.uid()));
create policy episodes_creator_update on public.podcast_episodes for update to authenticated using (exists (select 1 from public.podcasts p where p.id = podcast_id and p.creator_id = auth.uid())) with check (exists (select 1 from public.podcasts p where p.id = podcast_id and p.creator_id = auth.uid()));
create policy episodes_creator_delete on public.podcast_episodes for delete to authenticated using (exists (select 1 from public.podcasts p where p.id = podcast_id and p.creator_id = auth.uid()));
create policy podcast_subscriptions_read on public.podcast_subscriptions for select to authenticated using (true);
create policy podcast_subscriptions_self_insert on public.podcast_subscriptions for insert to authenticated with check (user_id = auth.uid());
create policy podcast_subscriptions_self_delete on public.podcast_subscriptions for delete to authenticated using (user_id = auth.uid());
create policy events_read on public.events for select to anon, authenticated using (true);
create policy events_create on public.events for insert to authenticated with check (host_id = auth.uid());
create policy events_owner_update on public.events for update to authenticated using (host_id = auth.uid()) with check (host_id = auth.uid());
create policy events_owner_delete on public.events for delete to authenticated using (host_id = auth.uid());
create policy event_attendees_read on public.event_attendees for select to anon, authenticated using (true);
create policy event_attendees_self_insert on public.event_attendees for insert to authenticated with check (user_id = auth.uid());
create policy event_attendees_self_update on public.event_attendees for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy event_attendees_self_delete on public.event_attendees for delete to authenticated using (user_id = auth.uid());

-- Personal notifications, reports and block list.
create policy notifications_owner_read on public.notifications for select to authenticated using (user_id = auth.uid());
create policy notifications_owner_update on public.notifications for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy reports_owner_create on public.content_reports for insert to authenticated
with check (reporter_id = auth.uid() and status = 'open');
create policy reports_owner_read on public.content_reports for select to authenticated using (reporter_id = auth.uid());
create policy blocks_owner_read on public.user_blocks for select to authenticated using (blocker_id = auth.uid());
create policy blocks_owner_insert on public.user_blocks for insert to authenticated with check (blocker_id = auth.uid());
create policy blocks_owner_delete on public.user_blocks for delete to authenticated using (blocker_id = auth.uid());

-- Storage buckets for profile images, post media and podcast audio.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('negros-avatars', 'negros-avatars', true, 5242880, array['image/jpeg','image/png','image/webp']),
  ('negros-post-media', 'negros-post-media', true, 20971520, array['image/jpeg','image/png','image/webp','video/mp4']),
  ('negros-podcast-audio', 'negros-podcast-audio', true, 104857600, array['audio/mpeg','audio/mp4','audio/aac','audio/ogg','audio/wav'])
on conflict (id) do nothing;

create policy "public can read negros media" on storage.objects for select to anon, authenticated
using (bucket_id in ('negros-avatars','negros-post-media','negros-podcast-audio'));
create policy "users upload own negros media" on storage.objects for insert to authenticated
with check (
  bucket_id in ('negros-avatars','negros-post-media','negros-podcast-audio')
  and (storage.foldername(name))[1] = auth.uid()::text
);
create policy "users update own negros media" on storage.objects for update to authenticated
using ((storage.foldername(name))[1] = auth.uid()::text)
with check ((storage.foldername(name))[1] = auth.uid()::text);
create policy "users delete own negros media" on storage.objects for delete to authenticated
using ((storage.foldername(name))[1] = auth.uid()::text);

-- Realtime publication for the live conversation experience.
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.notifications;
