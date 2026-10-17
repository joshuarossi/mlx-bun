import kernels.trellis.PackedArraySyntax
namespace Inference.Kernels.Trellis.PackedArraySemantics
open PackedArraySyntax
set_option maxRecDepth 10000

-- An affine uint32 address remains symbolic until attached to the ORIGINAL
-- global byte buffer. Addition wraps32 exactly. Global memory is read-only in
-- this grammar: only declared private arrays may be assigned.
inductive Index where
  | constant : BitVec 32 → Index
  | relative : String → BitVec 32 → Index
  deriving DecidableEq,Repr

def Index.evaluate (bases : String → BitVec 32) : Index → BitVec 32
  | .constant n => n
  | .relative name offset => bases name+offset

inductive Word where
  | global : String → Index → Word
  | shiftLeft : Word → Nat → Word
  | shiftRight : Word → Nat → Word
  | bitOr : Word → Word → Word
  deriving DecidableEq,Repr

def Word.evaluate (bases : String → BitVec 32) (global : String → Nat → BitVec 32) : Word → BitVec 32
  | .global name index => global name (index.evaluate bases).toNat
  | .shiftLeft value n => value.evaluate bases global <<< n
  | .shiftRight value n => value.evaluate bases global >>> n
  | .bitOr left right => left.evaluate bases global ||| right.evaluate bases global

inductive Value where
  | signed : Int → Value
  | unsigned : BitVec 32 → Value
  | address : String → BitVec 32 → Value
  | boolean : Bool → Value
  | word : Word → Value
  deriving DecidableEq,Repr

def asUInt : Value → Option (BitVec 32)
  | .signed value => some (BitVec.ofInt 32 value)
  | .unsigned value => some value
  | _ => none

def natural : Value → Option Nat
  | .signed value => if 0≤value then some value.toNat else none
  | .unsigned value => some value.toNat
  | _ => none

def signed (value : Int) : Option Value :=
  if -(2^31)≤value ∧ value<2^31 then some (.signed value) else none

structure PrivateArray where
  dimensions : List Nat
  cells : List (Option Value)
structure State where
  variables : List (String × Value)
  arrays : List (String × PrivateArray)
  globals : List String

def lookup {α : Type} (name : String) : List (String × α) → Option α
  | [] => none
  | (key,value)::rest => if name=key then some value else lookup name rest

def remove {α : Type} (name : String) : List (String × α) → List (String × α)
  | [] => []
  | (key,value)::rest => if name=key then remove name rest else (key,value)::remove name rest

def lookupVariable (state : State) (name : String) : Option Value := lookup name state.variables
def lookupArray (state : State) (name : String) : Option PrivateArray := lookup name state.arrays

def putVariable (state : State) (name : String) (value : Option Value) : State :=
  {state with variables := match value with
    | none => remove name state.variables
    | some value => (name,value)::remove name state.variables}

def putArray (state : State) (name : String) (value : PrivateArray) : State :=
  {state with arrays := (name,value)::remove name state.arrays}

def flatIndex : List Nat → List Nat → Option Nat
  | [],[] => some 0
  | dimension::tail,index::rest => if index<dimension then do
      let offset ←flatIndex tail rest
      pure (index*tail.prod+offset)
    else none
  | _,_ => none

def readGlobal (state : State) (name : String) (index : Index) : Option Value :=
  if name∈state.globals then
    match lookupVariable state name with
    | none => some (.word (.global name index))
    | some (.address base offset) => match index with
      | .constant i => some (.word (.global name (.relative base (offset+i))))
      | _ => none
    | _ => none
  else none

def readArray (state : State) (name : String) (indices : List Value) : Option Value := do
  match lookupArray state name with
  | some array => do
    let indices ←indices.mapM natural
    let index ←flatIndex array.dimensions indices
    (array.cells[index]?).join
  | none => match indices with
    | [.unsigned index] => readGlobal state name (.constant index)
    | [.signed index] => if 0≤index then readGlobal state name (.constant (BitVec.ofInt 32 index)) else none
    | [.address base offset] => readGlobal state name (.relative base offset)
    | _ => none

def add (left right : Value) : Option Value :=
  match left,right with
  | .signed a,.signed b => signed (a+b)
  | .address name offset,b => do pure (.address name (offset+(←asUInt b)))
  | a,.address name offset => do pure (.address name ((←asUInt a)+offset))
  | a,b => do pure (.unsigned ((←asUInt a)+(←asUInt b)))
def subtract (left right : Value) : Option Value :=
  match left,right with
  | .signed a,.signed b => signed (a-b)
  | a,b => do pure (.unsigned ((←asUInt a)-(←asUInt b)))
def multiply (left right : Value) : Option Value :=
  match left,right with
  | .signed a,.signed b => signed (a*b)
  | a,b => do pure (.unsigned ((←asUInt a)*(←asUInt b)))
def divide (left right : Value) : Option Value := do
  let a ←asUInt left
  let b ←asUInt right
  if b.toNat=0 then none else pure (.unsigned (BitVec.ofNat 32 (a.toNat/b.toNat)))
