#
# DKMS configuration for VMware Workstation kernel dependencies.
# by Damien Dejean <djod4556@yahoo.fr>
#
# Makefile wrapper to allow DKMS to use the VMware proprietary tool to build and
# install kernel modules.
#

KERNEL := $(KERNELRELEASE)
HEADERS := /usr/src/linux-$(KERNEL)/include
GCC := $(shell vmware-modconfig --console --get-gcc)
DEST := /lib/modules/$(KERNEL)/vmware

TARGETS := vmmon vmnet vmblock vmci vsock

LOCAL_MODULES := $(addsuffix .ko, $(TARGETS))

all: $(LOCAL_MODULES)
	mkdir -p modules/
	mv *.ko modules/
	rm -rf $(DEST)
	depmod

/usr/src/linux-$(KERNEL)/include/linux/version.h:
	ln -s /usr/src/linux-$(KERNEL)/include/generated/uapi/linux/version.h /usr/src/linux-$(KERNEL)/include/linux/version.h

%.ko: /usr/src/linux-$(KERNEL)/include/linux/version.h
	vmware-modconfig --console --build-mod -k $(KERNEL) $* $(GCC) $(HEADERS) vmware/
	cp -f $(DEST)/$*.ko .

clean:
	rm -rf modules/

