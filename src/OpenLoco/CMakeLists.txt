
# To avoid unnecessary rebuilds, set the current branch and short sha1 hash
# only for the one file that uses these definitions: Version.cpp
set_property(SOURCE ${CMAKE_SOURCE_DIR}/Version.cpp
    PROPERTY COMPILE_DEFINITIONS
    OPENLOCO_VERSION_TAG="${OPENLOCO_VERSION_TAG}"
    OPENLOCO_BRANCH="${OPENLOCO_BRANCH}"
    OPENLOCO_COMMIT_SHA1_SHORT="${OPENLOCO_COMMIT_SHA1_SHORT}")

# add source files
file(GLOB_RECURSE OLOCO_SOURCES "src/*.cpp")
file(GLOB_RECURSE OLOCO_HEADERS "src/*.h" "src/*.hpp")

if (APPLE)
    file(GLOB_RECURSE OLOCO_MM_SOURCES "src/*.mm")
    set_source_files_properties(${OLOCO_MM_SOURCES} PROPERTIES COMPILE_FLAGS "-x objective-c++")
endif()

# Disable optimizations for interop.cpp for all compilers, to allow optimized
# builds without need for -fno-omit-frame-pointer
if (MSVC)
    set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/src/Interop/Interop.cpp" PROPERTIES COMPILE_FLAGS "/Oy- /Od")
else ()
    set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/src/Interop/Interop.cpp" PROPERTIES COMPILE_FLAGS "-fno-omit-frame-pointer -O0")
endif ()

if (MINGW)
    loco_add_library(OpenLoco SHARED
        PRIVATE_FILES
            ${OLOCO_SOURCES})
    target_link_libraries(OpenLoco winmm)
else ()
    if (MSVC)
        # Headers added as well so that shown correctly in IDEs
        loco_add_library(OpenLoco SHARED 
            PRIVATE_FILES
                ${OLOCO_SOURCES}
                ${OLOCO_HEADERS})
    else ()
        loco_add_executable(OpenLoco 
            PRIVATE_FILES
                ${OLOCO_SOURCES}
                ${OLOCO_MM_SOURCES})
        add_dependencies(OpenLoco linkable_sections)
        # set_source_files_properties has to be set in the CMakeLists that uses them
        set_source_files_properties(
            ${LOCO_SECTIONS}
            PROPERTIES
            EXTERNAL_OBJECT true
            GENERATED true
        )
        target_sources(OpenLoco
            PRIVATE
                ${LOCO_SECTIONS})
        set_target_properties(OpenLoco PROPERTIES LINK_FLAGS ${LOCO_SEGMENT_LINKER_FLAGS})

        if (TARGET SDL2::SDL2main)
            target_link_libraries(OpenLoco SDL2::SDL2main)
        endif ()
    endif ()
endif ()

target_link_libraries(OpenLoco
    Thirdparty
    ${SDL2_LIB}
    Threads::Threads
    yaml-cpp
    ${PNG_LIBRARY}
    ${OPENAL_LIBRARIES})

if (WIN32)
    target_link_libraries(OpenLoco ${BREAKPAD_LIBRARIES})
    target_link_libraries(OpenLoco winmm ws2_32 Resources)
endif ()

if (NOT WIN32)
    add_dependencies(OpenLoco segfiles)
endif()

if (NOT APPLE AND NOT MSVC)
    target_link_libraries(OpenLoco stdc++fs)
endif()

if (MINGW)
    target_compile_definitions(OpenLoco PRIVATE DEBUG=${DEBUG_LEVEL} _WIN32_WINNT=0x0501 SDL_MAIN_HANDLED=1)
    target_link_libraries(OpenLoco imm32 winmm version)
    # newer GCC gets confused about our use of hardcoded address shenanigans
elseif (MSVC)
    target_compile_definitions(OpenLoco PRIVATE DEBUG=${DEBUG_LEVEL} _WINDLL _MBCS DEBUG_WIN32=1 _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE _USE_MATH_DEFINES SDL_MAIN_HANDLED _WINSOCK_DEPRECATED_NO_WARNINGS USE_BREAKPAD)
else ()
    target_compile_definitions(OpenLoco PRIVATE DEBUG=${DEBUG_LEVEL} _NO_LOCO_WIN32_=1)
endif()

