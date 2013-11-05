#
# Sloth.cmake - The main include file for the Sloth CMake library.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

if(_SLOTH_CMAKE_INCLUDED)
  return()
endif()
set(_SLOTH_CMAKE_INCLUDED 1)

include(FeatureSummary)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

set(SLOTH_RESOUCES_DIR "${CMAKE_CURRENT_LIST_DIR}/../Resources")

include("${CMAKE_CURRENT_LIST_DIR}/SlothTools.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothConfigure.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothRemote.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothDoxygen.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothDump.cmake")

function(sloth_finalize)
  if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(_cflagslst)
    set(_cxxflagslst)
    if(CMAKE_C_FLAGS)
      string(REPLACE " " ";" _cflags "${CMAKE_C_FLAGS}")
      list(APPEND _cflagslst ${_cflags})
    endif()
    if(CMAKE_CXX_FLAGS)
      string(REPLACE " " ";" _cxxflags "${CMAKE_CXX_FLAGS}")
      list(APPEND _cxxflagslst ${_cxxflags})
    endif()
    if(CMAKE_BUILD_TYPE)
      string(TOUPPER ${CMAKE_BUILD_TYPE} _buildtype)
      if(CMAKE_C_FLAGS_${_buildtype})
        string(REPLACE " " ";" _cflags "${CMAKE_C_FLAGS_${_buildtype}}")
        list(APPEND _cflagslst ${_cflags})
      endif()
      if(CMAKE_CXX_FLAGS_${_buildtype})
        string(REPLACE " " ";" _cxxflags "${CMAKE_CXX_FLAGS_${_buildtype}}")
        list(APPEND _cxxflagslst ${_cxxflags})
      endif()
    endif()
    get_directory_property(_gcflags COMPILE_OPTIONS)
    if(_gcflags)
      list(APPEND _cflagslst ${_gcflags})
      list(APPEND _cxxflagslst ${_gcflags})
    endif()
    get_directory_property(_gdefs   COMPILE_DEFINITIONS)
    foreach(_def IN LISTS _gdefs)
      list(APPEND _cflagslst -D${_def})
      list(APPEND _cxxflagslst -D${_def})
    endforeach()

    set(_info "Build Summary:\n")
    if(NOT CMAKE_HOST_SYSTEM STREQUAL CMAKE_SYSTEM)
      set(_info "${_info} * Host system:          ${CMAKE_HOST_SYSTEM}\n")
    endif()
    set(_info "${_info} * System:               ${CMAKE_SYSTEM}\n")
    if(CMAKE_CROSSCOMPILING)
      set(_info "${_info} * Crosscompiling:       ${CMAKE_CROSSCOMPILING}\n")
    endif()
    set(_info "${_info}\n")
    if(CMAKE_BUILD_TYPE)
      set(_info "${_info} * Build type:           ${CMAKE_BUILD_TYPE}\n")
      set(_info "${_info}\n")
    endif()
    set(_info "${_info} * C compiler:           ${CMAKE_C_COMPILER}\n")
    if(_cflags)
      set(_info "${_info} * C compiler options:\n")
      foreach(_flag IN LISTS _cflagslst)
        set(_info "${_info}   - ${_flag}\n")
      endforeach()
    endif()
    set(_info "${_info}\n")
    set(_info "${_info} * C++ compiler:         ${CMAKE_CXX_COMPILER}\n")
    if(_cflags)
      set(_info "${_info} * C++ compiler options:\n")
      foreach(_flag IN LISTS _cxxflagslst)
        set(_info "${_info}   - ${_flag}\n")
      endforeach()
    endif()
    message(STATUS ${_info})
    feature_summary(INCLUDE_QUIET_PACKAGES WHAT ALL)
  endif()
endfunction()

