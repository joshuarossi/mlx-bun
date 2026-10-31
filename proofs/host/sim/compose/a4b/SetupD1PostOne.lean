import host.sim.template.a4pre_d1_post_one.Spread
import host.sim.template.a4pre_d1_post_one.Endpoint
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1PostOne
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Route
open Host.Load.Run.Tpl

noncomputable def startCut (NB : Nat) (tk : Nat → Nat) (bytes : List Byte) (q : List Val)
    (ν : Nat → F64) (K0 : Host.Ts.Sim.Ctx) (M0 : Map) (y0 : Host.Mlx.Ffi.St) : ICut FF :=
  cut NB tk bytes q ν K0 M0 y0 D1Body.s155 D1Body.S155

theorem startCut_exact (NB : Nat) (tk : Nat → Nat) (bytes : List Byte) (q : List Val)
    (ν : Nat → F64) (K0 : Host.Ts.Sim.Ctx) (M0 : Map) (y0 : Host.Mlx.Ffi.St) :
    startCut NB tk bytes q ν K0 M0 y0 =
      cut NB tk bytes q ν K0 M0 y0 D1PostOne.s0 D1PostOne.S0 := by
  unfold startCut cut
  rw [D1PostOne.start_exact, D1PostOne.tab_exact]

theorem run {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (htok : tk 1 < 248320) (hne : tk 1 ≠ 248044)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat (tk 1)) :
    CutStep (startCut NB tk bytes q ν K0 M0 y0)
      (endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10) 11445 := by
  have hg := D1PostOne.good htok hne h0 h1 hν.2
  exact ((beforeSize hν hg).trans ((size hν hg).trans ((beforeLen1 hν hg).trans
    ((len1 hν hq).trans ((beforeLen2 hν).trans ((len2 hν hq).trans
      ((beforeSpread hν).trans (spread.trans (afterSpread hν))))))))).cast
        (startCut_exact NB tk bytes q ν K0 M0 y0) rfl rfl

theorem halt {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (htok : tk 1 < 248320) (hne : tk 1 ≠ 248044)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat (tk 1)) :
    CutHaltW (startCut NB tk bytes q ν K0 M0 y0) 11445
      (endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).Inv := by
  intro t C hi
  obtain ⟨tF, CF, hrun, hout⟩ := run hν hq htok hne h0 h1 t C hi
  obtain ⟨x, ht, hC, ⟨hr, hb⟩, hB⟩ := hout
  have hc : x.t.ctl = x.M.ctl D1PostOne.s10.ctl := hr.ctl
  have hh : tF.ctl = .halt (.normal .undef) := by
    rw [← ht, hc, D1PostOne.halt]; rfl
  exact ⟨tF, CF, .undef, hrun, hh, runC_le _ _ _ _ _ hrun, x, ht, hC, ⟨hr, hb⟩, hB⟩

theorem selected {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hq : q.length = 1) (htok : tk 1 < 248320) (hne : tk 1 ≠ 248044) :
    CutHaltW (startCut NB tk bytes q (D1PostOne.select (tk 1)) K0 M0 y0) 11445
      (endCut NB tk bytes q (D1PostOne.select (tk 1)) K0 M0 y0 D1PostOne.s10 D1PostOne.S10).Inv :=
  halt (D1PostOne.select_bounds htok) hq htok hne rfl rfl

end Host.Ts.Sim.Compose.SetupD1PostOne
