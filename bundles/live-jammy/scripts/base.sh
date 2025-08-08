
LWRISO_VERSION=2.0.1
UBUNTU_RELEASE=jammy
LWRISO_BOOT_VER=22.04.3
LWRISO_USER=luwrain
LWRISO_ARCH=amd64
LWRISO_DATE="$(date +%Y%m%d)"
LWRISO_NAMESERVER=8.8.8.8
LWRISO_LANG=ru
if [ -z "$LWRISO_ROOT" ]; then
    export LWRISO_ROOT=/iso/chroot
fi

chroot-run()
{
    chroot $LWRISO_ROOT "$@"
}

install-pkg()
{
chroot-run apt-get --yes install $@
}

remove-pkg()
{
chroot-run apt-get --yes remove $@
}

rm-pkg()
{
chroot-run apt-get --yes remove --ignore-missing --no-download $@
}

remove-pkg-prefix()
{
    remove-pkg $(apt-cache search "$1" | grep "^$1" | cut -f1 -d' ')
}

latest-iso()
{
    curl https://download.luwrain.org/nightly/latest/ 2> /dev/null | egrep -o  'luwrain-iso-[a-z0-9-]*.tar.gz' | head -n 1
}
