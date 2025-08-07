@echo off
setlocal

echo Wiping Flutter app data...

:: === Change this to your Flutter app name ===
set APP_NAME=annotateit

:: === Get user profile base paths ===
set DB_PATH=%USERPROFILE%\AppData\Roaming\%APP_NAME%\databases
set DOCS_PATH=%USERPROFILE%\AppData\Roaming\%APP_NAME%\documents
set CACHE_PATH=%USERPROFILE%\AppData\Local\%APP_NAME%\cache
set PREFS_PATH=%USERPROFILE%\AppData\Roaming\%APP_NAME%\shared_prefs

:: === Delete database directory ===
if exist "%DB_PATH%" (
    echo Deleting DB at: %DB_PATH%
    rmdir /s /q "%DB_PATH%"
)

:: === Delete documents directory ===
if exist "%DOCS_PATH%" (
    echo Deleting documents at: %DOCS_PATH%
    rmdir /s /q "%DOCS_PATH%"
)

:: === Delete cache directory ===
if exist "%CACHE_PATH%" (
    echo Deleting cache at: %CACHE_PATH%
    rmdir /s /q "%CACHE_PATH%"
)

:: === Delete SharedPreferences (if used) ===
if exist "%PREFS_PATH%" (
    echo Deleting preferences at: %PREFS_PATH%
    rmdir /s /q "%PREFS_PATH%"
)

echo App data deleted.
