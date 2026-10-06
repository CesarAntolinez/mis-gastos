# First Expense Vertical Slice

## Goal
Bootstrap the Flutter application and deliver the approved first end-to-end expense slice on a clean worktree from `origin/main`.

## Problem and why now
Issue #1 is approved, but the repository has no executable Flutter app or reproducible development environment. A small real slice must validate the accepted Flutter + Drift + Riverpod + go_router architecture before broader MVP work.

## Confirmed scope
- Minimal setup for one cash account, including an optional available-cash opening amount; seed initial expense categories idempotently.
- Minimal app shell and summary with available balance; register an expense; show it in expense history and open its detail.
- Record historical NEEDS/WANTS bucket on the operation. Category defaults only propose a bucket.
- Keep product COP-only, local/offline-first, and preserve 50/30/20 semantics without implementing analytics cards/charts.
- Use Flutter + Dart, SQLite + Drift, Riverpod, and go_router; follow the accepted design system and light/dark direction.

## Non-goals
Income, transfers, savings flows, reimbursements, loans/debts, full onboarding for all financial products, editing/voiding, filters, analytics/dashboard indicators, authentication, cloud sync, iOS environment, emulator-in-Docker, and full CI/CD.

## Accepted decisions
- First-slice `OperationKind` values: `expense` and `opening_balance`; defer all other kinds until their flows are authorized.
- A positive initial available-cash amount is an `opening_balance` event; `$0` creates no zero-value event and never counts as income.
- Persist the historical NEEDS/WANTS bucket on the operation; never derive historical classification from a subsequently changed category.
- Flutter stable 3.47.5 / Dart 3.13.4 is pinned from the official release JSON: archive `stable/linux/flutter_linux_3.47.5-stable.tar.xz`, SHA-256 `2132e990f236f8d22e7c6314b29a191a95b10d7cbcfec9b4e2e303d996652cbb`. Recheck official release evidence immediately before freezing the image.
- Keep the existing dirty worktree untouched. Worktree: `D:/Repositories/mis-gastos-expense-slice`, branch `feature/first-expense-slice`, base `origin/main` at `c9bdd2f7fab51d4e9106517415731e4c0fee3df8`.

## Constraints and workflow
- Read canonical product and architecture docs before changing behavior; record accepted ADR-009 resolutions before schema freeze.
- Preserve native/mobile design skill rules and avoid placeholder/dead controls.
- Use test-first for domain/persistence/UI behavior when deterministic tests are applicable: observe RED, implement minimum behavior, observe GREEN, refactor with focused checks. Tooling-only bootstrap has no meaningful pre-existing RED; use structural/toolchain verification and document why.
- Use the repository-pinned Docker environment for Flutter checks, code generation, and Android builds; do not require Flutter on the host.
- No push, PR, merge, or release. The user explicitly authorized a local work-unit commit for task 1 only; future task commits require separate explicit authorization.
- Route multi-file writes through one bounded `gentle-ai-worker` per task; delegate command-running verification to `gentle-ai-verify`.
- Keep future delivery aligned with the previously selected `stacked-to-main` strategy; no publishing is authorized.

## Acceptance criteria
- Clean checkout provides a documented Docker workflow with exact Flutter/Dart and compatible Android/JDK tooling versions; no `latest`-only pin.
- Docker workflow can run dependency resolution, formatting/checks, `flutter analyze`, `flutter test`, Drift generation, and build an Android APK without an emulator.
- App opens into a complete minimal setup path, seeds categories idempotently, and creates/selects the cash account.
- A user can register a COP expense with date, category, and bucket; balance derives from persisted entries and the expense appears in history/detail.
- Money calculations use integer minor units, not `double`; financial rules stay outside widgets/providers/SQL triggers.
- No flow outside confirmed scope is exposed as a dead control or placeholder.
- Relevant domain, persistence, and widget tests pass in the pinned container; light/dark themes use the approved design-system direction.
- Existing dirty worktree contents remain unchanged.

