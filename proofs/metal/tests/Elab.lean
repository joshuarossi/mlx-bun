import metal.Elab
import metal.Frontend
import metal.tests.Assemble

namespace Metal.Elab.Tests
open Metal Core Elab Assemble.Tests Host.Mlx

/-! # Elaboration tests

Kernel-checked: the ten route kernels' exact texts (tests/Assemble.lean)
elaborate, with distinct sites and their floating-operation inventories
(compare `inventory` of `elaborateO0` with proofs/metal/AirInventory.ts's
`-O0` column and `inventoryDefault` of `elaborate` with its `default`
column; AirInventory's `(const)` conversions are folded here); then the
typing rules on small kernels. -/

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

theorem affineRow_elaborates : ((frontend affineRowText).bind elaborate).isSome = true := by decide +kernel
theorem siluRmsHeads_elaborates : ((frontend siluRmsHeadsText).bind elaborate).isSome = true := by
  decide +kernel
theorem gatedDeltaStep_elaborates : ((frontend gatedDeltaStepText).bind elaborate).isSome = true := by
  decide +kernel
theorem gatedRmsNorm_elaborates : ((frontend gatedRmsNormText).bind elaborate).isSome = true := by
  decide +kernel
theorem residualRmsNorm_elaborates : ((frontend residualRmsNormText).bind elaborate).isSome = true := by
  decide +kernel
theorem gateUp_elaborates : ((frontend gateUpText).bind elaborate).isSome = true := by decide +kernel
theorem downPartial_elaborates : ((frontend downPartialText).bind elaborate).isSome = true := by
  decide +kernel
theorem downFold_elaborates : ((frontend downFoldText).bind elaborate).isSome = true := by decide +kernel
theorem argmaxPartial_elaborates : ((frontend argmaxPartialText).bind elaborate).isSome = true := by
  decide +kernel
theorem argmaxFinish_elaborates : ((frontend argmaxFinishText).bind elaborate).isSome = true := by
  decide +kernel

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

/-- Every contraction site, barrier and collective has its own site. -/
theorem route_sites :
    [affineRowText, siluRmsHeadsText, gatedDeltaStepText, gatedRmsNormText, residualRmsNormText,
      gateUpText, downPartialText, downFoldText, argmaxPartialText, argmaxFinishText].all sitesDistinct = true := by
  decide +kernel

/-! ## Inventories

AirInventory.ts (`xcrun metal -std=metal4.1 -fmetal-math-mode=safe`) gives
the same counts in both columns, except that the default level's
`fcmp.olt.bf16` in gatedRmsNorm is `fcmp.olt.f32` here: the optimizer
narrows `g < 0.0f` for `g = float(gate[index])` through the local; the
semantics compares `bfloat`s through widening, so the core keeps it. -/

theorem affineRow_inventory :
    ((frontend affineRowText).bind elaborateO0).map inventory = some
      [("fadd.bf16", 7), ("fadd.f32", 2), ("fsub.f32", 10), ("fmul.f32", 3), ("fdiv.f32", 7),
       ("llvm.fmuladd.f32", 11), ("air.simd_sum.f32", 1), ("air.wg.barrier", 1), ("fpext bf16→f32", 11),
       ("fptrunc f32→bf16", 1), ("bitcast i32→f32", 10)] := by
  decide +kernel

theorem affineRow_inventoryDefault :
    ((frontend affineRowText).bind elaborate).map inventoryDefault = some
      [("fadd.bf16", 7), ("fadd.f32", 12), ("fmul.f32", 10), ("llvm.fmuladd.f32", 11),
       ("air.simd_sum.f32", 1), ("air.wg.barrier", 1), ("fpext bf16→f32", 11), ("fptrunc f32→bf16", 1),
       ("bitcast i32→f32", 10)] := by
  decide +kernel

theorem siluRmsHeads_inventory :
    ((frontend siluRmsHeadsText).bind elaborateO0).map inventory = some
      [("fadd.bf16", 1), ("fadd.f32", 1), ("fsub.bf16", 1), ("fmul.bf16", 3), ("fmul.f32", 1),
       ("fdiv.bf16", 1), ("fdiv.f32", 1), ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1),
       ("air.fast_fabs.f32", 1), ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 1), ("fcmp.olt.bf16", 1),
       ("fpext bf16→f32", 4), ("fptrunc f32→bf16", 3)] := by
  decide +kernel

