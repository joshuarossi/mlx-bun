import host.sim.native.OpCalls
import host.sim.native.Read
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # `FfiSim` for the load world

`okCall P` accepts the `mlx_*` calls of a decode iteration whose source
arguments satisfy the per-symbol checks below (decidable facts about the
source native state and arguments): handles are present, integers are fixed
by the map (`natOk`: literal numbers or bigints below `P.lo`), buffer cells
read whole elements or concrete bytes, every dimension an operation or leaf
receives is literal and every input shape is literal (`opCheck`), returned
bigints are below `P.lo`, and the template has room for the allocation.
No callback continuation is accepted (`okBack` is `false`): compiled-closure
applies are not covered. -/

namespace NativeOk
variable (P : LoadP) (x : NSt)

def notOther : Arg → Bool
  | .other _ => false
  | _ => true

def room1 : Bool := decide (x.next + 1 ≤ P.E)
def nroom1 : Bool := decide (x.nnext + 1 ≤ P.NE)

def free : List Arg → Bool
  | [a] => hdOk x a
  | _ => false

def node1 : List Arg → Bool
  | [a] => nodeOk x a
  | _ => false

def ndim : List Arg → Bool
  | [a] => nodeOk x a && match (Host.Mlx.Ffi.argNat a).bind x.node? with
    | some nd => decide (len nd.shape < P.lo)
    | none => false
  | _ => false

def size : List Arg → Bool
  | [a] => nodeOk x a && match (Host.Mlx.Ffi.argNat a).bind x.node? with
    | some nd => match Host.Mlx.Ffi.natsOfDims nd.shape with
      | some ds => bigOk P ((ds.foldr (· * ·) 1 : Nat) : Int)
      | none => true
    | none => false
  | _ => false

def new0 : List Arg → Bool
  | [] => room1 P x
  | _ => false

def any1 : List Arg → Bool
  | [_] => true
  | _ => false

def vsize : List Arg → Bool
  | [v] => vecOk x v && match (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.vec ns) => decide (len ns < P.lo)
    | _ => false
  | _ => false

def vec1 : List Arg → Bool
  | [v] => vecOk x v
  | _ => false

def vget : List Arg → Bool
  | [o, v, i] => slotOk P x o && vecOk x v && natOk P i && room1 P x
  | _ => false

def vdata : List Arg → Bool
  | [p, c] => handlesOk P x p c && room1 P x
  | _ => false

def cout : List Arg → Bool
  | [c, sh, m, dt] => cfgOk x c && dimsOk P sh m && dimsLitOk sh m && natOk P dt
  | _ => false

def cnums : List Arg → Bool
  | [c, .num _, .num _, .num _] => cfgOk x c
  | _ => false

def cint : List Arg → Bool
  | [c, _, .num _] => cfgOk x c
  | _ => false

def cdtype : List Arg → Bool
  | [c, _, dt] => cfgOk x c && natOk P dt
  | _ => false

def kapply : List Arg → Bool
  | [o, k, v, c, _] => slotOk P x o && kernOk x k && vecOk x v && cfgOk x c && room1 P x &&
      match (Host.Mlx.Ffi.argNat c).bind x.obj? with
      | some (.cfg cf) => decide (x.nnext + cf.outs.length ≤ P.NE)
      | _ => false
  | _ => false

def wired : List Arg → Bool
  | [.jsPtr _ _ _, l] => natOk P l && bigOk P (x.wired : Int)
  | _ => false

def newData : List Arg → Bool
  | [.jsPtr _ _ _, sh, nd, dt] => dimsOk P sh nd && dimsLitOk sh nd && natOk P dt && room1 P x && nroom1 P x
  | _ => false

def zeros : List Arg → Bool
  | [o, sh, m, dt, _] => slotOk P x o && dimsOk P sh m && dimsLitOk sh m && natOk P dt && room1 P x && nroom1 P x
  | _ => false

def item : List Arg → Bool
  | [.jsPtr _ _ _, a] => nodeOk x a
  | _ => false

def reshape : List Arg → Bool
  | [o, a, sh, m, _] => hdOk x a && dimsOk P sh m && match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg sh m with
    | some ins, some shape => opCheck P x o (.reshape shape) ins
    | _, _ => false
  | _ => false

def transpose : List Arg → Bool
  | [o, a, ax, m, _] => hdOk x a && dimsOk P ax m && match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg ax m with
    | some ins, some ds => match Host.Mlx.Ffi.natsOfDims ds with
      | some axes => opCheck P x o (.transpose axes) ins
      | none => false
    | _, _ => false
  | _ => false

