# Copyright (C) 2014 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# inherit from Sony common
include device/sony/common/BoardConfigCommon.mk

# must be defined before qcom-common include
BOARD_EGL_CFG := device/sony/msm8974-common/rootdir/system/lib/egl/egl.cfg

# inherit from qcom-common
include device/sony/qcom-common/BoardConfigCommon.mk

# Kernel properties
TARGET_KERNEL_SOURCE := kernel/sony/msm8974

# use CAF variants
BOARD_USES_QCOM_HARDWARE := true

# Platform
TARGET_BOOTLOADER_BOARD_NAME := MSM8974
TARGET_BOARD_PLATFORM := msm8974

# Architecture
TARGET_CPU_VARIANT := krait

# Audio
BOARD_USES_ALSA_AUDIO := true
AUDIO_FEATURE_DISABLED_USBAUDIO := true
AUDIO_FEATURE_ENABLED_EXTN_POST_PROC := true

# Bionic
TARGET_USE_QCOM_BIONIC_OPTIMIZATION := true
BOARD_USES_LEGACY_MMAP := true

# Enable Minikin text layout engine (will be the default soon)
USE_MINIKIN := true

# Graphics
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
OVERRIDE_RS_DRIVER := libRSDriver_adreno.so

# Include an expanded selection of fonts
EXTENDED_FONT_FOOTPRINT := true

# Shader cache config options
# Maximum size of the  GLES Shaders that can be cached for reuse.
# Increase the size if shaders of size greater than 12KB are used.
MAX_EGL_CACHE_KEY_SIZE := 12*1024

# Maximum GLES shader cache size for each app to store the compiled shader
# binaries. Decrease the size if RAM or Flash Storage size is a limitation
# of the device.
MAX_EGL_CACHE_SIZE := 2048*1024

VSYNC_EVENT_PHASE_OFFSET_NS := 7500000
SF_VSYNC_EVENT_PHASE_OFFSET_NS := 5000000

BOARD_CUSTOM_BOOTIMG_MK := device/sony/msm8974-common/boot/custombootimg.mk

# Logd
TARGET_USES_LOGD := false

# SELinux
include device/qcom/sepolicy/sepolicy.mk

BOARD_SEPOLICY_DIRS += \
    device/sony/msm8974-common/sepolicy

# The list below is order dependent
BOARD_SEPOLICY_UNION += \
    bluetooth.te \
    device.te \
    domain.te \
    file.te \
    radio.te \
    rild.te \
    sensors.te \
    tee.te \
    time_daemon.te \
    wpa.te \
    file_contexts \
    genfs_contexts

# Time
BOARD_USES_QC_TIME_SERVICES := true
