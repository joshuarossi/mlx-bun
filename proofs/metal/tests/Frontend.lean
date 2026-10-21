import metal.Frontend
import metal.tests.Assemble

namespace Metal.Frontend.Tests
open Host.Mlx Metal.Assemble.Tests

/-! Each route kernel's exact assembled text (tests/Assemble.lean proves it is
what `assemble` produces from the route's launch) goes through the frontend. -/

def kinds : List Top → List Nat :=
  List.map fun | .func f => if f.kernel then 1 else 0 | .instantiate .. => 2

theorem affineRow_frontend :
    ((frontend (text .affineRow affineRowSignature affineRowInstantiation)).map kinds) = some [0, 0, 1, 2] := by
  decide +kernel
theorem siluRmsHeads_frontend :
    ((frontend (text .siluRmsHeads siluRmsHeadsSignature siluRmsHeadsInstantiation)).map kinds).isSome := by
  decide +kernel
theorem gatedDeltaStep_frontend :
    ((frontend (text .gatedDeltaStep gatedDeltaStepSignature gatedDeltaStepInstantiation)).map kinds).isSome := by
  decide +kernel
theorem gatedRmsNorm_frontend :
    ((frontend (text .gatedRmsNorm gatedRmsNormSignature gatedRmsNormInstantiation)).map kinds).isSome := by
  decide +kernel
theorem residualRmsNorm_frontend :
    ((frontend (text .residualRmsNorm residualRmsNormSignature residualRmsNormInstantiation)).map kinds).isSome := by
  decide +kernel
theorem gateUp_frontend :
    ((frontend (text .gateUp gateUpSignature gateUpInstantiation)).map kinds).isSome := by
  decide +kernel
theorem downPartial_frontend :
    ((frontend (text .downPartial downPartialSignature downPartialInstantiation)).map kinds).isSome := by
  decide +kernel
theorem downFold_frontend :
    ((frontend (text .downFold downFoldSignature downFoldInstantiation)).map kinds).isSome := by
  decide +kernel
theorem argmaxPartial_frontend :
    ((frontend (text .argmaxPartial argmaxPartialSignature argmaxPartialInstantiation)).map kinds).isSome := by
  decide +kernel
theorem argmaxFinish_frontend :
    ((frontend (text .argmaxFinish argmaxFinishSignature argmaxFinishInstantiation)).map kinds).isSome := by
  decide +kernel

end Metal.Frontend.Tests
