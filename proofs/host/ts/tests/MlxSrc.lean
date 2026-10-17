import host.ts.ast.mlx.Ffi
import host.ts.ast.mlx.Array
import host.ts.ast.mlx.Ops
import host.ts.Mock

/-! Stand-ins for the three `packages/mlx/src` files the route imports but
does not execute on the decode path (`native.ts`: library path and version;
`command-buffers.ts`: Metal environment setup; `host-buffer.ts`: restore
buffers), and the measurement drivers. -/

namespace Host.Ts.Tests.MlxNative
def source : String := "export const MLX_CORE_VERSION = \"0.32.2\";
export function resolveLibmlxc() { return \"/opt/libmlxc.dylib\"; }"
source_parse source
source_ast
end Host.Ts.Tests.MlxNative

namespace Host.Ts.Tests.MlxCommandBuffers
def source : String := "export function applyCommandBufferLimits() {}"
source_parse source
source_ast
end Host.Ts.Tests.MlxCommandBuffers

namespace Host.Ts.Tests.MlxHostBuffer
def source : String := "export const hostBufferDestructor = 4096;
export class HostBuffer {}"
source_parse source
source_ast
end Host.Ts.Tests.MlxHostBuffer

namespace Host.Ts.Tests.MlxDrive
/-- `MlxArray.shape`, `outArray` and `ops.reshape` on a mock array. -/
def source : String := "import * as ops from \"./ops\";
const a = ops.zeros([2, 3, 4], 10);
const s0 = a.shape;
const b = ops.reshape(a, [6, 4]);
export const out = [s0, b.shape];"
source_parse source
source_ast
end Host.Ts.Tests.MlxDrive

namespace Host.Ts.Tests
open Host.Ts

def mlxMods (drive : Module) : List UMod :=
  [⟨chars!"packages/mlx/src/ffi.ts", Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/native.ts", MlxNative.ast⟩,
   ⟨chars!"packages/mlx/src/command-buffers.ts", MlxCommandBuffers.ast⟩,
   ⟨chars!"packages/mlx/src/host-buffer.ts", MlxHostBuffer.ast⟩,
   ⟨chars!"packages/mlx/src/__drive.ts", drive⟩]

def mlxBoot (drive : Module) : Option (St Mock.St) :=
  boot Mock.init (mlxMods drive) [bunFfi] chars!"packages/mlx/src/__drive.ts"

end Host.Ts.Tests
