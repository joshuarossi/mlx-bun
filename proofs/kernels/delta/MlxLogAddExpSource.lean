import kernels.delta.MlxLogAddExpSyntax
import kernels.delta.Softplus
namespace Inference.Kernels.Delta.MlxLogAddExpSource
open Contracts.Mlx BFloat16Arithmetic
open FloatLib.Floats.Formats.BinaryInterchange
open MlxLogAddExpSyntax (Expr Call Return)
set_option maxRecDepth 10000
attribute [local irreducible] MlxLogAddExpSyntax.parseNan MlxLogAddExpSyntax.parseInfinity
  MlxLogAddExpSyntax.parseCall MlxLogAddExpSyntax.parseReturn

-- metal::max/min remain scalar compiler primitives comparing flushed
-- operands. These flags specify their equal-operand choice, including
-- distinct signed-zero and subnormal bit patterns. No claim about the
-- installed compiler's tie choices is made here.
structure Policy where
  maximumLeft : Bool
  minimumLeft : Bool
  deriving DecidableEq,Repr

def maximum (leftTie : Bool) (x y : Value) : Value :=
  if Model.compare (flush x) (flush y)=some .lt then y else
    if Model.compare (flush x) (flush y)=some .gt then x else if leftTie then x else y
def minimum (leftTie : Bool) (x y : Value) : Value :=
  if Model.compare (flush x) (flush y)=some .lt then x else
    if Model.compare (flush x) (flush y)=some .gt then y else if leftTie then x else y

def legacyPolicy : Policy := ⟨true,false⟩

theorem maximum_finite (policy : Bool) (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true) :
    Model.isFinite (maximum policy x y)=true := by
  unfold maximum
  split
  · exact hy
  · split
    · exact hx
    · split <;> assumption

theorem minimum_finite (policy : Bool) (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true) :
    Model.isFinite (minimum policy x y)=true := by
  unfold minimum
  split
  · exact hx
  · split
    · exact hy
    · split <;> assumption

theorem maximum_zero (x : Value) : maximum true x Trellis.GateUpSplitTail.zero=Softplus.top x := by
  simp only [maximum,Softplus.top,Trellis.GateUpSplitTail.negative,Trellis.GateUpSplitTail.zero,Softplus.flush_zero,
    ite_true,ite_self]
  rfl
theorem minimum_zero (x : Value) : minimum false x Trellis.GateUpSplitTail.zero=Softplus.bottom x := by
  simp only [minimum,Softplus.bottom,Trellis.GateUpSplitTail.negative,Trellis.GateUpSplitTail.zero,Softplus.flush_zero,
    Bool.false_eq_true,ite_false,ite_self]
  rfl


def input (x y : Value) (name : String) : Option Value :=
  if name="x" then some x else if name="y" then some y else none

def call (policy : Policy) (bindings : String→Option Value) (statement : Call) : Option Value := do
  let x ←bindings statement.left
  let y ←bindings statement.right
  if statement.operation="max" then some (maximum policy.maximumLeft x y)
  else if statement.operation="min" then some (minimum policy.minimumLeft x y) else none

def captured (maxName minName : String) (maxval minval : Value) (name : String) : Option Value :=
  if name=maxName then some maxval else if name=minName then some minval else none

def evaluate (exp log1p : Value→Value) (bindings : String→Option Value) : Expr→Option Value
  | .variable name => bindings name
  | .add a b => do pure (add (←evaluate exp log1p bindings a) (←evaluate exp log1p bindings b))
  | .subtract a b => do pure (sub (←evaluate exp log1p bindings a) (←evaluate exp log1p bindings b))
  | .exponential x => (evaluate exp log1p bindings x).map exp
  | .logarithm x => (evaluate exp log1p bindings x).map log1p

def sourceSyntax {α : Type} (body : Call→Call→Return→Option α) : Option α := do
  let _ ←MlxLogAddExpSyntax.parseNan MlxLogAddExpSyntax.nanSource
  let _ ←MlxLogAddExpSyntax.parseInfinity MlxLogAddExpSyntax.infinitySource
  let maxCall ←MlxLogAddExpSyntax.parseCall MlxLogAddExpSyntax.maximumSource
  let minCall ←MlxLogAddExpSyntax.parseCall MlxLogAddExpSyntax.minimumSource
  let ret ←MlxLogAddExpSyntax.parseReturn MlxLogAddExpSyntax.returnSource
  body maxCall minCall ret

theorem syntax_bind {α : Type} (body : Call→Call→Return→Option α) :
    sourceSyntax body=body MlxLogAddExpSyntax.maximum MlxLogAddExpSyntax.minimum MlxLogAddExpSyntax.returned := by
  rw [sourceSyntax,MlxLogAddExpSyntax.parsed_nan,MlxLogAddExpSyntax.parsed_infinity,
    MlxLogAddExpSyntax.parsed_maximum,MlxLogAddExpSyntax.parsed_minimum,MlxLogAddExpSyntax.parsed_return]
  rfl

