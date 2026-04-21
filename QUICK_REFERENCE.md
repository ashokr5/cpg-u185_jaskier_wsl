# Quick Build Reference

## TL;DR - Quick Start

### Prerequisites Check
```bash
# Verify toolchain is installed
arm-none-eabi-gcc --version

# Verify make is available
make --version
```

### Fast Track Build & Flash
```bash
# One-liner: Clean build and flash
make clean && make && make flash
```

### Common Commands

| Command | Purpose |
|---------|---------|
| `make` | Build (incremental) |
| `make clean` | Remove build artifacts |
| `make all` | Full build (same as `make`) |
| `make flash` | Program device |
| `make size` | Show firmware size |
| `make info` | Show build config |
| `make help` | List all targets |

---

## Project Summary

| Feature | Detail |
|---------|--------|
| **MCU** | STM32F401xE (Cortex-M4, 84 MHz) |
| **Function** | Toggle LED on PA05 every 100ms |
| **Board** | STM32F4xx Nucleo RevB/C |
| **Framework** | STM32F4xx HAL |
| **IDE Support** | IAR (EWARM), Keil (MDK-ARM), GNU Make |

---

## What Happens During Build

1. **Compilation** - C source files → object files (`*.o`)
2. **Assembly** - Startup code compiled
3. **Linking** - All object files combined with HAL libraries
4. **Binary Generation** - ELF → Binary/Hex formats
5. **Size Report** - Memory usage displayed

Output: `build/bin/GPIO_IOToggle.{elf,bin,hex}`

---

## Build Directory Structure

```
build/
├── bin/           ← Output files (ELF, BIN, HEX)
├── obj/           ← Object files (.o) - intermediate
├── lst/           ← Listing files (.lst)
└── deps/          ← Dependency tracking (.d)
```

Delete `build/` folder to do a clean rebuild.

---

## Troubleshooting

### Q: "No such file or directory: stm32f401xe_flash.icf"
**A:** Ensure you're in the project root directory and the file exists at `EWARM/stm32f401xe_flash.icf`

### Q: Device not detected for flashing
**A:** 
- Plug in USB cable
- Check drivers: `st-info --probe`
- Use different USB port
- Check OpenOCD: `openocd -f board/st_nucleo_f4.cfg`

### Q: Permission denied when flashing
**A:** Add USB permissions (Linux):
```bash
sudo usermod -a -G dialout $USER
```

### Q: "undefined reference to `malloc`"
**A:** The nano newlib is already used. If needed, disable heap in linker script.

---

## File Locations Quick Ref

```
Makefile          ← The build configuration (in root)
BUILD_GUIDE.md    ← Full documentation
Inc/              ← Header files (.h)
Src/              ← Source files (.c)
Drivers/          ← STM32 drivers and CMSIS
EWARM/            ← IAR project + startup + linker script
```

---

## Build Examples

### Minimal Debug Build (for development)
```bash
# Compile with debug symbols, minimal optimization
make clean
make
```

### Production Build (optimized for size)
Edit Makefile:
```makefile
CFLAGS += -Os  # Optimize for size instead of -O2
```
Then:
```bash
make clean && make
```

### Verbose Build (see all compiler messages)
```bash
make -B  # Force all files to rebuild
make verbose  # Show all variables
```

---

## Firmware Installation Methods

### Method 1: ST-LINK Command Line (Simplest)
```bash
st-flash write build/bin/GPIO_IOToggle.bin 0x08000000
```

### Method 2: Makefile Target
```bash
make flash
```

### Method 3: OpenOCD + GDB
```bash
make flash-openocd
```

### Method 4: STM32CubeProgrammer GUI
1. Open `build/bin/GPIO_IOToggle.bin`
2. Set start address: `0x08000000`
3. Click "Start Programing"

---

## Success Indicators

✅ **Good Build:**
```
[CC] Src/main.c
[CC] Src/system_stm32f4xx.c
...
[LD] build/bin/GPIO_IOToggle.elf
====== Firmware Size ======
   text    data     bss     dec     hex filename
  48256    1908    8456   58620   e4ac build/bin/GPIO_IOToggle.elf
Build complete!
```

❌ **Build Failed:**
```
stm32f401xe_flash.icf: no such file or directory
```
→ Check file paths and working directory

---

## Getting Help

1. Run `make help` - shows all targets
2. Run `make info` - shows configuration
3. Check `BUILD_GUIDE.md` - comprehensive guide
4. Review error messages - usually very informative

---

## Next Steps

After successful build:
1. **Flash:** `make flash`
2. **Verify:** LED should blink after reset
3. **Debug:** Use `make debug` to attach GDB
4. **Modify:** Edit `Src/main.c` to change LED behavior
5. **Rebuild:** `make` will incrementally rebuild changed files

