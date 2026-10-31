import host.sim.compose.PostGlue
import host.sim.compose.a4b.PLD1
import host.sim.compose.a4b.D1BodyFill
import host.sim.compose.CallLink
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
kernel_rfl θ14 : PLD1.θ 14 = .var 17
kernel_rfl θKeys : PLWalkD1.R.theta.map Prod.fst = [10, 11, 14, 16, 21, 22, 24, 26]
kernel_rfl anchorA : PLWalkD1.R.data.a 2590 = 2590
kernel_rfl anchorB : PLWalkD1.R.data.a 2586 = 2586
kernel_rfl anchorC : PLWalkD1.R.data.a 2589 = 2589
kernel_rfl inputNode : PLWalkD1.R.data.nodeF 15235 = 15235
kernel_rfl sameNext : D1Body.s155.next = PRE_pl_entry.s0.next
kernel_rfl nodesBelow : Nat.ble (mlxOf D1Body.s155.ffi).nnext PLD1.P0.NL = true

/-- The variables the entry binds, at the singleton's row. -/
private theorem entryValuation {π : List Nat} {ν : Nat → F64} (hv : VBOkF loopVB ν) (h9 : ν 9 = F64.ofNat 1) :
    VBOkF loopVB (Shift.valuation PLD1.θ ν) := by
  intro j
  change ∃ k ≤ 2 ^ 20, Shift.valuation PLD1.θ ν j = F64.ofNat k
  by_cases hj : j ∈ [10, 11, 14, 16, 21, 22, 24, 26]
  · simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
    rcases hj with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
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
  · have hθ : PLD1.θ j = .var j := Post.thetaOf_off (by rw [θKeys]; exact hj)
    have h := hv j
    change ∃ k ≤ 2 ^ 20, ν j = F64.ofNat k at h
    obtain ⟨k, hk, he⟩ := h
    refine ⟨k, hk, ?_⟩
    change (PLD1.θ j).eval ν = _
    rw [hθ]
    exact he

/-- **The singleton's return at the L-general POST entry.** -/
theorem toEntry (NB T : Nat) (tk : Nat → Nat) {ρ : List Nat} (hρ : ∀ k ∈ ρ, k < 248320) {cap : Nat}
    (hcap : 4096 ≤ cap) :
    CutConv (returnedPromptCut NB T tk ρ) (Post.indexedCut NB T tk cap ρ PRE_pl_entry.s0 PRE_pl_entry.S0) := by
  rintro x ⟨π, K0, hr, hb, hip, hv, hem⟩ ⟨⟨hf, hc⟩, hp, hnat⟩
  obtain ⟨origin, hfb, _⟩ := hb
  have hP : x.K.fr 2665 = some ([], π.map natV) := SetupD1PromptIdentity.forward_prompt hfb
  have hC : x.K.fr D1Frames.chunk = some ([], π.map natV) := by
    change ({ x.K with base' := origin } : Ctx).fr D1Frames.chunk = _
    rw [hfb.frames]
    simp [D1Continue.framed, Disp.typedK, Disp.Ctx.frameAt, D1Frames.chunk, D1Frames.buffer]
  have e : ρ = π := (SetupDrop.promptEq hfb.vocab hρ hP hp).symm
  subst e
  have hctx : Disp.KpJ (D1Frames.typedJ (Post.bytes ρ)) 4096 x.K := hfb.context
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf D1Body.s155.ffi).nnext).NL ≤ PLD1.P0.NL := by
    change (mlxOf D1Body.s155.ffi).nnext ≤ PLD1.P0.NL
    exact Nat.le_of_ble_eq_true nodesBelow
  have hNB : NB ≤ PLD1.P0.NL := Nat.le_trans top.1.load.mlx.nbl hNL
  have hsame : D1Body.s155.next - PRE_pl_entry.s0.next = 0 := by rw [sameNext]; omega
  have hD : x.K.D + (D1Body.s155.next - PRE_pl_entry.s0.next) < Sim.bound := by
    rw [hsame]
    have := hctx.2
    simp only [Sim.bound]
    omega
  have hrel := Post.linkRel PLD1.facts (π := ρ) (γ := ρ) hr hctx hP hC hnat (by decide) (by decide) hNB hD
  have h9 : x.ν 9 = F64.ofNat 1 := hfb.singleton
  have hlen : ρ.length = 1 := hfb.length
  have hfr : Shift.framedNext x.M x.K D1Body.s155 = x.K.fr := Post.linkFrames PLD1.facts hctx.1
  have hoff : x.t.next = D1Body.s155.next + x.K.D := hr.offset
  refine ⟨_, rfl, rfl, ⟨ρ, hrel, ?_⟩, hf, ?_⟩
  · refine
      { nonempty := by rw [hlen]; decide
        vocab := hfb.vocab
        lastRows := by rw [hlen]; simp
        rowsLength := hlen
        rowsVocab := hfb.vocab
        valuation := entryValuation (π := ρ) hfb.valuation h9
        promptValue := ?_
        rowValue := θat h9 θ10
        offsetValue := ?_
        capValue := ?_
        context := ⟨⟨hctx.1.1, hctx.1.2.1, fun a => ?_⟩, ?_⟩
        prompt := ?_
        chunk := ?_
        reserved := ?_
        emittedAnchor := ?_
        input := ?_ }
    · have hθ : PLD1.θ 9 = .var 9 := Post.thetaOf_off (by rw [θKeys]; decide)
      change (PLD1.θ 9).eval x.ν = _
      rw [hθ, hlen]
      exact h9
    · rw [hlen]
      exact θat h9 θ11
    · rw [hlen]
      exact θat h9 θ16
    · change Shift.framedNext x.M x.K D1Body.s155 a ≠ none ↔ _
      rw [hfr]
      exact hctx.1.2.2 a
    · change x.t.next - PRE_pl_entry.s0.next ≤ cap
      have := hctx.2
      rw [hoff, sameNext]
      omega
    · change Shift.framedNext x.M x.K D1Body.s155 2665 = _
      rw [hfr]
      exact hP
    · change Shift.framedNext x.M x.K D1Body.s155 D1Frames.chunk = _
      rw [hfr]
      exact hC
    · intro j hj
      have hθ : PLD1.θ j = .var j := Post.thetaOf_off (by
        rw [θKeys]
        simp only [List.mem_cons, List.not_mem_nil, or_false]
        omega)
      change (PLD1.θ j).eval x.ν = _
      rw [hθ]
      exact hv j hj
    · change x.M.a (PLWalkD1.R.data.a 2590) = 2590
      rw [anchorA]
      exact hem
    · change x.M.node (PLWalkD1.R.data.nodeF 15235) < (mlxOf x.t.ffi).nnext ∧
        Host.Mlx.FfiEval.HostInt32 (concrete x.C.val) (mlxOf x.t.ffi) (x.M.node (PLWalkD1.R.data.nodeF 15235))
          (ρ.map Int.ofNat) [1, 1]
      rw [inputNode]
      exact hip
  · change x.M.a (PLWalkD1.R.data.a 2586) = 2586 ∧ x.M.a (PLWalkD1.R.data.a 2589) = 2589
    rw [anchorB, anchorC]
    exact hc

