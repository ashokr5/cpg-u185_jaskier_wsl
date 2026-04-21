# GPIO_IOToggle - GNU Build System Setup

## 📋 Overview

This directory now contains a complete **GNU Make build system** for the STM32F401xE GPIO_IOToggle project. The setup enables you to build, flash, and debug the firmware using open-source tools instead of proprietary IDEs.

### What Was Added

| File | Purpose |
|------|---------|
| **Makefile** | GNU Make build configuration (main build file) |
| **BUILD_GUIDE.md** | Comprehensive build documentation |
| **QUICK_REFERENCE.md** | Quick-start guide and troubleshooting |
| **build.bat** | Windows batch script to build the project |
| **flash.bat** | Windows batch script to flash the device |
| **clean.bat** | Windows batch script to clean build artifacts |
| **debug.bat** | Windows batch script to start GDB debugging |
| **SETUP_GUIDE.md** | This file - overview and setup instructions |

---

## 🚀 Quick Start

### For Windows Users

1. **Prerequisite**: Install GNU ARM toolchain
   - Download: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
   - Extract and add `bin` folder to Windows PATH

2. **Build the project**:
   ```batch
   double-click build.bat
   ```

3. **Flash to device**:
   ```batch
   double-click flash.bat
   ```

### For Linux/Mac Users

1. **Install GNU ARM toolchain**:
   ```bash
   sudo apt-get install gcc-arm-none-eabi  # Ubuntu/Debian
   brew install arm-none-eabi-gcc          # macOS
   ```

2. **Build**:
   ```bash
   make
   ```

3. **Flash**:
   ```bash
   make flash
   ```

---

## 📁 Project Structure

```
GPIO_IOToggle/
├── Makefile                    ← GNU Make build configuration
├── BUILD_GUIDE.md             ← Full build documentation
├── QUICK_REFERENCE.md         ← Quick start guide
├── SETUP_GUIDE.md             ← This file
├── build.bat / flash.bat / ... ← Windows helper scripts
│
├── Src/                       ← Application source code
│   ├── main.c
│   ├── stm32f4xx_it.c        ← Interrupt handlers
│   ├── system_stm32f4xx.c    ← System initialization
│   └── ...
│
├── Inc/                       ← Application headers
│   ├── main.h
│   ├── stm32f4xx_hal_conf.h
│   └── ...
│
├── Drivers/                   ← STM32 HAL and CMSIS
│   ├── STM32F4xx_HAL_Driver/
│   ├── CMSIS/
│   └── BSP/STM32F4xx-Nucleo/
│
├── EWARM/                     ← IAR Embedded Workbench project
│   ├── startup_stm32f401xe.s ← Startup code
│   └── stm32f401xe_flash.icf ← Linker script
│
└── MDK-ARM/                   ← Keil µVision project
    └── ...
```

---

## 🎯 What This Project Does

**GPIO_IOToggle** is a simple embedded application that:

1. **Initializes the STM32F401xE microcontroller** with 84 MHz clock
2. **Configures PA05** as an output GPIO pin (LED2 on Nucleo board)
3. **Toggles the LED** every 100ms in an infinite loop

```c
while (1) {
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
    HAL_Delay(100);  // 100ms delay
}
```

**Result**: LED blinks with 200ms period (100ms on, 100ms off)

---

## 📋 Build System Details

### Compilation Flow

```
Source Files (*.c)
    ↓
Preprocessor
    ↓
Compiler (arm-none-eabi-gcc)
    ↓
Object Files (*.o)
    ↓
Linker (arm-none-eabi-ld)
    ↓
ELF File (executable)
    ↓
Object Copy (arm-none-eabi-objcopy)
    ↓
BIN / HEX Files (ready for flashing)
```

### Key Compilation Settings

- **Target**: STM32F401xE (ARM Cortex-M4)
- **Instruction Set**: Thumb-2 (16/32-bit)
- **FPU**: Hardware floating-point (fpv4-sp-d16)
- **Optimization**: -O2 (balanced)
- **Warnings**: All enabled (-Wall -Wextra)
- **Linker Script**: EWARM/stm32f401xe_flash.icf

### Minimal HAL Modules Included

