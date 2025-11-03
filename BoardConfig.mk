# config.mk
#
# Product-specific compile-time definitions.
#
TARGET_KERNEL_DLKM_DISABLE := true
TARGET_SEPOLICY_DIR := gen4_gvm

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic

BOARD_SECCOMP_POLICY := device/qcom/$(TARGET_BOARD_PLATFORM)/seccomp

TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true
TARGET_NO_KERNEL := false

TARGET_SCREEN_DENSITY := 160
BUILD_BROKEN_DUP_RULES := true
BOARD_RAMDISK_USE_LZ4 := true

BOARD_INCLUDE_DTB_IN_BOOTIMG := true


-include $(QCPATH)/common/gen5_gvm/BoardConfigVendor.mk

# Some framework code requires this to enable BT
BOARD_HAVE_BLUETOOTH := true
BOARD_USES_WIPOWER := false
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/qcom/common/automotive

USE_OPENGL_RENDERER := true
BOARD_USE_LEGACY_UI := true
# Set Header version for bootimage
BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION)

ifeq ($(TARGET_SINGLE_TREE), true)
  BOARD_SYSTEM_QCOM_GPS_LOC_API_HARDWARE := default
endif

ifeq ($(TARGET_NO_RECOVERY), true)
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
endif

# Specify init boot header version
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

### Dynamic partition Handling
ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
  ifeq ($(ENABLE_VENDOR_IMAGE), true)
    BOARD_VENDORIMAGE_PARTITION_SIZE := 1073741824
  endif
  BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3221225472
  BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
  ifeq ($(ENABLE_AB), true)
      TARGET_NO_RECOVERY := true
      BOARD_USES_RECOVERY_AS_BOOT := false
  else
      BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x04000000
  endif
else
  # System_ext support
  TARGET_COPY_OUT_SYSTEM_EXT := system_ext
  BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4

 ifeq ($(TARGET_SINGLE_TREE), true)
    BOARD_USES_PRODUCTIMAGE := true
    TARGET_COPY_OUT_PRODUCT := product
    BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
 endif
 ifeq ($(TARGET_BOARD_DERIVATIVE_SUFFIX), _microdroid)
    BOARD_USES_PRODUCTIMAGE := true
    TARGET_COPY_OUT_PRODUCT := product
    BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
 endif

  # System DLKM dynamic Partition support
  BOARD_USES_SYSTEM_DLKMIMAGE := true
  TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
  BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4

  # Vendor DLKM dynamic partition support
  BOARD_USES_VENDOR_DLKMIMAGE := true
  BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
  TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

  # Define the Dynamic Partition sizes and groups.
  ifeq ($(ENABLE_AB), true)
    TARGET_NO_RECOVERY := true
    BOARD_USES_RECOVERY_AS_BOOT := false
    BOARD_SUPER_PARTITION_SIZE := 12884901888
  else
    BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
    BOARD_SUPER_PARTITION_SIZE := 6442450944 #6GB
  endif
  BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
  BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 6438256640 #(6GB - 4MB)
  ifeq ($(TARGET_SINGLE_TREE), true)
    BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := vendor vendor_dlkm system_dlkm system system_ext product
  else ifeq ($(TARGET_BOARD_DERIVATIVE_SUFFIX), _microdroid)
    BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := vendor vendor_dlkm system_dlkm system system_ext product
  else
    BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := vendor vendor_dlkm system_dlkm
  endif
  BOARD_EXT4_SHARE_DUP_BLOCKS := true
endif

#Generate DTBO image
BOARD_KERNEL_SEPARATED_DTBO := false

ifeq ($(BOARD_KERNEL_SEPARATED_DTBO),true)
    # Enable DTBO for recovery image
    BOARD_INCLUDE_RECOVERY_DTBO := true
endif

### Dynamic partition Handling

