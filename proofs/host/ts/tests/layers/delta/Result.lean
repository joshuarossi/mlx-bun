import host.ts.tests.layers.delta.Run
namespace Host.Ts.Tests.Layers.DeltaLayer
open Host.Ts

/-! What the Delta-layer run computes, read from its final state (13 chunks, `P.result`). -/

noncomputable def run : Option (St Host.Mlx.Ffi.St × SSrv) := boot0.bind fun s => runS Host.Mlx.Ffi.ffi 130000 s ⟨[], []⟩

theorem run_eq : run = some (P.s13, P.S13) := P.result 130000 (by decide)

/-- The driver's `out`: first output shape and dtype, second output shape and
dtype, cache offset, conv and recurrent state shapes, recurrent dtype. -/
noncomputable def summary (r : Option (St Host.Mlx.Ffi.St × SSrv)) : Option (J × Nat) :=
  r.bind fun (s, _) => (bindingOf s (entryEnv P.s0) chars!"out").bind fun out =>
    (render s 8 out).map fun j => (j, s.trace.length)

def expected : Option (J × Nat) :=
  some (.arr [.arr [.arr [.num 1, .num 1, .num 5120], .num 12], .arr [.num 1, .num 1, .num 5120], .num 12, .num 2,
    .arr [.num 1, .num 3, .num 10240], .arr [.num 1, .num 48, .num 128, .num 128], .num 10], 942)

kernel_rfl final : summary (some (P.s13, P.S13)) = expected

/-- Two Delta-layer decode forwards from an empty cache: each output
`[1, 1, 5120]` bf16; conv state `[1, 3, 10240]`, recurrent state
`[1, 48, 128, 128]` float32; 942 FFI calls. -/
theorem forward : summary run = expected := by rw [run_eq]; exact final

end Host.Ts.Tests.Layers.DeltaLayer
