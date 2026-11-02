import host.route.HandFill
import host.route.cert.Dec.Carriers
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load.Run.Tpl Host.Mlx.SimGraph
open Host.Route.Cert.Row (rowToks rowCr)
open Host.Route.Cert.Dec (inputs)

/-! # POST's end holds the decode template's carriers -/

kernel_rfl hand_read0 : Hand.κ.node inputs.read = rowToks 0 1
kernel_rfl hand_fed0 : Hand.κ.node inputs.fed = rowToks 0 2
kernel_rfl hand_caches0 : inputs.caches.map (fun p => (p.1.map Hand.κ.node, p.2.map Hand.κ.node)) = rowCr 2 0

theorem hand_read (L : Nat) : Hand.κ.node inputs.read = rowToks L 1 := hand_read0
theorem hand_fed (L : Nat) : Hand.κ.node inputs.fed = rowToks L 2 := hand_fed0
theorem hand_caches (L : Nat) : inputs.caches.map (fun p => (p.1.map Hand.κ.node, p.2.map Hand.κ.node)) = rowCr 2 L := hand_caches0

end Host.Route.PrefGraph
