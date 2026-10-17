import kernels.trellis.GateUpScheduled
import kernels.trellis.DownScheduled
import layers.TrellisCodebookGateUp
import layers.TrellisCodebookDown

namespace Inference.Layers.TrellisScheduled
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def gateUpRaw (p : TrellisCodebookGateUp.Platform) (memory : GateUpBarrier.RawMemory) (inputBase : Nat)
    (w : TrellisCodebookGateUp.Projection) (row : Nat) : Float32 :=
  p.reduce (fun index => GateUpScheduled.lane p.load memory p.base inputBase w.words w.width w.scale row index.val)

theorem gateUpRaw_eq (p : TrellisCodebookGateUp.Platform) (memory : GateUpBarrier.RawMemory) (inputBase : Nat)
    (w : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (ready : GateUpBarrier.Ready memory p.base inputBase input) (row : Nat) :
    gateUpRaw p memory inputBase w row=TrellisCodebookGateUp.raw p w input row := by
  unfold gateUpRaw TrellisCodebookGateUp.raw
  apply congrArg p.reduce
  funext index
  rw [GateUpScheduled.lane_eq p.load memory p.base inputBase w.words w.width w.scale input ready row index.val index.isLt]
  exact (GateUpFlushToZero.sourceLane_correct p.load p.loads (GateUpBarrier.floatMemory memory) p.base p.aligned p.bounded
    ready.codebook w.words w.width w.validWidth w.scale input row index.val index.isLt).trans
    (GateUpFlushToZero.sourceLane_correct p.load p.loads (TrellisCodebookGateUp.table p) p.base p.aligned p.bounded
      (TrellisCodebookGateUp.table_initialized p) w.words w.width w.validWidth w.scale input row index.val index.isLt).symm

def gateUpSplitOutput (p : TrellisCodebookGateUp.Platform) (memory : GateUpBarrier.RawMemory) (inputBase : Nat)
    (gate up : TrellisCodebookGateUp.Projection) (row : Nat)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) : Float32 :=
  BFloat16.widen (GateUpSplitTail.tail expAbs (BFloat16.narrow (gateUpRaw p memory inputBase gate row))
    (BFloat16.narrow (gateUpRaw p memory inputBase up row)))

theorem gateUpSplitOutput_eq (p : TrellisCodebookGateUp.Platform) (memory : GateUpBarrier.RawMemory) (inputBase : Nat)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (ready : GateUpBarrier.Ready memory p.base inputBase input) (row : Nat)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) :
    gateUpSplitOutput p memory inputBase gate up row expAbs=TrellisCodebookGateUp.splitOutput p gate up input row expAbs := by
  unfold gateUpSplitOutput TrellisCodebookGateUp.splitOutput
  rw [gateUpRaw_eq p memory inputBase gate input ready row, gateUpRaw_eq p memory inputBase up input ready row]

def gateUpFloatOutput (p : TrellisCodebookGateUp.Platform) (memory : GateUpBarrier.RawMemory) (inputBase : Nat)
    (gate up : TrellisCodebookGateUp.Projection) (row : Nat) (expNeg : Float32 → Float32) : Float32 :=
  GateUpTailFlushToZero.tail expNeg (BFloat16.cast (gateUpRaw p memory inputBase gate row))
    (BFloat16.cast (gateUpRaw p memory inputBase up row))

theorem gateUpFloatOutput_eq (p : TrellisCodebookGateUp.Platform) (memory : GateUpBarrier.RawMemory) (inputBase : Nat)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (ready : GateUpBarrier.Ready memory p.base inputBase input) (row : Nat) (expNeg : Float32 → Float32) :
    gateUpFloatOutput p memory inputBase gate up row expNeg=TrellisCodebookGateUp.floatOutput p gate up input row expNeg := by
  unfold gateUpFloatOutput TrellisCodebookGateUp.floatOutput
  rw [gateUpRaw_eq p memory inputBase gate input ready row, gateUpRaw_eq p memory inputBase up input ready row]

def downForward (p : TrellisCodebookDown.Platform) (w : TrellisCodebookDown.Projection) (input : Nat → Float32)
    (traces : ∀ ty, DownScheduled.Trace p.load (p.before ty) p.base w.words w.width w.scale input ty)
    (col : Fin 5120) : Float32 :=
  DownScheduled.output p.load p.before p.base w.words w.width w.scale input traces p.reduce BFloat16.cast col.val

theorem downForward_eq (p : TrellisCodebookDown.Platform) (w : TrellisCodebookDown.Projection) (input : Nat → Float32)
    (traces : ∀ ty, DownScheduled.Trace p.load (p.before ty) p.base w.words w.width w.scale input ty)
    (col : Fin 5120) : downForward p w input traces col=TrellisCodebookDown.forward p w input col := by
  unfold downForward
  rw [DownScheduled.output_correct p.load p.loads p.before p.base p.aligned p.bounded w.words w.width w.validWidth
    w.scale input traces p.reduce BFloat16.cast col.val col.isLt, TrellisCodebookDown.forward_eq_widen]
  rfl

theorem down_error (p : TrellisCodebookDown.Platform) (w : TrellisCodebookDown.Projection) (input : Nat → Float32)
    (traces : ∀ ty, DownScheduled.Trace p.load (p.before ty) p.base w.words w.width w.scale input ty)
    (hf : TrellisCodebookDown.Finite p w input) (ideal inputError : Nat → ℝ)
    (hi : ∀ row : Fin 17408, |real (input row.val)-ideal row.val| ≤ inputError row.val) (col : Fin 5120) :
    |real (downForward p w input traces col)-TrellisCodebookDown.target w.words w.width w.scale ideal col.val| ≤
      TrellisCodebookDown.errorBudget p w input inputError col := by
  rw [downForward_eq, TrellisCodebookDown.forward_eq_widen, BFloat16.widen_real _ (hf.narrowing col)]
  exact TrellisCodebookDown.value_error p w input hf ideal inputError hi col

end Inference.Layers.TrellisScheduled
