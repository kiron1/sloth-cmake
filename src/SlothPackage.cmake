#
# SlothPackage.cmake - Defines high level cmake package function.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

if(_SLOTH_PACKAGE_CMAKE_INCLUDED)
  return()
endif()
set(_SLOTH_PACKAGE_CMAKE_INCLUDED 1)

include(CMakeParseArguments)
include(CMakePackageConfigHelpers)

function(sloth_parse_package_arguments _in)
  set(_flags
    EXCLUDE_FROM_EXPORT
  )

  set(_opts
    NAME
    NAMESPACE
    EXPORT_SET
    COMPONENT
    INSTALL_DESTINATION
    VERSION
    COMPATIBILITY
  )

  set(_args
    TARGETS
    INCLUDE_DIRECTORIES
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

  foreach(_k IN LISTS _keys ITEMS UNPARSED_ARGUMENTS)
    if("_a_${_k}")
      set("${_a_${_k}}" ${_arg_${_k}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(sloth_install)
  sloth_parse_package_arguments("${ARGN}"
    NAME                       _name
    EXPORT_SET                 _export_set
    EXCLUDE_FROM_EXPORT        _exclude_from_export
    COMPONENT                  _comp
    TARGETS                    _targets
    INCLUDE_DIRECTORIES        _incdirs
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for package `${_name}'")
  endif()

  if(NOT _targets)
    message(SEND_ERROR "No list of targets provided to install")
  endif()

  if(NOT _name)
    set(_name ${PROJECT_NAME})
  endif()

  if(NOT _export_set)
    set(_export_set ${_name})
  endif()

  set(_export)
  if(NOT _exclude_from_export)
      set(_export EXPORT "${_export_set}")
  endif()

  # TODO: print warning for targets which are not build by all target

  install(TARGETS ${_targets} ${_export}
    RUNTIME        DESTINATION bin                  COMPONENT "${_comp}"
    LIBRARY        DESTINATION lib                  COMPONENT "${_comp}"
    ARCHIVE        DESTINATION lib/static           COMPONENT "${_comp}-dev"
    PRIVATE_HEADER DESTINATION src/${_name}/include COMPONENT "${_comp}-dev"
    PUBLIC_HEADER  DESTINATION include              COMPONENT "${_comp}-dev"
    RESOURCE       DESTINATION share/${_name}       COMPONENT "${_comp}"
    INCLUDES       DESTINATION include
  )
  if(_incdirs)
    install(DIRECTORY ${_incdirs}
      DESTINATION include
      COMPONENT   "${_comp}-dev"
    )
  endif()
endfunction()

function(sloth_export)
  sloth_parse_package_arguments("${ARGN}"
    NAME                       _name
    NAMESPACE                  _namespace
    EXPORT_SET                 _export_set
    COMPONENT                  _comp
    REQUIRES                   _reqs
    VERSION                    _version
    COMPATIBILITY              _compat
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for package `${_name}'")
  endif()

  if(NOT _name)
    set(_name ${PROJECT_NAME})
  endif()

  if(NOT _version)
    get_property(_version GLOBAL PROPERTY ${_name}_VERSION)
  endif()

  if(NOT _compat)
    get_property(_compat GLOBAL PROPERTY ${_name}_COMPATIBILITY)
    if(NOT _compat)
      set(_compat "ExactVersion")
    endif()
  endif()

  if(NOT _namespace)
    get_property(_namespace GLOBAL PROPERTY ${_name}_NAMESPACE)
  endif()

  if(NOT _reqs)
    get_property(_reqs GLOBAL PROPERTY ${_name}_REQUIRES)
  endif()

  if(NOT _comp)
    set(_comp ${_name})
  endif()

  if(NOT _export_set)
    set(_export_set ${_name})
  endif()

  set(_path_vars)

  set(_targets_cmake        "${_export_set}Targets.cmake")
  set(_config_cmake_in      "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_name}Config.cmake.in")
  set(_export_dir           "${CMAKE_CURRENT_BINARY_DIR}")
  set(_export_config_cmake  "${_export_dir}/${_name}Config.cmake")
  set(_install_config_cmake "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_name}Config.cmake")
  set(_config_version_cmake "${CMAKE_CURRENT_BINARY_DIR}/${_name}ConfigVersion.cmake")
  set(_pkg_dest             "share/${_name}/cmake")

  set_property(GLOBAL APPEND PROPERTY ${_name}_PROVIDES ${_targets})


  file(WRITE ${_config_cmake_in}
    "\n"
    "@PACKAGE_INIT@\n"
    "\n"
    "if(NOT COMMAND find_dependency)\n"
    "  include(CMakeFindDependencyMacro)\n"
    "endif()\n"
    "\n"
    "foreach(_dep IN ITEMS @DEPENDENCIES@)\n"
    "  if(_dep MATCHES \"\\\\/[0-9]+(\\\\.[0-9]+)*\")\n"
    "    string(REGEX REPLACE \"(.*)\\\\/[0-9]+(\\\\.[0-9]+)*\" \"\\\\1\" _depname \"\${_dep}\")\n"
    "    string(REGEX REPLACE \".*\\\\/([0-9]+(\\\\.[0-9]+)*)\" \"\\\\1\" _depversion \"\${_dep}\")\n"
    "  else()\n"
    "    set(_depname \${_dep})\n"
    "    set(_depversion)\n"
    "  endif()\n"
    "  find_dependency(\${_depname} \${_depversion})\n"
    "  unset(_depname)\n"
    "  unset(_depversion)\n"
    "endforeach()\n"
    "\n"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/${_targets_cmake}\")\n"
    "\n"
  )

  set(DEPENDENCIES ${_reqs})
  configure_package_config_file(
    ${_config_cmake_in} ${_install_config_cmake}
    INSTALL_DESTINATION ${_pkg_dest}
    PATH_VARS ${_path_vars}
  )

  write_basic_package_version_file(
    ${_config_version_cmake}
    VERSION       ${_version}
    COMPATIBILITY ${_compat}
  )

  set(_export_namespace)
  if(_namespace)
    set(_export_namespace NAMESPACE "${_namespace}::")
  endif()

  install(EXPORT "${_export_set}"
    FILE "${_targets_cmake}"
    ${_export_namespace}
    DESTINATION "${_pkg_dest}"
    COMPONENT   "${_comp}-dev"
  )

  install(FILES ${_install_config_cmake} ${_config_version_cmake}
    DESTINATION ${_pkg_dest}
    COMPONENT   "${_comp}-dev"
  )

  # export build dir
  if(Sloth_EXPORT_BINARY_DIR AND NOT CMAKE_CROSSCOMPILING)
    export(EXPORT "${_export_set}"
      NAMESPACE "${_namespace}::"
      FILE "${CMAKE_CURRENT_BINARY_DIR}/${_targets_cmake}"
    )
    export(PACKAGE "${_name}")

    configure_package_config_file(
      ${_config_cmake_in} ${_export_config_cmake}
      INSTALL_DESTINATION ${_export_dir}
      PATH_VARS ${_path_vars}
    )
  endif()
endfunction()

function(sloth_package)
  sloth_install(${ARGV})
  sloth_export(${ARGV})
endfunction()