def modulo (left right : Value) : Option Value := do
  let a ←asUInt left
  let b ←asUInt right
  if b.toNat=0 then none else pure (.unsigned (BitVec.ofNat 32 (a.toNat%b.toNat)))

def shift (left right : Value) (isLeft : Bool) : Option Value := do
  let n ←natural right
  if n<32 then match left with
  | .unsigned a => pure (.unsigned (if isLeft then a <<< n else a >>> n))
  | .word a => pure (.word (if isLeft then .shiftLeft a n else .shiftRight a n))
  | _ => none
  else none

def evaluate : Nat → State → Expr → Option Value
  | 0,_,_ => none
  | _fuel+1,state,.variable name => lookupVariable state name
  | _fuel+1,_state,.literal .signed n => signed n
  | _fuel+1,_state,.literal .unsigned n => if n<2^32 then some (.unsigned (BitVec.ofNat 32 n)) else none
  | fuel+1,state,.castUInt value => do pure (.unsigned (←asUInt (←evaluate fuel state value)))
  | fuel+1,state,.index name indices => do readArray state name (←indices.mapM (evaluate fuel state))
  | fuel+1,state,.add left right => do add (←evaluate fuel state left) (←evaluate fuel state right)
  | fuel+1,state,.subtract left right => do subtract (←evaluate fuel state left) (←evaluate fuel state right)
  | fuel+1,state,.multiply left right => do multiply (←evaluate fuel state left) (←evaluate fuel state right)
  | fuel+1,state,.divide left right => do divide (←evaluate fuel state left) (←evaluate fuel state right)
  | fuel+1,state,.modulo left right => do modulo (←evaluate fuel state left) (←evaluate fuel state right)
  | fuel+1,state,.shiftLeft left right => do shift (←evaluate fuel state left) (←evaluate fuel state right) true
  | fuel+1,state,.shiftRight left right => do shift (←evaluate fuel state left) (←evaluate fuel state right) false
  | fuel+1,state,.bitOr left right => do
    match ←evaluate fuel state left,←evaluate fuel state right with
    | .word a,.word b => pure (.word (.bitOr a b))
    | .unsigned a,.unsigned b => pure (.unsigned (a ||| b))
    | _,_ => none
  | fuel+1,state,.equal left right => do
    match ←evaluate fuel state left,←evaluate fuel state right with
    | .signed a,.signed b => pure (.boolean (decide (a=b)))
    | a,b => do pure (.boolean (decide ((←asUInt a)=(←asUInt b))))
  | fuel+1,state,.conditional test yes no => do
    match ←evaluate fuel state test with
    | .boolean true => evaluate fuel state yes
    | .boolean false => evaluate fuel state no
    | _ => none

def declare (state : State) (name : String) (dimensions : List Expr) : Option State := do
  let shape ←dimensions.mapM (fun expr => do natural (←evaluate 16 state expr))
  if shape=[] ∨ 0∈shape then none else
    some (putArray state name ⟨shape,List.replicate shape.prod none⟩)

def assign (state : State) (name : String) (indices : List Expr) (expression : Expr) : Option State := do
  let array ←lookupArray state name
  let indices ←indices.mapM (fun expr => do natural (←evaluate 16 state expr))
  let index ←flatIndex array.dimensions indices
  let value ←evaluate 16 state expression
  match value with
  | .unsigned _ | .word _ =>
    pure (putArray state name {array with cells := array.cells.set index (some value)})
  | _ => none

mutual
  def execute : Nat → List Stmt → State → Option State
    | 0,_,_ => none
    | _+1,[],state => some state
    | fuel+1,.declare arrays::rest,state => do
      let state ←arrays.foldlM (fun state item => declare state item.1 item.2) state
      execute fuel rest state
    | fuel+1,.assign name indices value::rest,state => do
      let state ←assign state name indices value
      execute fuel rest state
    | fuel+1,.forLoop name start inclusive bound body::rest,state => do
      let original := lookupVariable state name
      let index ←asUInt (←evaluate 16 state start)
      let state ←loop fuel name inclusive bound body (putVariable state name (some (.unsigned index)))
      execute fuel rest (putVariable state name original)
  def loop : Nat → String → Bool → Expr → List Stmt → State → Option State
    | 0,_,_,_,_,_ => none
    | fuel+1,name,inclusive,bound,body,state => do
      let index ←asUInt (←lookupVariable state name)
      let limit ←asUInt (←evaluate 16 state bound)
      if (if inclusive then index.toNat≤limit.toNat else index.toNat<limit.toNat) then do
        let after ←execute fuel body state
        loop fuel name inclusive bound body (putVariable after name (some (.unsigned (index+1))))
      else some state
end

def runSource (state : State) (source : String) : Option State := do
  let statement ←PackedArraySyntax.parse source
  execute 64 [statement] state

def runSources : List String → State → Option State
  | [],state => some state
  | source::rest,state => do runSources rest (←runSource state source)

def cell (state : State) (name : String) (indices : List Nat) : Option Value := do
  let array ←lookupArray state name
  let index ←flatIndex array.dimensions indices
  (array.cells[index]?).join

end Inference.Kernels.Trellis.PackedArraySemantics
