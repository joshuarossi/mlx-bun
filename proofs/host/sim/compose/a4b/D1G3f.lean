import host.sim.compose.PostGlue
import host.sim.compose.a4b.PLD1
import host.sim.compose.PfLink
import host.sim.conv.Decanon
import host.sim.compose.a4b.D1BodyFill
import host.sim.template.a4pre_pl_head.Origin
import host.sim.template.a4pre_pl_head.Run
import host.sim.template.a4pre_pl_head.Good
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

private theorem θat {j : Nat} {c : F64} {ν : Nat → F64} (h9 : ν 9 = F64.ofNat 1)
    (h : (fun ν : Nat → F64 => (PLD1.θ j).eval (upd ν 9 (F64.ofNat 1))) = fun _ => c) :
    Shift.valuation PLD1.θ ν j = c := by
  have e : (PLD1.θ j).eval (upd ν 9 (F64.ofNat 1)) = c := congrFun h ν
  rw [← h9] at e
  have hs : upd ν 9 (ν 9) = ν := by
    funext k
    by_cases hk : k = 9
    · subst hk
      exact upd_self _ _ _
    · exact upd_other _ _ hk
  rw [hs] at e
  exact e

kernel_rfl θ10 : (fun ν : Nat → F64 => (PLD1.θ 10).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 1
kernel_rfl θ11 : (fun ν : Nat → F64 => (PLD1.θ 11).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 1
kernel_rfl θ16 : (fun ν : Nat → F64 => (PLD1.θ 16).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 256
kernel_rfl θ21 : (fun ν : Nat → F64 => (PLD1.θ 21).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 4
kernel_rfl θ22 : (fun ν : Nat → F64 => (PLD1.θ 22).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 4
kernel_rfl θ24 : (fun ν : Nat → F64 => (PLD1.θ 24).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 4
kernel_rfl θ26 : (fun ν : Nat → F64 => (PLD1.θ 26).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 1
kernel_rfl θ40 : (fun ν : Nat → F64 => (PLD1.θ 40).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 1
kernel_rfl θ41 : (fun ν : Nat → F64 => (PLD1.θ 41).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 1
kernel_rfl θ42 : (fun ν : Nat → F64 => (PLD1.θ 42).eval (upd ν 9 (F64.ofNat 1))) = fun _ => F64.ofNat 1
kernel_rfl θ14 : PLD1.θ 14 = .var 17
kernel_rfl θKeys : (PLWalkD1.R.theta ++ PLD1.thetaX).map Prod.fst = [10, 11, 14, 16, 21, 22, 24, 26, 40, 41, 42]
kernel_rfl anchorA : PLWalkD1.R.data.a 2590 = 2590
kernel_rfl anchorB : PLWalkD1.R.data.a 2586 = 2586
kernel_rfl anchorC : PLWalkD1.R.data.a 2589 = 2589
kernel_rfl anchorE : PLWalkD1.R.data.a 12504 = 12504
kernel_rfl inputNode : PLWalkD1.R.data.nodeF 15235 = 15235
kernel_rfl sameNext : D1Body.s155.next = PRE_pl_entry.s0.next
kernel_rfl sameHandles : (mlxOf D1Body.s155.ffi).next = (mlxOf PRE_pl_entry.s0.ffi).next
kernel_rfl sameNodes : (mlxOf D1Body.s155.ffi).nnext = (mlxOf PRE_pl_entry.s0.ffi).nnext
kernel_rfl walkNN : PLWalkD1.R.data.nn0 = PLWalkD1.R.data.nn1
kernel_rfl walkNK : PTrie.keys PLWalkD1.R.data.node = []
kernel_rfl nodesBelow : Nat.ble (mlxOf D1Body.s155.ffi).nnext PLD1.P0.NL = true

/-- The variables the entry binds, at the singleton's row. -/
private theorem entryValuation {ν : Nat → F64} (hv : VBOkF loopVB ν) (h9 : ν 9 = F64.ofNat 1) :
    VBOkF loopVB (Shift.valuation PLD1.θ ν) := by
  intro j
  change ∃ k ≤ 2 ^ 20, Shift.valuation PLD1.θ ν j = F64.ofNat k
  by_cases hj : j ∈ [10, 11, 14, 16, 21, 22, 24, 26, 40, 41, 42]
  · simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
    rcases hj with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact ⟨1, by decide, θat h9 θ10⟩
    · exact ⟨1, by decide, θat h9 θ11⟩
    · have h17 := hv 17
      change ∃ k ≤ 2 ^ 20, ν 17 = F64.ofNat k at h17
      obtain ⟨k, hk, he⟩ := h17
      refine ⟨k, hk, ?_⟩
      change (PLD1.θ 14).eval ν = _
      rw [θ14]
      exact he
    · exact ⟨256, by decide, θat h9 θ16⟩
    · exact ⟨4, by decide, θat h9 θ21⟩
    · exact ⟨4, by decide, θat h9 θ22⟩
    · exact ⟨4, by decide, θat h9 θ24⟩
    · exact ⟨1, by decide, θat h9 θ26⟩
    · exact ⟨1, by decide, θat h9 θ40⟩
    · exact ⟨1, by decide, θat h9 θ41⟩
    · exact ⟨1, by decide, θat h9 θ42⟩
  · have hθ : PLD1.θ j = .var j := Pf.thetaOf_off (by rw [θKeys]; exact hj)
    have h := hv j
    change ∃ k ≤ 2 ^ 20, ν j = F64.ofNat k at h
    obtain ⟨k, hk, he⟩ := h
    refine ⟨k, hk, ?_⟩
    change (PLD1.θ j).eval ν = _
    rw [hθ]
    exact he

/-- **The singleton's return at the L-general POST entry.** -/
theorem toEntry (NB T : Nat) (tk : Nat → Nat) {ρ : List Nat} (hρ : ∀ k ∈ ρ, k < 248320) {cap : Nat}
    (hcap : 4096 ≤ cap) {Mem : SegInst FF → Prop} (hMem : ∀ x y, NTrack x y → Mem x → Mem y) :
    CutConv (withMem Mem (returnedPromptCut NB T tk ρ))
      (withMem Mem (Post.indexedCut NB T tk cap 15235 ρ PRE_pl_entry.s0 PRE_pl_entry.S0)) := by
  rintro x ⟨π, K0, hr, hb, hip, hv, hem⟩ ⟨⟨⟨hf, hc⟩, hp⟩, hm⟩
  obtain ⟨origin, hfb, _⟩ := hb
  have hP0 := SetupD1PromptIdentity.forward_prompt hfb
  have hP : x.K.fr 2665 = some ([], π.map natV) := hP0
  have e : ρ = π := (SetupDrop.promptEq hfb.vocab hρ hP hp).symm
  subst e
  have hctx := hfb.context
  have hfrK : ∀ a, x.K.fr a ≠ none ↔ a ∈ 2665 :: [D1Frames.chunk, D1Frames.buffer, D1Frames.view] := hctx.1.2.2
  have hlo : x.K.lo = 18151 := hctx.1.1
  have hhi : x.K.hi = 131072 := hctx.1.2.1
  have hDK : x.K.D ≤ 4096 := hctx.2
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf D1Body.s155.ffi).nnext).NL ≤ PLD1.P0.NL := by
    change (mlxOf D1Body.s155.ffi).nnext ≤ PLD1.P0.NL
    exact Nat.le_of_ble_eq_true nodesBelow
  have hNB : NB ≤ PLD1.P0.NL := Nat.le_trans top.1.load.mlx.nbl hNL
  have hsame : D1Body.s155.next - PRE_pl_entry.s0.next = 0 := by rw [sameNext]; omega
  have hD : x.K.D + (D1Body.s155.next - PRE_pl_entry.s0.next) < Sim.bound := by
    rw [hsame]
    simp only [Sim.bound]
    omega
  have h9 : x.ν 9 = F64.ofNat 1 := hfb.singleton
  have hrelV := Pf.pfRel PLD1.facts (π := ρ) hr hfrK hlo hhi hP
    (Pf.linkRoomSame hr sameHandles sameNodes) hNB hD
  have hdef : ∀ j v e, nth? PLD1.renV j = some v → nth? PLD1.renE j = some e →
      Shift.valuation PLD1.θ x.ν v = e.eval (Shift.valuation PLD1.θ x.ν) := by
    intro j v e hv he
    match j, hv, he with
    | 0, hv, he =>
      obtain rfl : 40 = v := Option.some.inj hv
      obtain rfl : SymE.var 11 = e := Option.some.inj he
      exact (θat h9 θ40).trans (θat h9 θ11).symm
    | 1, hv, he =>
      obtain rfl : 41 = v := Option.some.inj hv
      obtain rfl : SymE.var 11 = e := Option.some.inj he
      exact (θat h9 θ41).trans (θat h9 θ11).symm
    | 2, hv, he =>
      obtain rfl : 42 = v := Option.some.inj hv
      obtain rfl : SymE.var 11 = e := Option.some.inj he
      exact (θat h9 θ42).trans (θat h9 θ11).symm
    | j + 3, hv, _ => cases hv
  have hrel := Host.Ts.Sim.RelB.decanon hrelV hdef
  change RelB FF _ _ [] _ _ _ _ ⟨PLD1.tabV.map (·.subst (Conv.compactθ PLD1.renV PLD1.renE)), []⟩ _ _ at hrel
  rw [PLD1.tabEq] at hrel
  have hlen : ρ.length = 1 := hfb.length
  have hoff : x.t.next = D1Body.s155.next + x.K.D := hr.offset
  let y : SegInst FF := ⟨((x.M.after PLWalkD1.R.data.map).rebig (mlxOf PRE_pl_entry.s0.ffi).next setupP.E
      (mlxOf x.t.ffi).next).withJs, Shift.valuation PLD1.θ x.ν,
    ⟨dropNext x.M x.K Pf.keepP noFrames D1Body.s155, PRE_pl_entry.s0.trace, x.t.trace, x.t.next - PRE_pl_entry.s0.next,
      x.K.lo, x.K.hi⟩, x.t, x.C⟩
  have hfrY : ∀ a, y.K.fr a = if a = 2665 then x.K.fr 2665 else none := Pf.drop_prompt PLD1.facts x.M x.K
  have hnode : y.M.node = x.M.node := funext fun k => congrArg x.M.node (nodeF_id walkNN walkNK k)
  refine ⟨y, rfl, rfl, ⟨ρ, hrel, ?_⟩, ⟨hf, ?_⟩, hMem x y (NTrack.conv rfl rfl hnode (by change x.M.a (PLWalkD1.R.data.a 12504) = _; rw [anchorE])) hm⟩
  · refine
      { nonempty := by omega
        vocab := hfb.vocab
        lastRows := by rw [hlen]; simp
        rowsLength := hlen
        rowsVocab := hfb.vocab
        valuation := entryValuation hfb.valuation h9
        promptValue := ?_
        rowValue := θat h9 θ10
        offsetValue := ?_
        capValue := ?_
        context := ⟨⟨hlo, hhi, fun a => ?_⟩, ?_⟩
        prompt := ?_
        reserved := ?_
        emittedAnchor := ?_
        input := ?_ }
    · have hθ : PLD1.θ 9 = .var 9 := Pf.thetaOf_off (by rw [θKeys]; decide)
      change (PLD1.θ 9).eval x.ν = _
      rw [hθ, hlen]
      exact h9
    · rw [hlen]
      exact θat h9 θ11
    · rw [hlen]
      exact θat h9 θ16
    · rw [hfrY a]
      by_cases ha : a = 2665
      · subst ha
        simp only [if_true, List.mem_cons, List.not_mem_nil, or_false, iff_true]
        rw [hP]
        exact Option.some_ne_none _
      · rw [if_neg ha]
        simp only [ne_eq, not_true_eq_false, List.mem_cons, List.not_mem_nil, or_false, false_iff]
        exact ha
    · change x.t.next - PRE_pl_entry.s0.next ≤ cap
      rw [hoff, sameNext]
      omega
    · change y.K.fr 2665 = _
      rw [hfrY 2665, if_pos rfl]
      exact hP
    · intro j hj
      have hθ : PLD1.θ j = .var j := Pf.thetaOf_off (by
        rw [θKeys]
        simp only [List.mem_cons, List.not_mem_nil, or_false]
        omega)
      change (PLD1.θ j).eval x.ν = _
      rw [hθ]
      exact hv j hj
    · change x.M.a (PLWalkD1.R.data.a 2590) = 2590
      rw [anchorA]
      exact hem
    · have e : y.M.node 15235 = x.M.node 15235 := by
        change x.M.node (PLWalkD1.R.data.nodeF 15235) = _
        rw [inputNode]
      have hi : SetupD1Input.InputAt ρ (y.M.node 15235) x.t x.C := by
        rw [e]
        exact hip
      exact hi
  · change x.M.a (PLWalkD1.R.data.a 2586) = 2586 ∧ x.M.a (PLWalkD1.R.data.a 2589) = 2589
    rw [anchorB, anchorC]
    exact hc

kernel_rfl headBridge : bridgeOf PRE_pl_head.s1.ffi = bridgeOf PRE_pl_head.s0.ffi
kernel_rfl headTop : noRetBlock PRE_pl_head.s1 = true
kernel_rfl headInactive : (bridgeOf PRE_pl_head.s0.ffi).active = false
kernel_rfl headCnt : countersOkB PRE_pl_head.s0 PRE_pl_head.s1 = true

noncomputable def g3f_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (hπ : ∀ k ∈ π, k < 248320)
    (cap : Nat) (hcap : 4096 ≤ cap) (hcap2 : cap ≤ 4096 + 1593835520)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF [final_cold.r0] (fun _ => withMem (Mem 1) (returnedPromptCut NB T tk π))
      (fun i => withMem (Mem i.L) (Post.indexedCut NB T tk cap 15235 π PRE_pl_head.s1 PRE_pl_head.S1)) where
  m := []
  n := 809
  O := []
  chk _ _ := rfl
  ok r hr i hi _ := by
    obtain rfl := List.mem_singleton.mp hr
    have hL : i.L = 1 := D1Split.finalRowL hi
    have hstep : CutStep (withMem (Mem 1) (Post.indexedCut NB T tk cap 15235 π PRE_pl_head.s0 PRE_pl_head.S0))
        (withMem (Mem 1) (Post.indexedCut NB T tk cap 15235 π PRE_pl_head.s1 PRE_pl_head.S1)) 809 :=
      Post.glueMem (hMem 1) hcap2 PRE_pl_head.typedAccepted0 PRE_pl_head.typedRun headTop
        (fun _ hν => PRE_pl_head.good hν) headInactive headBridge headCnt
    have hhead : CutConv (withMem (Mem 1) (Post.indexedCut NB T tk cap 15235 π PRE_pl_entry.s0 PRE_pl_entry.S0))
        (withMem (Mem 1) (Post.indexedCut NB T tk cap 15235 π PRE_pl_head.s0 PRE_pl_head.S0)) := by
      rintro x ⟨γ, hrel, hb⟩ hB
      refine ⟨x, rfl, rfl, ⟨γ, ?_, hb⟩, hB⟩
      change RelB FF _ _ [] x.M x.ν x.K PRE_pl_head.s0 ⟨PRE_pl_head.S0.tab, []⟩ x.t x.C
      rw [PRE_pl_head.s0_eq, PRE_pl_head.s0_tab]
      exact hrel
    change CutStep (withMem (Mem 1) (returnedPromptCut NB T tk π))
      (withMem (Mem i.L) (Post.indexedCut NB T tk cap 15235 π PRE_pl_head.s1 PRE_pl_head.S1)) 809
    rw [hL]
    exact hstep.convL ((toEntry NB T tk hπ hcap (hMem 1)).trans hhead)

end Host.Ts.Sim.Compose.D1First
