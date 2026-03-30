// SAM inference wrapper for Flutter Web using onnxruntime-web
// Exposes window.SAM with init() and run() methods
// - init(): loads encoder/decoder ONNX models
// - run(): runs encoder and decoder given a preprocessed 1x3x1024x1024 Float32Array input and a single-point prompt
//
// Quality improvements over baseline:
// - Returns sigmoid-quantized logits (0..255) instead of binary 0/1
// - Selects the best mask from multi-mask output via IoU scores
// - Caches encoder embeddings to avoid redundant encoder runs
// - Performs automatic iterative refinement (re-runs decoder with previous mask)

(function(){
  const W = 1024;
  const H = 1024;
  const LOWRES = 256;

  const defaultEncoderUrl = 'assets/assets/models_sam/mobile_sam.encoder.onnx';
  const defaultDecoderUrl = 'assets/assets/models_sam/mobile_sam.decoder.onnx';

  let encoderSession = null;
  let decoderSession = null;

  // Encoder embedding cache: avoids re-running the encoder for the same image
  let cachedEmbedding = null;
  let cachedInputHash = null;

  function pickByHint(names, hints) {
    const lower = names.map(n => n.toLowerCase());
    for (let i = 0; i < lower.length; i++) {
      const n = lower[i];
      let ok = true;
      for (const h of hints) {
        if (!n.includes(h)) { ok = false; break; }
      }
      if (ok) return names[i];
    }
    return null;
  }

  function computeInputHash(inputNCHWFloat32) {
    // Fast hash: sample ~256 evenly spaced values and combine
    const len = inputNCHWFloat32.length;
    const step = Math.max(1, Math.floor(len / 256));
    let h = 0;
    for (let i = 0; i < len; i += step) {
      const bits = inputNCHWFloat32[i];
      h = (h * 31 + (bits * 1000000 | 0)) | 0;
    }
    return h;
  }

  async function init(encoderUrl, decoderUrl) {
    if (!window.ort) {
      console.error('onnxruntime-web (ort) is not loaded.');
      return false;
    }
    const ep = ['wasm'];
    encoderSession = await ort.InferenceSession.create(encoderUrl || defaultEncoderUrl, { executionProviders: ep });
    decoderSession = await ort.InferenceSession.create(decoderUrl || defaultDecoderUrl, { executionProviders: ep });
    cachedEmbedding = null;
    cachedInputHash = null;
    return true;
  }

  function findOutputByDims(results, names, targetLastTwo) {
    for (const name of names) {
      const tensor = results[name];
      if (!tensor || !tensor.dims) continue;
      const d = tensor.dims;
      if (d.length >= 2 && d[d.length - 1] === targetLastTwo && d[d.length - 2] === targetLastTwo) {
        return { name, tensor };
      }
    }
    return null;
  }

  function sigmoid(x) {
    if (x >= 0) {
      return 1.0 / (1.0 + Math.exp(-x));
    }
    const ex = Math.exp(x);
    return ex / (1.0 + ex);
  }

  function runDecoder(imageEmbeddings, tapX, tapY, origW, origH, maskInput, hasMask) {
    const din = decoderSession.inputNames;
    const imageEmbName = pickByHint(din, ['embed']) || 'image_embeddings';
    const pCoordsName = pickByHint(din, ['point', 'coord']) || 'point_coords';
    const pLabelsName = pickByHint(din, ['point', 'label']) || 'point_labels';
    const maskInName   = pickByHint(din, ['mask', 'input']) || 'mask_input';
    const hasMaskName  = pickByHint(din, ['has', 'mask'])   || 'has_mask_input';
    const origSizeName = pickByHint(din, ['orig', 'size'])  || 'orig_im_size';

    const pointCoords = new Float32Array([tapX, tapY]);
    const pointLabels = new Float32Array([1]);

    const pointCoordsTensor = new ort.Tensor('float32', pointCoords, [1, 1, 2]);
    const pointLabelsTensor = new ort.Tensor('float32', pointLabels, [1, 1]);
    const maskInputTensor = new ort.Tensor('float32', maskInput, [1, 1, LOWRES, LOWRES]);
    const hasMaskTensor = new ort.Tensor('float32', new Float32Array([hasMask ? 1 : 0]), [1]);
    const origSizeTensor = new ort.Tensor('float32', new Float32Array([origH, origW]), [1, 2]);

    const decFeeds = {};
    decFeeds[imageEmbName] = imageEmbeddings;
    decFeeds[pCoordsName] = pointCoordsTensor;
    decFeeds[pLabelsName] = pointLabelsTensor;
    decFeeds[maskInName] = maskInputTensor;
    decFeeds[hasMaskName] = hasMaskTensor;
    decFeeds[origSizeName] = origSizeTensor;

    return decoderSession.run(decFeeds);
  }

  function extractBestMask(decResults) {
    const outNames = decoderSession.outputNames;

    // Find the mask output (spatial LOWRES x LOWRES)
    let maskInfo = findOutputByDims(decResults, outNames, LOWRES);
    if (!maskInfo) {
      const fallbackName = outNames.find(n => n.toLowerCase().includes('mask')) || outNames[0];
      const tensor = decResults[fallbackName];
      if (tensor) maskInfo = { name: fallbackName, tensor };
    }
    if (!maskInfo) return null;

    const masksTensor = maskInfo.tensor;
    const data = masksTensor.data;
    const dims = masksTensor.dims || [];
    const plane = LOWRES * LOWRES;

    // Find IoU scores output to select the best mask
    let iouData = null;
    for (const name of outNames) {
      if (name === maskInfo.name) continue;
      const t = decResults[name];
      if (!t || !t.dims) continue;
      const d = t.dims;
      const totalElems = d.reduce((a, b) => a * b, 1);
      if (totalElems >= 2 && totalElems <= 8) {
        iouData = { data: t.data, count: totalElems };
        break;
      }
    }

    let numMasks = 1;
    if (dims.length === 4) {
      numMasks = dims[1] || 1;
    } else if (dims.length === 3) {
      numMasks = dims[0] || 1;
    }

    // Select mask with highest IoU score
    let bestIdx = 0;
    if (iouData && numMasks > 1) {
      let bestScore = -Infinity;
      const maxCheck = Math.min(numMasks, iouData.count);
      for (let i = 0; i < maxCheck; i++) {
        if (iouData.data[i] > bestScore) {
          bestScore = iouData.data[i];
          bestIdx = i;
        }
      }
    }

    const offset = bestIdx * plane;
    const logits = data.subarray(offset, offset + plane);

    return { logits, lowResLogits: data.subarray(offset, offset + plane) };
  }

  async function run(inputNCHWFloat32, origW, origH, tapX1024, tapY1024) {
    if (!encoderSession || !decoderSession) throw new Error('SAM not initialized');

    // Check encoder embedding cache
    const inputHash = computeInputHash(inputNCHWFloat32);
    let imageEmbeddings;

    if (cachedEmbedding && cachedInputHash === inputHash) {
      imageEmbeddings = cachedEmbedding;
    } else {
      const encInName = encoderSession.inputNames[0];
      const encOutName = encoderSession.outputNames[0];
      const imageTensor = new ort.Tensor('float32', inputNCHWFloat32, [1, 3, H, W]);
      const encFeeds = {};
      encFeeds[encInName] = imageTensor;
      const encResults = await encoderSession.run(encFeeds);
      imageEmbeddings = encResults[encOutName];
      cachedEmbedding = imageEmbeddings;
      cachedInputHash = inputHash;
    }

    // --- Pass 1: initial decode with no prior mask ---
    const emptyMask = new Float32Array(LOWRES * LOWRES);
    const decResults1 = await runDecoder(imageEmbeddings, tapX1024, tapY1024, origW, origH, emptyMask, false);
    const best1 = extractBestMask(decResults1);
    if (!best1) return null;

    // --- Pass 2: iterative refinement using pass-1 logits as mask_input ---
    const decResults2 = await runDecoder(imageEmbeddings, tapX1024, tapY1024, origW, origH, best1.lowResLogits, true);
    const best2 = extractBestMask(decResults2);
    const finalLogits = best2 ? best2.logits : best1.logits;

    // Convert logits to sigmoid-quantized 0..255 values (preserving confidence info)
    const size = LOWRES * LOWRES;
    const quantized = new Uint8Array(size);
    for (let i = 0; i < size; i++) {
      quantized[i] = Math.round(sigmoid(finalLogits[i]) * 255);
    }

    return quantized;
  }

  window.SAM = { init, run };
})();
