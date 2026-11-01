import host.sim.compose.PreFill
import host.sim.full.BridgeJs
import host.sim.full.TargetGrowD
import host.sim.conv.CompactBridge
import host.sim.template.Sigma
set_option Elab.async false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template

/-! # What the stretches between forwards keep

A property of the target and its node map that any stretch between forwards keeps joins a cut's
bookkeeping (`withMem`). The route's graph predicates are such properties: the pieces are generic in
them and only owe `NTrack`, the facts they read. -/

/-- A stretch's facts: the server grows, the node map stays, the native state grows, no readback. -/
structure NTrack (x y : SegInst FF) : Prop where
  server : CSrv.Le x.C y.C
  map : y.M.node = x.M.node
  nodes : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)
  tokens : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens
  /-- The emitted array keeps its address. -/
  emit : y.M.a 12504 = x.M.a 12504

theorem NTrack.refl (x : SegInst FF) : NTrack x x :=
  ⟨CSrv.Le.refl _, rfl, Host.Mlx.Ffi.NGrow.refl _, rfl, rfl⟩

theorem NTrack.trans {x y z : SegInst FF} (h : NTrack x y) (h' : NTrack y z) : NTrack x z :=
  ⟨h.server.trans h'.server, h'.map.trans h.map, h.nodes.trans h'.nodes, h'.tokens.trans h.tokens, h'.emit.trans h.emit⟩

/-- A conversion moves neither the target nor the server. -/
theorem NTrack.conv {x y : SegInst FF} (ht : y.t = x.t) (hC : y.C = x.C) (hn : y.M.node = x.M.node)
    (ha : y.M.a 12504 = x.M.a 12504) : NTrack x y where
  server := by rw [hC]; exact CSrv.Le.refl _
  map := hn
  nodes := by rw [ht]; exact Host.Mlx.Ffi.NGrow.refl _
  tokens := by rw [ht]
  emit := ha

/-- The cut with a retained property of its instance. -/
def withMem (Mem : SegInst FF → Prop) (A : ICut FF) : ICut FF :=
  { A with B := fun x => A.B x ∧ Mem x }

theorem withMem_forget (Mem : SegInst FF → Prop) (A : ICut FF) : CutConv (withMem Mem A) A :=
  fun x hr hb => ⟨x, rfl, rfl, hr, hb.1⟩

theorem withMem_true (A : ICut FF) : CutConv A (withMem (fun _ => True) A) :=
  fun x hr hb => ⟨x, rfl, rfl, hr, hb, trivial⟩

/-- Native growth pops nothing when the two relations' queues have the same length. -/
theorem tokens_of_grow {P : LoadP} {NB : Nat} {W W' : Nat → Option WFrame} {M M' : Map} {ν ν' : Nat → F64}
    {K K' : Ctx} {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Disp.FRJ (FullRXD P NB)) W' [] M' ν' K' sb Sb t' C')
    (hg : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi))
    (hs : (mlxOf sb.ffi).tokens.length = (mlxOf sa.ffi).tokens.length) :
    (mlxOf t'.ffi).tokens = (mlxOf t.ffi).tokens := by
  obtain ⟨P0, hP0, r0⟩ := hr.ffi.1
  obtain ⟨P1, hP1, r1⟩ := hr'.ffi.1
  have rest0 : P0.rest = P.rest := by rcases hP0 with rfl | ⟨_, -, -, rfl⟩ <;> rfl
  have rest1 : P1.rest = P.rest := by rcases hP1 with rfl | ⟨_, -, -, rfl⟩ <;> rfl
  have e0 : (mlxOf t.ffi).tokens = (mlxOf sa.ffi).tokens.map M.nv ++ P0.rest := r0.load.mlx.tokensX
  have e1 : (mlxOf t'.ffi).tokens = (mlxOf sb.ffi).tokens.map M'.nv ++ P1.rest := r1.load.mlx.tokensX
  obtain ⟨ps, he, -⟩ := hg.pops
  have l0 := congrArg List.length e0
  have l1 := congrArg List.length e1
  have l := congrArg List.length he
  simp only [List.length_append, List.length_map] at l0 l1 l
  rw [rest0] at l0
  rw [rest1] at l1
  have hps : ps = [] := List.eq_nil_of_length_eq_zero (by omega)
  subst hps
  rw [he]
  rfl

/-- A map with no renamed node and no dropped node fixes every node. -/
theorem nodeF_id {D : RData} (hn : D.nn0 = D.nn1) (hk : PTrie.keys D.node = []) (k : Nat) : D.nodeF k = k := by
  by_cases hle : D.nn0 ≤ k
  · simp only [RData.nodeF, RData.ble_true hle, Bool.cond_true]
    omega
  · cases hg : D.node.get k with
    | none => simp only [RData.nodeF, RData.ble_false (Nat.lt_of_not_le hle), Bool.cond_false, hg, Option.getD_none]
    | some y =>
      have := PTrie.mem_keys D.node k y hg
      rw [hk] at this
      cases this

theorem compact_node_id {n0 n1 nS : Nat} {pl : List Nat} {nr : List NumV} {big : Int → Int} {region : Nat → Nat}
    {D : RData} (hn : D.nn0 = D.nn1) (hk : PTrie.keys D.node = []) (k : Nat) :
    (Conv.Map.compact n0 n1 nS pl nr big region D.nodeF).node k = k :=
  nodeF_id hn hk k

end Host.Ts.Sim.Compose
