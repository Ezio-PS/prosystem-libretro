DEBUG = 0

ifeq ($(platform),)
	platform = unix
	ifeq ($(shell uname -a),)
		platform = win
	else ifneq ($(findstring Darwin,$(shell uname -a)),)
		platform = osx
		arch = intel
		ifeq ($(shell uname -p),powerpc)
			arch = ppc
		endif
	else ifneq ($(findstring MINGW,$(shell uname -a)),)
		platform = win
	endif
endif

# system platform
system_platform = unix
ifeq ($(shell uname -a),)
	EXE_EXT = .exe
	system_platform = win
else ifneq ($(findstring Darwin,$(shell uname -a)),)
	system_platform = osx
	arch = intel
	ifeq ($(shell uname -p),powerpc)
		arch = ppc
	endif
else ifneq ($(findstring MINGW,$(shell uname -a)),)
	system_platform = win
endif

TARGET_NAME := prosystem

# Unix
ifeq ($(platform), unix)
	TARGET := $(TARGET_NAME)_libretro.so
	fpic := -fPIC
	SHARED := -shared -Wl,--no-undefined -Wl,--version-script=link.T
	CFLAGS+=-fsigned-char

# OS X
else ifeq ($(platform), osx)
	TARGET := $(TARGET_NAME)_libretro.dylib
	fpic := -fPIC
	SHARED := -dynamiclib
	ifeq ($(arch),ppc)
		FLAGS += -DMSB_FIRST
		OLD_GCC = 1
	endif
	OSXVER = `sw_vers -productVersion | cut -d. -f 2`
	OSX_LT_MAVERICKS = `(( $(OSXVER) <= 9)) && echo "YES"`
	fpic += -mmacosx-version-min=10.1

# iOS
else ifneq (,$(findstring ios,$(platform)))
	TARGET := $(TARGET_NAME)_libretro_ios.dylib
	fpic := -fPIC
	SHARED := -dynamiclib
	ifeq ($(IOSSDK),)
		IOSSDK := $(shell xcodebuild -version -sdk iphoneos Path)
	endif
	CC = cc -arch armv7 -isysroot $(IOSSDK)

ifeq ($(platform),ios9)
	CC     += -miphoneos-version-min=8.0
	SHARED += -miphoneos-version-min=8.0
else
	CC     += -miphoneos-version-min=5.0
	SHARED += -miphoneos-version-min=5.0
endif

# Theos
else ifeq ($(platform), theos_ios)
	DEPLOYMENT_IOSVERSION = 5.0
	TARGET = iphone:latest:$(DEPLOYMENT_IOSVERSION)
	ARCHS = armv7 armv7s
	TARGET_IPHONEOS_DEPLOYMENT_VERSION=$(DEPLOYMENT_IOSVERSION)
	THEOS_BUILD_DIR := objs
	include $(THEOS)/makefiles/common.mk

	LIBRARY_NAME = $(TARGET_NAME)_libretro_ios

# QNX
else ifeq ($(platform), qnx)
	TARGET := $(TARGET_NAME)_libretro_$(platform).so
	fpic := -fPIC
	SHARED := -shared -Wl,--no-undefined -Wl,--version-script=link.T
	CC = qcc -Vgcc_ntoarmv7le

# PS3
else ifeq ($(platform), ps3)
	TARGET := $(TARGET_NAME)_libretro_$(platform).a
	CC = $(CELL_SDK)/host-win32/ppu/bin/ppu-lv2-gcc.exe
	AR = $(CELL_SDK)/host-win32/ppu/bin/ppu-lv2-ar.exe
	STATIC_LINKING = 1
	FLAGS += -DMSB_FIRST
	OLD_GCC = 1

# Lightweight PS3 Homebrew SDK
else ifeq ($(platform), psl1ght)
	TARGET := $(TARGET_NAME)_libretro_$(platform).a
	CC = $(PS3DEV)/ppu/bin/ppu-gcc$(EXE_EXT)
	AR = $(PS3DEV)/ppu/bin/ppu-ar$(EXE_EXT)
	STATIC_LINKING = 1
	FLAGS += -DMSB_FIRST
	OLD_GCC = 1
	
# sncps3
else ifeq ($(platform), sncps3)
	TARGET := $(TARGET_NAME)_libretro_ps3.a
	CC = $(CELL_SDK)/host-win32/sn/bin/ps3ppusnc.exe
	AR = $(CELL_SDK)/host-win32/sn/bin/ps3snarl.exe
	STATIC_LINKING = 1
	FLAGS += -DMSB_FIRST
	NO_GCC = 1

