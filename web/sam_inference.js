// Simple MobileSAM inference wrapper for Flutter Web using onnxruntime-web
// Exposes window.SAM with init() and run() methods
// - init(): loads encoder/decoder ONNX models
// - run(): runs encoder and decoder given a preprocessed 1x3x1024x1024 Float32Array input and a single-point prompt

(function(){
  const W = 1024;
  const H = 1024;
  const LOWRES = 256;

  const defaultEncoderUrl = 'assets/assets/models_sam/mobile_sam.encoder.onnx';
  const defaultDecoderUrl = 'assets/assets/models_sam/mobile_sam.decoder.onnx';

  let encoderSession = null;
  let decoderSession = null;

  function pickByHint(names, hints) {
    // Try to find a name that contains all hints (case-insensitive)
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

  async function init(encoderUrl, decoderUrl) {
    if (!window.ort) {
      console.error('onnxruntime-web (ort) is not loaded.');
      return false;
    }
    const ep = ['wasm'];
    encoderSession = await ort.InferenceSession.create(encoderUrl || defaultEncoderUrl, { executionProviders: ep });
    decoderSession = await ort.InferenceSession.create(decoderUrl || defaultDecoderUrl, { executionProviders: ep });
    return true;
  }

  async function run(inputNCHWFloat32, origW, origH, tapX1024, tapY1024) {
    if (!encoderSession || !decoderSession) throw new Error('SAM not initialized');

    // Encoder I/O names (be flexible)
    const encInName = encoderSession.inputNames[0];
    const encOutName = encoderSession.outputNames[0];
    const imageTensor = new ort.Tensor('float32', inputNCHWFloat32, [1,3,H,W]);

    const encFeeds = {};
    encFeeds[encInName] = imageTensor;
    const encResults = await encoderSession.run(encFeeds);
    const imageEmbeddings = encResults[encOutName]; // ort.Tensor

    // Decoder inputs — try to map by name hints
    const din = decoderSession.inputNames;
    const imageEmbName = pickByHint(din, ['embed']) || 'image_embeddings';
    const pCoordsName = pickByHint(din, ['point', 'coord']) || 'point_coords';
    const pLabelsName = pickByHint(din, ['point', 'label']) || 'point_labels';
    const maskInName   = pickByHint(din, ['mask', 'input']) || 'mask_input';
    const hasMaskName  = pickByHint(din, ['has', 'mask'])   || 'has_mask_input';
    const origSizeName = pickByHint(din, ['orig', 'size'])  || 'orig_im_size';

    const pointCoords = new Float32Array([tapX1024, tapY1024]);
    const pointLabels = new Float32Array([1]); // positive point

    const pointCoordsTensor = new ort.Tensor('float32', pointCoords, [1, 1, 2]);
    const pointLabelsTensor = new ort.Tensor('float32', pointLabels, [1, 1]);

    const maskInput = new Float32Array(1 * 1 * LOWRES * LOWRES); // zeros
    const maskInputTensor = new ort.Tensor('float32', maskInput, [1, 1, LOWRES, LOWRES]);

    const hasMaskInput = new Float32Array([0]);
    const hasMaskTensor = new ort.Tensor('float32', hasMaskInput, [1]);

    const origSize = new Float32Array([origH, origW]);
    const origSizeTensor = new ort.Tensor('float32', origSize, [1, 2]);

    const decFeeds = {};
    decFeeds[imageEmbName] = imageEmbeddings;
    decFeeds[pCoordsName] = pointCoordsTensor;
    decFeeds[pLabelsName] = pointLabelsTensor;
    decFeeds[maskInName] = maskInputTensor;
    decFeeds[hasMaskName] = hasMaskTensor;
    decFeeds[origSizeName] = origSizeTensor;

    const decResults = await decoderSession.run(decFeeds);
    // Try common output names, else take the first
    let outName = decoderSession.outputNames.find(n => n.toLowerCase().includes('mask')) || decoderSession.outputNames[0];
    const masksTensor = decResults[outName];
    const logits = masksTensor.data; // Float32Array size 1*1*256*256

    // Threshold to binary
    const size = LOWRES * LOWRES;
    const binary = new Uint8Array(size);
    for (let i = 0; i < size; i++) binary[i] = logits[i] > 0 ? 1 : 0;

    return binary; // length 65536, row-major
  }

  window.SAM = { init, run };
})();
