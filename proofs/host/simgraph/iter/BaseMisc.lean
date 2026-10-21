import host.simgraph.iter.Inputs
import host.load.run.full.cached.Choice2
import host.load.run.full.cached.Choice3
import host.load.run.full.FirstChoice
import host.load.CacheCarriersCommand
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Ts Host.Load Host.Load.Extract Host.Load.Run.Full Host.Load.Run.Full.Cached

/-! Concrete facts of the first ordinary readback cut `P.s3272`. -/

kernel_rfl base_nnext : (P.s3272.ffi : LSt).mlx.nnext = 22539
kernel_rfl base_items : (P.s3272.ffi : LSt).mlx.items = (PTrie.nil : PTrie NumV).set 17776 (.ref 1)
kernel_rfl base_ref1 : nth? P.S3272.tab 1 = some (.var 1)
kernel_rfl base_caches : after3.cache.map cacheNodePair = tplCaches

/-- All cache tensors of the first three forwards are below the cut's node counter. -/
def cachesBelowB (cs : List Cache) (b : Nat) : Bool :=
  cs.all fun c => (c.first.all fun t => decide (t.node < b)) && (c.second.all fun t => decide (t.node < b))

kernel_rfl base_below1 : cachesBelowB firstChoice.cache 22539 = true
kernel_rfl base_below2 : cachesBelowB after2.cache 22539 = true
kernel_rfl base_below3 : cachesBelowB after3.cache 22539 = true

end Host.Mlx.SimGraph.Iter