# Defines for enabling A/B builds
AB_OTA_UPDATER := true
ifeq ($(ENABLE_AB), true)
 # Full A/B partition update set
    ifeq ($(TARGET_SINGLE_TREE), true)
      AB_OTA_PARTITIONS ?= vendor vbmeta vendor_dlkm system_dlkm system system_ext product boot init_boot vendor_boot
    else ifeq ($(TARGET_BOARD_DERIVATIVE_SUFFIX), _microdroid)
      AB_OTA_PARTITIONS ?= vendor vbmeta vendor_dlkm system_dlkm system system_ext product boot init_boot vendor_boot
    else
      AB_OTA_PARTITIONS ?= vendor vbmeta vendor_dlkm system_dlkm boot init_boot vendor_boot
    endif
else
  AB_OTA_PARTITIONS ?= boot system
  ifneq ($(BOARD_USES_RECOVERY_AS_BOOT), true)
    ifeq ($(BOARD_AVB_ENABLE), true)
      BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
      BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
      BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
      BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
    endif
  endif
endif
#Enable compilation of oem-extensions to recovery
#These need to be explicitly 
ifneq ($(AB_OTA_UPDATER),true)
  TARGET_RECOVERY_UPDATER_LIBS += librecovery_updater_msm
endif

TARGET_RECOVERY_FSTAB := device/qcom/gen5_gvm/fstab.gen5.qti
#Enable Metadata compilation and adding metadata related attributes
BOARD_USES_METADATA_PARTITION := true
BOARD_METADATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_METADATAIMAGE_PARTITION_SIZE := 67108864
TARGET_HW_DISK_ENCRYPTION := false
TARGET_HW_DISK_ENCRYPTION_PERF := false

#Enable split vendor image
ENABLE_VENDOR_IMAGE := true
ifeq ($(ENABLE_VENDOR_IMAGE), true)
  BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
  TARGET_COPY_OUT_VENDOR := vendor
  BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
endif

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x04000000
BOARD_KERNEL-GKI_BOOTIMAGE_PARTITION_SIZE := $(BOARD_BOOTIMAGE_PARTITION_SIZE)
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 0x04000000
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 0x00800000
# Userdata partition size is set to 49GB
BOARD_USERDATAIMAGE_PARTITION_SIZE := 52613349376
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_PREBUILT_DTBOIMAGE := out/target/product/gen4_gvm/prebuilt_dtbo.img
BOARD_DTBOIMG_PARTITION_SIZE := 0x0800000
BOARD_PERSISTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

#----------------------------------------------------------------------
# Compile Linux Kernel
#----------------------------------------------------------------------
ifeq ($(KERNEL_DEFCONFIG),)
    ifeq ($(TARGET_BUILD_VARIANT),user)
        KERNEL_DEFCONFIG := autogvm-qgki_defconfig
    else
        KERNEL_DEFCONFIG := autogvm-qgki-debug_defconfig
    endif
endif

BOARD_DO_NOT_STRIP_VENDOR_MODULES := true
TARGET_USES_ION := true
TARGET_USES_NEW_ION_API :=true
TARGET_USES_QCOM_BSP := false

BOARD_BOOTCONFIG := androidboot.hardware=qcom androidboot.selinux=enforcing androidboot.memcg=1 androidboot.recover_usb=1 androidboot.usbcontroller=a200000.dwc3

BOARD_KERNEL_CMDLINE := debug user_debug=31 loglevel=9 print-fatal-signals=1  init=/init swiotlb=4096  kpti=0 pcie_ports=compat firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7

ifeq ($(TARGET_CONSOLE_ENABLED),true)
BOARD_KERNEL_CMDLINE += console=hvc0,115200
BOARD_BOOTCONFIG += androidboot.console=hvc0
else ifeq ($(TARGET_CONSOLE_ENABLED),false)
BOARD_KERNEL_CMDLINE += qcom_geni_serial.con_enabled=0
endif

BOARD_EGL_CFG := device/qcom/$(TARGET_BOARD_PLATFORM)/egl.cfg

BOARD_KERNEL_BASE        := 0x00000000
BOARD_KERNEL_PAGESIZE    := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x01E00000
BOARD_RAMDISK_OFFSET     := 0x02000000

TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(shell pwd)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-


MAX_EGL_CACHE_KEY_SIZE := 12*1024
MAX_EGL_CACHE_SIZE := 2048*1024

BOARD_USES_GENERIC_AUDIO := true
BOARD_QTI_CAMERA_32BIT_ONLY := true
TARGET_NO_RPC := true

