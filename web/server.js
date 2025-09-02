const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3001;

const arch = process.argv[2] || 'wasm-mt';
console.log(`Starting server, architecture mode: ${arch}`);

if (arch === 'wasm-mt') {
    app.use((req, res, next) => {
        res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
        res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
        next();
    });
}

app.use(express.static(path.join(__dirname, 'demo')));
app.use('/build', express.static(path.join(__dirname, 'build')));

app.use((req, res, next) => {
  if (req.path.endsWith('.wasm')) {
    res.type('application/wasm');
  }
  next();
});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'demo', 'index.html'));
});

app.use((req, res, next) => {
  if (req.path === '/build/tgfx-web-demo.wasm') {
    const wasmPath = path.join(__dirname, 'build', 'tgfx-web-demo.wasm');
    if (!fs.existsSync(wasmPath)) {
      return res.status(404).send('WASM file not found. Please build the project first.');
    }
  }
  next();
});

app.listen(port, () => {
  console.log(`TGFX Web Demo server running at http://localhost:${port}`);
  console.log(`Architecture mode: ${arch}`);
  console.log('Press Ctrl+C to stop server');
});