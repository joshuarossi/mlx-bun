import host.mlx.Kernel
import host.ts.Source
namespace Host.Mlx.KernelPorts

/-! The input and output names and the `ensureRowContiguous`/`atomicOutputs` flags the ten route
kernel constructors pass to `mlx_fast_metal_kernel_new`.
KernelSourceBinding.ts checks these literals against the pinned TypeScript. -/

def inputNames : Kernel → List (List Char)
  | .affineRow => [chars!"x", chars!"w", chars!"scales", chars!"biases"]
  | .siluRmsHeads => [chars!"x", chars!"qscale", chars!"kscale"]
  | .gatedDeltaStep => [chars!"q", chars!"k", chars!"v", chars!"g", chars!"beta", chars!"state_in", chars!"Tin"]
  | .gatedRmsNorm => [chars!"x", chars!"gate", chars!"weight"]
  | .residualRmsNorm => [chars!"x", chars!"update", chars!"weight"]
  | .gateUp => [chars!"x", chars!"gcodes", chars!"gscales", chars!"ucodes", chars!"uscales"]
  | .downPartial => [chars!"x", chars!"codes", chars!"scales"]
  | .downFold => [chars!"partial"]
  | .argmaxPartial => [chars!"logits", chars!"lse"]
  | .argmaxFinish => [chars!"values", chars!"indices"]

def outputNames : Kernel → List (List Char)
  | .affineRow => [chars!"y"]
  | .siluRmsHeads => [chars!"q", chars!"k", chars!"v"]
  | .gatedDeltaStep => [chars!"y", chars!"state_out"]
  | .gatedRmsNorm => [chars!"out"]
  | .residualRmsNorm => [chars!"residual", chars!"normalized"]
  | .gateUp => [chars!"mid"]
  | .downPartial => [chars!"partial"]
  | .downFold => [chars!"out"]
  | .argmaxPartial => [chars!"values", chars!"indices"]
  | .argmaxFinish => [chars!"out"]

/-- `ensureRowContiguous` (absent: `true`). -/
def rowContiguous : Kernel → Bool
  | .affineRow => true
  | .siluRmsHeads => true
  | .gatedDeltaStep => true
  | .gatedRmsNorm => true
  | .residualRmsNorm => true
  | .gateUp => true
  | .downPartial => true
  | .downFold => true
  | .argmaxPartial => true
  | .argmaxFinish => true

/-- `atomicOutputs` (absent: `false`). -/
def atomicOutputs : Kernel → Bool
  | .affineRow => false
  | .siluRmsHeads => false
  | .gatedDeltaStep => false
  | .gatedRmsNorm => false
  | .residualRmsNorm => false
  | .gateUp => false
  | .downPartial => false
  | .downFold => false
  | .argmaxPartial => false
  | .argmaxFinish => false

end Host.Mlx.KernelPorts
