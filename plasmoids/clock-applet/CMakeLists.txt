project(nx-clock-applet)

set(PROJECT_VERSION "1.0")
set(PROJECT_VERSION_MAJOR 1)

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

find_package(ECM 1.8.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

include(ECMPackageConfigHelpers)
include(ECMOptionalAddSubdirectory)
include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Core
    Qml
    Quick
)


find_package(KF5 REQUIRED
    I18n Plasma)


# add_subdirectory(lib)
# add_subdirectory(plugin)

plasma_install_package(package org.nx.clock)

 file(GLOB_RECURSE APPLET_SRCS package/*)
 add_custom_target(AppletFiles ALL echo SOURCES ${APPLET_SRCS})
