# TGFX vcpkg Demo

This repository demonstrates how to integrate the TGFX graphics library using vcpkg for offline dependency management. TGFX is Tencent's open-source lightweight 2D graphics library that provides high-performance cross-platform rendering for text, geometries, and images.

## CLion Build (macOS)

### 1. CLion with Vcpkg integration

Please refer to the official CLion documentation for configuring vcpkg integration: https://www.jetbrains.com/help/clion/package-management.html

### 2. Build and Run

1. CLion will automatically detect CMakeLists.txt and begin configuration
2. Wait for vcpkg to download and build TGFX dependencies (initial build may take considerable time)
3. Once build is complete, click the run button to execute the demo

## Command Line Build

### Download and Install vcpkg

Please refer to the official vcpkg installation guide: https://vcpkg.io/en/getting-started.html

### Build on macOS/Linux

```bash
# Create build directory
mkdir build && cd build

# Configure CMake (replace with your vcpkg path)
cmake .. -DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake

# Build project
cmake --build .

# Run demo
./demo
```

### Build on Windows

```cmd
# Create build directory
mkdir build && cd build

# Configure CMake (replace with your vcpkg path)
cmake .. -DCMAKE_TOOLCHAIN_FILE=C:\path\to\vcpkg\scripts\buildsystems\vcpkg.cmake

# Build project
cmake --build .

# Run demo
.\Debug\demo.exe
```

## Project Structure

```
tgfx-vcpkg-demo/
├── CMakeLists.txt              # CMake build configuration
├── main.cpp                    # Demo source code
├── vcpkg.json                  # vcpkg manifest file
├── vcpkg-configuration.json    # vcpkg configuration
├── README.md                   # Project documentation
└── ports/                      # Custom vcpkg ports
    └── tgfx/                   # TGFX port configuration
        ├── portfile.cmake      # Port build script
        ├── vcpkg.json          # Port dependency configuration
        ├── usage               # Usage instructions
        ├── scripts/            # Build scripts
        └── triplets/           # Platform configurations
```

## Getting Help

- [TGFX Official Repository](https://github.com/Tencent/tgfx)
- [vcpkg Official Documentation](https://vcpkg.io/)
- [CMake Official Documentation](https://cmake.org/documentation/)

## Contributing

Issues and Pull Requests are welcome to improve this demonstration project. Please ensure your contributions follow the existing code style and include appropriate documentation.

---

**Note:** This is a demonstration project designed to showcase TGFX integration with vcpkg. For production use, please adapt the configuration according to your specific requirements.