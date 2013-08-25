#
# SlothAddTarget.cmake - Defines high level functions to add targets.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

function(sloth_target_setup _name)
  sloth_parse_target_arguments("${ARGN}"
    EXCLUDE_FROM_ALL              _exclude_from_all
    EXCLUDE_FROM_DEFAULT_BUILD    _exclude_from_default_build
    GROUP                         _group
    CONFIGURATIONS                _cfgs
    SOURCES                       _src
    PUBLIC_COMPILE_DEFINITIONS    _public_defs
    INTERFACE_COMPILE_DEFINITIONS _interface_defs
    PRIVATE_COMPILE_DEFINITIONS   _private_defs
    PUBLIC_INCLUDE_DIRECTORIES    _public_include_dirs
    INTERFACE_INCLUDE_DIRECTORIES _interface_include_dirs
    PRIVATE_INCLUDE_DIRECTORIES   _private_include_dirs
    LINK_LIBRARIES                _link_libs
    REQUIRES                      _requires
    DEPENDS                       _depends
    UNPARSED_ARGUMENTS            _unparsed_args
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for target `${_name}'")
  endif()

  if(_group)
    sloth_target_group("${_group}" "${_name}")
  endif()

  set_target_properties("${_name}"
    PROPERTIES
      EXCLUDE_FROM_ALL ${_exclude_from_all}
      EXCLUDE_FROM_DEFAULT_BUILD ${_exclude_from_default_build}
  )

  if(_requires)
    foreach(_req ${_requires})
      list(APPEND _required_defs $<TARGET_PROPERTY:${_req},INTERFACE_COMPILE_DEFINITIONS>)

      list(APPEND _required_inc_dirs $<TARGET_PROPERTY:${_req},INTERFACE_INCLUDE_DIRECTORIES>)

      # TODO: waiting for INTERFACE library type in CMake 2.8.13(?)
      #       UNKNOWN type is missused as a workaround
      list(APPEND _required_libs
        $<$<NOT:$<STREQUAL:$<TARGET_PROPERTY:${_req},TYPE>,UNKNOWN_LIBRARY>>:${_req}>
        $<$<STREQUAL:$<TARGET_PROPERTY:${_req},TYPE>,UNKNOWN_LIBRARY>:$<TARGET_PROPERTY:${_req},LINK_INTERFACE_LIBRARIES>>
        $<$<STREQUAL:$<TARGET_PROPERTY:${_req},TYPE>,UNKNOWN_LIBRARY>:$<TARGET_PROPERTY:${_req},LINK_LIBRARIES>>
      )
    endforeach()
  endif()

  set(_private_def   ${_private_defs}   ${_public_defs} ${_required_defs})
  set(_interface_def ${_interface_defs} ${_public_defs} ${_required_defs})

  if(_private_def)
    target_compile_definitions("${_name}" PRIVATE ${_private_def})
  endif()
  if(_interface_def)
    target_compile_definitions("${_name}" INTERFACE ${_interface_def})
  endif()

  set(_private_inc   ${_private_include_dirs}   ${_public_include_dirs} ${_required_inc_dirs})
  set(_interface_inc ${_interface_include_dirs} ${_public_include_dirs} ${_required_inc_dirs})

  if(_private_inc)
    target_include_directories("${_name}" PRIVATE ${_private_inc})
  endif()
  if(_interface_inc)
    target_include_directories("${_name}" INTERFACE ${_interface_inc})
  endif()

  if(_link_libs OR _required_libs)
    target_link_libraries("${_name}" ${_link_libs} ${_required_libs})
  endif()

  if(_depends)
    add_dependencies("${_name}" ${_depends})
  endif()
endfunction()

function(sloth_add_library _name)
  sloth_parse_target_arguments("${ARGN}"
    STATIC               _static
    SHARED               _shared
    MODULE               _module
    SOURCES              _src
    REQUIRES             _req
    COMPONENT            _comp
    EXCLUSE_FROM_INSTALL _noinst
  )
  if(_module)
    set(_type "MODULE")
  elseif(_shared)
    set(_type "SHARED")
  elseif(_static)
    set(_type "STATIC")
  else()
    set(_type "")
  endif()
  sloth_set_iff(_comp _comp _comp "library")
  add_library("${_name}" ${_type} ${_src})
  sloth_target_setup("${_name}" ${ARGN})
  if(NOT _noinst)
    install(TARGETS "${_name}" # EXPORT "${_name}Targets"
      RUNTIME DESTINATION bin COMPONENT "${_comp}"
      LIBRARY DESTINATION lib COMPONENT "${_comp}"
      ARCHIVE DESTINATION lib/static COMPONENT "${_comp}"
      RESOURCE DESTINATION share COMPONENT "${_comp}"
      PUBLIC_HEADER DESTINATION include COMPONENT "${_comp}"
    )
    #install(EXPORT "${_name}Targets"
    #  FILE "${_name}Targets.cmake"
    #  DESTINATION "CMake"
    #)
  endif()
endfunction()

function(sloth_add_executable _name)
  sloth_parse_target_arguments("${ARGN}"
    SOURCES              _src
    REQUIRES             _req
    COMPONENT            _comp
    EXCLUSE_FROM_INSTALL _noinst
  )
  sloth_set_iff(_comp _comp _comp "executable")
  add_executable("${_name}" ${_src})
  sloth_target_setup("${_name}" ${ARGN})
  if(NOT _noinst)
    install(TARGETS "${_name}"
      RUNTIME DESTINATION bin COMPONENT "${_comp}"
      RESOURCE DESTINATION share COMPONENT "${_comp}"
    )
  endif()
endfunction()

function(sloth_add_test _name)
  sloth_parse_target_arguments("${ARGN}"
    SOURCES           _src
    ARGS              _args
    CONFIGURATIONS    _cfgs
    WORKING_DIRECTORY _wdir
  )
  add_executable("${_name}" ${_src})
  sloth_target_setup("${_name}" ${ARGN})
  add_test(NAME "${_name}"
    COMMAND "${_name}" ${_args}
    CONFIGURATIONS ${_cfgs}
    WORKING_DIRECTORY ${_wdir}
  )
endfunction()
