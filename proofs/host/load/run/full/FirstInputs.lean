import host.load.run.full.FirstChoice
import host.load.run.full.expected.Join
import host.mlx.GraphCertificateCommand
import host.mlx.KernelSources
namespace Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

/-- All symbolic readback valuations are admitted. Kernel identities use the
whole source and header bindings embedded from the TypeScript constructors. -/
def firstFfiGraph (table : List F64) : Nat → Option (RNode Int InKey) :=
  ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources firstChoice.graph

/- The input projection needs only the producing node. Its original native
handle has already been released at this yield; handle zero makes no claim
that a live array object survives. The node remains in the FFI graph. -/
def promptCarrier : Tensor := ⟨0, 15235, ⟨.data [.lit 235, .lit 37, .lit 0, .lit 0], [], [.lit 1, .lit 1], 7⟩⟩
def firstInputs : InKey → Option Nat := inputNode parameterChoice promptCarrier
@[noinline] def firstExpected (l : Loaded) : List (RNode Int InKey) :=
  ((layouts l).bind fun ls => (linearLayout l.model.head).map fun hl => (stepGraph ls hl 0).1).getD []


end Host.Load.Run.Full
