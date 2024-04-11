#include "Ui/Widget.h"

namespace OpenLoco::Ui::Widgets
{
    struct Button : Widget
    {
        Button(Ui::Point origin, Ui::Size size, WindowColour colour, uint32_t content = Widget::kContentNull, StringId tooltip = StringIds::null);

        static void draw(Gfx::RenderTarget* rt, const Widget& self, const WidgetState& widgetState);
    };

}
