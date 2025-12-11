set(public_files
    "${CMAKE_CURRENT_SOURCE_DIR}/include/OpenLoco/Version.hpp"
)

loco_add_library(Version INTERFACE
    PUBLIC_FILES
        ${public_files}
)

# Set compile definitions on the interface library
target_compile_definitions(Version
    INTERFACE
        ${PROJECT_NAMESPACE}_VERSION_TAG="${${PROJECT_NAMESPACE}_VERSION_TAG}"
        ${PROJECT_NAMESPACE}_BRANCH="${${PROJECT_NAMESPACE}_BRANCH}"
        ${PROJECT_NAMESPACE}_COMMIT_SHA1_SHORT="${${PROJECT_NAMESPACE}_COMMIT_SHA1_SHORT}"
)