kernel_rfl headBridge : bridgeOf PRE_pl_head.s1.ffi = bridgeOf PRE_pl_head.s0.ffi
kernel_rfl headTop : noRetBlock PRE_pl_head.s1 = true
kernel_rfl headInactive : (bridgeOf PRE_pl_head.s0.ffi).active = false

noncomputable def g3f_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (hπ : ∀ k ∈ π, k < 248320)
    (cap : Nat) (hcap : 4096 ≤ cap) (hcap2 : cap ≤ 4096 + 1593835520) :
    GluePiece FF [final_cold.r0] (fun _ => returnedPromptCut NB T tk π)
      (fun _ => Post.indexedCut NB T tk cap π PRE_pl_head.s1 PRE_pl_head.S1) where
  m := []
  n := 809
  O := []
  chk _ _ := rfl
  ok r hr i hi _ := by
    have hstep : CutStep (Post.indexedCut NB T tk cap π PRE_pl_head.s0 PRE_pl_head.S0)
        (Post.indexedCut NB T tk cap π PRE_pl_head.s1 PRE_pl_head.S1) 809 :=
      Post.glue hcap2 (fun bs => congrFun PRE_pl_head.typedAccepted0 bs) PRE_pl_head.typedRun headTop
        (fun _ hν => PRE_pl_head.good hν) headInactive headBridge
    have hhead : CutConv (Post.indexedCut NB T tk cap π PRE_pl_entry.s0 PRE_pl_entry.S0)
        (Post.indexedCut NB T tk cap π PRE_pl_head.s0 PRE_pl_head.S0) := by
      rintro x ⟨γ, hrel, hb⟩ hB
      refine ⟨x, rfl, rfl, ⟨γ, ?_, hb⟩, hB⟩
      change RelB FF _ _ [] x.M x.ν x.K PRE_pl_head.s0 ⟨PRE_pl_head.S0.tab, []⟩ x.t x.C
      rw [PRE_pl_head.s0_eq, PRE_pl_head.s0_tab]
      exact hrel
    exact hstep.convL ((toEntry NB T tk hπ hcap).trans hhead)

end Host.Ts.Sim.Compose.D1First