TARGET_PLATFORM_DEVICE_BASE := /devices/soc.0/
TARGET_INIT_VENDOR_LIB := libinit_msm

TARGET_KERNEL_APPEND_DTB := false
TARGET_COMPILE_WITH_MSM_KERNEL := false
TARGET_SIGNONLY_BOOTLOADER := true

#Enable PD locater/notifier
TARGET_PD_SERVICE_ENABLED := true

#Enable peripheral manager
TARGET_PER_MGR_ENABLED := true

#Set WITH_DEXPREOPT_DEBUG_INFO := false to resolve below error
#Cannot override readonly variable PRODUCT_DEX_PREOPT_BOOT_FLAGS
WITH_DEXPREOPT_DEBUG_INFO := false

# Enable dex pre-opt to speed up initial boot
ifeq ($(HOST_OS),linux)
    ifeq ($(WITH_DEXPREOPT),)
      WITH_DEXPREOPT := true
      WITH_DEXPREOPT_PIC := true
      ifneq ($(TARGET_BUILD_VARIANT),user)
        # Retain classes.dex in APK's for non-user builds
        DEX_PREOPT_DEFAULT := nostripping
      endif
    endif
endif

TARGET_USES_GRALLOC1 := true

# Enable sensor multi HAL
USE_SENSOR_MULTI_HAL := false

# Enable sensor Version V_1
USE_SENSOR_HAL_VER := 1.0
#Add non-hlos files to ota packages
ADD_RADIO_FILES := true

#Enable INTERACTION_BOOST
TARGET_USES_INTERACTION_BOOST := true

#Enable DRM plugins 64 bit compilation
TARGET_ENABLE_MEDIADRM_64 := true

#namespace definition for librecovery_updater
#differentiate legacy 'sg' or 'bsg' framework
SOONG_CONFIG_NAMESPACES += ufsbsg
SOONG_CONFIG_ufsbsg += ufsframework
SOONG_CONFIG_ufsbsg_ufsframework := bsg

SOONG_CONFIG_NAMESPACES += android_hardware_audio
SOONG_CONFIG_android_hardware_audio += run_64bit
SOONG_CONFIG_android_hardware_audio_run_64bit := true

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
ifeq ($(strip $(BOARD_HAS_QCOM_WLAN)),true)
include device/qcom/wlan/msmnile_au/BoardConfigWlan.mk
endif

$(call add_soong_config_var,qti,IS_ANDROID_SHIPPING_W)
$(call soong_config_set,qti,IS_ANDROID_SHIPPING_W,true)

#################################################################################
# This is the End of BoardConfig.mk file.
# Now, Pickup other split Board.mk files:
#################################################################################
# TODO: Relocate the system Board.mk files pickup into qssi lunch, once it is up.
-include vendor/qcom/defs/board-defs/system/*.mk
-include vendor/qcom/defs/board-defs/vendor/*.mk
#################################################################################

include device/qcom/sepolicy_vndr/SEPolicy.mk

BUILD_BROKEN_NINJA_USES_ENV_VARS := SDCLANG_AE_CONFIG SDCLANG_CONFIG SDCLANG_SA_ENABLED SDCLANG_CONFIG_AOSP
BUILD_BROKEN_NINJA_USES_ENV_VARS += TEMPORARY_DISABLE_PATH_RESTRICTIONS
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_USES_BUILD_HOST_SHARED_LIBRARY := true
BUILD_BROKEN_USES_BUILD_HOST_EXECUTABLE := true
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true
BUILD_BROKEN_USES_BUILD_HOST_STATIC_LIBRARY := true
BUILD_BROKEN_CLANG_PROPERTY := true
#Enable Camera2 APIs on automotive builds
ENABLE_CAMERA_SERVICE := true

#We are sorting BOARD_VENDOR_KERNEL_MODULES due to BoardConfig.mk invoked twice
#   1. From vendor/qcom/proprietary/common/config/device-vendor.mk
#   2. From build/make/core/board_config.mk
#which impacts duplicates found in vendor_dlkm partition while building image
BOARD_VENDOR_KERNEL_MODULES := $(sort $(BOARD_VENDOR_KERNEL_MODULES))
