#pragma once

#include <string>
#include <memory>
#include "tgfx/gpu/opengl/webgl/WebGLWindow.h"

// Forward declarations
// namespace tgfx {
// class Window;
// }

namespace tgfx_demo {

class TGFXBaseView {
public:
    TGFXBaseView(const std::string& canvasID);
    virtual ~TGFXBaseView() = default;
    
    void updateSize(float devicePixelRatio);
    virtual bool draw() = 0;
    
protected:
    std::string canvasID;
    std::shared_ptr<tgfx::Window> window;
    int width = 0;
    int height = 0;
    float devicePixelRatio = 1.0f;
};

// Single-threaded version
class TGFXView : public TGFXBaseView {
public:
    TGFXView(const std::string& canvasID);
    bool draw() override;
};

// Multi-threaded version
class TGFXThreadsView : public TGFXBaseView {
public:
    TGFXThreadsView(const std::string& canvasID);
    bool draw() override;
};

} // namespace tgfx_demo