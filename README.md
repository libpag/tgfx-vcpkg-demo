# Introduction

This repository demonstrates how to integrate the [TGFX](https://github.com/Tencent/tgfx) graphics library using vcpkg for offline dependency management. TGFX is Tencent's open-source lightweight 2D graphics library that provides high-performance cross-platform rendering for text, geometries, and images.

## TGFX vcpkg Integration Approach

**Important Note:** This project uses a special approach for TGFX integration with vcpkg that differs from standard vcpkg usage:

- **vcpkg Role**: Used solely for fetching TGFX source code, not for TGFX dependency management
- **Third-party Dependencies**: Managed using the [depsync](https://github.com/domchen/depsync) tool instead of vcpkg
- **Build System**: TGFX and its dependencies are compiled using the [vendor_tools](https://github.com/libpag/vendor_tools) build system

This hybrid approach allows us to leverage vcpkg's source management capabilities while maintaining control over the dependency resolution and build process through specialized tools designed for TGFX's requirements.

We are considering full vcpkg adaptation in future releases to provide a more standardized integration experience.

## Prerequisites

### Download and Install vcpkg

Please refer to the official vcpkg installation guide: https://vcpkg.io/en/getting-started.html

**Important:** After installing vcpkg, you need to add it to your system PATH or set it as a temporary environment variable:

**Option 1: Add to System PATH**
- **Windows**: Add the vcpkg installation directory to your system PATH environment variable
- **macOS/Linux**: Add `export PATH="/path/to/vcpkg:$PATH"` to your shell profile (`.bashrc`, `.zshrc`, etc.)

**Option 2: Temporary Environment Variable**
Set temporary environment variable (replace with your vcpkg path):
```bash
export VCPKG_ROOT=/path/to/vcpkg
export PATH="$VCPKG_ROOT:$PATH"
```

This ensures that the `vcpkg` command is available globally in your terminal.

## Download TGFX portfiles

To use the TGFX port files, you need to **download** any TGFX port files of v2.0.0 or above from [TGFX release](https://github.com/Tencent/tgfx/releases).

Then you need to replace the downloaded ports folder with the [ports folder](https://github.com/libpag/tgfx-vcpkg-demo/tree/main/ports) in root directory of the demo.

## Platform-Specific Build Instructions

### macOS Platform

#### Building with CLion (Recommended)

1. **CLion with Vcpkg integration**  
   Please refer to the official CLion documentation for configuring vcpkg integration: https://www.jetbrains.com/help/clion/package-management.html

2. **Build and Run**
   1. CLion will automatically detect CMakeLists.txt and begin configuration
   2. Wait for vcpkg to download and build TGFX dependencies (initial build may take considerable time)
   3. Once build is complete, click the run button to execute the demo

#### Command Line Build

Create build directory:
```bash
mkdir build && cd build
```

Configure CMake (replace with your vcpkg path):
This command will automatically download and install vcpkg third-party libraries:
```bash
cmake .. -DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake
```
Build project:
```bash
cmake --build .
```
Run demo:
```bash
./demo
```

### Windows Platform

#### Visual Studio Build
Create build directory:
```cmd
mkdir build
cd build
```
Configure CMake (replace with your vcpkg path):
This command will automatically download and install vcpkg third-party libraries:
```cmd
cmake .. -DCMAKE_TOOLCHAIN_FILE=C:\path\to\vcpkg\scripts\buildsystems\vcpkg.cmake
```
Optional: Specify architecture and build type:
```cmd
cmake .. -DCMAKE_TOOLCHAIN_FILE=C:\path\to\vcpkg\scripts\buildsystems\vcpkg.cmake -A x64 -DCMAKE_BUILD_TYPE=Release
cmake .. -DCMAKE_TOOLCHAIN_FILE=C:\path\to\vcpkg\scripts\buildsystems\vcpkg.cmake -A Win32 -DCMAKE_BUILD_TYPE=Debug
```

**Important:** Ensure that the Visual Studio toolchain used to build TGFX matches the toolchain used to build the Windows demo. Mismatched toolchains will result in linking errors.

After running the cmake command, a `demo.sln` solution file will be generated. Open this file in Visual Studio and build the project to generate the executable file.

### Web Platform

**Prerequisites:** 

1. **Install Emscripten SDK (EMSDK)**

   For detailed installation instructions, refer to: https://emscripten.org/docs/getting_started/downloads.html

2. **Install TGFX using vcpkg in the web directory:**
   
   TGFX supports both single-threaded and multi-threaded WebAssembly builds.
   
   Navigate to web directory:
   ```bash
   cd web
      ```
   Default: Multi-threaded WebAssembly version:
   ```bash
   vcpkg install --triplet=wasm32-emscripten
   ```
   
   **To use different threading modes**, modify the `web/vcpkg.json` file:

   For single-threaded version (default):
   ```json
   {
     "dependencies": [
       {
         "name": "tgfx"
       }
     ]
   }
   ```
   For multi-threaded version:
   ```json
   {
     "dependencies": [
       {
         "name": "tgfx",
         "features": ["threads"]
       }
     ]
   }
   ```
   
   **Note**: In vcpkg CLASSIC mode, you can use: `vcpkg install tgfx[threads] --triplet=wasm32-emscripten`.

To build and run the web demo:

Navigate to web directory:
```bash
cd web
```
Install dependencies:
```bash
npm install
```
Build for multi-threaded WebAssembly (recommended):
```bash
npm run build
```
Alternative build options:
```bash
npm run build:st        # Single-threaded WebAssembly
npm run build:debug     # Debug build with multi-threading
npm run build:st:debug  # Debug build with single-threading
```
Start development server:
```bash
npm run server
```
Alternative server options:
```bash
npm run server:st     # Serve single-threaded build
npm run server        # Serve multi-threaded build
```

Open your browser and navigate to `http://localhost:3000` to view the demo.

### OHOS Platform (HarmonyOS)

**Prerequisites:** Install TGFX using vcpkg in the OHOS directory:

```bash
cd ohos
vcpkg install --triplet=arm64-ohos
```
 Using `vcpkg install tgfx:x64-ohos` for x64 architecture

**Note:** By default, the OHOS demo uses ARM64 architecture. To build for x64 architecture instead:
1. Install x64 TGFX: `vcpkg install --triplet=x64-ohos`
2. Modify `ohos/demo/build-profile.json5` and change `"abiFilters": ["arm64-v8a"]` to `"abiFilters": ["x86-64"]`

#### Building with DevEco Studio

1. **Install DevEco Studio**  
   Download and install DevEco Studio from the official HarmonyOS developer website: https://developer.harmonyos.com/en/develop/deveco-studio

2. **Open Project**
   1. Launch DevEco Studio
   2. Open the `ohos` directory as a project
   3. Wait for the IDE to sync and configure the project

3. **Build and Run**
   1. Connect a HarmonyOS device or start an emulator
   2. Click the "Run" button in DevEco Studio
   3. The demo will be built and deployed to your device/emulator

## Project Structure

```
tgfx-vcpkg-demo/
├── CMakeLists.txt              # CMake build configuration
├── main.cpp                    # macOS/windows demo source code
├── vcpkg.json                  # vcpkg manifest file
├── vcpkg-configuration.json    # vcpkg configuration
├── README.md                   # Project documentation
├── web/                        # Web platform project
│   ├── package.json            # Web build scripts and dependencies
│   ├── build.js                # Web build script
│   ├── server.js               # Development server
│   └── demo/                   # Web demo source code
├── ohos/                       # OHOS platform project
│   ├── demo/                   # OHOS demo application
│   ├── hvigorfile.ts           # OHOS build configuration
│   └── build-profile.json5     # OHOS build profile
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