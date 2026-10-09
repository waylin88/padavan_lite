.EXPORT_ALL_VARIABLES:
.PHONY: all romfs clean

ifndef ROOTDIR
ROOTDIR=..
endif
ifndef ROMFSDIR
ROMFSDIR=$(ROOTDIR)/romfs
endif

include $(PROJECT_CONFIG)
include $(ARCH_CONFIG)

DESTDIR=$(ROOTDIR)/stage

# linux-3.4.x：uclibc-ng 已随工具链提供，无需本地编译，仅拷贝运行时库
all:
	if [ ! -f $(DESTDIR)/.installed_uclibc ] ; then \
		mkdir -p $(DESTDIR) ; \
		touch $(DESTDIR)/.installed_uclibc ; \
	fi

romfs:
	$(ROMFSINST) -p +x $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/usr/bin/ldd /bin/ldd ; \
	cp -fP $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/lib/libuClibc*.so* $(ROMFSDIR)/lib ; \
	cp -fP $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/lib/libc.so.0 $(ROMFSDIR)/lib ; \
	cp -fP $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/lib/ld-uClibc*.so* $(ROMFSDIR)/lib ; \
	cp -fP $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/lib/libgcc_s.so.* $(ROMFSDIR)/lib ; \
	cp -fP $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/lib/libthread_db*.so* $(ROMFSDIR)/lib

clean:
	rm -f $(DESTDIR)/.installed_uclibc

%_only:
	$(MAKE) -C $(@:_only=)

%_romfs:
	$(MAKE) -C $(@:_romfs=) romfs

%_clean:
	$(MAKE) -C $(@:_clean=) clean