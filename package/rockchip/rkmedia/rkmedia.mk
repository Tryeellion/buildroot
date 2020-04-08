ifeq ($(BR2_PACKAGE_RV1108),y)
RKMEDIA_SITE = $(TOPDIR)/../framework/media
else
RKMEDIA_SITE = $(TOPDIR)/../external/rkmedia
endif

RKMEDIA_SITE_METHOD = local

RKMEDIA_INSTALL_STAGING = YES

RKMEDIA_DEPENDENCIES = host-ninja

RKMEDIA_CONF_OPTS = -DWARNINGS_AS_ERRORS=ON

ifeq ($(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ), y)
RKMEDIA_DEPENDENCIES += camera_engine_rkaiq
RKMEDIA_CONF_OPTS += -DUSE_RKAIQ=ON
endif

ifeq ($(BR2_PACKAGE_LIBION),y)
RKMEDIA_DEPENDENCIES += libion
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_MPP),y)
RKMEDIA_DEPENDENCIES += mpp
RKMEDIA_CONF_OPTS += -DRKMPP=ON \
	-DRKMPP_HEADER_DIR=$(STAGING_DIR)/usr/include/rockchip \
	-DRKMPP_LIB_NAME=rockchip_mpp
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_MPP_ENCODER),y)
RKMEDIA_CONF_OPTS += -DRKMPP_ENCODER=ON
ifeq ($(BR2_PACKAGE_RKMEDIA_MPP_ENCODER_OSD), y)
  RKMEDIA_CONF_OPTS += -DRKMPP_ENCODER_OSD=ON
endif
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_MPP_DECODER),y)
RKMEDIA_CONF_OPTS += -DRKMPP_DECODER=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_OGG),y)
RKMEDIA_CONF_OPTS += -DOGG=ON
endif

BR2_PACKAGE_RKMEDIA_OGGVORBIS =
ifeq ($(BR2_PACKAGE_RKMEDIA_OGGVORBIS_DEMUXER),y)
BR2_PACKAGE_RKMEDIA_OGGVORBIS=y
RKMEDIA_CONF_OPTS += -DOGGVORBIS=ON -DOGGVORBIS_DEMUXER=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_OGGVORBIS_MUXER),y)
BR2_PACKAGE_RKMEDIA_OGGVORBIS=y
RKMEDIA_CONF_OPTS += -DOGGVORBIS=ON -DOGGVORBIS_MUXER=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_OGGVORBIS),y)
RKMEDIA_DEPENDENCIES += libvorbis
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_FFMPEG),y)
RKMEDIA_DEPENDENCIES += ffmpeg
RKMEDIA_CONF_OPTS += -DFFMPEG=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_ALSA_PLAYBACK),y)
RKMEDIA_CONF_OPTS += -DALSA_PLAYBACK=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_ALSA_CAPTURE),y)
RKMEDIA_CONF_OPTS += -DALSA_CAPTURE=ON
endif

ifneq ($(BR2_PACKAGE_RKMEDIA_ALSA_PLAYBACK)$(BR2_PACKAGE_RKMEDIA_ALSA_CAPTURE),)
RKMEDIA_DEPENDENCIES += alsa-lib
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_V4L2_CAPTURE),y)
ifeq ($(BR2_PACKAGE_LIBV4L2),y)
RKMEDIA_DEPENDENCIES += libv4l
endif
RKMEDIA_CONF_OPTS += -DV4L2_CAPTURE=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_RKRGA),y)
RKMEDIA_DEPENDENCIES += linux-rga
RKMEDIA_CONF_OPTS += -DRKRGA=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_RKGUARD),y)
RKMEDIA_CONF_OPTS += -DRKGUARD=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_RKNN),y)
RKMEDIA_DEPENDENCIES += rknpu
RKMEDIA_CONF_OPTS += -DRKNN=ON \
	-DRKNPU_HEADER_DIR=$(RKNPU_BUILDDIR)/rknn/include
endif

ifeq ($(BR2_PACKAGE_DRM_DISPLAY_OUTPUT),y)
RKMEDIA_DEPENDENCIES += libdrm
RKMEDIA_CONF_OPTS += -DDRM_DISPLAY=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_LIVE555),y)
RKMEDIA_CONF_OPTS += -DLIVE555=ON \
	-DGROUPSOCK_HEADER_DIR=$(STAGING_DIR)/usr/include/groupsock \
	-DUSAGEENVIRONMENT_HEADER_DIR=$(STAGING_DIR)/usr/include/UsageEnvironment
RKMEDIA_DEPENDENCIES += live555
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_RTSP_SERVER),y)
RKMEDIA_CONF_OPTS += -DLIVE555_SERVER=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_RTSP_SERVER_H264),y)
RKMEDIA_CONF_OPTS += -DLIVE555_SERVER_H264=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_RTSP_SERVER_H265),y)
RKMEDIA_CONF_OPTS += -DLIVE555_SERVER_H265=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_UVC),y)
RKMEDIA_DEPENDENCIES += uvc_app
RKMEDIA_CONF_OPTS += -DUVC=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_MOVE_DETECTION),y)
RKMEDIA_DEPENDENCIES += common_algorithm
RKMEDIA_CONF_OPTS += -DMOVE_DETECTION=ON
endif

ifeq ($(BR2_PACKAGE_RKMEDIA_EXAMPLES),y)
RKMEDIA_CONF_OPTS += -DCOMPILES_EXAMPLES=ON
endif

RKMEDIA_CONF_OPTS += -G Ninja

RKMEDIA_NINJA_OPTS += $(if $(VERBOSE),-v) -j$(PARALLEL_JOBS)

define RKMEDIA_BUILD_CMDS
$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) ninja $($(PKG)_NINJA_OPTS) -C $($(PKG)_BUILDDIR)
endef

ifeq ($(BR2_PACKAGE_RK_OEM), y)
RKMEDIA_TARGET_DESTDIR=$(BR2_PACKAGE_RK_OEM_INSTALL_TARGET_DIR)
define RKMEDIA_INSTALL_TARGET_REMOVE_HOOK
	rm -rf $(RKMEDIA_TARGET_DESTDIR)/usr/include
	rm -rf $(RKMEDIA_TARGET_DESTDIR)/usr/lib/pkgconfig
endef
RKMEDIA_POST_INSTALL_TARGET_HOOKS += RKMEDIA_INSTALL_TARGET_REMOVE_HOOK
RKMEDIA_DEPENDENCIES += rk_oem
else
RKMEDIA_TARGET_DESTDIR=$(TARGET_DIR)
endif

define RKMEDIA_INSTALL_TARGET_CMDS
$(TARGET_MAKE_ENV) DESTDIR=$(RKMEDIA_TARGET_DESTDIR) ninja $($(PKG)_NINJA_OPTS) -C $($(PKG)_BUILDDIR) install
endef

define RKMEDIA_INSTALL_STAGING_CMDS
$(TARGET_MAKE_ENV) DESTDIR=$(STAGING_DIR) ninja $($(PKG)_NINJA_OPTS) -C $($(PKG)_BUILDDIR) install
endef

$(eval $(cmake-package))
