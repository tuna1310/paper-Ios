import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';

const SIZE = 1024;
const outPath = path.resolve(
  'ios/PaperTerritory/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png'
);

function crc32(buf) {
  let crc = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    crc ^= buf[i];
    for (let j = 0; j < 8; j++) {
      crc = (crc >>> 1) ^ (crc & 1 ? 0xedb88320 : 0);
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}

function clamp(v) {
  return Math.max(0, Math.min(255, Math.round(v)));
}

function mix(a, b, t) {
  return a + (b - a) * t;
}

function roundedBoxSDF(px, py, cx, cy, halfW, halfH, r) {
  const qx = Math.abs(px - cx) - (halfW - r);
  const qy = Math.abs(py - cy) - (halfH - r);
  const outDist = Math.hypot(Math.max(qx, 0), Math.max(qy, 0));
  const inDist = Math.min(Math.max(qx, qy), 0);
  return outDist + inDist - r;
}

const raw = Buffer.alloc((SIZE * 4 + 1) * SIZE);

for (let y = 0; y < SIZE; y++) {
  const rowStart = y * (SIZE * 4 + 1);
  raw[rowStart] = 0;
  const ny = y / SIZE;

  for (let x = 0; x < SIZE; x++) {
    const nx = x / SIZE;
    // Sky-blue radial gradient backdrop
    const radial = Math.max(0, 1 - Math.hypot(nx - 0.5, ny - 0.45) * 1.15);
    let r = mix(10, 34, ny) + radial * 48;
    let g = mix(142, 206, ny) + radial * 42;
    let b = mix(252, 250, ny);

    // Subtle paper grid pattern
    if ((x % 128 < 6 && y % 128 < 6)) {
      r = mix(r, 255, 0.2);
      g = mix(g, 255, 0.2);
      b = mix(b, 255, 0.2);
    }

    // Ribbon trail curving into the character block
    const trailDist = Math.abs(y - (610 + Math.sin((x - 220) * 0.011) * 90));
    if (x >= 130 && x <= 560 && trailDist < 72) {
      const edge = Math.max(0, Math.min(1, (72 - trailDist) / 4));
      r = mix(r, 255, edge * 0.88);
      g = mix(g, 130, edge * 0.88);
      b = mix(b, 168, edge * 0.88);
    }

    // Drop shadow under block
    const shadowD = roundedBoxSDF(x, y, 560, 505, 225, 225, 68);
    if (shadowD < 28) {
      const a = Math.max(0, Math.min(1, (28 - shadowD) / 28)) * 0.26;
      r = mix(r, 8, a);
      g = mix(g, 24, a);
      b = mix(b, 78, a);
    }

    // 2.5D darker base bevel
    const bevelD = roundedBoxSDF(x, y, 545, 495, 220, 220, 66);
    if (bevelD < 0) {
      r = 196;
      g = 18;
      b = 76;
    }

    // Main vibrant coral-red block face
    const faceD = roundedBoxSDF(x, y, 545, 455, 220, 215, 66);
    if (faceD < 0) {
      r = 255;
      g = 46;
      b = 112;
      // Top glossy highlight
      if (y < 330) {
        const hi = (330 - y) / 90;
        r = mix(r, 255, hi * 0.28);
        g = mix(g, 150, hi * 0.28);
        b = mix(b, 185, hi * 0.28);
      }
    }

    // Cute directional eyes
    const leftEyeD = roundedBoxSDF(x, y, 475, 445, 38, 48, 22);
    const rightEyeD = roundedBoxSDF(x, y, 615, 445, 38, 48, 22);
    if (leftEyeD < 0 || rightEyeD < 0) {
      r = 255;
      g = 255;
      b = 255;
    }

    const leftPupilD = roundedBoxSDF(x, y, 488, 448, 19, 25, 11);
    const rightPupilD = roundedBoxSDF(x, y, 628, 448, 19, 25, 11);
    if (leftPupilD < 0 || rightPupilD < 0) {
      r = 12;
      g = 26;
      b = 92;
    }

    const px = rowStart + 1 + x * 4;
    raw[px] = clamp(r);
    raw[px + 1] = clamp(g);
    raw[px + 2] = clamp(b);
    raw[px + 3] = 255;
  }
}

const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(SIZE, 0);
ihdr.writeUInt32BE(SIZE, 4);
ihdr[8] = 8; // bit depth
ihdr[9] = 6; // RGBA
ihdr[10] = 0;
ihdr[11] = 0;
ihdr[12] = 0;

const idat = zlib.deflateSync(raw, { level: 9 });
const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const png = Buffer.concat([
  signature,
  pngChunk('IHDR', ihdr),
  pngChunk('IDAT', idat),
  pngChunk('IEND', Buffer.alloc(0))
]);

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, png);
console.log(`Generated ${outPath} (${png.length} bytes)`);
