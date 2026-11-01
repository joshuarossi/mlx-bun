import host.route.GpuMem
import host.sim.compose.PostCut
import host.sim.template.a4pre_pl_t2p.H0
import host.sim.template.a4pre_pl_t1.H0
import host.sim.template.a4pre_pl_t1_eos.H0
import host.sim.template.a4pre_pl_ta.H0
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Run.Tpl Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Mach (refPrompt)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)

/-! # POST's first readback

`PRE_pl_t2p`'s first stretch pops token 1: one token leaves the queue, so one item is new, at the image of the template's
carrier, holding the table's symbol the machine's readback fixes. `hpop`: the reference held across it. -/

kernel_rfl t2p_tokens0 : (mlxOf PRE_pl_t2p.s0.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl t2p_tokens1 : (mlxOf PRE_pl_t2p.s1.ffi).tokens = [.ref 2]
kernel_rfl t2p_item1 : (mlxOf PRE_pl_t2p.s1.ffi).items.get 17776 = some (.ref 1)
kernel_rfl t2p_item0 : (mlxOf PRE_pl_t2p.s0.ffi).items.get 17776 = none
kernel_rfl t2p_node0 : ((mlxOf PRE_pl_t2p.s0.ffi).nodes.get 17776).isSome = true
kernel_rfl t2p_node1 : ((mlxOf PRE_pl_t2p.s1.ffi).nodes.get 17776).isSome = true
kernel_rfl t2p_tab1 : nth? PRE_pl_t2p.S0.tab 1 = some (.var 1)

/-- One token left the queue: one new item, holding it. -/
theorem pop_one {x y : Ffi.St} (hg : Ffi.NGrow x y) {a : NumV} {l : List NumV} (hx : x.tokens = a :: l)
    (hl : l.length = y.tokens.length) : ∃ k, x.items.get k = none ∧ y.items = x.items.set k a := by
  obtain ⟨ps, he, hp⟩ := hg.pops
  rw [hx] at he
  have hlen := congrArg List.length he
  simp only [List.length_cons, List.length_append, List.length_map, hl] at hlen
  obtain ⟨p, rfl⟩ : ∃ p, ps = [p] := List.length_eq_one_iff.mp (by omega)
  simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, List.cons.injEq] at he
  obtain ⟨k, v⟩ := p
  obtain ⟨hv, -⟩ := he
  dsimp only at hv
  subst hv
  exact ⟨k, hp.1, hp.2⟩

