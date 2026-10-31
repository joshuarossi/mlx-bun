import host.sim.compose.a4b.GraphColdFamilyProofs
import host.sim.compose.a4b.GraphColdExpected
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Load.Run.Full.Expected
noncomputable def normalized : Nat × List (RNode Int InKey) := run (normG (δ := Int) (κ := InKey) .finalNorm fragment63.1.1) fragment63.2
kernel_rfl normalized_eq : normalized = run (normG (δ := Int) (κ := InKey) .finalNorm fragment63.1.1) fragment63.2

kernel_rfl normalized_prefix : normalized = (4009, expectedInt)

end Host.Ts.Sim.Compose.ColdGraph
