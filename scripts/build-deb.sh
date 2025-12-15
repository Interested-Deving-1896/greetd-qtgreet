#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Download Source.

SRC_DIR="$(mktemp -d)"

git clone --depth 1 --branch "$QTGREET_BRANCH" https://gitlab.com/marcusbritanicus/QtGreet.git "$SRC_DIR/qtgreet-src"

cd "$SRC_DIR/qtgreet-src"


# -- Configure Build.

meson setup .build --prefix=/usr --buildtype=release


# -- Compile Source.

ninja -C .build -k 0 -j "$(nproc)"


# -- Create a temporary DESTDIR.

DESTDIR="$(pwd)/pkg"

rm -rf "$DESTDIR"


# -- Install to DESTDIR.

DESTDIR="$DESTDIR" ninja -C .build install


# -- Create DEBIAN control file.

mkdir -p "$DESTDIR/DEBIAN"

PKGNAME="greetd-qtgreet"
MAINTAINER="uri_herrera@nxos.org"
ARCHITECTURE="$(dpkg --print-architecture)"
DESCRIPTION="Qt based greeter for greetd, to be run under wayfire or similar wlr-based compositors."

cat > "$DESTDIR/DEBIAN/control" <<EOF
Package: $PKGNAME
Version: $PACKAGE_VERSION
Section: utils
Priority: optional
Architecture: $ARCHITECTURE
Maintainer: $MAINTAINER
Description: $DESCRIPTION
Depends: dfl-applications, dfl-ipc, dfl-login1, dfl-utils, dfl-wayqt-qt6, libmpv2, libqt6core6t64, libqt6gui6, libqt6openglwidgets6, libqt6waylandclient6, libqt6widgets6, qt6-wayland, greetd
EOF


# -- Build the Debian package.

cd "$(dirname "$DESTDIR")"

dpkg-deb --build "$(basename "$DESTDIR")" "${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb"


# -- Move .deb to ./build/ for CI consistency.

mkdir -p "$GITHUB_WORKSPACE/build"

mv "${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb" "$GITHUB_WORKSPACE/build/"

echo "Debian package created: $(pwd)/build/${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb"
