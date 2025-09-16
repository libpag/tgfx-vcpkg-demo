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

function detectEmscriptenAndEMSDK() {
    let emccVersion;
    let emsdkPath;
    
    try {
        emccVersion = execSync('emcc --version', { encoding: 'utf8' }).split('\n')[0];
        console.log(`Emscripten version: ${emccVersion}`);
    } catch (error) {
        console.error('Error: Emscripten not found, please install and configure EMSDK');
        console.error('Reference: https://emscripten.org/docs/getting_started/downloads.html');
        process.exit(1);
    }
    
    emsdkPath = process.env.EMSDK;
    if (emsdkPath && fs.existsSync(emsdkPath)) {
        console.log(`Found EMSDK path from environment: ${emsdkPath}`);
        return emsdkPath;
    }
    
    try {
        const emccPath = execSync('which emcc', { encoding: 'utf8' }).trim();
        if (emccPath) {
            const possibleEmsdkPath = path.resolve(emccPath, '../../../');
            
            if (fs.existsSync(possibleEmsdkPath)) {
                console.log(`Derived EMSDK path from emcc location: ${possibleEmsdkPath}`);
                return possibleEmsdkPath;
            }
        }
    } catch (error) {
    }
    
    console.error('Error: Could not locate EMSDK installation directory');
    console.error('Please ensure EMSDK is properly installed and either:');
    console.error('1. Set the EMSDK environment variable, or');
    console.error('2. Install EMSDK in a standard location');
    console.error('Reference: https://emscripten.org/docs/getting_started/downloads.html');
    process.exit(1);
}

const emsdkPath = detectEmscriptenAndEMSDK();

function detectTGFXArchitecture() {
    const libDir = path.join(VCPKG_DIR, 'lib');
    
    if (fs.existsSync(path.join(libDir, '.tgfx.wasm-mt.md5'))) {
        return 'wasm-mt';
    } else if (fs.existsSync(path.join(libDir, '.tgfx.wasm.md5'))) {
        return 'wasm';
    }
    
    return 'wasm-mt';
}

const detectedArch = detectTGFXArchitecture();
console.log(`Detected TGFX library architecture: ${detectedArch}`);

if (arch !== detectedArch) {
    console.warn(`Warning: Requested ${arch} but detected TGFX library as ${detectedArch}`);
    console.warn('Suggest using matching TGFX library architecture for best compatibility');
}

console.log('Cleaning build directory...');
if (fs.existsSync(BUILD_DIR)) {
    fs.rmSync(BUILD_DIR, { recursive: true, force: true });
}
fs.mkdirSync(BUILD_DIR, { recursive: true });

const buildType = debug ? 'Debug' : 'Release';
const usePthreads = arch === 'wasm-mt';

function findNodeExecutable() {
    if (!emsdkPath) {
        return 'node';
    }
    
    const nodeDir = path.join(emsdkPath, 'node');
    if (!fs.existsSync(nodeDir)) {
        return 'node';
    }
    
    try {
        const nodeDirs = fs.readdirSync(nodeDir).filter(dir => 
            fs.statSync(path.join(nodeDir, dir)).isDirectory()
        );
        
        // Sort to get the latest version first
        nodeDirs.sort().reverse();
        
        for (const nodeVersionDir of nodeDirs) {
            const nodeVersionPath = path.join(nodeDir, nodeVersionDir);
            
            // Try different possible node executable paths for cross-platform compatibility
            const possiblePaths = [
                path.join(nodeVersionPath, 'bin', 'node'),           // Unix/Linux/macOS
                path.join(nodeVersionPath, 'bin', 'node.exe'),       // Windows with bin dir
                path.join(nodeVersionPath, 'node.exe'),              // Windows direct
                path.join(nodeVersionPath, 'node')                   // Unix direct
            ];
            
            for (const nodePath of possiblePaths) {
                if (fs.existsSync(nodePath)) {
                    console.log(`Found EMSDK node: ${nodePath}`);
                    return nodePath;
                }
            }
        }
    } catch (error) {
        console.warn('Warning: Could not detect EMSDK node version, using system node');
    }
    
    return 'node';
}

const nodeExecutable = findNodeExecutable();

// Find vcpkg ninja tool
function findVcpkgNinja() {
    // Determine the vcpkg triplet based on platform and architecture
    let triplet;
    if (process.platform === 'win32') {
        triplet = process.arch === 'x64' ? 'x64-windows' : 'x86-windows';
    } else if (process.platform === 'darwin') {
        triplet = process.arch === 'arm64' ? 'arm64-osx' : 'x64-osx';
    } else {
        triplet = process.arch === 'arm64' ? 'arm64-linux' : 'x64-linux';
    }
    
    const ninjaExecutable = process.platform === 'win32' ? 'ninja.exe' : 'ninja';
    const ninjaPath = path.join(PROJECT_ROOT, 'vcpkg_installed', triplet, 'tools', 'ninja', ninjaExecutable);
    
    if (fs.existsSync(ninjaPath)) {
        console.log(`Using vcpkg ninja: ${ninjaPath}`);
        return ninjaPath;
    }
    
    console.warn('Warning: vcpkg ninja not found, falling back to system ninja');
    return 'ninja';
}

const ninjaPath = findVcpkgNinja();

const cmakeArgs = [
    `-G "Ninja"`,
    `-DCMAKE_MAKE_PROGRAM="${ninjaPath}"`,
    `-DCMAKE_BUILD_TYPE=${buildType}`,
    `-DCMAKE_TOOLCHAIN_FILE="${emsdkPath}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake"`,
    `-DCMAKE_PREFIX_PATH="${VCPKG_DIR}"`,
    `-DUSE_PTHREADS=${usePthreads ? 'ON' : 'OFF'}`,
    `-DCMAKE_CROSSCOMPILING_EMULATOR="${nodeExecutable}"`
];

try {
    console.log('Configuring CMake...');
    execSync(`emcmake cmake "${DEMO_DIR}" ${cmakeArgs.join(' ')}`, {
        cwd: BUILD_DIR,
        stdio: 'inherit'
    });

    console.log('Building project...');
    
    execSync(`emmake ${ninjaPath} -j${require('os').cpus().length}`, {
        cwd: BUILD_DIR,
        stdio: 'inherit'
    });

    console.log('=== Build completed ===');
    console.log(`Architecture: ${arch}`);
    console.log(`Mode: ${buildType}`);
    console.log(`Files: build/tgfx-web-demo.js, build/tgfx-web-demo.wasm`);
    console.log('Run: npm run server:mt');
    console.log('Access: http://localhost:3000');

} catch (error) {
    console.error('Build failed:', error.message);
    process.exit(1);
}