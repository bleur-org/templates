find_program(GLIB_COMPILE_RESOURCES NAMES glib-compile-resources REQUIRED)

set(GRESOURCE_C      cgtk.gresource.c)
set(GRESOURCE_XML    cgtk.gresource.xml)
set(GRESOURCE_XML_IN cgtk.gresource.xml.in)
set(GRESOURCE_DEPENDENCIES CACHE INTERNAL "GResource dependencies for cgtk")

set(OLD ${CMAKE_CURRENT_SOURCE_DIR}/${GRESOURCE_XML_IN})
set(NEW ${CMAKE_CURRENT_BINARY_DIR}/${GRESOURCE_XML})

if(NOT EXISTS ${NEW} OR (${OLD} IS_NEWER_THAN ${NEW}))
  configure_file(${GRESOURCE_XML_IN} ${GRESOURCE_XML})

  execute_process(
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND ${GLIB_COMPILE_RESOURCES} --generate-dependencies ${GRESOURCE_XML}
        OUTPUT_VARIABLE GRESOURCE_DEPENDENCIES
    )

  # OUTPUT_VARIABLE is not a list but a single string value with newlines
  # Convert it to a list and pop out the last newline character
  string(REPLACE "\n" ";" GRESOURCE_DEPENDENCIES ${GRESOURCE_DEPENDENCIES})
  list(POP_BACK GRESOURCE_DEPENDENCIES)
endif()

add_custom_command(
    OUTPUT ${GRESOURCE_C}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${GLIB_COMPILE_RESOURCES}
    ARGS
        --generate-source
        --target=${CMAKE_CURRENT_BINARY_DIR}/${GRESOURCE_C}
        ${NEW}
    VERBATIM
    MAIN_DEPENDENCY ${GRESOURCE_XML}
    DEPENDS ${GRESOURCE_DEPENDENCIES}
)
