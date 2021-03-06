OUTPUT := ./

PRODUCT_NAME := documentbuilder
PRODUCT_VERSION ?= 0.0.0

ifeq ($(OS),Windows_NT)
    PLATFORM := win
    EXEC_EXT := .exe
    SCRIPT_EXT := .bat
    SHARED_EXT := .dll
    ARCH_EXT := .zip
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        PLATFORM := linux
	SCRIPT_EXT := .sh
        SHARED_EXT := .so*
        ARCH_EXT := .tar.gz
    endif
endif

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	ARCHITECTURE := 64
	ARCH_SUFFIX := x64
endif
ifneq ($(filter %86,$(UNAME_M)),)
	ARCHITECTURE := 32
	ARCH_SUFFIX := x86
endif

PACKAGE_NAME := $(PRODUCT_NAME)-$(PRODUCT_VERSION)
ARCHIVE_NAME := $(PACKAGE_NAME)-$(ARCH_SUFFIX)$(ARCH_EXT)

PACKAGE := $(OUTPUT)/$(PACKAGE_NAME)
ARCHIVE := $(OUTPUT)/$(ARCHIVE_NAME)

TARGET := $(PLATFORM)_$(ARCHITECTURE)

BINARY_FILES += core/build/lib/$(TARGET)/*$(SHARED_EXT)

ifeq ($(PLATFORM),linux)
BINARY_FILES += core/Common/3dParty/icu/$(TARGET)/build/libicudata$(SHARED_EXT)
BINARY_FILES += core/Common/3dParty/icu/$(TARGET)/build/libicuuc$(SHARED_EXT)
BINARY_FILES += core/Common/3dParty/v8/$(TARGET)/icudtl_dat.S
endif

ifeq ($(PLATFORM),win)
BINARY_FILES += core/Common/3dParty/icu/$(TARGET)/build/icudt55$(SHARED_EXT)
BINARY_FILES += core/Common/3dParty/icu/$(TARGET)/build/icuuc55$(SHARED_EXT)
BINARY_FILES += core/Common/3dParty/v8/$(TARGET)/release/icudt.dll
endif

BINARY_FILES += core/build/bin/$(TARGET)/x2t$(EXEC_EXT)
#TODO Build docbuilder
BINARY_FILES += core/build/bin/$(TARGET)/docbuilder$(EXEC_EXT)

BINARY_FILES += DoctRenderer.config

BINARY_FILES += samples$(SCRIPT_EXT)

HTML_FILE_INTERNAL := HtmlFileInternal
HTML_FILE_INTERNAL_FILES += core/build/lib/$(TARGET)/HtmlFileInternal$(EXEC_EXT)
HTML_FILE_INTERNAL_FILES += core/Common/3dParty/cef/$(TARGET)/build/**

FOLDERS += web-apps/deploy/sdkjs
FOLDERS += empty
FOLDERS += samples

JQUERY += web-apps/deploy/web-apps/vendor/jquery
XREGEXP += web-apps/deploy/web-apps/vendor/xregexp

#TODO REFACTORING FILE PATH
INCLUDE_FILES += core/DesktopEditor/doctrenderer/docbuilder.h
INCLUDE_FILES += core/DesktopEditor/common/base_export.h

WRAPPERS_FILES += core/build/lib/$(TARGET)/docbuilder.com.dll
WRAPPERS_FILES += core/build/lib/$(TARGET)/docbuilder.net.dll

.PHONY: all clean

all: $(ARCHIVE)

$(ARCHIVE): $(PACKAGE)

$(PACKAGE):
	mkdir -p $(PACKAGE)
	cp -t $(PACKAGE) $(BINARY_FILES)
	mkdir -p $(PACKAGE)/$(HTML_FILE_INTERNAL)
	cp -r -t $(PACKAGE)/$(HTML_FILE_INTERNAL) $(HTML_FILE_INTERNAL_FILES)
	cp -r -t $(PACKAGE) $(FOLDERS)
	mkdir -p $(PACKAGE)/sdkjs/vendor
	cp -r -t $(PACKAGE)/sdkjs/vendor $(JQUERY) $(XREGEXP)
	mkdir -p $(PACKAGE)/include
	cp -t $(PACKAGE)/include $(INCLUDE_FILES)
	mkdir -p $(PACKAGE)/wrappers
	cp -t $(PACKAGE)/wrappers $(WRAPPERS_FILES)

clean:
	rm -fr $(PACKAGE) $(ARCHIVE)

%-$(ARCH_SUFFIX).tar.gz : %
	tar -zcvf $@ $<

%-$(ARCH_SUFFIX).zip : %
	7z a -y $@ $<
