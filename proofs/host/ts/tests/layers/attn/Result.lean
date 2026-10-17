import host.ts.tests.layers.attn.Run
namespace Host.Ts.Tests.Layers.AttnLayer
open Host.Ts

/-! What the attention-layer run computes, read from its final state (8
chunks, `P.result`), and its transfer to concrete offsets (`run_sim`). -/

/-- The run from the boot with the chain's fuel. -/
noncomputable def symRun : Option (St Host.Mlx.Ffi.St × SSrv) := boot0.bind fun s => runS Host.Mlx.Ffi.ffi 80000 s ⟨[.var 0], P.O⟩

theorem symRun_eq : symRun = some (P.s8, P.S8) := P.result 80000 (by decide)

/-- Output shape, dtype code and the new cache offset (through the number table). -/
noncomputable def summary (r : Option (St Host.Mlx.Ffi.St × SSrv)) : Option (List Nat × Nat × SymE × Nat) :=
  r.bind fun (s, S) => (bindingOf s (entryEnv P.s0) chars!"out").bind fun out =>
    (elemOf s out 0).bind fun y => (natsOf s y).bind fun shape => (elemOf s out 1).bind fun d =>
      (natOf d).bind fun dt => (elemOf s out 2).bind fun off => (symOf S off).map fun o => (shape, dt, o, s.trace.length)

kernel_rfl final : summary (some (P.s8, P.S8)) =
  some ([1, 1, 5120], 12, .bin .add (.var 0) (.lit (F64.fin false 1 0)), 387)

/-- One attention-layer decode forward at symbolic offset `n`: output
`[1, 1, 5120]` bf16, offset `n + 1`, 387 FFI calls. -/
theorem forward : summary symRun = some ([1, 1, 5120], 12, .bin .add (.var 0) (.lit (F64.fin false 1 0)), 387) := by
  rw [symRun_eq]; exact final

/-- Every concrete offset whose test answers are the oracle's runs the same. -/
theorem forward_at (ρ : Nat → F64) (h : Good ρ P.O) :
    ∀ s' S', symRun = some (s', S') →
      ∃ C', (boot0.bind fun s => runC Host.Mlx.Ffi.ffi 80000 s ⟨[ρ 0]⟩) = some (s', C') ∧ Inst ρ S' C' :=
  fun s' S' => boot_sim Host.Mlx.Ffi.ffi ρ boot0 80000 ⟨[.var 0], P.O⟩ ⟨[ρ 0]⟩ ⟨rfl, h⟩ s' S'

end Host.Ts.Tests.Layers.AttnLayer
