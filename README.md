# TGFX vcpkg Demo

This repository demonstrates how to integrate the TGFX graphics library using vcpkg for offline dependency management. TGFX is Tencent's open-source lightweight 2D graphics library that provides high-performance cross-platform rendering for text, geometries, and images.

## Overview

This project provides:
- Complete TGFX vcpkg port configuration
- Simple C++ demonstration code
- Cross-platform build configuration (macOS, Windows, Linux, Android, iOS, OpenHarmony)
- Comprehensive integration guide

## Installing vcpkg

### 1. Download and Install vcpkg

Please refer to the official vcpkg installation guide: https://vcpkg.io/en/getting-started.html

**macOS/Linux:**
```bash
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh
```

**Windows:**
```cmd
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat
```

## Running the Demo with CLion (macOS)

### 1. Clone the Repository

```bash
git clone https://github.com/libpag/tgfx-vcpkg-demo.git
cd tgfx-vcpkg-demo
```

### 2. Configure CLion

1. Open CLion and select "Open" to open the project directory
2. Navigate to `Settings/Preferences` → `Build, Execution, Deployment` → `CMake`
3. Add the following parameter to `CMake options`:

```
-DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake
```

**Note:** Replace `/path/to/vcpkg` with your actual vcpkg installation path.

### 3. Build and Run

1. CLion will automatically detect CMakeLists.txt and begin configuration
2. Wait for vcpkg to download and build TGFX dependencies (initial build may take considerable time)
3. Once build is complete, click the run button to execute the demo

## Command Line Build

### macOS/Linux

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

### Windows

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