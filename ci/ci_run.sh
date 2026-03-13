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
    "rel" | "release" | "RelWithDebInfo")
        echo "${BUILD_RELEASE}"
        ;;
    "debug" | "Debug")
        echo "${BUILD_DEBUG}"
        ;;
    esac
}

get_config() {
    case "${1}" in
    *-rel | *-release)
        echo "RelWithDebInfo"
        ;;
    *-debug)
        echo "debug"
        ;;
    esac
}

clean_ws() {
    popd >/dev/null
    BIN_PATH="$(get_path ${config})"
    rm -rf "${BIN_PATH}"
    mkdir -p "${BIN_PATH}"
    pushd "${BIN_PATH}" >/dev/null
}

cmake_configure() {
    case "${1}" in
    "rel" | "release" |  "RelWithDebInfo")
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
        -D "CMAKE_BUILD_TYPE=${1}" \
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
    config=$(get_config $action)

    BIN_PATH="$(get_path ${config})"
    mkdir -p "${BIN_PATH}"
    pushd "${BIN_PATH}" >/dev/null

    case $action in
    all-*)
        clean_ws "${config}"
        cmake_configure "${config}"
        cmake_build "${config}"
        cmake_test "${config}"
        cmake_install "${config}"
        cmake_pack "${config}"
        ;;

    clean-*)        clean_ws        "${config}" ;;
    configure-*)    cmake_configure "${config}" ;;
    build-*)        cmake_build     "${config}" ;;
    install-*)      cmake_install   "${config}" ;;
    test-*)         cmake_test      "${config}" ;;
    pack-*)         cmake_pack      "${config}" ;;

    *)
        echo "Unknown command $action"
        exit 1
        ;;
    esac

    popd >/dev/null
done
