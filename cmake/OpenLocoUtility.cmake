function(loco_thirdparty_target_compile_link_flags TARGET)
    # Set some compiler options

    # MSVC
    set(COMMON_COMPILE_OPTIONS_MSVC
        /MP                                 # Multithreaded compilation
        $<$<CONFIG:Debug>:/ZI>              # Debug Edit and Continue (Hot reload)
        $<$<CONFIG:Release>:/Zi>            # Debug information in release
        $<$<CONFIG:Release>:/Oi>            # Intrinsics
        $<$<CONFIG:RelWithDebInfo>:/Oi>     # Intrinsics
        /Zc:char8_t-                        # Enable char8_t<->char conversion :(
        /Zc:__cplusplus                     # Enable correct reporting for __cplusplus
    )

    # GNU/CLANG
    set(COMMON_COMPILE_OPTIONS_GNU
        -fno-char8_t             # Enable char8_t<->char conversion :(
    )

    set(COMMON_COMPILE_OPTIONS
        $<$<CXX_COMPILER_ID:MSVC>:${COMMON_COMPILE_OPTIONS_MSVC}>
        $<$<CXX_COMPILER_ID:GNU>:${COMMON_COMPILE_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:Clang>:${COMMON_COMPILE_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:AppleClang>:${COMMON_COMPILE_OPTIONS_GNU}>
    )

    # Set common link options

    # MSVC
    set(COMMON_LINK_OPTIONS_MSVC
        $<$<CONFIG:Release>:/DEBUG>             # Generate debug symbols even in release
        $<$<CONFIG:Debug>:/INCREMENTAL>         # Incremental linking required for hot reload
        /SAFESEH:NO                             # No safeseh linking required for hot reload and also crashes loading when enabled
        $<$<CONFIG:Release>:/OPT:ICF>           # COMDAT folding
        $<$<CONFIG:Release>:/OPT:REF>           # Eliminate unreferenced code/data
        $<$<CONFIG:RelWithDebInfo>:/OPT:ICF>    # COMDAT folding
        $<$<CONFIG:RelWithDebInfo>:/OPT:REF>    # Eliminate unreferenced code/data
    )

    # GNU/CLANG
    set(COMMON_LINK_OPTIONS_GNU
    )

    set(COMMON_LINK_OPTIONS
        $<$<CXX_COMPILER_ID:MSVC>:${COMMON_LINK_OPTIONS_MSVC}>
        $<$<CXX_COMPILER_ID:GNU>:${COMMON_LINK_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:Clang>:${COMMON_LINK_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:AppleClang>:${COMMON_LINK_OPTIONS_GNU}>
    )

    target_compile_options(${TARGET} PUBLIC ${COMMON_COMPILE_OPTIONS})
    target_link_options(${TARGET} PUBLIC ${COMMON_LINK_OPTIONS})
    target_compile_features(${TARGET} PUBLIC cxx_std_${CMAKE_CXX_STANDARD})
    set_property(TARGET ${TARGET} PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>") # Statically link the MSVC++ Runtime
    set_property(TARGET ${TARGET} PROPERTY POSITION_INDEPENDENT_CODE OFF) # Due to the way the linking works we must have no pie (remove when fully implemented)
endfunction()

function(loco_target_compile_link_flags TARGET)
    # Set some compiler options

    # MSVC
    set(COMMON_COMPILE_OPTIONS_MSVC
        /MP                      # Multithreaded compilation
        $<$<CONFIG:Debug>:/ZI>   # Debug Edit and Continue (Hot reload)
        $<$<CONFIG:Release>:/Zi> # Debug information in release

        $<$<BOOL:${STRICT}>:/WX> # Warnings are errors (STRICT ONLY)
        /W4                      # Warning level 4
                                 # Poke holes in W4 due to our interop code
        /wd4068                  #   4068: unknown pragma
        /wd4200                  #   4200: nonstandard extension used : zero-sized array in struct/union
        /wd4201                  #   4201: nonstandard extension used : nameless struct/union
        /wd4244                  #   4244: 'argument' : conversion from 'type1' to 'type2', possible loss of data
        /Zc:char8_t-             # Enable char8_t<->char conversion :(
        /utf-8
    )

    # GNU/CLANG
    set(COMMON_COMPILE_OPTIONS_GNU
        -fstrict-aliasing
        -Wall
        -Wextra
        -Wtype-limits
        $<$<BOOL:${STRICT}>:-Werror>         # Warnings are errors (STRICT ONLY)

        # Poke some holes in -Wall:
        -Wno-unknown-pragmas
        -Wno-unused-private-field
        -Waddress
        # -Warray-bounds
        # compilers often get confused about our memory access patterns, disable some of the warnings
        -Wno-array-bounds
        $<$<CXX_COMPILER_ID:GNU>:-Wno-stringop-overflow> # clang does not understand following options and errors with -Wunknown-warning-option
        $<$<CXX_COMPILER_ID:GNU>:-Wno-stringop-overread>
        $<$<CXX_COMPILER_ID:GNU>:-Wno-stringop-truncation>
        -Wchar-subscripts
        -Wenum-compare
        -Wformat
        -Wignored-qualifiers
        -Winit-self
        -Wmissing-declarations
        -Wnon-virtual-dtor
        -Wnull-dereference
        -Wstrict-aliasing
        -Wstrict-overflow=1
        -Wundef
        -Wunreachable-code
        -fno-char8_t             # Enable char8_t<->char conversion :(
        -Wno-deprecated-declarations
    )

    set(COMMON_COMPILE_OPTIONS
        $<$<CXX_COMPILER_ID:MSVC>:${COMMON_COMPILE_OPTIONS_MSVC}>
        $<$<CXX_COMPILER_ID:GNU>:${COMMON_COMPILE_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:Clang>:${COMMON_COMPILE_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:AppleClang>:${COMMON_COMPILE_OPTIONS_GNU}>
    )

    # Set common link options

    # MSVC
    set(COMMON_LINK_OPTIONS_MSVC
        $<$<CONFIG:Release>:/DEBUG>         # Generate debug symbols even in release
        $<$<CONFIG:Debug>:/INCREMENTAL>     # Incremental linking required for hot reload
        $<$<CONFIG:Debug>:/SAFESEH:NO>      # No safeseh linking required for hot reload
    )

    # GNU/CLANG
    set(COMMON_LINK_OPTIONS_GNU
    )

    set(COMMON_LINK_OPTIONS
        $<$<CXX_COMPILER_ID:MSVC>:${COMMON_LINK_OPTIONS_MSVC}>
        $<$<CXX_COMPILER_ID:GNU>:${COMMON_LINK_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:Clang>:${COMMON_LINK_OPTIONS_GNU}>
        $<$<CXX_COMPILER_ID:AppleClang>:${COMMON_LINK_OPTIONS_GNU}>
    )

    target_compile_options(${TARGET} PUBLIC ${COMMON_COMPILE_OPTIONS})
    target_link_options(${TARGET} PUBLIC ${COMMON_LINK_OPTIONS})
    target_compile_features(${TARGET} PUBLIC cxx_std_${CMAKE_CXX_STANDARD})
    set_property(TARGET ${TARGET} PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>") # Statically link the MSVC++ Runtime
    set_property(TARGET ${TARGET} PROPERTY POSITION_INDEPENDENT_CODE OFF) # Due to the way the linking works we must have no pie (remove when fully implemented)
endfunction()

function(_loco_add_target TARGET TYPE)
    cmake_parse_arguments("" "LIBRARY;EXECUTABLE;INTERFACE" "" "PRIVATE_FILES;PUBLIC_FILES;TEST_FILES;" ${ARGN})

    if (${TYPE} STREQUAL "INTERFACE")
        set(_LIBRARY NO)
        set(_INTERFACE YES)
    endif()
    # Add public files to target so that source_group works
    # (nice IDE layout)
    if (_LIBRARY)
        add_library(${TARGET} ${TYPE} 
            ${_PRIVATE_FILES}
            ${_PUBLIC_FILES})
        add_library(OpenLoco::${TARGET} ALIAS ${TARGET})

        # We need to include both include and src as src may have private headers
        # Note: Generator expresions for this were not working!
        if (DEFINED _PUBLIC_FILES)
            target_include_directories(${TARGET}
                PUBLIC
                    "${CMAKE_CURRENT_SOURCE_DIR}/include")
        endif()
        if (DEFINED _PRIVATE_FILES)
            target_include_directories(${TARGET}
                PRIVATE
                    "${CMAKE_CURRENT_SOURCE_DIR}/src")
        endif()

        # TODO Maybe pass an additional Component variable to the function instead of repeat TARGET
        if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include/OpenLoco/${TARGET}")
            target_include_directories(${TARGET}
                PRIVATE
                    "${CMAKE_CURRENT_SOURCE_DIR}/include/OpenLoco/${TARGET}")
        endif()
        loco_target_compile_link_flags(${TARGET})
        set_property(TARGET ${TARGET} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    elseif(_EXECUTABLE)
        add_executable(${TARGET}
            ${_PRIVATE_FILES}
            ${_PUBLIC_FILES})
        add_executable(OpenLoco::${TARGET} ALIAS ${TARGET})

        target_include_directories(${TARGET}
            PRIVATE
                ${CMAKE_CURRENT_SOURCE_DIR}/src)

        loco_target_compile_link_flags(${TARGET})
        set_property(TARGET ${TARGET} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    elseif(_INTERFACE)
        # We want to add the headers to the interface library so that it displays
        # nicely wihtin IDEs
        add_library(${TARGET} ${TYPE}
            ${_PUBLIC_FILES})
        add_library(OpenLoco::${TARGET} ALIAS ${TARGET})

        target_include_directories(${TARGET}
            INTERFACE
                "${CMAKE_CURRENT_SOURCE_DIR}/include")
    endif()

    # Defer header check to after configure time
    # This ensures all target properties and dependencies are fully set up
    if (OPENLOCO_HEADER_CHECK)
        cmake_language(EVAL CODE "cmake_language(DEFER CALL _loco_add_headers_check \"${TARGET}\")")
    endif()

    # Group the files nicely in IDEs into a tree view
    if (_PUBLIC_FILES)
        source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/include" PREFIX "include" FILES ${_PUBLIC_FILES})
    endif()
    if (_PRIVATE_FILES)
        source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/src" PREFIX "src" FILES ${_PRIVATE_FILES})
    endif()
    if (_TEST_FILES AND ${OPENLOCO_BUILD_TESTS})
        # Tests will be under the libraryNameTests.exe
        set(TEST_TARGET ${TARGET}Tests)
        add_executable(${TEST_TARGET} ${_TEST_FILES})
        add_executable(OpenLoco::${TEST_TARGET} ALIAS ${TEST_TARGET})

        target_link_libraries(${TEST_TARGET}
            $<$<BOOL:${_LIBRARY}>:${TARGET}>
            GTest::gtest_main)

        include(GoogleTest)

        gtest_discover_tests(${TEST_TARGET})

        # Now that we have tests group the two targets as one in IDEs
        set_target_properties(${TARGET} ${TEST_TARGET} PROPERTIES FOLDER ${TARGET})
        # Group files nicely in IDEs
        source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/tests" PREFIX "tests" FILES ${_TEST_FILES})
        
        # Tell each target about the project directory.
        target_compile_definitions(${TEST_TARGET} PRIVATE OPENLOCO_PROJECT_PATH="${OPENLOCO_PROJECT_PATH}")

        loco_target_compile_link_flags(${TEST_TARGET})
    endif()
    
    # Tell each target about the project directory.
    target_compile_definitions(${TARGET} PRIVATE OPENLOCO_PROJECT_PATH="${OPENLOCO_PROJECT_PATH}")
endfunction()

function(loco_add_library TARGET TYPE)
    _loco_add_target(${TARGET} ${TYPE} ${ARGN} LIBRARY)
endfunction()

function(loco_add_executable TARGET)
    _loco_add_target(${TARGET} NULL ${ARGN} EXECUTABLE)
endfunction()

function(_loco_add_headers_check TARGET)
    # Create the global target first, even if we return early
    if (NOT TARGET all-headers-check)
        add_custom_target(all-headers-check)
    endif()
    
    if (NOT OPENLOCO_HEADER_CHECK)
        return()
    endif()
    
    # Check if target exists
    if (NOT TARGET ${TARGET})
        message(WARNING "_loco_add_headers_check: Target '${TARGET}' does not exist")
        return()
    endif()
    
    # Only valid for Clang for now:
    # - GCC 8 does not support -Wno-pragma-once-outside-header
    # - Other compilers status unknown
    if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        message(STATUS "Header check for ${TARGET} skipped (only supported with Clang)")
        return()
    endif()

    # Get all sources from the target
    get_target_property(TARGET_SOURCES ${TARGET} SOURCES)
    if (NOT TARGET_SOURCES OR TARGET_SOURCES STREQUAL "TARGET_SOURCES-NOTFOUND")
        message(WARNING "_loco_add_headers_check: No sources found for target ${TARGET}")
        return()
    endif()
    
    # Get public include directories to distinguish public vs private headers
    get_target_property(TARGET_INCLUDE_DIRS ${TARGET} INCLUDE_DIRECTORIES)
    if (TARGET_INCLUDE_DIRS STREQUAL "TARGET_INCLUDE_DIRS-NOTFOUND")
        set(TARGET_INCLUDE_DIRS)
    endif()
    
    get_target_property(TARGET_INTERFACE_INCLUDE_DIRS ${TARGET} INTERFACE_INCLUDE_DIRECTORIES)
    if (TARGET_INTERFACE_INCLUDE_DIRS STREQUAL "TARGET_INTERFACE_INCLUDE_DIRS-NOTFOUND")
        set(TARGET_INTERFACE_INCLUDE_DIRS)
    endif()
    
    set(PUBLIC_INCLUDE_DIRS)
    if (TARGET_INTERFACE_INCLUDE_DIRS)
        list(APPEND PUBLIC_INCLUDE_DIRS ${TARGET_INTERFACE_INCLUDE_DIRS})
    endif()
    
    # Filter to only header files (.h, .hpp, .hxx) and separate public from private
    set(PUBLIC_HEADER_FILES)
    set(PRIVATE_HEADER_FILES)
    
    foreach(source_file ${TARGET_SOURCES})
        if (source_file MATCHES "\\.(h|hpp|hxx)$")
            get_filename_component(header_abs ${source_file} ABSOLUTE)
            
            # Check if header is in a public include directory
            set(IS_PUBLIC_HEADER NO)
            foreach(public_dir ${PUBLIC_INCLUDE_DIRS})
                file(RELATIVE_PATH rel_path ${public_dir} ${header_abs})
                # If relative path doesn't start with "..", it's under the public directory
                if (NOT rel_path MATCHES "^\\.\\.")
                    set(IS_PUBLIC_HEADER YES)
                    break()
                endif()
            endforeach()
            
            if (IS_PUBLIC_HEADER)
                list(APPEND PUBLIC_HEADER_FILES ${header_abs})
            else()
                list(APPEND PRIVATE_HEADER_FILES ${header_abs})
            endif()
        endif()
    endforeach()

    list(LENGTH PUBLIC_HEADER_FILES PUBLIC_HEADER_COUNT)
    list(LENGTH PRIVATE_HEADER_FILES PRIVATE_HEADER_COUNT)
    
    if (PUBLIC_HEADER_COUNT EQUAL 0 AND PRIVATE_HEADER_COUNT EQUAL 0)
        message(STATUS "Header check for ${TARGET} skipped (no header files found)")
        return()
    endif()
    
    message(STATUS "Header check for ${TARGET}: ${PUBLIC_HEADER_COUNT} public, ${PRIVATE_HEADER_COUNT} private headers")

    set(WRAPPER_DIR "${CMAKE_BINARY_DIR}/header-check/${TARGET}")
    file(MAKE_DIRECTORY ${WRAPPER_DIR})
    
    # Create public headers check target
    if (PUBLIC_HEADER_COUNT GREATER 0)
        set(PUBLIC_WRAPPER_FILES)
        set(PUBLIC_WRAPPER_DIR "${WRAPPER_DIR}/public")
        file(MAKE_DIRECTORY ${PUBLIC_WRAPPER_DIR})
        
        foreach(header_file ${PUBLIC_HEADER_FILES})
            # Find which public include directory this header belongs to
            set(rel_path)
            foreach(public_dir ${PUBLIC_INCLUDE_DIRS})
                file(RELATIVE_PATH temp_rel_path ${public_dir} ${header_file})
                if (NOT temp_rel_path MATCHES "^\\.\\.")
                    set(rel_path ${temp_rel_path})
                    break()
                endif()
            endforeach()
            
            # Fallback to just filename if we couldn't determine relative path
            if (NOT rel_path)
                get_filename_component(rel_path ${header_file} NAME)
            endif()
            
            # Replace extension with .cpp
            string(REGEX REPLACE "\\.[^.]*$" ".cpp" wrapper_rel_path ${rel_path})
            set(wrapper_file "${PUBLIC_WRAPPER_DIR}/${wrapper_rel_path}")
            
            # Create subdirectories if needed
            get_filename_component(wrapper_dir ${wrapper_file} DIRECTORY)
            file(MAKE_DIRECTORY ${wrapper_dir})
            
            file(WRITE ${wrapper_file} "#include \"${header_file}\"\n")
            list(APPEND PUBLIC_WRAPPER_FILES ${wrapper_file})
        endforeach()

        set(PUBLIC_HEADER_CHECK_TARGET ${TARGET}-public-headers-check)
        add_library(${PUBLIC_HEADER_CHECK_TARGET} OBJECT ${PUBLIC_WRAPPER_FILES})
        set_target_properties(${PUBLIC_HEADER_CHECK_TARGET} PROPERTIES LINKER_LANGUAGE CXX)
        
        if (TARGET_INTERFACE_INCLUDE_DIRS)
            target_include_directories(${PUBLIC_HEADER_CHECK_TARGET} PUBLIC ${TARGET_INTERFACE_INCLUDE_DIRS})
        endif()
        
        get_target_property(TARGET_INTERFACE_LINK_LIBS ${TARGET} INTERFACE_LINK_LIBRARIES)
        if (TARGET_INTERFACE_LINK_LIBS AND NOT TARGET_INTERFACE_LINK_LIBS STREQUAL "TARGET_INTERFACE_LINK_LIBS-NOTFOUND")
            target_link_libraries(${PUBLIC_HEADER_CHECK_TARGET} PUBLIC ${TARGET_INTERFACE_LINK_LIBS})
        endif()
        
        add_dependencies(all-headers-check ${PUBLIC_HEADER_CHECK_TARGET})
    endif()
    
    # Create private headers check target
    if (PRIVATE_HEADER_COUNT GREATER 0)
        set(PRIVATE_WRAPPER_FILES)
        set(PRIVATE_WRAPPER_DIR "${WRAPPER_DIR}/private")
        file(MAKE_DIRECTORY ${PRIVATE_WRAPPER_DIR})
        
        foreach(header_file ${PRIVATE_HEADER_FILES})
            # Find which private include directory this header belongs to
            set(rel_path)
            foreach(private_dir ${TARGET_INCLUDE_DIRS})
                file(RELATIVE_PATH temp_rel_path ${private_dir} ${header_file})
                if (NOT temp_rel_path MATCHES "^\\.\\.")
                    set(rel_path ${temp_rel_path})
                    break()
                endif()
            endforeach()
            
            # Fallback to just filename if we couldn't determine relative path
            if (NOT rel_path)
                get_filename_component(rel_path ${header_file} NAME)
            endif()
            
            # Replace extension with .cpp
            string(REGEX REPLACE "\\.[^.]*$" ".cpp" wrapper_rel_path ${rel_path})
            set(wrapper_file "${PRIVATE_WRAPPER_DIR}/${wrapper_rel_path}")
            
            # Create subdirectories if needed
            get_filename_component(wrapper_dir ${wrapper_file} DIRECTORY)
            file(MAKE_DIRECTORY ${wrapper_dir})
            
            file(WRITE ${wrapper_file} "#include \"${header_file}\"\n")
            list(APPEND PRIVATE_WRAPPER_FILES ${wrapper_file})
        endforeach()

        set(PRIVATE_HEADER_CHECK_TARGET ${TARGET}-private-headers-check)
        add_library(${PRIVATE_HEADER_CHECK_TARGET} OBJECT ${PRIVATE_WRAPPER_FILES})
        set_target_properties(${PRIVATE_HEADER_CHECK_TARGET} PROPERTIES LINKER_LANGUAGE CXX)
        
        if (TARGET_INCLUDE_DIRS)
            target_include_directories(${PRIVATE_HEADER_CHECK_TARGET} PUBLIC ${TARGET_INCLUDE_DIRS})
        endif()
        if (TARGET_INTERFACE_INCLUDE_DIRS)
            target_include_directories(${PRIVATE_HEADER_CHECK_TARGET} PUBLIC ${TARGET_INTERFACE_INCLUDE_DIRS})
        endif()
        
        get_target_property(TARGET_LINK_LIBS ${TARGET} LINK_LIBRARIES)
        if (TARGET_LINK_LIBS AND NOT TARGET_LINK_LIBS STREQUAL "TARGET_LINK_LIBS-NOTFOUND")
            target_link_libraries(${PRIVATE_HEADER_CHECK_TARGET} PUBLIC ${TARGET_LINK_LIBS})
        endif()
        
        get_target_property(TARGET_INTERFACE_LINK_LIBS ${TARGET} INTERFACE_LINK_LIBRARIES)
        if (TARGET_INTERFACE_LINK_LIBS AND NOT TARGET_INTERFACE_LINK_LIBS STREQUAL "TARGET_INTERFACE_LINK_LIBS-NOTFOUND")
            target_link_libraries(${PRIVATE_HEADER_CHECK_TARGET} PUBLIC ${TARGET_INTERFACE_LINK_LIBS})
        endif()
        
        add_dependencies(all-headers-check ${PRIVATE_HEADER_CHECK_TARGET})
    endif()
endfunction()
