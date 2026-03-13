#!/bin/bash

set -e

SRC_DIR="$(pwd)"
BUILD_DEBUG="$(pwd)/build/${VCPKG_TARGET_TRIPLET}-debug"
BUILD_RELEASE="$(pwd)/build/${VCPKG_TARGET_TRIPLET}-release"

if [[ ! -v BUILD_NUMBER ]]; then
    export BUILD_NUMBER=0
fi

get_path() {
    case "${1}" in
    "rel" | "release")
        echo "${BUILD_RELEASE}"
        ;;
    "debug")
        echo "${BUILD_DEBUG}"
        ;;
    esac
}

clean_ws() {
    rm -rf "$(get_path "${1}")/*"
}

cmake_configure() {
    case "${1}" in
    "rel" | "release")
        TRIPLET_SUFFIX="-release"
        PACKAGE_NAME_SUFFIX="release"
        ;;
    "dbg" | "debug")
        TRIPLET_SUFFIX=""
        PACKAGE_NAME_SUFFIX="debug"
        ;;
    esac

    cmake \
        -G Ninja \
        -D "JENKINS_BUILD_NUMBER=${BUILD_NUMBER}" \
        -D "PACKAGE_BUILD_TYPE=${PACKAGE_NAME_SUFFIX}" \
        -D "VCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}${TRIPLET_SUFFIX}" \
        --toolchain "${CMAKE_TOOLCHAIN_FILE}" \
        -S "${SRC_DIR}" \
        -B "$(get_path "${1}")"
}

cmake_build() {
    cmake --build . --config "${1}"
}

cmake_install() {
    cmake --build . --target install --config "${1}"
}

cmake_test() {
    ctest --build-config "${1}" .
}

cmake_pack() {
    cpack -G ZIP -C "${1}"
}

for action in "$@"; do
    type=$(echo $action | cut -d'-' -f 2 )

    BIN_PATH="$(get_path ${type})"
    mkdir -p "${BIN_PATH}"
    pushd "${BIN_PATH}" >/dev/null

    case $action in
    all-*)
        clean_ws "${type}"
        cmake_configure "${type}"
        cmake_build "${type}"
        cmake_install "${type}"
        cmake_test "${type}"
        cmake_pack "${type}"
        ;;

    clean-*)        clean_ws        "${type}" ;;
    configure-*)    cmake_configure "${type}" ;;
    build-*)        cmake_build     "${type}" ;;
    install-*)      cmake_install   "${type}" ;;
    test-*)         cmake_test      "${type}" ;;
    pack-*)         cmake_pack      "${type}" ;;

    *)
        echo "Unknown command $action"
        exit 1
        ;;
    esac

    popd >/dev/null
done