The Makefile includes only the essential HAL drivers needed:
- `stm32f4xx_hal` - Core HAL
- `stm32f4xx_hal_gpio` - GPIO operations
- `stm32f4xx_hal_rcc` - Clock management
- `stm32f4xx_hal_cortex` - Core Cortex-M4 functions
- `stm32f4xx_hal_flash` - Flash initialization

This keeps the binary size small (~48 KB) for an embedded project.

---

## 🔧 Available Make Targets

### Build Commands
```bash
make            # Build the project
make all        # Same as above
make clean      # Remove build artifacts
make rebuild    # Clean + build
```

### Flash Commands
```bash
make flash      # Flash using st-flash (STLink)
make flash-openocd  # Flash using OpenOCD
```

### Debug Commands
```bash
make debug      # Start GDB debug session
```

### Information Commands
```bash
make info       # Show build configuration
make size       # Show firmware memory usage
make help       # Show all available targets
```

---

## 📊 Build Output

After a successful build, the `build/` directory contains:

```
build/
├── bin/
│   ├── GPIO_IOToggle.elf    ← Full executable with debug symbols
│   ├── GPIO_IOToggle.bin    ← Binary for flashing
│   ├── GPIO_IOToggle.hex    ← Intel HEX format
│   └── GPIO_IOToggle.map    ← Memory map
├── obj/                      ← Object files
├── lst/                      ← Assembly listings
└── deps/                     ← Dependency files (for incremental builds)
```

### Typical Firmware Size
- Text (code): ~40-50 KB
- Data: ~2 KB
- Total: ~50 KB out of 512 KB available

---

## 🔌 Hardware Setup

### Required Hardware
- **Board**: STM32F4xx-Nucleo (RevB or RevC)
- **USB Cable**: USB Mini-B to PC (for ST-LINK USB)
- **Debugger**: ST-LINK/V2 (onboard on Nucleo)

### LED Connections
- **LED Target**: PA05 (GPIO Port A, Pin 5)
- **Board**: LED2 (Green LED) on Nucleo board
- The project simply toggles this GPIO output every 100ms

### Flashing Methods
1. **ST-LINK** (via USB, recommended): `make flash`
2. **OpenOCD**: `make flash-openocd`
3. **STM32CubeProgrammer**: Manual GUI method

---

## ⚙️ Installation & Setup

### Windows

#### Step 1: Install GNU ARM Toolchain
1. Download from: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
2. Run the installer
3. Check "Add path to environment variable"
4. Verify installation:
   ```cmd
   arm-none-eabi-gcc --version
   ```

#### Step 2: Ensure GNU Make is Available
Option A: Install MSYS2
```cmd
choco install msys2  # If using Chocolatey
```
Or download from https://www.msys2.org/

Option B: Use MinGW
Download from http://www.mingw.org/

Verify:
```cmd
make --version
```

#### Step 3: Install ST-LINK Tools (for flashing)
```cmd
choco install st-link  # Via Chocolatey
```
Or download from: https://github.com/stlink-org/stlink/releases

#### Step 4: Build and Flash
```cmd
build.bat       # Or: make
flash.bat       # Or: make flash
```

### Linux (Ubuntu/Debian)

```bash
# Install toolchain
sudo apt-get update
sudo apt-get install gcc-arm-none-eabi build-essential

# Install ST-LINK tools (optional)
sudo apt-get install stlink-tools

# Build
make

# Flash
make flash
```

### macOS

```bash
# Install toolchain via Homebrew
brew install arm-none-eabi-gcc

# Install ST-LINK tools (optional)
brew install stlink

# Build
make

# Flash
make flash
```

---

## 🐛 Troubleshooting

### Build Issues

**"arm-none-eabi-gcc: command not found"**
- Install GNU ARM toolchain
- Verify PATH environment variable includes toolchain bin folder

**"make: command not found"**
- Install GNU make (part of build-essential on Linux)
- On Windows, install MSYS2 or MinGW

**Linker script not found: "stm32f401xe_flash.icf"**
- Ensure you're in the project root directory
- Verify EWARM/stm32f401xe_flash.icf exists
- Check file paths in Makefile use forward slashes

### Flash Issues

**"st-flash: command not found"**
- Install ST-LINK tools (see Installation section)

**Device not detected**
- Check USB cable connection
- Try different USB port
- Verify device appears in system (lsusb on Linux, Device Manager on Windows)
- Run `st-info --probe` to check connection

