import host.sim.template.a4pre_d1_body.TraceStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.SetupD1 Host.Ts.Sim.Prefill
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

private theorem freshAt {NB T : Nat} {tk : Nat → Nat} {y0 : Host.Mlx.Ffi.St}
    {W : Nat → Option WFrame} {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (D1BodyAdvance.Native NB T tk y0) W [] M ν K sa Sa t C)
    (hr' : RelB FF (D1BodyAdvance.Native NB T tk y0) W [] M' ν K' sb Sb t' C')
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

private theorem fixedAt {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
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
    (ha : (fun bs : List Byte => checkedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (checkedOk bs) n sa Sa = some (sb, Sb))
    (hb : (fun bs : List Byte => checkedOk bs sb Sb) = fun _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true)
    (hgood : Lin.goodEnum Lin.Cls.final_cold.r0.ps (Lin.Cls.varsOf Lin.Cls.final_cold.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 sa Sa)
      (D1BodyAdvance.cut NB T tk π K0 M0 y0 sc Sc) (n + 1) := by
  apply cut_glueCall (checkedSimulation NB T tk (D1Typed.bytes π) y0)
    (congrFun ha _) (hrun _) (congrFun hb _) hh hs htop
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact ⟨hbook.context, hbook.valuation⟩
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact D1Row.good hgood hbook.singleton
  · intro x M' t' C' hbook hB hr he _ hrel
    exact ⟨⟨hrel.withOracle (fun _ h => nomatch h), hbook.ext he⟩,
      freshAt hr hrel hi hbr hB.1, fixedAt hB.2.1 he,
      hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem finish {NB T n : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {M0 : Map} {y0 : Host.Mlx.Ffi.St} {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun bs : List Byte => checkedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (checkedOk bs) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : Lin.goodEnum Lin.Cls.final_cold.r0.ps (Lin.Cls.varsOf Lin.Cls.final_cold.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 sa Sa)
      (D1BodyAdvance.cut NB T tk π K0 M0 y0 sb Sb) n := by
  apply cut_glue (checkedSimulation NB T tk (D1Typed.bytes π) y0) (congrFun ha _) (hrun _) htop
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact ⟨hbook.context, hbook.valuation⟩
  · intro x hbook _
    obtain ⟨origin, hbook, _⟩ := hbook
    exact D1Row.good hgood hbook.singleton
  · intro x M' t' C' hbook hB hr he _ hrel
    exact ⟨⟨hrel.withOracle (fun _ h => nomatch h), hbook.ext he⟩,
      freshAt hr hrel hi hbr hB.1, fixedAt hB.2.1 he,
      hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

end Host.Load.Run.Tpl.D1BodyTrace
