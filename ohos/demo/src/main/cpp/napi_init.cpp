#include "napi/native_api.h"
#include <ace/xcomponent/native_interface_xcomponent.h>
#include "tgfx/gpu/opengl/egl/EGLWindow.h"
#include "SimpleDemo.h"

// 全局状态 - 极简化
static float screenDensity = 1.0f;
static std::shared_ptr<SimpleDemo> demo = nullptr;

// 更新密度
static napi_value OnUpdateDensity(napi_env env, napi_callback_info info) {
  size_t argc = 1;
  napi_value args[1] = {nullptr};
  napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
  double value;
  napi_get_value_double(env, args[0], &value);
  screenDensity = static_cast<float>(value);
  return nullptr;
}

// 绘制一帧
static napi_value DrawFrame(napi_env, napi_callback_info) {
  if (demo) {
    demo->draw();
  }
  return nullptr;
}

// 更新尺寸
static void UpdateSize(OH_NativeXComponent* component, void* nativeWindow) {
  uint64_t width, height;
  int32_t ret = OH_NativeXComponent_GetXComponentSize(component, nativeWindow, &width, &height);
  if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
    return;
  }
  
  if (!demo) {
    demo = std::make_shared<SimpleDemo>();
  }
  demo->updateScreen(static_cast<int>(width), static_cast<int>(height), screenDensity);
}

// XComponent回调
static void OnSurfaceCreatedCB(OH_NativeXComponent* component, void* nativeWindow) {
  UpdateSize(component, nativeWindow);
  auto window = tgfx::EGLWindow::MakeFrom(reinterpret_cast<EGLNativeWindowType>(nativeWindow));
  if (window && demo) {
    demo->setWindow(window);
    demo->draw();
  }
}

static void OnSurfaceChangedCB(OH_NativeXComponent* component, void* nativeWindow) {
  UpdateSize(component, nativeWindow);
}

static void OnSurfaceDestroyedCB(OH_NativeXComponent*, void*) {
  if (demo) {
    demo->setWindow(nullptr);
  }
}

static void DispatchTouchEventCB(OH_NativeXComponent*, void*) {
  // 触摸时重绘
  if (demo) {
    demo->draw();
  }
}

// 注册回调
static void RegisterCallback(napi_env env, napi_value exports) {
  napi_status status;
  napi_value exportInstance = nullptr;
  OH_NativeXComponent* nativeXComponent = nullptr;
  
  status = napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance);
  if (status != napi_ok) return;
  
  status = napi_unwrap(env, exportInstance, reinterpret_cast<void**>(&nativeXComponent));
  if (status != napi_ok) return;
  
  static OH_NativeXComponent_Callback callback;
  callback.OnSurfaceCreated = OnSurfaceCreatedCB;
  callback.OnSurfaceChanged = OnSurfaceChangedCB;
  callback.OnSurfaceDestroyed = OnSurfaceDestroyedCB;
  callback.DispatchTouchEvent = DispatchTouchEventCB;
  
  OH_NativeXComponent_RegisterCallback(nativeXComponent, &callback);
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
  napi_property_descriptor desc[] = {
    {"drawFrame", nullptr, DrawFrame, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"updateDensity", nullptr, OnUpdateDensity, nullptr, nullptr, nullptr, napi_default, nullptr},
  };
  napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
  RegisterCallback(env, exports);
  return exports;
}
EXTERN_C_END

static napi_module demoModule = {1, 0, nullptr, Init, "demo", nullptr, {0}};

extern "C" __attribute__((constructor)) void RegisterDemoModule(void) {
  napi_module_register(&demoModule);
}