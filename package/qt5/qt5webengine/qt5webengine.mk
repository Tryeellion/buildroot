################################################################################
#
# qt5webengine
#
################################################################################

QT5WEBENGINE_VERSION = $(call qstrip,$(BR2_PACKAGE_QT5WEBENGINE_VERSION))
QT5WEBENGINE_MAJOR_VERSION = $(call qstrip,$(basename $(QT5WEBENGINE_VERSION)))
QT5WEBENGINE_SITE = https://download.qt.io/official_releases/qt/$(QT5WEBENGINE_MAJOR_VERSION)/$(QT5WEBENGINE_VERSION)/submodules
QT5WEBENGINE_SOURCE = qtwebengine-$(QT5_SOURCE_TARBALL_PREFIX)-$(QT5WEBENGINE_VERSION).tar.xz
QT5WEBENGINE_DEPENDENCIES = ffmpeg libglib2 libvpx opus webp qt5base \
	qt5declarative qt5webchannel host-bison host-flex host-gperf \
	host-pkgconf host-python
QT5WEBENGINE_INSTALL_STAGING = YES

ifneq ($(QT5WEBENGINE_VERSION),)
include package/qt5/qt5webengine/chromium-$(QT5WEBENGINE_VERSION).inc
endif

QT5WEBENGINE_LICENSE = GPL-2.0 or LGPL-3.0 or GPL-3.0 or GPL-3.0 with exception
QT5WEBENGINE_LICENSE_FILES = LICENSE.GPL2 LICENSE.GPL3 LICENSE.GPL3-EXCEPT \
	LICENSE.GPLv3 LICENSE.LGPL3 $(QT5WEBENGINE_CHROMIUM_LICENSE_FILES)

ifeq ($(BR2_PACKAGE_QT5BASE_XCB),y)
QT5WEBENGINE_DEPENDENCIES += xlib_libXScrnSaver xlib_libXcomposite \
	xlib_libXcursor xlib_libXi xlib_libXrandr xlib_libXtst
endif

QT5WEBENGINE_DEPENDENCIES += host-libpng host-libnss libnss

QT5WEBENGINE_CONFIG += -webengine-ffmpeg

ifeq ($(BR2_PACKAGE_QT5WEBENGINE_WEBRTC),y)
QT5WEBENGINE_CONFIG += -webengine-webrtc
endif

ifeq ($(BR2_PACKAGE_QT5WEBENGINE_PROPRIETARY_CODECS),y)
QT5WEBENGINE_CONFIG += -proprietary-codecs
endif

ifeq ($(BR2_PACKAGE_QT5WEBENGINE_ALSA),y)
QT5WEBENGINE_DEPENDENCIES += alsa-lib
else
QT5WEBENGINE_QMAKEFLAGS += QT_CONFIG-=alsa
endif

# QtWebengine's build system uses python, but only supports python2. We work
# around this by forcing python2 early in the PATH, via a python->python2
# symlink.
QT5WEBENGINE_ENV = PATH=$(@D)/host-bin:$(BR_PATH)
define QT5WEBENGINE_PYTHON2_SYMLINK
	mkdir -p $(@D)/host-bin
	ln -sf $(HOST_DIR)/bin/python2 $(@D)/host-bin/python
endef
QT5WEBENGINE_PRE_CONFIGURE_HOOKS += QT5WEBENGINE_PYTHON2_SYMLINK

QT5WEBENGINE_ENV += NINJAFLAGS="-j$(PARALLEL_JOBS)"

define QT5WEBENGINE_CREATE_HOST_PKG_CONFIG
	sed s%@HOST_DIR@%$(HOST_DIR)%g $(QT5WEBENGINE_PKGDIR)/host-pkg-config.in > $(@D)/host-bin/host-pkg-config
	chmod +x $(@D)/host-bin/host-pkg-config
endef
QT5WEBENGINE_PRE_CONFIGURE_HOOKS += QT5WEBENGINE_CREATE_HOST_PKG_CONFIG
QT5WEBENGINE_ENV += GN_PKG_CONFIG_HOST=$(@D)/host-bin/host-pkg-config

define QT5WEBENGINE_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_MAKE_ENV) $(QT5WEBENGINE_ENV) $(HOST_DIR)/bin/qmake $(QT5WEBENGINE_QMAKEFLAGS) -- $(QT5WEBENGINE_CONFIG))
endef

define QT5WEBENGINE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(QT5WEBENGINE_ENV) $(MAKE) -C $(@D)
endef

define QT5WEBENGINE_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(QT5WEBENGINE_ENV) $(MAKE) -C $(@D) install
endef

define QT5WEBENGINE_INSTALL_TARGET_QMLS
	cp -dpfr $(STAGING_DIR)/usr/qml/QtWebEngine $(TARGET_DIR)/usr/qml/
endef

ifeq ($(BR2_PACKAGE_QT5BASE_EXAMPLES),y)
define QT5WEBENGINE_INSTALL_TARGET_EXAMPLES
	cp -dpfr $(STAGING_DIR)/usr/lib/qt/examples/webengine* $(TARGET_DIR)/usr/lib/qt/examples/
endef
endif

ifneq ($(BR2_STATIC_LIBS),y)
define QT5WEBENGINE_INSTALL_TARGET_LIBS
	cp -dpf $(STAGING_DIR)/usr/lib/libQt5WebEngine*.so.* $(TARGET_DIR)/usr/lib
	cp -dpf $(STAGING_DIR)/usr/libexec/QtWebEngineProcess $(TARGET_DIR)/usr/libexec/
	cp -dpfr $(STAGING_DIR)/usr/resources/ $(TARGET_DIR)/usr/
	mkdir -p $(TARGET_DIR)/usr/translations/qtwebengine_locales/
	cp -dpfr $(STAGING_DIR)/usr/translations/qtwebengine_locales $(TARGET_DIR)/usr/translations/qtwebengine_locales/
endef
endif

define QT5WEBENGINE_INSTALL_TARGET_ENV
	$(INSTALL) -D -m 644 $(QT5WEBENGINE_PKGDIR)/qtwebengine.sh \
		$(TARGET_DIR)/etc/profile.d/qtwebengine.sh
endef

define QT5WEBENGINE_INSTALL_TARGET_CMDS
	$(QT5WEBENGINE_INSTALL_TARGET_LIBS)
	$(QT5WEBENGINE_INSTALL_TARGET_QMLS)
	$(QT5WEBENGINE_INSTALL_TARGET_EXAMPLES)
	$(QT5WEBENGINE_INSTALL_TARGET_ENV)
endef

# qtwebengine 5.12 has color issue when using VDA for WEBRTC.
ifneq ($(BR2_PACKAGE_QT5WEBENGINE_WEBRTC)$(BR2_PACKAGE_QT5WEBENGINE_5_12),yy)
ifeq ($(BR2_PACKAGE_LIBV4L_RKMPP),y)
define QT5WEBENGINE_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 $(QT5WEBENGINE_PKGDIR)/S99qtwebengine.sh \
		$(TARGET_DIR)/etc/init.d/S99qtwebengine.sh
endef
endif
endif

$(eval $(generic-package))
