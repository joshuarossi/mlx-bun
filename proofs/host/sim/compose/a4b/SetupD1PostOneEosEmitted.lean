import host.sim.compose.a4b.SetupD1PostOneEos
import host.sim.world.EmittedMapped
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

kernel_rfl D1PostOneEos.emitted_object : D1PostOneEos.s10.obj? 12504 =
  some (objOf D1PostOneEos.s10 12504)
kernel_rfl D1PostOneEos.emitted_kind : (objOf D1PostOneEos.s10 12504).kind = .array []

end Host.Load.Run.Tpl
namespace Host.Ts.Sim.Compose.SetupD1PostOneEos
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Route
open Host.Load.Run.Tpl

theorem end_emitted {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {x : SegInst FF} {env : Env} {nm : Name}
    (hr : (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).R x
      D1PostOneEos.s10 ⟨D1PostOneEos.S10.tab, []⟩)
    (hb : (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).B x)
    (hsaved : M0.a 2590 = 2590) (hl : lookupEnv nm env = some 2590) :
    emittedValsW x.t env nm x.C = some [] := by
  obtain ⟨hrel, hbook⟩ := hr
  obtain ⟨_, _, hext⟩ := hb
  have hcell : x.M.a 2590 = 2590 := by rw [hext.a]; exact hsaved
  have hframe : x.K.fr 12504 = none := by
    by_contra hn
    have hm := (hbook.context.1.2.2 12504).mp hn
    exact (by decide : 12504 ∉ [2665, 2673479, 2673484, 2673485] ++ [2673435, D1PostOneEos.cacheArray]) hm
  exact hrel.emittedMappedValsW hl D1PostOneEos.emissionCell hcell
    D1PostOneEos.emitted_object D1PostOneEos.emitted_kind hframe (by rfl) (by rfl)

theorem end_emitted_inv {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {t : St FF.S} {C : CSrv} {env : Env} {nm : Name}
    (h : (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).Inv t C)
    (hsaved : M0.a 2590 = 2590) (hl : lookupEnv nm env = some 2590) :
    emittedValsW t env nm C = some [] := by
  obtain ⟨x, rfl, rfl, hr, hb⟩ := h
  exact end_emitted hr hb hsaved hl

theorem halt_emitted_stop {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {env : Env} {nm : Name}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat 248044)
    (hsaved : M0.a 2590 = 2590) (hemit : lookupEnv nm env = some 2590)
    (hgen : lookupEnv chars!"generation" env = some 2589) :
    CutHaltW (startCut NB tk bytes q ν K0 M0 y0) 11253
      (fun t C => (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).Inv t C ∧
        emittedValsW t env nm C = some [] ∧ stopFin env t) := by
  intro t C hi
  obtain ⟨tF, CF, v, hr, hh, hc, hend, hstop⟩ := halt_stop hν hq h0 h1 hgen t C hi
  exact ⟨tF, CF, v, hr, hh, hc, hend, end_emitted_inv hend hsaved hemit, hstop⟩

theorem halt_emitted_stop_primary {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {env : Env} {nm : Name}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat 248044)
    (hsaved : M0.a 2590 = 2590) (hemit : lookupEnv nm env = some 2590)
    (hgen : lookupEnv chars!"generation" env = some 2589) :
    CutHaltW (SetupD1PostOne.startCut NB tk bytes q ν K0 M0 y0) 11253
      (fun t C => (endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).Inv t C ∧
        emittedValsW t env nm C = some [] ∧ stopFin env t) := by
  intro t C hi
  exact halt_emitted_stop hν hq h0 h1 hsaved hemit hgen t C (startCut_of_primary hi)

end Host.Ts.Sim.Compose.SetupD1PostOneEos
