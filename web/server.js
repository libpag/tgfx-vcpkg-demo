const express = require('express');
const path = require('path');

const app = express();
const port = 3000;

// Get architecture mode from command line arguments
const args = process.argv.slice(2);
const arch = args.includes('wasm') ? 'wasm' : 'wasm-mt';

console.log(`Starting TGFX Web Demo server, architecture mode: ${arch}`);

// Enable SharedArrayBuffer for multi-threaded WebAssembly
app.use((req, res, next) => {
  res.set('Cross-Origin-Opener-Policy', 'same-origin');
  res.set('Cross-Origin-Embedder-Policy', 'require-corp');
  next();
});

// Serve static files
app.use(express.static(path.join(__dirname, 'demo')));
app.use('/build', express.static(path.join(__dirname, 'build')));

// Set correct MIME type for WASM files
app.use((req, res, next) => {
  if (req.path.endsWith('.wasm')) {
    res.type('application/wasm');
  }
  next();
});

// Default route
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'demo', 'index.html'));
});

app.listen(port, () => {
  console.log(`TGFX Web Demo server running at http://localhost:${port}`);
  console.log(`Architecture mode: ${arch}`);
  
  // Auto-open browser
  const url = `http://localhost:${port}`;
  const start = (process.platform === 'darwin' ? 'open' : process.platform === 'win32' ? 'start' : 'xdg-open');
  require('child_process').exec(`${start} ${url}`, (error) => {
    if (error) {
      console.log('Could not auto-open browser. Please manually navigate to:', url);
    } else {
      console.log('Browser opened automatically');
    }
  });
  
  console.log('Press Ctrl+C to stop server');
});