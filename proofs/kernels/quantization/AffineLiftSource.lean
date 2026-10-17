import kernels.quantization.AffineLift
import kernels.trellis.CodebookBitsSemantics

namespace Inference.Kernels.Quantization.AffineLiftSource
open Contracts.Mlx Contracts.Mlx.Numerics
open Trellis.CodebookBitsSyntax (Expr tokenize literal)
open Trellis.CodebookBitsSemantics (Value decimalFloat evaluate)
open Copy.ScalarCopySyntax (accept nameToken)
set_option maxRecDepth 10000

-- Restricted grammar for the complete MLXQ_F macro expression. The cast,
-- bitcast, OR constant and floating subtraction are retained in the AST.
def parse (source : String) : Option Expr := do
  let tokens ←tokenize source
  let rest ←accept "(" tokens
  let rest ←accept "as_type" rest
  let rest ←accept "<" rest
  let rest ←accept "float" rest
  let rest ←accept ">" rest
  let rest ←accept "(" rest
  let rest ←accept "(" rest
  let rest ←accept "uint" rest
  let rest ←accept ")" rest
  let rest ←accept "(" rest
  let (argument,rest) ←nameToken rest
  let rest ←accept ")" rest
  let rest ←accept "|" rest
  let constant::rest := rest | none
  let bits ←literal constant
  let rest ←accept ")" rest
  let rest ←accept "-" rest
  let offset::rest := rest | none
  let offset ←literal offset
  let rest ←accept ")" rest
  if rest=[] then some (.subtract (.reinterpretFloat (.bitOr (.toUInt (.variable argument)) bits)) offset)
  else none

def sourceBody : String := "(as_type<float>((uint)(q) | 0x4B000000u) - 8388608.0f)"
def body : Expr := .subtract
  (.reinterpretFloat (.bitOr (.toUInt (.variable "q")) (.integer true 1258291200)))
  (.floating 83886080 1)
theorem parsed_body : parse sourceBody=some body := by decide +kernel

def environment (q : Nat) : Trellis.CodebookBitsSemantics.Environment := fun name =>
  if name="q" then some (.signed q) else none
def executeSource (q : Nat) : Option Value :=
  (parse sourceBody).bind (evaluate (environment q))

theorem decimal_offset : decimalFloat 83886080 1=(8388608:Float32) := by decide +kernel
theorem uint_offset : UInt32.ofNat 1258291200=(0x4b000000:UInt32) := by decide +kernel

theorem uint_conversion (q : Nat) (bounded : q<2^32) :
    UInt32.ofInt (q:Int)=UInt32.ofNat q := by
  unfold UInt32.ofInt
  rw [Int.emod_eq_of_lt (Int.natCast_nonneg q) (show (q:Int)<(2:Int)^32 by exact_mod_cast bounded)]
  rfl

theorem evaluate_uint (env : Trellis.CodebookBitsSemantics.Environment) (expr : Expr)
    (q : Int) (argument : evaluate env expr=some (.signed q)) :
    evaluate env (.toUInt expr)=
      (if 0≤q ∧ q<2^32 then some (.unsigned (UInt32.ofInt q)) else none) := by
  rw [evaluate,argument]
  rfl

theorem evaluate_argument (q : Nat) (bounded : q<2^32) :
    evaluate (environment q) (.toUInt (.variable "q"))=some (.unsigned (UInt32.ofNat q)) := by
  rw [evaluate_uint (environment q) (.variable "q") (q:Int) (by rfl)]
  rw [ite_eq_left ⟨Int.natCast_nonneg q,by exact_mod_cast bounded⟩,uint_conversion q bounded]

theorem evaluate_bits (q : Nat) (bounded : q<2^32) :
    evaluate (environment q) (.bitOr (.toUInt (.variable "q")) (.integer true 1258291200))=
      some (.unsigned (UInt32.ofNat q ||| 0x4b000000)) := by
  rw [evaluate,evaluate_argument q bounded]
  simp only [evaluate,ite_true,show (1258291200:Nat)<2^32 by decide,uint_offset]
  rfl

theorem evaluate_lift (q : Nat) (bounded : q<2^32) :
    evaluate (environment q) (.reinterpretFloat
      (.bitOr (.toUInt (.variable "q")) (.integer true 1258291200)))=
      some (.floating (Float32.ofBits (UInt32.ofNat q ||| 0x4b000000))) := by
  rw [evaluate,evaluate_bits q bounded]
  rfl

theorem evaluate_body (q : Nat) (bounded : q<2^32) :
    evaluate (environment q) body=some (.floating (AffineLift.value q)) := by
  unfold body
  rw [evaluate,evaluate_lift q bounded]
  simp only [evaluate,decimal_offset]
  rfl

-- UInt conversion, bit reinterpretation and a separately rounded subtraction
-- use the already declared binary32 machine, with no native compiler claim.
attribute [local irreducible] evaluate parse
theorem execution (q : Nat) (bounded : q<2^32) :
    executeSource q=some (.floating (AffineLift.value q)) := by
  rw [executeSource,parsed_body,Option.bind_some,evaluate_body q bounded]

theorem field_bound (field : Fin 16) (shift : Fin 13) : field.val*2^shift.val<2^32 := by
  have power : 2^shift.val≤4096 :=
    Nat.pow_le_pow_right (by decide) (show shift.val≤12 by have := shift.isLt; omega)
  have bound : field.val*2^shift.val≤15*4096 :=
    Nat.mul_le_mul (show field.val≤15 by have := field.isLt; omega) power
  omega

theorem field_execution (field : Fin 16) (shift : Fin 13) :
    executeSource (field.val*2^shift.val)=some (.floating (AffineLift.value (field.val*2^shift.val))) ∧
      real (AffineLift.value (field.val*2^shift.val))=(field.val*2^shift.val:Nat) ∧
      (AffineLift.value (field.val*2^shift.val)).isFinite=true :=
  ⟨execution _ (field_bound field shift),by
    simpa only [Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat] using AffineLift.field_exact field shift,
    AffineLift.field_finite field shift⟩

theorem mask_execution (n width shift : Nat) (widthBound : width≤4) (shiftBound : shift<13) :
    executeSource (n &&& ((2^width-1)*2^shift))=
      some (.floating (AffineLift.value (n &&& ((2^width-1)*2^shift)))) ∧
    real (AffineLift.value (n &&& ((2^width-1)*2^shift)))=(n &&& ((2^width-1)*2^shift):Nat) ∧
    (AffineLift.value (n &&& ((2^width-1)*2^shift))).isFinite=true := by
  have fieldBound : n/2^shift%2^width<16 :=
    (Nat.mod_lt _ (by positivity)).trans_le (Nat.pow_le_pow_right (by decide) widthBound)
  have range : n &&& ((2^width-1)*2^shift)<2^32 := by
    rw [AffinePacking.shifted_mask]
    exact field_bound ⟨_,fieldBound⟩ ⟨shift,shiftBound⟩
  exact ⟨execution _ range,AffineLift.mask_exact n width shift widthBound shiftBound,
    AffineLift.mask_finite n width shift widthBound shiftBound⟩

end Inference.Kernels.Quantization.AffineLiftSource
