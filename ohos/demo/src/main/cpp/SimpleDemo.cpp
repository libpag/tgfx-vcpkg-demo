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

#include "SimpleDemo.h"
#include "tgfx/core/Paint.h"
#include "tgfx/core/Path.h"
#include "tgfx/core/Rect.h"
#include "tgfx/core/Color.h"

SimpleDemo::SimpleDemo() {
}

void SimpleDemo::updateScreen(int width, int height, float density) {
  if (width > 0 && height > 0 && density >= 1.0f) {
    _width = width;
    _height = height;
    _density = density;
    if (_window) {
      _window->invalidSize();
    }
  }
}

void SimpleDemo::setWindow(std::shared_ptr<tgfx::Window> window) {
  _window = window;
}

void SimpleDemo::draw() {
  if (!_window || _width <= 0 || _height <= 0) {
    return;
  }
  
  auto device = _window->getDevice();
  auto context = device->lockContext();
  if (!context) {
    return;
  }
  
  auto surface = _window->getSurface(context);
  if (!surface) {
    device->unlock();
    return;
  }
  
  auto canvas = surface->getCanvas();
  canvas->clear(tgfx::Color::White());
  drawShapes(canvas);
  
  context->flushAndSubmit();
  _window->present(context);
  device->unlock();
}

void SimpleDemo::drawShapes(tgfx::Canvas* canvas) {
  float width = static_cast<float>(_width);
  float height = static_cast<float>(_height);
  
  // 计算基础尺寸
  float baseSize = std::min(width, height) * 0.15f;
  float spacing = width * 0.25f;
  float startX = (width - 2 * spacing) * 0.5f;
  float centerY = height * 0.5f;
  
  tgfx::Paint paint;
  
  // 红色矩形
  paint.setColor(tgfx::Color::Red());
  tgfx::Rect redRect = tgfx::Rect::MakeXYWH(
    startX - baseSize * 0.5f, 
    centerY - baseSize * 0.4f, 
    baseSize, 
    baseSize * 0.8f
  );
  canvas->drawRect(redRect, paint);
  
  // 蓝色椭圆
  paint.setColor(tgfx::Color::Blue());
  tgfx::Rect blueOval = tgfx::Rect::MakeXYWH(
    startX + spacing - baseSize * 0.5f, 
    centerY - baseSize * 0.5f, 
    baseSize, 
    baseSize
  );
  canvas->drawOval(blueOval, paint);
  
  // 绿色三角形
  paint.setColor(tgfx::Color::Green());
  tgfx::Path greenTriangle;
  float triangleX = startX + 2 * spacing;
  float triangleSize = baseSize * 0.6f;
  greenTriangle.moveTo(triangleX, centerY + triangleSize * 0.5f);
  greenTriangle.lineTo(triangleX - triangleSize * 0.5f, centerY - triangleSize * 0.5f);
  greenTriangle.lineTo(triangleX + triangleSize * 0.5f, centerY - triangleSize * 0.5f);
  greenTriangle.close();
  canvas->drawPath(greenTriangle, paint);
}