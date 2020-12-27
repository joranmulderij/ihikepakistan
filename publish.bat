@echo off
cls
echo [92mUpdate Firebase RemoteConfig![92m
echo.
echo [0mBuild Web.[0m

flutter build web --release

echo deploy hosting

firebase deploy

cmd /k