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

include(FeatureSummary)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

set(SLOTH_RESOUCES_DIR "${CMAKE_CURRENT_LIST_DIR}/../Resources")

include("${CMAKE_CURRENT_LIST_DIR}/SlothTools.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothConfigure.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothImport.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothRemote.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothDoxygen.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/SlothDump.cmake")

function(sloth_finalize)
  if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    feature_summary(INCLUDE_QUIET_PACKAGES WHAT ALL)
  endif()
endfunction()
