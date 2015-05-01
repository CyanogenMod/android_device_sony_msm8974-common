LOCAL_PATH := $(call my-dir)

ifeq ($(BOARD_VENDOR),sony)
ifeq ($(TARGET_BOARD_PLATFORM),msm8974)
    include $(call all-subdir-makefiles,$(LOCAL_PATH))
    include hardware/sony/thermanager/dummy.mk
endif
endif
