import host.load.run.full.expected.Join
import host.simgraph.prompt.PromptStep
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Load.Run.Full.Expected

def stages : List StageLayout := Host.Load.Run.Full.Expected.stages

/-- The source arrow's actual boundary: all 64 D1 layers and finalNorm.
The separate logits/sampler tail remains the suffix of the unchanged full step. -/
def hiddenOps : RowOps InKey :=
  { (d1Family id head (PDim.lit 0) (PDim.lit 1)).ops with
    final := fun _ y => normG InKey.finalNorm y }

def hiddenFamily : RowFamily InKey where
  ops := hiddenOps
  natural := {
    embed := (d1_natural id head (PDim.lit 0) (PDim.lit 1)).embed
    layer := (d1_natural id head (PDim.lit 0) (PDim.lit 1)).layer
    final := fun f _ y => nat_normG f InKey.finalNorm y }
  sigOK := (d1Family id head (PDim.lit 0) (PDim.lit 1)).sigOK

end Host.Ts.Sim.Compose.ColdGraph
