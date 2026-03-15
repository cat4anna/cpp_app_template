cmake_minimum_required(VERSION 3.21)

project(cpp_app_template)

if (DEFINED JENKINS_BUILD_NUMBER)
    set(CURRENT_BUILD_NUMBER ${JENKINS_BUILD_NUMBER})
else ()
    set(CURRENT_BUILD_NUMBER 0)
endif()

set(CMAKE_PROJECT_VERSION 0.0.1.${CURRENT_BUILD_NUMBER})
set(CMAKE_PROJECT_DESCRIPTION "An template for making c++ apps")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include("add_all_subdirectories")
include("configuration")
include("compiler_setup")
include("setup_packages")
include("default_targets")
include("packaging")

add_subdirectory(src)
add_subdirectory(test)
