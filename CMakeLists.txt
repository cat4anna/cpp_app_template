cmake_minimum_required(VERSION 3.16)

project(cpp_app_template)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include("add_all_subdirectories")
include("configuration")
include("compiler_setup")
include("setup_packages")
include("default_targets")

add_subdirectory(src)
add_subdirectory(test)

# if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
#     set(CPACK_PACKAGE_VERSION "MyApp-dbg")
# else()
#     set(CPACK_PACKAGE_VERSION "MyApp")
# endif()
set(CPACK_PACKAGE_VERSION_MAJOR 1)
set(CPACK_PACKAGE_VERSION_MINOR 0)
set(CPACK_PACKAGE_VERSION_PATCH 0)
# set(CPACK_PACKAGE_VERSION "asdf")
# set(CPACK_PACKAGE_BUILD_TYPE ${CMAKE_BUILD_TYPE})
# set(CPACK_INSTALL_SCRIPT DoSomething.cmake)

# set(CPACK_PACKAGE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/distribution/${CMAKE_BUILD_TYPE}/")

#     set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-dbg")
# else()
#     # set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-")
# endif()

# SET(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION}-${CMAKE_BUILD_TYPE}")

include(CPack)
