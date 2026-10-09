.EXPORT_ALL_VARIABLES:
.PHONY: all romfs clean

ifndef ROOTDIR
ROOTDIR=..
endif
ifndef ROMFSDIR
ROMFSDIR=$(ROOTDIR)/romfs
endif

UCLINUX_BUILD_LIB=1
-include $(LINUX_CONFIG)
include $(PROJECT_CONFIG)
include $(ARCH_CONFIG)

CFLAGS  += -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections

DESTDIR=$(ROOTDIR)/stage

dir_y =
dir_n =
dir_  =

LIBS_INCLUDE_LIBSSL=n
LIBS_INCLUDE_LIBUSB_1=n

ifeq ($(CONFIG_FIRMWARE_INCLUDE_EAP_PEAP),y)
LIBS_INCLUDE_LIBSSL=y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_HTTPS),y)
LIBS_INCLUDE_LIBSSL=y
endif

ifdef CONFIG_USB_SUPPORT
LIBS_INCLUDE_LIBUSB_1=y
endif

dir_y						+= libz
dir_$(LIBS_INCLUDE_LIBSSL)			+= libssl
dir_$(LIBS_INCLUDE_LIBUSB_1)			+= libusb-1.0
dir_y						+= libnfnetlink

all:
	for i in $(dir_y) ; do \
		[ -d $$i ] && \
		$(MAKE) -j1 -C $$i || \
		exit $$? ; \
		if [ ! -f $(DESTDIR)/.installed_$$i ] ; then \
			$(MAKE) -C $$i install && \
			touch $(DESTDIR)/.installed_$$i ; \
		fi ; \
	done

%_only:
	$(MAKE) -C $(@:_only=)

%_romfs:
	$(MAKE) -C $(@:_romfs=) romfs

%_clean:
	$(MAKE) -C $(@:_clean=) clean

romfs:
	for i in $(dir_y) ; do \
		[ -d $$i ] && \
		$(MAKE) -C $$i romfs ; \
	done

clean:
	for i in `ls -d *` ; do \
		if [ -d $$i ] ; then \
			$(MAKE) -C $$i clean ; \
			rm -f $(DESTDIR)/.installed_$$i ; \
		fi ; \
	done