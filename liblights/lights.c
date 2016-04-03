/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (C) 2014 The  Linux Foundation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "lights.msm8974"

#include <cutils/log.h>

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>

#include <sys/ioctl.h>
#include <sys/types.h>

#include <hardware/lights.h>

/******************************************************************************/

static pthread_once_t g_init = PTHREAD_ONCE_INIT;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t g_lcd_lock = PTHREAD_MUTEX_INITIALIZER;
static struct light_state_t g_notification;
static struct light_state_t g_battery;

enum led_ident {
	LED_RED,
	LED_GREEN,
	LED_BLUE,
	LED_BACKLIGHT
};

static struct led_desc {
	int max_brightness;
	const char *max_brightness_s;
	const char *brightness;
	const char *blink;
} led_descs[] = {
	[LED_BACKLIGHT] = {
		.max_brightness = 0,
		.max_brightness_s = "/sys/class/leds/lcd-backlight/max_brightness",
		.brightness = "/sys/class/leds/lcd-backlight/brightness",
	},
	[LED_RED] = {
		.max_brightness = 0,
		.max_brightness_s = "/sys/class/leds/led:rgb_red/max_brightness",
		.brightness = "/sys/class/leds/led:rgb_red/brightness",
		.blink = "/sys/class/leds/led:rgb_red/blink",
	},
	[LED_GREEN] = {
		.max_brightness = 0,
		.max_brightness_s = "/sys/class/leds/led:rgb_green/max_brightness",
		.brightness = "/sys/class/leds/led:rgb_green/brightness",
		.blink = "/sys/class/leds/led:rgb_green/blink",
	},
	[LED_BLUE] = {
		.max_brightness = 0,
		.max_brightness_s = "/sys/class/leds/led:rgb_blue/max_brightness",
		.brightness = "/sys/class/leds/led:rgb_blue/brightness",
		.blink = "/sys/class/leds/led:rgb_blue/blink",
	},
};

/**
 * device methods
 */

void init_globals(void)
{
	// init the mutex
	pthread_mutex_init(&g_lock, NULL);
	pthread_mutex_init(&g_lcd_lock, NULL);
}

static int
write_int(char const* path, int value)
{
	int fd;
	static int already_warned = 0;

	fd = open(path, O_WRONLY);
	if (fd >= 0) {
		char buffer[20] = {0,};
		int bytes = snprintf(buffer, sizeof(buffer), "%d\n", value);
		ssize_t amt = write(fd, buffer, (size_t)bytes);
		close(fd);
		return amt == -1 ? -errno : 0;
	} else {
		if (already_warned == 0) {
			ALOGE("write_int failed to open %s\n", path);
			already_warned = 1;
		}
		return -errno;
	}
}

static int
read_int(const char *path)
{
	static int already_warned = 0;
	char buffer[12];
	int fd, rc;

	fd = open(path, O_RDONLY);
	if (fd < 0) {
		if (already_warned == 0) {
			ALOGE("read_int failed to open %s\n", path);
			already_warned = 1;
		}
		return -1;
	}

	rc = read(fd, buffer, sizeof(buffer) - 1);
	close(fd);
	if (rc <= 0)
		return -1;

	buffer[rc] = 0;

	return strtol(buffer, 0, 0);
}

static int
is_lit(struct light_state_t const* state)
{
	return state->color & 0x00ffffff;
}

static int
rgb_to_brightness(struct light_state_t const* state)
{
	int color = state->color & 0x00ffffff;
	return ((77 * ((color >> 16) & 0x00ff))
			+ (150 * ((color >> 8) & 0x00ff)) + (29 * (color & 0x00ff))) >> 8;
}

static int
set_light_backlight(struct light_device_t* dev,
		struct light_state_t const* state)
{
	int err = 0;
	int brightness = rgb_to_brightness(state);
	int max_brightness = read_int(led_descs[LED_BACKLIGHT].max_brightness_s);
	int scaled;

	if(!dev) {
		return -1;
	}

	if (brightness > max_brightness)
		scaled = max_brightness;
	else
		scaled = brightness;

	pthread_mutex_lock(&g_lcd_lock);
	err = write_int(led_descs[LED_BACKLIGHT].brightness, scaled);
	pthread_mutex_unlock(&g_lcd_lock);
	return err;
}

static int
set_speaker_light_locked(struct light_device_t* dev,
		struct light_state_t const* state)
{
	int red, green, blue;
	int blink;
	int onMS, offMS;
	unsigned int colorRGB;

