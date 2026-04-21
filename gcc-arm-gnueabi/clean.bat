@echo off
REM Clean build artifacts
REM This removes the build/ directory

setlocal enabledelayedexpansion

echo.
echo ========================================
echo Cleaning build artifacts...
echo ========================================
echo.

if exist build (
    echo Removing build directory...
    rmdir /s /q build
    if %ERRORLEVEL% EQU 0 (
        echo Clean successful - build directory removed.
    ) else (
        echo WARNING: Could not remove all files.
    )
) else (
    echo Build directory not found - already clean.
)

echo.
echo ========================================
echo Clean complete!
echo ========================================
echo.
echo Next step: Run build.bat to rebuild the project
echo.

endlocal
