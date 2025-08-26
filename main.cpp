#include <iostream>
#include "tgfx/core/Matrix.h"
#include "tgfx/core/Point.h"

int main() {
    std::cout << "Testing TGFX library..." << std::endl;

    const tgfx::Matrix& matrix = tgfx::Matrix::I();

    tgfx::Point point(100.0f, 200.0f);

    tgfx::Point transformedPoint = matrix.mapXY(point.x, point.y);

    std::cout << "Original point: (" << point.x << ", " << point.y << ")" << std::endl;
    std::cout << "Transformed point: (" << transformedPoint.x << ", " << transformedPoint.y << ")" << std::endl;

    tgfx::Matrix scaleMatrix = tgfx::Matrix::MakeScale(2.0f, 3.0f);
    tgfx::Point scaledPoint = scaleMatrix.mapXY(point.x, point.y);

    std::cout << "Scaled point: (" << scaledPoint.x << ", " << scaledPoint.y << ")" << std::endl;

    return 0;
}