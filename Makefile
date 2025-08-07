ARCHS = arm64e arm64

export THEOS=/var/theos_RootHide

# export THEOS_PACKAGE_SCHEME = roothide
export THEOS_PACKAGE_SCHEME = rootless

export TARGET = iphone:14.5
export SDKVERSION = 14.5

export THEOS_DEVICE_IP = 192.168.1.7
export THEOS_DEVICE_PORT = 22
export iP = $(THEOS_DEVICE_IP)
export Port = $(THEOS_DEVICE_PORT)
export Pass = alpine
export Bundle = net.whatsapp.WhatsApp


# DEBUG = 0

# THEOS_DEVICE_IP = 192.168.100.4

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WATranslator

WATranslator_FILES = Tweak.xm WATranslationMenuManager.m
WATranslator_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk


install5::
		install5.exec