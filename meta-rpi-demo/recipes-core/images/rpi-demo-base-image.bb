SUMMARY = "Raspberry Pi demo base image"

require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " \
    tree \
    openssh \
    openssh-sshd \
"
