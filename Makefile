DEPENDENCIES := nothing
default: i915
.PHONY: install
.SILENT: clean uninstall patch download install i915

ifeq ($(KVER),)
KVER := "$(shell uname -r)"
endif

DISTRO := $(shell lsb_release -i | sed 's/Distributor ID:\t\(.*\)/\1/')
ifeq ($(DISTRO),Ubuntu)
	CKERNEL := "/lib/modules/$(KVER)"
	CKERNELVERSION := $(shell echo $(KVER) | cut -d- -f1 | cut -d\. -f1,2)
	UBUNTU_PATCH := linux_$(shell uname -r | cut -d- -f1)-$(shell uname -r | cut -d- -f2).$(shell uname -v | cut -d- -f1 | cut -d\# -f2).diff
else
	CKERNEL := "/usr/lib/modules/$(shell uname -r)"
	CKERNELVERSION := $(shell uname -r | cut -d- -f1)
endif
# 4.14.8
LOCALKERNEL := $(shell pwd)/linux-$(CKERNELVERSION)
# ./linux-4.14.8
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
		if [ "$(DISTRO)" = "Ubuntu" ]; then \
			apt-get source linux-image-unsigned-$(shell uname -r); \
			mv linux-$(shell echo $(KVER) | cut -d- -f1) $(LOCALKERNEL); \
		else \
			git clone --depth=1 --branch v$(CKERNELVERSION); \
			https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git $(LOCALKERNEL); \
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
