# ShopEase – Flutter REST API Assignment

A beginner-friendly product catalogue app built with Flutter, DummyJSON, Dio, Provider and Hive.

## API Used
- API: https://dummyjson.com/products
- Search reference: https://dummyjson.com/products/search?q=phone
- Pagination: `limit` and `skip` query parameters.
- DummyJSON is a practice API. Its product endpoint is treated as read-only in this project. Create, Update and Delete are therefore implemented locally with Hive.

## Features
- Splash screen and product home screen
- Product grid with responsive 2/3/4-column layout
- Product search
- Product details and additional fields
- Add, edit and delete products locally
- Hive local cache for offline viewing
- API pagination with infinite scrolling
- Pull-to-refresh
- Loading, empty and offline/error states
- Light and dark themes (system preference)

## Packages
- `dio`: HTTP requests
- `provider`: state management
- `hive`, `hive_flutter`: local database/cache
- `cached_network_image`: product image caching

## Project Structure
```text
lib/
  data/
    datasources/
    models/
    repositories/
  presentation/
    screens/
    widgets/
  providers/
  main.dart
```

## How to Run
1. Install Flutter SDK and Android Studio / Xcode.
2. Create a Flutter project:
   ```bash
   flutter create --platforms=android,ios shopease
   ```
3. Copy this package's `lib/`, `pubspec.yaml`, and `analysis_options.yaml` into the generated project, replacing files when prompted.
4. Open the project folder in VS Code.
5. Run:
   ```bash
   flutter pub get
   flutter analyze
   flutter run
   ```

For iOS builds, use macOS with Xcode. Android can be built on Windows, macOS or Linux.

## Build APK
```bash
flutter build apk --release
```
APK location:
`build/app/outputs/flutter-apk/app-release.apk`

## Screenshots
Add your own screenshots here after running the app:
- `screenshots/home.png`
- `screenshots/details.png`
- `screenshots/add-edit.png`

## CRUD Behaviour
Since DummyJSON is not used as a persistent backend, local CRUD changes are stored in Hive. The local cache is retained when the app is closed and reopened. Deletions are marked locally so a later API refresh does not bring the deleted product back.

## Notes
- Internet is needed for the first API download.
- Previously cached products remain available offline.
- Product images may need internet unless they have already been cached by the image package.
