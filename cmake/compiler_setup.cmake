
set(TARGET_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/output/${CMAKE_BUILD_TYPE}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${TARGET_DESTINATION})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${TARGET_DESTINATION})
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install")
message(STATUS "Target destination: " ${TARGET_DESTINATION})

set(TEST_RESULT_DIR ${CMAKE_CURRENT_BINARY_DIR}/Testing)
file(MAKE_DIRECTORY ${TEST_RESULT_DIR})

enable_testing()

if(WIN32)
    set(APP_INSTALL_CONFIG
        RUNTIME_DEPENDENCIES
        PRE_EXCLUDE_REGEXES "api-ms-" "ext-ms-"
        POST_EXCLUDE_REGEXES ".*system32/.*\\.dll"
    )
else()
    # set(APP_INSTALL_CONFIG)
endif()

if(MSVC)
  add_compile_options(/external:anglebrackets /external:W0 /W4 /diagnostics:caret) # /WX
  add_compile_options(/wd4100) # unreferenced formal parameter
  add_compile_options(/wd4275) # non dll-interface class
else()
  add_compile_options(-Wall -Wextra -pedantic) # -Werror
  add_compile_options(-Wno-unused-parameter)
  add_compile_options(-Wno-missing-field-initializers)
  add_compile_options(-Wno-gnu-zero-variadic-macro-arguments)
endif()

if(WIN32)
  add_definitions(-DWINDOWS)
elseif(LINUX)
  add_definitions(-DLINUX)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  message(STATUS "Enabling debug features")
  add_definitions(-DDEBUG)
endif()

find_program(clang_tidy_executable NAMES clang-tidy)
if(MSVC OR NOT clang_tidy_executable)
  message(STATUS "Disabling clang-tidy")
  set(CLANG_TIDY_COMMAND "")
else()
  message(STATUS "Using clang-tidy ${clang_tidy_executable}")
  set(CLANG_TIDY_COMMAND
      ${clang_tidy_executable} -header-filter=${CMAKE_CURRENT_SOURCE_DIR}/.*
      --warnings-as-errors=*
      -checks=modernize*,diagnostic*,cppcoreguidelines*,readability*,clang-analyzer*,bugprone*,performance*,-diagnostic-missing-field-initializers,-modernize-use-trailing-return-type,-readability-magic-numbers,-cppcoreguidelines-avoid-magic-numbers,-readability-uppercase-literal-suffix,-modernize-use-nodiscard,-modernize-pass-by-value,-readability-convert-member-functions-to-static,-readability-qualified-auto,-performance-unnecessary-value-param,-performance-unnecessary-value-param,-cppcoreguidelines-non-private-member-variables-in-classes,-readability-else-after-return,-cppcoreguidelines-special-member-functions,-cppcoreguidelines-pro-type-member-init,-cppcoreguidelines-pro-type-member-init,-bugprone-reserved-identifier,-modernize-use-equals-default,-readability-named-parameter,-cppcoreguidelines-macro-usage,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-modernize-use-nullptr,-clang-diagnostic-unused-private-field,-cppcoreguidelines-pro-type-reinterpret-cast,-cppcoreguidelines-pro-type-const-cast,-readability-use-anyofallof,-cppcoreguidelines-pro-type-vararg
  )
endif()

function(enable_clang_tidy TARGET_NAME)
  set_target_properties(${TARGET_NAME} PROPERTIES CXX_CLANG_TIDY "${CLANG_TIDY_COMMAND}")
endfunction()

function(disable_clang_tidy TARGET_NAME)
  set_target_properties(${TARGET_NAME} PROPERTIES CXX_CLANG_TIDY "")
endfunction()
