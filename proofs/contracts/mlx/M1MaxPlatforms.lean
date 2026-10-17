import contracts.mlx.M1MaxContract
import contracts.mlx.RmsNorm
import kernels.quantization.AffineRow
import kernels.attention.SdpaVector
import kernels.attention.SdpaNormalize
import kernels.attention.RopeAngles
import kernels.sampling.LogSumExpRanges
import layers.TrellisCodebookGateUp
import layers.TrellisCodebookDown

namespace Inference.Contracts.Mlx.M1Max.Contract
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels

-- Kernel platforms built from the operation-level contract. Remaining
-- arguments are host choices (thread groups), compiler contraction choices at
-- llvm.fmuladd sites, and initial threadgroup contents; they carry no claim.
variable (C : Contract)

theorem division : Division.Contract C.fdiv FlushToZero.divBudget := by
  constructor
  · intro x y hx hy hd ho
    rw [C.fdiv_model x y hx hy hd] at ho ⊢
    exact Division.flushedRneContract.accuracy x y hx hy hd ho
  · intro x y hx hy hn hd ho
    rw [C.fdiv_model x y hx hy hd] at ho ⊢
    exact Division.flushedRneContract.nonnegative x y hx hy hn hd ho

noncomputable def rsqrtError (x : Float32) : ℝ := |real (C.rsqrt x)-1/Real.sqrt (real x)|

theorem rootAccuracy : Normalization.RsqrtContract C.rsqrt C.rsqrtError :=
  ⟨fun _ _ _ _ => le_rfl⟩

noncomputable def rmsPlatform (groups : Nat) (positive : 0<groups) (bounded : groups≤32) (contracted : Bool) : RmsNorm.Platform where
  divide := C.fdiv
  divError := FlushToZero.divBudget
  division := C.division
  reduce := C.simdSum
  reduction := C.simdSum_tree
  rsqrt := C.rsqrt
  rsqrtError := C.rsqrtError
  rootAccuracy := C.rootAccuracy
  groups := groups
  groupsPositive := positive
  groupsBounded := bounded
  contracted := contracted

noncomputable def tilePlatform (contracted tailContracted : Bool) : Quantization.AffineTile.Platform where
  divide := C.fdiv
  divError := FlushToZero.divBudget
  division := C.division
  contracted := contracted
  tailContracted := tailContracted

noncomputable def rowPlatform (contracted tailContracted : Bool) : Quantization.AffineRow.Platform where
  tile := C.tilePlatform contracted tailContracted
  reduce := C.simdSum
  reduction := C.simdSum_tree

noncomputable def exp2Error (x : Float32) : ℝ := |real (C.exp2 x)-Attention.RopeAngles.exp2 (real x)|

noncomputable def anglePlatform : Attention.RopeAngles.Platform where
  divide := C.fdiv
  divError := FlushToZero.divBudget
  division := C.division
  exp2 := C.exp2
  expError := C.exp2Error
  exponential := ⟨fun _ _ _ _ => le_rfl⟩

-- The reached rotation angles satisfy |theta| ≤ 2^18.
def angleDomain (theta : Float32) : Prop := |real theta|≤(2:ℝ)^(18:Nat)

noncomputable def sinError (x : Float32) : ℝ := |real (C.fastSin x)-Real.sin (real x)|
noncomputable def cosError (x : Float32) : ℝ := |real (C.fastCos x)-Real.cos (real x)|

noncomputable def rotationPlatform (firstContraction secondContraction : Attention.Rope.Contraction) : Attention.Rope.Platform where
  sin := C.fastSin
  cos := C.fastCos
  sinError := C.sinError
  cosError := C.cosError
  domain := angleDomain
  sine := ⟨fun _ _ _ _ => le_rfl⟩
  cosine := ⟨fun _ _ _ _ => le_rfl⟩
  first := firstContraction
  second := secondContraction

noncomputable def fastExpError (x : Float32) : ℝ := |real (C.fastExp x)-Real.exp (real x)|

noncomputable def updatePlatform (sumContracted : Bool) (numeratorContracted : Attention.SdpaUpdate.Contraction) :
    Attention.SdpaUpdate.Platform where
  exp := C.fastExp
  expError := C.fastExpError
  exponential := ⟨fun _ _ _ => le_rfl⟩
  sumContracted := sumContracted
  numeratorContracted := numeratorContracted

noncomputable def mergePlatform (sumContracted : Bool) (numeratorContracted : Attention.SdpaUpdate.Contraction) :
    Attention.SdpaMerge.Platform where
  scalar := C.updatePlatform sumContracted numeratorContracted
  reduce := C.simdSum
  reduction := C.simdSum_tree

noncomputable def normalizePlatform : Attention.SdpaNormalize.Platform where
  divide := C.fdiv
  error := FlushToZero.divBudget
  division := C.division

noncomputable def sdpaPlatform (sumContracted : Bool) (numeratorContracted : Attention.SdpaUpdate.Contraction)
    (scoreContracted : Bool) : Attention.SdpaVector.Platform where
  merge := C.mergePlatform sumContracted numeratorContracted
  normalization := C.normalizePlatform
  scoreContracted := scoreContracted
  maximum := C.fmax
  simdMaximum := C.simdMax

noncomputable def logSumExpPlatform (sumContracted : Bool) (numeratorContracted : Attention.SdpaUpdate.Contraction) :
    Sampling.LogSumExpRanges.Platform where
  scalar := C.updatePlatform sumContracted numeratorContracted
  maximumTree := C.simdMax_tree.tree
  maximumCoverage := C.simdMax_tree.coverage
  sumTree := C.simdSum_tree.tree
  sumCoverage := C.simdSum_tree.coverage
  log := C.log

def gateUpPlatform (before : WordMemory) (base : Nat) (aligned : base%4=0) (bounded : base+16384≤2^64) :
    Layers.TrellisCodebookGateUp.Platform where
  load := C.threadgroupLoad
  loads := C.threadgroupLoad_contract
  before := before
  base := base
  aligned := aligned
  bounded := bounded
  reduce := C.simdSum
  reduction := C.simdSum_tree

def downPlatform (before : Nat → WordMemory) (base : Nat) (aligned : base%4=0) (bounded : base+16384≤2^64) :
    Layers.TrellisCodebookDown.Platform where
  load := C.threadgroupLoad
  loads := C.threadgroupLoad_contract
  before := before
  base := base
  aligned := aligned
  bounded := bounded
  reduce := C.simdSum
  reduction := C.simdSum_tree

end Inference.Contracts.Mlx.M1Max.Contract
