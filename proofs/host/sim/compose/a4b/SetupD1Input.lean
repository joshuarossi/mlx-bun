import host.sim.template.a4pre_d1_input.Continuation
import host.sim.template.a4pre_d1_input.Creation
import host.sim.template.a4pre_d1_input.Source
import host.sim.template.a4pre_d1_input.Evaluation
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1Input
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Route Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk Host.Ts.Sim.Compose.SetupD1

noncomputable def forwardInputCut (NB T : Nat) (tk : Nat → Nat) : ICut FF where
  s0 := D1Call.s1
  tab0 := D1Call.S1.tab
  R := fun x s S => ∃ π K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K s S x.t x.C ∧
      ForwardBook π K0 x ∧ InputAt π (x.M.node 15235) x.t x.C
  B := fun x => AneFresh x.t ∧ fixedCells x

theorem forwardInputCut_forgetR {NB T : Nat} {tk : Nat → Nat} {x : SegInst FF} {s : St FF.S} {S : SSrv}
    (h : (forwardInputCut NB T tk).R x s S) : (SetupD1.forwardCut NB T tk).R x s S := by
  obtain ⟨π, K0, hr, hb, _⟩ := h
  exact ⟨π, K0, hr, hb⟩

theorem forwardInputCut_forget {NB T : Nat} {tk : Nat → Nat} {t : St FF.S} {C : CSrv}
    (h : (forwardInputCut NB T tk).Inv t C) : (SetupD1.forwardCut NB T tk).Inv t C := by
  obtain ⟨x, ht, hc, hr, hb⟩ := h
  exact ⟨x, ht, hc, forwardInputCut_forgetR hr, hb⟩

theorem toForwardInputCore {NB T : Nat} {tk : Nat → Nat} :
    CutStep (dispatchCut NB T tk D1Input.s2 D1Input.S2) (forwardInputCut NB T tk) 350 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hq⟩, hb⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb.1
  have hi2 : (bridgeOf D1Input.s2.ffi).active = false :=
    (congrArg (fun s : St FF.S => (bridgeOf s.ffi).active) D1Input.slice_origin).trans beforeSliceInactive
  have hbr : bridgeOf D1Call.s1.ffi = bridgeOf D1Input.s2.ffi := D1Call.bridge.trans D1Input.bridge2.symm
  have hiF : (bridgeOf D1Call.s1.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) hbr).trans hi2
  have hi14 : (bridgeOf D1Input.s14.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) (D1Input.bridge14.trans D1Input.bridge2.symm)).trans hi2
  have hv : x.ν 9 = F64.ofNat 1 := hq.2.2.1
  obtain ⟨M', t', C', K', hrun, hext, hrel, hkp, hfr, hD, hlo, hhi, hev, hinput⟩ :=
    D1Continue.run_input hr hk hq.1 hframe hlen hv hi14 hvocab
  have hbook : ForwardBook π x.K ⟨M', x.ν, K', t', C'⟩ :=
    ⟨hlen, hvocab, hq.1, hv, hkp, hk, hframe, hmemo, hfr, hD.trans hd, hlo, hhi, hev⟩
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hrel.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hiF).bridge.1.trans (hbr.trans (r0.toR hi2).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have hids : fixedCells (⟨M', x.ν, K', t', C'⟩ : SegInst FF) := by
    constructor
    · change M'.a 2586 = 2586
      rw [hext.a]
      exact hb.2.1
    · change M'.a 2589 = 2589
      rw [hext.a]
      exact hb.2.2
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl, ⟨π, x.K, hrel, hbook, hinput⟩, fresh, hids⟩

/-- Canonical full-FFI s16 to the actual cold D1 call, for an arbitrary singleton token. -/
theorem toForwardInput {NB T : Nat} {tk : Nat → Nat} :
    CutStep (SetupRest.setupNextCut NB T tk 1) (forwardInputCut NB T tk) 603 := by
  have hout : dispatchCut NB T tk D1Input.s2 D1Input.S2 =
      dispatchCut NB T tk D1BeforeSlice.s1 D1BeforeSlice.S1 :=
    dispatchCut_congr D1Input.slice_origin D1Input.slice_tab
  exact ((toSlice.trans (toForwardInputCore.cast hout rfl rfl)).cast (startCut_eq_setupNext NB T tk).symm rfl rfl)

/-- The accepted setup is consumed once; this theorem stops before the cold forward body. -/
theorem ldCut_forward_input {NB T : Nat} {tk : Nat → Nat} (hctx : 1 + T ≤ 262144) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk 1)
      (forwardInputCut NB T tk) 3011 :=
  ((SetupRest.ldCut_next hctx (by decide) (by decide)).trans toForwardInput).cast rfl rfl rfl


end Host.Ts.Sim.Compose.SetupD1Input
