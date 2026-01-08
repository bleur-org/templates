cmake_minimum_required(VERSION 3.26)
project(example C)

set(CMAKE_C_STANDARD 23)

include_directories(./include)
include_directories($ENV{LD_LIBRARY_PATH})

file(
  GLOB SOURCES CONFIGURE_DEPENDS
  "include/*.h"
  "src/*.c"
)

add_executable(example ${SOURCES})

set(CMAKE_BUILD_TYPE Debug)

install(TARGETS example DESTINATION bin)
