#include "Button.h"
#include "Graphics/Colour.h"
#include "Graphics/ImageIds.h"
#include "Graphics/SoftwareDrawingEngine.h"
#include "Ui/Window.h"

namespace OpenLoco::Ui::Widgets
{

    Button::Button(Ui::Point origin, Ui::Size size, WindowColour colour, uint32_t content /*= Widget::kContentNull*/, StringId tooltip /*= StringIds::null*/)
    {
        static_cast<Widget&>(*this) = makeWidget(origin, size, WidgetType::button, colour, content, tooltip);
        drawFunction = &draw;
    }

    void Button::draw(Gfx::RenderTarget* rt, const Widget& self, const WidgetState& widgetState)
    {
        auto* window = widgetState.window;
        int l = window->x + self.left;
        int r = window->x + self.right;
        int t = window->y + self.top;
        int b = window->y + self.bottom;

        auto flags = widgetState.flags;
        if (widgetState.activated)
        {
            flags |= Gfx::RectInsetFlags::borderInset;
        }

        auto& drawingCtx = Gfx::getDrawingEngine().getDrawingContext();
        drawingCtx.fillRectInset(*rt, l, t, r, b, widgetState.colour, flags);
    }

}
