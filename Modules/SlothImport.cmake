#
# SlothImport.cmake - Convenient way to create a imported library.
#
# Creates a library which can be used for usage requirements
# propagation.
#
# sloth_declare_library(name type
# )
#
# sloth_import_package(name type
# )
#
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

function(sloth_declare_library _name _type)
  sloth_parse_declare_library_arguments("${ARGN}"
    COMPILE_DEFINITIONS _defs
    INCLUDE_DIRECTORIES _incdirs
    LINK_LIBRARIES      _libs
    REQUIRES            _requires
    UNPARSED_ARGUMENTS  _unparsed_args
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for library declaration `${_name}'")
  endif()

  # TODO: waiting for INTERFACE library type in CMake 2.8.13(?)
  # then we can replace set_property(...) below with the proper calls
  # to target_compile_definitions, target_include_directories, and
  # target_link_libraries
  add_library("${_name}" "${_type}" IMPORTED GLOBAL)

  if(_defs)
    set_property(TARGET "${_name}" PROPERTY
      INTERFACE_COMPILE_DEFINITIONS ${_defs})
  endif()

  if(_incdirs)
    sloth_list_filename_component(_incdirs ABSOLUTE ${_incdirs})
    set_property(TARGET "${_name}" PROPERTY
      INTERFACE_INCLUDE_DIRECTORIES ${_incdirs})
  endif()

  if(_libs)
    # TODO: wait for Cmake 2.8.13, to get INTERFACE libraries

    sloth_parse_library_config("${_libs}" DEBUG _dbg OPTIMIZED _opt GENERAL _gen UNKNOWN _unk)

    if(_dbg)
      set_property(TARGET "${_name}" APPEND PROPERTY IMPORTED_LOCATION_DEBUG ${_dbg}) # $<$<CONFIG:Debug>:${_dbg}>)
    endif()

    if(_opt)
      set_property(TARGET "${_name}" APPEND PROPERTY IMPORTED_LOCATION_RELEASE ${_opt}) # $<$<CONFIG:Release>:${_opt}>)
    endif()

    if(_gen)
      set(_loc ${_gen})
    elseif(_unk)
      set(_loc ${_unk})
    endif()

    if(_loc)
      set_property(TARGET "${_name}" APPEND PROPERTY IMPORTED_LOCATION ${_loc})
    elseif(_dbg)
      set_property(TARGET "${_name}" APPEND PROPERTY IMPORTED_LOCATION ${_dbg})
    elseif(_opt)
      set_property(TARGET "${_name}" APPEND PROPERTY IMPORTED_LOCATION ${_opt})
    endif()
    
  endif()

  sloth_target_requires("${_name}" ${_requires})
endfunction()

function(sloth_import_package _name _type)
  find_package(${ARGN} REQUIRED QUIET)
  string(TOUPPER "${_req}" _up)
  if("${_up}_FOUND" OR "${_req}_FOUND")

    set(_defs ${${_req}_DEFINITIONS})
    set(_incdirs ${${_req}_INCLUDE_DIRS} ${${_req}_INCLUDES})
    set(_libs ${${_req}_LIBRARIES} ${${_req}_LIBRARIE} ${${_req}_LIBS})

    list(REMOVE_DUPLICATES _defs)
    list(REMOVE_DUPLICATES _incdirs)
    list(REMOVE_DUPLICATES _libs)

    sloth_declare_library("${_name}" "${_type}"
      COMPILE_DEFINITIONS ${_defs}
      INCLUDE_DIRECTORIES ${_incdirs}
      LINK_LIBRARIES      ${_libs}
    )
  endif()
endfunction()
