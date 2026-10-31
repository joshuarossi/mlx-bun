import host.sim.compose.a4b.SetupD1PostOne
import host.sim.world.EmittedMapped
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

kernel_rfl D1PostOne.emitted_object : D1PostOne.s10.obj? 12504 =
  some (objOf D1PostOne.s10 12504)
kernel_rfl D1PostOne.emitted_kind : (objOf D1PostOne.s10 12504).kind =
  .array [.num (.ref 1)]

end Host.Load.Run.Tpl
namespace Host.Ts.Sim.Compose.SetupD1PostOne
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Route
open Host.Load.Run.Tpl

theorem end_emitted {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {x : SegInst FF} {env : Env} {nm : Name}
    (hr : (endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).R x
      D1PostOne.s10 ⟨D1PostOne.S10.tab, []⟩)
    (hb : (endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).B x)
    (hsaved : M0.a 2590 = 2590) (h1 : ν 1 = F64.ofNat (tk 1))
    (hl : lookupEnv nm env = some 2590) :
    emittedValsW x.t env nm x.C = some (tokVals tk 1) := by
  obtain ⟨hrel, hbook⟩ := hr
  obtain ⟨_, _, hext⟩ := hb
  have hcell : x.M.a 2590 = 2590 := by rw [hext.a]; exact hsaved
  have hframe : x.K.fr 12504 = none := by
    by_contra hn
    have hm := (hbook.context.1.2.2 12504).mp hn
    exact (by decide : 12504 ∉ [2665, 2673479, 2673484, 2673485] ++ [2673435, D1PostOne.cacheArray]) hm
  apply hrel.emittedMappedValsW hl D1PostOne.emissionCell hcell
    D1PostOne.emitted_object D1PostOne.emitted_kind hframe (by rfl)
  change [.num (.ref 1)].mapM (symValW ⟨D1PostOne.S10.tab, []⟩ x.ν) =
    some [F64.ofNat (tk 1)]
  simp only [List.mapM_cons, List.mapM_nil, symValW, D1PostOne.tokenVar,
    Option.map_some, SymE.eval, hbook.valuation, h1]
  rfl

theorem end_emitted_inv {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {t : St FF.S} {C : CSrv} {env : Env} {nm : Name}
    (h : (endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).Inv t C)
    (hsaved : M0.a 2590 = 2590) (h1 : ν 1 = F64.ofNat (tk 1))
    (hl : lookupEnv nm env = some 2590) :
    emittedValsW t env nm C = some (tokVals tk 1) := by
  obtain ⟨x, rfl, rfl, hr, hb⟩ := h
  exact end_emitted hr hb hsaved h1 hl

theorem halt_emitted {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {env : Env} {nm : Name}
    (hν : D1PostSmall.VP ν) (hq : q.length = 1)
    (htok : tk 1 < 248320) (hne : tk 1 ≠ 248044)
    (h0 : ν 0 = F64.ofNat 1) (h1 : ν 1 = F64.ofNat (tk 1))
    (hsaved : M0.a 2590 = 2590) (hl : lookupEnv nm env = some 2590) :
    CutHaltW (startCut NB tk bytes q ν K0 M0 y0) 11445
      (fun t C => emittedValsW t env nm C = some (tokVals tk 1)) := by
  intro t C hi
  obtain ⟨tF, CF, v, hr, hh, hc, he⟩ := halt hν hq htok hne h0 h1 t C hi
  exact ⟨tF, CF, v, hr, hh, hc, end_emitted_inv he hsaved h1 hl⟩

end Host.Ts.Sim.Compose.SetupD1PostOne
