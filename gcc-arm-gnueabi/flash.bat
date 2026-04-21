@echo off
REM Flash the firmware to STM32F401xE device
REM Requires: st-flash tool (STLink utilities)

setlocal enabledelayedexpansion

echo.
echo ========================================
echo Flashing GPIO_IOToggle to Device
echo Target: STM32F401xE at 0x08000000
echo ========================================
echo.

REM Check if st-flash is available
where st-flash >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: st-flash tool not found!
    echo.
    echo Please install ST-LINK Tools:
    echo   - Download from: https://github.com/stlink-org/stlink/releases
    echo   - Or install via package manager
    echo.
    echo Windows installation:
    echo   1. Download st-link release
    echo   2. Extract to a folder
    echo   3. Add to PATH environment variable
    echo.
    pause
    exit /b 1
)

REM Check if binary file exists
if not exist "build\bin\GPIO_IOToggle.bin" (
    echo ERROR: Firmware binary not found at build\bin\GPIO_IOToggle.bin
    echo.
    echo Please build the project first:
    echo   build.bat
    echo.
    pause
    exit /b 1
)

echo Firmware file: build\bin\GPIO_IOToggle.bin
echo Flash address: 0x08000000
echo.
echo Make sure the board is connected via ST-LINK USB...
echo.

REM Flash the device
st-flash write build\bin\GPIO_IOToggle.bin 0x08000000

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Flash successful!
    echo The device has been programmed.
    echo.
    echo The device will be reset automatically.
    echo LED on PA05 should start blinking.
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo Flash FAILED!
    echo ========================================
    echo.
    echo Troubleshooting:
    echo   1. Check USB connection
    echo   2. Try different USB port
    echo   3. Verify ST-LINK drivers are installed
    echo   4. Run: st-info --probe
    echo.
    pause
    exit /b 1
)

endlocal
