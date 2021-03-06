#
# SlothConfigure.cmake
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

if(_SLOTH_CONFIGURE_CMAKE_INCLUDED)
  return()
endif()
set(_SLOTH_CONFIGURE_CMAKE_INCLUDED 1)

function(sloth_configure _input _ouput)
  foreach(_kv IN LISTS ARGN)
    if(_k)
      set(${_k} ${_kv})
      unset(_k)
    else()
      set(_k ${_kv})
    endif()
  endforeach()

  configure_file(${_input} ${_ouput} @ONLY)

endfunction()
