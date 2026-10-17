import kernels.trellis.GateHostSelection
namespace Inference.Kernels.Trellis.GateHostSelectedShape
open GateHostSelection
set_option maxRecDepth 10000

-- Leading dimensions are metadata supplied by the native tensor. The host
-- preserves them in the final reshape; no native extraction claim is made.
def input (leading : List Nat) : Input := {single with leading := leading}
def expected (leading : List Nat) (gateWidth upWidth : Nat) (preference : Tail) : Launch :=
  {GateHostSelection.expected gateWidth upWidth preference with reshapeOutput := leading++[17408]}

theorem selected (leading : List Nat) (gateWidth upWidth : Nat) (preference : Tail) :
    select (input leading) (geometry gateWidth) (geometry upWidth) preference=
      some (expected leading gateWidth upWidth preference) := by
  simp [select,input,single,geometry,groups,threads,simds,expected,GateHostSelection.expected]

theorem model_leading (gateWidth upWidth : Nat) (preference : Tail) :
    (select (input [1,1]) (geometry gateWidth) (geometry upWidth) preference).map Launch.reshapeOutput=
      some [1,1,17408] := by
  rw [selected,Option.map_some]
  rfl

end Inference.Kernels.Trellis.GateHostSelectedShape
