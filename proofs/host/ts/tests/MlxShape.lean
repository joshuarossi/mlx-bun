import host.ts.tests.MlxSrc
namespace Host.Ts.Tests.MlxShape
open Host.Ts Host.Ts.Tests

/-! Kernel-checked: the `packages/mlx/src` load phase, then `ops.zeros`,
`MlxArray.shape`, `outArray` and `ops.reshape` against the mock FFI. -/

def run : Option (St Mock.St × Env) :=
  runModules Mock.ffi Mock.init (mlxMods MlxDrive.ast) [bunFfi] chars!"packages/mlx/src/__drive.ts" 10000

theorem shapes : (run.bind fun (s, env) => (bindingOf s env chars!"out").bind (natss s)) = some [[2, 3, 4], [6, 4]] := by
  decide +kernel

end Host.Ts.Tests.MlxShape
