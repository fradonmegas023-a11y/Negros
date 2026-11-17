# NEGROS — Product specification

## Product statement

NEGROS is an intergenerational digital society built around expression, connection and the exchange of ideas. It combines social networking with structured debate, Q&A, podcasts, communities and events.

**Tagline:** One Generation. Different Voices. One Society.

## Expression policy

The product should not remove an opinion because it is unpopular, controversial, critical of a belief system, political institution, social norm or public figure. Disagreement is a core use case.

The product still needs narrow conduct rules for credible threats, incitement to violence, doxxing, non-consensual intimate imagery, exploitation, spam, impersonation and other unlawful or directly harmful conduct. Moderation decisions should target the conduct, not the viewpoint. Users should be able to mute, block, hide topics and control replies without suppressing the speaker for everyone.

## Main navigation

- Home: personalized and followed feed.
- Explore: Debate Arena, Ask Society, Podcasts, Communities, Events and Society Pulse.
- Create: post, debate, question, podcast episode and event.
- Chats: private and group conversations.
- Profile: identity, posts, following, followers, creator work and reputation.

## Core capabilities

### Social feed
Text, image, video and audio posts; comments and replies; likes; reposts; topic labels; sorting and feed controls.

### Debate Arena
A debate has a clear motion, host, opening statements, arguments for/against, rebuttals, audience questions and optional voting. Voting should measure audience sentiment, not determine whether an argument is allowed to exist.

### Ask Society
Questions can be public or pseudonymous. Answers support replies, votes and accepted answers. Pseudonymous does not mean untraceable to the platform in cases of serious abuse or legal obligations.

### Podcasts
Creator channels, episodes, audio playback, episode descriptions, follows and comments. Large media files should use object storage/CDN and not be stored in Postgres rows.

### Communities
Public/private groups, member roles, pinned posts, community-specific feeds, invitations and moderation controls.

### Events
Online/offline events, event pages, RSVP, reminders and live audio/video integrations in later releases.

### Messaging
One-to-one and group chats, membership checks, attachments, read receipts and realtime delivery. Message content must only be readable by conversation members.

## Roles

- Member: ordinary platform participation.
- Creator: podcast and media publishing tools.
- Community moderator: moderation within assigned communities.
- Platform moderator: handles reports and platform-level conduct enforcement.
- Platform administrator: configuration and role assignment.

Platform-level admin roles must be granted only through a trusted server/dashboard process. Never let a client app grant itself admin status.

## Monetization principle

Core expression, reading, posting, joining public discussions and ordinary messaging should remain free. Do not charge members to debate or participate. Optional creator tools, sponsorships and event tickets may be considered later, but must not paywall basic participation. Hosting, storage, bandwidth, moderation and compliance still have operating costs; a free backend tier is suitable for an early test, not a promise of unlimited free scale.

## Release roadmap

1. Alpha: authentication, profiles, feed, comments, reactions, follow graph.
2. Beta: debates, Q&A, communities, notifications and private chat.
3. Creator release: podcast uploads, media player, events and creator pages.
4. Public launch: reporting workflow, admin console, analytics, rate limits, privacy policy, terms, account deletion and security review.

## Non-functional requirements

- Android-first, responsive and accessible.
- Secure authentication and Row Level Security.
- No service-role secrets in mobile binaries.
- Rate limits and anti-spam controls.
- Account export and deletion workflow.
- User-controlled mute/block/filter tools.
- Clear moderation appeals and transparency reporting.
- Backups, error monitoring and performance metrics before public launch.
