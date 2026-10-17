import models.qwen.CheckpointRanges
import models.qwen.TrellisMlpRanges
import contracts.mlx.Float16
import contracts.mlx.FlushedIdentities

namespace Inference.Models.Qwen.CheckpointTrellis
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Exact byte constructors for the selected 17408 by 5120 stored Trellis
-- matrices. Gate/up use row-major words. The 3-bit down representation is
-- block-interleaved; 2-/4-bit down is row-major. Mathematical functions are
-- totalized with zero outside these shapes; native bounds are separate.
abbrev Codes (width : Nat) := Fin (4*(17408*20*(8*width))) → BitVec 8
abbrev Scales := Fin (2*17408) → BitVec 8

theorem row_major_bound (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (row block word : Nat) (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    DownCodebook.rowMajor row block word width < 17408*20*(8*width) := by
  unfold DownCodebook.rowMajor
  rcases valid with rfl | rfl | rfl <;> omega

def gateWords (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (bytes : Codes width) : DownExecution.PackedMatrix :=
  fun row block word =>
    if h : row<17408 ∧ block<20 ∧ word<8*width then
      TensorWords.readWord32 bytes ⟨DownCodebook.rowMajor row block word width,
        row_major_bound width valid row block word h.1 h.2.1 h.2.2⟩
    else 0
def downWords (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (bytes : Codes width) : DownExecution.PackedMatrix :=
  fun row block word =>
    if h : row<17408 ∧ block<20 ∧ word<8*width then
      if interleaved : width=3 then
        TensorWords.readWord32 bytes ⟨DownCodebook.interleaved row block word, by
          subst width
          exact DownCodebook.interleaved_bounds row block word h.1 h.2.1 h.2.2⟩
      else TensorWords.readWord32 bytes ⟨DownCodebook.rowMajor row block word width,
        row_major_bound width valid row block word h.1 h.2.1 h.2.2⟩
    else 0

theorem gate_word (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (bytes : Codes width)
    (row block word : Nat) (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    gateWords width valid bytes row block word = TensorWords.readWord32 bytes
      ⟨DownCodebook.rowMajor row block word width, row_major_bound width valid row block word hr hb hw⟩ := by
  simp only [gateWords, hr, hb, hw, and_self, ↓reduceDIte]
theorem down_interleaved (valid : 3=2 ∨ 3=3 ∨ 3=4) (bytes : Codes 3)
    (row block word : Nat) (hr : row<17408) (hb : block<20) (hw : word<24) :
    downWords 3 valid bytes row block word = TensorWords.readWord32 bytes
      ⟨DownCodebook.interleaved row block word, DownCodebook.interleaved_bounds row block word hr hb hw⟩ := by
  simp only [downWords, show 8*3=24 from rfl, hr, hb, hw, and_self, ↓reduceDIte]
theorem down_row_major (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (ordinary : width≠3) (bytes : Codes width)
    (row block word : Nat) (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    downWords width valid bytes row block word = TensorWords.readWord32 bytes
      ⟨DownCodebook.rowMajor row block word width, row_major_bound width valid row block word hr hb hw⟩ := by
  simp only [downWords, hr, hb, hw, and_self, ordinary, ↓reduceDIte]

def scale (bytes : Scales) (row : Nat) : Float32 :=
  if h : row<17408 then Float16.widen (TensorWords.readFloat16 bytes ⟨row,h⟩) else 0
theorem scale_exact (bytes : Scales) (row : Fin 17408) :
    scale bytes row.val = Float16.widen (TensorWords.readFloat16 bytes row) := by simp only [scale, row.isLt, ↓reduceDIte]
theorem scale_bound (bytes : Scales) (cap : Float16.Value) (nonnegative : 0 ≤ Model.toReal cap)
    (checked : TensorWords.check (List.ofFn (TensorWords.readFloat16 bytes)) cap = true) :
    ∀ row, (scale bytes row).isFinite = true ∧ |real (scale bytes row)| ≤ Model.toReal cap := by
  intro row
  unfold scale
  split
  · exact Float16.widen_bound _ _ (TensorWords.readFloat16_bound bytes cap checked _)
  · exact ⟨by decide, by simpa only [FlushedIdentities.zero_real, abs_zero] using nonnegative⟩

def gateCap : Float16.Value := Model.ofBits 0x2880
def upCap : Float16.Value := Model.ofBits 0x2c00
def downCap : Float16.Value := Model.ofBits 0x2800
theorem gateCap_real : Model.toReal gateCap = (9 : ℝ)/256 := by
  have h : Model.toDyadic? gateCap = some ⟨false, 1152, -15⟩ := by decide +kernel
  rw [Model.toReal_eq, h]
  norm_num [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]
theorem upCap_real : Model.toReal upCap = (1 : ℝ)/16 := by
  have h : Model.toDyadic? upCap = some ⟨false, 1024, -14⟩ := by decide +kernel
  rw [Model.toReal_eq, h]
  norm_num [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]
theorem downCap_real : Model.toReal downCap = (1 : ℝ)/32 := by
  have h : Model.toDyadic? downCap = some ⟨false, 1024, -15⟩ := by decide +kernel
  rw [Model.toReal_eq, h]
  norm_num [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]
theorem caps_finite : Model.isFinite gateCap = true ∧ Model.isFinite upCap = true ∧ Model.isFinite downCap = true := by
  decide +kernel

def gateUp (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (weights : Codes width) (scales : Scales) :
    TrellisCodebookGateUp.Projection := ⟨gateWords width valid weights, width, valid, scale scales⟩
def down (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (weights : Codes width) (scales : Scales) :
    TrellisCodebookDown.Projection := ⟨downWords width valid weights, width, valid, scale scales⟩

theorem parameters (mlp : WrittenLayers.GateDown) (gateScales upScales downScales : Scales)
    (gateBinding : mlp.gate.scale = scale gateScales) (upBinding : mlp.up.scale = scale upScales)
    (downBinding : mlp.down.scale = scale downScales)
    (gateChecked : TensorWords.check (List.ofFn (TensorWords.readFloat16 gateScales)) gateCap = true)
    (upChecked : TensorWords.check (List.ofFn (TensorWords.readFloat16 upScales)) upCap = true)
    (downChecked : TensorWords.check (List.ofFn (TensorWords.readFloat16 downScales)) downCap = true) :
    TrellisMlpRanges.Parameters mlp := by
  constructor
  · rw [gateBinding]
    simpa only [gateCap_real] using scale_bound gateScales gateCap (by rw [gateCap_real]; norm_num) gateChecked
  · rw [upBinding]
    simpa only [upCap_real] using scale_bound upScales upCap (by rw [upCap_real]; norm_num) upChecked
  · rw [downBinding]
    simpa only [downCap_real] using scale_bound downScales downCap (by rw [downCap_real]; norm_num) downChecked

end Inference.Models.Qwen.CheckpointTrellis
