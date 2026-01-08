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

# Include gtk configurations
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/gtk.cmake")

# Adding debug prints
set(CMAKE_BUILD_TYPE Debug)

# Copy the executable to bin directory
install(TARGETS cgtk DESTINATION bin)
