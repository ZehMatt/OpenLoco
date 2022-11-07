set(public_files 
    "${CMAKE_CURRENT_SOURCE_DIR}/include/ThirdParty/Stdx/filesystem.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/ThirdParty/Stdx/span.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/ThirdParty/Stdx/variant.hpp"
)

loco_add_library(ThirdPartyStdx INTERFACE 
    PUBLIC_FILES ${public_files}
)
