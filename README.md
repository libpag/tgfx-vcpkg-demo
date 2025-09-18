# Introduction

This repository demonstrates how to integrate the [TGFX](https://github.com/Tencent/tgfx) graphics library using vcpkg for offline dependency management. TGFX is Tencent's open-source lightweight 2D graphics library that provides high-performance cross-platform rendering for text, geometries, and images.

## TGFX vcpkg Integration Approach

**Important Note:** This project uses vcpkg only for fetching TGFX source code, while dependencies are managed by [depsync](https://github.com/domchen/depsync) and built using [vendor_tools](https://github.com/libpag/vendor_tools). This hybrid approach provides better control over TGFX's specialized build requirements compared to standard vcpkg dependency management.

## Prerequisites

### Download and Install vcpkg

Please refer to the official vcpkg installation guide: https://vcpkg.io/en/getting-started.html

## Updating TGFX Version

This project currently uses the latest TGFX version by default. To update to a specific TGFX version, you have two options:

### Method 1: Download from Official Releases (Recommended)

1. Visit the [TGFX releases page](https://github.com/Tencent/tgfx/releases)
2. Download the corresponding port files for your target version
3. Replace the files in the `ports/tgfx/` directory with the downloaded versions

### Method 2: Using the Update Script

Use the provided script in this project root directory to automatically update the portfile:


Find the commit hash for your target version in TGFX repository
Then run the update script with the commit hash
```bash
node update_vcpkg <commit-hash>
```

Example: Update to a specific commit
```bash
node update_vcpkg 6095b909b1109d4910991a034405f4ae30d6786f
```

The script will automatically download the source code, calculate the SHA512 hash, and update the `ports/tgfx/portfile.cmake` file.

## Using TGFX with vcpkg

### Port Installation

Before using TGFX through vcpkg, you need to make the custom port available:

1. **Copy the port to vcpkg**: Copy the `ports/tgfx` directory to your vcpkg installation's `ports` directory
2. **Alternative**: Use overlay ports by specifying `--overlay-ports=./ports` in vcpkg commands

### Installation Methods

vcpkg supports two installation modes for dependency management:

#### Manifest Mode (Recommended for Projects)

Manifest mode provides project-local dependency management through a `vcpkg.json` file:

```json
{
  "name": "your-project",
  "version": "1.0.0",
  "dependencies": [
    {
      "name": "tgfx",
      "features": ["svg", "pdf", "opengl", "threads"]
    }
  ]
}
```

Install dependencies locally to your project:
```bash
vcpkg install --triplet=x64-osx
```

#### Classic Mode

Classic mode installs packages globally for system-wide access:

Basic installation:
```bash
vcpkg install tgfx
```

Install with specific features:
```bash
vcpkg install tgfx[svg,pdf] --triplet=x64-osx
```

WebAssembly multi-threaded build example:
```bash
vcpkg install tgfx[threads] --triplet=wasm32-emscripten
```

### Available Features

Refer to [`ports/tgfx/vcpkg.json`](ports/tgfx/vcpkg.json) for the complete feature list and descriptions.

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
