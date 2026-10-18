import host.ts.Harness
namespace Host.Mlx.Ffi
open Host.Ts

/-! # The mlx-c FFI at the shape and dtype level

The interpreter's `Ffi` for `libmlxc` (mlx-c over MLX v0.32.2, pinned in
`proofs/check.ts`). MLX is a trusted dependency whose C API operations are
functions on immutable array values (`Host.Mlx.Value`, `Host.Mlx.Ops`);
this model keeps what the TypeScript observes without reading values:
handles, the graph each array is a node of, shapes and dtypes, and the
native objects around them.

* Arrays: a handle (`mlx_array.ctx`) names a node; `mlx_array_new` is the
  null handle and an operation writing `*res` allocates (null) or
  reassigns (`mlx_array_set_`, mlx-c `private/array.h`). A node is the
  producing primitive, its argument nodes and the shape and dtype MLX
  infers (`ops.cpp`, `fast.cpp`). `mlx_array_free` releases the handle,
  not the node (graphs and vectors keep nodes alive); a freed handle is
  unusable (the model gets stuck).
* Dimensions are integers or numbers of the run's number server
  (`Dim.sym`): a cache offset `n` stays symbolic through slices and
  concatenations, and every comparison MLX's shape inference makes on it
  is a server test (an oracle answer in a symbolic run).
* `mlx_array_shape` returns native memory (region `4h`) read through
  `toArrayBuffer`.
* Vectors of arrays hold nodes; vectors of strings their length.
* Metal kernels (name, source and header, as created) and their configurations;
  an application node names the kernel object, and its outputs are
  the configuration's output shapes and dtypes.
* Closures: `mlx_compile` of a payload closure; the first
  `mlx_closure_apply` per input signature (dtypes and shapes, or ndims when
  shapeless) traces: the call invokes the payload's `JSCallback` with
  tracer inputs (`Ret.callback`), the trace function's outputs come back
  through `mlx_vector_array_set_data`, and the call continues (`back`) by
  replaying the traced graph on the real inputs, as MLX's compiler does;
  replayed nodes are tagged with the closure (`Prim.replayed`): MLX runs them
  as the closure's compiled graph.
  Later applies replay without calling JavaScript.
