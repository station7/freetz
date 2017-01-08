$(call PKG_INIT_BIN, 7.2)
$(PKG)_SOURCE:=TrueCrypt-$($(PKG)_VERSION)-source-unix.tar.gz
$(PKG)_SOURCE_MD5:=ec3ab06022bbd00a7a94fde170c4df36
$(PKG)_SITE:=@SF/truecrypt

$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)-source

$(PKG)_BINARY := $($(PKG)_DIR)/Main/$(pkg)
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_CATEGORY:=Unstable

$(PKG)_DEPENDS_ON += $(STDCXXLIB) fuse wxWidgets pkcs11

$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRUECRYPT_STATIC

# strip LFS flags
$(PKG)_CFLAGS := $(subst $(TARGET_CFLAGS_LFS),,$(TARGET_CFLAGS))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TRUECRYPT_DIR) \
		NOGUI=1 \
		NOTEST=1 \
		VERBOSE=1 \
		DISABLE_PRECOMPILED_HEADERS=1 \
		\
		ARCH=$(TARGET_ARCH) \
		\
		LFS_FLAGS="$(TARGET_CFLAGS_LFS)" \
		\
		CC="$(TARGET_CC)" \
		TC_EXTRA_CFLAGS="$(TRUECRYPT_CFLAGS)" \
		\
		CXX="$(TARGET_CXX)" \
		TC_EXTRA_CXXFLAGS="$(TRUECRYPT_CFLAGS)" \
		\
		LDFLAGS="$(TARGET_LDFLAGS)" \
		\
		PKCS11_INC="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pkcs11" \
		\
		PKG_CONFIG_PATH="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig" \
		WX_CONFIG="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/wx-config" \
		AR="$(TARGET_AR)" \
		LD="$(TARGET_LD)" \
		RANLIB="$(TARGET_RANLIB)" \
		STRIP="$(TARGET_STRIP)" \
		\
		$(if $(FREETZ_PACKAGE_TRUECRYPT_STATIC),EXTRA_LDFLAGS="-static")

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TRUECRYPT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TRUECRYPT_TARGET_BINARY)

$(PKG_FINISH)
