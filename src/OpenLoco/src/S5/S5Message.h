#pragma once

#include <cstdint>
#include <OpenLoco/Core/Reflection.hpp>

namespace OpenLoco
{
    struct Message;
}

namespace OpenLoco::S5
{
#pragma pack(push, 1)
    struct Message
    {
        uint8_t type;             // 0x00
        char messageString[198];  // 0x01
        uint8_t companyId;        // 0xC7
        uint16_t timeActive;      // 0xC8 (1 << 15) implies manually opened news 0xFFFF implies no longer active
        uint16_t itemSubjects[3]; // 0xCA
        uint32_t date;            // 0xD0
    };
    static_assert(sizeof(Message) == 0xD4);
#pragma pack(pop)

    S5::Message exportMessage(const OpenLoco::Message& src);
    OpenLoco::Message importMessage(const S5::Message& src);
}

namespace OpenLoco::Reflection
{
    template<>
    struct Descriptor<S5::Message>
    {
        static constexpr auto kFields = std::make_tuple(
            &S5::Message::type, &S5::Message::messageString, &S5::Message::companyId,
            &S5::Message::timeActive, &S5::Message::itemSubjects, &S5::Message::date);
    };
    static_assert(validateDescriptorSize<S5::Message>());
}
