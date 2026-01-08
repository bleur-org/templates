cmake_minimum_required(VERSION 3.26)
project(cgtk C)

# C properties
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Include libraries
include_directories(./include)

# Include source codes
file(
  GLOB SOURCES CONFIGURE_DEPENDS
  "include/*.h"
  "src/*.c"
)

# Output executable binary
add_executable(cgtk ${SOURCES})

# Pkg-config for GTK
find_package(PkgConfig REQUIRED)
set(PKG_CONFIG_EXECUTABLE $ENV{PKG_CONFIG_EXECUTABLE})

# GTK oriented properties
pkg_check_modules(GTK4 REQUIRED IMPORTED_TARGET gtk4)
target_link_libraries(cgtk PRIVATE PkgConfig::GTK4)

# Adding debug prints
set(CMAKE_BUILD_TYPE Debug)

# Copy the executable to bin directory
install(TARGETS cgtk DESTINATION bin)