**Permission denied (Linux)**
- Add user to dialout group: `sudo usermod -a -G dialout $USER`
- Then log out and back in

### Runtime Issues

**LED not blinking after flash**
- Verify ST-LINK shows successful erase and write
- Try hardware reset button on board
- Check that PA05 is actually connected to LED2
- Verify supply voltage to board

---

## 📚 Documentation

1. **QUICK_REFERENCE.md** - Fast answers to common questions
2. **BUILD_GUIDE.md** - Comprehensive build documentation
3. **Makefile** - Inline comments explain each section
4. **README.txt** - Original project readme

---

## 🔄 Workflow Example

### Daily Development
```bash
# Start coding
edit Src/main.c

# Incremental build (only changed files compiled)
make

# Check firmware size
make size

# Flash to device
make flash

# Compare with IDE build
# - Build in IAR/Keil and compare outputs
```

### Release Build
```bash
# Clean and rebuild everything
make clean && make

# Verify size is reasonable
make size

# Create production binary
cp build/bin/GPIO_IOToggle.bin GPIO_IOToggle_release.bin
```

### Debugging Session
```bash
# In Terminal 1: Start OpenOCD
openocd -f board/st_nucleo_f4.cfg

# In Terminal 2: Start GDB
make debug

# Or manually:
arm-none-eabi-gdb build/bin/GPIO_IOToggle.elf \
    -ex "target remote localhost:3333" \
    -ex "load"
```

---

## 🎓 Learning Resources

- **ARM Cortex-M4 Architecture**: https://developer.arm.com/ip-products/processors/cortex-m/cortex-m4
- **STM32F401xE Datasheet**: https://www.st.com/resource/en/datasheet/stm32f401xe.pdf
- **STM32F4xx Reference Manual**: Available from ST Microelectronics website
- **GNU ARM Documentation**: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
- **OpenOCD Debugging**: http://openocd.org/

---

## 📝 Modifying the Project

### Adding New Source Files
1. Create file (e.g., `Src/mydriver.c`)
2. Edit Makefile, add to SOURCES:
   ```makefile
   SOURCES += Src/mydriver.c
   ```
3. Rebuild: `make clean && make`

### Changing Optimization
Edit Makefile CFLAGS:
```makefile
-O0    # No optimization (debugging)
-O2    # Balanced (default)
-O3    # Aggressive optimization
-Os    # Optimize for size
```

### Reducing Binary Size
```makefile
# In Makefile LDFLAGS section:
LDFLAGS += -specs=nano.specs  # Use newlib-nano (smaller)
LDFLAGS += -specs=nosys.specs # Remove system calls
```

### Adding Compiler Defines
```makefile
CFLAGS += -DMY_DEFINE=1
CFLAGS += -DDEBUG_ENABLED
```

---

## ✅ Verification Checklist

- [ ] GNU ARM toolchain installed and in PATH
- [ ] GNU Make installed and in PATH
- [ ] Project cloned/extracted to working directory
- [ ] Can run `make info` without errors
- [ ] Board connected via USB (ST-LINK)
- [ ] Build succeeds: `make clean && make`
- [ ] Firmware file created: `build/bin/GPIO_IOToggle.elf`
- [ ] Flash succeeds: `make flash`
- [ ] LED blinks on board after programming

---

## 🤝 Next Steps

1. **Understand the code**: Read `Src/main.c`
2. **Explore the build**: Run `make info` and check output files
3. **Try modifications**: Change LED toggle speed in `Src/main.c`
4. **Practice flashing**: Program the device with `make flash`
5. **Try debugging**: Use `make debug` and set breakpoints

---

## 📞 Support

For issues or questions:
1. Check QUICK_REFERENCE.md for common problems
2. Review BUILD_GUIDE.md for detailed explanations
3. Run `make info` to verify configuration
4. Check Makefile inline comments for tool details
5. Review error messages - they usually indicate the root cause

---

## 📄 License

This build system is provided for the GPIO_IOToggle project which uses STM32F4xx HAL Driver from STMicroelectronics (see included LICENSE files in the Drivers folder).

---

**Last Updated**: April 2026
**Version**: 1.0
**Target MCU**: STM32F401xE
**Toolchain**: GNU ARM Embedded (Cortex-M4)
