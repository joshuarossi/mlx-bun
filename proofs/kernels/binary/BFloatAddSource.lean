import kernels.copy.ScalarCopySyntax
import contracts.mlx.BinaryMemory
import contracts.mlx.ElementwiseAdd

namespace Inference.Kernels.Binary.BFloatAddSource
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx
open Copy.ScalarCopySyntax (tokenize accept nameToken)

-- The pinned helper has builtin bfloat operands and result, not explicit
-- float promotion/casts. This restricted parser covers its complete body;
-- template/type/dispatch selection and physical builtin conformance are separate.
inductive Expr where
  | var : String → Expr
  | plus : Expr → Expr → Expr
  deriving DecidableEq, Repr

structure Body where
  result : Expr
  deriving DecidableEq, Repr

def parseTokens (tokens : List String) : Option Body := do
  let rest ← accept "{" tokens
  let rest ← accept "return" rest
  let (left, rest) ← nameToken rest
  let rest ← accept "+" rest
  let (right, rest) ← nameToken rest
  let rest ← accept ";" rest
  let rest ← accept "}" rest
  if rest.isEmpty then pure ⟨.plus (.var left) (.var right)⟩ else none

def parseBody (source : String) : Option Body := do parseTokens (←tokenize source)
def sourceBody : String := "{\n    return x + y;\n  }"
def body : Body := ⟨.plus (.var "x") (.var "y")⟩
theorem parsed_body : parseBody sourceBody = some body := by decide +kernel

abbrev BF := BFloat16Arithmetic.Value
abbrev Environment := String → BF

-- A declared logical machine for builtin bfloat: nearest-even BF16 arithmetic
-- with input and output subnormal flushing. No claim that Metal implements this
-- machine follows from parsing. Model.add retains its signed-zero/NaN/Inf rules.
inductive Evaluates (environment : Environment) : Expr → BF → Prop where
  | var (name : String) : Evaluates environment (.var name) (environment name)
  | plus {left right : Expr} {x y : BF} :
      Evaluates environment left x → Evaluates environment right y →
      Evaluates environment (.plus left right)
        (BFloat16Arithmetic.flush (Model.add (BFloat16Arithmetic.flush x) (BFloat16Arithmetic.flush y)))

def environment (x y : BF) : Environment := fun name => if name="x" then x else y

theorem deterministic {env : Environment} {expression : Expr} {x y : BF}
    (first : Evaluates env expression x) (second : Evaluates env expression y) : x=y := by
  induction first generalizing y with
  | var => cases second; rfl
  | plus firstLeft firstRight ihLeft ihRight =>
    cases second with
    | plus secondLeft secondRight => rw [ihLeft secondLeft, ihRight secondRight]

theorem execution (x y : BF) : Evaluates (environment x y) body.result (BFloat16Arithmetic.add x y) := by
  apply Evaluates.plus
  · simpa [environment] using Evaluates.var (environment := environment x y) "x"
  · simpa [environment] using Evaluates.var (environment := environment x y) "y"

theorem any_execution (x y result : BF)
    (run : Evaluates (environment x y) body.result result) : result=BFloat16Arithmetic.add x y :=
  deterministic run (execution x y)

theorem parsed_execution (x y result : BF) {parsed : Body}
    (source : parseBody sourceBody=some parsed)
    (run : Evaluates (environment x y) parsed.result result) : result=BFloat16Arithmetic.add x y := by
  have equal : parsed=body := Option.some.inj (source.symm.trans parsed_body)
  subst parsed
  exact any_execution x y result run

theorem finite (x y result : BF) (run : Evaluates (environment x y) body.result result)
    (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (capacity : |Model.toReal x|+|Model.toReal y|≤Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) :
    Model.isFinite result=true := by
  rw [any_execution x y result run]
  exact BFloat16Arithmetic.add_finite x y hx hy capacity

theorem error (x y result : BF) (run : Evaluates (environment x y) body.result result)
    (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (capacity : |Model.toReal x|+|Model.toReal y|≤Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) :
    |Model.toReal result-(Model.toReal x+Model.toReal y)|≤BFloat16Arithmetic.addBudget x y := by
  rw [any_execution x y result run]
  exact BFloat16Arithmetic.add_error x y hx hy (BFloat16Arithmetic.raw_add_finite x y hx hy capacity)

-- The existing shared-heap constructor now consumes the operation determined by
-- this parsed scalar body. Its ownership/array execution remains BinaryMemory's
-- model; this is not a parsed binary_vv load/store or compiler proof.
def operation (x y : BF) : BF := BFloat16Arithmetic.flush
  (Model.add (BFloat16Arithmetic.flush x) (BFloat16Arithmetic.flush y))

theorem operation_eq : operation=BFloat16Arithmetic.add := rfl

def fromBuffers {n : Nat} {left right : Fin n → BF} (input : BinaryMemory.Input left right)
    (base : Nat) (bounded : 2*base+2*n≤2^64)
    (leftSafe : input.lhs.base/2=base ∨ MemoryRegions.Disjoint input.lhs.base (2*n) (2*base) (2*n))
    (rightSafe : input.rhs.base/2=base ∨ MemoryRegions.Disjoint input.rhs.base (2*n) (2*base) (2*n)) :
    BinaryMemory.Execution input operation := BinaryMemory.fromBuffers input operation base bounded leftSafe rightSafe

theorem buffer_read {n : Nat} {left right : Fin n → BF} {input : BinaryMemory.Input left right}
    (run : BinaryMemory.Execution input operation) (i : Fin n) :
    HalfMemory.load run.trace.memory (run.buffer.base+2*i.val)=
      ArrayStorage.bits (ElementwiseAdd.forward left right i) := run.buffer.attached i

-- 5120 BF16 residual elements are below the native work-per-thread threshold.
-- Native contiguous metadata extraction and operator/template lookup are not
-- inferred from array buffers by this arithmetic proof.
def residualCount : Nat := 1*5120
def work : Nat := if residualCount<65536 then 1 else max 1 (8/2)
def grid : Nat := (residualCount+work-1)/work
def group (maxThreads : Nat) : Nat := min maxThreads grid

theorem selected_dispatch : work=1 ∧ grid=5120 ∧ residualCount<2^32 := by decide +kernel
theorem group_positive {maxThreads : Nat} (positive : 0<maxThreads) : 0<group maxThreads := by
  change 0<min maxThreads grid
  exact lt_min positive (by decide +kernel)

end Inference.Kernels.Binary.BFloatAddSource
