################################################################################
# Makefile for STM32F4xx GPIO_IOToggle Project
# Target MCU: STM32F401xE (Cortex-M4)
# Toolchain: GNU ARM Embedded Toolchain (arm-none-eabi-gcc)
# 
# Usage:
#   make              - Build the project
#   make clean        - Remove build artifacts
#   make flash        - Flash the binary to device (requires st-flash or openocd)
#   make info         - Display build information
################################################################################

# Project Configuration
PROJECT_NAME = GPIO_IOToggle
TARGET_MCU = STM32F401xE
DEVICE_DEF = STM32F401xE

# Build Output Directories
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin
LST_DIR = $(BUILD_DIR)/lst
DEPS_DIR = $(BUILD_DIR)/deps

# Toolchain
TOOLCHAIN_PREFIX = arm-none-eabi
CC = $(TOOLCHAIN_PREFIX)-gcc
AS = $(TOOLCHAIN_PREFIX)-gcc -x assembler-with-cpp
LD = $(TOOLCHAIN_PREFIX)-ld
AR = $(TOOLCHAIN_PREFIX)-ar
OC = $(TOOLCHAIN_PREFIX)-objcopy
OD = $(TOOLCHAIN_PREFIX)-objdump
SZ = $(TOOLCHAIN_PREFIX)-size

# Detect toolchain path (optional - for cross-platform support)
TOOLCHAIN_PATH ?= $(shell which $(CC) 2>/dev/null)
ifeq ($(TOOLCHAIN_PATH),)
  $(warning ARM toolchain not found in PATH. Ensure $(CC) is installed.)
endif

# MCU Processor Flags
CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16

# Compiler Flags
CFLAGS = $(CPU_FLAGS)
CFLAGS += -std=gnu99
CFLAGS += -Wall -Wextra -Wshadow -Wstrict-prototypes
CFLAGS += -Wwrite-strings -Wredundant-decls -Wuninitialized
CFLAGS += -Wno-missing-field-initializers
CFLAGS += -O2
CFLAGS += -fno-common
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -DUSE_HAL_DRIVER
CFLAGS += -D$(DEVICE_DEF)

# Assembler Flags
ASFLAGS = $(CPU_FLAGS)
ASFLAGS += -c
ASFLAGS += -DUSE_HAL_DRIVER
ASFLAGS += -D$(DEVICE_DEF)

# Linker Flags
LDFLAGS = $(CPU_FLAGS)
LDFLAGS += -specs=nano.specs
LDFLAGS += -T$(LINKER_SCRIPT)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,--print-memory-usage
LDFLAGS += -Wl,--strict-libraries
LDFLAGS += -lc -lm -lnosys
LDFLAGS += -Wl,-Map=$(BIN_DIR)/$(PROJECT_NAME).map

# Include Paths
INCLUDES = -IInc
INCLUDES += -IDrivers/CMSIS/Include
INCLUDES += -IDrivers/CMSIS/Device/ST/STM32F4xx/Include
INCLUDES += -IDrivers/STM32F4xx_HAL_Driver/Inc
INCLUDES += -IDrivers/BSP/STM32F4xx-Nucleo

# Source Files - Application
SOURCES = Src/main.c
SOURCES += Src/stm32f4xx_it.c
SOURCES += Src/system_stm32f4xx.c
SOURCES += Src/eink.c
SOURCES += Src/images.c

# Source Files - HAL (minimal set needed for GPIO and system clock)
SOURCES += Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c
SOURCES += Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c
SOURCES += Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c
SOURCES += Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c
SOURCES += Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c
SOURCES += Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c
SOURCES += Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c

# Source Files - BSP
SOURCES += Drivers/BSP/STM32F4xx-Nucleo/stm32f4xx_nucleo.c

# Startup File (Assembler)
STARTUP_ASM = EWARM/startup_stm32f401xe.s

# Linker Script
LINKER_SCRIPT = EWARM/stm32f401xe_flash.icf

# Optional: If using a .ld linker script instead of .icf
# LINKER_SCRIPT = Linker/stm32f401xe_flash.ld

# Object Files
OBJS = $(SOURCES:%.c=$(OBJ_DIR)/%.o)
OBJS += $(STARTUP_ASM:%.s=$(OBJ_DIR)/%.o)

# Dependency Files
DEPS = $(OBJS:%.o=%.d)

# Output Files
ELF = $(BIN_DIR)/$(PROJECT_NAME).elf
BIN = $(BIN_DIR)/$(PROJECT_NAME).bin
HEX = $(BIN_DIR)/$(PROJECT_NAME).hex
LST = $(LST_DIR)/$(PROJECT_NAME).lst

# Default Target
.PHONY: all clean flash info help
all: $(ELF) $(BIN) $(HEX) $(LST) size

