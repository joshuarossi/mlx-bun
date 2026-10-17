import kernels.trellis.CodebookWindowSyntax
import kernels.trellis.CodebookIntegerSemantics
import kernels.trellis.Codebook
namespace Inference.Kernels.Trellis.CodebookWindowSemantics
open CodebookWindowSyntax
set_option maxRecDepth 10000

-- Local private uint arrays are represented symbolically, retaining the actual
-- selected read index and each bit operation. Integer arithmetic executes now;
-- evaluating WordExpr later performs the actual private-register array reads.
inductive WordExpr where
  | read : String → Nat → WordExpr
  | shiftRight : WordExpr → Nat → WordExpr
  | bitAnd : WordExpr → BitVec 32 → WordExpr
  deriving DecidableEq,Repr

def WordExpr.evaluate (arrays : String → Nat → BitVec 32) : WordExpr → BitVec 32
  | .read name index => arrays name index
  | .shiftRight value count => value.evaluate arrays >>> count
  | .bitAnd value mask => value.evaluate arrays &&& mask

inductive Value where
  | signed : Int → Value
  | unsigned : BitVec 32 → Value
  | boolean : Bool → Value
  | word : WordExpr → Value
abbrev Environment := String → Option Value
def set (env : Environment) (name : String) (value : Option Value) : Environment :=
  fun other => if other=name then value else env other

def signed (n : Int) : Option Value :=
  if CodebookIntegerSemantics.representable n then some (.signed n) else none

def shift (left : Value) (count : Nat) : Option Value :=
  if count<32 then match left with
  | .unsigned value => some (.unsigned (value >>> count))
  | .signed value => if 0≤value then signed (Int.ofNat (value.toNat / 2^count)) else none
  | .word value => some (.word (.shiftRight value count))
  | _ => none
  else none

def evaluate (env : Environment) : Expr → Option Value
  | .variable name => env name
  | .literal .signed n => signed n
  | .literal .unsigned n => if n<2^32 then some (.unsigned (BitVec.ofNat 32 n)) else none
  | .index name index => do
    match ←evaluate env index with
    | .signed value => if 0≤value then pure (.word (.read name value.toNat)) else none
    | .unsigned value => pure (.word (.read name value.toNat))
    | _ => none
  | .castInt value => do
    match ←evaluate env value with
    | .unsigned a => if a.toNat<2^31 then pure (.signed a.toInt) else none
    | _ => none
  | .castUInt value => do
    match ←evaluate env value with
    | .signed a => if 0≤a ∧ a<2^32 then pure (.unsigned (BitVec.ofInt 32 a)) else none
    | _ => none
  | .add left right => do
    match ←evaluate env left,←evaluate env right with
    | .signed a,.signed b => signed (a+b)
    | .unsigned a,.unsigned b => pure (.unsigned (a+b))
    | _,_ => none
  | .subtract left right => do
    match ←evaluate env left,←evaluate env right with
    | .signed a,.signed b => signed (a-b)
    | .unsigned a,.unsigned b => pure (.unsigned (a-b))
    | _,_ => none
  | .multiply left right => do
    match ←evaluate env left,←evaluate env right with
    | .signed a,.signed b => signed (a*b)
    | .unsigned a,.unsigned b => pure (.unsigned (a*b))
    | _,_ => none
  | .bitAnd left right => do
    match ←evaluate env left,←evaluate env right with
    | .unsigned a,.unsigned b => pure (.unsigned (a &&& b))
    | .signed a,.signed b => if 0≤a ∧ 0≤b then signed (Int.ofNat (a.toNat &&& b.toNat)) else none
    | .word a,.unsigned b => pure (.word (.bitAnd a b))
    | _,_ => none
  | .shiftLeft left right => do
    match ←evaluate env left,←evaluate env right with
    | .unsigned a,.unsigned b => if b.toNat<32 then pure (.unsigned (a <<< b.toNat)) else none
    | _,_ => none
  | .shiftRight left right => do
    let a ←evaluate env left
    match ←evaluate env right with
    | .signed b => if 0≤b then shift a b.toNat else none
    | .unsigned b => shift a b.toNat
    | _ => none
  | .ge left right => do
    match ←evaluate env left,←evaluate env right with
    | .signed a,.signed b => pure (.boolean (decide (b≤a)))
    | .unsigned a,.unsigned b => pure (.boolean (decide (b.toNat≤a.toNat)))
    | _,_ => none
  | .le left right => do
    match ←evaluate env left,←evaluate env right with
    | .signed a,.signed b => pure (.boolean (decide (a≤b)))
    | .unsigned a,.unsigned b => pure (.boolean (decide (a.toNat≤b.toNat)))
    | _,_ => none
  | .logicalAnd left right => do
    match ←evaluate env left with
    | .boolean false => pure (.boolean false)
    | .boolean true => match ←evaluate env right with
      | .boolean value => pure (.boolean value)
      | _ => none
    | _ => none

inductive Outcome where
  | state : Environment → Outcome
  | returned : WordExpr → Outcome

