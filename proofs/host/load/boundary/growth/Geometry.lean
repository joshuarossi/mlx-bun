import host.load.boundary.growth.Parameters
namespace Host.Load.Run.Full.Growth64
open Host.Ts Host.Load.Extract
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def expectedOperations : List (List Char) := (List.range 64).map fun i =>
  if i % 4 = 3 then chars!"KVCache" else chars!"SSMCache"

theorem cache_order_before : before.cache.map Cache.operation = expectedOperations := rfl
theorem cache_order_after : after.cache.map Cache.operation = expectedOperations := rfl

theorem method_caller_preserved : s1517.stack = entry.stack := rfl
theorem method_returned : (match s1517.ctl with | .ret _ => true | _ => false) = true := rfl
theorem next_read_selected : Host.Load.CacheBoundary.calledBody s1521 = Host.Load.CacheBoundary.itemMethod := rfl

theorem next_read_has_tensor : (Host.Load.CacheBoundary.itemInput s1521).isSome = true := rfl

theorem oracle_empty : O = [] := rfl
end Host.Load.Run.Full.Growth64
