#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Check if running as root.

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt"
else
    APT_COMMAND="apt"
fi


# -- Install build packages.

$APT_COMMAND update -q
$APT_COMMAND install -y --no-install-recommends \
    cmake \
    libmpv-dev \
    meson \
    ninja-build \
    pkg-config \
    qt6-base-dev \
    qt6-base-private-dev \
    qt6-declarative-dev-tools \
    qt6-l10n-tools \
    qt6-wayland-dev \
    qt6-wayland-private-dev


# -- Add package from our repository.

mkdir -p /etc/apt/keyrings

curl -fsSL https://packagecloud.io/nitrux/testing/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux_testing-archive-keyring.gpg

cat <<EOF > /etc/apt/sources.list.d/nitrux-testing.list
deb [signed-by=/etc/apt/keyrings/nitrux_testing-archive-keyring.gpg] https://packagecloud.io/nitrux/testing/debian/ duke main
EOF

$APT_COMMAND update -q
$APT_COMMAND install -y --no-install-recommends \
    dfl-applications \
    dfl-ipc \
    dfl-login1 \
    dfl-utils \
    dfl-wayqt-qt6
