
# -------------------------------- UNIT TESTS --------------------------------

function(define_ut_target target_name ut_name)
    if(NOT APP_DO_UNIT_TEST)
        return()
    endif()

    file(GLOB_RECURSE src_ut ${ut_name}/*_test*)

    string(REGEX REPLACE "test(.*)" "\\1" short_ut_name ${ut_name})
    string(REPLACE "/" "_" valid_ut_name "${short_ut_name}")

    set(target_ut_name "${target_name}${valid_ut_name}_ut")
    message(STATUS "Adding UTs ${target_ut_name} for ${target_name}")

    add_executable(${target_ut_name} ${src_ut})
    target_include_directories(${target_ut_name} PRIVATE src test)
    target_link_libraries(${target_ut_name} PRIVATE ${target_name} ${APP_UT_LIBS} ${APP_UT_RUNNER_TARGET})

    set(ut_result_file ${TESTS_DESTINATION}/${target_ut_name}.${APP_UT_OUTPUT_FORMAT})
    if(EMSCRIPTEN)
        set(ut_executable $<TARGET_FILE_DIR:${target_ut_name}>/${target_ut_name}.js)
    else()
        set(ut_executable ${target_ut_name})
        set(APP_UT_RUN_ARGS ${APP_UT_RUN_ARGS} --gtest_output=${APP_UT_OUTPUT_FORMAT}:${ut_result_file})
    endif()

    add_custom_target(
        run_${target_ut_name}
        COMMAND ${CMAKE_TEST_LAUNCHER} ${ut_executable} ${APP_UT_RUN_ARGS}
        WORKING_DIRECTORY ${TARGET_DESTINATION}
        COMMENT "Running test ${target_ut_name}"
        DEPENDS ${target_ut_name} ${target_name}
        )

    add_test(
        NAME test_${target_ut_name}
        COMMAND ${CMAKE_TEST_LAUNCHER} ${ut_executable} ${APP_UT_RUN_ARGS}
        WORKING_DIRECTORY ${TARGET_DESTINATION}
        )

    set_property(
        TARGET run_${target_ut_name}
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES ${ut_result_file}
        )

    install(
        TARGETS ${target_ut_name}
        EXCLUDE_FROM_ALL
        COMPONENT test
        DESTINATION test
        ${APP_INSTALL_CONFIG}
        )

    if(EMSCRIPTEN)
        install(
            FILES
                $<TARGET_FILE_DIR:${target_ut_name}>/${target_ut_name}.wasm
                $<TARGET_FILE_DIR:${target_ut_name}>/${target_ut_name}.js
            EXCLUDE_FROM_ALL
            COMPONENT test
            DESTINATION test
            ${APP_INSTALL_CONFIG}
            )
    endif()

    add_dependencies(execute_all_tests run_${target_ut_name})
    add_dependencies(build_all_tests ${target_ut_name})
endfunction()

function(define_ut_multi_target target_name ut_name)
    if(NOT APP_DO_UNIT_TEST)
        return()
    endif()

    file(GLOB_RECURSE src_ut LIST_DIRECTORIES true ${ut_name}/*_test*)
    set(src_list "")

    foreach(child ${src_ut})
        file(RELATIVE_PATH rel_child ${CMAKE_CURRENT_SOURCE_DIR} ${child})
        if(IS_DIRECTORY ${child})
            define_ut_target(${target_name} ${rel_child})
        else()
            list(APPEND src_list ${rel_child})
        endif()
    endforeach()
    if(src_list)
        define_ut_target(${target_name} ${ut_name})
    endif()
endfunction()

# -------------------------------- BENCHMARKS --------------------------------

function(define_benchmark_target target_name benchmark_name)
    if(NOT APP_DO_BENCHMARK)
        return()
    endif()

    file(GLOB_RECURSE src_benchmark ${benchmark_name}/*_benchmark*)

    string(REGEX REPLACE "test(.*)" "\\1" short_benchmark_name ${benchmark_name})
    string(REPLACE "/" "_" valid_benchmark_name "${short_benchmark_name}")

    set(target_benchmark_name "${target_name}${valid_benchmark_name}_benchmark")
    message(STATUS "Adding benchmarks ${target_benchmark_name} for ${target_name}")

    add_executable(${target_benchmark_name} ${src_benchmark})
    target_include_directories(${target_benchmark_name} PRIVATE src test)
    target_link_libraries(${target_benchmark_name} PRIVATE ${target_name} ${APP_BENCHMARK_LIBS} ${APP_BENCHMARK_RUNNER_TARGET})

    SET(benchmark_result_file ${TESTS_DESTINATION}/${target_benchmark_name}.${APP_BENCHMARK_OUTPUT_FORMAT})

    if(EMSCRIPTEN)
        set(benchmark_executable ${CMAKE_TEST_LAUNCHER} $<TARGET_FILE_DIR:${target_benchmark_name}>/${target_benchmark_name}.js)
    else()
        set(benchmark_executable ${target_benchmark_name})
        set(APP_BENCHMARK_RUN_ARGS ${APP_BENCHMARK_RUN_ARGS} --benchmark_out=${benchmark_result_file} --benchmark_out_format=${APP_BENCHMARK_OUTPUT_FORMAT})
    endif()

    add_custom_target(
        run_${target_benchmark_name}
        COMMAND ${benchmark_executable} ${APP_BENCHMARK_RUN_ARGS}
        WORKING_DIRECTORY ${TARGET_DESTINATION}
        COMMENT "Running benchmark ${target_benchmark_name}"
        DEPENDS ${target_benchmark_name} ${target_name}
        )

    add_test(
        NAME benchmark_${target_benchmark_name}
        COMMAND ${benchmark_executable} ${APP_BENCHMARK_RUN_ARGS}
        WORKING_DIRECTORY ${TARGET_DESTINATION}
        )

    set_property(
        TARGET run_${target_benchmark_name}
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES ${benchmark_result_file}
        )

    install(
        TARGETS ${target_benchmark_name}
        EXCLUDE_FROM_ALL
        COMPONENT test
        DESTINATION test
        ${APP_INSTALL_CONFIG}
        )

    if(EMSCRIPTEN)
        install(
            FILES
                $<TARGET_FILE_DIR:${target_benchmark_name}>/${target_benchmark_name}.wasm
                $<TARGET_FILE_DIR:${target_benchmark_name}>/${target_benchmark_name}.js
            EXCLUDE_FROM_ALL
            COMPONENT test
            DESTINATION test
            ${APP_INSTALL_CONFIG}
            )
    endif()

    add_dependencies(execute_all_tests run_${target_benchmark_name})
    add_dependencies(build_all_tests ${target_benchmark_name})
endfunction()

function(define_benchmark_multi_target target_name benchmark_name)
    if(NOT APP_DO_BENCHMARK)
        return()
    endif()

    file(GLOB_RECURSE src_benchmark LIST_DIRECTORIES true ${benchmark_name}/*_benchmark*)
    set(src_list "")

    foreach(child ${src_benchmark})
        file(RELATIVE_PATH rel_child ${CMAKE_CURRENT_SOURCE_DIR} ${child})
        if(IS_DIRECTORY ${child})
            define_benchmark_target(${target_name} ${rel_child})
        else()
            list(APPEND src_list ${rel_child})
        endif()
    endforeach()
    if(src_list)
        define_benchmark_target(${target_name} ${benchmark_name})
    endif()
endfunction()
