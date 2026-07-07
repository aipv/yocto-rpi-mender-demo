SUMMARY = "Install image version information"
DESCRIPTION = "Install /etc/image-version with build timestamp"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://image-version"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}

    install -m 0644 ${WORKDIR}/image-version \
        ${D}${sysconfdir}/image-version

    BUILD_TIME="$(date '+%Y-%m-%d %H:%M:%S %Z')"

    sed -i \
        "s|^Build Time[[:space:]]*:.*|Build Time : ${BUILD_TIME}|" \
        ${D}${sysconfdir}/image-version
}

FILES:${PN} += "${sysconfdir}/image-version"
