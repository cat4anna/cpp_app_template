#!/bin/bash

set -e

SRC_DIR="$(pwd)"
BUILD_DEBUG="$(pwd)/build/debug"
BUILD_RELEASE="$(pwd)/build/release"

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
    BIN_PATH="$(get_path $1)"
    mkdir -p "${BIN_PATH}"
    pushd "${BIN_PATH}" >/dev/null
    cmake --toolchain "${CMAKE_TOOLCHAIN_FILE}" -S "${SRC_DIR}" -B "${BIN_PATH}"
    popd >/dev/null
    #  -D CMAKE_BUILD_TYPE=$1
}

cmake_build() {
    pushd "$(get_path $1)" >/dev/null
    cmake --build . --config $1
    popd >/dev/null
}

cmake_test() {
    pushd "$(get_path $1)" >/dev/null
    ctest --build-config $1 .
    popd >/dev/null
}

cmake_pack() {
    pushd "$(get_path $1)" >/dev/null
    cpack -G ZIP -C $1
    popd >/dev/null
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
    "pack-rel")
        cmake_pack "rel"
        ;;
    *)
        echo "Unknown command $action"
        exit 1
        ;;
    esac
done

#  --target ALL_BUILD

# "CMAKE_TOOLCHAIN_FILE": "D:/Programowanie/external/vcpkg/scripts/buildsystems/vcpkg.cmake",
# "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"

#  h:/Projects/cpp_app_template/build -j 24 --