
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMAND ON)


# cmake_policy(SET CMP0167 NEW)

if(DEFINED JENKINS_BUILD_NUMBER)
    set(CURRENT_BUILD_NUMBER ${JENKINS_BUILD_NUMBER})
else ()
    set(CURRENT_BUILD_NUMBER 0)
endif()

set(CMAKE_PROJECT_VERSION 0.0.1.${CURRENT_BUILD_NUMBER})
set(CMAKE_PROJECT_DESCRIPTION "An template for making c++ apps")

if(DEFINED JENKINS_BUILD_NUMBER)
    # enable clang-tidy only when running through ci scripts
    set(APP_DO_CLANG_TIDY ON)
else()
    set(APP_DO_CLANG_TIDY OFF)
endif()
set(APP_CLANG_TIDY_WARNINGS_AS_ERRORS OFF)

set(APP_DO_UNIT_TEST ON)
set(APP_UT_RUNNER_TARGET runner_ut)
set(APP_UT_LIBS GTest::gmock GTest::gtest)
set(APP_UT_RUN_ARGS "--gtest_shuffle")
set(APP_UT_OUTPUT_FORMAT "xml")

set(APP_DO_BENCHMARK ON)
set(APP_BENCHMARK_RUNNER_TARGET runner_benchmark)
set(APP_BENCHMARK_LIBS benchmark::benchmark)
SET(APP_BENCHMARK_RUN_ARGS "--benchmark_enable_random_interleaving=true")
set(APP_BENCHMARK_OUTPUT_FORMAT "json")
