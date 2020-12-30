@echo off

set /p notes="Release notes: "


call firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app 1:1080382637840:android:18a0f5ac355c0d14f9c795 --release-notes "%notes%" --groups "beta"

call flutter build web --release

call firebase deploy

set /p DUMMY=Hit ENTER to continue...