def phase {α β : Type} (nan finite : Bool) (first second : Option α) (body : α→α→Option β) : Option β := do
  if nan || !finite then none else body (←first) (←second)

theorem phase_eq {α β : Type} (first second : Option α) (body : α→α→Option β) (a b : α)
    (ha : first=some a) (hb : second=some b) : phase false true first second body=body a b := by
  rw [phase,ha,hb]
  rfl

-- This is the finite source phase. The parsed NaN branch is retained, while
-- its quiet-NaN payload and nonfinite arithmetic are outside this theorem.
-- The infinity return guard is interpreted with exact IEEE classification.
def executeFinite (policy : Policy) (exp log1p : Value→Value) (x y : Value) : Option Value :=
  sourceSyntax (fun maxCall minCall ret=>
    phase (Model.isNaN x || Model.isNaN y) (Model.isFinite x && Model.isFinite y)
      (call policy (input x y) maxCall) (call policy (input x y) minCall)
      (fun maxval minval=>do
        if ret.infinity≠"inf" then none else
          let bindings := captured maxCall.target minCall.target maxval minval
          let lo ←bindings ret.minimum
          let hi ←bindings ret.maximum
          if (Model.isInf lo && Model.signBit lo) || (Model.isInf hi && !Model.signBit hi)
          then bindings ret.direct else evaluate exp log1p bindings ret.fallback))

theorem call_maximum (policy : Policy) (x y : Value) :
    call policy (input x y) MlxLogAddExpSyntax.maximum=some (maximum policy.maximumLeft x y) := by
  simp only [call,input,MlxLogAddExpSyntax.maximum]
  rfl

theorem call_minimum (policy : Policy) (x y : Value) :
    call policy (input x y) MlxLogAddExpSyntax.minimum=some (minimum policy.minimumLeft x y) := by
  simp only [call,input,MlxLogAddExpSyntax.minimum]
  rfl

theorem fallback (exp log1p : Value→Value) (hi lo : Value) :
    evaluate exp log1p (captured "maxval" "minval" hi lo) MlxLogAddExpSyntax.returned.fallback=
      some (add hi (log1p (exp (sub lo hi)))) := by
  simp only [MlxLogAddExpSyntax.returned,evaluate,captured]
  rfl

attribute [local irreducible] evaluate call maximum minimum

theorem execution (policy : Policy) (exp log1p : Value→Value) (x y : Value)
    (hx : Model.isFinite x=true) (hy : Model.isFinite y=true) :
    executeFinite policy exp log1p x y=some (add (maximum policy.maximumLeft x y)
      (log1p (exp (sub (minimum policy.minimumLeft x y) (maximum policy.maximumLeft x y))))) := by
  have nanx := Model.isNaN_eq_false_of_isFinite_eq_true x hx
  have nany := Model.isNaN_eq_false_of_isFinite_eq_true y hy
  have maxi := Model.isInf_eq_false_of_isFinite_eq_true _ (maximum_finite policy.maximumLeft x y hx hy)
  have mini := Model.isInf_eq_false_of_isFinite_eq_true _ (minimum_finite policy.minimumLeft x y hx hy)
  rw [executeFinite,syntax_bind]
  simp only [nanx,nany,hx,hy,Bool.false_or,Bool.true_and]
  rw [phase_eq _ _ _ _ _ (call_maximum policy x y) (call_minimum policy x y)]
  dsimp only [MlxLogAddExpSyntax.returned,MlxLogAddExpSyntax.maximum,MlxLogAddExpSyntax.minimum]
  simp only [captured, show ("inf" ≠ "inf") = False from propext (by simp), show ("minval" = "maxval") = False from propext (by decide), if_false, if_true, bind, Option.bind]
  simp only [mini,maxi,Bool.false_and,Bool.false_or,ite_false]
  exact fallback exp log1p _ _

theorem legacy_execution (exp log1p : Value→Value) (x : Value) (hx : Model.isFinite x=true) :
    executeFinite legacyPolicy exp log1p x Trellis.GateUpSplitTail.zero=some (Softplus.value exp log1p x) := by
  rw [execution _ _ _ _ _ hx (by decide)]
  simp only [legacyPolicy,maximum_zero,minimum_zero,Softplus.value,Softplus.difference]

theorem reject_nonfinite (policy : Policy) (exp log1p : Value→Value) (x y : Value)
    (outside : Model.isFinite x=false ∨ Model.isFinite y=false) : executeFinite policy exp log1p x y=none := by
  rw [executeFinite,syntax_bind]
  rcases outside with hx|hy
  · simp [phase,hx]
  · simp [phase,hy]
end Inference.Kernels.Delta.MlxLogAddExpSource
