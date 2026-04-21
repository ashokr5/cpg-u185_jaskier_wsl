@echo off
REM Debug script for GPIO_IOToggle
REM This attaches GDB to OpenOCD for debugging

setlocal enabledelayedexpansion

echo.
echo ========================================
echo GPIO_IOToggle Debug Session
echo ========================================
echo.

REM Check if arm-none-eabi-gdb is available
where arm-none-eabi-gdb >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: arm-none-eabi-gdb not found!
    echo Please install GNU ARM Embedded Toolchain
    echo.
    pause
    exit /b 1
)

REM Check if ELF file exists
if not exist "build\bin\GPIO_IOToggle.elf" (
    echo ERROR: ELF file not found!
    echo Please build the project first: build.bat
    echo.
    pause
    exit /b 1
)

REM Check if OpenOCD is available
where openocd >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: OpenOCD not found!
    echo Debugging requires OpenOCD to be running separately.
    echo.
    echo Installation:
    echo   https://openocd.org/
    echo.
    echo In another terminal, start OpenOCD:
    echo   openocd -f board/st_nucleo_f4.cfg
    echo.
    echo Then press Enter to continue...
    pause
)

echo Starting GDB debug session...
echo.
echo GDB Commands:
echo   target remote localhost:3333    - Connect to OpenOCD
echo   load                            - Load firmware
echo   break main                      - Set breakpoint at main
echo   continue                        - Run until breakpoint
echo   step                           - Step into
echo   next                           - Step over
echo   quit                           - Exit GDB
echo.

REM Start GDB
arm-none-eabi-gdb build\bin\GPIO_IOToggle.elf ^
    -ex "target remote localhost:3333" ^
    -ex "break main" ^
    -ex "load"

endlocal