* Values the TypeScript reads back (`mlx_array_item_uint32`, the sampled
  token) come from `tokens`, consumed in order at the first read of a node
  (numbers of the run's server, so a symbolic run reads symbolic tokens); a
  node read again returns its value (`items`). The trace is otherwise
  independent of array values.
* Weights: `mlx_load_safetensors` returns a map over the file's header
  (`files`, path ↦ name, shape, dtype), supplied as a literal bound to the
  checkpoint by `models/qwen/CheckpointFile*`.

An operation MLX would reject (status 1 through the error handler) leaves
the model stuck: a completed run never made one. Device facts the runtime
reads (`arch`, `deviceSizes`) are parameters. -/

/-! ## Dimensions -/

inductive Dim where
  | lit (i : Int)
  | sym (x : NumV)
deriving DecidableEq

def Dim.num : Dim → NumV
  | .lit i => .lit (F64.ofInt i)
  | .sym x => x

/-- A number as a dimension: integers literal, the rest symbolic. -/
def dimOf (x : NumV) : Dim :=
  match x with
  | .lit f => match F64.toInt? f with
    | some i => .lit i
    | none => .sym x
  | .ref _ => .sym x

def lits (xs : List Int) : List Dim := xs.map Dim.lit

def dAdd : Dim → Dim → M Dim
  | .lit a, .lit b => .pure (.lit (a + b))
  | a, b => .bind (numBin .add a.num b.num) fun r => .pure (dimOf r)

def dSub : Dim → Dim → M Dim
  | .lit a, .lit b => .pure (.lit (a - b))
  | a, b => .bind (numBin .sub a.num b.num) fun r => .pure (dimOf r)

def dMul : Dim → Dim → M Dim
  | .lit a, .lit b => .pure (.lit (a * b))
  | a, b => .bind (numBin .mul a.num b.num) fun r => .pure (dimOf r)

def dEq : Dim → Dim → M Bool
  | .lit a, .lit b => .pure (decide (a = b))
  | a, b => bif decide (a = b) then .pure true else numTest .eq a.num b.num

def dLt : Dim → Dim → M Bool
  | .lit a, .lit b => .pure (decide (a < b))
  | a, b => numTest .lt a.num b.num

def dMin (a b : Dim) : M Dim := .bind (dLt a b) fun l => .pure (bif l then a else b)
def dMax (a b : Dim) : M Dim := .bind (dLt a b) fun l => .pure (bif l then b else a)

def allEq : List Dim → List Dim → M Bool
  | [], [] => .pure true
  | a :: as, b :: bs => .bind (dEq a b) fun e => bif e then allEq as bs else .pure false
  | _, _ => .pure false

/-- Product of dimensions. -/
def dProd : List Dim → M Dim
  | [] => .pure (.lit 1)
  | d :: ds => .bind (dProd ds) fun p => dMul d p

/-! ## Dtypes (mlx `dtype.cpp`) -/

/-- `mlx_dtype` codes: bool 0, uint8…uint64 1–4, int8…int64 5–8, float16 9,
float32 10, float64 11, bfloat16 12, complex64 13. -/
def dtBool : Nat := 0
def dtUint32 : Nat := 3
def dtInt32 : Nat := 7
def dtF16 : Nat := 9
def dtF32 : Nat := 10
def dtBf16 : Nat := 12

def isFloat (d : Nat) : Bool := Nat.ble 9 d && Nat.ble d 12
def isInexact (d : Nat) : Bool := Nat.ble 9 d && Nat.ble d 13
def isInteger (d : Nat) : Bool := Nat.ble 1 d && Nat.ble d 8

/-- `type_rules` of `dtype.cpp`, row by row. -/
def promoteRows : List (List Nat) :=
  [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
   [1, 1, 2, 3, 4, 6, 6, 7, 8, 9, 10, 11, 12, 13],
   [2, 2, 2, 3, 4, 7, 7, 7, 8, 9, 10, 11, 12, 13],
   [3, 3, 3, 3, 4, 8, 8, 8, 8, 9, 10, 11, 12, 13],
   [4, 4, 4, 4, 4, 10, 10, 10, 10, 9, 10, 11, 12, 13],
   [5, 6, 7, 8, 10, 5, 6, 7, 8, 9, 10, 11, 12, 13],
   [6, 6, 7, 8, 10, 6, 6, 7, 8, 9, 10, 11, 12, 13],
   [7, 7, 7, 8, 10, 7, 7, 7, 8, 9, 10, 11, 12, 13],
   [8, 8, 8, 8, 10, 8, 8, 8, 8, 9, 10, 11, 12, 13],
   [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10, 11, 10, 13],
   [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 11, 10, 13],
   [11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 13],
   [12, 12, 12, 12, 12, 12, 12, 12, 12, 10, 10, 11, 12, 13],
   [13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13]]

/-- Element bytes of a dtype. -/
def dtSize (d : Nat) : Nat := nthD 8 [1, 1, 2, 4, 8, 1, 2, 4, 8, 2, 4, 8, 2, 8] d

def promote (a b : Nat) : Nat := nthD 13 (nthD [] promoteRows a) b

def atLeastFloat (d : Nat) : Nat := bif isInexact d then d else dtF32

/-! ## Graph nodes -/

/-- A kernel launch configuration (`mlx_fast_metal_kernel_config`). -/
structure Cfg where
  outs : List (List Dim × Nat)
  grid : List NumV
  group : List NumV
  ints : List (List Char × NumV)
  dtypes : List (List Char × Nat)
  init : Option NumV

def Cfg.empty : Cfg := ⟨[], [], [], [], [], none⟩

/-- The primitive producing a node, with the parameters its shape inference reads. -/
inductive Prim where
  /-- Host data (`mlx_array_new_data`): its bytes as the JS buffer held them. -/
  | data (bytes : List Byte)
  /-- A safetensors tensor. -/
  | load (file key : List Char)
  /-- Compile-trace input `i`. -/
  | tracer (i : Nat)
  | zeros
  | arange (start stop step : NumV)
  | reshape (shape : List Dim)
  | transpose (axes : List Nat)
  | slice (start stop strides : List Dim)
  | sliceUpdate (start stop strides : List Dim)
  | sliceDynamic (axes : List Nat) (sizes : List Dim)
  | concat (axis : Nat)
  | unary (op : List Char)
  | binary (op : List Char)
  | astype (dtype : Nat)
  | contiguous
  | rmsNorm (eps : NumV)
  | rope (dims : Nat) (traditional : Bool) (base : Arg) (scale offset : NumV)
  | sdpa (scale : NumV) (mask : List Char)
  | qmm (transpose : Bool) (group bits : Nat) (mode : List Char)
  | dequantize (group bits : Nat) (mode : List Char) (dtype : Option Nat)
  | take (axis : Nat)
  | conv1d (stride padding dilation groups : Nat)
  | logsumexp (axis : Nat) (keep : Bool)
  /-- Output `out` of an application of Metal kernel object `k` (its name, source and header). -/
  | kernel (k : Nat) (cfg : Cfg) (out : Nat)
  /-- A node a compiled closure's replay emitted (closure object `cls`): MLX runs the replayed
  graph as the closure's compiled graph, whose fused numerics need not be the eager operations'. -/
  | replayed (cls : Nat) (p : Prim)

structure Node where
  prim : Prim
  ins : List Nat
  shape : List Dim
  dtype : Nat

/-- A traced graph: tracer nodes for the inputs, output nodes, and the
other nodes reachable from the outputs in dependency order. -/
structure Trace where
  ins : List Nat
  outs : List Nat
  order : List Nat

inductive Clo where
  /-- `mlx_closure_new`: empty. -/
  | empty
  /-- `mlx_closure_new_func_payload(fun, payload, dtor)`: `fun` a `JSCallback` region. -/
  | fn (cb : Nat) (payload : Arg)
  /-- `mlx_compile(fun, shapeless)` with the traces made so far. -/
  | compiled (cb : Nat) (payload : Arg) (shapeless : Bool) (traces : List Trace)

/-- Native objects other than arrays. -/
inductive Obj where
  | stream
  | str (s : List Char)
  | vec (nodes : List Nat)
  | vstr (n : Nat)
  /-- `mlx_fast_metal_kernel_new`: name, Metal source and header, input and output name counts. -/
  | kernel (name source header : List Char) (nIn nOut : Nat)
  | cfg (c : Cfg)
  | clo (c : Clo)
  /-- A string-to-array map over safetensors file `file` (none: empty). -/
  | amap (file : Option (List Char))
  | smap
  | device
  | dinfo

/-- An apply waiting for its trace function: the caller's result slot,
the compiled closure, the real and tracer inputs, the traced outputs. -/
structure Pending where
  id : Nat
  outBuf : Nat
  outOff : Nat
  outSlot : Nat
  cls : Nat
  ins : List Nat
  tracers : List Nat
  res : Option (List Nat)

/-- A safetensors header: tensor name, shape, `mlx_dtype` code. -/
abbrev Header := List (List Char × List Nat × Nat)

structure St where
  next : Nat
  nodes : PTrie Node
  nnext : Nat
  arrs : PTrie Nat
  objs : PTrie Obj
  /-- Values `mlx_array_item_uint32` returns, in order (numbers of the run's server: a
  symbolic run reads symbolic tokens). -/
  tokens : List NumV
  files : List (List Char × Header)
  pending : List Pending
  errh : Option Arg
  /-- `mlx_device_info` facts: the `architecture` string and size entries. -/
  arch : List Char
  deviceSizes : List (List Char × Nat)
  wired : Nat
  /-- Values read back so far, by node: reading an array again returns the same value. -/
  items : PTrie NumV

def init (tokens : List NumV) (files : List (List Char × Header)) (arch : List Char)
    (deviceSizes : List (List Char × Nat)) : St :=
  ⟨1, .nil, 1, .nil, .nil, tokens, files, [], none, arch, deviceSizes, 0, .nil⟩

/-! ## State access -/

def St.node? (s : St) (h : Nat) : Option Node := (s.arrs.get h).bind s.nodes.get
def St.nodeId? (s : St) (h : Nat) : Option Nat := bif Nat.beq h 0 then none else s.arrs.get h
def St.obj? (s : St) (h : Nat) : Option Obj := s.objs.get h

def St.newObj (s : St) (o : Obj) : Nat × St := (s.next, { s with next := s.next + 1, objs := s.objs.set s.next o })
def St.setObj (s : St) (h : Nat) (o : Obj) : St := { s with objs := s.objs.set h o }
def St.addNode (s : St) (n : Node) : Nat × St := (s.nnext, { s with nnext := s.nnext + 1, nodes := s.nodes.set s.nnext n })

/-- `mlx_array_set_(*res, node)`: a null slot gets a new handle, a handle is reassigned. -/
def St.setArr (s : St) (slot : Nat) (node : Nat) : Nat × St :=
  bif Nat.beq slot 0 then (s.next, { s with next := s.next + 1, arrs := s.arrs.set s.next node })
  else (slot, { s with arrs := s.arrs.set slot node })

def St.freeArr (s : St) (h : Nat) : St :=
  bif Nat.beq h 0 then s else { s with arrs := s.arrs.set h 0 }

/-! ## Arguments -/

def argInt : Arg → Option Int
  | .big i => some i
  | .num (.lit x) => F64.toInt? x
  | .null => some 0
  | _ => none

def argNat (a : Arg) : Option Nat := (argInt a).bind fun i => bif decide (0 ≤ i) then some i.toNat else none

def argBool : Arg → Option Bool
  | .bool b => some b
  | _ => none

/-- A JS out-param slot: buffer, offset, the handle it holds. -/
def slotOf : Arg → Option (Nat × Nat × Nat)
  | .jsPtr b off bs => match readCell .u64 bs with
    | some (.big i) => some (b, off, i.toNat)
    | _ => none
  | _ => none

def cellsI32 : Nat → List Byte → Option (List NumV)
  | 0, _ => some []
  | n + 1, bs => match readCell .i32 bs with
    | some (.num x) => (cellsI32 n (bs.drop 4)).map (x :: ·)
    | _ => none

def cellsU64 : Nat → List Byte → Option (List Nat)
  | 0, _ => some []
  | n + 1, bs => match readCell .u64 bs with
    | some (.big i) => (cellsU64 n (bs.drop 8)).map (i.toNat :: ·)
    | _ => none

/-- `int*` with its count. -/
def dimsArg (p n : Arg) : Option (List Dim) :=
  match p, argNat n with
  | _, some 0 => some []
  | .jsPtr _ _ bs, some k => (cellsI32 k bs).map (·.map dimOf)
  | _, _ => none

def handlesArg (p n : Arg) : Option (List Nat) :=
  match p, argNat n with
  | _, some 0 => some []
  | .jsPtr _ _ bs, some k => cellsU64 k bs
  | _, _ => none

def natsOfDims : List Dim → Option (List Nat)
  | [] => some []
  | .lit i :: ds => bif decide (0 ≤ i) then (natsOfDims ds).map (i.toNat :: ·) else none
  | _ => none

/-- A NUL-terminated C string from a JS buffer pointer. -/
def cstrBytes : Nat → List Byte → Option (List Char)
  | 0, _ => none
  | _ + 1, [] => none
  | f + 1, .lit b :: bs => bif Nat.beq b 0 then some [] else (cstrBytes f bs).map (Char.ofNat b :: ·)
  | _ + 1, _ => none

def cstrArg : Arg → Option (List Char)
  | .jsPtr _ _ bs => cstrBytes (bs.length + 1) bs
  | _ => none

/-- `mlx_optional_int`: value in bits 0–31, `has_value` at bit 32. -/
def optIntArg (a : Arg) : Option (Option Nat) :=
  (argNat a).map fun v => bif Nat.beq (v / 2 ^ 32 % 2) 1 then some (v % 2 ^ 32) else none

def u64Write (b off v : Nat) : Nat × Nat × List Byte := (b, off, cellParts .u64 (.big v) 8 0)

/-! ## Shape inference (MLX `ops.cpp`, `fast.cpp`) -/

/-- Normalized axis (`normalize_axis_index`). -/
def axisOf (a : Int) (nd : Nat) : Option Nat :=
  let x := bif decide (a < 0) then a + nd else a
  bif decide (0 ≤ x ∧ x < nd) then some x.toNat else none

/-- Right-aligned broadcast of two shapes (`broadcast_shapes`). -/
def broadcast (a b : List Dim) : M (Option (List Dim)) :=
  let rec go : List Dim → List Dim → M (Option (List Dim))
    | [], ys => .pure (some ys.reverse)
    | xs, [] => .pure (some xs.reverse)
    | x :: xs, y :: ys => .bind (dEq x y) fun e =>
      bif e then .bind (go xs ys) fun r => .pure (r.map (· ++ [x]))
      else bif decide (x = .lit 1) then .bind (go xs ys) fun r => .pure (r.map (· ++ [y]))
      else bif decide (y = .lit 1) then .bind (go xs ys) fun r => .pure (r.map (· ++ [x]))
      else .pure none
  .bind (go a.reverse b.reverse) fun r => .pure r

/-- One axis of `normalize_slice` for a positive stride: output length. -/
def sliceAxis (n s e str : Dim) : M (Option Dim) :=
  .bind (dLt s (.lit 0)) fun sn => .bind (bif sn then dAdd s n else .pure s) fun s =>
  .bind (dLt e (.lit 0)) fun en => .bind (bif en then dAdd e n else .pure e) fun e =>
  .bind (dMin s n) fun st => .bind (dMax (.lit 0) st) fun st =>
  .bind (dMin e n) fun ed => .bind (dMax (.lit 0) ed) fun ed =>
  .bind (dLt ed st) fun lt => let ed := bif lt then st else ed
  match str with
  | .lit 1 => .bind (dSub ed st) fun r => .pure (some r)
  | .lit k => bif decide (0 < k) then match ed, st with
      | .lit a, .lit b => .pure (some (.lit ((a - b + k - 1) / k)))
      | _, _ => .pure none
    else .pure none
  | .sym _ => .pure none

def sliceShape : List Dim → List Dim → List Dim → List Dim → M (Option (List Dim))
  | [], [], [], [] => .pure (some [])
  | n :: ns, s :: ss, e :: es, k :: ks => .bind (sliceAxis n s e k) fun
    | some d => .bind (sliceShape ns ss es ks) fun r => .pure (r.map (d :: ·))
    | none => .pure none
  | _, _, _, _ => .pure none

/-- `reshape` shape with one inferred `-1` (`Reshape::output_shape`). -/
def reshapeShape (old new : List Dim) : M (Option (List Dim)) :=
  .bind (dProd old) fun total =>
  match new.filter (· = .lit (-1)) with
  | [] => .bind (dProd new) fun p => .bind (dEq p total) fun e => .pure (bif e then some new else none)
  | [_] => .bind (dProd (new.filter (· ≠ .lit (-1)))) fun p =>
    match total, p with
    | .lit t, .lit q => bif decide (q ≠ 0 ∧ t % q = 0) then .pure (some (new.map fun d => bif decide (d = .lit (-1)) then .lit (t / q) else d))
      else .pure none
    | _, _ => .pure none
  | _ => .pure none

def setAt {α : Type} : List α → Nat → α → List α
  | [], _, _ => []
  | _ :: xs, 0, v => v :: xs
  | x :: xs, n + 1, v => x :: setAt xs n v

/-- A node's shape and dtype from its inputs, or that it is input `i` itself. -/
inductive Out where
  | node (shape : List Dim) (dtype : Nat)
  | same (i : Nat)

def concatShape (axis : Nat) : List (List Dim × Nat) → M (Option (List Dim × Nat))
  | [] => .pure none
  | [(s, d)] => .pure (some (s, d))
  | (s, d) :: rest => .bind (concatShape axis rest) fun
    | some (r, dr) => bif Nat.beq (len s) (len r) then
        .bind (allEq (setAt s axis (.lit 0)) (setAt r axis (.lit 0))) fun e =>
        bif e then .bind (dAdd (nthD (.lit 0) s axis) (nthD (.lit 0) r axis)) fun a =>
          .pure (some (setAt s axis a, promote d dr))
        else .pure none
      else .pure none
    | none => .pure none

def unaryDtype (op : List Char) (d : Nat) : Nat :=
  bif nameEq op chars!"negative" || nameEq op chars!"contiguous" then d else atLeastFloat d

def binaryDtype (op : List Char) (a b : Nat) : Nat :=
  bif nameEq op chars!"divide" || nameEq op chars!"logaddexp" then atLeastFloat (promote a b) else promote a b

/-- Shape inference of a primitive over its inputs' shapes and dtypes. -/
def infer (p : Prim) (ins : List (List Dim × Nat)) : M (Option Out) :=
  match p, ins with
  | .replayed _ q, ins => infer q ins
  | .reshape new, [(s, d)] => .bind (reshapeShape s new) fun r => .pure (r.map (.node · d))
  | .transpose axes, [(s, d)] =>
    bif Nat.beq (len axes) (len s) && (List.range (len s)).all (fun a => axes.any (Nat.beq a)) then
      .pure (some (.node (axes.map (nthD (.lit 0) s)) d)) else .pure none
  | .slice st sp sr, [(s, d)] => bif Nat.beq (len st) (len s) then
      .bind (sliceShape s st sp sr) fun
        | some r => .bind (allEq r s) fun e => .pure (some (bif e then .same 0 else .node r d))
        | none => .pure none
    else .pure none
  | .sliceUpdate st sp sr, [(s, d), (u, _)] => .bind (sliceShape s st sp sr) fun
    | some r => .bind (broadcast u r) fun
      | some b => .bind (allEq b r) fun ok => bif ok then .pure (some (.node s d)) else .pure none
      | none => .pure none
    | none => .pure none
  | .sliceDynamic axes sizes, [(s, d), (st, sd)] =>
    bif Nat.beq (len sizes) (len s) && isInteger sd && Nat.ble (len st) 1 && axes.all (Nat.blt · (len s)) then
      .pure (some (.node sizes d)) else .pure none
  | .concat axis, xs => bif Nat.beq (len xs) 1 then .pure (some (.same 0)) else
    .bind (concatShape axis xs) fun r => .pure (r.map fun (s, d) => .node s d)
  | .unary op, [(s, d)] => .pure (some (.node s (unaryDtype op d)))
  | .binary op, [(a, da), (b, db)] => .bind (broadcast a b) fun r => .pure (r.map (.node · (binaryDtype op da db)))
  | .astype d, [(s, _)] => .pure (some (.node s d))
  | .contiguous, [(s, d)] => .pure (some (.node s d))
  | .rmsNorm _, [(s, d)] => bif isFloat d then .pure (some (.node s d)) else .pure none
  | .rmsNorm _, [(s, d), (w, dw)] => match w with
    | [n] => .bind (dEq n (nthD (.lit 0) s (len s - 1))) fun e =>
      bif e && isFloat (promote d dw) then .pure (some (.node s (promote d dw))) else .pure none
    | _ => .pure none
  | .rope _ _ _ _ _, [(s, d)] => bif Nat.ble 3 (len s) then .pure (some (.node s d)) else .pure none
  | .sdpa _ _, [(q, dq), (k, dk), (v, dv)] =>
    bif Nat.beq (len q) 4 && Nat.beq (len k) 4 && Nat.beq (len v) 4 then
      .pure (some (.node (setAt q 3 (nthD (.lit 0) v 3)) (promote dq (promote dk dv)))) else .pure none
  | .qmm tr g b mode, [(x, dx), (w, dw), (sc, dsc), (bi, dbi)] =>
    bif !(nameEq mode chars!"affine") || !(Nat.beq dw dtUint32) || Nat.beq b 0 then .pure none else
    let wl := nthD (.lit 0) w (len w - 1)
    let w2 := nthD (.lit 0) w (len w - 2)
    match wl, w2 with
    | .lit wl, .lit w2 =>
      let inner : Int := bif tr then wl * 32 / b else w2
      let outer : Int := bif tr then w2 else wl * 32 / b
      .bind (dEq (nthD (.lit 0) x (len x - 1)) (.lit inner)) fun e =>
      .bind (allEq sc bi) fun sb =>
      let dt := promote dx (promote dsc dbi)
      bif e && sb && Nat.ble 2 (len w) && isFloat dt then
        .pure (some (.node (setAt x (len x - 1) (.lit outer)) dt)) else .pure none
      | _, _ => .pure none
  | .dequantize g b mode dt, [(w, dw), (sc, dsc), (bi, dbi)] =>
    bif !(nameEq mode chars!"affine") || !(Nat.beq dw dtUint32) || Nat.beq b 0 then .pure none else
    match nthD (.lit 0) w (len w - 1) with
    | .lit wl => .bind (allEq sc bi) fun sb =>
      let d := match dt with | some d => d | none => promote dsc dbi
      let _ := g
      bif sb then .pure (some (.node (setAt w (len w - 1) (.lit (wl * 32 / b))) d)) else .pure none
    | _ => .pure none
  | .take axis, [(a, d), (i, di)] => bif Nat.blt axis (len a) && isInteger di then
      .pure (some (.node (a.take axis ++ i ++ a.drop (axis + 1)) d)) else .pure none
  | .conv1d stride pad dil groups, [(x, dx), (w, dw)] => match x, w with
    | [n, l, c], [o, k, ci] => match l, k, c, ci with
      | .lit l, .lit k, .lit c, .lit ci =>
        bif decide (0 < stride ∧ 0 < groups ∧ c = ci * groups) then
          let lo : Int := (l + 2 * pad - dil * (k - 1) - 1) / stride + 1
          .pure (some (.node [n, .lit lo, o] (promote dx dw))) else .pure none
      | _, _, _, _ => .pure none
    | _, _ => .pure none
  | .logsumexp axis keep, [(s, d)] => bif Nat.blt axis (len s) then
      .pure (some (.node (bif keep then setAt s axis (.lit 1) else s.take axis ++ s.drop (axis + 1)) (atLeastFloat d)))
    else .pure none
  | _, _ => .pure none

/-! ## Calls -/

abbrev R := M (Option (St × Ret × List (Nat × Nat × List Byte)))

def ok (s : St) (r : Ret) : R := .pure (some (s, r, []))
def okW (s : St) (r : Ret) (ws : List (Nat × Nat × List Byte)) : R := .pure (some (s, r, ws))
def status0 : Ret := .num zeroN
def stuck : R := .pure none

def shapesOf (s : St) : List Nat → Option (List (List Dim × Nat))
  | [] => some []
  | n :: ns => (s.nodes.get n).bind fun nd => (shapesOf s ns).map ((nd.shape, nd.dtype) :: ·)

def nodesOf (s : St) : List Nat → Option (List Nat)
  | [] => some []
  | h :: hs => (s.nodeId? h).bind fun n => (nodesOf s hs).map (n :: ·)

/-- An operation writing its result into the JS slot `o`: infer, add the node, write the handle. -/
def opOut (s : St) (o : Arg) (p : Prim) (ins : List Nat) : R :=
  match slotOf o, shapesOf s ins with
  | some (b, off, slot), some sh => .bind (infer p sh) fun
    | some (.node shape dt) =>
      let (n, s) := s.addNode ⟨p, ins, shape, dt⟩
      let (h, s) := s.setArr slot n
      okW s status0 [u64Write b off h]
    | some (.same i) => match nth? ins i with
      | some n => let (h, s) := s.setArr slot n; okW s status0 [u64Write b off h]
      | none => stuck
    | none => stuck
  | _, _ => stuck

/-- A node with a given shape (data, zeros, loads). -/
def leafOut (s : St) (o : Arg) (p : Prim) (shape : List Dim) (dt : Nat) : R :=
  match slotOf o with
  | some (b, off, slot) =>
    let (n, s) := s.addNode ⟨p, [], shape, dt⟩
    let (h, s) := s.setArr slot n
    okW s status0 [u64Write b off h]
  | none => stuck

def arrIns (s : St) (hs : List Arg) : Option (List Nat) :=
  hs.mapM fun a => (argNat a).bind s.nodeId?

def unaryOps : List (List Char) := [chars!"mlx_sigmoid", chars!"mlx_exp", chars!"mlx_negative", chars!"mlx_tanh",
  chars!"mlx_erf", chars!"mlx_log", chars!"mlx_sqrt", chars!"mlx_rsqrt", chars!"mlx_square", chars!"mlx_abs",
  chars!"mlx_cos", chars!"mlx_sin", chars!"mlx_log10", chars!"mlx_stop_gradient"]

def binaryOps : List (List Char) := [chars!"mlx_add", chars!"mlx_subtract", chars!"mlx_multiply", chars!"mlx_divide",
  chars!"mlx_power", chars!"mlx_logaddexp", chars!"mlx_maximum", chars!"mlx_minimum"]

def strip (name : List Char) : List Char := name.drop 4

/-! ### Compiled closures -/

/-- Nodes reachable from the stack's roots, stopping at `stop`, dependencies
first: depth-first with an explicit stack, fuel-bounded. -/
def topo (s : St) (stop : List Nat) : Nat → List (Nat × Bool) → List Nat → List Nat → Option (List Nat)
  | 0, _, _, _ => none
  | _ + 1, [], _, out => some out.reverse
  | f + 1, (n, true) :: st, seen, out => topo s stop f st seen (n :: out)
  | f + 1, (n, false) :: st, seen, out =>
    bif seen.any (Nat.beq n) || stop.any (Nat.beq n) then topo s stop f st seen out
    else match s.nodes.get n with
      | some nd => topo s stop f (nd.ins.map (·, false) ++ (n, true) :: st) (n :: seen) out
      | none => none

def substOf (m : List (Nat × Nat)) (n : Nat) : Nat := ((m.find? fun (a, _) => Nat.beq a n).map Prod.snd).getD n

/-- A Metal kernel application, replayed or not. -/
def isKernel : Prim → Bool
  | .kernel _ _ _ => true
  | .replayed _ p => isKernel p
  | _ => false

/-- Rebuild the traced nodes of closure `cls` in order over substituted inputs, shapes
re-inferred (constants and leaves are shared, as the compiled graph captures them); every
rebuilt node is tagged `replayed cls`. -/
def replayOrder (s : St) (cls : Nat) : List (Nat × Nat) → List Nat → M (Option (St × List (Nat × Nat)))
  | m, [] => .pure (some (s, m))
  | m, n :: ns => match s.nodes.get n with
    | some nd => match nd.prim with
      | .data _ | .load _ _ | .zeros | .arange _ _ _ | .tracer _ => replayOrder s cls m ns
      | p => bif isKernel p then
          let (k, s) := s.addNode ⟨.replayed cls p, nd.ins.map (substOf m), nd.shape, nd.dtype⟩
          replayOrder s cls ((n, k) :: m) ns
        else
        let ins := nd.ins.map (substOf m)
        bif decide (ins = nd.ins) then replayOrder s cls m ns else
        match shapesOf s ins with
        | some sh => .bind (infer p sh) fun
          | some (.node shape dt) => let (k, s) := s.addNode ⟨.replayed cls p, ins, shape, dt⟩; replayOrder s cls ((n, k) :: m) ns
          | some (.same i) => match nth? ins i with
            | some k => replayOrder s cls ((n, k) :: m) ns
            | none => .pure none
          | none => .pure none
        | none => .pure none
    | none => .pure none

def replay (s : St) (cls : Nat) (t : Trace) (xs : List Nat) : M (Option (St × List Nat)) :=
  .bind (replayOrder s cls (t.ins.zip xs) t.order) fun
    | some (s, m) => .pure (some (s, t.outs.map (substOf m)))
    | none => .pure none
/-- Inputs match a trace: dtypes, and shapes (or ndims when shapeless). -/
def traceFits (s : St) (shapeless : Bool) (t : Trace) (xs : List Nat) : M Bool :=
  match shapesOf s t.ins, shapesOf s xs with
  | some a, some b =>
    let rec go : List (List Dim × Nat) → List (List Dim × Nat) → M Bool
      | [], [] => .pure true
      | (sa, da) :: ra, (sb, db) :: rb => bif !(Nat.beq da db) || !(Nat.beq (len sa) (len sb)) then .pure false
        else bif shapeless then go ra rb else .bind (allEq sa sb) fun e => bif e then go ra rb else .pure false
      | _, _ => .pure false
    go a b
  | _, _ => .pure false

def findTrace (s : St) (shapeless : Bool) (xs : List Nat) : List Trace → M (Option Trace)
  | [] => .pure none
  | t :: ts => .bind (traceFits s shapeless t xs) fun m => bif m then .pure (some t) else findTrace s shapeless xs ts

/-- `mlx_vector_array_set_(*res, nodes)`: a vector slot reassigned or a new vector. -/
def setVec (s : St) (slot : Nat) (ns : List Nat) : Nat × St :=
  match s.obj? slot with
  | some (.vec _) => (slot, s.setObj slot (.vec ns))
  | _ => s.newObj (.vec ns)

/-- Finish an apply: outputs replayed on the real inputs, written to the caller's slot. -/
def applyDone (s : St) (cls b off slot : Nat) (t : Trace) (xs : List Nat) : R :=
  .bind (replay s cls t xs) fun
    | some (s, outs) => let (v, s) := setVec s slot outs; okW s status0 [u64Write b off v]
    | none => stuck

def closureApply (s : St) (o cls inv : Arg) : R :=
  match slotOf o, (argNat cls).bind s.obj?, (argNat inv).bind s.obj?, argNat cls with
  | some (b, off, slot), some (.clo (.compiled cb payload shapeless traces)), some (.vec xs), some c =>
    .bind (findTrace s shapeless xs traces) fun
      | some t => applyDone s c b off slot t xs
      | none => match shapesOf s xs with
        | some sh =>
          -- trace: tracer inputs with the real inputs' shapes and dtypes
          let rec tracers (s : St) (i : Nat) : List (List Dim × Nat) → St × List Nat
            | [] => (s, [])
            | (shape, dt) :: r => let (n, s) := s.addNode ⟨.tracer i, [], shape, dt⟩
              let (s, ns) := tracers s (i + 1) r; (s, n :: ns)
          let (s, ts) := tracers s 0 sh
          let (tv, s) := s.newObj (.vec ts)
          let p : Pending := ⟨s.next, b, off, slot, c, xs, ts, none⟩
          let s := { s with next := s.next + 1, pending := p :: s.pending }
          ok s (.callback cb [.extPtr (4 * p.id + 2) 0, .big tv, payload])
        | none => stuck
  | _, _, _, _ => stuck

/-- The trace function returned (`back`): status 0 and outputs set. -/
def traceBack (s : St) (status : Arg) : R :=
  match s.pending, argNat status with
  | p :: rest, some 0 => match p.res, s.obj? p.cls with
    | some outs, some (.clo (.compiled cb payload shapeless traces)) =>
      match topo s p.tracers 4096 (outs.map (·, false)) [] [] with
      | some order =>
        let t : Trace := ⟨p.tracers, outs, order⟩
        -- a shapeless graph re-infers shapes: custom kernels have no shape inference
        bif shapeless && order.any (fun n => match s.nodes.get n with | some nd => isKernel nd.prim | none => false) then stuck else
        let s := { s.setObj p.cls (.clo (.compiled cb payload shapeless (traces ++ [t]))) with pending := rest }
        applyDone s p.cls p.outBuf p.outOff p.outSlot t p.ins
      | none => stuck
    | _, _ => stuck
  | _, _ => stuck

/-! ### Kernels -/

def cfgUpdate (s : St) (cfg : Arg) (f : Cfg → Option Cfg) : R :=
  match (argNat cfg).bind fun h => (s.obj? h).map (h, ·) with
  | some (h, .cfg c) => match f c with
    | some c => ok (s.setObj h (.cfg c)) status0
    | none => stuck
  | _ => stuck

def kernelApply (s : St) (o k inv cfg : Arg) : R :=
  match slotOf o, (argNat k).bind fun h => (s.obj? h).map (h, ·), (argNat inv).bind s.obj?, (argNat cfg).bind s.obj? with
  | some (b, off, slot), some (kh, .kernel _ _ _ _ _), some (.vec xs), some (.cfg c) =>
    let rec outs (s : St) (i : Nat) : List (List Dim × Nat) → St × List Nat
      | [] => (s, [])
      | (shape, dt) :: r => let (n, s) := s.addNode ⟨.kernel kh c i, xs, shape, dt⟩
        let (s, ns) := outs s (i + 1) r; (s, n :: ns)
    let (s, ns) := outs s 0 c.outs
    let (v, s) := setVec s slot ns
    okW s status0 [u64Write b off v]
  | _, _, _, _ => stuck

/-! ### Weights -/

def headerOf (s : St) (path : List Char) : Option Header :=
  (s.files.find? fun (p, _) => nameEq p path).map Prod.snd

def mapGet (s : St) (o m key : Arg) : R :=
  match slotOf o, (argNat m).bind s.obj?, cstrArg key with
  | some (b, off, slot), some (.amap (some file)), some k =>
    match (headerOf s file).bind fun h => h.find? fun (n, _, _) => nameEq n k with
    | some (_, shape, dt) =>
      let (n, s) := s.addNode ⟨.load file k, [], lits (shape.map Int.ofNat), dt⟩
      let (h, s) := s.setArr slot n
      okW s status0 [u64Write b off h]
    | none => stuck
  | _, _, _ => stuck

def loadSafetensors (s : St) (am sm path : Arg) : R :=
  match slotOf am, slotOf sm, cstrArg path with
  | some (ab, aoff, aslot), some (sb, soff, sslot), some p => match headerOf s p with
    | some _ =>
      let s := match s.obj? aslot with
        | some (.amap _) => s.setObj aslot (.amap (some p))
        | _ => s
      okW s status0 [u64Write ab aoff aslot, u64Write sb soff sslot]
    | none => stuck
  | _, _, _ => stuck

/-! ### Dispatch -/

/-- Every modeled symbol. -/
inductive Sym where
  | arrayNew | arrayNewData | arrayFree | arrayEval | arrayNdim | arrayShape | arrayDtype | arraySize | itemU32
  | gpuStream | cpuStream | streamFree | stringNew | stringData | stringFree | version | setErrorHandler
  | getDefaultDevice | deviceInfoNew | deviceInfoGet | deviceInfoGetString | deviceInfoGetSize | deviceInfoFree
  | deviceFree | setWiredLimit | synchronize | clearCache | eval | asyncEval
  | vecNew | vecNewData | vecFree | vecSize | vecGet | vecSetData
  | vstrNewData | vstrFree
  | closureNew | closureFuncPayload | closureFree | closureApply | compile
  | kernelNew | kernelFree | cfgNew | cfgFree | cfgOutput | cfgGrid | cfgGroup | cfgInit | cfgInt | cfgDtype | kernelApply
  | mapArrayNew | mapArrayFree | mapArrayGet | mapStringNew | mapStringFree | loadSafetensors
  | reshape | transpose | slice | sliceUpdate | sliceDynamic | concat | zeros | astype | arange | contiguous
  | unary | binary | rmsNorm | rope | sdpa | qmm | dequantize | take | conv1d | logsumexp

def symTable : List (List Char × Sym) :=
  [(chars!"mlx_array_new", .arrayNew), (chars!"mlx_array_new_data", .arrayNewData), (chars!"mlx_array_free", .arrayFree),
   (chars!"mlx_array_eval", .arrayEval), (chars!"mlx_array_ndim", .arrayNdim), (chars!"mlx_array_shape", .arrayShape),
   (chars!"mlx_array_dtype", .arrayDtype), (chars!"mlx_array_size", .arraySize), (chars!"mlx_array_item_uint32", .itemU32),
   (chars!"mlx_default_gpu_stream_new", .gpuStream), (chars!"mlx_default_cpu_stream_new", .cpuStream),
   (chars!"mlx_stream_free", .streamFree), (chars!"mlx_string_new", .stringNew), (chars!"mlx_string_data", .stringData),
   (chars!"mlx_string_free", .stringFree), (chars!"mlx_version", .version), (chars!"mlx_set_error_handler", .setErrorHandler),
   (chars!"mlx_get_default_device", .getDefaultDevice), (chars!"mlx_device_info_new", .deviceInfoNew),
   (chars!"mlx_device_info_get", .deviceInfoGet), (chars!"mlx_device_info_get_string", .deviceInfoGetString),
   (chars!"mlx_device_info_get_size", .deviceInfoGetSize), (chars!"mlx_device_info_free", .deviceInfoFree),
   (chars!"mlx_device_free", .deviceFree), (chars!"mlx_set_wired_limit", .setWiredLimit),
   (chars!"mlx_synchronize", .synchronize), (chars!"mlx_clear_cache", .clearCache), (chars!"mlx_eval", .eval),
   (chars!"mlx_async_eval", .asyncEval), (chars!"mlx_vector_array_new", .vecNew),
   (chars!"mlx_vector_array_new_data", .vecNewData), (chars!"mlx_vector_array_free", .vecFree),
   (chars!"mlx_vector_array_size", .vecSize), (chars!"mlx_vector_array_get", .vecGet),
   (chars!"mlx_vector_array_set_data", .vecSetData), (chars!"mlx_vector_string_new_data", .vstrNewData),
   (chars!"mlx_vector_string_free", .vstrFree), (chars!"mlx_closure_new", .closureNew),
   (chars!"mlx_closure_new_func_payload", .closureFuncPayload), (chars!"mlx_closure_free", .closureFree),
   (chars!"mlx_closure_apply", .closureApply), (chars!"mlx_compile", .compile),
   (chars!"mlx_fast_metal_kernel_new", .kernelNew), (chars!"mlx_fast_metal_kernel_free", .kernelFree),
   (chars!"mlx_fast_metal_kernel_config_new", .cfgNew), (chars!"mlx_fast_metal_kernel_config_free", .cfgFree),
   (chars!"mlx_fast_metal_kernel_config_add_output_arg", .cfgOutput),
   (chars!"mlx_fast_metal_kernel_config_set_grid", .cfgGrid),
   (chars!"mlx_fast_metal_kernel_config_set_thread_group", .cfgGroup),
   (chars!"mlx_fast_metal_kernel_config_set_init_value", .cfgInit),
   (chars!"mlx_fast_metal_kernel_config_add_template_arg_int", .cfgInt),
   (chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype", .cfgDtype),
   (chars!"mlx_fast_metal_kernel_apply", .kernelApply), (chars!"mlx_map_string_to_array_new", .mapArrayNew),
   (chars!"mlx_map_string_to_array_free", .mapArrayFree), (chars!"mlx_map_string_to_array_get", .mapArrayGet),
   (chars!"mlx_map_string_to_string_new", .mapStringNew), (chars!"mlx_map_string_to_string_free", .mapStringFree),
   (chars!"mlx_load_safetensors", .loadSafetensors), (chars!"mlx_reshape", .reshape),
   (chars!"mlx_transpose_axes", .transpose), (chars!"mlx_slice", .slice), (chars!"mlx_slice_update", .sliceUpdate),
   (chars!"mlx_slice_dynamic", .sliceDynamic), (chars!"mlx_concatenate_axis", .concat), (chars!"mlx_zeros", .zeros),
   (chars!"mlx_astype", .astype), (chars!"mlx_arange", .arange), (chars!"mlx_contiguous", .contiguous),
   (chars!"mlx_fast_rms_norm", .rmsNorm), (chars!"mlx_fast_rope", .rope),
   (chars!"mlx_fast_scaled_dot_product_attention", .sdpa), (chars!"mlx_quantized_matmul", .qmm),
   (chars!"mlx_dequantize", .dequantize), (chars!"mlx_take_axis", .take), (chars!"mlx_conv1d", .conv1d),
   (chars!"mlx_logsumexp_axis", .logsumexp)] ++
  unaryOps.map (·, .unary) ++ binaryOps.map (·, .binary)

/-- A binary search tree over the symbols' packed codes. -/
inductive Bst where
  | leaf
  | node (code : Nat) (sym : Sym) (l r : Bst)

def insertBst (c : Nat) (x : Sym) : Bst → Bst
  | .leaf => .node c x .leaf .leaf
  | .node k y l r => bif Nat.blt c k then .node k y (insertBst c x l) r
    else bif Nat.blt k c then .node k y l (insertBst c x r) else .node k y l r

/-- Balanced build from code-sorted entries (halves, by fuel). -/
def ofSorted : Nat → List (Nat × Sym) → Bst
  | 0, _ => .leaf
  | _ + 1, [] => .leaf
  | f + 1, xs =>
    let m := len xs / 2
    match nth? xs m with
    | some (c, x) => .node c x (ofSorted f (xs.take m)) (ofSorted f (xs.drop (m + 1)))
    | none => .leaf

def flatBst : Bst → List (Nat × Sym)
  | .leaf => []
  | .node c x l r => flatBst l ++ (c, x) :: flatBst r

def symBst : Bst :=
  ofSorted 16 (flatBst (symTable.foldl (fun t (n, x) => insertBst (pack n) x t) .leaf))

def lookupBst (c : Nat) : Bst → Option Sym
  | .leaf => none
  | .node k x l r => bif Nat.blt c k then lookupBst c l else bif Nat.blt k c then lookupBst c r else some x

def symOf (name : Name) : Option Sym := lookupBst (pack name) symBst

/-- Shape cells of an array as `int32` bytes (`mlx_array_shape`'s memory). -/
def shapeBytes (shape : List Dim) : List Byte := cellBytes .i32 (shape.map fun d => .num d.num)

def call (s : St) (name : Name) (args : List Arg) : R :=
  match symOf name with
  | none => stuck
  | some x => match x, args with
  -- arrays
  | .arrayNew, [] => ok s (.big 0)
  | .arrayNewData, [.jsPtr _ _ bytes, sh, nd, dt] => match dimsArg sh nd, argNat dt with
    | some shape, some dt =>
      -- the array's bytes (MLX copies size × itemsize bytes from the pointer)
      let bytes := match natsOfDims shape with
        | some ds => bytes.take (ds.foldr (· * ·) 1 * dtSize dt)
        | none => bytes
      let (n, s) := s.addNode ⟨.data bytes, [], shape, dt⟩
      let (h, s) := s.setArr 0 n
      ok s (.big h)
    | _, _ => stuck
  | .arrayFree, [h] => match argNat h with
    | some h => ok (s.freeArr h) status0
    | none => stuck
  | .arrayEval, [h] => match (argNat h).bind s.node? with
    | some _ => ok s status0
    | none => stuck
  | .arrayNdim, [h] => match (argNat h).bind s.node? with
    | some n => ok s (.big (len n.shape))
    | none => stuck
  | .arrayShape, [h] => match argNat h with
    | some h => match s.node? h with
      | some _ => ok s (.ptr (4 * h) 0)
      | none => stuck
    | none => stuck
  | .arrayDtype, [h] => match (argNat h).bind s.node? with
    | some n => ok s (.num (.lit (F64.ofNat n.dtype)))
    | none => stuck
  | .arraySize, [h] => match (argNat h).bind s.node? with
    | some n => match natsOfDims n.shape with
      | some ds => ok s (.big (ds.foldr (· * ·) 1 : Nat))
      | none => stuck
    | none => stuck
  | .itemU32, [.jsPtr b off _, h] => match (argNat h).bind s.nodeId?, (argNat h).bind s.node? with
    | some k, some n => bif Nat.beq n.dtype dtUint32 then
        match s.items.get k, s.tokens with
        | some t, _ => okW s status0 [(b, off, cellParts .u32 (.num t) 4 0)]
        | none, t :: ts => okW { s with tokens := ts, items := s.items.set k t } status0 [(b, off, cellParts .u32 (.num t) 4 0)]
        | none, [] => stuck
      else stuck
    | _, _ => stuck
  -- runtime objects
  | .gpuStream, [] => let (h, s) := s.newObj .stream; ok s (.big h)
  | .cpuStream, [] => let (h, s) := s.newObj .stream; ok s (.big h)
  | .streamFree, [_] => ok s status0
  | .stringNew, [] => let (h, s) := s.newObj (.str []); ok s (.big h)
  | .version, [o] => match slotOf o with
    | some (b, off, slot) => match s.obj? slot with
      | some (.str _) => okW (s.setObj slot (.str chars!"0.32.2")) status0 [u64Write b off slot]
      | _ => stuck
    | none => stuck
  | .stringData, [h] => match (argNat h).bind s.obj? with
    | some (.str cs) => ok s (.cstr cs)
    | _ => stuck
  | .stringFree, [_] => ok s status0
  | .setErrorHandler, [f, _, _] => ok { s with errh := some f } .void
  | .getDefaultDevice, [o] => match slotOf o with
    | some (b, off, _) => let (h, s) := s.newObj .device; okW s status0 [u64Write b off h]
    | none => stuck
  | .deviceInfoNew, [] => let (h, s) := s.newObj .dinfo; ok s (.big h)
  | .deviceInfoGet, [o, d] => match slotOf o, (argNat d).bind s.obj? with
    | some (b, off, slot), some .device => okW s status0 [u64Write b off slot]
    | _, _ => stuck
  | .deviceInfoGetString, [.jsPtr b off _, i, k] => match (argNat i).bind s.obj?, cstrArg k with
    | some .dinfo, some key => bif nameEq key chars!"architecture" then
        let (h, s) := s.newObj (.str s.arch)
        okW s status0 [u64Write b off (ptrInt (.ext (4 * h + 1)) 0).toNat]
      else stuck
    | _, _ => stuck
  | .deviceInfoGetSize, [.jsPtr b off _, i, k] => match (argNat i).bind s.obj?, cstrArg k with
    | some .dinfo, some key => match s.deviceSizes.find? fun (n, _) => nameEq n key with
      | some (_, v) => okW s status0 [u64Write b off v]
      | none => stuck
    | _, _ => stuck
  | .deviceInfoFree, [_] => ok s status0
  | .deviceFree, [_] => ok s status0
  | .setWiredLimit, [.jsPtr b off _, l] => match argNat l with
    | some l => okW { s with wired := l } status0 [u64Write b off s.wired]
    | none => stuck
  | .synchronize, [_] => ok s status0
  | .clearCache, [] => ok s status0
  | .eval, [v] => match (argNat v).bind s.obj? with
    | some (.vec _) => ok s status0
    | _ => stuck
  | .asyncEval, [v] => match (argNat v).bind s.obj? with
    | some (.vec _) => ok s status0
    | _ => stuck
  -- vectors
  | .vecNew, [] => let (h, s) := s.newObj (.vec []); ok s (.big h)
  | .vecNewData, [p, n] => match (handlesArg p n).bind (nodesOf s) with
    | some ns => let (h, s) := s.newObj (.vec ns); ok s (.big h)
    | none => stuck
  | .vecFree, [_] => ok s status0
  | .vecSize, [v] => match (argNat v).bind s.obj? with
    | some (.vec ns) => ok s (.big (len ns))
    | _ => stuck
  | .vecGet, [o, v, i] => match slotOf o, (argNat v).bind s.obj?, argNat i with
    | some (b, off, slot), some (.vec ns), some i => match nth? ns i with
      | some n => let (h, s) := s.setArr slot n; okW s status0 [u64Write b off h]
      | none => stuck
    | _, _, _ => stuck
  | .vecSetData, [.extPtr r 0, p, n] => match (handlesArg p n).bind (nodesOf s) with
    | some ns => bif Nat.beq (r % 4) 2 then
        match s.pending with
        | q :: rest => bif Nat.beq q.id (r / 4) then ok { s with pending := { q with res := some ns } :: rest } status0
          else stuck
        | [] => stuck
      else stuck
    | none => stuck
  | .vstrNewData, [_, n] => match argNat n with
    | some n => let (h, s) := s.newObj (.vstr n); ok s (.big h)
    | none => stuck
  | .vstrFree, [_] => ok s status0
  -- closures
  | .closureNew, [] => let (h, s) := s.newObj (.clo .empty); ok s (.big h)
  | .closureFuncPayload, [.extPtr cb 0, payload, _] => let (h, s) := s.newObj (.clo (.fn cb payload)); ok s (.big h)
  | .closureFree, [_] => ok s status0
  | .compile, [o, f, sl] => match slotOf o, (argNat f).bind s.obj?, argBool sl with
    | some (b, off, slot), some (.clo (.fn cb payload)), some shapeless =>
      let c := Obj.clo (.compiled cb payload shapeless [])
      let (h, s) := match s.obj? slot with
        | some (.clo _) => (slot, s.setObj slot c)
        | _ => s.newObj c
      okW s status0 [u64Write b off h]
    | _, _, _ => stuck
  | .closureApply, [o, c, v] => closureApply s o c v
  -- kernels
  | .kernelNew, [nm, ins, outs, src, hdr, _, _] =>
    match cstrArg nm, (argNat ins).bind s.obj?, (argNat outs).bind s.obj?, cstrArg src, cstrArg hdr with
    | some n, some (.vstr a), some (.vstr b), some sc, some hd => let (h, s) := s.newObj (.kernel n sc hd a b); ok s (.big h)
    | _, _, _, _, _ => stuck
  | .kernelFree, [_] => ok s .void
  | .cfgNew, [] => let (h, s) := s.newObj (.cfg .empty); ok s (.big h)
  | .cfgFree, [_] => ok s .void
  | .cfgOutput, [c, sh, n, dt] => match dimsArg sh n, argNat dt with
    | some shape, some dt => cfgUpdate s c fun k => some { k with outs := k.outs ++ [(shape, dt)] }
    | _, _ => stuck
  | .cfgGrid, [c, .num x, .num y, .num z] => cfgUpdate s c fun k => some { k with grid := [x, y, z] }
  | .cfgGroup, [c, .num x, .num y, .num z] => cfgUpdate s c fun k => some { k with group := [x, y, z] }
  | .cfgInit, [c, .num x] => cfgUpdate s c fun k => some { k with init := some x }
  | .cfgInt, [c, nm, .num v] => match cstrArg nm with
    | some n => cfgUpdate s c fun k => some { k with ints := k.ints ++ [(n, v)] }
    | none => stuck
  | .cfgDtype, [c, nm, dt] => match cstrArg nm, argNat dt with
    | some n, some d => cfgUpdate s c fun k => some { k with dtypes := k.dtypes ++ [(n, d)] }
    | _, _ => stuck
  | .kernelApply, [o, k, v, c, _] => kernelApply s o k v c
  -- weights
  | .mapArrayNew, [] => let (h, s) := s.newObj (.amap none); ok s (.big h)
  | .mapArrayFree, [_] => ok s status0
  | .mapStringNew, [] => let (h, s) := s.newObj .smap; ok s (.big h)
  | .mapStringFree, [_] => ok s status0
  | .mapArrayGet, [o, m, k] => mapGet s o m k
  | .loadSafetensors, [am, sm, p, _] => loadSafetensors s am sm p
  -- operations
  | .reshape, [o, a, sh, n, _] => match arrIns s [a], dimsArg sh n with
    | some ins, some shape => opOut s o (.reshape shape) ins
    | _, _ => stuck
  | .transpose, [o, a, ax, n, _] => match arrIns s [a], (dimsArg ax n).bind natsOfDims with
    | some ins, some axes => opOut s o (.transpose axes) ins
    | _, _ => stuck
  | .slice, [o, a, st, n1, sp, n2, sr, n3, _] => match arrIns s [a], dimsArg st n1, dimsArg sp n2, dimsArg sr n3 with
    | some ins, some st, some sp, some sr => opOut s o (.slice st sp sr) ins
    | _, _, _, _ => stuck
  | .sliceUpdate, [o, a, u, st, n1, sp, n2, sr, n3, _] =>
    match arrIns s [a, u], dimsArg st n1, dimsArg sp n2, dimsArg sr n3 with
    | some ins, some st, some sp, some sr => opOut s o (.sliceUpdate st sp sr) ins
    | _, _, _, _ => stuck
  | .sliceDynamic, [o, a, st, ax, n1, sz, n2, _] =>
    match arrIns s [a, st], (dimsArg ax n1).bind natsOfDims, dimsArg sz n2 with
    | some ins, some axes, some sizes => opOut s o (.sliceDynamic axes sizes) ins
    | _, _, _ => stuck
  | .concat, [o, v, ax, _] => match (argNat v).bind s.obj?, argInt ax with
    | some (.vec ns), some ax => match ns with
      | n :: _ => match s.nodes.get n with
        | some nd => match axisOf ax (len nd.shape) with
          | some a => opOut s o (.concat a) ns
          | none => stuck
        | none => stuck
      | [] => stuck
    | _, _ => stuck
  | .zeros, [o, sh, n, dt, _] => match dimsArg sh n, argNat dt with
    | some shape, some dt => leafOut s o .zeros shape dt
    | _, _ => stuck
  | .astype, [o, a, dt, _] => match arrIns s [a], argNat dt with
    | some ins, some dt => opOut s o (.astype dt) ins
    | _, _ => stuck
  | .arange, [o, .num a, .num b, .num c, dt, _] => match argNat dt, a, b, c with
    | some dt, .lit x, .lit y, .lit z => match F64.toInt? x, F64.toInt? y, F64.toInt? z with
      | some x, some y, some z => bif decide (0 < z) then
          leafOut s o (.arange (.lit (F64.ofInt x)) (.lit (F64.ofInt y)) (.lit (F64.ofInt z))) [.lit (max 0 ((y - x + z - 1) / z))] dt
        else stuck
      | _, _, _ => stuck
    | _, _, _, _ => stuck
  | .contiguous, [o, a, _, _] => match arrIns s [a] with
    | some ins => opOut s o .contiguous ins
    | none => stuck
  | .unary, [o, a, _] => match arrIns s [a] with
    | some ins => opOut s o (.unary (strip name)) ins
    | none => stuck
  | .binary, [o, a, b, _] => match arrIns s [a, b] with
    | some ins => opOut s o (.binary (strip name)) ins
    | none => stuck
  | .rmsNorm, [o, x, w, .num eps, _] => match argNat w with
    | some 0 => match arrIns s [x] with
      | some ins => opOut s o (.rmsNorm eps) ins
      | none => stuck
    | _ => match arrIns s [x, w] with
      | some ins => opOut s o (.rmsNorm eps) ins
      | none => stuck
  | .rope, [o, x, .num dims, .bool tr, base, .num scale, .num off, freqs, _] =>
    match arrIns s [x], argNat freqs, F64.toInt? (match dims with | .lit f => f | .ref _ => .nan) with
    | some ins, some 0, some d => bif decide (0 < d) then opOut s o (.rope d.toNat tr base scale off) ins else stuck
    | _, _, _ => stuck
  | .sdpa, [o, q, k, v, .num scale, mask, mk, sk, _, _] =>
    match arrIns s [q, k, v], cstrArg mask, argNat mk, argNat sk with
    | some ins, some m, some 0, some 0 => opOut s o (.sdpa scale m) ins
    | _, _, _, _ => stuck
  | .qmm, [o, x, w, sc, bi, .bool tr, g, b, mode, _] =>
    match arrIns s [x, w, sc, bi], optIntArg g, optIntArg b, cstrArg mode with
    | some ins, some g, some b, some m => opOut s o (.qmm tr (g.getD 64) (b.getD 4) m) ins
    | _, _, _, _ => stuck
  | .dequantize, [o, w, sc, bi, g, b, mode, gs, dt, _] =>
    match arrIns s [w, sc, bi], optIntArg g, optIntArg b, cstrArg mode, argNat gs, optIntArg dt with
    | some ins, some g, some b, some m, some 0, some d => opOut s o (.dequantize (g.getD 64) (b.getD 4) m d) ins
    | _, _, _, _, _, _ => stuck
  | .take, [o, a, i, ax, _] => match arrIns s [a, i], argInt ax, (argNat a).bind s.node? with
    | some ins, some ax, some nd => match axisOf ax (len nd.shape) with
      | some ax => opOut s o (.take ax) ins
      | none => stuck
    | _, _, _ => stuck
  | .conv1d, [o, x, w, st, pd, dl, gr, _] =>
    match arrIns s [x, w], argNat st, argNat pd, argNat dl, argNat gr with
    | some ins, some st, some pd, some dl, some gr => opOut s o (.conv1d st pd dl gr) ins
    | _, _, _, _, _ => stuck
  | .logsumexp, [o, a, ax, .bool keep, _] => match arrIns s [a], argInt ax, (argNat a).bind s.node? with
    | some ins, some ax, some nd => match axisOf ax (len nd.shape) with
      | some ax => opOut s o (.logsumexp ax keep) ins
      | none => stuck
    | _, _, _ => stuck
  | _, _ => stuck

/-- Native memory: array shapes (region `4h`) and strings (`4h + 1`). -/
def read (s : St) (r off n : Nat) : Option (List Byte) :=
  match r % 4 with
  | 0 => (s.node? (r / 4)).map fun nd => ((shapeBytes nd.shape).drop off).take n
  | 1 => match s.obj? (r / 4) with
    | some (.str cs) => some ((((cs.map fun (c : Char) => (Byte.lit c.toNat : Byte)) ++ [Byte.lit 0]).drop off).take n)
    | _ => none
  | _ => none

def back (s : St) (a : Arg) : R := traceBack s a

def ffi : Ffi := ⟨St, call, read, fun _ => 4096, back⟩

end Host.Mlx.Ffi
