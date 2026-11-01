import host.sim.template.a4pre_d1_body.Endpoint
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyOutput
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

kernel_rfl shapeDtype : ((mlxOf D1Body.s155.ffi).nodes.get 17763).map
    (fun n => (n.shape, n.dtype)) = some ([.lit 1, .lit 1, .lit 5120], 12)
kernel_rfl outputPresent : D1Body.s155.obj? 2826766 = some (objOf D1Body.s155 2826766)
kernel_rfl mappedHandle : (fun M : Map => D1Endpoint.privateVal
    (M.obj (objOf D1Body.s155 2826766)) (chars!"handle")) =
  fun M => some (.big (M.big 21985))
kernel_rfl cacheArray : (objOf D1Body.s155 2672295).kind = .array (D1Endpoint.caches.map Val.obj)
kernel_rfl cacheArrayPresent : D1Body.s155.obj? 2672295 = some (objOf D1Body.s155 2672295)
kernel_rfl cachePresent : D1Endpoint.caches.all (fun a => (D1Body.s155.obj? a).isSome) = true

def objB : Option Val → Bool
  | some (.obj _) => true
  | _ => false

def numB : Option Val → Bool
  | some (.num _) => true
  | _ => false

def updatedB (o : Obj) : Bool :=
  numB (D1Endpoint.own o (chars!"offset")) &&
    objB ((D1Endpoint.privateVal o (chars!"conv")).orElse (fun _ => D1Endpoint.own o (chars!"keys"))) &&
    objB ((D1Endpoint.privateVal o (chars!"recurrent")).orElse (fun _ => D1Endpoint.own o (chars!"values")))

kernel_rfl cachesUpdated : D1Endpoint.caches.all (fun a => updatedB (objOf D1Body.s155 a)) = true
kernel_rfl mappedCachesUpdated : (fun M : Map => D1Endpoint.caches.all
    (fun a => updatedB (M.obj (objOf D1Body.s155 a)))) = fun _ => true

end Host.Load.Run.Tpl.D1BodyOutput
