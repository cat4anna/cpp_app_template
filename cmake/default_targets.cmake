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

function(define_static_lib target_name)
    file(GLOB_RECURSE SRC src/*.cpp src/*.hpp include/*.hpp)

    message(STATUS "Adding static lib ${target_name}")
    add_library(${target_name} STATIC ${SRC})
    target_include_directories(${target_name} PUBLIC include)
    target_include_directories(${target_name} PRIVATE src)
    add_dependencies(build_all_libs ${target_name})
    setup_clang_tidy(${target_name})

    set(TARGET ${target_name} PARENT_SCOPE )
    set(LIB_TARGET ${target_name} PARENT_SCOPE)

    if(${target_name} STREQUAL ${APP_UT_RUNNER_TARGET})
        target_link_libraries(${target_name} PRIVATE ${APP_UT_LIBS})
    endif()
    if(${target_name} STREQUAL ${APP_BENCHMARK_RUNNER_TARGET})
        target_link_libraries(${target_name} PRIVATE ${APP_BENCHMARK_LIBS})
    endif()
endfunction()

function(define_executable target_name )
    file(GLOB_RECURSE SRC src/*.cpp src/*.hpp include/*.hpp)

    message(STATUS "Adding executable ${target_name}")
    add_executable(${target_name} ${SRC})
    target_include_directories(${target_name} PUBLIC include)
    target_include_directories(${target_name} PRIVATE src)
    target_link_libraries(${target_name} PUBLIC Boost::program_options)

    add_dependencies(build_all_executables ${target_name})
    setup_clang_tidy(${target_name})

    install(
        TARGETS ${target_name}
        COMPONENT main
        DESTINATION "."
        ${APP_INSTALL_CONFIG}
        )

    set(TARGET ${target_name} PARENT_SCOPE)
endfunction()

function(define_static_lib_with_ut target_name)
    define_static_lib(${target_name})
    define_ut_multi_target(${target_name} test)
    set(TARGET ${target_name} PARENT_SCOPE)
endfunction()

function(define_static_lib_with_ut_and_benchmark target_name)
    define_static_lib(${target_name})
    define_ut_multi_target(${target_name} test)
    define_benchmark_multi_target(${target_name} test)
    set(TARGET ${target_name} PARENT_SCOPE)
endfunction()

function(define_static_lib_with_benchmark target_name)
    define_static_lib(${target_name})
    define_benchmark_multi_target(${target_name} test)
    set(TARGET ${target_name} PARENT_SCOPE)
endfunction()