kernel_rfl hpopT1_t0 : (mlxOf PRE_pl_t1.s0.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl hpopT1_t1 : (mlxOf PRE_pl_t1.s2.ffi).tokens = [.ref 2]
kernel_rfl hpopT1_i1 : (mlxOf PRE_pl_t1.s2.ffi).items.get 17776 = some (.ref 1)
kernel_rfl hpopT1_i0 : (mlxOf PRE_pl_t1.s0.ffi).items.get 17776 = none
kernel_rfl hpopT1_n0 : ((mlxOf PRE_pl_t1.s0.ffi).nodes.get 17776).isSome = true
kernel_rfl hpopT1_n1 : ((mlxOf PRE_pl_t1.s2.ffi).nodes.get 17776).isSome = true
kernel_rfl hpopT1_tb : nth? PRE_pl_t1.S0.tab 1 = some (.var 1)

kernel_rfl hpopT1Eos_t0 : (mlxOf PRE_pl_t1_eos.s0.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl hpopT1Eos_t1 : (mlxOf PRE_pl_t1_eos.s2.ffi).tokens = [.ref 2]
kernel_rfl hpopT1Eos_i1 : (mlxOf PRE_pl_t1_eos.s2.ffi).items.get 17776 = some (.ref 1)
kernel_rfl hpopT1Eos_i0 : (mlxOf PRE_pl_t1_eos.s0.ffi).items.get 17776 = none
kernel_rfl hpopT1Eos_n0 : ((mlxOf PRE_pl_t1_eos.s0.ffi).nodes.get 17776).isSome = true
kernel_rfl hpopT1Eos_n1 : ((mlxOf PRE_pl_t1_eos.s2.ffi).nodes.get 17776).isSome = true
kernel_rfl hpopT1Eos_tb : nth? PRE_pl_t1_eos.S0.tab 1 = some (.var 1)

kernel_rfl hpopTa_t0 : (mlxOf PRE_pl_ta.s0.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl hpopTa_t1 : (mlxOf PRE_pl_ta.s6.ffi).tokens = [.ref 2]
kernel_rfl hpopTa_i1 : (mlxOf PRE_pl_ta.s6.ffi).items.get 17776 = some (.ref 1)
kernel_rfl hpopTa_i0 : (mlxOf PRE_pl_ta.s0.ffi).items.get 17776 = none
kernel_rfl hpopTa_n0 : ((mlxOf PRE_pl_ta.s0.ffi).nodes.get 17776).isSome = true
kernel_rfl hpopTa_n1 : ((mlxOf PRE_pl_ta.s6.ffi).nodes.get 17776).isSome = true
kernel_rfl hpopTa_tb : nth? PRE_pl_ta.S0.tab 1 = some (.var 1)

variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat}

/-- **A stretch popping the first token keeps the reference held**, the carrier of time `L` being the template's. -/
theorem popAt {NB T cap nI : Nat} {tk : Nat → Nat} {sa sb : St FF.S} {Sa Sb : SSrv} (hT : 1 ≤ T)
    (t0 : (mlxOf sa.ffi).tokens = [.ref 1, .ref 2]) (t1 : (mlxOf sb.ffi).tokens = [.ref 2])
    (i1 : (mlxOf sb.ffi).items.get 17776 = some (.ref 1)) (i0 : (mlxOf sa.ffi).items.get 17776 = none)
    (n0 : ((mlxOf sa.ffi).nodes.get 17776).isSome = true) (n1 : ((mlxOf sb.ffi).nodes.get 17776).isSome = true)
    (tb : nth? Sa.tab 1 = some (.var 1))
    (htkR : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) (toks : Nat → Nat → Nat) (htoks : toks π.length 0 = 17776)
    (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat) (x y : SegInst FF)
    (hx : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π sa Sa).R x sa ⟨Sa.tab, []⟩)
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π sb Sb).R y sb ⟨Sb.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (hm : memPost P KR NE net env π 0 toks Cr L x) :
    memPost P KR NE net env π 0 toks Cr L y := by
  intro hL
  subst hL
  obtain ⟨kind, hp⟩ := hm rfl
  obtain ⟨_, hrx, hbx⟩ := hx
  obtain ⟨_, hry, -⟩ := hy
  obtain ⟨Px, hPx, rx⟩ := hrx.ffi.1
  obtain ⟨Py, hPy, ry⟩ := hry.ffi.1
  have mx := rx.load.mlx
  have my := ry.load.mlx
  have hrest : Py.rest = Px.rest := by
    rcases hPx with rfl | ⟨k, -, -, rfl⟩ <;> rcases hPy with rfl | ⟨k', -, -, rfl⟩ <;> rfl
  have tx : (mlxOf x.t.ffi).tokens = x.M.nv (.ref 1) :: (x.M.nv (.ref 2) :: Px.rest) := by
    have h : (mlxOf x.t.ffi).tokens = (mlxOf sa.ffi).tokens.map x.M.nv ++ Px.rest := mx.tokensX
    rw [t0] at h
    exact h
  have ty : (mlxOf y.t.ffi).tokens = y.M.nv (.ref 2) :: Px.rest := by
    have h : (mlxOf y.t.ffi).tokens = (mlxOf sb.ffi).tokens.map y.M.nv ++ Py.rest := my.tokensX
    rw [t1, hrest] at h
    exact h
  obtain ⟨k', hk0, hit⟩ := pop_one hg tx (by rw [ty]; rfl)
  refine ⟨kind, fun tab hC => ?_⟩
  have hC' := hle.trans hC
  rw [hnode]
  refine (hp tab hC').read hg (k0 := 0) (Nat.le_refl _) ?_ my.yitems
  intro k v hv
  rw [hit] at hv
  rcases PTrie.get_set_some hv with h | ⟨rfl, rfl⟩
  · exact .inl h
  · obtain ⟨hs, hR⟩ := htkR tab 0 hT
    have hyn : (mlxOf y.t.ffi).items.get (x.M.node 17776) = some (y.M.nv (.ref 1)) := by
      have h : (mlxOf y.t.ffi).items.get (y.M.node 17776) = ((mlxOf sb.ffi).items.get 17776).map y.M.nv :=
        my.items 17776 n1
      rw [i1, hnode] at h
      exact h
    have hxn : (mlxOf x.t.ffi).items.get (x.M.node 17776) = none := by
      have h : (mlxOf x.t.ffi).items.get (x.M.node 17776) = ((mlxOf sa.ffi).items.get 17776).map x.M.nv :=
        mx.items 17776 n0
      rw [i0] at h
      exact h
    have hcar : k = x.M.node 17776 := by
      refine Classical.byContradiction fun hne => ?_
      rw [hit, PTrie.get_set_ne' _ _ _ _ (Ne.symm hne), hxn] at hyn
      cases hyn
    have hval : CSrv.val ⟨tab⟩ (x.M.nv (.ref 1)) = some (F64.ofNat (tk 1)) := by
      have hn : CSrv.val ⟨tab⟩ (x.M.nv (.ref 1)) = some (x.ν 1) := hC'.val (hrx.srv.num 1 (.var 1) tb)
      rw [hn]
      have hr := hbx.reserved 1 (by decide)
      exact congrArg some (hr.trans (by simp [machVal]))
    exact .inr ⟨by rw [htoks]; exact hcar, tk 1, ⟨hs, hR⟩, htk1, hval⟩

/-- **The first readback**: `PRE_pl_t2p`'s. -/
theorem hpop {NB T cap nI : Nat} {tk : Nat → Nat} (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) (toks : Nat → Nat → Nat) (htoks : toks π.length 0 = 17776)
    (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat) (x y : SegInst FF)
    (hx : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_t2p.s0 PRE_pl_t2p.S0).R x PRE_pl_t2p.s0
      ⟨PRE_pl_t2p.S0.tab, []⟩)
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_t2p.s1 PRE_pl_t2p.S1).R y PRE_pl_t2p.s1
      ⟨PRE_pl_t2p.S1.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (hm : memPost P KR NE net env π 0 toks Cr L x) :
    memPost P KR NE net env π 0 toks Cr L y :=
  popAt hT t2p_tokens0 t2p_tokens1 t2p_item1 t2p_item0 t2p_node0 t2p_node1 t2p_tab1 htkR htk1 toks htoks Cr L x y hx hy hle hnode hg hm

