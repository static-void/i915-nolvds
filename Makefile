DEPENDENCIES := nothing
default: i915
.PHONY: install
.SILENT: clean uninstall patch download install i915

ifeq ($(KVER),)
KVER := "$(shell uname -r)"
endif

DEBIAN_VER := $(shell cat /etc/debian_version)
ifeq ($(DEBIAN_VER),)
	CKERNEL := "/usr/lib/modules/$(shell uname -r)"
	CKERNELVERSION := $(shell uname -r | cut -d- -f1)
else
	CKERNEL := "/lib/modules/$(KVER)"
	CKERNELVERSION := $(shell echo $(KVER) | cut -d- -f1 | cut -d\. -f1,2)
endif
LOCALKERNEL := $(shell pwd)/linux-$(CKERNELVERSION)
LOCALI915 := $(LOCALKERNEL)/drivers/gpu/drm/i915

clean:
	cd $(LOCALKERNEL); \
			find ./ -name "*.o" -delete; \
			find ./ -name "*.ko" -delete; \
			find ./ -name "*.ko.gz" -delete; \
			find ./ -name "*.rej" -delete
	make -C $(CKERNEL)/build M="$(LOCALI915)" clean
	rm -rf ./linux-*/
	echo "$(LOCALKERNEL) cleaned!"

uninstall:
	if [ -f $(CKERNEL)/updates/i915.ko.xz ]; then \
			rm $(CKERNEL)/updates/i915.ko.xz; \
			echo "$(CKERNEL)/updates/i915.ko.xz deleted."; \
			fi
	rmdir $(CKERNEL)/updates || \
			echo "$(CKERNEL) not empty!"; \
			ls -lah $(CKERNEL)/updates/ || \
			echo "Nothing to uninstall!"

download:
	if [ ! -d $(LOCALKERNEL)/ ]; then \
		echo "Downloading Linux kernel source for v$(CKERNELVERSION)"; \
		if [ "$(DEBIAN_VER)" = "" ]; then \
			git clone --depth=1 --branch v$(CKERNELVERSION); \
			https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git $(LOCALKERNEL); \
		else \
			apt-get source linux-image-unsigned-$(shell uname -r); \
			mv linux-$(shell echo $(KVER) | cut -d- -f1) $(LOCALKERNEL); \
		fi \
	fi

patch: download
	# Patch to allow building "out-of-tree"	
	echo $(LOCALKERNEL)
	patch --forward -p1 --directory=$(LOCALKERNEL) \
			< patches/i915-out-of-tree.patch || \
			echo "Already patched."
	# Patch to disable ghost LVDS display in i915 for x220/x230
	patch --forward -p1 --directory=$(LOCALKERNEL) \
			< patches/i915-no-lvds.patch || \
			echo "Already patched"

# default target
i915: patch
	echo Building $(LOCAL) using $(CKERNEL)/build
	make EXTRA_CFLAGS="-I$(LOCALKERNEL)/drivers/gpu/drm/i915 -DLOCALKERNEL=$(LOCALKERNEL)" -C $(CKERNEL)/build M="$(LOCALI915)"
	cp $(LOCALI915)/i915.ko \
		./i915.ko
	xz -z $(LOCALI915)/i915.ko

install: uninstall
	# too easy, drop modded .ko.gz in /usr/lib/modules/`uname -r`/updates , depmod, build initram and reboot...
	if [ ! -d $(CKERNEL)/updates/ ]; then \
			mkdir $(CKERNEL)/updates; fi
		
	cp $(LOCALI915)/i915.ko.xz \
			$(CKERNEL)/updates/i915.ko.xz && \
			echo "Installed modded i915.ko to $(CKERNEL)/updates/i915.ko.xz"
		
	depmod
	
	echo "Done! Reboot to load the new i915 module."
