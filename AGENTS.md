# Repository Guidelines

## Project Structure & Module Organization
Core SwiftUI views live in `Views/`, split by feature (e.g., `Views/Connect`, `Views/Links`, `Views/Auth`). Shared palettes and typography live in `Theme/`, service stubs in `Services/`, while static resources (mock JSON, fonts) sit in `Resources/`. Assets are managed through `Assets.xcassets` and supporting documents (e.g., `FIREBASE_SETUP.md`, `LOGO_ISTRUZIONI.md`) describe external integrations. Keep prototypes and helper scripts inside the repo root (`*.sh`, `create_project.py`) and avoid scattering binaries outside `build/`.

## Build, Test, and Development Commands
Use Xcode for day‑to‑day work: `open Lymbo.xcodeproj` and target iOS 18+. For CI or headless validation run `xcodebuild -scheme Lymbo -destination "platform=iOS Simulator,name=iPhone 15" build` to ensure the SwiftUI target compiles. The SPM manifest allows `swift build` from the root for quick syntax checks. Add tests to `Tests/` and execute them with `swift test` or `xcodebuild test` once targets exist.

## Coding Style & Naming Conventions
Follow Swift 5.9 defaults with 4-space indentation and explicit access modifiers for shared APIs. Views and models use `UpperCamelCase` (`ConnectView`, `EventsView`), local bindings and state use `lowerCamelCase`. Prefer small, composable SwiftUI structs and keep previews gated with `#Preview`. Color and spacing tokens should reference `Theme/ColorScheme.swift`; add new assets to `Assets.xcassets` using kebab-case folders that match Figma tokens.

## Testing Guidelines
There is no test target yet—create `Tests/LymboTests` when adding logic beyond pure UI. Name test files after the type under test (`ConnectViewModelTests.swift`) and use the XCTest pattern `test_componentBehavior_expectation()`. Aim for coverage on swipe matching logic, filtering, and any networking code added under `Services/`. Document fixtures in `Resources/` and keep deterministic data for snapshot tests.

## Commit & Pull Request Guidelines
Existing history favors short, descriptive messages (“Ridisegnata sezione Events…”). Continue using imperative present tense, optionally in Italian to stay consistent, and limit to ~72 characters. Pull requests should include: purpose summary, linked Linear/Jira issue, screenshots or screen recordings for UI tweaks, and a checklist covering build/test results (`xcodebuild` or simulator run). Tag reviewers who own the touched feature folder and call out any follow-up work.
