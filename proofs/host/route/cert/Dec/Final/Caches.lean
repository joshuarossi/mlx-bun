import host.route.cert.Dec.Final.Plain
import host.route.cert.Dec.Final.Clear0
import host.sim.template.SavedBindings
import host.sim.template.EndGenG
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Layers
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Prompt _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx.SimGraph
open _root_.Host.Route.Cert

/-! # The final chains' program caches: the cache cell's array, read at the decode template's carriers -/

namespace Final4Caches

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
  (ExtractSim.cachesT (Template.fullWorld.proj Final4Plain.s10) cacheEnv).getD []

kernel_rfl plain_cell : Final4Plain.s10.cell? 2586 = some (some (.obj 2672295))
kernel_rfl plain_ok : cachesOkWB Final4Plain.s10 cacheEnv (4910 :: ghostAddrs) = true
kernel_rfl plain_caches : ExtractSim.cachesT (Template.fullWorld.proj Final4Plain.s10) cacheEnv = some plainCaches
kernel_rfl plain_nodes : plainCaches.map cacheNodePair = Dec.inputs.caches

noncomputable def clear0Caches : List Cache :=
  (ExtractSim.cachesT (Template.fullWorld.proj Final4Clear0.s10) cacheEnv).getD []

kernel_rfl clear0_cell : Final4Clear0.s10.cell? 2586 = some (some (.obj 2672295))
kernel_rfl clear0_ok : cachesOkWB Final4Clear0.s10 cacheEnv (4910 :: ghostAddrs) = true
kernel_rfl clear0_caches : ExtractSim.cachesT (Template.fullWorld.proj Final4Clear0.s10) cacheEnv = some clear0Caches
kernel_rfl clear0_nodes : clear0Caches.map cacheNodePair = Dec.inputs.caches

end Final4Caches

/-- The saved environment's caches at the `plain` chain's end. -/
noncomputable def DEC4.finalPlain_cacheTpl (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV)
    (je : Env) (hc : lookupEnv chars!"cache" je = some 2586) :
    FinalCacheTpl (fullProjFb b0 NB) Dec4.fix4 Dec.inputs je ((DEC4.finalPlain b0 NB q).seg r) where
  wl := 4910 :: ghostAddrs
  hW := fun a w h => (wideG_mem_iff a).mp (by rw [h]; rfl)
  cc := 2586
  aL := 2672295
  hcc := hc
  hfix := by decide
  hwc := by decide
  hcell := Final4Caches.plain_cell
  hQF := by
    intro ν K h
    exact Disp.Kp.fr_none h.1 (by decide)
  hok := (Final4Caches.ok_env Final4Plain.s10 _ hc).trans Final4Caches.plain_ok
  cs := Final4Caches.plainCaches
  hcs := (Final4Caches.caches_env (Template.fullWorld.proj Final4Plain.s10) hc).trans Final4Caches.plain_caches
  hn := Final4Caches.plain_nodes

noncomputable def DEC4.finalPlain_savedCacheTpl (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV) (fw : List Val) (tail : List NumV) :
    FinalCacheTpl (fullProjFb b0 NB) Dec4.fix4 Dec.inputs
      (entryEnv (Host.Load.Run.Prompt.P.at0 fw tail)) ((DEC4.finalPlain b0 NB q).seg r) :=
  DEC4.finalPlain_cacheTpl b0 NB q r _ (Host.Load.Run.Prompt.saved_cache fw tail)

/-- The saved environment's caches at the `clear0` chain's end. -/
noncomputable def DEC4.finalClear0_cacheTpl (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV)
    (je : Env) (hc : lookupEnv chars!"cache" je = some 2586) :
    FinalCacheTpl (fullProjFb b0 NB) Dec4.fix4 Dec.inputs je ((DEC4.finalClear0 b0 NB q).seg r) where
  wl := 4910 :: ghostAddrs
  hW := fun a w h => (wideG_mem_iff a).mp (by rw [h]; rfl)
  cc := 2586
  aL := 2672295
  hcc := hc
  hfix := by decide
  hwc := by decide
  hcell := Final4Caches.clear0_cell
  hQF := by
    intro ν K h
    exact Disp.Kp.fr_none h.1 (by decide)
  hok := (Final4Caches.ok_env Final4Clear0.s10 _ hc).trans Final4Caches.clear0_ok
  cs := Final4Caches.clear0Caches
  hcs := (Final4Caches.caches_env (Template.fullWorld.proj Final4Clear0.s10) hc).trans Final4Caches.clear0_caches
  hn := Final4Caches.clear0_nodes

noncomputable def DEC4.finalClear0_savedCacheTpl (b0 : BSt) (NB : Nat) (q : List Val) (r : List NumV) (fw : List Val) (tail : List NumV) :
    FinalCacheTpl (fullProjFb b0 NB) Dec4.fix4 Dec.inputs
      (entryEnv (Host.Load.Run.Prompt.P.at0 fw tail)) ((DEC4.finalClear0 b0 NB q).seg r) :=
  DEC4.finalClear0_cacheTpl b0 NB q r _ (Host.Load.Run.Prompt.saved_cache fw tail)

end Host.Ts.Sim.Compose
