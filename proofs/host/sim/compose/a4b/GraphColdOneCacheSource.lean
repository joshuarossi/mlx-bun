import host.sim.compose.a4b.GraphColdOneCacheSourceChecks
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneCache
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.FfiEval _root_.Host.Load.Layers


theorem mapM_getD_of_isSome {α β : Type} (f : α → Option β) (fallback : β) :
    ∀ (xs : List α), (∀ a ∈ xs, (f a).isSome = true) →
      xs.mapM f = some (xs.map (fun a => (f a).getD fallback))
  | [], _ => rfl
  | a :: xs, h => by
      have ha := h a (by simp only [List.mem_cons, true_or])
      cases he : f a with
      | none => rw [he] at ha; cases ha
      | some b =>
          simp only [List.mapM_cons, he, Option.bind_eq_bind, Option.bind_some, List.map_cons,
            Option.getD_some]
          rw [mapM_getD_of_isSome f fallback xs (fun b hb => h b (List.mem_cons_of_mem a hb))]
          rfl

theorem cachesTW_of_list {S : Type} (mx : S → Host.Mlx.Ffi.St) (s : St S)
    (je : Env) (objects : List Nat) (cc aL : Nat)
    (hl : lookupEnv chars!"cache" je = some cc)
    (hc : s.cell? cc = some (some (.obj aL)))
    (he : elementsW s (.obj aL) = some (objects.map Val.obj))
    (hv : ∀ a ∈ objects, (cacheTW mx s (.obj a)).isSome = true) :
    cachesTW mx s je = some (objects.map (fun a =>
      (cacheTW mx s (.obj a)).getD ⟨[], 0, none, none⟩)) := by
  have hb : bindingOf s je chars!"cache" = some (.obj aL) := by
    unfold bindingOf
    rw [hl, Option.bind_some, hc]
    rfl
  unfold cachesTW
  rw [hb, Option.bind_some, he, Option.bind_some, ExtractSim.mapM_map]
  exact mapM_getD_of_isSome (fun a => cacheTW mx s (.obj a)) ⟨[], 0, none, none⟩ objects hv

theorem source_extraction : cachesTW mlxOf D1PostOne.s10 cacheEnv = some sourceCaches :=
  cachesTW_of_list mlxOf D1PostOne.s10 cacheEnv cacheObjects 2586 2672295
    cache_lookup cache_cell cache_list (fun a ha => List.all_eq_true.mp cache_entries a ha)

theorem binding_env {S : Type} (s : St S) {je : Env}
    (h : lookupEnv chars!"cache" je = some 2586) :
    bindingOf s je chars!"cache" = bindingOf s cacheEnv chars!"cache" := by
  unfold bindingOf
  rw [h, cache_lookup]

theorem extraction_env {S : Type} (mx : S → Host.Mlx.Ffi.St) (s : St S) {je : Env}
    (h : lookupEnv chars!"cache" je = some 2586) :
    cachesTW mx s je = cachesTW mx s cacheEnv := by
  unfold cachesTW
  rw [binding_env s h]

theorem ok_env {S : Type} (s : St S) {je : Env}
    (h : lookupEnv chars!"cache" je = some 2586) :
    cachesOkWB s je wideDomain = cachesOkWB s cacheEnv wideDomain := by
  unfold cachesOkWB
  rw [binding_env s h]


end Host.Ts.Sim.Compose.ColdGraph.OneCache
