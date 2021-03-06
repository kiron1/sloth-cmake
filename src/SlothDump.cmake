#
# SlothDump.cmake - Dump target properties to a yml file
#
# sloth_dump_target(file targets...)
#
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

if(_SLOTH_DUMP_CMAKE_INCLUDED)
  return()
endif()
set(_SLOTH_DUMP_CMAKE_INCLUDED 1)

function(sloth_dump_target _name)
  set(_properties
    EXPORT_NAME
    TYPE
    MACOSX_BUNDLE
    WIN32_EXECUTABLE
    IMPORTED
    IMPORTED_LOCATION
    IMPORTED_LOCATION_DEBUG
    IMPORTED_LOCATION_RELEASE
    IMPORTED_LOCATION_RELWITHDEBINFO
    IMPORTED_LOCATION_MINSIZEREL
    EXCLUDE_FROM_ALL
    EXCLUDE_FROM_DEFAULT_BUILD
    INTERFACE_COMPILE_DEFINITIONS
    COMPILE_DEFINITIONS
    INTERFACE_INCLUDE_DIRECTORIES
    INCLUDE_DIRECTORIES
    INTERFACE_COMPILE_OPTIONS
    COMPILE_OPTIONS
    INTERFACE_POSITION_INDEPENDENT_CODE
    POSITION_INDEPENDENT_CODE
    LINK_LIBRARIES
    LINK_INTERFACE_LIBRARIES
    INTERFACE_LINK_LIBRARIES
    SOURCES
  )

  if(CMAKE_VERSION VERSION_GREATER 2.8.12.201312115)
    set(_file "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_name}.in")
    file(GENERATE
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${_name}"
      INPUT "${_file}"
    )
  else()
    set(_file "${CMAKE_CURRENT_BINARY_DIR}/${_name}")
  endif()

  file(WRITE "${_file}" "\n")

  foreach(_target IN LISTS ARGN)
    file(APPEND "${_file}" "${_target}:\n")

    foreach(_prop IN LISTS _properties)
      string(TOLOWER "${_prop}" _lowprop)
      get_target_property(_propval ${_target} ${_prop})
      if(_propval)
        file(APPEND "${_file}" "  ${_lowprop}:\n")
        foreach(_val IN LISTS _propval)
          file(APPEND "${_file}" "    - ${_val}\n")
        endforeach()
        file(APPEND "${_file}" "\n")
      endif()
    endforeach()

    file(APPEND "${_file}" "\n")
  endforeach()
endfunction()