/-- T = 1, not EOS: `PRE_pl_t1`'s pop. -/
theorem hpopT1 {NB T cap nI : Nat} {tk : Nat → Nat} (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) (toks : Nat → Nat → Nat) (htoks : toks π.length 0 = 17776)
    (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat) (x y : SegInst FF)
    (hx : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_t1.s0 PRE_pl_t1.S0).R x PRE_pl_t1.s0 ⟨PRE_pl_t1.S0.tab, []⟩)
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_t1.s2 PRE_pl_t1.S2).R y PRE_pl_t1.s2 ⟨PRE_pl_t1.S2.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (hm : memPost P KR NE net env π 0 toks Cr L x) :
    memPost P KR NE net env π 0 toks Cr L y :=
  popAt hT hpopT1_t0 hpopT1_t1 hpopT1_i1 hpopT1_i0 hpopT1_n0 hpopT1_n1 hpopT1_tb htkR htk1 toks htoks Cr L x y hx hy hle hnode hg hm

/-- T = 1, EOS: `PRE_pl_t1_eos`'s pop. -/
theorem hpopT1Eos {NB T cap nI : Nat} {tk : Nat → Nat} (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) (toks : Nat → Nat → Nat) (htoks : toks π.length 0 = 17776)
    (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat) (x y : SegInst FF)
    (hx : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_t1_eos.s0 PRE_pl_t1_eos.S0).R x PRE_pl_t1_eos.s0 ⟨PRE_pl_t1_eos.S0.tab, []⟩)
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_t1_eos.s2 PRE_pl_t1_eos.S2).R y PRE_pl_t1_eos.s2 ⟨PRE_pl_t1_eos.S2.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (hm : memPost P KR NE net env π 0 toks Cr L x) :
    memPost P KR NE net env π 0 toks Cr L y :=
  popAt hT hpopT1Eos_t0 hpopT1Eos_t1 hpopT1Eos_i1 hpopT1Eos_i0 hpopT1Eos_n0 hpopT1Eos_n1 hpopT1Eos_tb htkR htk1 toks htoks Cr L x y hx hy hle hnode hg hm

/-- T ≥ 2, token 1 EOS: `PRE_pl_ta`'s pop. -/
theorem hpopTa {NB T cap nI : Nat} {tk : Nat → Nat} (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) (toks : Nat → Nat → Nat) (htoks : toks π.length 0 = 17776)
    (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat) (x y : SegInst FF)
    (hx : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_ta.s0 PRE_pl_ta.S0).R x PRE_pl_ta.s0 ⟨PRE_pl_ta.S0.tab, []⟩)
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_ta.s6 PRE_pl_ta.S6).R y PRE_pl_ta.s6 ⟨PRE_pl_ta.S6.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (hm : memPost P KR NE net env π 0 toks Cr L x) :
    memPost P KR NE net env π 0 toks Cr L y :=
  popAt hT hpopTa_t0 hpopTa_t1 hpopTa_i1 hpopTa_i0 hpopTa_n0 hpopTa_n1 hpopTa_tb htkR htk1 toks htoks Cr L x y hx hy hle hnode hg hm

end Host.Route.PrefGraph
