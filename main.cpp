#include <iostream>
#include <fstream>
#include "tgfx/core/Surface.h"
#include "tgfx/core/Canvas.h"
#include "tgfx/core/Paint.h"
#include "tgfx/core/Path.h"
#include "tgfx/core/Rect.h"
#include "tgfx/core/Color.h"
#include "tgfx/core/ImageCodec.h"
#include "tgfx/core/Pixmap.h"
#include "tgfx/gpu/opengl/GLDevice.h"

int main() {
    auto device = tgfx::GLDevice::Make();
    if (!device) {
        std::cerr << "Failed to create GLDevice!" << std::endl;
        return -1;
    }

    auto context = device->lockContext();
    if (!context) {
        std::cerr << "Failed to lock context!" << std::endl;
        return -1;
    }

    const int canvasWidth = 800;
    const int canvasHeight = 600;
    auto surface = tgfx::Surface::Make(context, canvasWidth, canvasHeight);
    if (!surface) {
        std::cerr << "Failed to create surface!" << std::endl;
        device->unlock();
        return -1;
    }

    auto canvas = surface->getCanvas();
    canvas->clear(tgfx::Color::White());

    tgfx::Paint paint;

    paint.setColor(tgfx::Color::Red());
    tgfx::Rect redRect = tgfx::Rect::MakeXYWH(50, 50, 200, 150);
    canvas->drawRect(redRect, paint);

    paint.setColor(tgfx::Color::Blue());
    tgfx::Rect blueOval = tgfx::Rect::MakeXYWH(300, 100, 150, 150);
    canvas->drawOval(blueOval, paint);

    paint.setColor(tgfx::Color::Green());
    tgfx::Path greenTriangle;
    greenTriangle.moveTo(500, 200);
    greenTriangle.lineTo(600, 100);
    greenTriangle.lineTo(700, 200);
    greenTriangle.close();
    canvas->drawPath(greenTriangle, paint);

    auto imageInfo = tgfx::ImageInfo::Make(canvasWidth, canvasHeight, tgfx::ColorType::RGBA_8888, tgfx::AlphaType::Premultiplied);
    auto pixelBuffer = std::make_unique<uint8_t[]>(imageInfo.byteSize());

    if (!surface->readPixels(imageInfo, pixelBuffer.get())) {
        std::cerr << "Failed to read pixels!" << std::endl;
        device->unlock();
        return -1;
    }

    tgfx::Pixmap pixmap(imageInfo, pixelBuffer.get());
    auto encodedData = tgfx::ImageCodec::Encode(pixmap, tgfx::EncodedFormat::WEBP, 100);

    if (!encodedData) {
        std::cerr << "Failed to encode image!" << std::endl;
        device->unlock();
        return -1;
    }

    std::ofstream outputFile("demo_output.webp", std::ios::binary);
    if (!outputFile) {
        std::cerr << "Failed to create output file!" << std::endl;
        device->unlock();
        return -1;
    }

    outputFile.write(reinterpret_cast<const char*>(encodedData->data()), static_cast<std::streamsize>(encodedData->size()));
    outputFile.close();

    std::cout << "Image saved as demo_output.webp" << std::endl;

    device->unlock();
    return 0;
}