theorem siluRmsHeads_inventoryDefault :
    ((frontend siluRmsHeadsText).bind elaborate).map inventoryDefault = some
      [("fadd.bf16", 1), ("fadd.f32", 1), ("fsub.bf16", 1), ("fmul.bf16", 3), ("fmul.f32", 2),
       ("fdiv.bf16", 1), ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1), ("air.fast_fabs.f32", 1),
       ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 1), ("fcmp.olt.bf16", 1), ("fpext bf16→f32", 4),
       ("fptrunc f32→bf16", 3)] := by
  decide +kernel

theorem gatedDeltaStep_inventory :
    ((frontend gatedDeltaStepText).bind elaborateO0).map inventory = some
      [("fsub.f32", 1), ("fmul.f32", 2), ("llvm.fmuladd.f32", 3), ("air.simd_sum.f32", 2),
       ("fpext bf16→f32", 5), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem gatedDeltaStep_inventoryDefault :
    ((frontend gatedDeltaStepText).bind elaborate).map inventoryDefault = some
      [("fsub.f32", 1), ("fmul.f32", 2), ("llvm.fmuladd.f32", 3), ("air.simd_sum.f32", 2),
       ("fpext bf16→f32", 5), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem gatedRmsNorm_inventory :
    ((frontend gatedRmsNormText).bind elaborateO0).map inventory = some
      [("fadd.f32", 2), ("fsub.f32", 1), ("fmul.bf16", 1), ("fmul.f32", 3), ("fdiv.f32", 2),
       ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1), ("air.fast_fabs.f32", 1), ("air.rsqrt.f32", 1),
       ("air.simd_sum.f32", 1), ("fcmp.olt.f32", 1), ("fpext bf16→f32", 4), ("fptrunc f32→bf16", 2)] := by
  decide +kernel

theorem gatedRmsNorm_inventoryDefault :
    ((frontend gatedRmsNormText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 2), ("fsub.f32", 1), ("fmul.bf16", 1), ("fmul.f32", 4), ("fdiv.f32", 1),
       ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1), ("air.fast_fabs.f32", 1), ("air.rsqrt.f32", 1),
       ("air.simd_sum.f32", 1), ("fcmp.olt.f32", 1), ("fpext bf16→f32", 4), ("fptrunc f32→bf16", 2)] := by
  decide +kernel

theorem residualRmsNorm_inventory :
    ((frontend residualRmsNormText).bind elaborateO0).map inventory = some
      [("fadd.f32", 2), ("fmul.bf16", 1), ("fmul.f32", 1), ("fdiv.f32", 1), ("llvm.fmuladd.f32", 1),
       ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 3), ("fpext bf16→f32", 4),
       ("fptrunc f32→bf16", 2)] := by
  decide +kernel

