import host.sim.full.Call
import host.sim.full.SymSim
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-! # The full world's native-call simulation with symbolic shapes

`fullCallSimX`: `fullCallSimG` at the load world's simulation with the forward's operations over
symbolic shapes (`G.loadFfiCallSimX`). The symbolic decider accepts no kernel, configuration or
free call, so the observers read its accepted calls as the general relation's. -/

/-- **The accepted calls of the full world** with symbolic shapes and the bridge inactive. -/
def okCallFX (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName && !(bridgeOf x).active &&
    G.okCallSX P (toLoad x) name args && obsOk (mlxOf x) name args

/-- **The numeric premise** with the symbolic calls' references. -/
def smallFX (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  G.smallX ν S (toLoad x) name args ∧
    (isSymShape name = true → ∀ a S', interpS (Host.Load.call (toLoad x) name args).run S = some (a, S') →
      a.isSome = true)

/-- The decider of `smallFX` (irreducible, as `smallFB`). -/
@[irreducible] def smallFXB (VB : Nat → Nat) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  G.smallXB VB S (toLoad x) name args && (!isSymShape name || symRunOk S x name args)

theorem smallFXB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : smallFXB VB S x name args = true) : smallFX ν S x name args := by
  unfold smallFXB at h
  simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  refine ⟨G.smallXB_sound h.1 hν, fun hs => ?_⟩
  rcases h.2 with h2 | h2
  · rw [hs] at h2; cases h2
  · exact symRunOk_sound h2

/-- Every call the general relation accepts is accepted. -/
theorem okCallSX_of {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg}
    (h : G.okCallSG P l name args = true) : G.okCallSX P l name args = true := by
  simp only [G.okCallSX, h, Bool.true_or]

theorem okCallFX_of {P : LoadP} {x : FF.S} {name : Name} {args : List Arg}
    (h : okCallF P x name args = true) : okCallFX P x name args = true := by
  simp only [okCallF, okCallFX, Bool.and_eq_true] at h ⊢
  exact ⟨⟨h.1.1, okCallSX_of h.1.2⟩, h.2⟩

/-- A call the symbolic decider accepts and the general relation does not. -/
theorem okCallSX_cases {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg}
    (h : G.okCallSX P l name args = true) :
    G.okCallSG P l name args = true ∨
      ∃ s, Host.Mlx.Ffi.symOf name = some s ∧ G.NativeOkX.sym P l.mlx s args = true := by
  simp only [G.okCallSX, Bool.or_eq_true, Bool.and_eq_true] at h
  rcases h with h | ⟨-, h⟩
  · exact Or.inl h
  · right
    cases hs : Host.Mlx.Ffi.symOf name with
    | none => simp only [hs] at h; cases h
    | some s => simp only [hs] at h; exact ⟨s, rfl, h⟩

theorem kernAccX_of {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg}
    (h : G.okCallSX P l name args = true) : KernAcc P l.mlx name args := by
  rcases okCallSX_cases h with h | ⟨s, hs, h⟩
  · exact kernAcc_of h
  · intro s' hs'
    rw [hs] at hs'
    cases hs'
    refine ⟨fun e => ?_, fun e => ?_⟩
    · subst e; simp [G.NativeOkX.sym] at h
    · rcases e with rfl | rfl | rfl <;> simp [G.NativeOkX.sym] at h

theorem arrAccX_of {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg}
    (h : G.okCallSX P l name args = true) :
    Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk l.mlx a = true := by
  rcases okCallSX_cases h with h | ⟨s, hs, h⟩
  · exact arrAcc_of h
  · intro hs'
    rw [hs] at hs'
    cases hs'
    simp [G.NativeOkX.sym] at h

/-- **The full world's native-call simulation** with symbolic shapes and the bridge inactive. -/
theorem fullCallSimX (P : LoadP) (NB : Nat) : FfiCallSim FF (FullR P NB) (okCallFX P) smallFX :=
  fullCallSimG P NB (G.loadFfiCallSimX P NB) (fun _ _ _ => kernAccX_of) (fun _ _ _ => arrAccX_of)

theorem okCallFX_rest (P : LoadP) (r : List NumV) : okCallFX { P with rest := r } = okCallFX P := by
  funext x name args
  unfold okCallFX
  rw [G.okCallSX_rest]

end Host.Ts.Sim.Full
