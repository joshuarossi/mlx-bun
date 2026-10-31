import host.sim.compose.a4b.FinalCachesSaved
import host.sim.compose.a4b.FinalClear1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full _root_.Host.Ts.Sim.Template
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Tpl _root_.Host.Load.Layers
open _root_.Host.Mlx.SimGraph

namespace FinalCaches
noncomputable def clear1Caches : List Cache :=
  (ExtractSim.cachesT (Template.fullWorld.proj FinalClear1.s10) cacheEnv).getD []

kernel_rfl clear1_cell : FinalClear1.s10.cell? 2586 = some (some (.obj 2672295))
kernel_rfl clear1_ok : cachesOkWB FinalClear1.s10 cacheEnv [4910] = true
kernel_rfl clear1_caches : ExtractSim.cachesT (Template.fullWorld.proj FinalClear1.s10) cacheEnv = some clear1Caches
kernel_rfl clear1_nodes : clear1Caches.map cacheNodePair = DEC.inputs.caches
end FinalCaches

noncomputable def DEC.finalClear1_cacheTpl (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV)
    (je : Env) (hc : lookupEnv chars!"cache" je = some 2586) :
    FinalCacheTpl (fullProjFb b0 NB) terminalFixP DEC.inputs je ((DEC.finalClear1 b0 NB q).seg r) where
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
  hcell := FinalCaches.clear1_cell
  hQF := by
    intro ν K h
    exact Disp.Kp.fr_none h.1 (by decide)
  hok := (FinalCaches.ok_env FinalClear1.s10 [4910] hc).trans FinalCaches.clear1_ok
  cs := FinalCaches.clear1Caches
  hcs := (FinalCaches.caches_env (Template.fullWorld.proj FinalClear1.s10) hc).trans FinalCaches.clear1_caches
  hn := FinalCaches.clear1_nodes

noncomputable def DEC.finalClear1_savedCacheTpl (b0 : BSt) (NB : Nat) (q : List Val)
    (r : List NumV) (fw : List Val) (tail : List NumV) :
    FinalCacheTpl (fullProjFb b0 NB) terminalFixP DEC.inputs
      (entryEnv (_root_.Host.Load.Run.Prompt.P.at0 fw tail)) ((DEC.finalClear1 b0 NB q).seg r) :=
  DEC.finalClear1_cacheTpl b0 NB q r _ (_root_.Host.Load.Run.Prompt.saved_cache fw tail)

end Host.Ts.Sim.Compose
