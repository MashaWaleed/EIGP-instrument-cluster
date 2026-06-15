cmake_minimum_required(VERSION 3.16)

project(eigp-instrument-cluster VERSION 0.1 LANGUAGES CXX)

option(EIGP_DEMO_FIRMWARE
    "Build demo firmware with simulated gauges and keyboard torque input"
    OFF)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Qml)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Qml)

set(PROJECT_SOURCES
    src/dashboarddatacontroller.cpp
    src/dashboarddatacontroller.h
    src/main.cpp
    resources/qml.qrc
)

if(NOT EIGP_DEMO_FIRMWARE)
    list(APPEND PROJECT_SOURCES
        src/dashboardcansource.cpp
        src/dashboardcansource.h
        src/canprotocol.h
    )
endif()

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(eigp-instrument-cluster
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
else()
    if(ANDROID)
        add_library(eigp-instrument-cluster SHARED
            ${PROJECT_SOURCES}
        )
    else()
        add_executable(eigp-instrument-cluster
            ${PROJECT_SOURCES}
        )
    endif()
endif()

target_include_directories(eigp-instrument-cluster PRIVATE src)

if(EIGP_DEMO_FIRMWARE)
    target_compile_definitions(eigp-instrument-cluster PRIVATE EIGP_DEMO_FIRMWARE)
endif()

target_link_libraries(eigp-instrument-cluster
    PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::Qml)

if(${QT_VERSION} VERSION_LESS 6.1.0)
    set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.eigp.instrument-cluster)
endif()

set_target_properties(eigp-instrument-cluster PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS eigp-instrument-cluster
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(eigp-instrument-cluster)
    qt_finalize_executable(eigp-instrument-cluster)
endif()
