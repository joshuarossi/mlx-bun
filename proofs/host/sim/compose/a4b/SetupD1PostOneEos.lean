import host.sim.template.a4pre_d1_post_one_eos.Spread
import host.sim.template.a4pre_d1_post_one_eos.Endpoint
import host.sim.compose.a4b.SetupD1PostOne
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1PostOneEos
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Route
open Host.Load.Run.Tpl

noncomputable def startCut (NB : Nat) (tk : Nat → Nat) (bytes : List Byte) (q : List Val)
    (ν : Nat → F64) (K0 : Host.Ts.Sim.Ctx) (M0 : Map) (y0 : Host.Mlx.Ffi.St) : ICut FF :=
  cut NB tk bytes q ν K0 M0 y0 D1Body.s155 D1Body.S155

theorem startCut_exact (NB : Nat) (tk : Nat → Nat) (bytes : List Byte) (q : List Val)
    (ν : Nat → F64) (K0 : Host.Ts.Sim.Ctx) (M0 : Map) (y0 : Host.Mlx.Ffi.St) :
    startCut NB tk bytes q ν K0 M0 y0 =
      cut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s0 D1PostOneEos.S0 := by
  unfold startCut cut
  rw [D1PostOneEos.start_exact, D1PostOneEos.tab_exact]

theorem startCut_of_primary {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {t : St FF.S} {C : CSrv}
    (h : (SetupD1PostOne.startCut NB tk bytes q ν K0 M0 y0).Inv t C) :
    (startCut NB tk bytes q ν K0 M0 y0).Inv t C := by
  obtain ⟨x, ht, hC, ⟨hr, hb⟩, hf, ha, he⟩ := h
  exact ⟨x, ht, hC, ⟨hr, ⟨hb.valuation, hb.context, hb.frames, hb.offset, hb.lo, hb.hi, hb.prompt⟩⟩,
    hf, ha, he⟩

theorem run {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat 248044) :
    CutStep (startCut NB tk bytes q ν K0 M0 y0)
      (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10) 11253 := by
  have hg := D1PostOneEos.good h0 h1 hν.2
  exact ((beforeSize hν hg).trans ((size hν hg).trans ((beforeLen1 hν hg).trans
    ((len1 hν hq).trans ((beforeLen2 hν).trans ((len2 hν hq).trans
      ((beforeSpread hν).trans (spread.trans (afterSpread hν))))))))).cast
        (startCut_exact NB tk bytes q ν K0 M0 y0) rfl rfl

theorem halt {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat 248044) :
    CutHaltW (startCut NB tk bytes q ν K0 M0 y0) 11253
      (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).Inv := by
  intro t C hi
  obtain ⟨tF, CF, hrun, hout⟩ := run hν hq h0 h1 t C hi
  obtain ⟨x, ht, hC, ⟨hr, hb⟩, hB⟩ := hout
  have hc : x.t.ctl = x.M.ctl D1PostOneEos.s10.ctl := hr.ctl
  have hh : tF.ctl = .halt (.normal .undef) := by
    rw [← ht, hc, D1PostOneEos.halt]; rfl
  exact ⟨tF, CF, .undef, hrun, hh, runC_le _ _ _ _ _ hrun, x, ht, hC, ⟨hr, hb⟩, hB⟩

theorem end_stop {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {env : Env} {t : St FF.S} {C : CSrv}
    (hgen : lookupEnv chars!"generation" env = some 2589)
    (h : (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).Inv t C) :
    stopFin env t := by
  obtain ⟨x, rfl, rfl, ⟨hr, hb⟩, hf, ha, he⟩ := h
  exact hr.statsFieldW_str hgen ha.2 (congrFun D1PostOneEos.stopCellNoW bytes)
    D1PostOneEos.generationCell (congrFun D1PostOneEos.stopGenNoW bytes)
    D1PostOneEos.stats_actual (congrFun D1PostOneEos.stopStatsNoW bytes) D1PostOneEos.stopFinish

theorem halt_stop {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} {env : Env}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat 248044)
    (hgen : lookupEnv chars!"generation" env = some 2589) :
    CutHaltW (startCut NB tk bytes q ν K0 M0 y0) 11253 (fun t C =>
      (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).Inv t C ∧ stopFin env t) := by
  intro t C hi
  obtain ⟨tF, CF, v, hr, hh, hle, hend⟩ := halt hν hq h0 h1 t C hi
  exact ⟨tF, CF, v, hr, hh, hle, hend, end_stop hgen hend⟩

theorem selected {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} (hq : q.length = 1) :
    CutHaltW (startCut NB tk bytes q D1PostOneEos.select K0 M0 y0) 11253
      (endCut NB tk bytes q D1PostOneEos.select K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).Inv :=
  halt D1PostOneEos.select_bounds hq rfl rfl

end Host.Ts.Sim.Compose.SetupD1PostOneEos