def slice : List Arg → Bool
  | [o, a, st, n1, sp, n2, sr, n3, _] => hdOk x a && dimsOk P st n1 && dimsOk P sp n2 && dimsOk P sr n3 &&
    match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg st n1, Host.Mlx.Ffi.dimsArg sp n2,
      Host.Mlx.Ffi.dimsArg sr n3 with
    | some ins, some d1, some d2, some d3 => opCheck P x o (.slice d1 d2 d3) ins
    | _, _, _, _ => false
  | _ => false

def sliceUpdate : List Arg → Bool
  | [o, a, u, st, n1, sp, n2, sr, n3, _] => hdOk x a && hdOk x u && dimsOk P st n1 && dimsOk P sp n2 &&
    dimsOk P sr n3 &&
    match Host.Mlx.Ffi.arrIns x [a, u], Host.Mlx.Ffi.dimsArg st n1, Host.Mlx.Ffi.dimsArg sp n2,
      Host.Mlx.Ffi.dimsArg sr n3 with
    | some ins, some d1, some d2, some d3 => opCheck P x o (.sliceUpdate d1 d2 d3) ins
    | _, _, _, _ => false
  | _ => false

def sliceDynamic : List Arg → Bool
  | [o, a, st, ax, n1, sz, n2, _] => hdOk x a && hdOk x st && dimsOk P ax n1 && dimsOk P sz n2 &&
    match Host.Mlx.Ffi.arrIns x [a, st], Host.Mlx.Ffi.dimsArg ax n1, Host.Mlx.Ffi.dimsArg sz n2 with
    | some ins, some d1, some sizes => match Host.Mlx.Ffi.natsOfDims d1 with
      | some axes => opCheck P x o (.sliceDynamic axes sizes) ins
      | none => false
    | _, _, _ => false
  | _ => false

def concat : List Arg → Bool
  | [o, v, ax, _] => hdOk x v && natOk P ax &&
    match (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.vec (i :: rest)) => match x.nodes.get i, Host.Mlx.Ffi.argInt ax with
      | some nd, some a => match Host.Mlx.Ffi.axisOf a (len nd.shape) with
        | some b => opCheck P x o (.concat b) (i :: rest)
        | none => false
      | _, _ => false
    | _ => false
  | _ => false

def unary (name : Name) : List Arg → Bool
  | [o, a, _] => hdOk x a && match Host.Mlx.Ffi.arrIns x [a] with
    | some ins => opCheck P x o (.unary (Host.Mlx.Ffi.strip name)) ins
    | none => false
  | _ => false

def binary (name : Name) : List Arg → Bool
  | [o, a, b, _] => hdOk x a && hdOk x b && match Host.Mlx.Ffi.arrIns x [a, b] with
    | some ins => opCheck P x o (.binary (Host.Mlx.Ffi.strip name)) ins
    | none => false
  | _ => false

def rms : List Arg → Bool
  | [o, a, w, .num eps, _] => hdOk x a && hdOk x w && match Host.Mlx.Ffi.arrIns x [a, w] with
    | some ins => opCheck P x o (.rmsNorm eps) ins
    | none => false
  | _ => false

def rope : List Arg → Bool
  | [o, a, .num (.lit dims), .bool tr, base, .num scale, .num off, freqs, _] =>
    hdOk x a && natOk P freqs && notOther base &&
    match Host.Mlx.Ffi.arrIns x [a], F64.toInt? dims with
    | some ins, some d => decide (0 < d) && opCheck P x o (.rope d.toNat tr base scale off) ins
    | _, _ => false
  | _ => false

def sdpa : List Arg → Bool
  | [o, q, k, v, .num scale, mask, mk, sk, _, _] => hdOk x q && hdOk x k && hdOk x v && natOk P mk && natOk P sk &&
    match Host.Mlx.Ffi.arrIns x [q, k, v], Host.Mlx.Ffi.cstrArg mask, Host.Mlx.Ffi.argNat mk, Host.Mlx.Ffi.argNat sk with
    | some ins, some m, some 0, some 0 => opCheck P x o (.sdpa scale m) ins
    | _, _, _, _ => false
  | _ => false

