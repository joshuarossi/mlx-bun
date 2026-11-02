import host.route.cert.Dec.Grow.Cert
import host.simgraph.GenLoadRel
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Route.Cert.Dec.Grow
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.SimGraph

noncomputable def exactNodeB (i : Nat) : Bool :=
  !tplDom NL N0 fixedBigs endLoad.ffi.mlx i || match endLoad.ffi.mlx.nodes.get i with
    | none => true
    | some nd => !G.shapeOnly nd

kernel_rfl exactNodes : (List.range endLoad.ffi.mlx.nnext).all exactNodeB = true

/-- Exactness on the checked source domain, using the source bound already supplied by the relation. -/
theorem source_exact {i : Nat} {nd : Ffi.Node} (hlt : i < endLoad.ffi.mlx.nnext)
    (hi : tplDom NL N0 fixedBigs endLoad.ffi.mlx i = true)
    (hn : endLoad.ffi.mlx.nodes.get i = some nd) : G.shapeOnly nd = false := by
  have h := List.all_eq_true.mp exactNodes i (List.mem_range.mpr hlt)
  simpa only [exactNodeB, hi, Bool.not_true, Bool.false_or, hn, Bool.not_eq_true'] using h

end Host.Route.Cert.Dec.Grow
