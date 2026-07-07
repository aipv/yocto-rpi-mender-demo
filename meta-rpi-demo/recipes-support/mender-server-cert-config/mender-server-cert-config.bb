SUMMARY = "Install Mender server certificate and configure mender.conf"
DESCRIPTION = "Install Mender server certificate and add ServerCertificate to mender.conf"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://server.crt"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/mender
    install -m 0644 ${WORKDIR}/server.crt \
        ${D}${sysconfdir}/mender/server.crt
}

FILES:${PN} += "${sysconfdir}/mender/server.crt"

pkg_postinst:${PN}() {
#!/bin/sh

CONF="$D/etc/mender/mender.conf"

if [ -f "$CONF" ]; then
    if ! grep -q '"ServerCertificate"' "$CONF"; then
        sed -i '1s|{|{\n    "ServerCertificate": "/etc/mender/server.crt",|' "$CONF"
    fi
fi
}
