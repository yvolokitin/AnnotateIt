using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;

class Program
{
    static int Main(string[] args)
    {
        string modelPath = null;

        for (int i = 0; i < args.Length - 1; i++)
            if (args[i] == "--model") modelPath = args[i + 1];

        if (string.IsNullOrWhiteSpace(modelPath) || !File.Exists(modelPath))
        {
            Console.Error.WriteLine("Usage: OrtSmoke --model <path_to_mobile_sam.encoder.onnx>");
            return 2;
        }

        try
        {
            using var opts = new SessionOptions();
            opts.LogSeverityLevel = OrtLoggingLevel.ORT_LOGGING_LEVEL_WARNING;
            opts.EnableMemoryPattern = false;
            opts.EnableCpuMemArena = true;
            opts.AppendExecutionProvider_CPU(); // CPU EP

            using var session = new InferenceSession(modelPath, opts);
            Console.WriteLine("[Info] Session created.");

            foreach (var kv in session.InputMetadata)
            {
                var name = kv.Key;
                var md = kv.Value;
                var dims = md.Dimensions.ToArray();
                Console.WriteLine($"[Input] {name}: elemType={md.ElementType}, dims=[{string.Join(",", dims)}]");
            }

            var inputName = session.InputMetadata.Keys.First();
            var shape = new[] { 1, 3, 1024, 1024 };

            var tensor = new DenseTensor<float>(shape); // zero tensor
            var inputs = new List<NamedOnnxValue> {
                NamedOnnxValue.CreateFromTensor(inputName, tensor)
            };

            Console.WriteLine("[Run] Running encoder with zero tensor...");
            using var results = session.Run(inputs);
            Console.WriteLine("[OK] Run completed.");

            foreach (var r in results)
            {
                var t = r.AsTensor<float>();
                var dims = t.Dimensions.ToArray();
                Console.WriteLine($"[Out] {r.Name}: shape=[{string.Join(",", dims)}], dtype=float32");
            }

            return 0;
        }
        catch (OnnxRuntimeException ex)
        {
            Console.Error.WriteLine("[ERR] OnnxRuntimeException:");
            Console.Error.WriteLine(ex);
            return 1;
        }
        catch (DllNotFoundException ex)
        {
            Console.Error.WriteLine("[ERR] DllNotFoundException:");
            Console.Error.WriteLine(ex);
            return 1;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine("[ERR] General Exception:");
            Console.Error.WriteLine(ex);
            return 1;
        }
    }
}
