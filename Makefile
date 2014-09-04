#
# Copyright © 2013 VMware, Inc.  All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the “License”); you may
# not use this file except in compliance with the License.  You may obtain a
# copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an “AS IS” BASIS, without warranties or
# conditions of any kind, EITHER EXPRESS OR IMPLIED.  See the License for the
# specific language governing permissions and limitations under the License.”
#
#
# DKMS configuration for VMware Workstation kernel dependencies.
# by Damien Dejean <ddejean@vmware.com>
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

