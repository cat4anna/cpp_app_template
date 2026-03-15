set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
SET(CPACK_VERBATIM_VARIABLES TRUE)
SET(CPACK_GENERATOR ZIP)

set(CPACK_COMPONENTS_GROUPING "IGNORE")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY ON)
set(CPACK_COMPONENT_INCLUDE_TOPLEVEL_DIRECTORY ON)

SET(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${VCPKG_TARGET_TRIPLET}")
set(CPACK_OUTPUT_FILE_PREFIX "${ARTIFACTS_DESTINATION}")
set(CPACK_COMPONENTS_ALL main)

if(APP_DO_UNIT_TEST OR APP_DO_BENCHMARK)
    set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} test "test-result")
    install(
        DIRECTORY ${TESTS_DESTINATION}
        EXCLUDE_FROM_ALL
        COMPONENT "test-result"
        DESTINATION "."
        )
endif()

include(CPack)
include(CPackComponent)

cpack_add_component(executables
    DISPLAY_NAME "Main Application"
    DESCRIPTION "The core executables (Required)"
    REQUIRED
)

if(APP_DO_UNIT_TEST OR APP_DO_BENCHMARK)
    cpack_add_component(test
        DISPLAY_NAME "Test executables"
        DESCRIPTION "The test executables"
    )

    cpack_add_component(test
        DISPLAY_NAME "Test results"
        DESCRIPTION "The test results"
    )
endif()
