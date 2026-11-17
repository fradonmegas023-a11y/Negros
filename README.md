# NEGROS — Android social platform (GitHub handoff package)

**One Generation. Different Voices. One Society.**

NEGROS is an Android-first Kotlin + Jetpack Compose project backed by Supabase. This package is a working alpha foundation intended for GitHub build-and-test, not a finished public social network.

## Included in this package

- Android app source (Kotlin, Jetpack Compose, Material 3).
- Dark interface with Home, Explore, Create, Chats and Profile navigation.
- Feed categories for posts, debates, Q&A, podcasts and events.
- Local preview publishing and device persistence.
- Supabase email sign-up/sign-in integration.
- Supabase cloud feed, post publishing, likes and comments integration.
- Supabase SQL migration with tables and Row Level Security policies for profiles, posts, comments, follows, debates, Q&A, communities, conversations/messages, podcasts, events, notifications, reports, blocks and media buckets.
- GitHub Actions workflow to build a debug APK.
- Setup and handoff instructions.

## Honest implementation status

| Area | Status in this package |
|---|---|
| Android UI and navigation | Implemented alpha UI |
| Email authentication | Supabase client integration; requires migration and project Auth configuration |
| Cloud posts/feed | Supabase integration |
| Cloud likes/comments | Supabase integration |
| Offline/local demo feed | Implemented |
| Direct/group messaging | UI/local preview only; not live across devices |
| Realtime subscriptions | SQL publication configured; Android subscriptions not wired |
| Image/video/audio uploads | Storage buckets/policies in SQL; Android upload UI/client flow not wired |
| Podcast playback/creator publishing | Preview only; not connected to hosted audio |
| Events, communities, debate and Q&A | UI/schema foundation; full cloud workflows not wired |
| Push notifications | Not implemented |
| Moderation/admin dashboard | Not implemented |

Do not launch this build publicly or advertise all modules as live. The next engineering work is listed in `GITHUB_HANDOFF.md`.

## Quick start

1. Extract this ZIP.
2. Open the extracted `NEGROS_Android` directory in Android Studio.
3. Allow Gradle sync and install Android SDK 35 if prompted. Use JDK 17 for the Android build.
4. Run the SQL migration described in `SUPABASE_SETUP.md` in your Supabase project's SQL Editor.
5. Run the app on an emulator or Android phone.

The project includes the Supabase Project URL and publishable key previously supplied for this app in `negros.backend.properties`. A publishable key is intended for client apps. Never put a Supabase `service_role`/secret key or database password in this repository, Android source, or GitHub Actions secrets.

## Build an APK with GitHub Actions

1. Create a new GitHub repository.
2. Upload the **contents** of the extracted `NEGROS_Android` folder to the repository root. Make sure `.github/workflows/android.yml`, `app/`, `supabase/`, and the Gradle files are included.
3. In GitHub, open **Actions** and enable workflows if prompted.
4. The workflow builds on pushes to `main`/`master`, or you can run it manually using **Run workflow**.
5. Open the completed workflow run and download the `negros-debug-apk` artifact.
6. Extract the artifact and install `app-debug.apk` on your Android phone.

For a GitHub build connected to Supabase, add repository Actions secrets named `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. If you leave them unset, the build is configured for local-preview mode. The existing `negros.backend.properties` is used by local builds; keep it free of secret credentials.

## Before public launch

Implement and test live messaging, media upload, podcast audio, communities, events, debate/Q&A workflows, realtime subscriptions, push notifications, reporting/moderation and account deletion. Review RLS using multiple test accounts, add rate limits and abuse controls, publish privacy/terms/community rules, and produce a signed release build.

## Build verification note

This handoff package has been inspected for source/configuration and ZIP integrity. It has **not** been compiled or run on an Android SDK in this workspace. The GitHub Actions workflow is included to perform the Android build; a successful workflow run is the first compile verification.
