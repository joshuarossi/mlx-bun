import host.sim.template.a4pre_d1_body.Advance
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyAdvance
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.SetupD1 Host.Ts.Sim.Prefill
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem size {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {M0 : Map} {y0 : Host.Mlx.Ffi.St} {sa sb : St FF.S} {Sa Sb Sdec : SSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} {asR : List Arg}
    (hparts : Disp.sizeParts sa = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk sa = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hta : ta ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view])
    (hdec : interpS (decodeArgs FF sa tys args).run Sa = some (some asR, Sdec))
    (hpre : sizePreB loopVB Sdec sa.ffi asR = true)
    (hsize : interpS (Disp.sizeS FF sa).run Sa = some (sb, Sb))
    (hgood : Lin.goodEnum Lin.Cls.final_cold.r0.ps (Lin.Cls.varsOf Lin.Cls.final_cold.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 17 ≤ Sa.tab.length) :
    CutStep (cut NB T tk π K0 M0 y0 sa Sa) (cut NB T tk π K0 M0 y0 sb Sb) 3 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hbook⟩, hf, hfixed, he0⟩
  obtain ⟨origin, hinit, hpref⟩ := hbook
  have hb : BodyBook π K0 x := ⟨origin, hinit, hpref⟩
  have hg := D1Row.good hgood hinit.singleton
  have hr0 := hr.withOracle hg
  have hfr : x.K.fr ta = none := by
    by_contra h
    exact hta ((hinit.context.1.2.2 ta).mp h)
  have hpre0 : ∀ ars S1, interpS (decodeArgs FF sa tys args).run Sa = some (some ars, S1) →
      D1BodySize.Pre x.ν S1 sa.ffi ars := by
    intro ars S1 hd
    exact ⟨sizePre_of hdec hpre hinit.valuation ars S1 hd, hi⟩
  obtain ⟨M', t', C', _, ⟨⟨gg, hrel, ars, ret, ars', ret', v, hs, ht, hv, hv'⟩, hrun⟩⟩ :=
    (D1BodySize.growAt y0 hr0 hparts hargs hsym hm hpay hfr hpre0).run sb Sb hsize
  let K' : Host.Ts.Sim.Ctx := ⟨x.K.fr, sb.trace, t'.trace, x.K.D, x.K.lo, x.K.hi⟩
  have hb' : BodyBook π K0 ⟨M', x.ν, K', t', C'⟩ := hb.restart gg.ext hr0 ht
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1.1
    obtain ⟨_, _, r1⟩ := hrel.ffi.1.1
    have hi' : (bridgeOf sb.ffi).active = false :=
      (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) hbr).trans hi
    have heq : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi').bridge.1.trans (hbr.trans (r0.toR hi).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [heq]
    exact hf Cx Pc Kc weights kind NE IP G init
  have fixed' : fixedCells (⟨M', x.ν, K', t', C'⟩ : SegInst FF) := by
    constructor
    · change M'.a 2586 = 2586
      rw [gg.ext.a]
      exact hfixed.1
    · change M'.a 2589 = 2589
      rw [gg.ext.a]
      exact hfixed.2
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨hrel.withOracle (fun _ h => nomatch h), hb'⟩,
    fresh, fixed', he0.trans (gg.ext.mono h20) (Nat.le_refl _)⟩

end Host.Load.Run.Tpl.D1BodyAdvance

-- rechecked: literal chunk length
