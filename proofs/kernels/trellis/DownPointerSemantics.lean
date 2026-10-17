import kernels.trellis.DownPointerSyntax
import kernels.trellis.PackedArrayDownMaterialization
namespace Inference.Kernels.Trellis.DownPointerSemantics
open DownPointerSyntax Contracts.Mlx Models.Qwen
set_option maxRecDepth 100000
inductive Value where
  | uint : BitVec 32 → Value
  | ulong : BitVec 64 → Value
  | signed : Int → Value
  | boolean : Bool → Value
  | pointer : BitVec 64 → Value
  deriving DecidableEq,Repr
abbrev Environment := String → Option Value

def asULong : Value → Option (BitVec 64)
  | .uint a => some (BitVec.ofNat 64 a.toNat)
  | .ulong a => some a
  | .signed a => some (BitVec.ofInt 64 a)
  | _ => none

def add (a b : Value) : Option Value := match a,b with
  | .uint a,.uint b => some (.uint (a+b))
  | .pointer a,b => (asULong b).map (fun b => .pointer (a+b))
  | a,b => do pure (.ulong ((←asULong a)+(←asULong b)))
def multiply (a b : Value) : Option Value := match a,b with
  | .uint a,.uint b => some (.uint (a*b))
  | a,b => do pure (.ulong ((←asULong a)*(←asULong b)))
def quotient (a b : Value) (isModulo : Bool) : Option Value := match a,b with
  | .uint a,.uint b => if b.toNat=0 then none else
      some (.uint (BitVec.ofNat 32 (if isModulo then a.toNat%b.toNat else a.toNat/b.toNat)))
  | _,_ => none

def evaluate (env : Environment) : Expr → Option Value
  | .variable name => env name
  | .uint n => if n<2^32 then some (.uint (BitVec.ofNat 32 n)) else none
  | .ulong n => if n<2^64 then some (.ulong (BitVec.ofNat 64 n)) else none
  | .castULong value => do pure (.ulong (←asULong (←evaluate env value)))
  | .add a b => do add (←evaluate env a) (←evaluate env b)
  | .multiply a b => do multiply (←evaluate env a) (←evaluate env b)
  | .divide a b => do quotient (←evaluate env a) (←evaluate env b) false
  | .modulo a b => do quotient (←evaluate env a) (←evaluate env b) true
  | .logicalNot value => do
    match ←evaluate env value with
    | .boolean value => some (.boolean (!value))
    | _ => none
  | .conditional test yes no => do
    match ←evaluate env test with
    | .boolean true => evaluate env yes
    | .boolean false => evaluate env no
    | _ => none

def environment (k block : Nat) (active : Bool) : Environment := fun name =>
  if name="INTERLEAVE" then some (.boolean (decide (k=3)))
  else if name="active" then some (.boolean active)
  else if name="codes" then some (.pointer 0)
  else if name="WPB" then some (.uint (BitVec.ofNat 32 (8*k)))
  else if name="NB" then some (.uint 20)
  else if name="R" then some (.signed 17408)
  else if name="blk" then some (.uint (BitVec.ofNat 32 block)) else none

def stride (k : Nat) : Nat := if k=3 then 2*(8*k) else 20*(8*k)
def blockOffset (k block : Nat) : Nat :=
  if k=3 then block/2*17408*(2*(8*k))+block%2*(8*k) else block*(8*k)

theorem stride_closed : ∀ k : Fin 3,
    evaluate (environment (PackedArrayGate.width k) 0 true) DownPointerSyntax.stride.value=
      some (.ulong (BitVec.ofNat 64 (stride (PackedArrayGate.width k)))) := by decide +kernel

theorem block_closed : ∀ k : Fin 3, ∀ block : Fin 20, ∀ active : Bool,
    evaluate (environment (PackedArrayGate.width k) block.val active) DownPointerSyntax.block.value=
      some (.pointer (BitVec.ofNat 64 (if active then blockOffset (PackedArrayGate.width k) block.val else 0))) := by decide +kernel

def rowEnvironment (base stride : BitVec 64) (r0 r u : BitVec 32) : Environment := fun name =>
  if name="blockWords" then some (.pointer base)
  else if name="ROWW" then some (.ulong stride)
  else if name="r0" then some (.uint r0)
  else if name="r" then some (.uint r)
  else if name="u" then some (.uint u) else none

theorem pair_evaluate (base stride : BitVec 64) (r0 r u : BitVec 32) :
    evaluate (rowEnvironment base stride r0 r u) DownPointerSyntax.pair.value=
      some (.pointer (base+BitVec.ofNat 64 (r0+r+u).toNat*stride)) := rfl

theorem tail_evaluate (base stride : BitVec 64) (r0 r u : BitVec 32) :
    evaluate (rowEnvironment base stride r0 r u) DownPointerSyntax.tail.value=
      some (.pointer (base+BitVec.ofNat 64 (r0+r).toNat*stride)) := rfl

-- No byte image is replaced: this offset is the index into the original
-- codes allocation, whose attachment is supplied by PackedArrayDownMaterialization.Input.
theorem original_index (row block word k : Nat) :
    blockOffset k block+row*stride k+word=CheckpointTrellisMemory.downIndex row block word k := rfl
end Inference.Kernels.Trellis.DownPointerSemantics
