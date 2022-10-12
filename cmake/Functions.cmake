
function(_loco_add_target TARGET TYPE)
    cmake_parse_arguments("" "LIBRARY;EXECUTABLE;" "" "PRIVATE_FILES;PUBLIC_FILES;TEST_FILES;" ${ARGN})

    # Add public files to target so that source_group works
    # (nice IDE layout)
    if (_LIBRARY)
        add_library(${TARGET} ${TYPE} 
            ${_PRIVATE_FILES}
            ${_PUBLIC_FILES})
        # We need to include both include and src as src may have private headers
        target_include_directories(${TARGET}
            PUBLIC 
                "${CMAKE_CURRENT_SOURCE_DIR}/include"
            PRIVATE
                $<$<BOOL:${_PRIVATE_FILES}>:${CMAKE_CURRENT_SOURCE_DIR}/src>)
    else()
        add_executable(${TARGET}
            ${_PRIVATE_FILES}
            ${_PUBLIC_FILES})
        target_include_directories(${TARGET}
            PRIVATE
                ${CMAKE_CURRENT_SOURCE_DIR}/src)
    endif()
    target_compile_features(${TARGET} PUBLIC cxx_std_17)
    
    # Group the files nicely in IDEs into a tree view
    source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/include" PREFIX "include" FILES ${_PUBLIC_FILES})
    source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/src" PREFIX "src" FILES ${_PRIVATE_FILES})

    if (_TEST_FILES)
        enable_testing()

        # Tests will be under the libraryNameTests.exe
        set(TEST_TARGET ${TARGET}Tests)
        add_executable(${TEST_TARGET} ${_TEST_FILES})

        target_link_libraries(${TEST_TARGET}
            $<$<BOOL:${_LIBRARY}>:${TARGET}>
            GTest::gtest_main)

        include(GoogleTest)

        gtest_discover_tests(${TEST_TARGET})

        # Now that we have tests group the two targets as one in IDEs
        set_target_properties(${TARGET} ${TEST_TARGET} PROPERTIES FOLDER ${TARGET})
        # Group files nicely in IDEs
        source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/tests" PREFIX "tests" FILES ${_TEST_FILES})
    endif()
endfunction()

function(loco_add_library TARGET TYPE)
    _loco_add_target(${TARGET} ${TYPE} ${ARGN} LIBRARY)
endfunction()

function(loco_add_executable TARGET)
    _loco_add_target(${TARGET} NULL ${ARGN} EXECUTABLE)
endfunction() 

