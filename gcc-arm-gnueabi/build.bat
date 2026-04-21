@echo off
REM GPIO_IOToggle Project - Build Script for Windows
REM This script builds the GPIO_IOToggle firmware using GNU Make

setlocal enabledelayedexpansion

echo.
echo ========================================
echo GPIO_IOToggle Build System
echo Target: STM32F401xE
echo ========================================
echo.

REM Check if make is available
where make >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: GNU make not found!
    echo Please ensure make is installed and in your PATH.
    echo.
    echo Installation options:
    echo   1. MSYS2: pacman -S mingw-w64-i686-make
    echo   2. MinGW: Download from http://www.mingw.org/
    echo   3. Toolchain: Use arm-none-eabi toolchain with make included
    echo.
    pause
    exit /b 1
)

REM Check if arm-none-eabi-gcc is available
where arm-none-eabi-gcc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ARM toolchain (arm-none-eabi-gcc) not found!
    echo Please install GNU ARM Embedded Toolchain:
    echo   https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
    echo.
    pause
    exit /b 1
)

echo ARM Toolchain:
arm-none-eabi-gcc --version
echo.

REM Run make build
echo Building GPIO_IOToggle...
echo.

REM Check for command line arguments
if "%1"=="" (
    REM Default: clean build
    make clean
    echo.
    make all
) else if "%1"=="clean" (
    make clean
) else if "%1"=="flash" (
    make flash
) else if "%1"=="debug" (
    make debug
) else if "%1"=="info" (
    make info
) else if "%1"=="help" (
    make help
) else (
    REM Pass argument to make
    make %1
)

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build successful!
    echo Output: build\bin\GPIO_IOToggle.elf
    echo         build\bin\GPIO_IOToggle.bin
    echo         build\bin\GPIO_IOToggle.hex
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo Build FAILED!
    echo ========================================
    echo.
    pause
    exit /b 1
)

endlocal
