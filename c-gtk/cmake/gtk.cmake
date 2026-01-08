# Pkg-config for GTK
find_package(PkgConfig REQUIRED)
set(PKG_CONFIG_EXECUTABLE $ENV{PKG_CONFIG_EXECUTABLE})

# GTK oriented properties
pkg_check_modules(GTK4 REQUIRED IMPORTED_TARGET gtk4>=4.16.5)
message("GTK4 include dir: ${GTK4_INCLUDE_DIRS}")
message("GTK4 libraries: ${GTK4_LIBRARY_DIRS}")
message("GTK4 other Cflags: ${GTK4_CFLAGS_OTHER}")
target_link_libraries(cgtk PRIVATE PkgConfig::GTK4)

# Libadwaita for theming
pkg_check_modules(ADW REQUIRED IMPORTED_TARGET libadwaita-1>=1.6.1)
message("ADW include dir: ${ADW_INCLUDE_DIRS}")
message("ADW libraries: ${ADW_LIBRARY_DIRS}")
message("ADW other Cflags: ${ADW_CFLAGS_OTHER}")
target_link_libraries(cgtk PRIVATE PkgConfig::ADW)

# C Flags
message(STATUS "Flags: ${CMAKE_C_FLAGS}")
