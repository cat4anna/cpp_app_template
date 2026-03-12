#!/bin/bash

set -e

# docker build -t tpl:latest -f .\ci\dockerfile.test .

BUILD_DEBUG="build/debug"
BUILD_RELEASE="build/release"

get_path() {
    case $1 in
    "rel")
        echo "${BUILD_RELEASE}"
        ;;
    "debug")
        echo "${BUILD_DEBUG}"
        ;;
    esac
}

cmake_configure() {
    mkdir -p "$(get_path $1)"
    pushd "$(get_path $1)"
    cmake --toolchain "${CMAKE_TOOLCHAIN_FILE}" -S "${SOURCE_DIR}" -B "$(get_path $1)"
    popd
    #  -D CMAKE_BUILD_TYPE=$1
}

cmake_build() {
    pushd "$(get_path $1)"
    cmake --build . --config $1
    popd
}

cmake_test() {
    pushd "$(get_path $1)"
    ctest --build-config $1 .
    popd
}

cmake_pack() {
    pushd "$(get_path $1)"
    cpack -G ZIP -C $1
    popd
}

for action in "$@"; do
    case $action in
    "clean-debug")
        rm -rf "${BUILD_DEBUG}/*"
        ;;
    "clean-rel")
        rm -rf "${BUILD_RELEASE}/*"
        ;;
    "configure-debug")
        cmake_configure "debug"
        ;;
    "configure-rel")
        cmake_configure "rel"
        ;;
    "build-debug")
        cmake_build "debug"
        ;;
    "build-rel")
        cmake_build "rel"
        ;;

    "test-debug")
        cmake_test "debug"
        ;;
    "test-rel")
        cmake_test "rel"
        ;;

    "pack-debug")
        cmake_pack "debug"
        ;;
    "pack-release")
        cmake_pack "rel"
        ;;
    esac
done


    #  --target ALL_BUILD

# "CMAKE_TOOLCHAIN_FILE": "D:/Programowanie/external/vcpkg/scripts/buildsystems/vcpkg.cmake",
# "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"

#  h:/Projects/cpp_app_template/build -j 24 --