cmake_minimum_required(VERSION 3.21)

project(
    cpp_app_template
    DESCRIPTION "An template for making c++ apps"
    )

if (NOT DEFINED JENKINS_BUILD_NUMBER)
    set(JENKINS_BUILD_NUMBER 0)
endif()

set(CMAKE_PROJECT_VERSION 0.0.1.${JENKINS_BUILD_NUMBER})

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include("add_all_subdirectories")
include("configuration")
include("compiler_setup")
include("setup_packages")
include("default_targets")
include("packaging")

add_subdirectory(src)
add_subdirectory(test)
