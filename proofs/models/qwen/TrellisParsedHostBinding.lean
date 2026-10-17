import kernels.trellis.GateHostSelectedShape
import models.qwen.TrellisMlpParsedGateTail
namespace Inference.Models.Qwen.TrellisParsedHostBinding
open Contracts.Mlx Kernels.Trellis Layers WrittenLayers
set_option maxRecDepth 10000

def preference : Activation → GateHostSelection.Tail
  | .float _ => .float
  | .split _ => .split

-- An arbitrary logical graph can request split arithmetic at equal widths;
-- the actual host cannot select that case. Retain this compatibility check.
def Supported (mlp : GateDown) : Prop := match mlp.activation with
  | .float _ => True
  | .split _ => mlp.gate.width≠mlp.up.width

theorem tail_code (mlp : GateDown) (supported : Supported mlp) :
    GateHostSelection.tailCode mlp.gate.width mlp.up.width (preference mlp.activation)=
      TrellisMlpParsedGateTail.code mlp.activation := by
  cases kind : mlp.activation with
  | float expNeg => exact GateHostSelection.float_tail mlp.gate.width mlp.up.width
  | split expAbs =>
    have different : mlp.gate.width≠mlp.up.width := by simpa only [Supported,kind] using supported
    exact GateHostSelection.split_tail mlp.gate.width mlp.up.width different

def actualCode (mlp : GateDown) (leading : List Nat) : Option Nat :=
  (GateHostSelection.select (GateHostSelectedShape.input leading) (GateHostSelection.geometry mlp.gate.width)
    (GateHostSelection.geometry mlp.up.width) (preference mlp.activation)).bind (fun launch =>
      (launch.templates.find? (fun pair => pair.1=="TAIL")).map Prod.snd)

theorem actual_code (mlp : GateDown) (leading : List Nat) (supported : Supported mlp) :
    actualCode mlp leading=some (TrellisMlpParsedGateTail.code mlp.activation) := by
  rw [actualCode,GateHostSelectedShape.selected,Option.bind_some]
  change some (GateHostSelection.tailCode mlp.gate.width mlp.up.width (preference mlp.activation))=_
  exact congrArg some (tail_code mlp supported)

end Inference.Models.Qwen.TrellisParsedHostBinding
