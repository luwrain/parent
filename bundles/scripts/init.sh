# Copyright 2012-2024 Michael Pozhidaev <msp@luwrain.org>
# The LUWRAIN Project, GPL v.3

THIS="${0##*/}"

if [ -r base/scripts/config.sh ]; then
    cd base/scripts
fi

. config.sh

PWD=$(pwd)
if [ -z "$SRC_DIR" ]; then
    export SRC_DIR="${PWD%/base/scripts*}"
fi
SCRIPTS_DIR="$SRC_DIR/base/scripts"

if ! [ -e "$SRC_DIR/base/scripts/init.sh" ]; then
    echo "ERROR: $THIS: Something wrong with the current directory:no \$SRC_DIR/base/scripts/init.sh" >&2
    exit 1
fi

export PATH="$SCRIPTS_DIR:$PATH"
cd "$SRC_DIR"