## Work units and status
1. **Bootstrap pinned Docker toolchain and Flutter app** — implementation and checks pass; the user authorized the local work-unit commit, which is not yet created. Preserve the existing scaffold.
2. **Record schema decisions and build tested domain kernel** — pending. Update ADR-009 for the two accepted operation kinds and operation-level bucket; implement money/date/operation domain types with tests.
3. **Add Drift schema, account setup, and idempotent category seed** — pending. Implement schema/migrations and persistence tests, including opening-balance zero/positive behavior.
4. **Add expense use case and derived balance/history queries** — pending. Test expense registration, bucket snapshot, balance derivation, and detail/history reads.
5. **Compose shell, setup, expense entry, and history/detail UI** — pending. Riverpod/go_router, accessible light/dark interfaces, summary and no placeholder routes; widget tests.
6. **Run integrated verification and reconcile evidence** — pending. Use exact pinned Docker commands for format, analyze, tests, codegen, and APK; record failures/skips and final worktree state.

## Verification evidence
- `gh issue view 1 --json number,title,state,labels,url,body`: issue #1 is OPEN and has `status:approved`; body confirms Docker tooling, minimal account setup, expense, derived balance, history/detail, and tests; out-of-scope list excludes analytics, income, transfers, reimbursements, debt, iOS, emulator-in-Docker, and full CI/CD.
- Delegated requirements map: clean repository has no `pubspec.yaml`, `lib/`, `test/`, `Dockerfile`, or CI; accepted design-system docs exist.
- Docker Engine 29.7.2 was available in a prior read-only check; host `flutter` and `dart` commands are absent. ADR-008 makes host SDK optional and requires a reproducible Docker toolchain.
- Official `releases_linux.json` was fetched directly from `https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`; the 3.47.5 entry confirms Dart 3.13.4, archive path, and SHA-256 above, matching the Dockerfile pin.
- Read-only audit found a complete-looking toolchain scaffold: Ubuntu 24.04, OpenJDK 21, Android command-line tools 15859902, platform android-36, build-tools 36.0.0, NDK 28.2.13676358, Flutter 3.47.5 / Dart 3.13.4; Compose service `app` mounts `app/` and caches Pub/Gradle. The successful container build and APK build exercised this combination; a non-fatal Android SDK XML-version warning remains.
- The app scaffold contains a minimal Material 3 light/dark welcome page and matching smoke test; Drift, Riverpod, and go_router are not yet added (later tasks). The audit flagged unused `flutter_localizations` and generated `com.example.mis_gastos` applicationId; decide whether to remove/defer before freezing.
- The first writer was cancelled at the user's pause request after creating the partial scaffold; cancellation returned no implementation summary or verification results. The current Git status is recorded separately below; no generated scaffold was discarded.
- Initial `docker compose config --quiet` passed; the first image build was blocked by the missing Docker engine pipe. After the user authorized a Docker Desktop start attempt, `docker desktop start` said the application was already running and a subsequent `docker info` succeeded with server version 29.7.2.
- Once Docker was reachable, all task-1 checks passed: `docker compose build app`; Flutter 3.47.5 / Dart 3.13.4 version checks; `flutter pub get`; `dart format --output=none --set-exit-if-changed .` (2 files, 0 changed); `flutter analyze` (no issues); `flutter test` (1 passed); and `flutter build apk` (release APK 43.7 MB). APK build emitted a non-fatal Android SDK XML-version warning.
- A separate parent spot-check of `docker compose run --rm app flutter analyze` also passed with no issues. No host install or commit occurred.
- `gentle_review assess` returned `unassessable` because untracked paths require explicit declaration; native plan treats this as high risk and requests writer self-verification plus independent verification. The original writer was cancelled and returned no self-verification report; the separate verifier ran the full suite and the parent spot-check passed. No native review candidate/commit exists yet.
- Git status after checks: modified `app/.gitignore` and `docs/development/workflow.md`; untracked `.dockerignore`, `Dockerfile`, `compose.yaml`, `app/.metadata`, `app/README.md`, `app/analysis_options.yaml`, `app/android/`, `app/lib/`, `app/pubspec.lock`, `app/pubspec.yaml`, `app/test/`, and this `odd/` task record. `app/.gitignore` was corrected so the generated application lockfile is not ignored. Original dirty worktree remains untouched.

## Next step
Stage only the reviewed task-1 files and create the authorized local Conventional Commit, with no push or PR. Then assess the committed range from `origin/main` and follow the native review plan before closing the task. Keep the original dirty worktree untouched.