theorem residualRmsNorm_inventoryDefault :
    ((frontend residualRmsNormText).bind elaborate).map inventoryDefault = some
      [("fadd.bf16", 1), ("fadd.f32", 1), ("fmul.bf16", 1), ("fmul.f32", 1), ("fdiv.f32", 1),
       ("llvm.fmuladd.f32", 1), ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 3),
       ("fpext bf16→f32", 2), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem gateUp_inventory :
    ((frontend gateUpText).bind elaborateO0).map inventory = some
      [("fadd.f32", 3), ("fsub.f32", 1), ("fmul.f32", 5), ("fdiv.f32", 1), ("fneg.f32", 1),
       ("air.fma.f32", 4), ("air.exp.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 1),
       ("fpext f16→f32", 2), ("fpext bf16→f32", 5), ("fptrunc f32→bf16", 5), ("bitcast i32→f32", 2)] := by
  decide +kernel

theorem gateUp_inventoryDefault :
    ((frontend gateUpText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 4), ("fmul.bf16", 2), ("fmul.f32", 3), ("fdiv.f32", 1), ("fneg.f32", 1),
       ("air.fma.f32", 4), ("air.exp.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 1),
       ("fpext f16→f32", 2), ("fpext bf16→f32", 1), ("fptrunc f32→bf16", 3), ("bitcast i32→f32", 2)] := by
  decide +kernel

theorem downPartial_inventory :
    ((frontend downPartialText).bind elaborateO0).map inventory = some
      [("fadd.f32", 1), ("fsub.f32", 1), ("fmul.f32", 3), ("air.fma.f32", 2), ("air.wg.barrier", 3),
       ("fpext f16→f32", 2), ("fpext bf16→f32", 2), ("bitcast i32→f32", 1)] := by
  decide +kernel

theorem downPartial_inventoryDefault :
    ((frontend downPartialText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 2), ("fmul.f32", 3), ("air.fma.f32", 2), ("air.wg.barrier", 3), ("fpext f16→f32", 2),
       ("fpext bf16→f32", 2), ("bitcast i32→f32", 1)] := by
  decide +kernel

theorem downFold_inventory :
    ((frontend downFoldText).bind elaborateO0).map inventory = some
      [("air.simd_sum.f32", 1), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem downFold_inventoryDefault :
    ((frontend downFoldText).bind elaborate).map inventoryDefault = some
      [("air.simd_sum.f32", 1), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem argmaxPartial_inventory :
    ((frontend argmaxPartialText).bind elaborateO0).map inventory = some
      [("fsub.bf16", 1), ("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2),
       ("air.wg.barrier", 1), ("air.min.u.i32", 1), ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3),
       ("fpext bf16→f32", 1), ("bitcast f32→i32", 1)] := by
  decide +kernel

theorem argmaxPartial_inventoryDefault :
    ((frontend argmaxPartialText).bind elaborate).map inventoryDefault = some
      [("fsub.bf16", 1), ("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2),
       ("air.wg.barrier", 1), ("air.min.u.i32", 1), ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3),
       ("fpext bf16→f32", 1), ("bitcast f32→i32", 1)] := by
  decide +kernel

theorem argmaxFinish_inventory :
    ((frontend argmaxFinishText).bind elaborateO0).map inventory = some
      [("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2), ("air.wg.barrier", 1),
       ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3)] := by
  decide +kernel

theorem argmaxFinish_inventoryDefault :
    ((frontend argmaxFinishText).bind elaborate).map inventoryDefault = some
      [("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2), ("air.wg.barrier", 1),
       ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3)] := by
  decide +kernel

/-! ## Typing rules on small kernels -/

/-- A kernel around `body`: float, bfloat, int and half buffers 0-3 and the
SIMD lane `i`. -/
def unit (body : List Char) : List Char :=
  chars!"[[kernel]] void k(device float* a [[buffer(0)]], device bfloat16_t* b [[buffer(1)]], device int* n [[buffer(2)]], const device half* h [[buffer(3)]], uint i [[thread_index_in_simdgroup]]) {\n" ++
    body ++ chars!"\n}\n"

def coreOf (body : List Char) : Option Core.Kernel := (frontend (unit body)).bind elaborate
def coreO0 (body : List Char) : Option Core.Kernel := (frontend (unit body)).bind elaborateO0

/-- The values the top-level statements store, and set. -/
def stored : Option Core.Kernel → List CExpr
  | some k => k.body.filterMap fun | .store _ _ v => some v | _ => none
  | none => []

def sets : Option Core.Kernel → List CExpr
  | some k => k.body.filterMap fun | .set _ v => some v | _ => none
  | none => []

def word (e : CExpr) : Option (Scalar × Nat) :=
  match e with
  | .lit v => v.word
  | _ => none

def isMul : CExpr → Bool
  | .bin .mul .f32 0 _ _ => true
  | _ => false

def contracted : CExpr → Bool
  | .bin .add .f32 s a b => s != 0 && (isMul a || isMul b)
  | .bin .sub .f32 s a b => s != 0 && (isMul a || isMul b)
  | _ => false

def plain : CExpr → Bool
  | .bin .add .f32 0 _ _ | .bin .sub .f32 0 _ _ => true
  | _ => false

/-- An `f32` `+`/`-` whose operand is an `f32` `*` is a contraction site
(left product kept as the left operand, `c - a*b` and compound `+=`
included); not through a slot, a negation, or a division turned into a
product. -/
theorem contraction :
    (stored (coreOf chars!"a[0] = a[1] * a[2] + a[3];")).all contracted = true ∧
    (match stored (coreOf chars!"a[0] = a[1] * a[2] + a[3] * a[4];") with
      | [.bin .add .f32 s (.bin .mul .f32 0 _ _) (.bin .mul .f32 0 _ _)] => s != 0
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = a[3] - a[1] * a[2];") with
      | [.bin .sub .f32 s _ (.bin .mul .f32 0 _ _)] => s != 0
      | _ => false) = true ∧
    (sets (coreOf chars!"float t = a[0]; t += a[1] * a[2]; a[0] = t;")).any contracted = true ∧
    (stored (coreOf chars!"float t = a[1] * a[2]; a[0] = t + a[3];")).all plain = true ∧
    (match stored (coreOf chars!"a[0] = -(a[1] * a[2]) + a[3];") with
      | [.bin .add .f32 0 (.un .neg .f32 (.bin .mul .f32 0 _ _)) _] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = a[1] / 8.0f + a[3];") with
      | [.bin .add .f32 0 (.conv .f32 (.bin .mul .f32 0 _ r)) _] => word r == some (.f32, 0x3E000000)
      | _ => false) = true ∧
    (match stored (coreO0 chars!"a[0] = a[1] / 8.0f + a[3];") with
      | [.bin .add .f32 0 (.bin .div .f32 0 _ _) _] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = a[1] / 3.0f;") with
      | [.bin .div .f32 0 _ _] => true
      | _ => false) = true := by
  decide +kernel

/-- `bfloat` with `bfloat` or an integer computes in `bfloat` (the integer
converted at compile time); with `float`, in `float`. `float` → `bfloat` is
only explicit; `half` only widens explicitly and has no arithmetic; a
`bfloat` contraction (`llvm.fmuladd.bf16`) is rejected. -/
theorem conversions :
    (match stored (coreOf chars!"b[0] = 1 + b[1];") with
      | [.bin .add .bf16 0 one (.load (.scalar .bf16) _)] => word one == some (.bf16, 0x3F80)
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = b[0] + 2.0f;") with
      | [.bin .add .f32 0 (.conv .f32 (.load (.scalar .bf16) _)) _] => true
      | _ => false) = true ∧
    (coreOf chars!"b[0] = a[0];").isNone = true ∧
    (match stored (coreOf chars!"b[0] = bfloat16_t(a[0]);") with
      | [.conv .bf16 (.load (.scalar .f32) _)] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = float(h[0]);") with
      | [.conv .f32 (.load (.scalar .f16) _)] => true
      | _ => false) = true ∧
    (coreOf chars!"a[0] = h[0];").isNone = true ∧
    (coreOf chars!"a[0] = float(h[0] + h[1]);").isNone = true ∧
    (coreOf chars!"b[0] = b[1] * b[2] + b[3];").isNone = true ∧
    (match stored (coreOf chars!"n[0] = 0xffffffff + 1;") with
      | [v] => word v == some (.i32, 0)
      | _ => false) = true ∧
    (coreOf chars!"n[0] = 2147483647 + 1;").isNone = true ∧
    (match stored (coreOf chars!"a[0] = -INFINITY;") with
      | [v] => word v == some (.f32, 0xFF800000)
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = as_type<float>(n[0]) + as_type<float>(0x3F800000u);") with
      | [.bin .add .f32 0 (.bitcast .f32 (.load (.scalar .i32) _)) one] => word one == some (.f32, 0x3F800000)
      | _ => false) = true := by
  decide +kernel

/-- The default level narrows `bfloat(op(float(x), float(y)))` to the
`bfloat` operation; a candidate it might narrow through a slot is rejected;
a `half`-exact constant operand blocks the narrowing (probed). -/
theorem narrowing :
    (match stored (coreOf chars!"b[0] = bfloat16_t(float(b[1]) + float(b[2]));") with
      | [.bin .add .bf16 0 (.load (.scalar .bf16) _) (.load (.scalar .bf16) _)] => true
      | _ => false) = true ∧
    (match stored (coreO0 chars!"b[0] = bfloat16_t(float(b[1]) + float(b[2]));") with
      | [.conv .bf16 (.bin .add .f32 0 (.conv .f32 _) (.conv .f32 _))] => true
      | _ => false) = true ∧
    (coreOf chars!"const float p = float(b[1]) * float(b[2]); b[0] = bfloat16_t(p);").isNone = true ∧
    (coreOf chars!"const float g = float(b[1]); b[0] = bfloat16_t(g + float(b[2]));").isNone = true ∧
    (match stored (coreOf chars!"b[0] = bfloat16_t(float(b[1]) * 2.0f);") with
      | [.conv .bf16 (.bin .mul .f32 0 (.conv .f32 _) _)] => true
      | _ => false) = true := by
  decide +kernel

/-- Built-ins: their core operations, MLX's bfloat overloads (widen, the
float operation, narrow), integer `min` on equal types only, collectives
with the `ushort` delta, barrier flags; conditions convert to `bool`; `?:`
is lazy. -/
theorem builtins :
    (match stored (coreOf chars!"b[0] = metal::exp(b[1]);") with
      | [.conv .bf16 (.un .fastExp .f32 (.conv .f32 _))] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = metal::precise::exp(a[1]) + metal::abs(a[2]) + metal::precise::rsqrt(a[3]);") with
      | [.bin .add .f32 0 (.bin .add .f32 0 (.un .exp .f32 _) (.un .fastFabs .f32 _)) (.un .rsqrt .f32 _)] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"a[0] = metal::fma(a[1], a[2], a[3]);") with
      | [.fma _ _ _] => true
      | _ => false) = true ∧
    (match stored (coreOf chars!"n[0] = min(n[1], n[2]);") with
      | [.bin .min .i32 0 _ _] => true
      | _ => false) = true ∧
    (coreOf chars!"n[0] = min(n[1], i);").isNone = true ∧
    (match (coreOf chars!"b[0] = simd_sum(b[1]);").map (·.body) with
      | some [_, _, _, _, .collective 1 s .sum .f32 (.conv .f32 _) _, .store _ _ (.conv .bf16 (.local s'))] => s == s'
      | _ => false) = true ∧
    (match (coreOf chars!"a[0] = simd_shuffle_down(a[1], i);").map (·.body) with
      | some [_, _, _, _, .collective 1 _ .shuffleDown .f32 _ (.conv .u16 (.coord .threadIndexInSimdgroup)), _] => true
      | _ => false) = true ∧
    (match (coreOf chars!"threadgroup_barrier(mem_flags::mem_threadgroup | mem_flags::mem_device); threadgroup_barrier(metal::mem_flags::mem_threadgroup);").map (·.body) with
      | some [_, _, _, _, .barrier 1 true true, .barrier 2 false true] => true
      | _ => false) = true ∧
    (match (coreOf chars!"if (n[0]) a[0] = isnan(a[1]) ? 1.0f : 0.0f;").map (·.body) with
      | some [_, _, _, _, .ite (.conv .bool (.load (.scalar .i32) _)) [.store _ _ (.cond (.un .isnan .f32 _) _ _)] []] => true
      | _ => false) = true := by
  decide +kernel

/-- A template kernel: template arguments bind its parameters, `constexpr`
values and array extents fold (threadgroup and thread arrays numbered in
order, `= {0}` zero-filled, 2-D arrays flattened), constant conditions
keep only the live branch. -/
def templated : List Char :=
  chars!"template <int K, typename T>\n[[kernel]] void k(device float* a [[buffer(0)]], device T* b [[buffer(1)]]) {\n  constexpr int N = 2 * K;\n  threadgroup float s[N];\n  thread float t[K][2];\n  float r[4] = {0};\n  if (K == 3) s[0] = r[1]; else s[1] = r[2];\n  a[0] = s[0] + t[1][1];\n  b[0] = T(a[1]);\n}\ntemplate [[host_name(\"k\")]] [[kernel]] decltype(k<3, bfloat16_t>) k<3, bfloat16_t>;\n"

theorem template_kernel :
    (match (frontend templated).bind elaborate with
      | some k =>
        k.buffers == 2 && k.threadgroupArrays == [(.scalar .f32, 6)] &&
          k.threadArrays == [(.scalar .f32, 6), (.scalar .f32, 4)] &&
          !k.body.any (fun | .ite .. => true | _ => false) &&
          (match stored (some k) with
            | [z0, _, _, _, .load _ _, .bin .add .f32 0 _ _, .conv .bf16 _] => word z0 == some (.f32, 0)
            | _ => false)
      | none => false) = true := by
  decide +kernel

/-- Header functions inline at each call (template arguments explicit);
each inlined contraction gets its own site. -/
def inlined : List Char :=
  chars!"template <int B> inline float f(float x, float y) { return x * B + y; }\n[[kernel]] void k(device float* a [[buffer(0)]]) {\n  a[0] = f<4>(a[1], a[2]) + f<4>(a[3], a[4]);\n}\n"

theorem inlining :
    (match (frontend inlined).bind elaborate with
      | some k => siteS 1000 k.body == [1, 2] &&
        (match k.body with
          | [_, _, _, .scope _, _, _, .scope _, .store _ _ (.bin .add .f32 0 (.local _) (.local _))] => true
          | _ => false)
      | none => false) = true := by
  decide +kernel

/-- Outside the modeled subset: a kernel-level `return`, an assignment inside
an expression, a float → integer conversion. -/
theorem rejected :
    (coreOf chars!"if (i == 0) return; a[0] = 1.0f;").isNone = true ∧
    (coreOf chars!"a[0] = (a[1] = 2.0f);").isNone = true ∧
    (coreOf chars!"n[0] = int(a[0]);").isNone = true := by
  decide +kernel

end Metal.Elab.Tests
