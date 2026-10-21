import host.load.run.full.H111
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Ts Host.Load Host.Load.Run.Full

/-! The first ordinary readback cut `P.s3272` and the five-token terminal state `P.s3573`
have the same native nodes below `22539` (the cut's node counter). -/

kernel_rfl base_nodes_check :
  (List.range 22539).map (fun j => (P.s3272.ffi : LSt).mlx.nodes.get j) =
    (List.range 22539).map (fun j => (P.s3573.ffi : LSt).mlx.nodes.get j)

end Host.Mlx.SimGraph.Iter
