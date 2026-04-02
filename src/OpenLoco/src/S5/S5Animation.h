#pragma once

#include <OpenLoco/Engine/World.hpp>
#include <OpenLoco/Core/Reflection.hpp>
#include <cstdint>

namespace OpenLoco::World
{
    struct Animation;
}

namespace OpenLoco::S5
{
#pragma pack(push, 1)
    struct Animation
    {
        uint8_t baseZ;   // 0x0
        uint8_t type;    // 0x1
        World::Pos2 pos; // 0x2
    };
#pragma pack(pop)
    static_assert(sizeof(Animation) == 0x6);

    S5::Animation exportAnimation(const OpenLoco::World::Animation& src);
    OpenLoco::World::Animation importAnimation(const S5::Animation& src);
}

namespace OpenLoco::Reflection
{
    template<>
    struct Descriptor<S5::Animation>
    {
        static constexpr auto kFields = std::make_tuple(
            &S5::Animation::baseZ, &S5::Animation::type, &S5::Animation::pos);
    };
    static_assert(validateDescriptorSize<S5::Animation>());
}
