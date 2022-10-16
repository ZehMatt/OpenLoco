
if (WIN32)
    set(public_files "${CMAKE_CURRENT_SOURCE_DIR}/include/OpenLoco/Resources/Resource.h")
    set(private_files "${CMAKE_CURRENT_SOURCE_DIR}/src/OpenLoco.rc")
    loco_add_library(Resources INTERFACE
        PUBLIC_FILES ${public_files}
        PRIVATE_FILES ${private_files})
endif()