# PSP
else ifeq ($(platform), psp1)
	TARGET := $(TARGET_NAME)_libretro_$(platform).a
	CC = psp-gcc$(EXE_EXT)
	AR = psp-ar$(EXE_EXT)
	STATIC_LINKING = 1
	FLAGS += -G0

# Vita
else ifeq ($(platform), vita)
	TARGET := $(TARGET_NAME)_libretro_$(platform).a
	CC = arm-vita-eabi-gcc$(EXE_EXT)
	AR = arm-vita-eabi-ar$(EXE_EXT)
	STATIC_LINKING = 1
	FLAGS += -DVITA

# CTR (3DS)
else ifeq ($(platform), ctr)
	TARGET := $(TARGET_NAME)_libretro_$(platform).a
	CC = $(DEVKITARM)/bin/arm-none-eabi-gcc$(EXE_EXT)
	AR = $(DEVKITARM)/bin/arm-none-eabi-ar$(EXE_EXT)
	FLAGS += -DARM11 -D_3DS
	STATIC_LINKING = 1

# Raspberry Pi 1
else ifeq ($(platform), rpi1)
	TARGET := $(TARGET_NAME)_libretro.so
	fpic := -fPIC
	SHARED := -shared -Wl,--no-undefined -Wl,--version-script=link.T
	CFLAGS+=-fsigned-char
	FLAGS += -DARM11 
	FLAGS += -marm -march=armv6j -mfpu=vfp -mfloat-abi=hard
	FLAGS += -fomit-frame-pointer -ffast-math

# Raspberry Pi 2
else ifeq ($(platform), rpi2)
	TARGET := $(TARGET_NAME)_libretro.so
	fpic := -fPIC
	SHARED := -shared -Wl,--no-undefined -Wl,--version-script=link.T
	CFLAGS+=-fsigned-char
	FLAGS += -DARM 
	FLAGS += -marm -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard
	FLAGS += -fomit-frame-pointer -ffast-math

# Raspberry Pi 3
else ifeq ($(platform), rpi3)
	TARGET := $(TARGET_NAME)_libretro.so
	fpic := -fPIC
	SHARED := -shared -Wl,--no-undefined -Wl,--version-script=link.T
	CFLAGS+=-fsigned-char
	FLAGS += -DARM 
	FLAGS += -marm -marm -mcpu=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard
	FLAGS += -fomit-frame-pointer -ffast-math

else ifeq ($(platform), emscripten)
	TARGET := $(TARGET_NAME)_libretro_$(platform).bc
	STATIC_LINKING = 1

# Windows
else
	TARGET := $(TARGET_NAME)_libretro.dll
	CC = gcc
	SHARED := -shared -Wl,--no-undefined -Wl,--version-script=link.T
	LDFLAGS += -static-libgcc -static-libstdc++ -lwinmm

endif

CORE_DIR := core

include Makefile.common

OBJECTS := $(SOURCES_C:.c=.o)

ifeq ($(DEBUG),1)
FLAGS += -O0 -g
else
FLAGS += -O2 -DNDEBUG
endif

LDFLAGS += $(fpic) $(SHARED)
FLAGS += $(fpic) 
FLAGS += $(INCFLAGS)

ifeq ($(OLD_GCC), 1)
WARNINGS := -Wall
else ifeq ($(NO_GCC), 1)
WARNINGS :=
else
WARNINGS := -Wall \
	-Wno-sign-compare \
	-Wno-unused-variable \
	-Wno-unused-function \
	-Wno-uninitialized \
	-Wno-strict-aliasing \
	-Wno-overflow \
	-fno-strict-overflow
endif

FLAGS += -D__LIBRETRO__ $(WARNINGS)

CFLAGS += $(FLAGS)

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

ifeq ($(platform), theos_ios)
COMMON_FLAGS := -DIOS $(COMMON_DEFINES) $(INCFLAGS) -I$(THEOS_INCLUDE_PATH) -Wno-error
$(LIBRARY_NAME)_CFLAGS += $(CFLAGS) $(COMMON_FLAGS)
${LIBRARY_NAME}_FILES = $(SOURCES_C)
include $(THEOS_MAKE_PATH)/library.mk
else
all: $(TARGET)
$(TARGET): $(OBJECTS)
ifeq ($(STATIC_LINKING), 1)
	$(AR) rcs $@ $(OBJECTS)
else
	$(CC) -o $@ $^ $(LDFLAGS)
endif

clean:
	rm -f $(TARGET) $(OBJECTS)

.PHONY: clean
endif