def execute : Nat → List Stmt → Environment → Option Outcome
  | 0,_,_ => none
  | _+1,[],env => some (.state env)
  | fuel+1,.constInt name value::rest,env => do
    match ←evaluate env value with
    | .signed v => execute fuel rest (set env name (some (.signed v)))
    | _ => none
  | fuel+1,.constUInt name value::rest,env => do
    match ←evaluate env value with
    | .unsigned v => execute fuel rest (set env name (some (.unsigned v)))
    | .word v => execute fuel rest (set env name (some (.word v)))
    | _ => none
  | fuel+1,.declareUInt name::rest,env => execute fuel rest (set env name none)
  | fuel+1,.assignUInt name value::rest,env => do
    match ←evaluate env value with
    | .unsigned v => execute fuel rest (set env name (some (.unsigned v)))
    | .word v => execute fuel rest (set env name (some (.word v)))
    | _ => none
  | fuel+1,.ifElse test yes no::rest,env => do
    match ←evaluate env test with
    | .boolean chosen =>
      match ←execute fuel (if chosen then yes else no) env with
      | .state next => execute fuel rest next
      | .returned value => pure (.returned value)
    | _ => none
  | _+1,[.returnTable base offset],env =>
    if base="table" then do
      match ←evaluate env offset with
      | .word value => some (.returned value)
      | _ => none
    else none
  | _+1,.returnTable _ _::_::_,_ => none

def initial (offset : Nat) : Environment := fun name =>
  if name="off" then some (.unsigned (BitVec.ofNat 32 offset))
  else if name="l" then some (.unsigned 12) else none

def result (code : List Stmt) (offset : Nat) : Option WordExpr := do
  match ←execute 32 code (initial offset) with
  | .returned value => some value
  | _ => none

def expected (offset : Nat) : WordExpr :=
  if 2≤offset ∧ (offset-2)%32+14≤32 then
    .bitAnd (.shiftRight (.read "w" ((offset-2)/32)) ((offset-2)%32)) 16383
  else .bitAnd (.shiftRight (.read "v" ((offset+14)/32)) ((offset+14)%32)) 16383

-- Finite proof covers all possible selected gate/up offsets (0..124), hence
-- also the down lane offsets (0..60). No packed input-word value is enumerated.
theorem symbolic_result : ∀ offset : Fin 125, result body offset.val=some (expected offset.val) := by decide +kernel

def arrays (words : Nat → BitVec 32) : String → Nat → BitVec 32 := fun name =>
  if name="w" then words else if name="v" then Codebook.CodebookWindow.virtualWord words else fun _ => 0

theorem expected_evaluate (words : Nat → BitVec 32) (offset : Nat) :
    (expected offset).evaluate (arrays words)=Codebook.CodebookWindow.byteOffset words offset := by
  unfold expected Codebook.CodebookWindow.byteOffset
  split <;> rfl

def byteOffset (words : Nat → BitVec 32) (offset : Nat) : Option (BitVec 32) := do
  let code ←parse sourceBody
  let symbolic ←result code offset
  pure (symbolic.evaluate (arrays words))

theorem source_byteOffset (words : Nat → BitVec 32) (offset : Nat) (bounded : offset≤124) :
    byteOffset words offset=some (Codebook.CodebookWindow.byteOffset words offset) := by
  simp only [byteOffset,parsed_body]
  change ((result body offset).bind (fun symbolic => some (symbolic.evaluate (arrays words))))=_
  have source := symbolic_result ⟨offset,by omega⟩
  rw [show result body offset=some (expected offset) from source]
  exact congrArg some (expected_evaluate words offset)
-- General actual-array interface. Only subsequent linkage to the mathematical
-- byteOffset uses the explicit virtual-word construction identity.
def executeArrays (actual : String → Nat → BitVec 32) (offset : Nat) : Option (BitVec 32) := do
  let code ←parse sourceBody
  let symbolic ←result code offset
  pure (symbolic.evaluate actual)

theorem actual_arrays (actual : String → Nat → BitVec 32) (offset : Nat) (bounded : offset≤124) :
    executeArrays actual offset=some ((expected offset).evaluate actual) := by
  unfold executeArrays
  rw [parsed_body]
  change ((result body offset).bind (fun symbolic => some (symbolic.evaluate actual)))=_
  rw [show result body offset=some (expected offset) from symbolic_result ⟨offset,by omega⟩]
  rfl

theorem linked_arrays (actual : String → Nat → BitVec 32) (words : Nat → BitVec 32)
    (wordLink : actual "w"=words) (virtualLink : actual "v"=Codebook.CodebookWindow.virtualWord words)
    (offset : Nat) (bounded : offset≤124) :
    executeArrays actual offset=some (Codebook.CodebookWindow.byteOffset words offset) := by
  rw [actual_arrays actual offset bounded]
  unfold expected Codebook.CodebookWindow.byteOffset
  split <;> simp only [WordExpr.evaluate,wordLink,virtualLink] <;> rfl

end Inference.Kernels.Trellis.CodebookWindowSemantics
