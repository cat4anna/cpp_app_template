cmake_minimum_required(VERSION 3.21)

project(cpp_app_template)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include("add_all_subdirectories")
include("configuration")
include("compiler_setup")
include("setup_packages")
include("sub_targets")
include("default_targets")
include("packaging")

add_subdirectory(src)
add_subdirectory(test)
