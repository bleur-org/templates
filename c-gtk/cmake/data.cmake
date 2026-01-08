# We gonna need gresources for data generation
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/gresources.cmake")

add_custom_target(cgtk DEPENDS ${GRESOURCE_C})
add_dependencies(${PROJECT_NAME} cgtk-resource)
