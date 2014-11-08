LOCAL_PATH := $(call my-dir)

ifeq ($(BOARD_VENDOR),sony)
ifeq ($(TARGET_BOARD_PLATFORM),msm8974)
    include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
endif
