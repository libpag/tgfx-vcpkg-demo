/////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Tencent is pleased to support the open source community by making tgfx available.
//
//  Copyright (C) 2023 Tencent. All rights reserved.
//
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except
//  in compliance with the License. You may obtain a copy of the License at
//
//      https://opensource.org/licenses/BSD-3-Clause
//
//  unless required by applicable law or agreed to in writing, software distributed under the
//  license is distributed on an "as is" basis, without warranties or conditions of any kind,
//  either express or implied. see the license for the specific language governing permissions
//  and limitations under the license.
//
/////////////////////////////////////////////////////////////////////////////////////////////////

#pragma once

#include "tgfx/core/Canvas.h"
#include "tgfx/gpu/Window.h"
#include <memory>

/**
 * SimpleDemo - 一个极简的TGFX演示类
 * 合并了原来的AppHost、Drawer和DisplayLink功能
 */
class SimpleDemo {
public:
  SimpleDemo();
  ~SimpleDemo() = default;

  // 更新屏幕尺寸和密度
  void updateScreen(int width, int height, float density);
  
  // 设置窗口
  void setWindow(std::shared_ptr<tgfx::Window> window);
  
  // 绘制一帧
  void draw();
  
  // 获取屏幕信息
  int width() const { return _width; }
  int height() const { return _height; }
  float density() const { return _density; }

private:
  // 绘制三个简单图形
  void drawShapes(tgfx::Canvas* canvas);
  
  int _width = 1280;
  int _height = 720;
  float _density = 1.0f;
  std::shared_ptr<tgfx::Window> _window = nullptr;
};