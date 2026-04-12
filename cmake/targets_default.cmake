add_custom_target(build_all_libs ALL)
add_custom_target(build_all_executables ALL)

if(APP_DO_UNIT_TEST)
    message(STATUS "Enabling tests")
else()
    message(STATUS "Disabling tests")
endif()

if(APP_DO_BENCHMARK)
    message(STATUS "Enabling benchmarks")
else()
    message(STATUS "Disabling benchmarks")
endif()

if(APP_DO_UNIT_TEST OR APP_DO_BENCHMARK)
    enable_testing()

    add_custom_target(build_all_tests ALL)
    add_custom_target(execute_all_tests)

    make_directory(${TESTS_DESTINATION})
endif()

function(define_static_lib)
    set(options UNIT_TEST BENCHMARK)
    set(oneValueArgs NAME)
    set(multiValueArgs PLATFORMS LINKS INCLUDES)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}"
    )
    set(target_name ${arg_NAME})

    if ((${APP_TARGET_PLATFORM} IN_LIST arg_PLATFORMS) OR ("${arg_PLATFORMS}" STREQUAL ""))
        message(STATUS "Adding executable ${target_name}")
        set(TARGET_ENABLED ON PARENT_SCOPE)
    else()
        message(STATUS "Skipping executable ${target_name} - not for current platform")
        set(TARGET ${target_name} PARENT_SCOPE)
        set(TARGET_ENABLED OFF PARENT_SCOPE)
        return()
    endif()

    file(GLOB_RECURSE SRC src/*.cpp src/*.hpp include/*.hpp)

    message(STATUS "Adding static lib ${target_name}")
    add_library(${target_name} STATIC ${SRC})
    target_include_directories(${target_name} PUBLIC include)
    target_include_directories(${target_name} PRIVATE src)
    add_dependencies(build_all_libs ${target_name})
    target_link_libraries(${target_name} PUBLIC ${arg_LINKS})
    target_include_directories(${target_name} PUBLIC ${arg_INCLUDES})
    setup_clang_tidy(${target_name})

    set(TARGET ${target_name} PARENT_SCOPE)
    set(LIB_TARGET ${target_name} PARENT_SCOPE)

    if(${target_name} STREQUAL ${APP_UT_RUNNER_TARGET})
        target_link_libraries(${target_name} PRIVATE ${APP_UT_LIBS})
    endif()
    if(${target_name} STREQUAL ${APP_BENCHMARK_RUNNER_TARGET})
        target_link_libraries(${target_name} PRIVATE ${APP_BENCHMARK_LIBS})
    endif()

    if (APP_DO_UNIT_TEST AND arg_UNIT_TEST)
        define_ut_target(${target_name} test)
    endif()
    if (APP_DO_BENCHMARK AND arg_BENCHMARK)
        define_benchmark_target(${target_name} test)
    endif()
endfunction()

function(define_executable)
    set(options)
    set(oneValueArgs NAME)
    set(multiValueArgs PLATFORMS LINKS INCLUDES)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}"
    )
    set(target_name ${arg_NAME})

    if ((${APP_TARGET_PLATFORM} IN_LIST arg_PLATFORMS) OR ("${arg_PLATFORMS}" STREQUAL ""))
        message(STATUS "Adding executable ${target_name}")
        set(TARGET_ENABLED ON PARENT_SCOPE)
    else()
        message(STATUS "Skipping executable ${target_name} - not for current platform")
        set(TARGET ${target_name} PARENT_SCOPE)
        set(TARGET_ENABLED OFF PARENT_SCOPE)
        return()
    endif()

    file(GLOB_RECURSE SRC src/*.cpp src/*.hpp include/*.hpp)
    add_executable(${target_name} ${SRC})
    target_include_directories(${target_name} PUBLIC include)
    target_include_directories(${target_name} PRIVATE src)
    target_link_libraries(${target_name} PUBLIC ${arg_LINKS})
    target_include_directories(${target_name} PUBLIC ${arg_INCLUDES})

    add_dependencies(build_all_executables ${target_name})
    setup_clang_tidy(${target_name})

    install(
        TARGETS ${target_name}
        COMPONENT main
        DESTINATION "."
        ${APP_INSTALL_CONFIG}
        )

    if(EMSCRIPTEN)
        install(
            FILES
                $<TARGET_FILE_DIR:${target_name}>/${target_name}.wasm
                $<TARGET_FILE_DIR:${target_name}>/${target_name}.js
            COMPONENT main
            DESTINATION "."
            ${APP_INSTALL_CONFIG}
            )
    endif()

    set(TARGET ${target_name} PARENT_SCOPE)
endfunction()
