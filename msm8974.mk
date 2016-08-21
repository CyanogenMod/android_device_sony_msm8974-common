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

COMMON_PATH := device/sony/msm8974-common

# Audio
PRODUCT_PACKAGES += \
    audiod \
    audio.a2dp.default \
    audio.primary.msm8974 \
    audio.r_submix.default \
    audio.usb.default \
    audio_policy.msm8974

PRODUCT_PACKAGES += \
    libaudio-resampler \
    libqcompostprocbundle \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    tinymix

# Audio configuration
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_effects.conf:system/vendor/etc/audio_effects.conf

# Camera
PRODUCT_PACKAGES += \
    camera.msm8974 \
    libmmcamera_interface \
    libmmjpeg_interface \
    libmm-qcamera \
    libqomx_core

PRODUCT_PROPERTY_OVERRIDES += \
    camera.disable_zsl_mode=0 \
    persist.camera.HAL3.enabled=1 \
    persist.camera.ois.disable=0

PRODUCT_PACKAGES += \
    Snap

# Display
PRODUCT_PACKAGES += \
    hwcomposer.msm8974 \
    gralloc.msm8974 \
    copybit.msm8974 \
    memtrack.msm8974 \
    libgenlock \
    libmemalloc \
    liboverlay \
    libqdutils \
    libtilerenderer \
    libI420colorconvert

# GPS
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/gps.conf:system/etc/gps.conf

PRODUCT_PACKAGES += \
    libloc_core \
    libloc_eng \
    libgps.utils \
    gps.msm8974

# Ion
PRODUCT_PACKAGES += \
    libion

# IO Scheduler
PRODUCT_PROPERTY_OVERRIDES += \
    sys.io.scheduler=bfq

# Lights
PRODUCT_PACKAGES += \
    lights.msm8974

# Media profile
PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
    $(COMMON_PATH)/media_codecs.xml:system/etc/media_codecs.xml \
    $(COMMON_PATH)/media_profiles.xml:system/etc/media_profiles.xml

# Media
PRODUCT_PACKAGES += \
    qcmediaplayer

PRODUCT_BOOT_JARS += \
    qcmediaplayer

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml

# Omx
PRODUCT_PACKAGES += \
    libOmxAacEnc \
    libOmxAmrEnc \
    libOmxCore \
    libOmxEvrcEnc \
    libOmxQcelp13Enc \
    libOmxVdec \
    libOmxVenc \
    libc2dcolorconvert \
    libdashplayer \
    libdivxdrmdecrypt \
    libmm-omxcore \
    libstagefrighthw

# Overlay
DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay
ifneq ($(BOARD_HAVE_RADIO),false)
    DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay-radio
    $(call inherit-product, $(COMMON_PATH)/radio.mk)
else
    DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay-wifionly
endif

# Power
PRODUCT_PACKAGES += \
    power.qcom

# Recovery
PRODUCT_PACKAGES += \
    keycheck

# RIL
PRODUCT_PACKAGES += \
    librmnetctl \
    libxml2

# Sensors
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/sensors_settings:system/etc/sensors_settings

PRODUCT_PROPERTY_OVERRIDES += \
    ro.qti.sensors.dpc=true

PRODUCT_PROPERTY_OVERRIDES += \
    persist.debug.sensors.hal=0 \
    debug.qualcomm.sns.daemon=0 \
    debug.qualcomm.sns.hal=0 \
    debug.qualcomm.sns.libsensor1=0

# Thermal management
PRODUCT_PACKAGES += \
    thermanager

# Time
PRODUCT_PACKAGES += \
    timekeep \
    TimeKeep

# USB OTG
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.isUsbOtgEnabled=true

# Wifi
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0 \
    wifi.supplicant_scan_interval=15

PRODUCT_PACKAGES += \
    libwpa_client \
    hostapd \
    dhcpcd.conf \
    wpa_supplicant \
    wpa_supplicant.conf

# QCOM Display
PRODUCT_PROPERTY_OVERRIDES += \
    persist.hwc.mdpcomp.enable=true

# OpenGL ES 3.0
PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=196608

# Updater properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.disable.recovery.updater=1

# Include non-opensource parts
$(call inherit-product, vendor/sony/msm8974-common/msm8974-common-vendor.mk)
