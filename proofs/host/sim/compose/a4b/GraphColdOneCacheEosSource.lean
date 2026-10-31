import host.sim.compose.a4b.GraphColdOneCacheSource
import host.sim.compose.a4b.GraphColdOneEosSource
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneCache
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.SimGraph
open _root_.Host.Load.Layers

kernel_rfl eos_list : elementsW D1PostOneEos.s10 (.obj 2672295) =
  some (cacheObjects.map Val.obj)
kernel_rfl eos_ordinary : cacheObjects.all (fun a => match D1PostOneEos.s10.obj? a with
  | some o => match o.kind with | .ordinary => true | _ => false
  | none => false) = true
kernel_rfl eos_ok : cachesOkWB D1PostOneEos.s10 cacheEnv wideDomain = true


def cacheReaders {S : Type} (s : St S) (N : Host.Mlx.Ffi.St) : List (Option Cache) :=
  cacheObjects.map (fun a => cacheTW (fun _ => N) s (.obj a))

kernel_rfl_eager eos_cache_readers : ∀ N : Host.Mlx.Ffi.St,
  cacheReaders D1PostOneEos.s10 N = cacheReaders D1PostOne.s10 N
#check eos_cache_readers

theorem mapM_eq_of_map_eq {α β : Type} (f g : α → Option β) :
    ∀ (xs : List α), xs.map f = xs.map g → xs.mapM f = xs.mapM g
  | [], _ => rfl
  | a :: xs, h => by
      have he := List.cons.inj h
      simp only [List.mapM_cons, he.1, mapM_eq_of_map_eq f g xs he.2]

theorem eos_cache_map :
    cacheObjects.map (fun a => cacheTW mlxOf D1PostOneEos.s10 (.obj a)) =
      cacheObjects.map (fun a => cacheTW mlxOf D1PostOne.s10 (.obj a)) :=
  (eos_cache_readers (mlxOf D1PostOneEos.s10.ffi)).trans
    (congrArg (cacheReaders D1PostOne.s10) OneEos.native_same)

theorem cachesTW_eq_of_list {S T : Type}
    (mx : S → Host.Mlx.Ffi.St) (my : T → Host.Mlx.Ffi.St) (s : St S) (t : St T)
    (je : Env) (objects : List Nat) (cc aL : Nat)
    (hl : lookupEnv chars!"cache" je = some cc)
    (hc : s.cell? cc = some (some (.obj aL)))
    (hc' : t.cell? cc = some (some (.obj aL)))
    (he : elementsW s (.obj aL) = some (objects.map Val.obj))
    (he' : elementsW t (.obj aL) = some (objects.map Val.obj))
    (hv : objects.map (fun a => cacheTW mx s (.obj a)) =
      objects.map (fun a => cacheTW my t (.obj a))) :
    cachesTW mx s je = cachesTW my t je := by
  have hb : bindingOf s je chars!"cache" = some (.obj aL) := by
    unfold bindingOf; rw [hl, Option.bind_some, hc]; rfl
  have hb' : bindingOf t je chars!"cache" = some (.obj aL) := by
    unfold bindingOf; rw [hl, Option.bind_some, hc']; rfl
  unfold cachesTW
  rw [hb, hb', Option.bind_some, Option.bind_some, he, he', Option.bind_some, Option.bind_some,
    ExtractSim.mapM_map, ExtractSim.mapM_map]
  exact mapM_eq_of_map_eq _ _ objects hv

theorem eos_extraction : cachesTW mlxOf D1PostOneEos.s10 cacheEnv = some sourceCaches :=
  (cachesTW_eq_of_list mlxOf mlxOf D1PostOneEos.s10 D1PostOne.s10 cacheEnv cacheObjects
    2586 2672295 cache_lookup D1PostOneEos.cacheCell cache_cell eos_list cache_list eos_cache_map).trans
      source_extraction

end Host.Ts.Sim.Compose.ColdGraph.OneCache
