import host.sim.compose.a4b.GraphColdOneCacheSourceCarriers
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneCache
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.FfiEval _root_.Host.Load.Layers

kernel_rfl cache_lookup : lookupEnv chars!"cache" cacheEnv = some 2586
kernel_rfl_eager saved_lookup : ∀ (fw : List Val) (tail : List NumV),
  lookupEnv chars!"cache" (entryEnv (_root_.Host.Load.Run.Prompt.P.at0 fw tail)) = some 2586
kernel_rfl cache_cell : D1PostOne.s10.cell? 2586 = some (some (.obj 2672295))

kernel_rfl cache_list : elementsW D1PostOne.s10 (.obj 2672295) =
  some (cacheObjects.map Val.obj)
kernel_rfl cache_ordinary : cacheObjects.all (fun a => match D1PostOne.s10.obj? a with
  | some o => match o.kind with | .ordinary => true | _ => false
  | none => false) = true


#check cache_ordinary
kernel_rfl cache_entries : cacheObjects.all
  (fun a => (cacheTW mlxOf D1PostOne.s10 (.obj a)).isSome) = true
#check cache_entries
kernel_rfl source_operations : sourceCaches.map Cache.operation = cacheOperations
#check source_operations
kernel_rfl source_ok : cachesOkWB D1PostOne.s10 cacheEnv wideDomain = true
#check source_ok

end Host.Ts.Sim.Compose.ColdGraph.OneCache
