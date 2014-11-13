# Copyright (C) 2014 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# inherit from qcom-common
include device/sony/qcom-common/BoardConfigCommon.mk

BOARD_CUSTOM_BOOTIMG_MK := device/sony/msm8974-common/boot/custombootimg.mk

BLUETOOTH_HCI_USE_MCT := true

TARGET_USES_LOGD := false

BOARD_SEPOLICY_DIRS += \
	device/sony/msm8974-common/sepolicy

# The list below is order dependent
BOARD_SEPOLICY_UNION += \
	app.te \
	bluetooth.te \
	bridge.te \
	device.te \
	domain.te \
	file.te \
	irsc_util.te \
	mediaserver.te \
	mpdecision.te \
	netmgrd.te \
	platform_app.te \
	qmux.te \
	radio.te \
	rild.te \
	rmt.te \
	sensors.te \
	surfaceflinger.te \
	system_server.te \
	tee.te \
	time.te \
	ueventd.te \
	wpa.te \
	file_contexts \
	genfs_contexts \
	te_macros
