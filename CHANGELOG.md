# Changelog

All notable changes to the RG10 iOS app are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Photo gallery: browse photos in a grid with a full-screen viewer, backed by Supabase.
- In-app password reset: recovery emails now deep-link back into the app via `rg10://` and open a reset-password screen, so passwords can be changed without leaving the app.
- Image performance utilities for photo-heavy screens: downsampled async image loading and a memory monitor.
- Shared Xcode scheme so the project builds consistently across machines and CI.
- TST 2026 spotlight on the Home tab linking to a dedicated screen and the team-gear store.

### Changed

- Store now shows the live Flite Sports team-gear collection: products, images, and prices are fetched live from the official store, and tapping a product opens the real storefront in an in-app browser for size selection, cart, and checkout. The previous in-app Stripe merchandise checkout was removed (Stripe still powers training subscriptions and booking payments).
- "TST 2026" copy updated from upcoming ("we're coming", "applied to compete") to past tense ("we competed at TST 2026").

### Fixed

- Removed the broken username sign-in path: it depended on a database table that never existed, so it always failed with a confusing "User not found" after a doomed network call. Sign-in is now email-only with a clear validation message; usernames are still captured at sign-up for display.
- Stopped tracking editor state files (`.DS_Store`, `xcuserdata`) that were committed despite being gitignored, eliminating noisy diffs.
