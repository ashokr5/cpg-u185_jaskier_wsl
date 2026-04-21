# GPIO_IOToggle Project - Build Documentation

## Project Overview

**GPIO_IOToggle** is an embedded firmware application for the STM32F401xE microcontroller (ARM Cortex-M4) that demonstrates GPIO pin toggling functionality.

### Key Features:
- **Target Device**: STM32F401xE (Nucleo-F4 Development Board)
- **Application**: Toggles the LED on GPIO PA05 (LED2 - Green) every 100ms
- **System Clock**: 84 MHz (configured via HSI with PLL)
- **Framework**: STM32F4xx Hardware Abstraction Layer (HAL)

### Hardware:
- **Development Board**: STM32F4xx-Nucleo RevB/C
- **Target Pin**: PA05 (LED2, Green)
- **LED Behavior**: Blinking with 100ms toggle interval (200ms period total)

---

## Project Structure

```
GPIO_IOToggle/
├── Makefile                               # GNU Make build configuration (NEW)
├── Inc/                                   # Application header files
│   ├── main.h                            # Main application header
│   ├── stm32f4xx_hal_conf.h             # HAL library configuration
│   └── stm32f4xx_it.h                   # Interrupt handlers header
│
├── Src/                                   # Application source files
│   ├── main.c                           # Main application logic
│   ├── stm32f4xx_it.c                   # Interrupt service routines
│   ├── system_stm32f4xx.c               # System initialization
│   ├── eink.c/h                         # E-Ink display driver (optional)
│   └── images.c/h                       # Image data (optional)
│
├── Drivers/
│   ├── CMSIS/                           # Cortex Microcontroller Software Interface Standard
│   │   ├── Include/                     # CMSIS core headers
│   │   └── Device/ST/STM32F4xx/        # STM32F4xx device headers and startup
│   │
│   ├── STM32F4xx_HAL_Driver/           # STM32F4xx Hardware Abstraction Layer
│   │   ├── Inc/                        # HAL library headers
│   │   └── Src/                        # HAL library implementations
│   │
│   └── BSP/STM32F4xx-Nucleo/           # Board Support Package
│       ├── stm32f4xx_nucleo.c/h        # Nucleo board configuration
│       └── LICENSE.txt
│
├── EWARM/                               # IAR Embedded Workbench files
│   ├── Project.ewp/eww/ewd             # IAR project files
│   ├── startup_stm32f401xe.s           # ARM Cortex-M4 startup code
│   └── stm32f401xe_flash.icf           # IAR linker script
│
└── MDK-ARM/                             # Keil µVision project files
    ├── Project.uvprojx                 # Keil project file
    └── startup_stm32f401xe.s           # Startup code (same as EWARM)
```

---

## Building the Project

### Prerequisites

1. **GNU ARM Embedded Toolchain**: arm-none-eabi-gcc
   - Download: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
   - Version: 9.3.1 or later recommended

2. **Make**: GNU make utility
   - Linux/Mac: Usually pre-installed; `sudo apt-get install build-essential` on Ubuntu
   - Windows: Install MSYS2, MinGW, or add toolchain path to PATH

3. **Flash Tools** (optional, for programming device):
   - st-flash (STLink utilities)
   - OpenOCD
   - STM32CubeProgrammer

### Installation on Windows

#### Option 1: Using MSYS2
```bash
# Download and install MSYS2 from https://www.msys2.org/
pacman -S mingw-w64-i686-gcc-toolchain mingw-w64-i686-make
```

#### Option 2: Using the Official STM32CubeF4
- Include the toolchain with your STM32 IDE installation
- Add toolchain `bin` directory to Windows PATH

---

## Build Commands

### Basic Build
```bash
# Build the entire project
make

# Same as above (all is default target)
make all
```

### Clean Build
```bash
# Remove all build artifacts
make clean

# Full clean rebuild
make clean && make
```

### Flash to Device
```bash
# Flash using st-flash (ST-LINK v2)
make flash

# Alternative: Flash using OpenOCD
make flash-openocd
```

### Debugging
```bash
# Start GDB debugging session with OpenOCD
make debug
```

### Display Information
```bash
# Show firmware size (ROM and RAM usage)
make size

# Display build configuration
make info

# Show all build targets and usage
make help

# Show source files and object files (debug)
make verbose
```

---

## Build Output

After successful build, the following files are generated in `build/` directory:

```
build/
├── bin/
│   ├── GPIO_IOToggle.elf     # ELF executable (with symbols for debugging)
│   ├── GPIO_IOToggle.bin     # Binary file (for flashing)
│   ├── GPIO_IOToggle.hex     # Intel HEX format (alternative flashing format)
│   └── GPIO_IOToggle.map     # Memory map (symbol locations and memory usage)
│
├── obj/                       # Object files (.o) - one per source file
│
├── lst/                       # Listing files (.lst) - assembly with source code
│
└── deps/                      # Dependency files (.d) - for incremental builds
```

### File Descriptions:
- **`.elf`** - Executable and Linkable Format. Contains all debugging information. Used with GDB debuggers.
- **`.bin`** - Raw binary. Most compact format for flashing.
- **`.hex`** - Intel HEX format. Text-based, easy to verify by humans, supports addresses.
- **`.map`** - Shows all symbols and their memory addresses. Useful for memory optimization.

---

## Compiler Configuration Details

