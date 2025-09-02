#include <emscripten/bind.h>
#include "TGFXView.h"

using namespace tgfx_demo;
using namespace emscripten;

EMSCRIPTEN_BINDINGS(TGFXDemo) {

  class_<TGFXBaseView>("TGFXBaseView")
      .function("updateSize", &TGFXBaseView::updateSize)
      .function("draw", &TGFXBaseView::draw);

  class_<TGFXView, base<TGFXBaseView>>("TGFXView")
      .smart_ptr<std::shared_ptr<TGFXView>>("TGFXView")
      .class_function("MakeFrom", optional_override([](const std::string& canvasID) {
                        if (canvasID.empty()) {
                          return std::shared_ptr<TGFXView>(nullptr);
                        }
                        return std::make_shared<TGFXView>(canvasID);
                      }));

  class_<TGFXThreadsView, base<TGFXBaseView>>("TGFXThreadsView")
      .smart_ptr<std::shared_ptr<TGFXThreadsView>>("TGFXThreadsView")
      .class_function("MakeFrom", optional_override([](const std::string& canvasID) {
                        if (canvasID.empty()) {
                          return std::shared_ptr<TGFXThreadsView>(nullptr);
                        }
                        return std::make_shared<TGFXThreadsView>(canvasID);
                      }));
}