if (APPLE)
    # TODO: This is broken
    target_link_libraries(OpenLoco "-framework Cocoa")

    set_target_properties(OpenLoco PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/distribution/macos/Info.plist.in)

    set(MACOSX_BUNDLE_BUNDLE_NAME "OpenLoco")
    set(MACOSX_BUNDLE_BUNDLE_VERSION "${OPENRCT2_COMMIT_SHA1_SHORT}")
    set(MACOSX_BUNDLE_COPYRIGHT "OpenLoco is licensed under the MIT License")
    set(MACOSX_BUNDLE_GUI_IDENTIFIER "io.openloco.OpenLoco")
    set(MACOSX_BUNDLE_ICON_FILE "AppIcon")

    if(${OPENLOCO_BRANCH} EQUAL master)
        set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${OPENLOCO_VERSION_TAG}")
    else()
        set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${OPENLOCO_VERSION_TAG} ${OPENLOCO_BRANCH}")
    endif()

    set(BUNDLE_RESOURCES "")

    find_program(ICONUTIL iconutil)
    if (ICONUTIL)
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/distribution/macos/AppIcon.iconset DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
        set(ICON_TARGET "${CMAKE_CURRENT_BINARY_DIR}/AppIcon.iconset")
        set(ICON_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/AppIcon.icns")
        set(SOURCE_ICON_DIR "${CMAKE_CURRENT_SOURCE_DIR}/resources/logo")
        add_custom_command(OUTPUT ${ICON_OUTPUT}
                COMMAND cp icon_x16.png ${ICON_TARGET}/icon_16x16.png
                COMMAND cp icon_x32.png ${ICON_TARGET}/icon_16x16@2x.png
                COMMAND cp icon_x32.png ${ICON_TARGET}/icon_32x32.png
                COMMAND cp icon_x64.png ${ICON_TARGET}/icon_32x32@2x.png
                COMMAND cp icon_x128.png ${ICON_TARGET}/icon_128x128.png
                COMMAND cp icon_x256.png ${ICON_TARGET}/icon_128x128@2x.png
                COMMAND cp icon_x256.png ${ICON_TARGET}/icon_256x256.png
                COMMAND cp icon_x512.png ${ICON_TARGET}/icon_256x256@2x.png
                COMMAND cp icon_x512.png ${ICON_TARGET}/icon_512x512.png
                COMMAND cp icon_x1024.png ${ICON_TARGET}/icon_512x512@2x.png
                COMMAND ${ICONUTIL} --convert icns --output ${ICON_OUTPUT} ${ICON_TARGET}
                WORKING_DIRECTORY ${SOURCE_ICON_DIR})
        list(APPEND BUNDLE_RESOURCES ${ICON_OUTPUT})
    endif ()

    list(APPEND BUNDLE_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/CHANGELOG.md)
    list(APPEND BUNDLE_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/CONTRIBUTORS.md)
    set_target_properties(OpenLoco PROPERTIES RESOURCE "${BUNDLE_RESOURCES}")
    target_sources(OpenLoco PUBLIC ${BUNDLE_RESOURCES})

    file(GLOB BUNDLE_LANGUAGES "${CMAKE_CURRENT_SOURCE_DIR}/data/language/*")
    target_sources(OpenLoco PUBLIC ${BUNDLE_LANGUAGES})
    set_property(
        SOURCE ${BUNDLE_LANGUAGES}
        PROPERTY MACOSX_PACKAGE_LOCATION "Resources/language"
    )
endif ()

# Add headers check to verify all headers carry their dependencies.
# Only valid for Clang for now:
# - GCC 8 does not support -Wno-pragma-once-outside-header
# - Other compilers status unknown
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_library(OpenLoco-headers-check OBJECT ${OLOCO_HEADERS})
    set_target_properties(OpenLoco-headers-check PROPERTIES LINKER_LANGUAGE CXX)
    set_source_files_properties(${OLOCO_HEADERS} PROPERTIES LANGUAGE CXX)
    loco_target_compile_link_flags(OpenLoco-headers-check)
    target_compile_options(OpenLoco-headers-check PUBLIC -x c++ -Wno-pragma-once-outside-header -Wno-unused-const-variable)
    target_link_libraries(OpenLoco-headers-check PUBLIC
        ${SDL2_LIB} # These libraries are used in some of our headers try to minimize doing this
        yaml-cpp
        Thirdparty)
else ()
    # Dummy target to ease invocation
    add_custom_target(OpenLoco-headers-check)
endif ()
