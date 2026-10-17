import kernels.trellis.DownControlSyntax
namespace Inference.Kernels.Trellis.DownControlSource
open DownControlSyntax PackedArraySemantics Contracts.Mlx
set_option maxRecDepth 100000
abbrev Environment := String → Option Value

def boolean : Value → Option Bool
  | .boolean value => some value
  | .unsigned value => some (decide (value.toNat≠0))
  | _ => none

def compare (a b : Value) (kind : Nat) : Option Value := do
  let a ←asUInt a
  let b ←asUInt b
  pure (.boolean (if kind=0 then decide (a.toNat<b.toNat) else if kind=1 then decide (b.toNat≤a.toNat) else decide (a=b)))

def evaluate (env : Environment) : Expr → Option Value
  | .variable name => env name
  | .uint n => if n<2^32 then some (.unsigned (BitVec.ofNat 32 n)) else none
  | .castUInt value => do pure (.unsigned (←asUInt (←evaluate env value)))
  | .add a b => do add (←evaluate env a) (←evaluate env b)
  | .subtract a b => do subtract (←evaluate env a) (←evaluate env b)
  | .divide a b => do divide (←evaluate env a) (←evaluate env b)
  | .modulo a b => do modulo (←evaluate env a) (←evaluate env b)
  | .bitAnd a b => do pure (.unsigned ((←asUInt (←evaluate env a)) &&& (←asUInt (←evaluate env b))))
  | .less a b => do compare (←evaluate env a) (←evaluate env b) 0
  | .greaterEqual a b => do compare (←evaluate env a) (←evaluate env b) 1
  | .equal a b => do compare (←evaluate env a) (←evaluate env b) 2
  | .logicalNot value => do pure (.boolean (!(←boolean (←evaluate env value))))
  | .logicalAnd a b => do
    if ←boolean (←evaluate env a) then do pure (.boolean (←boolean (←evaluate env b)))
    else some (.boolean false)
  | .minimum a b => do pure (.unsigned (BitVec.ofNat 32 (min (←asUInt (←evaluate env a)).toNat (←asUInt (←evaluate env b)).toNat)))
  | .conditional test yes no => do
    if ←boolean (←evaluate env test) then evaluate env yes else evaluate env no

def execute (text : String) (env : Environment) : Option Value :=
  (parse text).bind (fun code =>
    (evaluate env code.value).bind (fun result =>
      if code.boolean then (boolean result).map Value.boolean
      else (asUInt result).map Value.unsigned))

def shifted (k lane : Nat) : Option Value :=
  (DownSetupSource.setup k lane).bind (fun state => execute shiftedSource (lookupVariable state))

theorem shifted_selected : ∀ k : Fin 3, ∀ lane : Fin 32,
    shifted (PackedArrayGate.width k) lane.val=some
      (.boolean (decide (PackedArrayGate.width k=3 ∧ (lane.val%16)%2=1))) := by decide +kernel

def rowEnvironment (active : Bool) (r0 : BitVec 32) : Environment := fun name =>
  if name="active" then some (.boolean active)
  else if name="R" then some (.signed 17408)
  else if name="SPLITS" then some (.signed 128)
  else if name="ROWS_PER" then some (.unsigned 136)
  else if name="r0" then some (.unsigned r0) else none

theorem rows_selected (active : Bool) (r0 : BitVec 32) :
    execute rowsSource (rowEnvironment active r0)=some (.unsigned (if active then 136 else 0)) := by
  rw [execute,parsed_rows,Option.bind_some]
  cases active <;> rfl

def activeEnvironment (group block : Nat) : Environment := fun name =>
  if name="colGroup" then some (.unsigned (BitVec.ofNat 32 group))
  else if name="SGS" then some (.unsigned 10)
  else if name="blk" then some (.unsigned (BitVec.ofNat 32 block))
  else if name="NB" then some (.unsigned 20) else none

theorem active_selected : ∀ group : Fin 10, ∀ block : Fin 20,
    execute activeSource (activeEnvironment group.val block.val)=some (.boolean true) := by decide +kernel
end Inference.Kernels.Trellis.DownControlSource
