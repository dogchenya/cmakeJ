find_path(LIBFMT_INCLUDE_DIR fmt/core.h)
mark_as_advanced(LIBFMT_INCLUDE_DIR)

find_library(LIBFMT_LIBRARY NAMES fmt fmtd)
mark_as_advanced(LIBFMT_LIBRARY)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    LIBFMT
    DEFAULT_MSG
    LIBFMT_LIBRARY LIBFMT_INCLUDE_DIR)

if(LIBFMT_FOUND)
    set(LIBFMT_LIBRARIES ${LIBFMT_LIBRARY})
    set(LIBFMT_INCLUDE_DIRS ${LIBFMT_INCLUDE_DIR})
    message(STATUS "Found {fmt}: ${LIBFMT_LIBRARY}")
    add_library(fmt::fmt UNKNOWN IMPORTED)
    set_target_properties(
      fmt::fmt PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${LIBFMT_INCLUDE_DIR}"
    )
    set_target_properties(
      fmt::fmt PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_LOCATION "${LIBFMT_LIBRARY}"
    )
endif()