def qmm : List Arg → Bool
  | [o, a, w, sc, bi, .bool tr, g, b, mode, _] => hdOk x a && hdOk x w && hdOk x sc && hdOk x bi &&
    natOk P g && natOk P b &&
    match Host.Mlx.Ffi.arrIns x [a, w, sc, bi], Host.Mlx.Ffi.optIntArg g, Host.Mlx.Ffi.optIntArg b,
      Host.Mlx.Ffi.cstrArg mode with
    | some ins, some gv, some bv, some m => opCheck P x o (.qmm tr (gv.getD 64) (bv.getD 4) m) ins
    | _, _, _, _ => false
  | _ => false

def dequantize : List Arg → Bool
  | [o, w, sc, bi, g, b, mode, gs, dt, _] => hdOk x w && hdOk x sc && hdOk x bi && natOk P g && natOk P b &&
    natOk P gs && natOk P dt &&
    match Host.Mlx.Ffi.arrIns x [w, sc, bi], Host.Mlx.Ffi.optIntArg g, Host.Mlx.Ffi.optIntArg b,
      Host.Mlx.Ffi.cstrArg mode, Host.Mlx.Ffi.argNat gs, Host.Mlx.Ffi.optIntArg dt with
    | some ins, some gv, some bv, some m, some 0, some dv => opCheck P x o (.dequantize (gv.getD 64) (bv.getD 4) m dv) ins
    | _, _, _, _, _, _ => false
  | _ => false

def take : List Arg → Bool
  | [o, a, i, ax, _] => nodeOk x a && hdOk x i && natOk P ax &&
    match Host.Mlx.Ffi.arrIns x [a, i], Host.Mlx.Ffi.argInt ax, (Host.Mlx.Ffi.argNat a).bind x.node? with
    | some ins, some av, some nd => match Host.Mlx.Ffi.axisOf av (len nd.shape) with
      | some b => opCheck P x o (.take b) ins
      | none => false
    | _, _, _ => false
  | _ => false

def conv1d : List Arg → Bool
  | [o, a, w, st, pd, dl, gr, _] => hdOk x a && hdOk x w && natOk P st && natOk P pd && natOk P dl && natOk P gr &&
    match Host.Mlx.Ffi.arrIns x [a, w], Host.Mlx.Ffi.argNat st, Host.Mlx.Ffi.argNat pd, Host.Mlx.Ffi.argNat dl,
      Host.Mlx.Ffi.argNat gr with
    | some ins, some v1, some v2, some v3, some v4 => opCheck P x o (.conv1d v1 v2 v3 v4) ins
    | _, _, _, _, _ => false
  | _ => false

/-- The per-symbol checks. -/
def sym (name : Name) : Host.Mlx.Ffi.Sym → List Arg → Bool
  | .arrayNew => fun as => as.isEmpty
  | .arrayFree => free x
  | .arrayEval => node1 x
  | .arrayNdim => ndim P x
  | .arrayShape => node1 x
  | .arrayDtype => node1 x
  | .arraySize => size P x
  | .vecNew => new0 P x
  | .vecFree => any1
  | .vecSize => vsize P x
  | .vecGet => vget P x
  | .vecNewData => vdata P x
  | .asyncEval => vec1 x
  | .cfgNew => new0 P x
  | .cfgFree => any1
  | .cfgOutput => cout P x
  | .cfgGrid => cnums x
  | .cfgGroup => cnums x
  | .cfgInt => cint x
  | .cfgDtype => cdtype P x
  | .kernelApply => kapply P x
  | .arrayNewData => newData P x
  | .zeros => zeros P x
  | .itemU32 => item x
  | .reshape => reshape P x
  | .transpose => transpose P x
  | .slice => slice P x
  | .sliceUpdate => sliceUpdate P x
  | .sliceDynamic => sliceDynamic P x
  | .concat => concat P x
  | .unary => unary P x name
  | .binary => binary P x name
  | .rmsNorm => rms P x
  | .rope => rope P x
  | .sdpa => sdpa P x
  | .qmm => qmm P x
  | .dequantize => dequantize P x
  | .take => take P x
  | .conv1d => conv1d P x
  | .clearCache => fun as => as.isEmpty
  | .synchronize => any1
  | .setWiredLimit => wired P x
  | _ => fun _ => false
end NativeOk

/-- **The accepted native calls.** -/
def okCall (P : LoadP) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && match Host.Mlx.Ffi.symOf name with
    | some s => NativeOk.sym P x.mlx name s args
    | none => false

/-- No callback continuation is accepted. -/
def okBack (_x : Host.Load.LSt) (_a : Arg) : Bool := false

end Host.Ts.Sim
