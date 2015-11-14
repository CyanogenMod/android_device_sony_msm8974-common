LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    libutils_shim.c \
    libui_shim.cpp \
    libgui_shim.c

LOCAL_SHARED_LIBRARIES := \
    libui \
    libgui \
    libutils

LOCAL_MODULE := libsony_cam
LOCAL_MODULE_CLASS := SHARED_LIBRARIES

include $(BUILD_SHARED_LIBRARY)
