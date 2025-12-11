include(FindGit)

find_package(Git)
if (Git_FOUND)
    # Describe current version in terms of closest tag
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe HEAD --always
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE ${PROJECT_NAMESPACE}_VERSION_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
        # ERROR_QUIET
    )

    if (${PROJECT_NAMESPACE}_VERSION_TAG)
        # Use a platform agnostic sed equivalent to strip the commit hash from the version tag
        # i.e. "v22.10-9-g8ff1d207" becomes "v22.10-9 "
        string(REGEX REPLACE "-g.+$" " " ${PROJECT_NAMESPACE}_VERSION_TAG ${${PROJECT_NAMESPACE}_VERSION_TAG})
        # Has to be in two bits due to empty string not being possible to pass to REGEX REPLACE
        string(STRIP ${${PROJECT_NAMESPACE}_VERSION_TAG} ${PROJECT_NAMESPACE}_VERSION_TAG)
    else()
        # If a low fetch depth is used then nearest tag for git will fail
        # so just use the project version in that case.
        set(${PROJECT_NAMESPACE}_VERSION_TAG ${PROJECT_VERSION})
    endif()
    
    # Define current git branch
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE ${PROJECT_NAMESPACE}_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    # Define short commit hash
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE ${PROJECT_NAMESPACE}_COMMIT_SHA1_SHORT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    
    message(STATUS "Version: ${${PROJECT_NAMESPACE}_VERSION_TAG} | Branch: ${${PROJECT_NAMESPACE}_BRANCH} | Commit: ${${PROJECT_NAMESPACE}_COMMIT_SHA1_SHORT}")
    
    # Propagate version variables to parent scope for use in other CMakeLists.txt files
    set(${PROJECT_NAMESPACE}_VERSION_TAG "${${PROJECT_NAMESPACE}_VERSION_TAG}")
    set(${PROJECT_NAMESPACE}_BRANCH "${${PROJECT_NAMESPACE}_BRANCH}")
    set(${PROJECT_NAMESPACE}_COMMIT_SHA1_SHORT "${${PROJECT_NAMESPACE}_COMMIT_SHA1_SHORT}")
else()
    message(WARNING "Git not found, version information will be limited.")

    set(${PROJECT_NAMESPACE}_VERSION_TAG "unknown")
    set(${PROJECT_NAMESPACE}_BRANCH "unknown")
    set(${PROJECT_NAMESPACE}_COMMIT_SHA1_SHORT "unknown")
endif()