	if(!dev) {
		return -1;
	}

	switch (state->flashMode) {
		case LIGHT_FLASH_TIMED:
			onMS = state->flashOnMS;
			offMS = state->flashOffMS;
			break;
		case LIGHT_FLASH_NONE:
		default:
			onMS = 0;
			offMS = 0;
			break;
	}

	colorRGB = state->color;

#if 0
	ALOGD("set_speaker_light_locked mode %d, colorRGB=%08X, onMS=%d, offMS=%d\n",
			state->flashMode, colorRGB, onMS, offMS);
#endif

	red = (colorRGB >> 16) & 0xFF;
	green = (colorRGB >> 8) & 0xFF;
	blue = colorRGB & 0xFF;

	if (onMS > 0 && offMS > 0) {
		/*
		 * if ON time == OFF time
		 *   use blink mode 2
		 * else
		 *   use blink mode 1
		 */
		if (onMS == offMS)
			blink = 2;
		else
			blink = 1;
	} else {
		blink = 0;
	}

	if (blink) {
		if (red) {
			if (write_int(led_descs[LED_RED].blink, blink))
				write_int(led_descs[LED_RED].brightness, 0);
	}
		if (green) {
			if (write_int(led_descs[LED_GREEN].blink, blink))
				write_int(led_descs[LED_GREEN].brightness, 0);
	}
		if (blue) {
			if (write_int(led_descs[LED_BLUE].blink, blink))
				write_int(led_descs[LED_BLUE].brightness, 0);
	}
	} else {
		write_int(led_descs[LED_RED].brightness, red);
		write_int(led_descs[LED_GREEN].brightness, green);
		write_int(led_descs[LED_BLUE].brightness, blue);
	}

	return 0;
}

static void
handle_speaker_battery_locked(struct light_device_t* dev)
{
	if (is_lit(&g_battery)) {
		set_speaker_light_locked(dev, &g_battery);
	} else {
		set_speaker_light_locked(dev, &g_notification);
	}
}

static int
set_light_battery(struct light_device_t* dev,
		struct light_state_t const* state)
{
	if(!dev) {
		return -1;
	}

	pthread_mutex_lock(&g_lock);
	g_battery = *state;
	handle_speaker_battery_locked(dev);
	pthread_mutex_unlock(&g_lock);
	return 0;
}

static int
set_light_notifications(struct light_device_t* dev,
		struct light_state_t const* state)
{
	if(!dev) {
		return -1;
	}

	pthread_mutex_lock(&g_lock);
	g_notification = *state;
	handle_speaker_battery_locked(dev);
	pthread_mutex_unlock(&g_lock);
	return 0;
}

/** Close the lights device */
static int
close_lights(struct light_device_t *dev)
{
	if (dev) {
		free(dev);
	}
	return 0;
}


/******************************************************************************/

/**
 * module methods
 */

/** Open a new instance of a lights device using name */
static int open_lights(const struct hw_module_t* module, char const* name,
		struct hw_device_t** device)
{
	int (*set_light)(struct light_device_t* dev,
			struct light_state_t const* state);

	if (0 == strcmp(LIGHT_ID_BACKLIGHT, name))
		set_light = set_light_backlight;
	else if (0 == strcmp(LIGHT_ID_BATTERY, name))
		set_light = set_light_battery;
	else if (0 == strcmp(LIGHT_ID_NOTIFICATIONS, name))
		set_light = set_light_notifications;
	else
		return -EINVAL;

	pthread_once(&g_init, init_globals);

	struct light_device_t *dev = malloc(sizeof(struct light_device_t));

	if(!dev)
		return -ENOMEM;

	memset(dev, 0, sizeof(*dev));

	dev->common.tag = HARDWARE_DEVICE_TAG;
	dev->common.version = 0;
	dev->common.module = (struct hw_module_t*)module;
	dev->common.close = (int (*)(struct hw_device_t*))close_lights;
	dev->set_light = set_light;

	*device = (struct hw_device_t*)dev;
	return 0;
}

static struct hw_module_methods_t lights_module_methods = {
	.open =  open_lights,
};

/*
 * The lights Module
 */
struct hw_module_t HAL_MODULE_INFO_SYM = {
	.tag = HARDWARE_MODULE_TAG,
	.version_major = 1,
	.version_minor = 0,
	.id = LIGHTS_HARDWARE_MODULE_ID,
	.name = "Sony lights Module",
	.author = "Google, Inc.",
	.methods = &lights_module_methods,
};
