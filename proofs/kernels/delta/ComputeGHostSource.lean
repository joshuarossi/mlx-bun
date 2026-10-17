import kernels.delta.ComputeGHostSyntax
import kernels.delta.MlxLogAddExpSource
import kernels.delta.Decay
namespace Inference.Kernels.Delta.ComputeGHostSource
open Contracts.Mlx FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
inductive Scalar where
  | bf : BF→Scalar
  | fp : Float32→Scalar

def cast : Scalar→Scalar
  | .bf x => .fp (BFloat16.widen x)
  | .fp x => .fp x

def exp (p : Decay.Platform) : Scalar→Scalar
  | .bf x => .bf (p.expBF x)
  | .fp x => .fp (p.exp x)

def neg : Scalar→Option Scalar
  | .fp x => some (.fp (-x))
  | .bf _ => none

def add : Scalar→Scalar→Option Scalar
  | .bf x,.bf y => some (.bf (BFloat16Arithmetic.add x y))
  | _,_ => none

def zero (fp bf : List Nat) : Scalar→Option Scalar
  | .bf _ => if bf=[0,0] then some (.bf Trellis.GateUpSplitTail.zero) else none
  | .fp _ => if fp=[0,0,0,0] then some (.fp 0) else none

def logadd (policy : MlxLogAddExpSource.Policy) (p : Decay.Platform) : Scalar→Scalar→Option Scalar
  | .bf x,.bf y => (MlxLogAddExpSource.executeFinite policy p.expBF p.log1pBF x y).map Scalar.bf
  | _,_ => none

def mul : Scalar→Scalar→Option Scalar
  | .fp x,.bf y => some (.fp (FlushToZero.mul x (BFloat16.widen y)))
  | _,_ => none

-- The selected mixed-dtype graph is explicit. Unused dtype combinations are
-- rejected rather than assigned a source semantics by this specialization.
structure Operations (α : Type) where
  cast : α→α
  exp : α→α
  neg : α→Option α
  add : α→α→Option α
  zero : List Nat→List Nat→α→Option α
  logadd : α→α→Option α
  mul : α→α→Option α

def interpret {α : Type} (op : Operations α) (inputs : Nat→Option α) :
    ComputeGHostSyntax.Expr→Option α
  | .input index => inputs index
  | .castF32 x => (interpret op inputs x).map op.cast
  | .exponential x => (interpret op inputs x).map op.exp
  | .negative x => (interpret op inputs x).bind op.neg
  | .add x y => do op.add (←interpret op inputs x) (←interpret op inputs y)
  | .zeroLike x fp bf => (interpret op inputs x).bind (op.zero fp bf)
  | .logaddexp x y => do op.logadd (←interpret op inputs x) (←interpret op inputs y)
  | .multiply x y => do op.mul (←interpret op inputs x) (←interpret op inputs y)

def operations (policy : MlxLogAddExpSource.Policy) (p : Decay.Platform) : Operations Scalar :=
  ⟨cast,exp p,neg,add,zero,logadd policy p,mul⟩
def evaluate (policy : MlxLogAddExpSource.Policy) (p : Decay.Platform) := interpret (operations policy p)

theorem interpret_body {α : Type} (op : Operations α) (inputs : Nat→Option α) :
    interpret op inputs ComputeGHostSyntax.body =
      (do let aLog ←inputs 0
          let a ←inputs 1
          let dt ←inputs 2
          let summed ←op.add a dt
          let z ←op.zero [0,0,0,0] [0,0] summed
          let sp ←op.logadd summed z
          let n ←op.neg (op.exp (op.cast aLog))
          let prod ←op.mul n sp
          pure (op.exp prod)) := by
  cases h0 : inputs 0 <;> cases h1 : inputs 1 <;> cases h2 : inputs 2 <;>
    simp [ComputeGHostSyntax.body,interpret,h0,h1,h2,Option.map_none,Option.map_some,Option.bind_none,Option.bind_some]
  next aLog a dt =>
    cases hs : op.add a dt <;> simp [hs,Option.bind_none,Option.bind_some]
    next summed =>
      cases hz : op.zero [0,0,0,0] [0,0] summed <;> simp [hz,Option.bind_none,Option.bind_some]
      next z =>
        cases hl : op.logadd summed z <;> cases hn : op.neg (op.exp (op.cast aLog)) <;>
          simp [hl,hn,Option.bind_none,Option.bind_some]
        next sp n =>
          cases hm : op.mul n sp <;> rfl
def inputs (aLog a dt : BF) : Nat→Option Scalar
  | 0 => some (.bf aLog)
  | 1 => some (.bf a)
  | 2 => some (.bf dt)
  | _ => none

def execute (policy : MlxLogAddExpSource.Policy) (p : Decay.Platform) (aLog a dt : BF) : Option Scalar := do
  let _ ←ComputeGHostSyntax.parseCaller ComputeGHostSyntax.callerSource
  let body ←ComputeGHostSyntax.parseTokens ComputeGHostSyntax.bodyTokens
  evaluate policy p (inputs aLog a dt) body

-- Establish the host frontend reduction without exposing binary floating-point
-- representations to the parser's Option interpreter.
theorem parsed_bind {α : Type} (body : ComputeGHostSyntax.Expr→Option α) :
    (do let _ ←ComputeGHostSyntax.parseCaller ComputeGHostSyntax.callerSource
        let expr ←ComputeGHostSyntax.parseTokens ComputeGHostSyntax.bodyTokens
        body expr)=body ComputeGHostSyntax.body := by
  rw [ComputeGHostSyntax.parsed_caller,ComputeGHostSyntax.parsed_body]
  rfl

attribute [local irreducible] ComputeGHostSyntax.parse ComputeGHostSyntax.parseCaller

theorem execution (p : Decay.Platform) (aLog a dt : BF)
    (finite : Model.isFinite (Decay.biased a dt)=true) :
    execute p.policy p aLog a dt=
      some (.fp (Decay.value p (BFloat16.widen aLog) a dt)) := by
  rw [execute,parsed_bind]
  unfold evaluate
  rw [interpret_body]
  simp only [inputs,operations,Bind.bind,Option.bind_some,cast,exp,neg,add,zero]
  have zeroBytes : ([0,0] : List Nat)=[0,0] := rfl
  simp only [zeroBytes,ite_true,Option.bind_some,logadd]
  rw [MlxLogAddExpSource.zero_execution p.policy p.expBF p.log1pBF (BFloat16Arithmetic.add a dt) finite]
  rfl

end Inference.Kernels.Delta.ComputeGHostSource
