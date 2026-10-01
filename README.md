# FPL Team Viewer

An iOS app that lists Fantasy Premier League teams and shows each team's squad grouped by position.

## Build and Run

1. Open `FPLTeamViewer.xcodeproj` in Xcode.
2. Select the `FPLTeamViewer` scheme and an iOS 18.2+ simulator or device.
3. Press **Run** (⌘R). Run unit tests with **Test** (⌘U).

No third-party dependencies or setup are required.

## Assumptions

- Data comes from the public `https://fantasy.premierleague.com/api/bootstrap-static/` endpoint; no authentication is needed.
- Players belong to a team via the player's `team` field matching the team's `id`.
- Within each position, players are ordered by total FPL points (highest first), then by name.
- Price is shown as returned by the API (`now_cost`, in tenths of a million).
- Cached data has no expiry. It's only shown when a request fails, never instead of fresh data.

## Architecture

**MVVM with Builder and Router**, one folder per feature (`TeamList`, `TeamSquad`):

- **Model**: `Decodable` structs matching the API, plus data transformation (`LegueModel.makeSections`, `position(for:)`) so it's reusable and easy to test.
- **ViewModel**: screen state and logic (loading, errors, caching fallback, search). No UIKit, so it's unit-testable.
- **View/ViewController**: UIKit table views that render view model state.
- **Builder**: creates and wires each module's dependencies.
- **Router**: handles navigation, for example pushing the squad screen with the selected team and league data.
- **APIService protocol**: lets `APIManager` be swapped for `MockAPIManager` in tests.
- **ViewState enum** (`Utility`): shared states (initial loading, loaded, initial failure, refreshing, refresh failure, empty).

MVVM keeps concerns separated and fits the size of the current requirements without the overhead of heavier patterns.

## Improvements With More Time

- Persist cached data with Core Data or SwiftData, with an expiry policy.
- Add UI tests for the main flows (list, squad, search, error and retry states).
- Add a loading and error state to the squad screen, and show when cached data is being displayed.
- Add friendlier error messages (for example, a specific "no internet" message).

## Known Limitations

- The cache lives in the Caches folder, so iOS can delete it when the device is low on storage.
- Cached data never expires, so it can be stale after a long time offline.
- Only the team list uses `ViewState`; the squad screen relies on data passed from the list.
- No UI tests yet; unit tests cover decoding, data transformation, search, error handling and caching.
