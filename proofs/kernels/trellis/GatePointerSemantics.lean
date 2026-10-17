import kernels.trellis.GatePointerSyntax
import kernels.trellis.PackedArraySemantics
namespace Inference.Kernels.Trellis.GatePointerSemantics
open GatePointerSyntax
set_option maxRecDepth 100000

-- Row remains symbolic; every operation evaluates in uint32 at realization.
-- Ground operations fold with the same wrapping and signed promotion rules.
inductive Symbol where
  | constant : BitVec 32 → Symbol
  | row : Symbol
  | add : Symbol → Symbol → Symbol
  | multiply : Symbol → Symbol → Symbol
  deriving DecidableEq,Repr

def Symbol.realize (row : Nat) : Symbol → BitVec 32
  | .constant value => value
  | .row => BitVec.ofNat 32 row
  | .add a b => a.realize row+b.realize row
  | .multiply a b => a.realize row*b.realize row

def add (a b : Symbol) : Symbol := match a,b with
  | .constant a,.constant b => .constant (a+b)
  | a,b => .add a b

def multiply (a b : Symbol) : Symbol := match a,b with
  | .constant a,.constant b => .constant (a*b)
  | a,b => .multiply a b

theorem add_realize (a b : Symbol) (row : Nat) : (add a b).realize row=a.realize row+b.realize row := by
  cases a <;> cases b <;> rfl

theorem multiply_realize (a b : Symbol) (row : Nat) : (multiply a b).realize row=a.realize row*b.realize row := by
  cases a <;> cases b <;> rfl

inductive Value where
  | signed : Int → Value
  | unsigned : Symbol → Value
  deriving DecidableEq,Repr
abbrev Environment := List (String × Value)

def signed (value : Int) : Option Value :=
  if -(2^31)≤value ∧ value<2^31 then some (.signed value) else none

def unsigned : Value → Symbol
  | .signed value => .constant (BitVec.ofInt 32 value)
  | .unsigned value => value

def sum (a b : Value) : Option Value := match a,b with
  | .signed a,.signed b => signed (a+b)
  | a,b => some (.unsigned (add (unsigned a) (unsigned b)))

def product (a b : Value) : Option Value := match a,b with
  | .signed a,.signed b => signed (a*b)
  | a,b => some (.unsigned (multiply (unsigned a) (unsigned b)))

def difference (a b : Value) : Option Value := match a,b with
  | .signed a,.signed b => signed (a-b)
  | a,b => match unsigned a,unsigned b with
    | .constant a,.constant b => some (.unsigned (.constant (a-b)))
    | _,_ => none

def quotient (a b : Value) : Option Value := match a,b with
  | .signed a,.signed b => if 0≤a ∧ 0<b then signed (a/b) else none
  | a,b => match unsigned a,unsigned b with
    | .constant a,.constant b => if b.toNat=0 then none else
        some (.unsigned (.constant (BitVec.ofNat 32 (a.toNat/b.toNat))))
    | _,_ => none

def evaluate (state : Environment) : PackedArraySyntax.Expr → Option Value
  | .variable name => PackedArraySemantics.lookup name state
  | .literal .signed n => signed n
  | .literal .unsigned n => if n<2^32 then some (.unsigned (.constant (BitVec.ofNat 32 n))) else none
  | .castUInt expression => do pure (.unsigned (unsigned (←evaluate state expression)))
  | .add a b => do sum (←evaluate state a) (←evaluate state b)
  | .multiply a b => do product (←evaluate state a) (←evaluate state b)
  | .subtract a b => do difference (←evaluate state a) (←evaluate state b)
  | .divide a b => do quotient (←evaluate state a) (←evaluate state b)
  | _ => none

def declaration : Declaration → Environment → Option Environment
  | [],state => some state
  | (name,expression)::rest,state => do
    let value ←evaluate state expression
    declaration rest ((name,.unsigned (unsigned value))::state)

def execute : List Declaration → Environment → Option Environment
  | [],state => some state
  | first::rest,state => do execute rest (←declaration first state)

def initial (kg ku run : Nat) : Environment := [
  ("BT",.signed 256),("KG",.signed kg),("KU",.signed ku),("C",.signed 5120),
  ("row",.unsigned .row),("run",.unsigned (.constant (BitVec.ofNat 32 run)))]

private def c (value : Nat) : Value := .unsigned (.constant (BitVec.ofNat 32 value))
private def rowProduct (width : Nat) : Symbol := .multiply .row (.constant (BitVec.ofNat 32 (20*(8*width))))

def expected (kg ku run : Nat) : Environment := [
  ("uW0",c ((7-run%8)*ku)),("gW0",c ((7-run%8)*kg)),
  ("uw",.unsigned (.add (rowProduct ku) (.constant (BitVec.ofNat 32 (run/8*(8*ku)))))),
  ("gw",.unsigned (.add (rowProduct kg) (.constant (BitVec.ofNat 32 (run/8*(8*kg)))))),
  ("t0",c (run%8*32)),("blk",c (run/8)),
  ("uRow",.unsigned (rowProduct ku)),("gRow",.unsigned (rowProduct kg)),
  ("runsPerBlock",c 8),("uWpb",c (8*ku)),("gWpb",c (8*kg))]++initial kg ku run

-- Full finite width/run closure, with the row deliberately NOT enumerated or
-- assumed to equal the desired address. All intermediate declarations execute.
theorem prepared : ∀ kg ku : Fin 3, ∀ run : Fin 160,
    execute code (initial (kg.val+2) (ku.val+2) run.val)=some (expected (kg.val+2) (ku.val+2) run.val) := by
  intro kg ku
  have gate : kg.val=0 ∨ kg.val=1 ∨ kg.val=2 := by omega
  have up : ku.val=0 ∨ ku.val=1 ∨ ku.val=2 := by omega
  rcases gate with gate|gate|gate <;> rcases up with up|up|up <;>
    simp only [gate,up] <;> decide +kernel

def prepare (kg ku run : Nat) : Option Environment :=
  (parseSources sources).bind (fun statements => execute statements (initial kg ku run))

attribute [local irreducible] execute

theorem parsed_bind {α : Type} (continuation : List Declaration → Option α) :
    (parseSources sources).bind continuation=continuation code := by
  rw [parsed,Option.bind_some]

theorem prepare_source (kg ku run : Nat) : prepare kg ku run=execute code (initial kg ku run) :=
  parsed_bind (fun statements => execute statements (initial kg ku run))
end Inference.Kernels.Trellis.GatePointerSemantics
