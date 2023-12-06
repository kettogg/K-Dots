#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt-get"
else
    APT_COMMAND="apt-get"
fi

$APT_COMMAND update -q
$APT_COMMAND install -qy --no-install-recommends \
    appstream \
    automake \
    autotools-dev \
    build-essential \
    checkinstall \
    cmake \
    curl \
    devscripts \
    equivs \
    extra-cmake-modules \
    gettext \
    git \
    gnupg2 \
    kirigami2-dev \
    libkdecorations2-dev \
    libkf5activities-dev \
    libkf5activitiesstats-dev \
    libkf5archive-dev \
    libkf5configwidgets-dev \
    libkf5coreaddons-dev \
    libkf5crash-dev \
    libkf5declarative-dev \
    libkf5guiaddons-dev \
    libkf5i18n-dev \
    libkf5iconthemes-dev\
    libkf5kcmutils-dev \
    libkf5kio-dev \
    libkf5networkmanagerqt-dev \
    libkf5newstuff-dev \
    libkf5notifications-dev \
    libkf5plasma-dev \
    libkf5solid-dev \
    libkf5wayland-dev \
    libkf5windowsystem-dev \
    libqt5svg5-dev \
    libqt5x11extras5-dev \
    libqt5x11extras5-dev \
    libsm-dev \
    libwayland-dev \
    libx11-xcb-dev \
    libxcb-randr0-dev \
    libxcb-shape0-dev \
    libxcb-util-dev \
    libxcb-xkb-dev \
    libxkbcommon-x11-dev \
    lintian \
    plasma-wayland-protocols \
    plasma-workspace-dev \
    qml-module-qtgraphicaleffects \
    qml-module-qtquick-controls \
    qml-module-qtquick-shapes \
    qt5-qmake  \
    qtbase5-dev \
    qtbase5-dev-tools  \
    qtchooser  \
    qtdeclarative5-dev \
    qtmultimedia5-dev  \
    qtquickcontrols2-5-dev  \
    qttools5-dev \
    qtwayland5 \
    qtwayland5-dev-tools \
    qtwayland5-private-dev \
    x11-xkb-utils \
    xcb
