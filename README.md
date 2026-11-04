# Student Academic Assistant

A beginner-friendly Flutter app for managing school tasks, subject reviewers,
and study flashcards. Version 1 stores data on the device with
`shared_preferences`; it does not need an account or an internet connection.

## Run the application

Install Flutter and an Android emulator or connect an Android device, then run
these commands from this project folder:

```shell
flutter pub get
flutter run
```

To run the application on iOS, use a Mac with Xcode and run `flutter run` there.

Run the automated widget test and analyzer with:

```shell
flutter test
flutter analyze
```

## Source files

- `lib/main.dart` - app startup, Material 3 theme, and bottom navigation.
- `lib/models/study_models.dart` - task, reviewer, and flashcard data types.
- `lib/state/app_state.dart` - app data and local save/load operations.
- `lib/widgets/app_widgets.dart` - small shared UI and date helpers.
- `lib/pages/dashboard_page.dart` - welcome screen, counts, recent tasks, and shortcuts.
- `lib/pages/task_manager_page.dart` - add, complete, and delete tasks.
- `lib/pages/reviewers_page.dart` - create, view, edit, and delete reviewers.
- `lib/pages/flashcards_page.dart` - create, study, navigate, and delete flashcards.
- `assets/images/study_logo.png` - the supplied logo used in the app and launcher icons.
- `test/widget_test.dart` - a basic navigation and task-creation test.

The `android/` and `ios/` folders contain Flutter's generated platform files.
To regenerate launcher icons after changing the logo, run
`dart run flutter_launcher_icons`.
