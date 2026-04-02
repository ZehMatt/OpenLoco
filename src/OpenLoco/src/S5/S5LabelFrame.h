#pragma once

#include <OpenLoco/Core/Reflection.hpp>
#include <cstdint>

namespace OpenLoco
{
    struct LabelFrame;
}

namespace OpenLoco::S5
{
#pragma pack(push, 1)
    struct LabelFrame
    {
        int16_t left[4]{};
        int16_t right[4]{};
        int16_t top[4]{};
        int16_t bottom[4]{};
    };
    static_assert(sizeof(LabelFrame) == 0x20);
#pragma pack(pop)

    S5::LabelFrame exportLabelFrame(const OpenLoco::LabelFrame& src);
    OpenLoco::LabelFrame importLabelFrame(const S5::LabelFrame& src);
}

namespace OpenLoco::Reflection
{
    template<>
    struct Descriptor<S5::LabelFrame>
    {
        static constexpr auto kFields = std::make_tuple(
            &S5::LabelFrame::left, &S5::LabelFrame::right, &S5::LabelFrame::top, &S5::LabelFrame::bottom);
    };
    static_assert(validateDescriptorSize<S5::LabelFrame>());
}
