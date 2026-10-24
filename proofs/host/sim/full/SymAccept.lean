import host.sim.full.SymGraph
import host.sim.native.Small
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf GraphOp)

/-! # Accepting the forward's operations over symbolic shapes

The general relation's acceptance (`okCallSG`: `NativeOk.*` through `opCheck`) takes most
operations only over literal input shapes, and graph operations, `astype`, `contiguous`,
`logsumexp` and `mlx_eval` not at all. `okCallSX` extends it as a layer: a call is accepted when
`okCallSG` accepts it or the symbolic decider `NativeOkX.sym` does. `NativeOkX` checks what
`opCheck` checks except that input shapes be literal (the slot, the handle and node room), and what
each simulation needs: closed and canonical inputs are the relation's; dimensions read by value
have values (`dimOkV`, and the numeric premise `smallX` for their references, decided by
`smallXB`); products are bounded statically (`prodBnd`); quantized matmul and normalization check
literal weights and inner dimensions. `loadFfiCallSimX` is the load world's native-call simulation
for `okCallSX`. -/

namespace NativeOkX
variable (P : LoadP) (x : NSt)

/-- The output slot and room. -/
def out (o : Arg) : Bool := slotOk P x o && decide (x.next + 1 ≤ P.E) && decide (x.nnext + 1 ≤ P.NE)

def one (ins : List Nat) : Bool :=
  match Host.Mlx.Ffi.shapesOf x ins with
  | some [_] => true
  | _ => false

def two (ins : List Nat) : Bool :=
  match Host.Mlx.Ffi.shapesOf x ins with
  | some [_, _] => true
  | _ => false

def unary : List Arg → Bool
  | [o, a, _] => hdOk x a && out P x o && match Host.Mlx.Ffi.arrIns x [a] with
    | some ins => one x ins
    | none => false
  | _ => false

def astype : List Arg → Bool
  | [o, a, dt, _] => hdOk x a && natOk P dt && out P x o && match Host.Mlx.Ffi.arrIns x [a] with
    | some ins => one x ins
    | none => false
  | _ => false

def contiguous : List Arg → Bool
  | [o, a, _, _] => hdOk x a && out P x o && match Host.Mlx.Ffi.arrIns x [a] with
    | some ins => one x ins
    | none => false
  | _ => false

def rope : List Arg → Bool
  | [o, a, .num (.lit dims), .bool _, base, .num _, .num _, freqs, _] =>
    hdOk x a && natOk P freqs && NativeOk.notOther base && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a], F64.toInt? dims with
    | some ins, some d => decide (0 < d) && one x ins
    | _, _ => false
  | _ => false

def logsumexp : List Arg → Bool
  | [o, a, ax, .bool _, _] => nodeOk x a && natOk P ax && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.argInt ax, (Host.Mlx.Ffi.argNat a).bind x.node? with
    | some ins, some av, some nd => (Host.Mlx.Ffi.axisOf av (len nd.shape)).isSome && one x ins
    | _, _, _ => false
  | _ => false

def transpose : List Arg → Bool
  | [o, a, ax, m, _] => hdOk x a && dimsOk P ax m && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg ax m with
    | some ins, some ds => (Host.Mlx.Ffi.natsOfDims ds).isSome && one x ins
    | _, _ => false
  | _ => false

def take : List Arg → Bool
  | [o, a, i, ax, _] => nodeOk x a && hdOk x i && natOk P ax && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a, i], Host.Mlx.Ffi.argInt ax, (Host.Mlx.Ffi.argNat a).bind x.node? with
    | some ins, some av, some nd => (Host.Mlx.Ffi.axisOf av (len nd.shape)).isSome && two x ins
    | _, _, _ => false
  | _ => false

def eval : List Arg → Bool
  | [v] => vecOk x v
  | _ => false

def binary : List Arg → Bool
  | [o, a, b, _] => hdOk x a && hdOk x b && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a, b] with
    | some ins => match Host.Mlx.Ffi.shapesOf x ins with
      | some [(sa, _), (sb, _)] => sa.all dimOkV && sb.all dimOkV
      | _ => false
    | none => false
  | _ => false

def lastLit (s : List Dim) : Bool :=
  match nthD (.lit 0) s (len s - 1) with
  | .lit _ => true
  | .sym _ => false

def rms : List Arg → Bool
  | [o, a, w, .num _, _] => hdOk x a && out P x o &&
    match Host.Mlx.Ffi.argNat w with
    | some 0 => natOk P w && match Host.Mlx.Ffi.arrIns x [a] with
      | some ins => one x ins
      | none => false
    | _ => hdOk x w && match Host.Mlx.Ffi.arrIns x [a, w] with
      | some ins => match Host.Mlx.Ffi.shapesOf x ins with
        | some [(s, _), ([.lit _], _)] => lastLit s
        | _ => false
      | none => false
  | _ => false

def qmm : List Arg → Bool
  | [o, a, w, sc, bi, .bool _, g, b, mode, _] => hdOk x a && hdOk x w && hdOk x sc && hdOk x bi &&
    natOk P g && natOk P b && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a, w, sc, bi], Host.Mlx.Ffi.optIntArg g, Host.Mlx.Ffi.optIntArg b,
      Host.Mlx.Ffi.cstrArg mode with
    | some ins, some _, some _, some _ => match Host.Mlx.Ffi.shapesOf x ins with
      | some [(xs, _), (ws, _), (scs, _), (bis, _)] => lastLit xs && ws.all dimLit && scs.all dimLit && bis.all dimLit
      | _ => false
    | _, _, _, _ => false
  | _ => false