### Target MCU Flags
```makefile
CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
```
- `cortex-m4`: ARM Cortex-M4 processor
- `-mthumb`: Use Thumb instruction set (more compact)
- `-mfloat-abi=hard`: Use hardware FPU (Floating-Point Unit)
- `-mfpu=fpv4-sp-d16`: ARMv7E-M floating point co-processor

### Optimization Flags
```makefile
-O2                           # Optimize for speed and code size balance
-fno-common                   # Place uninitialized variables in BSS section
-ffunction-sections           # Place each function in separate section
-fdata-sections               # Place each data item in separate section
```

The `-ffunction-sections` and `-fdata-sections` combined with linker `--gc-sections` enable unused code elimination.

### Compiler Warnings
All warnings are enabled to catch potential issues:
```makefile
-Wall -Wextra -Wshadow -Wstrict-prototypes
-Wwrite-strings -Wredundant-decls -Wuninitialized
```

### Linker Script
The project uses the IAR Embedded Workbench linker script:
```
EWARM/stm32f401xe_flash.icf
```

**Alternatives:**
- Create a GNU-compatible `.ld` script (currently not included)
- Use `-specs=nano.specs` for reduced libc footprint

---

## Memory Layout (STM32F401xE)

```
Flash Memory:     512 KB (0x08000000 - 0x0807FFFF)
  ├── Bootloader:  (if present)
  └── Firmware:    (compiled image)

SRAM:             96 KB (0x20000000 - 0x20017FFF)
  ├── Data:       (initialized variables)
  ├── BSS:        (uninitialized variables)
  ├── Heap:       (dynamic memory, malloc)
  └── Stack:      (grows downward from top)
```

Check actual usage with:
```bash
make size
```

---

## Common Build Issues and Solutions

### Issue 1: "arm-none-eabi-gcc: command not found"
**Solution:**
- Install ARM toolchain
- Add toolchain `bin` directory to PATH:
  ```bash
  export PATH="/path/to/toolchain/bin:$PATH"  # Linux/Mac
  # Or set in Windows Environment Variables
  ```

### Issue 2: "make: command not found" (Windows)
**Solution:**
- Install GNU make via MSYS2, MinGW, or Chocolatey
- Verify: `make --version`

### Issue 3: Build fails with linker error
**Solution:**
- Ensure `EWARM/stm32f401xe_flash.icf` exists
- Check file paths in Makefile (use forward slashes)
- Verify all source files exist

### Issue 4: Device not found during flash
**Solution:**
- Check USB cable connection
- Install ST-LINK drivers
- Verify device with: `st-info --probe` or `openocd`
- Check OpenOCD configuration: `board/st_nucleo_f4.cfg`

---

## Customization

### Adding New Source Files
Edit the `SOURCES` variable in Makefile:
```makefile
SOURCES += Src/myfile.c
SOURCES += Drivers/MyDriver/driver.c
```

### Changing Optimization Level
Modify `CFLAGS`:
```makefile
-O0   # No optimization (for debugging)
-O2   # Balanced (default)
-O3   # Aggressive optimization
-Os   # Optimize for size
```

### Reducing Binary Size
```makefile
# Use newlib-nano (smaller C library)
LDFLAGS += -specs=nano.specs -specs=nosys.specs
```

### Adding Compiler Defines
```makefile
CFLAGS += -DUSE_HAL_DRIVER
CFLAGS += -DUSE_FULL_ASSERT
CFLAGS += -DMY_CUSTOM_DEFINE=1
```

### Custom HAL Configuration
Edit `Inc/stm32f4xx_hal_conf.h` to enable/disable HAL modules.

---

## Flashing Options

### Using ST-LINK/V2 (Recommended)
```bash
make flash
```

Requires: `st-link` package installed

### Using OpenOCD
```bash
make flash-openocd
```

Requires OpenOCD installed with Nucleo board config.

### Manual Flashing
```bash
# Using st-flash
st-flash write build/bin/GPIO_IOToggle.bin 0x08000000

# Using cubeprogram CLI
STM32_Programmer_CLI.exe -c port=SWD -d build/bin/GPIO_IOToggle.bin -v
```

---

## Debugging

### With GDB and OpenOCD
```bash
# Terminal 1: Start OpenOCD
openocd -f board/st_nucleo_f4.cfg

# Terminal 2: Start GDB
make debug
```

### GDB Commands
```gdb
target remote localhost:3333    # Connect to OpenOCD
load                             # Load binary
break main                       # Set breakpoint
continue                         # Run
step                            # Step into
next                            # Step over
quit                            # Exit
```

---

## Performance Characteristics

### Firmware Size Example (Typical)
```
Text (code):      ~40-50 KB
Data (init vars): ~1 KB
BSS (uninit):     ~2 KB
Total:            ~50 KB
```

### Build Time
- Clean build: ~2-5 seconds
- Incremental rebuild: <1 second

---

## References

- **STM32F401xE Datasheet**: https://www.st.com/resource/en/datasheet/stm32f401xe.pdf
- **STM32F4xx Reference Manual**: Available from ST Microelectronics
- **STM32CubeF4 Documentation**: Included in repository
- **ARMv7-M Architecture**: ARM cortex-m4 documentation
- **GNU ARM GCC**: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm

---

## Version History

- **v1.0** (Apr 2026): Initial GNU Makefile created
  - Support for STM32F401xE
  - Build, flash, and debug targets
  - Complete HAL driver integration

---

## Support

If you encounter issues:
1. Check `make info` output matches your setup
2. Verify all required files exist
3. Ensure toolchain is properly installed
4. Check file paths use correct separators
5. Review compilation errors carefully

