#include "TGFXView.h"
#include <iostream>
#include "tgfx/core/Surface.h"

namespace tgfx_demo {

TGFXView::TGFXView(const std::string& canvasID) : TGFXBaseView(canvasID) {
    std::cout << "TGFXView constructor" << std::endl;
}

bool TGFXView::draw() {
    std::cout << "TGFXView::draw called" << std::endl;
    
    if (width <= 0 || height <= 0) {
        std::cout << "Invalid canvas size: " << width << "x" << height << std::endl;
        return false;
    }
    
    if (window == nullptr) {
        std::cout << "Creating WebGL window" << std::endl;
        window = tgfx::WebGLWindow::MakeFrom(canvasID);
        if (window == nullptr) {
            std::cout << "Failed to create WebGL window" << std::endl;
            return false;
        }
        std::cout << "WebGL window created" << std::endl;
    }
    
    auto device = window->getDevice();
    if (device == nullptr) {
        std::cout << "Failed to get device" << std::endl;
        return false;
    }
    
    auto context = device->lockContext();
    if (context == nullptr) {
        std::cout << "Failed to lock context" << std::endl;
        return false;
    }
    
    auto surface = window->getSurface(context);
    if (surface == nullptr) {
        std::cout << "Failed to get surface" << std::endl;
        device->unlock();
        return false;
    }
    
    auto canvas = surface->getCanvas();
    if (canvas == nullptr) {
        std::cout << "Failed to get canvas" << std::endl;
        device->unlock();
        return false;
    }
    
    std::cout << "Clearing canvas" << std::endl;
    canvas->clear(tgfx::Color::White());
    
    std::cout << "Drawing shapes" << std::endl;
    
    tgfx::Paint paint;
    
    paint.setColor(tgfx::Color::Red());
    tgfx::Rect redRect = tgfx::Rect::MakeXYWH(50, 50, 200, 150);
    canvas->drawRect(redRect, paint);
    std::cout << "Drew rectangle" << std::endl;
    
    paint.setColor(tgfx::Color::Blue());
    tgfx::Rect blueOval = tgfx::Rect::MakeXYWH(300, 100, 150, 150);
    canvas->drawOval(blueOval, paint);
    std::cout << "Drew oval" << std::endl;
    
    paint.setColor(tgfx::Color::Green());
    tgfx::Path greenTriangle;
    greenTriangle.moveTo(500, 200);
    greenTriangle.lineTo(600, 100);
    greenTriangle.lineTo(700, 200);
    greenTriangle.close();
    canvas->drawPath(greenTriangle, paint);
    std::cout << "Drew triangle" << std::endl;
    
    context->flushAndSubmit();
    window->present(context);
    device->unlock();
    
    std::cout << "Draw completed" << std::endl;
    return true;
}

}

int main(int, const char*[]) {
    return 0;
}