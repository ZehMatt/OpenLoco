#pragma once

#include <cstddef>
#include <string_view>
#include <tuple>
#include <type_traits>
#include <utility>

namespace OpenLoco::Reflection
{
    namespace Detail
    {
        consteval bool isIdentChar(char c)
        {
            return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_';
        }

        template<auto MemberPtr>
        consteval std::string_view extractMemberName()
        {
#if defined(_MSC_VER) && !defined(__clang__)
            std::string_view s = __FUNCSIG__;
#else
            std::string_view s = __PRETTY_FUNCTION__;
#endif
            size_t end = s.size();
            for (size_t i = s.size(); i > 0; --i)
            {
                if (s[i - 1] == '>' || s[i - 1] == ']')
                {
                    end = i - 1;
                    break;
                }
            }
            size_t nameEnd = end;
            while (nameEnd > 0 && !isIdentChar(s[nameEnd - 1]))
            {
                nameEnd--;
            }
            size_t nameStart = nameEnd;
            while (nameStart > 0 && isIdentChar(s[nameStart - 1]))
            {
                nameStart--;
            }
            return s.substr(nameStart, nameEnd - nameStart);
        }
    }

    // Struct descriptor: specialize for each type you want to reflect.
    //
    //   template<>
    //   struct Descriptor<MyStruct>
    //   {
    //       static constexpr auto kFields = std::make_tuple(
    //           &MyStruct::field1,
    //           &MyStruct::field2);
    //   };
    //
    template<typename T>
    struct Descriptor;

    template<typename T, typename = void>
    inline constexpr bool kDescribable = false;

    template<typename T>
    inline constexpr bool kDescribable<T, std::void_t<decltype(Descriptor<T>::kFields)>> = true;

    template<typename T>
    consteval size_t fieldCount()
    {
        return std::tuple_size_v<std::remove_cvref_t<decltype(Descriptor<T>::kFields)>>;
    }

    template<typename T, typename F>
    void forEachFieldPair(const T& a, const T& b, F&& fn)
    {
        constexpr auto& kFields = Descriptor<T>::kFields;
        [&]<size_t... Is>(std::index_sequence<Is...>) {
            (fn(a.*std::get<Is>(kFields),
                b.*std::get<Is>(kFields),
                Detail::extractMemberName<std::get<Is>(kFields)>()),
             ...);
        }(std::make_index_sequence<std::tuple_size_v<std::remove_cvref_t<decltype(kFields)>>>{});
    }

    template<typename T, typename F>
    void forEachField(const T& obj, F&& fn)
    {
        constexpr auto& kFields = Descriptor<T>::kFields;
        [&]<size_t... Is>(std::index_sequence<Is...>) {
            (fn(obj.*std::get<Is>(kFields),
                Detail::extractMemberName<std::get<Is>(kFields)>()),
             ...);
        }(std::make_index_sequence<std::tuple_size_v<std::remove_cvref_t<decltype(kFields)>>>{});
    }

    // Validates descriptor covers all bytes of a packed struct.
    template<typename T>
    consteval bool validateDescriptorSize()
    {
        constexpr auto& kFields = Descriptor<T>::kFields;
        size_t total = 0;
        [&]<size_t... Is>(std::index_sequence<Is...>) {
            ((total += sizeof(std::remove_reference_t<decltype(std::declval<T&>().*std::get<Is>(kFields))>)), ...);
        }(std::make_index_sequence<std::tuple_size_v<std::remove_cvref_t<decltype(kFields)>>>{});
        return total == sizeof(T);
    }
}