def reshape : List Arg → Bool
  | [o, a, sh, n, _] => hdOk x a && dimsOk P sh n && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg sh n with
    | some ins, some new => match Host.Mlx.Ffi.shapesOf x ins with
      | some [(old, _)] => new.all dimOkV && old.all dimOkV && decide (prodBnd new < 2 ^ 53) &&
          decide (prodBnd old < 2 ^ 53)
      | _ => false
    | _, _ => false
  | _ => false

def sliceDynamic : List Arg → Bool
  | [o, a, st, ax, n1, sz, n2, _] => hdOk x a && hdOk x st && dimsOk P ax n1 && dimsOk P sz n2 && out P x o &&
    match Host.Mlx.Ffi.arrIns x [a, st], Host.Mlx.Ffi.dimsArg ax n1, Host.Mlx.Ffi.dimsArg sz n2 with
    | some ins, some d1, some sizes => (Host.Mlx.Ffi.natsOfDims d1).isSome && two x ins && sizes.all dimOkV
    | _, _, _ => false
  | _ => false

def zeros : List Arg → Bool
  | [o, sh, m, dt, _] => out P x o && dimsOk P sh m && natOk P dt &&
    match Host.Mlx.Ffi.dimsArg sh m with
    | some ds => ds.all dimOkV
    | none => false
  | _ => false

def cout : List Arg → Bool
  | [c, sh, m, dt] => cfgOk x c && dimsOk P sh m && natOk P dt &&
    match Host.Mlx.Ffi.dimsArg sh m with
    | some ds => ds.all dimOkV
    | none => false
  | _ => false

def graph (op : GraphOp) : List Arg → Bool
  | o :: a :: rest => nodeOk x a && (Host.Mlx.Ffi.graphArrays op a rest).all (hdOk x) &&
    natOk P (Host.Mlx.Ffi.graphAxis op rest) && out P x o &&
    match Host.Mlx.Ffi.arrIns x (Host.Mlx.Ffi.graphArrays op a rest), Host.Mlx.Ffi.argInt (Host.Mlx.Ffi.graphAxis op rest),
      (Host.Mlx.Ffi.argNat a).bind x.node? with
    | some ins, some av, some _ => (Host.Mlx.Ffi.graphOut x op av rest ins).isSome
    | _, _, _ => false
  | _ => false

/-- **The symbolic decider** by symbol. -/
def sym : Host.Mlx.Ffi.Sym → List Arg → Bool
  | .unary => unary P x
  | .astype => astype P x
  | .contiguous => contiguous P x
  | .rope => rope P x
  | .logsumexp => logsumexp P x
  | .transpose => transpose P x
  | .take => take P x
  | .eval => eval x
  | .binary => binary P x
  | .rmsNorm => rms P x
  | .qmm => qmm P x
  | .reshape => reshape P x
  | .sliceDynamic => sliceDynamic P x
  | .zeros => zeros P x
  | .cfgOutput => cout P x
  | .graph op => graph P x op
  | _ => fun _ => false

end NativeOkX

/-- The references the symbolic calls read by value. -/
def symRefsX (x : NSt) : Host.Mlx.Ffi.Sym → List Arg → List Nat
  | .binary, [_, a, b, _] => match Host.Mlx.Ffi.arrIns x [a, b] with
    | some ins => shRefs x ins
    | none => []
  | .reshape, [_, a, sh, n, _] => (match Host.Mlx.Ffi.arrIns x [a] with
    | some ins => shRefs x ins
    | none => []) ++ dimsArgRefs sh n
  | .sliceDynamic, [_, _, _, _, _, sz, n2, _] => dimsArgRefs sz n2
  | .zeros, [_, sh, m, _, _] => dimsArgRefs sh m
  | .cfgOutput, [_, sh, m, _] => dimsArgRefs sh m
  | _, _ => []

def smallRefsX (x : NSt) (name : Name) (args : List Arg) : List Nat :=
  match Host.Mlx.Ffi.symOf name with
  | some s => symRefsX x s args
  | none => []

/-- **The accepted native calls** with the forward's operations over symbolic shapes. -/
def okCallSX (P : LoadP) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  okCallSG P x name args || (Host.Load.isMlx name && match Host.Mlx.Ffi.symOf name with
    | some s => NativeOkX.sym P x.mlx s args
    | none => false)

/-- **The numeric premise** with the symbolic calls' references. -/
def smallX (ν : Nat → F64) (S : SSrv) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Prop :=
  smallLoad ν S x name args ∧ ∀ j ∈ smallRefsX x.mlx name args, RefSmall ν S j

def smallXB (VB : Nat → Nat) (S : SSrv) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  smallLoadB VB S x name args && (smallRefsX x.mlx name args).all (refSmallB VB S)

theorem smallXB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : Host.Load.LSt} {name : Name}
    {args : List Arg} (h : smallXB VB S x name args = true) (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) :
    smallX ν S x name args := by
  simp only [smallXB, Bool.and_eq_true] at h
  exact ⟨smallLoadB_sound h.1 hν, fun j hj => refSmallB_sound (List.all_eq_true.mp h.2 j hj) hν⟩

end Host.Ts.Sim.G
