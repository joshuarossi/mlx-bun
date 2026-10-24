import metal.Elab
import metal.Frontend
import metal.tests.Assemble

namespace Metal.Elab.Tests
open Metal Core Elab Assemble.Tests Host.Mlx

/-! # Elaboration tests

Floating literals and constants, and the ten route kernels' exact texts (tests/Assemble.lean), which the
kernel proofs (metal/kernels) elaborate. Kernel-checked in ElabRoute.lean: the texts elaborate, with distinct
sites; in ElabInventory.lean: their floating-operation inventories; in ElabRules.lean: the typing rules on
small kernels. -/

/-! ## Floating literals and constants -/

/-- Literals round directly from their decimal value to binary32 (the
values Apple's compiler emits; `1.00000005960464477539062500001` is just
above the tie `1 + 2^-24`, which rounds to even). -/
theorem literals :
    decimal f32Fmt 147800537109375 (-12) = 0x4313CCF0 ∧
    decimal f32Fmt 1 (-6) = 0x358637BD ∧
    decimal f32Fmt 83886080 (-1) = 0x4B000000 ∧
    decimal f32Fmt 125 (-3) = 0x3E000000 ∧
    decimal f32Fmt 1 (-1) = 0x3DCCCCCD ∧
    decimal f32Fmt 100000005960464477539062500001 (-29) = 0x3F800001 ∧
    decimal f32Fmt 1000000059604644775390625 (-24) = 0x3F800000 ∧
    decimal f32Fmt 34028235677973366 22 = 0x7F7FFFFF ∧
    decimal f32Fmt 35 37 = 0x7F800000 ∧
    decimal f32Fmt 1 (-45) = 0x00000001 := by
  decide +kernel

/-- Folded constants: `1.0f / 147.800537109375f` is the compiler's
`0x3F7BB688E0000000` (as a double); division by `8.0f`, `0.5f` and a bfloat
`2` become multiplications, by `3.0f` not; integer folding is Value.lean's. -/
theorem constants :
    fbin f32Fmt .div 0x3F800000 0x4313CCF0 = some 0x3BDDB447 ∧
    fbin f32Fmt .div 0x3F800000 0x40400000 = some 0x3EAAAAAB ∧
    fbin f32Fmt .add 0x3F800000 0x40000000 = some 0x40400000 ∧
    reciprocal f32Fmt 0x41000000 = some 0x3E000000 ∧
    reciprocal f32Fmt 0x3F000000 = some 0x40000000 ∧
    reciprocal f32Fmt 0x40400000 = none ∧
    reciprocal ⟨8, 8⟩ 0x4000 = some 0x3F00 ∧
    convK .bf16 ⟨.i32, 1⟩ = some ⟨.bf16, 0x3F80⟩ ∧
    convK .f32 ⟨.i32, 128⟩ = some ⟨.f32, 0x43000000⟩ ∧
    convK .u32 ⟨.i32, 2 ^ 32 - 1⟩ = some ⟨.u32, 2 ^ 32 - 1⟩ ∧
    ibin .add .i32 0x7FFFFFFF 1 = none ∧
    ibin .add .u32 0xFFFFFFFF 1 = some ⟨.u32, 0⟩ := by
  decide +kernel

/-! ## The route kernels -/

def affineRowText : List Char := text .affineRow affineRowSignature affineRowInstantiation
def siluRmsHeadsText : List Char := text .siluRmsHeads siluRmsHeadsSignature siluRmsHeadsInstantiation
def gatedDeltaStepText : List Char := text .gatedDeltaStep gatedDeltaStepSignature gatedDeltaStepInstantiation
def gatedRmsNormText : List Char := text .gatedRmsNorm gatedRmsNormSignature gatedRmsNormInstantiation
def residualRmsNormText : List Char :=
  text .residualRmsNorm residualRmsNormSignature residualRmsNormInstantiation
def gateUpText : List Char := text .gateUp gateUpSignature gateUpInstantiation
def downPartialText : List Char := text .downPartial downPartialSignature downPartialInstantiation
def downFoldText : List Char := text .downFold downFoldSignature downFoldInstantiation
def argmaxPartialText : List Char := text .argmaxPartial argmaxPartialSignature argmaxPartialInstantiation
def argmaxFinishText : List Char := text .argmaxFinish argmaxFinishSignature argmaxFinishInstantiation

/-- Contraction, barrier and collective sites (nonzero) of a core. -/
def siteE : Nat → CExpr → List Nat
  | 0, _ => []
  | f + 1, e =>
    match e with
    | .bin _ _ s a b => (if s == 0 then [] else [s]) ++ siteE f a ++ siteE f b
    | .un _ _ a | .conv _ a | .bitcast _ a | .load _ a | .ptrCast _ a => siteE f a
    | .fma a b c | .cond a b c => siteE f a ++ siteE f b ++ siteE f c
    | .and a b | .or a b | .offset a b | .component a b => siteE f a ++ siteE f b
    | _ => []

def siteS : Nat → List CStmt → List Nat
  | 0, _ => []
  | _ + 1, [] => []
  | f + 1, s :: rest =>
    (match s with
      | .set _ e => siteE 1000 e
      | .store _ p v => siteE 1000 p ++ siteE 1000 v
      | .ite c a b => siteE 1000 c ++ siteS f a ++ siteS f b
      | .loop c st b => siteE 1000 c ++ siteS f st ++ siteS f b
      | .scope b => siteS f b
      | .barrier s _ _ => [s]
      | .collective s _ _ _ e d => s :: (siteE 1000 e ++ siteE 1000 d)
      | _ => []) ++ siteS f rest

def distinct : List Nat → Bool
  | [] => true
  | x :: xs => !xs.contains x && distinct xs

def sitesDistinct (t : List Char) : Bool :=
  match (frontend t).bind elaborate with
  | some k => distinct (siteS 100000 k.body)
  | none => false


end Metal.Elab.Tests