# Create Build Directories
$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR) $(addprefix $(OBJ_DIR)/,Src Drivers/STM32F4xx_HAL_Driver/Src Drivers/BSP/STM32F4xx-Nucleo EWARM)

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(LST_DIR):
	@mkdir -p $(LST_DIR)

# Compile C Source Files
$(OBJ_DIR)/%.o: %.c | $(OBJ_DIR) $(DEPS_DIR)
	@echo [CC] $<
	@$(CC) -c $(CFLAGS) $(INCLUDES) -MMD -MP -MF $(DEPS_DIR)/$*.d -o $@ $<

# Assemble Startup File
$(OBJ_DIR)/%.o: %.s | $(OBJ_DIR) $(DEPS_DIR)
	@echo [AS] $<
	@$(AS) $(ASFLAGS) $(INCLUDES) -MMD -MP -MF $(DEPS_DIR)/$*.d -o $@ $<

# Link Object Files
$(ELF): $(OBJS) $(LINKER_SCRIPT) | $(BIN_DIR)
	@echo [LD] $@
	@$(CC) $(LDFLAGS) $(OBJS) -o $@
	@echo Build complete: $(ELF)

# Generate Binary File
$(BIN): $(ELF)
	@echo [OC] Generating binary: $@
	@$(OC) -O binary $< $@

# Generate Hex File
$(HEX): $(ELF)
	@echo [OC] Generating hex: $@
	@$(OC) -O ihex $< $@

# Generate List File
$(LST): $(ELF)
	@echo [OD] Generating listing: $@
	@$(OD) -S $< > $@

# Display Size Information
.PHONY: size
size: $(ELF)
	@echo 
	@echo ====== Firmware Size ======
	@$(SZ) -A -d $<

# Flash Firmware to Device (using st-link)
.PHONY: flash
flash: $(BIN)
	@echo Flashing firmware to STM32F401xE...
	st-flash write $(BIN) 0x08000000
	@echo Flash complete!

# Flash Firmware to Device (alternative: using openocd)
.PHONY: flash-openocd
flash-openocd: $(ELFEXE)
	@echo Flashing firmware using OpenOCD...
	openocd -f board/st_nucleo_f4.cfg \
		-c "init" \
		-c "reset init" \
		-c "flash write_image erase $(ELF)" \
		-c "reset" \
		-c "shutdown"

# Debug: Start GDB with OpenOCD
.PHONY: debug
debug: $(ELF)
	@echo Starting GDB debug session...
	$(TOOLCHAIN_PREFIX)-gdb $(ELF) \
		-ex "target remote localhost:3333" \
		-ex "load" \
		-ex "break main" \
		-ex "continue"

# Display Build Information
.PHONY: info
info:
	@echo ===== Build Configuration =====
	@echo Project: $(PROJECT_NAME)
	@echo Target: $(TARGET_MCU)
	@echo Toolchain: $(TOOLCHAIN_PREFIX)-gcc
	@echo Build Directory: $(BUILD_DIR)
	@echo
	@echo Compiler: $(CC)
	@echo Assembler: $(AS)
	@echo Linker: $(LD)
	@echo
	@echo CFLAGS: $(CFLAGS)
	@echo ASFLAGS: $(ASFLAGS)
	@echo LDFLAGS: $(LDFLAGS)
	@echo
	@echo Include Paths:
	@echo $(INCLUDES)
	@echo
	@echo Source Files: $(SOURCES)
	@echo Startup File: $(STARTUP_ASM)
	@echo Linker Script: $(LINKER_SCRIPT)

# Help Message
.PHONY: help
help:
	@echo "GPIO_IOToggle Build System (GNU ARM)"
	@echo ""
	@echo "Available Targets:"
	@echo "  make              - Build the project (default)"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make flash        - Flash to device (requires st-link)"
	@echo "  make debug        - Start GDB debugging session"
	@echo "  make info         - Display build configuration"
	@echo "  make size         - Display firmware size"
	@echo "  make help         - Display this help message"
	@echo ""
	@echo "Configuration Variables:"
	@echo "  TOOLCHAIN_PREFIX  - ARM toolchain prefix (default: arm-none-eabi)"
	@echo ""
	@echo "Examples:"
	@echo "  make TOOLCHAIN_PREFIX=arm-none-eabi"
	@echo "  make clean && make"
	@echo "  make flash"

# Clean Build Artifacts
.PHONY: clean
clean:
	@echo Cleaning build artifacts...
	@rm -rf $(BUILD_DIR)
	@echo Clean complete!

# Include Dependency Files
-include $(DEPS)

# Print Variables (for debugging)
.PHONY: printvars
printvars:
	@$(foreach V,$(sort $(.VARIABLES)),$(if $(filter-out environment% default automatic, $(origin $V)),$(warning $V=$($V))))

.PHONY: verbose
verbose:
	@echo Sources: $(SOURCES)
	@echo Objects: $(OBJS)
	@echo Dependencies: $(DEPS)
