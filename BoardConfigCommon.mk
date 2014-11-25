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

# inherit from qcom-common
include device/sony/qcom-common/BoardConfigCommon.mk

BOARD_CUSTOM_BOOTIMG_MK := device/sony/msm8974-common/boot/custombootimg.mk

TARGET_USES_LOGD := false

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
