#
# Mender OTA configuration
#

INHERIT += "mender-full"

MENDER_ARTIFACT_NAME = "release-1"

PREFERRED_VERSION_mender = "5.0.0"


PACKAGECONFIG:remove:pn-mender = "version-inventory-script"

MENDER_BOOT_PART_SIZE_MB = "64"
