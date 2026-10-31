import host.sim.compose.a4b.FinalPlain
import host.sim.compose.a4b.FinalClear0
import host.sim.compose.a4b.FixedEnds
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Prompt _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx.SimGraph

namespace FinalCaches

/-- A computational view of the saved cache binding. The actual environment is transported below. -/
def cacheEnv : Env := [(chars!"cache", 2586)]

kernel_rfl cacheEnv_lookup : lookupEnv chars!"cache" cacheEnv = some 2586

theorem binding_eq {S : Type} (s : St S) {je : Env}
    (hc : lookupEnv chars!"cache" je = some 2586) :
    bindingOf s je chars!"cache" = bindingOf s cacheEnv chars!"cache" := by
  unfold bindingOf
  rw [hc, cacheEnv_lookup]

theorem ok_env {S : Type} (s : St S) (wl : List Nat) {je : Env}
    (hc : lookupEnv chars!"cache" je = some 2586) :
    cachesOkWB s je wl = cachesOkWB s cacheEnv wl := by
  unfold cachesOkWB
  rw [binding_eq s hc]

theorem caches_env (s : St LSt) {je : Env}
    (hc : lookupEnv chars!"cache" je = some 2586) :
    ExtractSim.cachesT s je = ExtractSim.cachesT s cacheEnv := by
  unfold ExtractSim.cachesT
  rw [binding_eq s hc]

noncomputable def plainCaches : List Cache :=
  (ExtractSim.cachesT (Template.fullWorld.proj FinalPlain.s10) cacheEnv).getD []

kernel_rfl plain_cell : FinalPlain.s10.cell? 2586 = some (some (.obj 2672295))
kernel_rfl plain_ok : cachesOkWB FinalPlain.s10 cacheEnv [4910] = true
kernel_rfl plain_caches : ExtractSim.cachesT (Template.fullWorld.proj FinalPlain.s10) cacheEnv = some plainCaches
kernel_rfl plain_nodes : plainCaches.map cacheNodePair = DEC.inputs.caches

noncomputable def clear0Caches : List Cache :=
  (ExtractSim.cachesT (Template.fullWorld.proj FinalClear0.s10) cacheEnv).getD []

kernel_rfl clear0_cell : FinalClear0.s10.cell? 2586 = some (some (.obj 2672295))
kernel_rfl clear0_ok : cachesOkWB FinalClear0.s10 cacheEnv [4910] = true
kernel_rfl clear0_caches : ExtractSim.cachesT (Template.fullWorld.proj FinalClear0.s10) cacheEnv = some clear0Caches
kernel_rfl clear0_nodes : clear0Caches.map cacheNodePair = DEC.inputs.caches

end FinalCaches

/-- Cache extraction at the saved environment, under the independently derived terminal fixed list. -/
noncomputable def DEC.finalPlain_cacheTpl (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV)
    (je : Env) (hc : lookupEnv chars!"cache" je = some 2586) :
    FinalCacheTpl (fullProjFb b0 NB) terminalFixP DEC.inputs je ((DEC.finalPlain b0 NB q).seg r) where
  wl := [4910]
  hW := by
    intro a w h
    by_cases ha : a = 4910
    · simp [ha]
    · simp [wideP, beq_false ha] at h
  cc := 2586
  aL := 2672295
  hcc := hc
  hfix := by decide
  hwc := by decide
  hcell := FinalCaches.plain_cell
  hQF := by
    intro ν K h
    exact Disp.Kp.fr_none h.1 (by decide)
  hok := by
    exact (FinalCaches.ok_env FinalPlain.s10 [4910] hc).trans FinalCaches.plain_ok
  cs := FinalCaches.plainCaches
  hcs := by
    exact (FinalCaches.caches_env (Template.fullWorld.proj FinalPlain.s10) hc).trans FinalCaches.plain_caches
  hn := FinalCaches.plain_nodes

noncomputable def DEC.finalClear0_cacheTpl (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV)
    (je : Env) (hc : lookupEnv chars!"cache" je = some 2586) :
    FinalCacheTpl (fullProjFb b0 NB) terminalFixP DEC.inputs je ((DEC.finalClear0 b0 NB q).seg r) where
  wl := [4910]
  hW := by
    intro a w h
    by_cases ha : a = 4910
    · simp [ha]
    · simp [wideP, beq_false ha] at h
  cc := 2586
  aL := 2672295
  hcc := hc
  hfix := by decide
  hwc := by decide
  hcell := FinalCaches.clear0_cell
  hQF := by
    intro ν K h
    exact Disp.Kp.fr_none h.1 (by decide)
  hok := by
    exact (FinalCaches.ok_env FinalClear0.s10 [4910] hc).trans FinalCaches.clear0_ok
  cs := FinalCaches.clear0Caches
  hcs := by
    exact (FinalCaches.caches_env (Template.fullWorld.proj FinalClear0.s10) hc).trans FinalCaches.clear0_caches
  hn := FinalCaches.clear0_nodes

end Host.Ts.Sim.Compose
