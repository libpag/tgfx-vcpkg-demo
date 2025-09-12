#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const arch = args.includes('--arch=wasm') ? 'wasm' : 'wasm-mt';
const debug = args.includes('--debug');

console.log(`=== TGFX Web Demo Build (${arch}) ===`);

const PROJECT_ROOT = __dirname;
const BUILD_DIR = path.join(PROJECT_ROOT, 'build');
const DEMO_DIR = path.join(PROJECT_ROOT, 'demo');
const VCPKG_DIR = path.join(PROJECT_ROOT, 'vcpkg_installed', 'wasm32-emscripten');

try {
    const emccVersion = execSync('emcc --version', { encoding: 'utf8' }).split('\n')[0];
    console.log(`Emscripten version: ${emccVersion}`);
} catch (error) {
    console.error('Error: Emscripten not found, please install and configure EMSDK');
    console.error('Reference: https://emscripten.org/docs/getting_started/downloads.html');
    process.exit(1);
}

function detectTGFXArchitecture() {
    const libDir = path.join(VCPKG_DIR, 'lib');
    
    if (fs.existsSync(path.join(libDir, '.tgfx.wasm-mt.md5'))) {
        return 'wasm-mt';
    } else if (fs.existsSync(path.join(libDir, '.tgfx.wasm.md5'))) {
        return 'wasm';
    }
    
    return 'wasm';
}

const detectedArch = detectTGFXArchitecture();
console.log(`Detected TGFX library architecture: ${detectedArch}`);

if (arch !== detectedArch) {
    console.warn(`Warning: Requested ${arch} but detected TGFX library as ${detectedArch}`);
    console.warn('Suggest using matching TGFX library architecture for best compatibility');
}

console.log('Cleaning build directory...');
execSync(`rm -rf "${BUILD_DIR}"`, { stdio: 'inherit' });
fs.mkdirSync(BUILD_DIR, { recursive: true });

const buildType = debug ? 'Debug' : 'Release';
const usePthreads = arch === 'wasm-mt';
const emsdkPath = process.env.EMSDK || '/Users/huangbeiao/Documents/emsdk';

const cmakeArgs = [
    `-DCMAKE_BUILD_TYPE=${buildType}`,
    `-DCMAKE_TOOLCHAIN_FILE="${emsdkPath}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake"`,
    `-DCMAKE_PREFIX_PATH="${VCPKG_DIR}"`,
    `-DUSE_PTHREADS=${usePthreads ? 'ON' : 'OFF'}`,
    `-DCMAKE_CROSSCOMPILING_EMULATOR="${emsdkPath}/node/20.18.0_64bit/bin/node"`
];

try {
    console.log('Configuring CMake...');
    execSync(`emcmake cmake "${DEMO_DIR}" ${cmakeArgs.join(' ')}`, {
        cwd: BUILD_DIR,
        stdio: 'inherit'
    });

    console.log('Building project...');
    execSync(`emmake make -j${require('os').cpus().length}`, {
        cwd: BUILD_DIR,
        stdio: 'inherit'
    });

    console.log('=== Build completed ===');
    console.log(`Architecture: ${arch}`);
    console.log(`Mode: ${buildType}`);
    console.log(`Files: build/tgfx-web-demo.js, build/tgfx-web-demo.wasm`);
    console.log('Run: npm run server:mt');
    console.log('Access: http://localhost:3001');

} catch (error) {
    console.error('Build failed:', error.message);
    process.exit(1);
}