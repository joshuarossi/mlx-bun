import host.ts.tests.MlxSrc
namespace Host.Ts.Tests.MlxLoad
open Host.Ts Host.Ts.Tests

def source : String := "import * as ops from \"./ops\";
export const out = 0;"
source_parse source
source_ast

def run : Option (St Mock.St × Env) :=
  runModules Mock.ffi Mock.init (mlxMods ast) [bunFfi] chars!"packages/mlx/src/__drive.ts" 10000

/-- Load phase of `ffi.ts`, `array.ts`, `ops.ts`: the FFI calls it issues. -/
theorem loads : (run.map fun (s, _) => traceSyms s) = some [chars!"mlx_set_error_handler", chars!"mlx_string_new",
    chars!"mlx_version", chars!"mlx_string_data", chars!"mlx_string_free", chars!"mlx_default_gpu_stream_new",
    chars!"mlx_default_cpu_stream_new"] := by
  decide +kernel

end Host.Ts.Tests.MlxLoad
