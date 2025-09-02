#include "TGFXView.h"
#include <iostream>
#include <emscripten/html5.h>
#include "tgfx/core/Surface.h"

namespace tgfx_demo {

TGFXBaseView::TGFXBaseView(const std::string& canvasID) : canvasID(canvasID) {
    std::cout << "TGFXBaseView constructor called with canvasID: " << canvasID << std::endl;
    
    if (!canvasID.empty() && canvasID[0] != '#') {
        this->canvasID = "#" + canvasID;
        std::cout << "Fixed canvasID to: " << this->canvasID << std::endl;
    }
    
    int width, height;
    EMSCRIPTEN_RESULT result = emscripten_get_canvas_element_size(this->canvasID.c_str(), &width, &height);
    if (result == EMSCRIPTEN_RESULT_SUCCESS) {
        std::cout << "Canvas element found, size: " << width << "x" << height << std::endl;
    } else {
        std::cout << "Canvas element NOT found, error: " << result << std::endl;
    }
}

void TGFXBaseView::updateSize(float devicePixelRatio) {
    std::cout << "updateSize called with devicePixelRatio: " << devicePixelRatio << std::endl;
    this->devicePixelRatio = devicePixelRatio;
    
    if (!canvasID.empty()) {
        int pixelWidth, pixelHeight;
        EMSCRIPTEN_RESULT result = emscripten_get_canvas_element_size(canvasID.c_str(), &pixelWidth, &pixelHeight);
        if (result == EMSCRIPTEN_RESULT_SUCCESS) {
            width = pixelWidth;
            height = pixelHeight;
            std::cout << "Canvas pixel size: " << width << "x" << height << std::endl;
        } else {
            width = 800;
            height = 600;
            std::cout << "Using default size: " << width << "x" << height << std::endl;
        }
    }
}

}