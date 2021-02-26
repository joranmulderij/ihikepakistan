@echo off

cd admin

call python main.py

cd ..

call move admin\sample.json repo\hikes.json

cd repo

call firebase deploy

rem set /p notes="Release notes: "


rem call firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app 1:1080382637840:android:18a0f5ac355c0d14f9c795 --release-notes "%notes%" --groups "beta"

rem call flutter build web --release

rem call firebase deploy

set /p DUMMY=Hit ENTER to continue...
