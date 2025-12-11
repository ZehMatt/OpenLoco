if (WIN32)
    set(${PROJECT_NAMESPACE}_USE_VCPKG_DEFAULT YES)
else()
    set(${PROJECT_NAMESPACE}_USE_VCPKG_DEFAULT NO)
endif()
option(${PROJECT_NAMESPACE}_USE_VCPKG "Use vcpkg for dependencies and toolchain" ${${PROJECT_NAMESPACE}_USE_VCPKG_DEFAULT})

# On windows VCPKG is used to get all dependencies other platforms can use it as well by setting ${PROJECT_NAMESPACE}_USE_VCPKG
if (${PROJECT_NAMESPACE}_USE_VCPKG)
    if (EXISTS ${VCPKG_ROOT})
        set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
            CACHE STRING "CMake toolchain file")
    else()
        # Provide a message for first time invocations
        if (NOT CMAKE_TOOLCHAIN_FILE)
            message("VCPKG not installed, fetching and building VCPKG. Warning may take a while on slow connections.")
        endif ()
        FetchContent_Declare(vcpkg
            GIT_REPOSITORY https://github.com/microsoft/vcpkg.git
            GIT_TAG 89dc8be6dbcf18482a5a1bf86a2f4615c939b0fb)
        FetchContent_MakeAvailable(vcpkg)

        set(CMAKE_TOOLCHAIN_FILE "${vcpkg_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake"
            CACHE STRING "CMake toolchain file")
    endif()
endif ()
