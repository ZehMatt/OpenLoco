#pragma once

#include "Config.h"
#include "Input.h"
#include <SDL2/SDL.h>
#include <yaml-cpp/yaml.h>

#define enum_def(x, y) \
    {                  \
        x::y, #y       \
    }

namespace YAML
{
    using namespace OpenLoco::Config;
    using namespace OpenLoco::Input;

    template<typename T>
    using convert_pair_vector = std::vector<std::pair<T, const char*>>;

    template<typename T>
    struct convert_enum_base
    {
        static Node encode(const T& rhs)
        {
            for (const auto& e : convert<T>::getEntries())
            {
                if (rhs == e.first)
                {
                    return Node(e.second);
                }
            }
            return Node();
        }

        static bool decode(const Node& node, T& rhs)
        {
            if (node.IsScalar())
            {
                auto sz = node.Scalar();
                for (const auto& e : convert<T>::getEntries())
                {
                    if (e.second == sz)
                    {
                        rhs = e.first;
                        return true;
                    }
                }
            }
            return false;
        }
    };

    // Keyboard shortcuts
    template<>
    struct convert<KeyboardShortcut>
    {
        static constexpr char kDelimiter = '+';

        static Node encode(const KeyboardShortcut& rhs)
        {
            std::string keyName = "";
            if (rhs.keyCode == 0xFFFFFFFF)
                return Node(keyName);

            if (rhs.modifiers & KeyModifier::shift)
            {
                keyName += SDL_GetKeyName(SDLK_LSHIFT);
                keyName += kDelimiter;
            }
            if (rhs.modifiers & KeyModifier::control)
            {
                keyName += SDL_GetKeyName(SDLK_LCTRL);
                keyName += kDelimiter;
            }
            if (rhs.modifiers & KeyModifier::unknown)
            {
                keyName += SDL_GetKeyName(SDLK_LGUI);
                keyName += kDelimiter;
            }

            keyName += SDL_GetKeyName(rhs.keyCode);
            return Node(keyName);
        }

        static bool decode(const Node& node, KeyboardShortcut& rhs)
        {
            auto s = node.as<std::string>();
            if (s.empty())
            {
                rhs.keyCode = 0xFFFFFFFF;
                rhs.modifiers = 0xFF;
                return true;
            }

            rhs.modifiers = 0;
            std::size_t current = 0;
            std::size_t pos = s.find_first_of(kDelimiter, 0);
            std::string token = s;

            while (pos != std::string::npos)
            {
                token = s.substr(current, pos);
                current = pos + 1;
                pos = s.find_first_of(kDelimiter, current);

                SDL_Keycode keyCode = SDL_GetKeyFromName(token.c_str());

                // Check against known modifiers
                if (keyCode == SDLK_LSHIFT || keyCode == SDLK_RSHIFT)
                    rhs.modifiers |= KeyModifier::shift;
                else if (keyCode == SDLK_LCTRL || keyCode == SDLK_RCTRL)
                    rhs.modifiers |= KeyModifier::control;
                else if (keyCode == SDLK_LGUI || keyCode == SDLK_RGUI)
                    rhs.modifiers |= KeyModifier::unknown;
            }

            token = s.substr(current);
            SDL_Keycode keyCode = SDL_GetKeyFromName(token.c_str());
            rhs.keyCode = keyCode;

            return true;
        }
    };

    // Resolution
    template<>
    struct convert<Resolution>
    {
        static Node encode(const Resolution& rhs)
        {
            Node node;
            node["width"] = rhs.width;
            node["height"] = rhs.height;
            return node;
        }

        static bool decode(const Node& node, Resolution& rhs)
        {
            if (node.IsMap())
            {
                rhs.width = node["width"].as<int32_t>();
                rhs.height = node["height"].as<int32_t>();
                return true;
            }
            return false;
        }
    };

    // ScreenMode
    const convert_pair_vector<ScreenMode> screenModeEntries = {
        enum_def(ScreenMode, window),
        enum_def(ScreenMode, fullscreen),
        enum_def(ScreenMode, fullscreenBorderless),
    };
    template<>
    struct convert<ScreenMode> : convert_enum_base<ScreenMode>
    {
        static const convert_pair_vector<ScreenMode>& getEntries() { return screenModeEntries; }
    };
}

#undef enum_def
