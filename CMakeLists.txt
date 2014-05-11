#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(Sloth NONE)

set(Sloth_VERSION_MAJOR 0)
set(Sloth_VERSION_MINOR 3)
set(Sloth_VERSION_PATCH 1)
set(Sloth_VERSION "${Sloth_VERSION_MAJOR}.${Sloth_VERSION_MINOR}.${Sloth_VERSION_PATCH}")
set(Sloth_VERSION_STRING "${Sloth_VERSION}")

set(_src
  src/Sloth.cmake
  src/SlothAddTarget.cmake
  src/SlothConfigure.cmake
  src/SlothDoxygen.cmake
  src/SlothDump.cmake
  src/SlothPackage.cmake
  src/SlothTools.cmake
)

set_property(DIRECTORY APPEND PROPERTY
  CMAKE_CONFIGURE_DEPENDS ${_src}
)

set(PACKAGE_SCRIPT "")
foreach(_file IN LISTS _src)
  file(READ "${_file}" _content)
  set(PACKAGE_SCRIPT "${PACKAGE_SCRIPT}\n${_content}")
endforeach()

set(_config_cmake_in      "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in")
set(_export_dir           "${CMAKE_CURRENT_BINARY_DIR}")
set(_export_config_cmake  "${_export_dir}/${PROJECT_NAME}Config.cmake")
set(_install_config_cmake "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}Config.cmake")
set(_config_version_cmake "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")

set(_pkg_dest "share/${PROJECT_NAME}/cmake")

include(CMakePackageConfigHelpers)

configure_package_config_file(
  "${_config_cmake_in}"
  "${_install_config_cmake}"
  INSTALL_DESTINATION "${_pkg_dest}"
  NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

write_basic_package_version_file(
  "${_config_version_cmake}"
  VERSION "${Sloth_VERSION}"
  COMPATIBILITY AnyNewerVersion
)

install(FILES "${_install_config_cmake}" "${_config_version_cmake}"
  DESTINATION "${_pkg_dest}"
)

configure_package_config_file(
  "${_config_cmake_in}"
  "${_export_config_cmake}"
  INSTALL_DESTINATION "${_export_dir}"
  NO_CHECK_REQUIRED_COMPONENTS_MACRO
)
export(PACKAGE ${PROJECT_NAME})


if(NOT CPACK_GENERATOR)
  set(CPACK_GENERATOR "TGZ;ZIP")
endif()
set(CPACK_PACKAGE_NAME          ${PROJECT_NAME})
set(CPACK_PACKAGE_VERSION_MAJOR ${Sloth_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${Sloth_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${Sloth_VERSION_PATCH})
set(CPACK_PACKAGE_FILE_NAME     "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
include(CPack)

