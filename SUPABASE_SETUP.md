# NEGROS — connect to the supplied Supabase project

The Android build is preconfigured with the project URL and **publishable** key supplied for NEGROS. The publishable key is designed for use in client applications; never put a Supabase secret/service-role key in Android code or GitHub.

## A. Apply the database schema (required once)

1. Open https://supabase.com/dashboard and select the NEGROS project.
2. Open **SQL Editor** → **New query**.
3. On your PC, open `supabase/migrations/0001_negros_schema.sql`.
4. Copy the entire file into the SQL Editor and click **Run**.
5. Confirm the query finishes successfully. The migration creates app tables, indexes, Row Level Security policies, storage buckets and Realtime publication entries.

Do not skip this step. The app cannot read or write the cloud feed until the schema exists in your project.

## B. Check Supabase project settings

- In **Authentication → Providers**, ensure Email is enabled.
- For the first test, you may turn off email confirmation in **Authentication → Settings** so test accounts can sign in immediately. Before public launch, configure the confirmation flow you want.
- In **Project Settings → API → Data API**, ensure the `public` schema is exposed.
- In **Database → Publications**, confirm `messages` and `notifications` are in `supabase_realtime` after running the migration.

## C. Run the Android app

1. Extract this ZIP.
2. Open the extracted `NEGROS_Android` folder in Android Studio.
3. Let Gradle sync and install Android SDK 35 if prompted.
4. Connect your Android phone with USB debugging enabled, or use an emulator.
5. Press **Run**.

The included `negros.backend.properties` supplies the project URL and publishable key for this local build. Android Studio's `local.properties` remains available for its `sdk.dir` setting. The app should show the sign-in / create-account screen instead of the offline demo when configured.

## D. First backend test

1. Create a test account in NEGROS.
2. Sign in.
3. Publish a post.
4. Open Supabase Dashboard → **Table Editor → posts** and confirm the post appears.
5. Sign in with a second test account on another device and confirm the post is visible; test likes and comments.

If signup requires email confirmation, confirm the email before signing in.

## Current implementation boundary

This build connects the Android app's email sign-up/sign-in, cloud feed, post publishing, likes and comments to Supabase. The SQL migration also lays out tables and policies for the broader platform. However, the chat screen is still a local UI preview: end-to-end message sending/receiving and realtime chat subscriptions are not yet wired into the Android screens. Media upload, podcast streaming, push notifications, moderation tools and live rooms also remain to be implemented and tested. This is a connected backend foundation, not a claim that every social feature is finished.

## GitHub APK builds

For GitHub Actions builds, add repository Actions secrets:
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

The workflow reads these secrets. Never add a Supabase secret/service-role key or database password.

## Security before public launch

Review RLS policies with at least two test accounts; add rate limits and abuse reporting; test account deletion; review storage upload limits and MIME types; configure backups; and publish privacy, terms and community standards.
