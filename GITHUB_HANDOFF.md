# NEGROS — GitHub handoff and next engineering steps

## What you can do immediately

1. Create a GitHub repository named `negros-android` (or any name you prefer).
2. Extract this ZIP and upload the contents of the `NEGROS_Android` directory into the repository root. Do not upload only the ZIP itself.
3. Confirm the repository contains `.github/workflows/android.yml`, `app/build.gradle.kts`, `settings.gradle.kts`, and `supabase/migrations/0001_negros_schema.sql`.
4. Open **Actions** and enable workflows. Trigger **Build NEGROS Android APK**.
5. If the workflow fails, open the failed step and use its first Gradle/Kotlin error as the starting point; do not assume the APK was produced.

## Supabase setup

1. Open your Supabase project dashboard.
2. Go to SQL Editor → New query.
3. Paste the complete `supabase/migrations/0001_negros_schema.sql` file and run it once.
4. Enable Email in Authentication → Providers. Decide whether email confirmation is required for testing.
5. For GitHub Actions, add `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` under repository Settings → Secrets and variables → Actions. Use only the publishable key in the mobile client.
6. Never add a database password, Supabase secret key, or `service_role` key to the Android project or GitHub.

## Existing connected behavior

- Email sign-up/sign-in calls Supabase Auth.
- The feed can fetch rows from `public.posts`.
- Publishing creates a cloud post.
- Likes create/delete `public.post_likes` rows.
- Comments insert into `public.comments`.

These flows depend on successfully applying the SQL migration and enabling the Supabase project settings. They have not been verified against a live test account in this workspace.

## Remaining implementation work (not just configuration)

### Priority 1 — reliability and identity
- Compile and fix all Gradle/Kotlin errors in CI.
- Test sign-up, email confirmation, sign-in, sign-out and session restoration on two devices.
- Load real profile display names rather than the abbreviated author UUID currently used in cloud feed cards.
- Add account/profile editing and account deletion.
- Add robust loading, empty, offline and retry states.

### Priority 2 — real messaging
- Build conversation creation and participant management screens.
- Implement message history queries and message inserts through Supabase.
- Subscribe/unsubscribe to Realtime message changes in lifecycle-aware code.
- Test that only conversation members can read/send messages using separate accounts.
- Add pagination, delivery/read state and attachment handling.

### Priority 3 — complete the social modules
- Connect debate creation, arguments, rebuttals and voting to the existing schema.
- Connect Q&A creation, answers and answer votes.
- Connect community creation, membership and community feeds.
- Connect event creation and RSVP.
- Connect podcast channel/episode publishing and audio playback.
- Add search, follows, bookmarks, reposts and notifications.

### Priority 4 — media, safety and release
- Wire authenticated Storage uploads with file type/size checks and progress.
- Add reporting, blocking, moderation queues, appeals and admin tools.
- Add server-side rate limiting and abuse protection. Never grant admin roles from the client.
- Add privacy policy, terms, community standards, data export/deletion and backup plan.
- Run RLS/security tests with at least two normal accounts and an unauthenticated session.
- Create a signed release build only after security and privacy review.

## Product principle

NEGROS should not remove a viewpoint merely because it is unpopular or controversial. Rules should target harmful conduct (for example credible threats, doxxing, exploitation, spam, impersonation and unlawful content), with transparent decisions and an appeal process.
