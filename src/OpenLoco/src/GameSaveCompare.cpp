#include "GameSaveCompare.h"

#include <string>
#include <type_traits>

#include "GameState.h"
#include "Logging.h"
#include "OpenLoco.h"
#include "S5/S5.h"
#include "S5/S5File.h"
#include <OpenLoco/Core/FileStream.h>
#include <OpenLoco/Core/Reflection.hpp>

using namespace OpenLoco::Diagnostics;

namespace OpenLoco::GameSaveCompare
{
    namespace
    {
        struct FieldPath
        {
            std::string value;

            explicit FieldPath(std::string_view root)
                : value(root)
            {
            }

            [[nodiscard]] size_t mark() const { return value.size(); }
            void restore(size_t pos) { value.resize(pos); }

            void pushField(std::string_view name)
            {
                value += '.';
                value += name;
            }

            void pushIndex(size_t i)
            {
                fmt::format_to(std::back_inserter(value), "[{}]", i);
            }
        };

        struct CompareResult
        {
            bool displayAll;
            long count = 0;
        };

        template<typename T>
        void logDivergence(const T& lhs, const T& rhs, const FieldPath& path, CompareResult& result)
        {
            result.count++;
            if (!result.displayAll && result.count > 1)
                return;

            if constexpr (std::is_same_v<T, bool>)
            {
                Logging::info("DIVERGENCE {}: {} != {}", path.value, lhs, rhs);
            }
            else if constexpr (std::is_enum_v<T>)
            {
                using U = std::make_unsigned_t<std::underlying_type_t<T>>;
                Logging::info("DIVERGENCE {}: {:#x} != {:#x}", path.value,
                    static_cast<U>(lhs), static_cast<U>(rhs));
            }
            else if constexpr (std::is_integral_v<T>)
            {
                Logging::info("DIVERGENCE {}: {:#x} != {:#x}", path.value,
                    static_cast<uint64_t>(static_cast<std::make_unsigned_t<T>>(lhs)),
                    static_cast<uint64_t>(static_cast<std::make_unsigned_t<T>>(rhs)));
            }
            else
            {
                Logging::info("DIVERGENCE {}", path.value);
            }
        }

        template<typename T>
        bool compareValue(const T& lhs, const T& rhs, FieldPath& path, CompareResult& result)
        {
            if constexpr (std::is_array_v<T>)
            {
                constexpr auto kSize = std::extent_v<T>;
                bool diverged = false;
                for (size_t i = 0; i < kSize; i++)
                {
                    const auto pos = path.mark();
                    path.pushIndex(i);
                    diverged |= compareValue(lhs[i], rhs[i], path, result);
                    path.restore(pos);
                }
                return diverged;
            }
            else if constexpr (Reflection::kDescribable<std::remove_cvref_t<T>>)
            {
                bool diverged = false;
                Reflection::forEachFieldPair(lhs, rhs, [&](const auto& lhsField, const auto& rhsField, std::string_view name) {
                    const auto pos = path.mark();
                    path.pushField(name);
                    diverged |= compareValue(lhsField, rhsField, path, result);
                    path.restore(pos);
                });
                return diverged;
            }
            else
            {
                if (lhs != rhs)
                {
                    logDivergence(lhs, rhs, path, result);
                    return true;
                }
                return false;
            }
        }
    }

    static bool compareGameStates(const S5::GameState& gameState1, const S5::GameState& gameState2, bool displayAllDivergences)
    {
        if (displayAllDivergences)
        {
            Logging::info("Displaying all divergences");
        }

        FieldPath path("GameState");
        CompareResult result{ displayAllDivergences };
        compareValue(gameState1, gameState2, path, result);

        if (result.count == 0)
        {
            Logging::info("No divergences found");
        }
        else if (!displayAllDivergences && result.count > 1)
        {
            Logging::info("{} divergences found ({} omitted)", result.count, result.count - 1);
        }

        return result.count == 0;
    }

    bool compareElements(const std::vector<S5::TileElement>& tileElements1, const std::vector<S5::TileElement>& tileElements2, bool displayAllDivergences)
    {
        CompareResult result{ displayAllDivergences };

        if (tileElements1.size() != tileElements2.size())
        {
            Logging::info("TileElements sizes differ: {} vs {}", tileElements1.size(), tileElements2.size());
        }

        int elementCount = 0;
        auto iterator1 = tileElements1.begin();
        auto iterator2 = tileElements2.begin();
        for (auto y = 0; y < 384; ++y)
        {
            for (auto x = 0; x < 384; ++x)
            {
                auto allElementsOnTile = [](auto& iter) {
                    std::vector<S5::TileElement> ts;
                    do
                    {
                        ts.push_back(*iter);
                    } while (!iter++->isLast());
                    return ts;
                };
                const auto t1s = allElementsOnTile(iterator1);
                const auto t2s = allElementsOnTile(iterator2);
                auto i = 0U;
                const auto limit = std::min(t1s.size(), t2s.size());
                for (; i < limit; ++i)
                {
                    FieldPath elemPath(fmt::format("TileElement[{}] x:{} y:{}", elementCount, x, y));
                    compareValue(t1s[i], t2s[i], elemPath, result);
                    elementCount++;
                }

                for (; i < t1s.size(); ++i)
                {
                    result.count++;
                    if (result.displayAll || result.count == 1)
                    {
                        Logging::info("Extra TileElement[{}] x:{} y:{}", elementCount, x, y);
                    }
                    elementCount++;
                }
                for (; i < t2s.size(); ++i)
                {
                    result.count++;
                    if (result.displayAll || result.count == 1)
                    {
                        Logging::info("Removed TileElement[{}] x:{} y:{}", elementCount, x, y);
                    }
                    elementCount++;
                }
            }
        }

        if (!displayAllDivergences && result.count > 1)
        {
            Logging::info("{} tile element divergences ({} omitted)", result.count, result.count - 1);
        }

        return result.count == 0;
    }

    bool compareGameStates(const fs::path& path)
    {
        const auto* gameStateChar = reinterpret_cast<const char*>(&getGameState());
        const auto* currentS5GameState = reinterpret_cast<const S5::GameState*>(gameStateChar);
        Logging::info("Comparing reference file {} to current GameState frame", path);
        FileStream referenceFile(path, StreamMode::read);
        auto referenceGameState = S5::importSave(referenceFile);
        return compareGameStates(*currentS5GameState, referenceGameState->gameState, false);
    }

    bool compareGameStates(const fs::path& path1, const fs::path& path2, bool displayAllDivergences)
    {
        Logging::info("Comparing game state files:");
        Logging::info("   file1: {}", path1);
        Logging::info("   file2: {}", path2);

        FileStream file1(path1, StreamMode::read);
        auto state1 = S5::importSave(file1);
        FileStream file2(path2, StreamMode::read);
        auto state2 = S5::importSave(file2);
        auto match = compareGameStates(state1->gameState, state2->gameState, displayAllDivergences);
        match &= compareElements(state1->tileElements, state2->tileElements, displayAllDivergences);
        return match;
    }
}
