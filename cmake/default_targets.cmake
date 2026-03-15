
# set(TEST_RESULT_DIR ${CMAKE_CURRENT_BINARY_DIR}/Testing)
# file(MAKE_DIRECTORY ${TEST_RESULT_DIR})

add_custom_target(build_all_libs ALL)

if(APP_DO_UNIT_TEST)
    message(STATUS "Enabling tests")
    enable_testing()
    add_custom_target(build_all_test ALL)
    add_custom_target(execute_all_test)
else()
    message(STATUS "Disabling tests")
endif()

# add_custom_target(build_all_benchmark ALL)
add_custom_target(build_all_executables ALL)

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
        target_link_libraries(${target_name} PUBLIC ${APP_UT_LIBS})
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

function(define_ut_target target_name ut_name)
    if(NOT APP_DO_UNIT_TEST)
        return()
    endif()

    file(GLOB src_ut ${ut_name}/*)

    string(REGEX REPLACE "test(.*)" "\\1" short_ut_name ${ut_name})
    string(REPLACE "/" "_" valid_ut_name "${short_ut_name}")

    set(target_ut_name "${target_name}${valid_ut_name}_ut")
    message(STATUS "Adding UTs ${target_ut_name} for ${target_name}")

    add_executable(${target_ut_name} ${src_ut})
    target_include_directories(${target_ut_name} PRIVATE src test)
    target_link_libraries(${target_ut_name} PUBLIC ${target_name} ${APP_UT_LIBS} ${APP_UT_RUNNER_TARGET})

    add_custom_target(
        run_${target_ut_name}
        COMMAND ${target_ut_name} --gtest_shuffle
        WORKING_DIRECTORY ${TARGET_DESTINATION}
        COMMENT "Running test ${target_ut_name}"
        DEPENDS ${target_ut_name} ${target_name}
        )

    add_test(
        NAME test_${target_ut_name}
        COMMAND ${target_ut_name} --gtest_shuffle --gtest_output=xml:${TEST_RESULT_DIR}/${target_ut_name}.xml
        WORKING_DIRECTORY ${TARGET_DESTINATION}
        )

    set_property(
        TARGET run_${target_ut_name}
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES ${TEST_RESULT_DIR}/${target_ut_name}.xml
        )

    install(
        TARGETS ${target_ut_name}
        # EXCLUDE_FROM_ALL
        COMPONENT test
        DESTINATION test
        ${APP_INSTALL_CONFIG}
        )

    add_dependencies(execute_all_test run_${target_ut_name})
    add_dependencies(build_all_test ${target_ut_name})
endfunction()

function(define_ut_multi_target target_name ut_name)
    if(NOT APP_DO_UNIT_TEST)
        return()
    endif()

    file(
        GLOB src_ut
        LIST_DIRECTORIES true
        ${ut_name}/*
        )

    set(srclist "")

    foreach(child ${src_ut})
        file(RELATIVE_PATH rel_child ${CMAKE_CURRENT_SOURCE_DIR} ${child})
        if(IS_DIRECTORY ${child})
        define_ut_target(${target_name} ${rel_child})
        else()
        list(APPEND srclist ${rel_child})
        endif()
    endforeach()
    if(srclist)
        define_ut_target(${target_name} ${ut_name})
    endif()
endfunction()

function(define_static_lib_with_ut target_name)
    define_static_lib(${target_name})
    define_ut_multi_target(${target_name} test)
    set(TARGET ${target_name} PARENT_SCOPE)
endfunction()

# target_link_libraries(${TARGET} PRIVATE benchmark::benchmark)
# define_static_lib_with_ut_and_benchmark(app_shared)
