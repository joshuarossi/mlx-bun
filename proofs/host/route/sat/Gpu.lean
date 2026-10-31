import metal.Group
import host.mlx.KernelGpuPrefill

namespace Host.Route.Sat
open Inference.Contracts.Mlx Metal Core Host.Mlx

/-! # A model of the GPU assumption

`Metal.Gpu C` asks one `executeAll` to agree with every `(S, out)` the model's run determines. It is satisfiable
because `runLaunch` is one deterministic run and fuel only bounds it (`runLaunch_mono`): two successful runs of one
launch at any fuels have the same result. The model is that run itself at zero initial contents and garbage. -/

variable (C : M1Max.Contract)

/-- The launch of `text`'s kernel at zero output contents. -/
def zeroLaunch (kernel : Core.Kernel) (grid tg : Nat × Nat × Nat) (inputs : List Buffer) (sizes : List Nat) : Launch :=
  ⟨kernel, grid, tg, buffers inputs sizes 16 fun _ _ => 0⟩

def zeroGarbage : Garbage := ⟨fun _ _ _ => 0, fun _ _ _ => 0⟩

/-- Two successful runs of a launch have the same result, at any fuels. -/
theorem runLaunch_unique (fuse : Nat → Bool) (L : Launch) (g : Garbage) {f r b f' r' b' : Nat} {x y : Result}
    (hx : runLaunch C fuse L g f r b = some x) (hy : runLaunch C fuse L g f' r' b' = some y) : x = y := by
  have h1 := runLaunch_mono C fuse L g (Nat.le_max_left f f') (Nat.le_max_left r r') (Nat.le_max_left b b') hx
  have h2 := runLaunch_mono C fuse L g (Nat.le_max_right f f') (Nat.le_max_right r r') (Nat.le_max_right b b') hy
  rw [h1] at h2
  exact Option.some.inj h2

open Classical in
/-- Every buffer's contents after the model's run, when it has one. -/
noncomputable def modelExecute (text : List Char) (grid tg : Nat × Nat × Nat) (inputs : List Buffer)
    (sizes : List Nat) : Option (List ByteMemory.Bytes) :=
  match compile text with
  | none => none
  | some kernel =>
    if h : ∃ f r b x, runLaunch C (fun _ => false) (zeroLaunch kernel grid tg inputs sizes) zeroGarbage f r b = some x then
      some ((List.range (inputs.length + sizes.length)).map (final h.choose_spec.choose_spec.choose_spec.choose inputs sizes))
    else none

/-- **A model of the GPU assumption**, every contraction site unfused and every pipeline allowing 1024 threads. -/
noncomputable def gpuModel : Gpu C where
  executeAll := modelExecute C
  maxThreads := fun _ => 1024
  fusion := fun _ _ => false
  runs_as_modeled := by
    intro text kernel grid tg inputs sizes S out hc _ hrun
    obtain ⟨f, r, b, x, hx, -, hout⟩ := hrun (fun _ _ => 0) zeroGarbage
    have hx' : runLaunch C (fun _ => false) (zeroLaunch kernel grid tg inputs sizes) zeroGarbage f r b = some x := hx
    have hex : ∃ f r b x, runLaunch C (fun _ => false) (zeroLaunch kernel grid tg inputs sizes) zeroGarbage f r b = some x :=
      ⟨f, r, b, x, hx'⟩
    refine ⟨(List.range (inputs.length + sizes.length)).map
      (final hex.choose_spec.choose_spec.choose_spec.choose inputs sizes), ?_, by simp, ?_⟩
    · simp only [modelExecute, hc]; exact dite_eq_left hex
    · intro i hi hS
      have hchosen := hex.choose_spec.choose_spec.choose_spec.choose_spec
      have heq := runLaunch_unique C _ _ _ hchosen hx'
      simp only [List.getElem_map, List.getElem_range, heq]
      exact hout i hS

theorem gpuModel_maxThreads (text : List Char) : (gpuModel C).maxThreads text = 1024 := rfl

/-- The pipelines' limits at the model: each route text's threads per threadgroup is at most 1024, the real
pipelines' limit (`M1Max.Pipelines`). -/
theorem gpuModel_pipelines : KernelGpu.RoutePipelines (gpuModel C) := by
  constructor <;> (intros; show _ ≤ 1024; decide)

/-- The `setBytes` alignment. -/
def setBytesModel : KernelGpu.SetBytes := ⟨4, Nat.dvd_refl 4⟩

end Host.Route.Sat
