LOCAL_PATH := $(call my-dir)

uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk.cpio
$(uncompressed_ramdisk): $(INSTALLED_RAMDISK_TARGET)
	gunzip -c $< > $@

INITSH := $(LOCAL_PATH)/init.sh
BOOTREC_DEVICE := $(TARGET_RECOVERY_ROOT_OUT)/etc/bootrec-device

DTBTOOL := $(HOST_OUT_EXECUTABLES)/dtbToolCM$(HOST_EXECUTABLE_SUFFIX)
$(INSTALLED_DTIMAGE_TARGET): $(DTBTOOL) $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr $(INSTALLED_KERNEL_TARGET)
	$(call pretty,"Target DT image: $@")
	$(hide) $(DTBTOOL) $(TARGET_DTB_EXTRA_FLAGS) -o $(INSTALLED_DTIMAGE_TARGET) -s $(BOARD_KERNEL_PAGESIZE) -p $(KERNEL_OUT)/scripts/dtc/ $(KERNEL_OUT)/arch/arm/boot/
	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}

$(INSTALLED_BOOTIMAGE_TARGET): $(PRODUCT_OUT)/kernel $(uncompressed_ramdisk) $(recovery_uncompressed_ramdisk) $(INSTALLED_RAMDISK_TARGET) $(INITSH) $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/utilities/extract_elf_ramdisk $(PRODUCT_OUT)/utilities/keycheck $(MKBOOTIMG) $(MINIGZIP) $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_DTIMAGE_TARGET)
	$(call pretty,"Target boot image: $@")

	$(hide) rm -fr $(PRODUCT_OUT)/combinedroot
	$(hide) mkdir -p $(PRODUCT_OUT)/combinedroot/sbin

	$(hide) mv $(PRODUCT_OUT)/root/logo.rle $(PRODUCT_OUT)/combinedroot/logo.rle
	$(hide) cp $(uncompressed_ramdisk) $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(recovery_uncompressed_ramdisk) $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(PRODUCT_OUT)/utilities/extract_elf_ramdisk $(PRODUCT_OUT)/combinedroot/sbin/
	$(hide) cp $(PRODUCT_OUT)/utilities/keycheck $(PRODUCT_OUT)/combinedroot/sbin/

	$(hide) cp $(INITSH) $(PRODUCT_OUT)/combinedroot/sbin/init.sh
	$(hide) chmod 755 $(PRODUCT_OUT)/combinedroot/sbin/init.sh
	$(hide) ln -s sbin/init.sh $(PRODUCT_OUT)/combinedroot/init
	$(hide) cp $(BOOTREC_DEVICE) $(PRODUCT_OUT)/combinedroot/sbin/

	$(hide) $(MKBOOTFS) $(PRODUCT_OUT)/combinedroot/ > $(PRODUCT_OUT)/combinedroot.cpio
	$(hide) cat $(PRODUCT_OUT)/combinedroot.cpio | gzip > $(PRODUCT_OUT)/combinedroot.fs

	$(hide) $(MKBOOTIMG) --kernel $(PRODUCT_OUT)/kernel --ramdisk $(PRODUCT_OUT)/combinedroot.fs --cmdline "$(BOARD_KERNEL_CMDLINE)" --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) --dt $(INSTALLED_DTIMAGE_TARGET) $(BOARD_MKBOOTIMG_ARGS) -o $(INSTALLED_BOOTIMAGE_TARGET)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

INSTALLED_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel) $(INSTALLED_DTIMAGE_TARGET)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) --kernel $(PRODUCT_OUT)/kernel --ramdisk $(PRODUCT_OUT)/ramdisk-recovery.img --cmdline "$(BOARD_KERNEL_CMDLINE)" --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) --dt $(INSTALLED_DTIMAGE_TARGET) $(BOARD_MKBOOTIMG_ARGS) -o $(INSTALLED_RECOVERYIMAGE_TARGET)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}
