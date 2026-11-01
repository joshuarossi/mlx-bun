import host.route.GpuLoad
import host.route.GpuMem
import host.route.Gpu
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Ts Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Load.Run.Prompt (ldStT ldStT_mlx Ld.Yn Ld.X0)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF)

/-! # The load cut's bookkeeping

`ld_mem`: at the boot's end, the prefill's cold bookkeeping, and the emitted array at its own address (the load cut's map is the
identity). `FromLoad`: what any run keeps of the load's end, `FromLoad.queue`: with one token popped, that token's value in the target's
queue and items. -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The load entry's bookkeeping**, for every length. -/
theorem ld_mem (leaves : Leaves code env.weights) (fw : List Val) (τ : List NumV) {NB : Nat} {Pw : Host.Ts.Sim.LoadP}
    {W : Nat → Option Host.Ts.Sim.WFrame} {s0 : St FF.S} {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hb : (ldPromptCutAt NB Pw W s0 T tk π (ldStT fw τ)).B x) (L : Nat) :
    memCold P KR net env π L x ∧ x.M.a 12504 = 12504 := by
  refine ⟨fun _ kind => coldG_ld P KR net env kind leaves fw τ hb.2, ?_⟩
  have hM : x.M = Host.Ts.Sim.Map.id := hb.1.1.1
  rw [hM]
  rfl

/-- What a run keeps of the load's end: the target grew from it. -/
def FromLoad (T : Nat) (tk : Nat → Nat) (x : SegInst FF) : Prop :=
  Host.Mlx.Ffi.NGrow (Ld.Yn (machReads T tk)) (Host.Ts.Sim.Full.mlxOf x.t.ffi)

variable {T : Nat} {tk : Nat → Nat} {x y : SegInst FF}

theorem FromLoad.grow (h : FromLoad T tk x)
    (hg : Host.Mlx.Ffi.NGrow (Host.Ts.Sim.Full.mlxOf x.t.ffi) (Host.Ts.Sim.Full.mlxOf y.t.ffi)) : FromLoad T tk y :=
  Host.Mlx.Ffi.NGrow.trans h hg

/-- **The boot's end is where a run starts.** -/
theorem ld_from {NB : Nat} {Pw : Host.Ts.Sim.LoadP} {W : Nat → Option Host.Ts.Sim.WFrame} {s0 : St FF.S} {fw : List Val}
    (hb : (ldPromptCutAt NB Pw W s0 T tk π (ldStT fw (machReads T tk))).B x) : FromLoad T tk x := by
  have ht : x.t = ldStT fw (machReads T tk) := hb.2
  unfold FromLoad
  rw [ht, ldStT_mlx]
  exact Host.Mlx.Ffi.NGrow.refl _

/-- **One token popped since the load's end**: the head left is the second token's symbol, and the one item is the first's. -/
theorem FromLoad.queue (h : FromLoad T tk x) {b : NumV}
    (ht : (Host.Ts.Sim.Full.mlxOf x.t.ffi).tokens = b :: machReads T tk) :
    b = .ref 2 ∧ ∀ k v, (Host.Ts.Sim.Full.mlxOf x.t.ffi).items.get k = some v → v = .ref 1 := by
  obtain ⟨ps, he, hp⟩ := h.pops
  have h0 : (Ld.Yn (machReads T tk)).tokens = .ref 1 :: .ref 2 :: machReads T tk := rfl
  rw [h0, ht] at he
  have hlen := congrArg List.length he
  simp only [List.length_cons, List.length_append, List.length_map] at hlen
  obtain ⟨p, rfl⟩ : ∃ p, ps = [p] := List.length_eq_one_iff.mp (by omega)
  simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.cons.injEq] at he
  obtain ⟨k0, v0⟩ := p
  obtain ⟨hv, hb, -⟩ := he
  dsimp only at hv
  subst hv
  refine ⟨hb.symm, fun k v hk => ?_⟩
  have hi : (Host.Ts.Sim.Full.mlxOf x.t.ffi).items = (Ld.Yn (machReads T tk)).items.set k0 (.ref 1) := hp.2
  rw [hi] at hk
  rcases Host.Ts.PTrie.get_set_some hk with e | ⟨-, rfl⟩
  · have hn : (Ld.Yn (machReads T tk)).items.get k = Ld.X0.items.get k := rfl
    rw [hn, ld_items] at e
    cases e
  · rfl

end Host.Route.PrefGraph
