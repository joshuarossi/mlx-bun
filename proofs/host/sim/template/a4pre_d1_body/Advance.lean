import host.sim.template.a4pre_d1_body.History
import host.sim.template.a4pre_d1_body.SizeAt
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyAdvance
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.SetupD1
open Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

abbrev Native (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :=
  Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
    (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))

noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (K0 : Host.Ts.Sim.Ctx)
    (M0 : Map) (y0 : Host.Mlx.Ffi.St) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => RelB FF (Native NB T tk y0) (D1Frames.typedW (D1Typed.bytes π)) []
    x.M x.ν x.K s S x.t x.C ∧ BodyBook π K0 x
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ Ext M0 x.M 17

theorem simulation (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Native NB T tk y0) (D1Frames.typedOk bytes)
      (Disp.KpJ (D1Frames.typedJ bytes) 4096) (D1Frames.typedW bytes) [] (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (D1Frames.typedJ bytes).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB (D1Frames.typedJ bytes) 4096 hj rfl rfl rfl rfl rfl []
    (D1Frames.typed_wp bytes) y0
  simpa only [Native, P, backRest, D1Frames.typedOk] using hs

private theorem fresh {NB T : Nat} {tk : Nat → Nat} {y0 : Host.Mlx.Ffi.St}
    {W : Nat → Option WFrame} {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (Native NB T tk y0) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Native NB T tk y0) W [] M' ν K' sb Sb t' C')
    (hi : (bridgeOf sa.ffi).active = false) (he : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hf : AneFresh t) : AneFresh t' := by
  obtain ⟨_, _, r0⟩ := hr.ffi.1.1
  obtain ⟨_, _, r1⟩ := hr'.ffi.1.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) he).trans hi
  have hb : bridgeOf t'.ffi = bridgeOf t.ffi :=
    (r1.toR hi').bridge.1.trans (he.trans (r0.toR hi).bridge.1.symm)
  intro Cx Pc Kc weights kind NE IP G init
  rw [hb]
  exact hf Cx Pc Kc weights kind NE IP G init

private theorem fixed {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : fixedCells (⟨M, ν, K, t, C⟩ : SegInst FF)) (he : Ext M M' n) :
    fixedCells (⟨M', ν, K', t', C'⟩ : SegInst FF) := by
  constructor
  · change M'.a 2586 = 2586
    rw [he.a]
    exact h.1
  · change M'.a 2589 = 2589
    rw [he.a]
    exact h.2

theorem toCall {NB T n : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {M0 : Map} {y0 : Host.Mlx.Ffi.St} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    (ha : (fun bs : List Byte => D1Frames.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (D1Frames.typedOk bs) n sa Sa = some (sb, Sb))
    (hb : (fun bs : List Byte => D1Frames.typedOk bs sb Sb) = fun _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true)
    (hgood : Lin.goodEnum Lin.Cls.final_cold.r0.ps (Lin.Cls.varsOf Lin.Cls.final_cold.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (h20 : 17 ≤ Sa.tab.length) :
    CutStep (cut NB T tk π K0 M0 y0 sa Sa) (cut NB T tk π K0 M0 y0 sc Sc) (n + 1) := by
  apply cut_glueCall (simulation NB T tk (D1Typed.bytes π) y0)
    (congrFun ha _) (hrun _) (congrFun hb _) hh hs htop
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact ⟨hbook.context, hbook.valuation⟩
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact D1Row.good hgood hbook.singleton
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), hbook.ext he⟩,
      fresh hr hrel hi hbr hB.1, fixed hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem finish {NB T n : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {M0 : Map} {y0 : Host.Mlx.Ffi.St} {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun bs : List Byte => D1Frames.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (D1Frames.typedOk bs) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : Lin.goodEnum Lin.Cls.final_cold.r0.ps (Lin.Cls.varsOf Lin.Cls.final_cold.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 17 ≤ Sa.tab.length) :
    CutStep (cut NB T tk π K0 M0 y0 sa Sa) (cut NB T tk π K0 M0 y0 sb Sb) n := by
  apply cut_glue (simulation NB T tk (D1Typed.bytes π) y0) (congrFun ha _) (hrun _) htop
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact ⟨hbook.context, hbook.valuation⟩
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact D1Row.good hgood hbook.singleton
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), hbook.ext he⟩,
      fresh hr hrel hi hbr hB.1, fixed hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

end Host.Load.Run.Tpl.D1BodyAdvance
