#
# SlothParseArguemnts.cmake - For internal use only.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

include(CMakeParseArguments)

function(sloth_parse_target_arguments _in)
  set(_flags
    EXPORT
    EXCLUDE_FROM_ALL
    EXCLUDE_FROM_DEFAULT_BUILD
    EXCLUSE_FROM_INSTALL
    STATIC
    SHARED
    MODULE
    INTERFACE
    IMPORTED
    GLOBAL
    WIN32
    MACOSX_BUNDLE
  )

  set(_opts
    VERSION
    COMPATIBILITY
    EXPORT_AS
    GROUP
    ALIAS
    IMPORTED_LOCATION
    COMMAND
    CONFIGURATIONS
    WORKING_DIRECTORY
  )

  set(_args
    SOURCES
    ADDITIONAL_SOURCES
    PUBLIC_COMPILE_OPTIONS
    INTERFACE_COMPILE_OPTIONS
    PRIVATE_COMPILE_OPTIONS
    PUBLIC_COMPILE_DEFINITIONS
    INTERFACE_COMPILE_DEFINITIONS
    PRIVATE_COMPILE_DEFINITIONS
    PUBLIC_INCLUDE_DIRECTORIES
    INTERFACE_INCLUDE_DIRECTORIES
    PRIVATE_INCLUDE_DIRECTORIES
    PUBLIC_LINK_LIBRARIES
    INTERFACE_LINK_LIBRARIES
    PRIVATE_LINK_LIBRARIES
    REQUIRES
    DEPENDS
    RUN
    RUN_FAIL
    COMPILE
    COMPILE_FAIL
  )

  set(_keys ${_flags} ${_opts} ${_args})

  list(APPEND _args
    COMPILE_OPTIONS
    COMPILE_DEFINITIONS
    INCLUDE_DIRECTORIES
    LINK_LIBRARIES
  )

  cmake_parse_arguments("_a" "" "${_keys}" "" ${ARGN})

  cmake_parse_arguments("_arg"
    "${_flags}"
    "${_opts}"
    "${_args}"
    ${_in}
  )

  list(APPEND _arg_PUBLIC_COMPILE_OPTIONS ${_arg_COMPILE_OPTIONS})
  list(APPEND _arg_PUBLIC_COMPILE_DEFINITIONS ${_arg_COMPILE_DEFINITIONS})
  list(APPEND _arg_PUBLIC_INCLUDE_DIRECTORIES ${_arg_INCLUDE_DIRECTORIES})
  list(APPEND _arg_PUBLIC_LINK_LIBRARIES ${_arg_LINK_LIBRARIES})

  foreach(_k ${_keys} UNPARSED_ARGUMENTS)
    if("_a_${_k}")
      set("${_a_${_k}}" ${_arg_${_k}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(sloth_parse_library_config _in)
  set(_flags
  )

  set(_opts
  )

  set(_args
    debug
    optimized
    general
  )

  set(_keys ${_flags} ${_opts} ${_args} unknown)
  sloth_list_string(_Keys TOUPPER ${_keys})
  cmake_parse_arguments("_a" "" "${_Keys}" "" ${ARGN})

  cmake_parse_arguments("_arg"
    "${_flags}"
    "${_opts}"
    "${_args}"
    ${_in}
  )

  foreach(_k ${_keys} UNPARSED_ARGUMENTS)
    string(TOUPPER ${_k} _K)
    if("_a_${_K}")
      set("${_a_${_K}}" ${_arg_${_k}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(sloth_parse_declare_library_arguments _in)
  set(_flags
  )

  set(_opts
    VERSION
    COMPATIBILITY
  )

  set(_args
    COMPILE_DEFINITIONS
    INCLUDE_DIRECTORIES
    LINK_LIBRARIES
    REQUIRES
  )

  set(_keys ${_flags} ${_opts} ${_args})

  cmake_parse_arguments("_a" "" "${_keys}" "" ${ARGN})

  cmake_parse_arguments("_arg"
    "${_flags}"
    "${_opts}"
    "${_args}"
    ${_in}
  )

  foreach(_k ${_keys} UNPARSED_ARGUMENTS)
    if("_a_${_k}")
      set("${_a_${_k}}" ${_arg_${_k}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

