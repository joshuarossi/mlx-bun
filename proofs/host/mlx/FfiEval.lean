import host.mlx.Ffi
import host.mlx.GlueM1Max
namespace Host.Mlx.FfiEval
open Inference.Contracts.Mlx
open Host.Mlx.Ffi (Dim Prim Node Cfg)

/-! # Values of the FFI model's graph

`Host.Mlx.Ffi` keeps the graph of nodes the TypeScript built (primitive,
argument nodes, shape and dtype); `Host.Mlx.Ops`/`Kernel` give the value
semantics of the MLX operations on the route. This module evaluates the
graph with that semantics and relates it to the decode step's value trace.

* A node is first *resolved*: its numbers (dimensions, kernel
  configurations, the RoPE offset) are read through a number valuation
  (the run's concrete server table, `Host.Ts.CSrv.val`), f32 scalars become
  their binary32 words. `RPrim δ κ` is generic in the dimension type `δ`
  (`Int` here; an expression type for a symbolic comparison) and carries
  two leaves that only expected graphs use: `input κ` and `computeG`.
* `evalR` evaluates a resolved graph (`Nat → Option (RNode δ κ)`): each
  primitive applies the `Ops`/`Kernel` operation to its evaluated
  arguments; loads read the checkpoint environment; data nodes decode
  their bytes; kernel nodes dispatch on the kernel name to
  `KernelContract.apply` with the recorded configuration. The traced
  body of the compiled `compute_g` closure (an `exp` root over
  multiply/negative/exp/astype/logaddexp/add and the bf16 zero) is
  evaluated as the compiled closure (`Ops.Closure.computeG`); its
  intermediate nodes have no eager semantics on the route.
* `Matches G E cert`: a decidable check that the expected graph `E` is
  carried by `G` at node ids `cert`. `matches_eval`: then every expected
  node and its carrier evaluate alike.
* `stepGraph` builds `E` for one decode step from the layout of the loaded
  weights and caches; `stepGraph_eval`: its token and cache nodes
  evaluate to the values `GlueStep.stepTrace` returns. -/

/-! ## Resolved nodes -/

structure RCfg (δ : Type) where
  outs : List (List δ × Nat)
  grid : List δ
  group : List δ
  ints : List (List Char × δ)
  dtypes : List (List Char × Nat)
  init : Option δ
deriving DecidableEq

inductive RPrim (δ κ : Type) where
  /-- An expected-graph leaf: step input `k`. -/
  | input (k : κ)
  /-- An expected-graph node: the compiled compute_g closure on three inputs. -/
  | computeG
  | data (bytes : List Nat) (shape : List δ) (dtype : Nat)
  | load (file key : List Char)
  | zeros (shape : List δ) (dtype : Nat)
  /-- Trace inputs and `arange`: no value on the route. -/
  | unsupported
  | reshape (shape : List δ)
  | transpose (axes : List Nat)
  | slice (start stop strides : List δ)
  | sliceUpdate (start stop strides : List δ)
  | sliceDynamic (axes : List Nat) (sizes : List δ)
  | concat (axis : Nat)
  | unary (op : List Char)
  | binary (op : List Char)
  | astype (dtype : Nat)
  | contiguous
  /-- `eps` as its binary32 word (bun:ffi passes the f32 argument). -/
  | rmsNorm (eps : Nat)
  /-- `base` the packed optional-float word, `scale` a binary32 word. -/
  | rope (dims : Nat) (traditional : Bool) (base scale : Nat) (offset : δ)
  | sdpa (scale : Nat) (mask : List Char)
  | qmm (transpose : Bool) (group bits : Nat) (mode : List Char)
  | dequantize (group bits : Nat) (mode : List Char) (dtype : Option Nat)
  | take (axis : Nat)
  | conv1d (stride padding dilation groups : Nat)
  | logsumexp (axis : Nat) (keep : Bool)
  | kernel (name : List Char) (cfg : RCfg δ) (out : Nat)
deriving DecidableEq

structure RNode (δ κ : Type) where
  prim : RPrim δ κ
  ins : List Nat
deriving DecidableEq

/-- How a node's numbers are read: integers into `δ`, f32 scalars as words. -/
structure Nums (δ : Type) where
  dim : Host.Ts.NumV → Option δ
  word : Host.Ts.NumV → Option Nat
  lit : Int → δ

def Nums.d {δ : Type} (N : Nums δ) : Dim → Option δ
  | .lit i => some (N.lit i)
  | .sym x => N.dim x

/-- The concrete reading: a number valuation (the final concrete server's `val`). -/
def concrete (ν : Host.Ts.NumV → Option Host.Ts.F64) : Nums Int :=
  ⟨fun x => (ν x).bind Host.Ts.F64.toInt?, fun x => (ν x).map fun f => Host.Ts.F64.f32Bits (Host.Ts.F64.toF32 f), id⟩

def litBytes : List Host.Ts.Byte → Option (List Nat)
  | [] => some []
  | .lit b :: bs => (litBytes bs).map (b :: ·)
  | _ => none

def resolveCfg {δ : Type} (N : Nums δ) (c : Cfg) : Option (RCfg δ) := do
  let outs ← c.outs.mapM fun (s, d) => (s.mapM N.d).map (·, d)
  let grid ← c.grid.mapM N.dim
  let group ← c.group.mapM N.dim
  let ints ← c.ints.mapM fun (n, v) => (N.dim v).map (n, ·)
  let init ← match c.init with
    | none => some none
    | some v => (N.dim v).map some
  pure ⟨outs, grid, group, ints, c.dtypes, init⟩

def resolvePrim {δ κ : Type} (N : Nums δ) (shape : List Dim) (dtype : Nat) : Prim → Option (RPrim δ κ)
  | .data bytes => do pure (.data (← litBytes bytes) (← shape.mapM N.d) dtype)
  | .load f k => some (.load f k)
  | .tracer _ => some .unsupported
  | .zeros => (shape.mapM N.d).map (.zeros · dtype)
  | .arange _ _ _ => some .unsupported
  | .reshape s => (s.mapM N.d).map .reshape
  | .transpose ax => some (.transpose ax)
  | .slice a b c => do pure (.slice (← a.mapM N.d) (← b.mapM N.d) (← c.mapM N.d))
  | .sliceUpdate a b c => do pure (.sliceUpdate (← a.mapM N.d) (← b.mapM N.d) (← c.mapM N.d))
  | .sliceDynamic ax sz => (sz.mapM N.d).map (.sliceDynamic ax)
  | .concat a => some (.concat a)
  | .unary op => some (.unary op)
  | .binary op => some (.binary op)
  | .astype d => some (.astype d)
  | .contiguous => some .contiguous
  | .rmsNorm eps => (N.word eps).map .rmsNorm
  | .rope d t base scale off => do pure (.rope d t (← Ffi.argNat base) (← N.word scale) (← N.dim off))
  | .sdpa scale m => (N.word scale).map (.sdpa · m)
  | .qmm t g b m => some (.qmm t g b m)
  | .dequantize g b m d => some (.dequantize g b m d)
  | .take a => some (.take a)
  | .conv1d a b c d => some (.conv1d a b c d)
  | .logsumexp a k => some (.logsumexp a k)
  | .kernel name c i => (resolveCfg N c).map (.kernel name · i)

def resolveNode {δ κ : Type} (N : Nums δ) (nd : Node) : Option (RNode δ κ) :=
  (resolvePrim N nd.shape nd.dtype nd.prim).map (⟨·, nd.ins⟩)

/-- The FFI model's graph, resolved. -/
def ffiGraph {δ κ : Type} (N : Nums δ) (s : Ffi.St) (i : Nat) : Option (RNode δ κ) :=
  (s.nodes.get i).bind (resolveNode N)

/-- An expected graph as a list (node `i` is entry `i`). -/
def listGraph {δ κ : Type} (E : List (RNode δ κ)) (i : Nat) : Option (RNode δ κ) := E[i]?

/-! ## compute_g's traced body

ComputeGHostSyntax.body as the FFI records it (gated.ts computeG):
`exp(multiply(negative(exp(astype(aLog, f32))), logaddexp(add(a, dt), zero)))`
with `zero` the bf16 scalar `MlxArray.fromBytesCopy([0,0], [], bf16)`. Each
step reads a node of smaller id. -/

def one? : List Nat → Option Nat
  | [x] => some x
  | _ => none

def two? : List Nat → Option (Nat × Nat)
  | [x, y] => some (x, y)
  | _ => none

/-- The pattern below root `r`, reading nodes through `b`. -/
def cgAux {δ κ : Type} [DecidableEq δ] [DecidableEq κ] (r : RNode δ κ) (b : Nat → Option (RNode δ κ)) :
    Option (List Nat) := do
  if r.prim = .unary chars!"exp" then pure () else none
  let m ← one? r.ins
  let mn ← b m
  if mn.prim = .binary chars!"multiply" then pure () else none
  let (ng, sp) ← two? mn.ins
  let nn ← b ng
  if nn.prim = .unary chars!"negative" then pure () else none
  let e1 ← one? nn.ins
  let en ← b e1
  if en.prim = .unary chars!"exp" then pure () else none
  let c ← one? en.ins
  let cn ← b c
  if cn.prim = .astype Ffi.dtF32 then pure () else none
  let x0 ← one? cn.ins
  let sn ← b sp
  if sn.prim = .binary chars!"logaddexp" then pure () else none
  let (sm, z) ← two? sn.ins
  let smn ← b sm
  if smn.prim = .binary chars!"add" then pure () else none
  let (x1, x2) ← two? smn.ins
  let zn ← b z
  if zn = ⟨.data [0, 0] [] Ffi.dtBf16, []⟩ then pure [x0, x1, x2] else none

/-- compute_g's leaves (aLog, a, dt) if node `i` is the root of its traced body;
the pattern reads only nodes of smaller id. -/
def cgLeaves {δ κ : Type} [DecidableEq δ] [DecidableEq κ] (g : Nat → Option (RNode δ κ)) (i : Nat) :
    Option (List Nat) :=
  (g i).bind fun r => cgAux r (fun j => if j < i then g j else none)

theorem cgAux_none {δ κ : Type} [DecidableEq δ] [DecidableEq κ] (r : RNode δ κ) (b : Nat → Option (RNode δ κ))
    (h : r.prim ≠ .unary chars!"exp") : cgAux r b = none := by
  simp [cgAux, h]

theorem cgLeaves_none {δ κ : Type} [DecidableEq δ] [DecidableEq κ] (g : Nat → Option (RNode δ κ)) (i : Nat)
    (r : RNode δ κ) (hg : g i = some r) (h : r.prim ≠ .unary chars!"exp") : cgLeaves g i = none := by
  simp [cgLeaves, hg, cgAux_none r _ h]

theorem cgLeaves_congr {δ κ : Type} [DecidableEq δ] [DecidableEq κ] (g g' : Nat → Option (RNode δ κ)) (i : Nat)
    (h : ∀ j ≤ i, g j = g' j) : cgLeaves g i = cgLeaves g' i := by
  have hb : (fun j => if j < i then g j else none) = (fun j => if j < i then g' j else none) := by
    funext j; split <;> [rw [h j (by omega)]; rfl]
  simp only [cgLeaves, hb, h i (Nat.le_refl i)]

/-! ## Value semantics of a primitive -/

def natShape : List Int → Option (List Nat)
  | [] => some []
  | d :: ds => if 0 ≤ d then (natShape ds).map (d.toNat :: ·) else none

def nat? (d : Int) : Option Nat := if 0 ≤ d then some d.toNat else none

/-- Little-endian element `i` of host bytes; an array of `size` elements
repeats (elements past the size are not observed; scalars are constant). -/
def leWord (bytes : List Nat) (width i : Nat) : Nat :=
  (List.range width).foldr (fun k acc => bytes.getD (i * width + k) 0 * 256 ^ k + acc) 0

def dataValue (bytes : List Nat) (shape : List Int) (dtype : Nat) : Option Value := do
  let dt ← Dtype.ofCode dtype
  let sh ← natShape shape
  pure ⟨dt, sh, fun i => leWord bytes dt.bytes (i % extent sh)⟩

/-- `mlx_reshape` dims: one inferred `-1` (GlueLayout.reshapeInfer) or all known. -/
def reshapeDims (v : Value) (ds : List Int) : Option Value :=
  if ds.count (-1) = 1 then GlueLayout.reshapeInfer v ds else (natShape ds).bind (reshape v)

def unitStrides (ds : List Int) : Bool := ds.all (· = 1)

def triple? : List Int → Option (Nat × Nat × Nat)
  | [a, b, c] => do pure ((← nat? a), (← nat? b), (← nat? c))
  | _ => none

def outOf (p : List Int × Nat) : Option (List Nat × Dtype) := do pure ((← natShape p.1), (← Dtype.ofCode p.2))
def dtOf (p : List Char × Nat) : Option (String × Dtype) := (Dtype.ofCode p.2).map (String.ofList p.1, ·)
def intOf (p : List Char × Int) : Option (String × Nat) := (nat? p.2).map (String.ofList p.1, ·)
def initOf : Option Int → Option (Option Nat)
  | none => some none
  | some v => (nat? v).map some

def toConfig (c : RCfg Int) : Option Config := do
  let outs ← c.outs.mapM outOf
  let grid ← triple? c.grid
  let group ← triple? c.group
  let dts ← c.dtypes.mapM dtOf
  let ints ← c.ints.mapM intOf
  let init ← initOf c.init
  pure ⟨outs, grid, group, dts, ints, init⟩

/-- The route's kernels by the `name` our TypeScript passes to `mlx_fast_metal_kernel_new`. -/
def kernelNames : List (List Char × Kernel) :=
  [(chars!"mlx_bun_affine_row", .affineRow), (chars!"mlx_bun_silu_rms_heads", .siluRmsHeads),
   (chars!"gated_delta_step", .gatedDeltaStep), (chars!"mlx_bun_gated_rms_norm", .gatedRmsNorm),
   (chars!"mlx_bun_residual_rms_norm", .residualRmsNorm),
   (chars!"mlx_bun_trellis_gateup_codebook_row", .gateUp),
   (chars!"mlx_bun_trellis_down_codebook_row", .downPartial),
   (chars!"mlx_bun_trellis_down_codebook_fold", .downFold),
   (chars!"normalized_argmax_partial", .argmaxPartial), (chars!"normalized_argmax_finish", .argmaxFinish)]

def kernelOf (name : List Char) : Option Kernel := (kernelNames.find? (·.1 = name)).map (·.2)

/-! ### Kernel identity

A kernel node carries the `name` given to `mlx_fast_metal_kernel_new`. The
FFI model drops the call's source and header arguments; the run's trace
keeps them (each event holds the NUL-terminated buffers). `KernelsBound S
trace`: every kernel created under a route name has the source and header
`S` assigns that kernel, the bodies whose parsed programs the
`KernelContract` fields' executions are about. -/

/-- A NUL-terminated buffer of any length. -/
def cstrAll : Host.Ts.Arg → Option (List Char)
  | .jsPtr _ _ bs => Ffi.cstrBytes (bs.length + 1) bs
  | _ => none

/-- Name, source and header of a `mlx_fast_metal_kernel_new` call. -/
def kernelNewArgs (ev : Host.Ts.Event) : Option (List Char × List Char × List Char) :=
  if ev.sym = chars!"mlx_fast_metal_kernel_new" then
    match ev.args with
    | [nm, _, _, src, hdr, _, _] => do pure ((← cstrAll nm), (← cstrAll src), (← cstrAll hdr))
    | _ => none
  else none

/-- The Metal source and header of each route kernel. -/
structure KernelSources where
  source : Kernel → List Char
  header : Kernel → List Char

def KernelsBound (S : KernelSources) (trace : List Host.Ts.Event) : Bool :=
  trace.all fun ev => match kernelNewArgs ev with
    | some (nm, src, hdr) => match kernelOf nm with
      | some k => decide (src = S.source k ∧ hdr = S.header k)
      | none => true
    | none => true

/-- What the evaluation reads outside the graph: checkpoint tensors by
(file, name), and the expected graph's step inputs. -/
structure Env (κ : Type) where
  weights : List Char → List Char → Option Value
  inputs : κ → Option Value

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} (env : Env κ)

def single : List Value → Option Value
  | [v] => some v
  | _ => none

/-- mlx_fast_rms_norm's kernel by axis width (normalization.cpp:57-80): the
looped kernel above 4096, the single-row kernel of the 256-wide head norm. -/
noncomputable def normPlatform (w : Value) : Option RmsNorm.Platform :=
  match w.shape with
  | [n] => if 4096 < n then some M.hiddenNorm else if n = 256 then some M.headNorm else none
  | _ => none

noncomputable def primEval : RPrim Int κ → List Value → Option Value
  | .input k, [] => env.inputs k
  | .computeG, xs => (closureApply M .computeG xs).bind single
  | .data bytes shape dt, [] => dataValue bytes shape dt
  | .load f k, [] => env.weights f k
  | .zeros shape dt, [] => do pure (zeros (← natShape shape) (← Dtype.ofCode dt))
  | .reshape s, [v] => reshapeDims v s
  | .transpose ax, [v] => transpose v ax
  | .slice st sp sr, [v] => if unitStrides sr then do slice v (← natShape st) (← natShape sp) else none
  | .sliceUpdate st sp sr, [v, u] =>
    if unitStrides sr then do sliceUpdateRange v u (← natShape st) (← natShape sp) else none
  | .sliceDynamic ax sz, [v, st] => do sliceDynamic v st ax (← natShape sz)
  | .concat axis, [a, b] => concatenate a b axis
  | .unary op, [v] => if op = chars!"sigmoid" then sigmoid M v else none
  | .binary op, [a, b] =>
    if op = chars!"multiply" then multiply a b else if op = chars!"add" then add a b else none
  | .contiguous, [v] => some v
  | .rmsNorm eps, [x, w] => do rmsNorm (← normPlatform M w) x w (f32 eps)
  | .rope d t base scale off, [x] => rope M x d t (GlueAttention.optionalFloat base) (f32 scale) off
  | .sdpa scale mask, [q, k, v] => if mask = [] then sdpa M q k v (f32 scale) else none
  | .qmm t g b mode, [x, w, s, bi] => quantizedMatmul M x w s bi t g b (String.ofList mode)
  | .dequantize g b mode dt, [w, s, bi] =>
    if g = 64 ∧ b = 4 ∧ mode = chars!"affine" ∧ dt = none then dequantizeRow M w s bi else none
  | .take axis, [a, i] => if axis = 0 then takeAxis0 a i else none
  | .conv1d s p d g, [x, w] => conv1d M x w s p d g
  | .logsumexp axis keep, [v] => if axis = 1 ∧ keep = true then logsumexp K.sampling v else none
  | .kernel name c out, xs => do
    let k ← kernelOf name
    let cfg ← toConfig c
    let ys ← K.apply k xs cfg
    ys[out]?
  | _, _ => none

variable [DecidableEq κ]

/-- The value of node `i`: compute_g's traced body as the compiled closure,
any other node by its primitive on its evaluated arguments (each of
smaller id). -/
noncomputable def evalR (g : Nat → Option (RNode Int κ)) (i : Nat) : Option Value :=
  match g i with
  | none => none
  | some nd =>
    match cgLeaves g i with
    | some leaves => do
      let xs ← leaves.mapM fun j => if _h : j < i then evalR g j else none
      (closureApply M .computeG xs).bind single
    | none => do
      let xs ← nd.ins.mapM fun j => if _h : j < i then evalR g j else none
      primEval M K env nd.prim xs
termination_by i
decreasing_by all_goals assumption

end

/-! ## Evaluation lemmas -/

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ] (env : Env κ)

theorem evalR_eq (g : Nat → Option (RNode Int κ)) (i : Nat) : evalR M K env g i =
    match g i with
    | none => none
    | some nd =>
      match cgLeaves g i with
      | some leaves => (leaves.mapM fun j => if _h : j < i then evalR M K env g j else none).bind
          fun xs => (closureApply M .computeG xs).bind single
      | none => (nd.ins.mapM fun j => if _h : j < i then evalR M K env g j else none).bind (primEval M K env nd.prim) := by
  rw [evalR]; rfl

theorem mapM_congr' {α β : Type} (l : List α) (f h : α → Option β) (e : ∀ x ∈ l, f x = h x) :
    l.mapM f = l.mapM h := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    simp only [List.mapM_cons, e a (List.mem_cons_self ..), ih fun x hx => e x (List.mem_cons_of_mem _ hx)]

def isExp (p : RPrim Int κ) : Bool := decide (p = .unary chars!"exp")
def isInput : RPrim Int κ → Bool
  | .input _ => true
  | _ => false

theorem not_exp {p : RPrim Int κ} (h : isExp p = false) : p ≠ .unary chars!"exp" := by
  simpa [isExp] using h

/-! ## Graph matching

`cert` lists, for each expected node, the FFI node carrying it. -/

def certAt (cert : List Nat) (j : Nat) : Nat := cert.getD j 0

def nodeOk (G : Nat → Option (RNode Int κ)) (cert : List Nat) (k : Nat) (e : RNode Int κ) : Bool :=
  e.ins.all (· < k) && e.ins.all (fun j => certAt cert j < certAt cert k) &&
  (if isInput e.prim then e.ins.isEmpty
   else if e.prim = .computeG then decide (cgLeaves G (certAt cert k) = some (e.ins.map (certAt cert)))
   else !isExp e.prim && decide (G (certAt cert k) = some ⟨e.prim, e.ins.map (certAt cert)⟩))

/-- `E` is carried by `G` at `cert`: every operation node of `E` is the FFI node
at its certificate over the certificates of its arguments, each argument of
smaller id on both sides; a compute_g node is the FFI's traced body over them. -/
def Matches (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (cert : List Nat) : Bool :=
  (List.range E.length).all fun k => match E[k]? with
    | some e => nodeOk G cert k e
    | none => false

/-- The FFI nodes carrying `E`'s inputs hold the inputs' values. -/
def InputsHeld (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (cert : List Nat) : Prop :=
  ∀ k e key, E[k]? = some e → e.prim = .input key → evalR M K env G (certAt cert k) = env.inputs key

theorem matches_eval (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ)) (cert : List Nat)
    (hm : Matches G E cert = true) (hin : InputsHeld M K env G E cert) :
    ∀ k, k < E.length → evalR M K env G (certAt cert k) = evalR M K env (listGraph E) k := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
  intro hk
  have hek : E[k]? = some E[k] := List.getElem?_eq_getElem hk
  generalize E[k] = e at hek
  have hok : nodeOk G cert k e = true := by
    have := List.all_eq_true.mp hm k (List.mem_range.mpr hk)
    simpa [hek] using this
  simp only [nodeOk, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨hlt, hcl⟩, hrest⟩ := hok
  have hE : listGraph E k = some e := hek
  -- arguments evaluate alike
  have hargs : (e.ins.mapM fun j => if _h : j < k then evalR M K env (listGraph E) j else none) =
      e.ins.mapM fun j => evalR M K env G (certAt cert j) := by
    apply mapM_congr'
    intro j hj
    rw [dif_pos (hlt j hj), ih j (hlt j hj) (by have := hlt j hj; omega)]
  have hargsG : ((e.ins.map (certAt cert)).mapM fun j => if _h : j < certAt cert k then evalR M K env G j else none) =
      e.ins.mapM fun j => evalR M K env G (certAt cert j) := by
    rw [List.mapM_map]
    apply mapM_congr'
    intro j hj
    simp only [Function.comp, dif_pos (hcl j hj)]
  by_cases hi : isInput e.prim = true
  · rw [if_pos hi] at hrest
    cases hp : e.prim with
    | input key =>
      have hnil : e.ins = [] := by simpa using hrest
      rw [hin k e key hek hp, evalR_eq, hE, cgLeaves_none _ _ e hE (by rw [hp]; simp)]
      simp [hnil, hp, primEval]
    | _ => rw [hp] at hi; simp [isInput] at hi
  · rw [if_neg hi] at hrest
    by_cases hc : e.prim = .computeG
    · rw [if_pos hc] at hrest
      simp only [decide_eq_true_eq] at hrest
      obtain ⟨r, hr, _⟩ := Option.bind_eq_some_iff.mp hrest
      rw [evalR_eq, hr, hrest]
      dsimp only
      rw [hargsG, evalR_eq, hE, cgLeaves_none _ _ e hE (by rw [hc]; simp)]
      dsimp only
      rw [hargs, hc]
      rfl
    · rw [if_neg hc] at hrest
      simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] at hrest
      obtain ⟨hx, hG⟩ := hrest
      rw [evalR_eq, hG, cgLeaves_none _ _ _ hG (not_exp hx)]
      dsimp only
      rw [hargsG, evalR_eq, hE, cgLeaves_none _ _ e hE (not_exp hx)]
      dsimp only
      rw [hargs]

/-! ## Prefix stability -/

theorem evalR_append (g t : List (RNode Int κ)) :
    ∀ i, i < g.length → evalR M K env (listGraph (g ++ t)) i = evalR M K env (listGraph g) i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro hi
  have hl : ∀ j ≤ i, listGraph (g ++ t) j = listGraph g j := fun j hj =>
    List.getElem?_append_left (by omega)
  have hf : (fun j => if _h : j < i then evalR M K env (listGraph (g ++ t)) j else none) =
      (fun j => if _h : j < i then evalR M K env (listGraph g) j else none) := by
    funext j
    by_cases h : j < i
    · rw [dif_pos h, dif_pos h, ih j h (by omega)]
    · rw [dif_neg h, dif_neg h]
  rw [evalR_eq, evalR_eq, hl i (Nat.le_refl i), cgLeaves_congr _ _ i hl, hf]

/-- Node `i` of `g` has value `v` in every extension of `g`. -/
def EvA (g : List (RNode Int κ)) (i : Nat) (v : Value) : Prop :=
  i < g.length ∧ evalR M K env (listGraph g) i = some v

theorem EvA.app {g : List (RNode Int κ)} {i : Nat} {v : Value} (h : EvA M K env g i v) (t : List (RNode Int κ)) :
    EvA M K env (g ++ t) i v :=
  ⟨by have := h.1; rw [List.length_append]; omega, by rw [evalR_append M K env g t i h.1]; exact h.2⟩

/-- The facts `Σ` hold in `g`. -/
def AllEv (g : List (RNode Int κ)) (fs : List (Nat × Value)) : Prop := ∀ p ∈ fs, EvA M K env g p.1 p.2

theorem emit_ev (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs)
    (p : RPrim Int κ) (ins : List Nat) (vs : List Value) (v : Value) (hp : isExp p = false)
    (hins : List.Forall₂ (fun j x => (j, x) ∈ fs) ins vs) (hv : primEval M K env p vs = some v) :
    AllEv M K env (g ++ [⟨p, ins⟩]) ((g.length, v) :: fs) := by
  have hE : listGraph (g ++ [⟨p, ins⟩]) g.length = some ⟨p, ins⟩ := by simp [listGraph]
  have hargs : ∀ (t : List (RNode Int κ)) (js : List Nat) (xs : List Value),
      List.Forall₂ (fun j x => (j, x) ∈ fs) js xs →
      (js.mapM fun j => if _h : j < g.length then evalR M K env (listGraph (g ++ t)) j else none) = some xs := by
    intro t js xs hjs
    induction hjs with
    | nil => rfl
    | @cons j x js xs hjx _ ih =>
      have hj := hfs _ hjx
      rw [List.mapM_cons, dif_pos hj.1, evalR_append M K env g _ j hj.1, hj.2, ih]
      rfl
  intro q hq
  rcases List.mem_cons.mp hq with rfl | hq
  · refine ⟨by simp, ?_⟩
    rw [evalR_eq, hE, cgLeaves_none _ _ _ hE (not_exp hp)]
    simp only
    rw [hargs _ ins vs hins]
    exact hv
  · exact (hfs q hq).app M K env _

theorem AllEv.cons {g : List (RNode Int κ)} {fs : List (Nat × Value)} (h : AllEv M K env g fs) (i : Nat) (v : Value)
    (hv : EvA M K env g i v) : AllEv M K env g ((i, v) :: fs) := by
  intro q hq
  rcases List.mem_cons.mp hq with rfl | hq
  · exact hv
  · exact h q hq

end

/-! ## Expected-graph builders -/

abbrev Build (δ κ α : Type) := StateM (List (RNode δ κ)) α

def emit {δ κ : Type} (p : RPrim δ κ) (ins : List Nat) : Build δ κ Nat :=
  fun g => (g.length, g ++ [⟨p, ins⟩])

def run {δ κ α : Type} (b : Build δ κ α) (g : List (RNode δ κ)) : α × List (RNode δ κ) := b g

/-- `Q` holds of the builder's result and final graph from `g`. -/
def Spec {δ κ α : Type} (b : Build δ κ α) (g : List (RNode δ κ)) (Q : α → List (RNode δ κ) → Prop) : Prop :=
  Q (run b g).1 (run b g).2

theorem spec_bind {δ κ α β : Type} {x : Build δ κ α} {f : α → Build δ κ β} {g : List (RNode δ κ)}
    {Q : β → List (RNode δ κ) → Prop} (h : Spec x g fun a g' => Spec (f a) g' Q) : Spec (x >>= f) g Q := h

theorem spec_pure {δ κ α : Type} {a : α} {g : List (RNode δ κ)} {Q : α → List (RNode δ κ) → Prop}
    (h : Q a g) : Spec (pure a) g Q := h

theorem spec_emit {δ κ : Type} {p : RPrim δ κ} {ins : List Nat} {g : List (RNode δ κ)}
    {Q : Nat → List (RNode δ κ) → Prop} (h : Q g.length (g ++ [⟨p, ins⟩])) : Spec (emit p ins) g Q := h

theorem spec_mono {δ κ α : Type} {b : Build δ κ α} {g : List (RNode δ κ)} {P Q : α → List (RNode δ κ) → Prop}
    (h : Spec b g P) (k : ∀ a g', P a g' → Q a g') : Spec b g Q := k _ _ h

/-! ## Step inputs and layout

The expected graph's leaves are the step's inputs: loaded weights (and the
host-built head scales), the caches carried from the previous step, and the
token ids. Its shape is fixed by the layout of the weights and caches. -/

inductive LinKey where
  | w | scales | biases
deriving DecidableEq

inductive MlpKey where
  | norm | gateCodes | gateScales | upCodes | upScales | downCodes | downScales
deriving DecidableEq

/-- A stage's inputs. Projections: Delta 0 qkv, 1 z, 2 a, 3 b, 4 out;
attention 0 q, 1 k, 2 v, 3 o. Caches: Delta 0 conv, 1 recurrent;
attention 0 keys, 1 values. -/
inductive SKey where
  | inputNorm | lin (j : Nat) (l : LinKey) | conv | aLog | dtBias | norm | qScale | kScale | qNorm | kNorm
  | mlp (m : MlpKey) | cache (c : Nat)
deriving DecidableEq

inductive InKey where
  | tokenIds | embedWords | embedScales | embedBiases | finalNorm | head (l : LinKey) | stage (p : Nat) (k : SKey)
deriving DecidableEq

open GlueLayers GlueStep

def linGet : LinKey → Linear → Option Value
  | .w, l => some l.w
  | .scales, l => some l.scales
  | .biases, l => some l.biases

def mlpGet : MlpKey → MlpWeights → Option Value
  | .norm, m => some m.norm
  | .gateCodes, m => some m.gateCodes
  | .gateScales, m => some m.gateScales
  | .upCodes, m => some m.upCodes
  | .upScales, m => some m.upScales
  | .downCodes, m => some m.downCodes
  | .downScales, m => some m.downScales

def deltaInput (w : DeltaWeights) (conv rec : Option Value) : SKey → Option Value
  | .inputNorm => some w.inputNorm
  | .lin 0 l => linGet l w.qkv
  | .lin 1 l => linGet l w.z
  | .lin 2 l => linGet l w.a
  | .lin 3 l => linGet l w.b
  | .lin 4 l => linGet l w.out
  | .conv => some w.conv
  | .aLog => some w.aLog
  | .dtBias => some w.dtBias
  | .norm => some w.norm
  | .qScale => some w.qScale
  | .kScale => some w.kScale
  | .mlp m => mlpGet m w.mlp
  | .cache 0 => conv
  | .cache 1 => rec
  | _ => none

def attnInput (w : AttentionWeights) (kb vb : Option Value) : SKey → Option Value
  | .inputNorm => some w.inputNorm
  | .lin 0 l => linGet l w.q
  | .lin 1 l => linGet l w.k
  | .lin 2 l => linGet l w.v
  | .lin 3 l => linGet l w.o
  | .qNorm => some w.qNorm
  | .kNorm => some w.kNorm
  | .mlp m => mlpGet m w.mlp
  | .cache 0 => kb
  | .cache 1 => vb
  | _ => none

def stageInput : StageWeights → Handles → SKey → Option Value
  | .delta w, .delta conv rec => deltaInput w conv rec
  | .attention w, .attention kb vb => attnInput w kb vb
  | _, _ => fun _ => none

/-- The step's inputs: token ids, the pipeline weights, and stage `p`'s
weights and caches at chain position `p`. -/
def stepInputs (w : PipelineWeights) (token : Nat) (hs : List Handles) : InKey → Option Value
  | .tokenIds => some (tokenIds token)
  | .embedWords => some w.embedWords
  | .embedScales => some w.embedScales
  | .embedBiases => some w.embedBiases
  | .finalNorm => some w.finalNorm
  | .head l => linGet l w.head
  | .stage p k => match (stageWeights w)[p]?, hs[p]? with
    | some s, some h => stageInput s h k
    | _, _ => none

structure LinLayout where
  kind : Projector
  bits : Nat
  rows : Nat
  cols : Nat
deriving DecidableEq

structure MlpLayout where
  gateBits : Nat
  upBits : Nat
  downBits : Nat
deriving DecidableEq

structure DeltaLayout where
  qkv : LinLayout
  z : LinLayout
  a : LinLayout
  b : LinLayout
  out : LinLayout
  mlp : MlpLayout
  /-- Whether the conv and recurrent caches exist (else zeros are built). -/
  hasConv : Bool
  hasRec : Bool
deriving DecidableEq

structure AttnLayout where
  q : LinLayout
  k : LinLayout
  v : LinLayout
  o : LinLayout
  mlp : MlpLayout
  /-- The key and value buffers' capacities (none: no buffer yet). -/
  kcap : Option Nat
  vcap : Option Nat
deriving DecidableEq

inductive StageLayout where
  | delta (d : DeltaLayout)
  | attention (a : AttnLayout)
deriving DecidableEq

def linLayout (kind : Projector) (l : Linear) : LinLayout :=
  ⟨kind, l.bits, l.scales.shape.headD 0, l.scales.shape.getD 1 0 * 64⟩

def mlpLayout (m : MlpWeights) : MlpLayout := ⟨m.gateBits, m.upBits, m.downBits⟩

def deltaLayout (w : DeltaWeights) (conv rec : Option Value) : DeltaLayout :=
  ⟨linLayout w.qkvKind w.qkv, linLayout w.zKind w.z, linLayout .plain w.a, linLayout .plain w.b,
    linLayout w.outKind w.out, mlpLayout w.mlp, conv.isSome, rec.isSome⟩

def capOf (b : Option Value) : Option Nat := b.map (·.shape.getD 2 0)

def attnLayout (w : AttentionWeights) (kb vb : Option Value) : AttnLayout :=
  ⟨linLayout w.qKind w.q, linLayout w.kKind w.k, linLayout w.vKind w.v, linLayout w.oKind w.o,
    mlpLayout w.mlp, capOf kb, capOf vb⟩

def stageLayout : StageWeights → Handles → StageLayout
  | .delta w, .delta conv rec => .delta (deltaLayout w conv rec)
  | .delta w, _ => .delta (deltaLayout w none none)
  | .attention w, .attention kb vb => .attention (attnLayout w kb vb)
  | .attention w, _ => .attention (attnLayout w none none)

def chainLayout : List StageWeights → List Handles → List StageLayout
  | s :: ss, h :: hs => stageLayout s h :: chainLayout ss hs
  | _, _ => []

/-! ## Builders

Generic in the dimension type: `L` embeds integer literals, `nD`/`n1D` are
the cache offset `n` and `n + 1` as the FFI records them. -/

section
variable {δ κ : Type} (L : Int → δ)

def D (l : List Nat) : List δ := l.map fun n => L n

def cfgOf (c : Config) : RCfg δ :=
  ⟨c.outputs.map (fun o => (D L o.1, o.2.code)), [L c.grid.1, L c.grid.2.1, L c.grid.2.2],
    [L c.threadGroup.1, L c.threadGroup.2.1, L c.threadGroup.2.2],
    c.templateInts.map (fun t => (t.1.toList, L t.2)), c.templateDtypes.map (fun t => (t.1.toList, t.2.code)),
    c.initValue.map fun n => L n⟩

def kern (name : List Char) (c : Config) (out : Nat) : RPrim δ κ := .kernel name (cfgOf L c) out

def inp (k : κ) : Build δ κ Nat := emit (.input k) []

/-- A cache input if present, else the node `zp` (zeros). -/
def optInp (b : Bool) (key : κ) (zp : RPrim δ κ) : Build δ κ Nat := if b then inp key else emit zp []

def projPrim (lay : LinLayout) : RPrim δ κ :=
  match lay.kind with
  | .affineRow => kern L chars!"mlx_bun_affine_row" (affineConfig lay.cols lay.rows lay.bits) 0
  | .plain => .qmm true 64 lay.bits chars!"affine"

/-- GlueLayers.project. -/
def projectG (lay : LinLayout) (key : LinKey → κ) (x : Nat) : Build δ κ Nat := do
  let w ← inp (key .w)
  let s ← inp (key .scales)
  let b ← inp (key .biases)
  emit (projPrim L lay) [x, w, s, b]

def epsWord32 : Nat := 0x358637bd

/-- GlueStep.embedTrace. -/
def embedG (key : InKey → κ) : Build δ κ Nat := do
  let ids ← inp (key .tokenIds)
  let w ← inp (key .embedWords)
  let s ← inp (key .embedScales)
  let b ← inp (key .embedBiases)
  let rows ← emit (.take 0) [w, ids]
  let sc ← emit (.take 0) [s, ids]
  let bi ← emit (.take 0) [b, ids]
  emit (.dequantize 64 4 chars!"affine" none) [rows, sc, bi]

/-- GlueLayers.suffixTrace. -/
def suffixG (m : MlpLayout) (key : MlpKey → κ) (x mixed : Nat) : Build δ κ Nat := do
  let nw ← inp (key .norm)
  let h ← emit (kern L chars!"mlx_bun_residual_rms_norm" residualConfig 0) [x, mixed, nw]
  let n ← emit (kern L chars!"mlx_bun_residual_rms_norm" residualConfig 1) [x, mixed, nw]
  let x2 ← emit (.reshape (D L [1, 5120])) [n]
  let gc ← inp (key .gateCodes)
  let gs ← inp (key .gateScales)
  let uc ← inp (key .upCodes)
  let us ← inp (key .upScales)
  let mid ← emit (kern L chars!"mlx_bun_trellis_gateup_codebook_row" (gateUpConfig m.gateBits m.upBits) 0)
    [x2, gc, gs, uc, us]
  let mid1 ← emit (.reshape (D L [1, 1, 17408])) [mid]
  let mid2 ← emit (.reshape (D L [1, 17408])) [mid1]
  let dc ← inp (key .downCodes)
  let ds ← inp (key .downScales)
  let part ← emit (kern L chars!"mlx_bun_trellis_down_codebook_row" (downConfig m.downBits) 0) [mid2, dc, ds]
  let o ← emit (kern L chars!"mlx_bun_trellis_down_codebook_fold" foldConfig 0) [part]
  let hidden ← emit (.reshape (D L [1, 1, 5120])) [o]
  emit (.binary chars!"add") [h, hidden]

/-- The hidden-size RMS norm (`eps` 1e-6 as its f32 word). -/
def normG (key : κ) (x : Nat) : Build δ κ Nat := do
  let w ← inp key
  emit (.rmsNorm epsWord32) [x, w]

/-- GlueLayers.deltaMixerTrace. -/
def deltaMixerG (d : DeltaLayout) (key : SKey → κ) (x : Nat) : Build δ κ (Nat × Nat × Nat) := do
  let qkv ← projectG L d.qkv (key ∘ .lin 0) x
  let z0 ← projectG L d.z (key ∘ .lin 1) x
  let z ← emit (.reshape (D L [1, 1, 48, 128])) [z0]
  let b ← projectG L d.b (key ∘ .lin 3) x
  let a ← projectG L d.a (key ∘ .lin 2) x
  let conv ← optInp d.hasConv (key (.cache 0)) (.zeros (D L [1, 3, 10240]) Ffi.dtBf16)
  let joined ← emit (.concat 1) [conv, qkv]
  let view ← emit (.slice (D L [0, 1, 0]) (D L [1, 4, 10240]) (D L [1, 1, 1])) [joined]
  let zi ← emit (.data [0, 0, 0, 0] [] Ffi.dtInt32) []
  let tail ← emit (.sliceDynamic [0] (D L [1, 3, 10240])) [view, zi]
  let cw ← inp (key .conv)
  let c ← emit (.conv1d 1 0 1 10240) [joined, cw]
  let qs ← inp (key .qScale)
  let ks ← inp (key .kScale)
  let q ← emit (kern L chars!"mlx_bun_silu_rms_heads" headsConfig 0) [c, qs, ks]
  let k ← emit (kern L chars!"mlx_bun_silu_rms_heads" headsConfig 1) [c, qs, ks]
  let v ← emit (kern L chars!"mlx_bun_silu_rms_heads" headsConfig 2) [c, qs, ks]
  let beta ← emit (.unary chars!"sigmoid") [b]
  let al ← inp (key .aLog)
  let dt ← inp (key .dtBias)
  let g ← emit .computeG [al, a, dt]
  let st0 ← optInp d.hasRec (key (.cache 1)) (.zeros (D L [1, 48, 128, 128]) Ffi.dtF32)
  let t ← emit (.data [1, 0, 0, 0] (D L [1]) Ffi.dtInt32) []
  let y ← emit (kern L chars!"gated_delta_step" gatedConfig 0) [q, k, v, g, beta, st0, t]
  let s ← emit (kern L chars!"gated_delta_step" gatedConfig 1) [q, k, v, g, beta, st0, t]
  let nw ← inp (key .norm)
  let gated ← emit (kern L chars!"mlx_bun_gated_rms_norm" gatedNormConfig 0) [y, z, nw]
  let merged ← emit (.reshape (D L [1, 1, 6144])) [gated]
  let mixed ← projectG L d.out (key ∘ .lin 4) merged
  pure (mixed, tail, s)

/-- GlueLayers.deltaLayerTrace: output, conv tail, recurrent state. -/
def deltaLayerG (d : DeltaLayout) (key : SKey → κ) (x : Nat) : Build δ κ (Nat × Nat × Nat) := do
  let normed ← normG (key .inputNorm) x
  let (mixed, tail, s) ← deltaMixerG L d key normed
  let out ← suffixG L d.mlp (key ∘ .mlp) x mixed
  pure (out, tail, s)

/-- The capacity after kv.ts growth (GlueKv.step). -/
def kvCap (cap : Option Nat) (n : Nat) : Nat :=
  match cap with
  | none => 256
  | some c => if c < n + 1 then (if n % 256 = 0 then c else n) + 256 else c

variable (n : Nat) (nD n1D : δ)

def kvOldG (b : Nat) : Build δ κ Nat :=
  if n % 256 = 0 then pure b
  else emit (.slice (D L [0, 0, 0, 0]) [L 1, L 4, nD, L 256] (D L [1, 1, 1, 1])) [b]

def kvGrownG (c b : Nat) : Build δ κ Nat :=
  if c < n + 1 then do
    let old ← kvOldG L n nD b
    let z ← emit (.zeros (D L [1, 4, 256, 256]) Ffi.dtBf16) []
    emit (.concat 2) [old, z]
  else pure b

def kvGrowG (cap : Option Nat) (key : κ) : Build δ κ Nat :=
  match cap with
  | none => emit (.zeros (D L [1, 4, 256, 256]) Ffi.dtBf16) []
  | some c => do
    let b ← inp key
    kvGrownG L n nD c b

def kvViewG (cap : Option Nat) (b : Nat) : Build δ κ Nat :=
  if kvCap cap n = n + 1 then pure b
  else emit (.slice (D L [0, 0, 0, 0]) [L 1, L 4, n1D, L 256] (D L [1, 1, 1, 1])) [b]

/-- GlueKv.step: the written buffer and the view `[0, n+1)`. A slice of the
whole buffer is the buffer itself (MLX's slice of an unchanged shape). -/
def kvStepG (cap : Option Nat) (key : κ) (x : Nat) : Build δ κ (Nat × Nat) := do
  let grown ← kvGrowG L n nD cap key
  let b ← emit (.sliceUpdate [L 0, L 0, nD, L 0] [L 1, L 4, n1D, L 256] (D L [1, 1, 1, 1])) [grown, x]
  let view ← kvViewG L n n1D cap b
  pure (b, view)

/-- GlueAttention.attentionTrace. -/
def attentionG (a : AttnLayout) (key : SKey → κ) (qp kp vp : Nat) : Build δ κ (Nat × Nat × Nat) := do
  let qpr ← emit (.reshape (D L [1, 1, 24, 512])) [qp]
  let qh ← emit (.slice (D L [0, 0, 0, 0]) (D L [1, 1, 24, 256]) (D L [1, 1, 1, 1])) [qpr]
  let gh ← emit (.slice (D L [0, 0, 0, 256]) (D L [1, 1, 24, 512]) (D L [1, 1, 1, 1])) [qpr]
  let gate ← emit (.reshape (D L [1, 1, 6144])) [gh]
  let kr ← emit (.reshape (D L [1, 1, 4, 256])) [kp]
  let vr ← emit (.reshape (D L [1, 1, 4, 256])) [vp]
  let qn ← normG (key .qNorm) qh
  let qt ← emit (.transpose [0, 2, 1, 3]) [qn]
  let kn ← normG (key .kNorm) kr
  let kt ← emit (.transpose [0, 2, 1, 3]) [kn]
  let vt ← emit (.transpose [0, 2, 1, 3]) [vr]
  let q ← emit (.rope 64 false (0x4b189680 + 2 ^ 32) 0x3f800000 nD) [qt]
  let k ← emit (.rope 64 false (0x4b189680 + 2 ^ 32) 0x3f800000 nD) [kt]
  let (kb, keys) ← kvStepG L n nD n1D a.kcap (key (.cache 0)) k
  let (vb, values) ← kvStepG L n nD n1D a.vcap (key (.cache 1)) vt
  let attn ← emit (.sdpa 0x3d800000 []) [q, keys, values]
  let attnT ← emit (.transpose [0, 2, 1, 3]) [attn]
  let merged ← emit (.reshape [L 1, L 1, L (-1)]) [attnT]
  let sig ← emit (.unary chars!"sigmoid") [gate]
  let gated ← emit (.binary chars!"multiply") [merged, sig]
  pure (gated, kb, vb)

/-- GlueLayers.attentionLayerTrace: output, key and value buffers. -/
def attentionLayerG (a : AttnLayout) (key : SKey → κ) (x : Nat) : Build δ κ (Nat × Nat × Nat) := do
  let normed ← normG (key .inputNorm) x
  let qp ← projectG L a.q (key ∘ .lin 0) normed
  let kp ← projectG L a.k (key ∘ .lin 1) normed
  let vp ← projectG L a.v (key ∘ .lin 2) normed
  let (gated, kb, vb) ← attentionG L n nD n1D a key qp kp vp
  let mixed ← projectG L a.o (key ∘ .lin 3) gated
  let out ← suffixG L a.mlp (key ∘ .mlp) x mixed
  pure (out, kb, vb)

def stageG : StageLayout → (SKey → κ) → Nat → Build δ κ (Nat × Nat × Nat)
  | .delta d, key, x => deltaLayerG L d key x
  | .attention a, key, x => attentionLayerG L n nD n1D a key x

/-- GlueStep.chainTrace from chain position `p`: the hidden node and each
stage's two cache nodes. -/
def chainG (key : InKey → κ) : Nat → List StageLayout → Nat → Build δ κ (Nat × List (Nat × Nat))
  | _, [], x => pure (x, [])
  | p, s :: ss, x => do
    let (y, c1, c2) ← stageG L n nD n1D s (fun k => key (.stage p k)) x
    let (z, cs) ← chainG key (p + 1) ss y
    pure (z, (c1, c2) :: cs)

/-- GlueStep.stepTrace: the token node (before `item_uint32`) and the cache nodes. -/
def stepG (key : InKey → κ) (stages : List StageLayout) (head : LinLayout) : Build δ κ (Nat × List (Nat × Nat)) := do
  let x ← embedG (κ := κ) (δ := δ) key
  let (y, cs) ← chainG L n nD n1D key 0 stages x
  let h ← normG (key .finalNorm) y
  let logits ← projectG L head (key ∘ .head) h
  let l ← emit (.reshape (D L [1, 248320])) [logits]
  let lse ← emit (.logsumexp 1 true) [l]
  let values ← emit (kern L chars!"normalized_argmax_partial" partialConfig 0) [l, lse]
  let indices ← emit (kern L chars!"normalized_argmax_partial" partialConfig 1) [l, lse]
  let tok ← emit (kern L chars!"normalized_argmax_finish" finishConfig 0) [values, indices]
  let r ← emit (.reshape (D L [1])) [tok]
  pure (r, cs)

end

/-- The expected graph of one decode step at cache offset `n`, its token
node and cache nodes. -/
def stepGraph (stages : List StageLayout) (head : LinLayout) (n : Nat) :
    List (RNode Int InKey) × Nat × List (Nat × Nat) :=
  let r := run (stepG id n (n : Int) ((n : Int) + 1) id stages head) []
  (r.2, r.1)

/-! ## Primitive values at the builders' constants -/

theorem natShape_D (l : List Nat) : natShape (D id l) = some l := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    show natShape ((a : Int) :: D id l) = some (a :: l)
    rw [natShape, if_pos (Int.natCast_nonneg a), ih]
    simp

theorem count_D (l : List Nat) : (D id l).count (-1) = 0 := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    show ((a : Int) :: D id l).count (-1) = 0
    rw [List.count_cons, ih]
    simp only [beq_iff_eq]
    split <;> omega

theorem nat?_nat (n : Nat) : nat? (n : Int) = some n := by simp [nat?]

theorem mapM_self {α β : Type} (l : List α) (f : α → β) (h : β → Option α) (e : ∀ x ∈ l, h (f x) = some x) :
    (l.map f).mapM h = some l := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    simp only [List.map_cons, List.mapM_cons, e a (List.mem_cons_self ..),
      ih fun x hx => e x (List.mem_cons_of_mem _ hx)]
    rfl

theorem toConfig_cfgOf (c : Config) : toConfig (cfgOf id c) = some c := by
  obtain ⟨outs, ⟨g1, g2, g3⟩, ⟨t1, t2, t3⟩, dts, ints, init⟩ := c
  have ho : (outs.map fun o => (D id o.1, o.2.code)).mapM outOf = some outs :=
    mapM_self _ _ _ fun ⟨s, d⟩ _ => by simp [outOf, natShape_D, Dtype.ofCode_code]
  have hd : (dts.map fun t => (t.1.toList, t.2.code)).mapM dtOf = some dts :=
    mapM_self _ _ _ fun ⟨n, d⟩ _ => by simp [dtOf, Dtype.ofCode_code, String.ofList_toList]
  have hi : (ints.map fun t => (t.1.toList, id (t.2 : Int))).mapM intOf = some ints :=
    mapM_self _ _ _ fun ⟨n, d⟩ _ => by simp [intOf, nat?_nat, String.ofList_toList]
  have hn : initOf (init.map fun n => id (n : Int)) = some init := by
    cases init <;> simp [initOf, nat?_nat]
  simp only [toConfig, cfgOf, ho, hd, hi, hn]
  simp [triple?, nat?_nat]

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} (env : Env κ)

theorem pe_reshape (l : List Nat) (v : Value) :
    primEval M K env (.reshape (D id l)) [v] = reshape v l := by
  simp only [primEval, reshapeDims, count_D, natShape_D]
  rfl

theorem pe_reshapeInfer (v : Value) :
    primEval M K env (.reshape [id 1, id 1, id (-1)]) [v] = GlueLayout.reshapeInfer v [1, 1, -1] := by
  simp [primEval, reshapeDims]

theorem pe_slice (st sp : List Int) (a b : List Nat) (sr : List Int) (hs : unitStrides sr = true)
    (ha : natShape st = some a) (hb : natShape sp = some b) (v : Value) :
    primEval M K env (.slice st sp sr) [v] = slice v a b := by
  simp only [primEval, hs, ha, hb, if_true]
  rfl

theorem pe_sliceUpdate (st sp : List Int) (a b : List Nat) (sr : List Int) (hs : unitStrides sr = true)
    (ha : natShape st = some a) (hb : natShape sp = some b) (v u : Value) :
    primEval M K env (.sliceUpdate st sp sr) [v, u] = sliceUpdateRange v u a b := by
  simp only [primEval, hs, ha, hb, if_true]
  rfl

theorem pe_sliceDynamic (ax : List Nat) (sz : List Nat) (v st : Value) :
    primEval M K env (.sliceDynamic ax (D id sz)) [v, st] = sliceDynamic v st ax sz := by
  simp only [primEval, natShape_D]
  rfl

theorem pe_zeros (s : List Nat) (dt : Dtype) :
    primEval M K env (.zeros (D id s) dt.code) [] = some (zeros s dt) := by
  simp only [primEval, natShape_D, Dtype.ofCode_code]
  rfl

theorem pe_kernel (name : List Char) (k : Kernel) (hk : kernelOf name = some k) (c : Config) (out : Nat)
    (xs : List Value) : primEval M K env (kern id name c out) xs = (K.apply k xs c).bind (·[out]?) := by
  simp only [kern, primEval, hk, toConfig_cfgOf]
  rfl

theorem pe_kernel_some {name : List Char} {k : Kernel} (hk : kernelOf name = some k) {c : Config} {out : Nat}
    {xs ys : List Value} (h : K.apply k xs c = some ys) {y : Value} (hy : ys[out]? = some y) :
    primEval M K env (kern id name c out) xs = some y := by
  rw [pe_kernel M K env name k hk c out xs, h]
  exact hy

theorem pe_rmsNorm (e : Nat) (x w : Value) (P : RmsNorm.Platform) (h : normPlatform M w = some P) :
    primEval M K env (.rmsNorm e) [x, w] = rmsNorm P x w (f32 e) := by
  simp only [primEval, h]
  rfl

theorem normPlatform_hidden (w : Value) (h : w.shape = [5120]) : normPlatform M w = some M.hiddenNorm := by
  simp [normPlatform, h]

theorem normPlatform_head (w : Value) (h : w.shape = [256]) : normPlatform M w = some M.headNorm := by
  simp [normPlatform, h]

theorem pe_project (kind : Projector) (l : Linear) (x y : Value) (h : project M K kind l x = some y) :
    primEval M K env (projPrim id (linLayout kind l)) [x, l.w, l.scales, l.biases] = some y := by
  cases kind with
  | affineRow =>
    simp only [project] at h
    obtain ⟨ys, e, h⟩ := Option.bind_eq_some_iff.mp h
    rcases ys with _ | ⟨a, _ | ⟨_, _⟩⟩
    · exact absurd h (by simp)
    · dsimp only at h
      cases h
      exact pe_kernel_some M K env (k := .affineRow) rfl e rfl
    · exact absurd h (by simp)
  | plain =>
    simp only [project] at h
    simp only [projPrim, linLayout, primEval]
    rw [← h]

theorem projPrim_noexp [DecidableEq κ] (lay : LinLayout) : isExp (κ := κ) (projPrim id lay) = false := by
  unfold projPrim; split <;> simp [isExp, kern]

theorem pe_input (k : κ) : primEval M K env (.input k) [] = env.inputs k := rfl
theorem pe_take (a i : Value) : primEval M K env (.take 0) [a, i] = takeAxis0 a i := rfl
theorem pe_dequant (w s b : Value) :
    primEval M K env (.dequantize 64 4 chars!"affine" none) [w, s, b] = dequantizeRow M w s b := by
  simp [primEval]
theorem pe_concat (a b : Value) (axis : Nat) : primEval M K env (.concat axis) [a, b] = concatenate a b axis := rfl
theorem pe_conv (x w : Value) : primEval M K env (.conv1d 1 0 1 10240) [x, w] = conv1d M x w 1 0 1 10240 := rfl
theorem pe_transpose (v : Value) (ax : List Nat) : primEval M K env (.transpose ax) [v] = transpose v ax := rfl
theorem pe_sigmoid (v : Value) : primEval M K env (.unary chars!"sigmoid") [v] = sigmoid M v := by simp [primEval]
theorem pe_add (a b : Value) : primEval M K env (.binary chars!"add") [a, b] = add a b := by simp [primEval]
theorem pe_multiply (a b : Value) : primEval M K env (.binary chars!"multiply") [a, b] = multiply a b := by
  simp [primEval]
theorem pe_rope (x : Value) (n : Int) :
    primEval M K env (.rope 64 false (0x4b189680 + 2 ^ 32) 0x3f800000 n) [x] =
      rope M x 64 false (GlueAttention.optionalFloat (0x4b189680 + 2 ^ 32)) (f32 0x3f800000) n := rfl
theorem pe_sdpa (q k v : Value) : primEval M K env (.sdpa 0x3d800000 []) [q, k, v] = sdpa M q k v (f32 0x3d800000) := by
  simp [primEval]
theorem pe_logsumexp (v : Value) : primEval M K env (.logsumexp 1 true) [v] = logsumexp K.sampling v := by
  simp [primEval]
theorem pe_computeG (xs : List Value) (g : Value) (h : closureApply M .computeG xs = some [g]) :
    primEval M K env .computeG xs = some g := by
  simp only [primEval, h]; rfl

end

/-! ## Builder steps -/

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ] (env : Env κ)

theorem spec_seq {α β : Type} {x : Build Int κ α} {f : α → Build Int κ β} {g : List (RNode Int κ)}
    {P : α → List (RNode Int κ) → Prop} {Q : β → List (RNode Int κ) → Prop}
    (h : Spec x g P) (k : ∀ a g', P a g' → Spec (f a) g' Q) : Spec (x >>= f) g Q := k _ _ h

theorem spec_step {β : Type} {g : List (RNode Int κ)} {fs : List (Nat × Value)} {p : RPrim Int κ} {ins : List Nat}
    {vs : List Value} {v : Value} {f : Nat → Build Int κ β} {Q : β → List (RNode Int κ) → Prop}
    (hfs : AllEv M K env g fs) (hp : isExp p = false) (hins : List.Forall₂ (fun j x => (j, x) ∈ fs) ins vs)
    (hv : primEval M K env p vs = some v)
    (k : ∀ g' i, AllEv M K env g' ((i, v) :: fs) → Spec (f i) g' Q) : Spec (emit p ins >>= f) g Q :=
  k _ _ (emit_ev M K env g fs hfs p ins vs v hp hins hv)

theorem spec_last {g : List (RNode Int κ)} {fs : List (Nat × Value)} {p : RPrim Int κ} {ins : List Nat}
    {vs : List Value} {v : Value} {Q : Nat → List (RNode Int κ) → Prop}
    (hfs : AllEv M K env g fs) (hp : isExp p = false) (hins : List.Forall₂ (fun j x => (j, x) ∈ fs) ins vs)
    (hv : primEval M K env p vs = some v)
    (k : ∀ g' i, AllEv M K env g' ((i, v) :: fs) → Q i g') : Spec (emit p ins) g Q :=
  k _ _ (emit_ev M K env g fs hfs p ins vs v hp hins hv)

theorem spec_inp {β : Type} {g : List (RNode Int κ)} {fs : List (Nat × Value)} {key : κ} {v : Value}
    {f : Nat → Build Int κ β} {Q : β → List (RNode Int κ) → Prop}
    (hfs : AllEv M K env g fs) (hv : env.inputs key = some v)
    (k : ∀ g' i, AllEv M K env g' ((i, v) :: fs) → Spec (f i) g' Q) : Spec (inp key >>= f) g Q :=
  spec_step M K env hfs (by simp [isExp]) .nil hv k

theorem AllEv.mono {g : List (RNode Int κ)} {fs fs' : List (Nat × Value)} (h : AllEv M K env g fs)
    (sub : ∀ p ∈ fs', p ∈ fs) : AllEv M K env g fs' := fun p hp => h p (sub p hp)

theorem projectG_spec (kind : Projector) (l : Linear) (key : LinKey → κ) (hkey : ∀ k, env.inputs (key k) = linGet k l)
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs) (x : Nat) (xv : Value)
    (hx : (x, xv) ∈ fs) (y : Value) (hy : project M K kind l xv = some y) :
    Spec (projectG id (linLayout kind l) key x) g (fun o g' => AllEv M K env g' ((o, y) :: fs)) := by
  unfold projectG
  refine spec_inp M K env hfs (hkey .w) fun g1 w h1 => ?_
  refine spec_inp M K env h1 (hkey .scales) fun g2 s h2 => ?_
  refine spec_inp M K env h2 (hkey .biases) fun g3 b h3 => ?_
  refine spec_last M K env h3 (projPrim_noexp _) (by simp [hx]) (pe_project M K env kind l xv y hy)
    fun g' i h => h.mono M K env (by intro p hp; simp only [List.mem_cons] at hp ⊢; tauto)


end

/-! ## The step's pieces evaluate to the trace's values -/

macro "peel " h:ident " => " x:ident e:ident : tactic =>
  `(tactic| obtain ⟨$x, $e, $h⟩ := Option.bind_eq_some_iff.mp $h)

macro "sub_tac" : tactic => `(tactic| (intro p hp; simp only [List.mem_cons] at hp ⊢; tauto))

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) {κ : Type} [DecidableEq κ] (env : Env κ)

theorem embedG_spec (key : InKey → κ) (words scales biases : Value) (token : Nat)
    (hk : env.inputs (key .tokenIds) = some (tokenIds token)) (hw : env.inputs (key .embedWords) = some words)
    (hs : env.inputs (key .embedScales) = some scales) (hb : env.inputs (key .embedBiases) = some biases)
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs)
    (x : Value) (hx : embedTrace M words scales biases token = some x) :
    Spec (embedG (δ := Int) key) g (fun o g' => AllEv M K env g' ((o, x) :: fs)) := by
  unfold embedTrace at hx
  peel hx => rows e1
  peel hx => sc e2
  peel hx => bi e3
  unfold embedG
  refine spec_inp M K env hfs hk fun g1 i1 h1 => ?_
  refine spec_inp M K env h1 hw fun g2 i2 h2 => ?_
  refine spec_inp M K env h2 hs fun g3 i3 h3 => ?_
  refine spec_inp M K env h3 hb fun g4 i4 h4 => ?_
  refine spec_step M K env h4 (by simp [isExp]) (by simp) ((pe_take M K env _ _).trans e1) fun g5 i5 h5 => ?_
  refine spec_step M K env h5 (by simp [isExp]) (by simp) ((pe_take M K env _ _).trans e2) fun g6 i6 h6 => ?_
  refine spec_step M K env h6 (by simp [isExp]) (by simp) ((pe_take M K env _ _).trans e3) fun g7 i7 h7 => ?_
  exact spec_last M K env h7 (by simp [isExp]) (by simp) ((pe_dequant M K env _ _ _).trans hx)
    fun g' i h => h.mono M K env (by sub_tac)


theorem pe_zeroIndex : primEval M K env (.data [0, 0, 0, 0] [] Ffi.dtInt32) [] = some GlueConv.zeroIndex := by
  simp only [primEval, dataValue, natShape, GlueConv.zeroIndex]
  show some _ = some _
  congr 2
  funext i
  rw [show extent ([] : List Nat) = 1 from rfl, Nat.mod_one]
  rfl

theorem pe_steps : primEval M K env (.data [1, 0, 0, 0] (D id [1]) Ffi.dtInt32) [] =
    some ⟨.int32, [1], fun _ => 1⟩ := by
  simp only [primEval, dataValue, natShape_D]
  show some _ = some _
  congr 2
  funext i
  rw [show extent [1] = 1 from rfl, Nat.mod_one]
  rfl

theorem spec_opt {β : Type} {g : List (RNode Int κ)} {fs : List (Nat × Value)} (o : Option Value) (dflt : Value)
    (key : κ) (zp : RPrim Int κ) (hz : primEval M K env zp [] = some dflt) (hzx : isExp zp = false)
    (hk : ∀ v, o = some v → env.inputs key = some v) (hfs : AllEv M K env g fs)
    {f : Nat → Build Int κ β} {Q : β → List (RNode Int κ) → Prop}
    (k : ∀ g' i, AllEv M K env g' ((i, o.getD dflt) :: fs) → Spec (f i) g' Q) :
    Spec (optInp o.isSome key zp >>= f) g Q := by
  cases o with
  | none => exact spec_step M K env hfs hzx .nil hz k
  | some v => exact spec_inp M K env hfs (hk v rfl) k

theorem suffixG_spec (m : MlpWeights) (key : MlpKey → κ) (hkey : ∀ k, env.inputs (key k) = mlpGet k m)
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs) (x mixed : Nat) (xv mv : Value)
    (hx : (x, xv) ∈ fs) (hm : (mixed, mv) ∈ fs) (out : Value) (ho : suffixTrace K m xv mv = some out) :
    Spec (suffixG id (mlpLayout m) key x mixed) g (fun o g' => AllEv M K env g' ((o, out) :: fs)) := by
  unfold suffixTrace at ho
  peel ho => l1 e1
  split at ho <;> [skip; exact absurd ho (by simp)]
  rename_i h n
  peel ho => x2 e2
  peel ho => l3 e3
  split at ho <;> [skip; exact absurd ho (by simp)]
  rename_i mid
  peel ho => mid1 e4
  peel ho => mid2 e5
  peel ho => l6 e6
  split at ho <;> [skip; exact absurd ho (by simp)]
  rename_i part
  peel ho => l7 e7
  split at ho <;> [skip; exact absurd ho (by simp)]
  rename_i o
  peel ho => hidden e8
  unfold suffixG
  refine spec_inp M K env hfs (hkey .norm) fun g1 i1 h1 => ?_
  refine spec_step M K env h1 (by simp [isExp, kern]) (by simp [hx, hm])
    (pe_kernel_some M K env (k := .residualRmsNorm) rfl e1 rfl) fun g2 i2 h2 => ?_
  refine spec_step M K env h2 (by simp [isExp, kern]) (by simp [hx, hm])
    (pe_kernel_some M K env (k := .residualRmsNorm) rfl e1 rfl) fun g3 i3 h3 => ?_
  refine spec_step M K env h3 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e2) fun g4 i4 h4 => ?_
  refine spec_inp M K env h4 (hkey .gateCodes) fun g5 i5 h5 => ?_
  refine spec_inp M K env h5 (hkey .gateScales) fun g6 i6 h6 => ?_
  refine spec_inp M K env h6 (hkey .upCodes) fun g7 i7 h7 => ?_
  refine spec_inp M K env h7 (hkey .upScales) fun g8 i8 h8 => ?_
  refine spec_step M K env h8 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .gateUp) rfl e3 rfl) fun g9 i9 h9 => ?_
  refine spec_step M K env h9 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e4) fun g10 i10 h10 => ?_
  refine spec_step M K env h10 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e5) fun g11 i11 h11 => ?_
  refine spec_inp M K env h11 (hkey .downCodes) fun g12 i12 h12 => ?_
  refine spec_inp M K env h12 (hkey .downScales) fun g13 i13 h13 => ?_
  refine spec_step M K env h13 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .downPartial) rfl e6 rfl) fun g14 i14 h14 => ?_
  refine spec_step M K env h14 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .downFold) rfl e7 rfl) fun g15 i15 h15 => ?_
  refine spec_step M K env h15 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e8) fun g16 i16 h16 => ?_
  exact spec_last M K env h16 (by simp [isExp]) (by simp) ((pe_add M K env _ _).trans ho)
    fun g' i h => h.mono M K env (by sub_tac)

theorem normG_spec (key : κ) (wv : Value) (hk : env.inputs key = some wv) (P : RmsNorm.Platform)
    (hP : normPlatform M wv = some P) (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs)
    (x : Nat) (xv : Value) (hx : (x, xv) ∈ fs) (y : Value) (hy : rmsNorm P xv wv (f32 0x358637bd) = some y) :
    Spec (normG (δ := Int) key x) g (fun o g' => AllEv M K env g' ((o, y) :: fs)) := by
  unfold normG
  refine spec_inp M K env hfs hk fun g1 i1 h1 => ?_
  exact spec_last M K env h1 (by simp [isExp]) (by simp [hx]) ((pe_rmsNorm M K env _ _ _ P hP).trans hy)
    fun g' i h => h.mono M K env (by sub_tac)

set_option maxHeartbeats 4000000 in
theorem deltaMixerG_spec (w : DeltaWeights) (conv rec : Option Value) (key : SKey → κ)
    (hkey : ∀ k, env.inputs (key k) = deltaInput w conv rec k)
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs) (x : Nat) (xv : Value)
    (hx : (x, xv) ∈ fs) (mo tlo so : Value) (hm : deltaMixerTrace M K w conv rec xv = some (mo, tlo, so)) :
    Spec (deltaMixerG id (deltaLayout w conv rec) key x) g
      (fun o g' => AllEv M K env g' ((o.1, mo) :: (o.2.1, tlo) :: (o.2.2, so) :: fs)) := by
  unfold deltaMixerTrace at hm
  peel hm => qkv e1
  peel hm => z0 e2
  peel hm => z e3
  peel hm => b e4
  peel hm => a e5
  peel hm => joined e6
  peel hm => view e7
  peel hm => tail e8
  peel hm => c e9
  peel hm => l10 e10
  split at hm <;> [skip; exact absurd hm (by simp)]
  rename_i q k v
  peel hm => beta e11
  peel hm => l12 e12
  split at hm <;> [skip; exact absurd hm (by simp)]
  rename_i gg
  peel hm => l13 e13
  split at hm <;> [skip; exact absurd hm (by simp)]
  rename_i y s
  peel hm => l14 e14
  split at hm <;> [skip; exact absurd hm (by simp)]
  rename_i gated
  peel hm => merged e15
  peel hm => mixed e16
  have hr : (mixed, tail, s) = (mo, tlo, so) := Option.some.inj hm
  cases hr
  unfold deltaMixerG
  refine spec_seq (projectG_spec M K env w.qkvKind w.qkv (key ∘ .lin 0) (fun l => hkey (.lin 0 l)) g fs hfs x xv hx
    qkv e1) fun i1 g1 h1 => ?_
  refine spec_seq (projectG_spec M K env w.zKind w.z (key ∘ .lin 1) (fun l => hkey (.lin 1 l)) g1 _ h1 x xv
    (by simp [hx]) z0 e2) fun i2 g2 h2 => ?_
  refine spec_step M K env h2 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e3) fun g3 i3 h3 => ?_
  refine spec_seq (projectG_spec M K env .plain w.b (key ∘ .lin 3) (fun l => hkey (.lin 3 l)) g3 _ h3 x xv
    (by simp [hx]) b e4) fun i4 g4 h4 => ?_
  refine spec_seq (projectG_spec M K env .plain w.a (key ∘ .lin 2) (fun l => hkey (.lin 2 l)) g4 _ h4 x xv
    (by simp [hx]) a e5) fun i5 g5 h5 => ?_
  refine spec_opt M K env conv (zeros [1, 3, 10240] .bfloat16) (key (.cache 0)) (.zeros (D id [1, 3, 10240]) Ffi.dtBf16)
    (pe_zeros M K env [1, 3, 10240] .bfloat16) (by simp [isExp])
    (fun v hv => by rw [hkey]; simp [deltaInput, hv]) h5 fun g6 i6 h6 => ?_
  refine spec_step M K env h6 (by simp [isExp]) (by simp) ((pe_concat M K env _ _ _).trans e6) fun g7 i7 h7 => ?_
  refine spec_step M K env h7 (by simp [isExp]) (by simp)
    ((pe_slice M K env _ _ _ _ _ rfl (natShape_D _) (natShape_D _) _).trans e7) fun g8 i8 h8 => ?_
  refine spec_step M K env h8 (by simp [isExp]) .nil (pe_zeroIndex M K env) fun g9 i9 h9 => ?_
  refine spec_step M K env h9 (by simp [isExp]) (by simp) ((pe_sliceDynamic M K env _ _ _ _).trans e8)
    fun g10 i10 h10 => ?_
  refine spec_inp M K env h10 (hkey .conv) fun g11 i11 h11 => ?_
  refine spec_step M K env h11 (by simp [isExp]) (by simp) ((pe_conv M K env _ _).trans e9) fun g12 i12 h12 => ?_
  refine spec_inp M K env h12 (hkey .qScale) fun g13 i13 h13 => ?_
  refine spec_inp M K env h13 (hkey .kScale) fun g14 i14 h14 => ?_
  refine spec_step M K env h14 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .siluRmsHeads) rfl e10 rfl) fun g15 i15 h15 => ?_
  refine spec_step M K env h15 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .siluRmsHeads) rfl e10 rfl) fun g16 i16 h16 => ?_
  refine spec_step M K env h16 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .siluRmsHeads) rfl e10 rfl) fun g17 i17 h17 => ?_
  refine spec_step M K env h17 (by simp [isExp]) (by simp) ((pe_sigmoid M K env _).trans e11) fun g18 i18 h18 => ?_
  refine spec_inp M K env h18 (hkey .aLog) fun g19 i19 h19 => ?_
  refine spec_inp M K env h19 (hkey .dtBias) fun g20 i20 h20 => ?_
  refine spec_step M K env h20 (by simp [isExp]) (by simp) (pe_computeG M K env _ _ e12) fun g21 i21 h21 => ?_
  refine spec_opt M K env rec (zeros [1, 48, 128, 128] .float32) (key (.cache 1)) (.zeros (D id [1, 48, 128, 128]) Ffi.dtF32)
    (pe_zeros M K env [1, 48, 128, 128] .float32) (by simp [isExp])
    (fun v hv => by rw [hkey]; simp [deltaInput, hv]) h21 fun g22 i22 h22 => ?_
  refine spec_step M K env h22 (by simp [isExp]) .nil (pe_steps M K env) fun g23 i23 h23 => ?_
  refine spec_step M K env h23 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .gatedDeltaStep) rfl e13 rfl) fun g24 i24 h24 => ?_
  refine spec_step M K env h24 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .gatedDeltaStep) rfl e13 rfl) fun g25 i25 h25 => ?_
  refine spec_inp M K env h25 (hkey .norm) fun g26 i26 h26 => ?_
  refine spec_step M K env h26 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .gatedRmsNorm) rfl e14 rfl) fun g27 i27 h27 => ?_
  refine spec_step M K env h27 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e15) fun g28 i28 h28 => ?_
  refine spec_seq (projectG_spec M K env w.outKind w.out (key ∘ .lin 4) (fun l => hkey (.lin 4 l)) g28 _ h28 i28
    merged (by simp) mo e16) fun i29 g29 h29 => ?_
  exact spec_pure (h29.mono M K env (by sub_tac))

theorem deltaLayerG_spec (w : DeltaWeights) (conv rec : Option Value) (key : SKey → κ)
    (hkey : ∀ k, env.inputs (key k) = deltaInput w conv rec k) (hn : w.inputNorm.shape = [5120])
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs) (x : Nat) (xv : Value)
    (hx : (x, xv) ∈ fs) (out tail s : Value) (h : deltaLayerTrace M K w conv rec xv = some (out, tail, s)) :
    Spec (deltaLayerG id (deltaLayout w conv rec) key x) g
      (fun o g' => AllEv M K env g' ((o.1, out) :: (o.2.1, tail) :: (o.2.2, s) :: fs)) := by
  unfold deltaLayerTrace at h
  peel h => normed e1
  peel h => r e2
  obtain ⟨mixed, tl, st⟩ := r
  dsimp only at h
  peel h => o e3
  have hr : (o, tl, st) = (out, tail, s) := Option.some.inj h
  cases hr
  unfold deltaLayerG
  refine spec_seq (normG_spec M K env (key .inputNorm) w.inputNorm (hkey .inputNorm) M.hiddenNorm
    (normPlatform_hidden M _ hn) g fs hfs x xv hx normed e1) fun i1 g1 h1 => ?_
  refine spec_seq (deltaMixerG_spec M K env w conv rec key hkey g1 _ h1 i1 normed (by simp) mixed tail s e2)
    fun ⟨a1, a2, a3⟩ g2 h2 => ?_
  dsimp only
  refine spec_seq (suffixG_spec M K env w.mlp (key ∘ .mlp) (fun m => hkey (.mlp m)) g2 _ h2 x a1 xv mixed
    (by simp [hx]) (by simp) out e3) fun i3 g3 h3 => ?_
  exact spec_pure (h3.mono M K env (by sub_tac))

/-! ### The KV cache update -/

/-- `a` agrees with `b` on dtype, shape and every in-range element. -/
def SameIn (a b : Value) : Prop :=
  a.dtype = b.dtype ∧ a.shape = b.shape ∧ ∀ idx, Within idx a.shape → a.get idx = b.get idx

/-- A cache buffer is `[1, 4, cap, 256]` (GlueKv.Holds). -/
def BufShape (b : Option Value) : Prop := ∀ v, b = some v → v.shape = [1, 4, v.shape.getD 2 0, 256]

theorem SameIn.refl (a : Value) : SameIn a a := ⟨rfl, rfl, fun _ _ => rfl⟩

set_option maxHeartbeats 2000000 in
theorem sdpa_congr (q k k' v v' : Value) (s : Float32) (hk : SameIn k' k) (hv : SameIn v' v) :
    sdpa M q k' v' s = sdpa M q k v s := by
  obtain ⟨kd, ks, kg⟩ := hk
  obtain ⟨vd, vs, vg⟩ := hv
  have hat : ∀ n, k.shape = [1, 4, n, 256] → v.shape = [1, 4, n, 256] → ∀ h c,
      sdpaAt M q k' v' n h c = sdpaAt M q k v n h c := by
    intro n hks hvs h c
    unfold sdpaAt
    have e1 : (fun (t : Fin n) (c : Fin 256) => bf (k'.get [0, (Inference.Kernels.Attention.SdpaScore.kvHead h).val, t.val, c.val])) =
        (fun t c => bf (k.get [0, (Inference.Kernels.Attention.SdpaScore.kvHead h).val, t.val, c.val])) := by
      funext t c
      rw [kg _ (by rw [ks, hks]; exact within4 (by omega) (Inference.Kernels.Attention.SdpaScore.kvHead h).isLt t.isLt c.isLt)]
    have e2 : (fun (t : Fin n) (c : Fin 256) => bf (v'.get [0, (Inference.Kernels.Attention.SdpaScore.kvHead h).val, t.val, c.val])) =
        (fun t c => bf (v.get [0, (Inference.Kernels.Attention.SdpaScore.kvHead h).val, t.val, c.val])) := by
      funext t c
      rw [vg _ (by rw [vs, hvs]; exact within4 (by omega) (Inference.Kernels.Attention.SdpaScore.kvHead h).isLt t.isLt c.isLt)]
    dsimp only
    rw [e1, e2]
  unfold sdpa
  rw [ks, kd, vd, vs]
  split
  next n hn =>
    by_cases hc : q.dtype = .bfloat16 ∧ k.dtype = .bfloat16 ∧ v.dtype = .bfloat16 ∧ q.shape = [1, 24, 1, 256] ∧
        v.shape = [1, 4, n, 256] ∧ s = Inference.Kernels.Attention.SdpaScore.scale
    · rw [if_pos hc, if_pos hc]
      have hf := fun i : Nat => congrArg bfWord (hat n hn hc.2.2.2.2.1 ⟨i / 256 % 24, Nat.mod_lt _ (by decide)⟩
        ⟨i % 256, Nat.mod_lt _ (by decide)⟩)
      simp only [hf]
    · rw [if_neg hc, if_neg hc]
  next => rfl

theorem natShape_start (n : Nat) : natShape [id 0, id 0, (n : Int), id 0] = some [0, 0, n, 0] := by
  simp [natShape]

theorem natShape_stop (n : Nat) : natShape [id 1, id 4, (n : Int), id 256] = some [1, 4, n, 256] := by
  simp [natShape]

theorem natShape_stop1 (n : Nat) : natShape [id 1, id 4, (n : Int) + 1, id 256] = some [1, 4, n + 1, 256] := by
  simp only [natShape, id]
  rw [if_pos (by omega), if_pos (by omega), if_pos (by omega), if_pos (by omega)]
  simp only [Option.map_some]
  congr

theorem spec_pure_bind {α β : Type} {a : α} {f : α → Build Int κ β} {g : List (RNode Int κ)}
    {Q : β → List (RNode Int κ) → Prop} (h : Spec (f a) g Q) : Spec (pure a >>= f) g Q := h

theorem kvTail_spec (n : Nat) (cap : Option Nat) (g : List (RNode Int κ)) (fs : List (Nat × Value))
    (hfs : AllEv M K env g fs) (gi : Nat) (gv : Value) (hg : (gi, gv) ∈ fs) (hgs : gv.shape = [1, 4, kvCap cap n, 256])
    (x : Nat) (kv : Value) (hx : (x, kv) ∈ fs) (b' view : Value)
    (e2 : sliceUpdateRange gv kv [0, 0, n, 0] [1, 4, n + 1, 256] = some b')
    (e3 : slice b' [0, 0, 0, 0] [1, 4, n + 1, 256] = some view) :
    Spec (do
        let b ← emit (.sliceUpdate [id 0, id 0, (n : Int), id 0] [id 1, id 4, (n : Int) + 1, id 256] (D id [1, 1, 1, 1]))
          [gi, x]
        let view ← kvViewG id n ((n : Int) + 1) cap b
        pure (b, view)) g
      (fun o g' => ∃ view', AllEv M K env g' ((o.1, b') :: (o.2, view') :: fs) ∧ SameIn view' view) := by
  refine spec_step M K env hfs (by simp [isExp]) (by simp [hg, hx])
    ((pe_sliceUpdate M K env _ _ _ _ _ rfl (natShape_start n) (natShape_stop1 n) _ _).trans e2) fun g1 i1 h1 => ?_
  unfold kvViewG
  by_cases hc : kvCap cap n = n + 1
  · rw [if_pos hc]
    refine spec_pure_bind ⟨b', h1.mono M K env (by sub_tac), ?_⟩
    have hb : b'.shape = gv.shape := by
      unfold sliceUpdateRange at e2
      split at e2
      · exact (sliceUpdate_spec _ _ _ _ e2).2.1
      · cases e2
    obtain ⟨vd, vs, vg⟩ := slice_spec _ _ _ _ e3
    have hvs : view.shape = [1, 4, n + 1, 256] := by rw [vs]; rfl
    have hbs : b'.shape = [1, 4, n + 1, 256] := by rw [hb, hgs, hc]
    refine ⟨vd.symm, hbs.trans hvs.symm, fun idx hi => ?_⟩
    rw [hbs] at hi
    match idx, hi with
    | [a, b, c, d], hi =>
      rw [vg [a, b, c, d] (by rw [hvs]; exact hi)]
      simp
  · rw [if_neg hc]
    exact spec_step M K env h1 (by simp [isExp]) (by simp)
      ((pe_slice M K env _ _ _ _ _ rfl (natShape_D _) (natShape_stop1 n) _).trans e3)
      fun g2 i2 h2 => ⟨view, h2.mono M K env (by sub_tac), SameIn.refl _⟩

theorem kvStep_of_grow (n : Nat) (cap : Option Nat) (key : κ) (g : List (RNode Int κ)) (fs : List (Nat × Value))
    (x : Nat) (kv : Value) (hx : (x, kv) ∈ fs) (grown b' view : Value) (hgs : grown.shape = [1, 4, kvCap cap n, 256])
    (e2 : sliceUpdateRange grown kv [0, 0, n, 0] [1, 4, n + 1, 256] = some b')
    (e3 : slice b' [0, 0, 0, 0] [1, 4, n + 1, 256] = some view)
    (hgrow : Spec (kvGrowG id n (n : Int) cap key) g
      (fun o g' => ∃ fs', (∀ p ∈ fs, p ∈ fs') ∧ AllEv M K env g' ((o, grown) :: fs'))) :
    Spec (kvStepG id n (n : Int) ((n : Int) + 1) cap key x) g
      (fun o g' => ∃ view', AllEv M K env g' ((o.1, b') :: (o.2, view') :: fs) ∧ SameIn view' view) := by
  unfold kvStepG
  refine spec_seq hgrow fun gi g1 ⟨fs', hsub, h1⟩ => ?_
  refine spec_mono (kvTail_spec M K env n cap g1 _ h1 gi grown (by simp) hgs x kv (by simp [hsub _ hx]) b' view e2 e3)
    fun o g' ⟨v', hv, hs⟩ => ⟨v', hv.mono M K env ?_, hs⟩
  intro p hp
  simp only [List.mem_cons] at hp ⊢
  rcases hp with h | h | h
  · exact Or.inl h
  · exact Or.inr (Or.inl h)
  · exact Or.inr (Or.inr (Or.inr (hsub p h)))

theorem kvStepG_spec (n : Nat) (buf : Option Value) (hb : BufShape buf) (key : κ)
    (hk : ∀ v, buf = some v → env.inputs key = some v) (g : List (RNode Int κ)) (fs : List (Nat × Value))
    (hfs : AllEv M K env g fs) (x : Nat) (kv : Value) (hx : (x, kv) ∈ fs) (b' view : Value)
    (h : GlueKv.step buf n kv = some (b', view)) :
    Spec (kvStepG id n (n : Int) ((n : Int) + 1) (capOf buf) key x) g
      (fun o g' => ∃ view', AllEv M K env g' ((o.1, b') :: (o.2, view') :: fs) ∧ SameIn view' view) := by
  unfold GlueKv.step at h
  cases buf with
  | none =>
    dsimp only at h
    peel h => grown e1
    cases e1
    peel h => b2 e2
    peel h => v3 e3
    have hr : (b2, v3) = (b', view) := Option.some.inj h
    cases hr
    refine kvStep_of_grow M K env n none key g fs x kv hx _ b' view rfl e2 e3 ?_
    unfold kvGrowG
    exact spec_last M K env hfs (by simp [isExp]) .nil (pe_zeros M K env [1, 4, 256, 256] .bfloat16)
      fun g' i h => ⟨fs, fun _ hp => hp, h⟩
  | some bv =>
    have hbs := hb bv rfl
    generalize hcd : bv.shape.getD 2 0 = c at hbs
    have hcd2 : bv.shape[2]?.getD 0 = c := by simpa using hcd
    dsimp only at h
    by_cases hc : c < n + 1
    · have hc' : bv.shape.getD 2 0 < n + 1 := by rw [hcd]; exact hc
      rw [if_pos hc'] at h
      by_cases hm : n % 256 = 0
      · rw [if_pos hm] at h
        peel h => old eo
        cases eo
        peel h => grown e1
        peel h => b2 e2
        peel h => v3 e3
        have hr : (b2, v3) = (b', view) := Option.some.inj h
        cases hr
        have hgs : grown.shape = [1, 4, kvCap (capOf (some bv)) n, 256] := by
          rw [(concatenate_spec _ _ _ _ e1).2.1, hbs]
          simp [kvCap, capOf, hcd2, hc, hm, zeros]
        refine kvStep_of_grow M K env n _ key g fs x kv hx grown b' view hgs e2 e3 ?_
        unfold kvGrowG
        refine spec_inp M K env hfs (hk bv rfl) fun g1 i1 h1 => ?_
        unfold kvGrownG
        rw [if_pos hc']
        unfold kvOldG
        rw [if_pos hm]
        refine spec_pure_bind ?_
        refine spec_step M K env h1 (by simp [isExp]) .nil (pe_zeros M K env [1, 4, 256, 256] .bfloat16)
          fun g2 i2 h2 => ?_
        exact spec_last M K env h2 (by simp [isExp]) (by simp) ((pe_concat M K env _ _ _).trans e1)
          fun g' i h => ⟨_, fun p hp => by simp [hp], h⟩
      · rw [if_neg hm] at h
        peel h => old eo
        peel h => grown e1
        peel h => b2 e2
        peel h => v3 e3
        have hr : (b2, v3) = (b', view) := Option.some.inj h
        cases hr
        have hos := (slice_spec _ _ _ _ eo).2.1
        have hgs : grown.shape = [1, 4, kvCap (capOf (some bv)) n, 256] := by
          rw [(concatenate_spec _ _ _ _ e1).2.1, hos]
          simp [kvCap, capOf, hcd2, hc, hm, zeros]
        refine kvStep_of_grow M K env n _ key g fs x kv hx grown b' view hgs e2 e3 ?_
        unfold kvGrowG
        refine spec_inp M K env hfs (hk bv rfl) fun g1 i1 h1 => ?_
        unfold kvGrownG
        rw [if_pos hc']
        unfold kvOldG
        rw [if_neg hm]
        refine spec_step M K env h1 (by simp [isExp]) (by simp)
          ((pe_slice M K env _ _ _ _ _ rfl (natShape_D _) (natShape_stop n) _).trans eo) fun g2 i2 h2 => ?_
        refine spec_step M K env h2 (by simp [isExp]) .nil (pe_zeros M K env [1, 4, 256, 256] .bfloat16)
          fun g3 i3 h3 => ?_
        exact spec_last M K env h3 (by simp [isExp]) (by simp) ((pe_concat M K env _ _ _).trans e1)
          fun g' i h => ⟨_, fun p hp => by simp [hp], h⟩
    · have hc' : ¬ bv.shape.getD 2 0 < n + 1 := by rw [hcd]; exact hc
      rw [if_neg hc'] at h
      peel h => grown e1
      cases e1
      peel h => b2 e2
      peel h => v3 e3
      have hr : (b2, v3) = (b', view) := Option.some.inj h
      cases hr
      have hgs : bv.shape = [1, 4, kvCap (capOf (some bv)) n, 256] := by
        rw [hbs]; simp [kvCap, capOf, hcd2, hc]
      refine kvStep_of_grow M K env n _ key g fs x kv hx bv b' view hgs e2 e3 ?_
      unfold kvGrowG
      refine spec_inp M K env hfs (hk bv rfl) fun g1 i1 h1 => ?_
      unfold kvGrownG
      rw [if_neg hc']
      exact ⟨_, fun p hp => by simp [hp], h1⟩

theorem pe_sdpa_same (q k k' v v' attn : Value) (hk : SameIn k' k) (hv : SameIn v' v)
    (h : sdpa M q k v (f32 0x3d800000) = some attn) :
    primEval M K env (.sdpa 0x3d800000 []) [q, k', v'] = some attn := by
  rw [pe_sdpa, sdpa_congr M q k k' v v' _ hk hv, h]

set_option maxHeartbeats 4000000 in
theorem attentionG_spec (n : Nat) (w : AttentionWeights) (kb vb : Option Value) (hkb : BufShape kb)
    (hvb : BufShape vb) (key : SKey → κ) (hkey : ∀ k, env.inputs (key k) = attnInput w kb vb k)
    (hqn : w.qNorm.shape = [256]) (hkn : w.kNorm.shape = [256])
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs) (qp kp vp : Nat)
    (qv kv vv : Value) (hqp : (qp, qv) ∈ fs) (hkp : (kp, kv) ∈ fs) (hvp : (vp, vv) ∈ fs)
    (go ko vo : Value) (h : GlueAttention.attentionTrace M qv kv vv w.qNorm w.kNorm kb vb n = some (go, ko, vo)) :
    Spec (attentionG id n (n : Int) ((n : Int) + 1) (attnLayout w kb vb) key qp kp vp) g
      (fun o g' => AllEv M K env g' ((o.1, go) :: (o.2.1, ko) :: (o.2.2, vo) :: fs)) := by
  unfold GlueAttention.attentionTrace at h
  peel h => qpr e1
  peel h => qh e2
  peel h => gh e3
  peel h => gate e4
  peel h => kr e5
  peel h => vr e6
  peel h => qn e7
  peel h => qt e8
  peel h => kn e9
  peel h => kt e10
  peel h => vt e11
  peel h => q e12
  peel h => k e13
  peel h => r14 e14
  obtain ⟨kb2, keys⟩ := r14
  dsimp only at h
  peel h => r15 e15
  obtain ⟨vb2, values⟩ := r15
  dsimp only at h
  peel h => attn e16
  peel h => attnT e17
  peel h => merged e18
  peel h => sig e19
  peel h => gated e20
  have hr : (gated, kb2, vb2) = (go, ko, vo) := Option.some.inj h
  cases hr
  unfold attentionG
  refine spec_step M K env hfs (by simp [isExp]) (by simp [hqp]) ((pe_reshape M K env _ _).trans e1)
    fun g1 i1 h1 => ?_
  refine spec_step M K env h1 (by simp [isExp]) (by simp)
    ((pe_slice M K env _ _ _ _ _ rfl (natShape_D _) (natShape_D _) _).trans e2) fun g2 i2 h2 => ?_
  refine spec_step M K env h2 (by simp [isExp]) (by simp)
    ((pe_slice M K env _ _ _ _ _ rfl (natShape_D _) (natShape_D _) _).trans e3) fun g3 i3 h3 => ?_
  refine spec_step M K env h3 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e4) fun g4 i4 h4 => ?_
  refine spec_step M K env h4 (by simp [isExp]) (by simp [hkp]) ((pe_reshape M K env _ _).trans e5)
    fun g5 i5 h5 => ?_
  refine spec_step M K env h5 (by simp [isExp]) (by simp [hvp]) ((pe_reshape M K env _ _).trans e6)
    fun g6 i6 h6 => ?_
  refine spec_seq (normG_spec M K env (key .qNorm) w.qNorm (hkey .qNorm) M.headNorm (normPlatform_head M _ hqn)
    g6 _ h6 i2 qh (by simp) qn e7) fun i7 g7 h7 => ?_
  refine spec_step M K env h7 (by simp [isExp]) (by simp) ((pe_transpose M K env _ _).trans e8) fun g8 i8 h8 => ?_
  refine spec_seq (normG_spec M K env (key .kNorm) w.kNorm (hkey .kNorm) M.headNorm (normPlatform_head M _ hkn)
    g8 _ h8 i5 kr (by simp) kn e9) fun i9 g9 h9 => ?_
  refine spec_step M K env h9 (by simp [isExp]) (by simp) ((pe_transpose M K env _ _).trans e10) fun g10 i10 h10 => ?_
  refine spec_step M K env h10 (by simp [isExp]) (by simp) ((pe_transpose M K env _ _).trans e11)
    fun g11 i11 h11 => ?_
  refine spec_step M K env h11 (by simp [isExp]) (by simp) ((pe_rope M K env _ _).trans e12) fun g12 i12 h12 => ?_
  refine spec_step M K env h12 (by simp [isExp]) (by simp) ((pe_rope M K env _ _).trans e13) fun g13 i13 h13 => ?_
  refine spec_seq (kvStepG_spec M K env n kb hkb (key (.cache 0)) (fun v hv => by rw [hkey]; simp [attnInput, hv])
    g13 _ h13 i13 k (by simp) ko keys e14) fun ⟨bk, wk⟩ g14 ⟨vk, h14, sk⟩ => ?_
  dsimp only
  refine spec_seq (kvStepG_spec M K env n vb hvb (key (.cache 1)) (fun v hv => by rw [hkey]; simp [attnInput, hv])
    g14 _ h14 i11 vt (by simp) vo values e15) fun ⟨bv, wv⟩ g15 ⟨vv', h15, sv⟩ => ?_
  dsimp only
  refine spec_step M K env h15 (by simp [isExp]) (by simp) (pe_sdpa_same M K env _ _ _ _ _ _ sk sv e16)
    fun g16 i16 h16 => ?_
  refine spec_step M K env h16 (by simp [isExp]) (by simp) ((pe_transpose M K env _ _).trans e17)
    fun g17 i17 h17 => ?_
  refine spec_step M K env h17 (by simp [isExp]) (by simp) ((pe_reshapeInfer M K env _).trans e18)
    fun g18 i18 h18 => ?_
  refine spec_step M K env h18 (by simp [isExp]) (by simp) ((pe_sigmoid M K env _).trans e19) fun g19 i19 h19 => ?_
  refine spec_step M K env h19 (by simp [isExp]) (by simp) ((pe_multiply M K env _ _).trans e20)
    fun g20 i20 h20 => ?_
  exact spec_pure (h20.mono M K env (by sub_tac))

theorem attentionLayerG_spec (n : Nat) (w : AttentionWeights) (kb vb : Option Value) (hkb : BufShape kb)
    (hvb : BufShape vb) (key : SKey → κ) (hkey : ∀ k, env.inputs (key k) = attnInput w kb vb k)
    (hin : w.inputNorm.shape = [5120]) (hqn : w.qNorm.shape = [256]) (hkn : w.kNorm.shape = [256])
    (g : List (RNode Int κ)) (fs : List (Nat × Value)) (hfs : AllEv M K env g fs) (x : Nat) (xv : Value)
    (hx : (x, xv) ∈ fs) (out ko vo : Value) (h : attentionLayerTrace M K w kb vb n xv = some (out, ko, vo)) :
    Spec (attentionLayerG id n (n : Int) ((n : Int) + 1) (attnLayout w kb vb) key x) g
      (fun o g' => AllEv M K env g' ((o.1, out) :: (o.2.1, ko) :: (o.2.2, vo) :: fs)) := by
  unfold attentionLayerTrace at h
  peel h => normed e1
  peel h => qp e2
  peel h => kp e3
  peel h => vp e4
  peel h => r e5
  obtain ⟨gated, kb2, vb2⟩ := r
  dsimp only at h
  peel h => mixed e6
  peel h => o e7
  have hr : (o, kb2, vb2) = (out, ko, vo) := Option.some.inj h
  cases hr
  unfold attentionLayerG
  refine spec_seq (normG_spec M K env (key .inputNorm) w.inputNorm (hkey .inputNorm) M.hiddenNorm
    (normPlatform_hidden M _ hin) g fs hfs x xv hx normed e1) fun i1 g1 h1 => ?_
  refine spec_seq (projectG_spec M K env w.qKind w.q (key ∘ .lin 0) (fun l => hkey (.lin 0 l)) g1 _ h1 i1 normed
    (by simp) qp e2) fun i2 g2 h2 => ?_
  refine spec_seq (projectG_spec M K env w.kKind w.k (key ∘ .lin 1) (fun l => hkey (.lin 1 l)) g2 _ h2 i1 normed
    (by simp) kp e3) fun i3 g3 h3 => ?_
  refine spec_seq (projectG_spec M K env w.vKind w.v (key ∘ .lin 2) (fun l => hkey (.lin 2 l)) g3 _ h3 i1 normed
    (by simp) vp e4) fun i4 g4 h4 => ?_
  refine spec_seq (attentionG_spec M K env n w kb vb hkb hvb key hkey hqn hkn g4 _ h4 i2 i3 i4 qp kp vp
    (by simp) (by simp) (by simp) gated ko vo e5) fun ⟨a1, a2, a3⟩ g5 h5 => ?_
  dsimp only
  refine spec_seq (projectG_spec M K env w.oKind w.o (key ∘ .lin 3) (fun l => hkey (.lin 3 l)) g5 _ h5 a1 gated
    (by simp) mixed e6) fun i6 g6 h6 => ?_
  refine spec_seq (suffixG_spec M K env w.mlp (key ∘ .mlp) (fun m => hkey (.mlp m)) g6 _ h6 x i6 xv mixed
    (by simp [hx]) (by simp) out e7) fun i7 g7 h7 => ?_
  exact spec_pure (h7.mono M K env (by sub_tac))

/-! ### Stages, the chain and the step -/

/-- The two cache values a stage leaves. -/
def handleVals : Handles → Option (Value × Value)
  | .delta (some a) (some b) => some (a, b)
  | .attention (some a) (some b) => some (a, b)
  | _ => none

/-- The norm weights and cache buffers have the route's shapes. -/
def StageShapes : StageWeights → Handles → Prop
  | .delta w, _ => w.inputNorm.shape = [5120]
  | .attention w, .attention kb vb =>
    w.inputNorm.shape = [5120] ∧ w.qNorm.shape = [256] ∧ w.kNorm.shape = [256] ∧ BufShape kb ∧ BufShape vb
  | .attention _, _ => True

def ShapesOk : List StageWeights → List Handles → Prop
  | s :: ss, h :: hs => StageShapes s h ∧ ShapesOk ss hs
  | _, _ => True

/-- Cache output nodes paired with the cache values. -/
def cacheFacts : List (Nat × Nat) → List Handles → List (Nat × Value)
  | c :: cs, h :: hs => (match handleVals h with
    | some (a, b) => [(c.1, a), (c.2, b)]
    | none => []) ++ cacheFacts cs hs
  | _, _ => []

theorem stageG_spec (n : Nat) (s : StageWeights) (hd : Handles) (hsh : StageShapes s hd) (key : SKey → κ)
    (hkey : ∀ k, env.inputs (key k) = stageInput s hd k) (g : List (RNode Int κ)) (fs : List (Nat × Value))
    (hfs : AllEv M K env g fs) (x : Nat) (xv : Value) (hx : (x, xv) ∈ fs) (y : Value) (h' : Handles)
    (h : stageTrace M K n s hd xv = some (y, h')) :
    Spec (stageG id n (n : Int) ((n : Int) + 1) (stageLayout s hd) key x) g
      (fun o g' => ∃ a b, handleVals h' = some (a, b) ∧ AllEv M K env g' ((o.1, y) :: (o.2.1, a) :: (o.2.2, b) :: fs)) := by
  cases s with
  | delta w =>
    cases hd with
    | delta conv rec =>
      simp only [stageTrace, Option.map_eq_some_iff] at h
      obtain ⟨⟨out, tail, st⟩, e, he⟩ := h
      simp only [Prod.mk.injEq] at he
      obtain ⟨rfl, rfl⟩ := he
      exact spec_mono (deltaLayerG_spec M K env w conv rec key hkey hsh g fs hfs x xv hx out tail st e)
        fun o g' h => ⟨tail, st, rfl, h⟩
    | attention _ _ => simp [stageTrace] at h
  | attention w =>
    cases hd with
    | attention kb vb =>
      simp only [stageTrace, Option.map_eq_some_iff] at h
      obtain ⟨⟨out, ko, vo⟩, e, he⟩ := h
      simp only [Prod.mk.injEq] at he
      obtain ⟨rfl, rfl⟩ := he
      obtain ⟨hin, hqn, hkn, hkb, hvb⟩ := hsh
      exact spec_mono (attentionLayerG_spec M K env n w kb vb hkb hvb key hkey hin hqn hkn g fs hfs x xv hx out ko vo e)
        fun o g' h => ⟨ko, vo, rfl, h⟩
    | delta _ _ => simp [stageTrace] at h

/-- Chain position `p + i` reads stage `i`'s inputs. -/
def StagesIn (key : InKey → κ) (p : Nat) (ss : List StageWeights) (hs : List Handles) : Prop :=
  ∀ i k, env.inputs (key (.stage (p + i) k)) = match ss[i]?, hs[i]? with
    | some s, some h => stageInput s h k
    | _, _ => none

theorem chainG_spec (n : Nat) (key : InKey → κ) : ∀ (ss : List StageWeights) (hs : List Handles) (p : Nat)
    (g : List (RNode Int κ)) (fs : List (Nat × Value)), AllEv M K env g fs → StagesIn env key p ss hs →
    ShapesOk ss hs → ∀ (x : Nat) (xv : Value), (x, xv) ∈ fs → ∀ (y : Value) (hs' : List Handles),
    chainTrace M K n ss hs xv = some (y, hs') →
    Spec (chainG id n (n : Int) ((n : Int) + 1) key p (chainLayout ss hs) x) g
      (fun o g' => o.2.length = hs'.length ∧ (∀ h ∈ hs', (handleVals h).isSome) ∧
        AllEv M K env g' ((o.1, y) :: cacheFacts o.2 hs' ++ fs)) := by
  intro ss
  induction ss with
  | nil =>
    intro hs p g fs hfs _ _ x xv hx y hs' h
    cases hs with
    | cons _ _ => simp [chainTrace] at h
    | nil =>
      simp only [chainTrace, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine spec_pure ⟨rfl, by simp, ?_⟩
      exact AllEv.cons M K env hfs x xv (hfs _ hx)
  | cons s ss ih =>
    intro hs p g fs hfs hst hsh x xv hx y hs' h
    cases hs with
    | nil => simp [chainTrace] at h
    | cons hd hs =>
      simp only [chainTrace] at h
      peel h => r e1
      peel h => t e2
      have hr : (t.1, r.2 :: t.2) = (y, hs') := Option.some.inj h
      cases hr
      obtain ⟨r1, r2⟩ := r
      obtain ⟨t1, t2⟩ := t
      have hk0 : ∀ k, env.inputs (key (.stage p k)) = stageInput s hd k := fun k => by
        simpa using hst 0 k
      have hst' : StagesIn env key (p + 1) ss hs := fun i k => by
        have := hst (i + 1) k
        rw [show p + (i + 1) = p + 1 + i by omega] at this
        simpa using this
      unfold chainG
      refine spec_seq (stageG_spec M K env n s hd hsh.1 (fun k => key (.stage p k)) hk0 g fs hfs x xv hx r1 r2 e1)
        fun ⟨y1, c1, c2⟩ g1 ⟨a, b, hab, h1⟩ => ?_
      dsimp only
      refine spec_seq (ih hs (p + 1) g1 _ h1 hst' hsh.2 y1 r1 (by simp) t1 t2 e2) fun ⟨z, cs⟩ g2 ⟨hl, hsome, h2⟩ => ?_
      dsimp only
      refine spec_pure ⟨by simp [hl], ?_, ?_⟩
      · intro h hm
        rcases List.mem_cons.mp hm with rfl | hm
        · simp [hab]
        · exact hsome h hm
      · refine h2.mono M K env ?_
        intro q hq
        simp only [cacheFacts, hab, List.mem_cons, List.mem_append] at hq ⊢
        tauto

theorem stepG_spec (n : Nat) (w : PipelineWeights) (token : Nat) (hs : List Handles) (key : InKey → κ)
    (hkey : ∀ k, env.inputs (key k) = stepInputs w token hs k) (hfn : w.finalNorm.shape = [5120])
    (hsh : ShapesOk (stageWeights w) hs) (t : Nat) (hs' : List Handles)
    (h : stepTrace M K w n token hs = some (t, hs')) :
    Spec (stepG id n (n : Int) ((n : Int) + 1) key (chainLayout (stageWeights w) hs) (linLayout .affineRow w.head)) []
      (fun o g' => (∃ r, EvA M K env g' o.1 r ∧ itemUint32 r = some t) ∧ o.2.length = hs'.length ∧
        (∀ h ∈ hs', (handleVals h).isSome) ∧ AllEv M K env g' (cacheFacts o.2 hs')) := by
  unfold stepTrace at h
  peel h => x e1
  peel h => r2 e2
  obtain ⟨y, hs2⟩ := r2
  dsimp only at h
  peel h => hn e3
  peel h => logits e4
  peel h => l e5
  peel h => l6 e6
  split at h <;> [skip; exact absurd h (by simp)]
  rename_i r
  peel h => t7 e7
  have hr : (t7, hs2) = (t, hs') := Option.some.inj h
  cases hr
  simp only [KernelClosure.eval] at e6
  peel e6 => sv e61
  peel e6 => pair e62
  split at e6 <;> [skip; exact absurd e6 (by simp)]
  rename_i values indices
  peel e6 => out e63
  split at e6 <;> [skip; exact absurd e6 (by simp)]
  rename_i tok
  obtain ⟨r', e64, he⟩ := Option.map_eq_some_iff.mp e6
  have hrr : r' = r := by simpa using he
  subst hrr
  have hfs0 : AllEv M K env ([] : List (RNode Int κ)) [] := fun _ hp => by simp at hp
  unfold stepG
  refine spec_seq (embedG_spec M K env key w.embedWords w.embedScales w.embedBiases token (hkey _) (hkey _)
    (hkey _) (hkey _) [] [] hfs0 x e1) fun i1 g1 h1 => ?_
  have hst : StagesIn env key 0 (stageWeights w) hs := fun i k => by
    rw [hkey]; simp only [stepInputs, Nat.zero_add]
  refine spec_seq (chainG_spec M K env n key (stageWeights w) hs 0 g1 _ h1 hst hsh i1 x (by simp) y hs' e2)
    fun ⟨i2, cs⟩ g2 ⟨hl, hsome, h2⟩ => ?_
  dsimp only
  refine spec_seq (normG_spec M K env (key .finalNorm) w.finalNorm (hkey _) M.hiddenNorm (normPlatform_hidden M _ hfn)
    g2 _ h2 i2 y (by simp) hn e3) fun i3 g3 h3 => ?_
  refine spec_seq (projectG_spec M K env .affineRow w.head (key ∘ .head) (fun l => hkey (.head l)) g3 _ h3 i3 hn
    (by simp) logits e4) fun i4 g4 h4 => ?_
  refine spec_step M K env h4 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e5) fun g5 i5 h5 => ?_
  refine spec_step M K env h5 (by simp [isExp]) (by simp) ((pe_logsumexp M K env _).trans e61) fun g6 i6 h6 => ?_
  refine spec_step M K env h6 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .argmaxPartial) rfl e62 rfl) fun g7 i7 h7 => ?_
  refine spec_step M K env h7 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .argmaxPartial) rfl e62 rfl) fun g8 i8 h8 => ?_
  refine spec_step M K env h8 (by simp [isExp, kern]) (by simp)
    (pe_kernel_some M K env (k := .argmaxFinish) rfl e63 rfl) fun g9 i9 h9 => ?_
  refine spec_step M K env h9 (by simp [isExp]) (by simp) ((pe_reshape M K env _ _).trans e64) fun g10 i10 h10 => ?_
  refine spec_pure ⟨⟨r', h10 (i10, r') (by simp), e7⟩, hl, hsome, h10.mono M K env ?_⟩
  intro q hq
  simp only [List.mem_cons, List.mem_append] at hq ⊢
  tauto

end

/-! ## The bridge -/

section
open Inference Inference.Models.Qwen
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- The step's environment: checkpoint tensors and the step inputs. -/
def stepEnv (weights : List Char → List Char → Option Value) (w : PipelineWeights) (token : Nat) (hs : List Handles) :
    Env InKey := ⟨weights, stepInputs w token hs⟩

/-- The expected graph of the step from `w`, `hs` at offset `n`. -/
def stepGraphOf (w : PipelineWeights) (hs : List Handles) (n : Nat) :
    List (RNode Int InKey) × Nat × List (Nat × Nat) :=
  stepGraph (chainLayout (stageWeights w) hs) (linLayout .affineRow w.head) n

/-- **The expected graph computes the trace.** If `stepTrace` returns the
token `t` and caches `hs'`, the token node of `stepGraph` evaluates to an
array whose `item_uint32` is `t`, and its cache nodes to `hs'`'s arrays. -/
theorem stepGraph_eval (weights : List Char → List Char → Option Value) (w : PipelineWeights) (n token : Nat)
    (hs hs' : List Handles) (t : Nat) (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (h : stepTrace M K w n token hs = some (t, hs')) :
    (∃ r, (stepGraphOf w hs n).2.1 < (stepGraphOf w hs n).1.length ∧
      evalR M K (stepEnv weights w token hs) (listGraph (stepGraphOf w hs n).1) (stepGraphOf w hs n).2.1 = some r ∧
      itemUint32 r = some t) ∧
    (stepGraphOf w hs n).2.2.length = hs'.length ∧ (∀ h ∈ hs', (handleVals h).isSome) ∧
    ∀ q ∈ cacheFacts (stepGraphOf w hs n).2.2 hs', q.1 < (stepGraphOf w hs n).1.length ∧
      evalR M K (stepEnv weights w token hs) (listGraph (stepGraphOf w hs n).1) q.1 = some q.2 := by
  have := stepG_spec M K (stepEnv weights w token hs) n w token hs id (fun _ => rfl) hfn hsh t hs' h
  obtain ⟨⟨r, hr, ht⟩, hl, hsome, hc⟩ := this
  exact ⟨⟨r, hr.1, hr.2, ht⟩, hl, hsome, fun q hq => hc q hq⟩

/-- **The FFI graph computes the trace.** If the FFI state's graph `G`
carries the step's expected graph at `cert` (a decidable check) and the
carriers of its inputs hold the inputs, the FFI token node evaluates to the
trace's token and its cache nodes to the trace's caches. -/
theorem ffi_step (weights : List Char → List Char → Option Value) (w : PipelineWeights) (n token : Nat)
    (hs hs' : List Handles) (t : Nat) (hfn : w.finalNorm.shape = [5120]) (hsh : ShapesOk (stageWeights w) hs)
    (h : stepTrace M K w n token hs = some (t, hs')) (G : Nat → Option (RNode Int InKey)) (cert : List Nat)
    (hm : Matches G (stepGraphOf w hs n).1 cert = true)
    (hin : InputsHeld M K (stepEnv weights w token hs) G (stepGraphOf w hs n).1 cert) :
    (∃ r, evalR M K (stepEnv weights w token hs) G (certAt cert (stepGraphOf w hs n).2.1) = some r ∧
      itemUint32 r = some t) ∧
    ∀ q ∈ cacheFacts (stepGraphOf w hs n).2.2 hs',
      evalR M K (stepEnv weights w token hs) G (certAt cert q.1) = some q.2 := by
  obtain ⟨⟨r, hlt, hr, ht⟩, _, _, hc⟩ := stepGraph_eval M K weights w n token hs hs' t hfn hsh h
  refine ⟨⟨r, ?_, ht⟩, fun q hq => ?_⟩
  · rw [matches_eval M K _ G _ cert hm hin _ hlt]; exact hr
  · obtain ⟨hql, hqv⟩ := hc q hq
    rw [matches_eval M K _ G _ cert hm hin _ hql]; exact hqv

/-! ### The FFI model's state -/

/-- `evalNode`: the value of FFI node `i` of state `s`, its numbers read
through the run's number valuation `ν`. -/
noncomputable def evalNode (ν : Host.Ts.NumV → Option Host.Ts.F64) (env : Env InKey) (s : Ffi.St) (i : Nat) :
    Option Value :=
  evalR M K env (ffiGraph (concrete ν) s) i

/-- The token `mlx_array_item_uint32` reads from array handle `h`. -/
noncomputable def itemOf (ν : Host.Ts.NumV → Option Host.Ts.F64) (env : Env InKey) (s : Ffi.St) (h : Nat) :
    Option Nat :=
  ((s.nodeId? h).bind (evalNode M K ν env s)).bind itemUint32

/-- **Compositionality.** A node an FFI call added (primitive `p` over
argument nodes of smaller id, not compute_g's traced root) evaluates to the
primitive's value semantics on the arguments' values. -/
theorem evalNode_call (ν : Host.Ts.NumV → Option Host.Ts.F64) (env : Env InKey) (s : Ffi.St) (i : Nat)
    (nd : Node) (hn : s.nodes.get i = some nd) (r : RNode Int InKey) (hr : resolveNode (concrete ν) nd = some r)
    (hx : isExp r.prim = false) (hlt : ∀ j ∈ r.ins, j < i) :
    evalNode M K ν env s i = (r.ins.mapM (evalNode M K ν env s)).bind (primEval M K env r.prim) := by
  have hg : ffiGraph (concrete ν) s i = some r := by simp [ffiGraph, hn, hr]
  unfold evalNode
  rw [evalR_eq, hg, cgLeaves_none _ _ _ hg (not_exp hx)]
  dsimp only
  rw [mapM_congr' _ _ _ fun j hj => dif_pos (hlt j hj)]

/-! ### Composition with the verified model -/

theorem shapes_of_holds {n : Nat} : ∀ (stages : List DecodeStage.Stage) (ws : List StageWeights) (hs : List Handles)
    (c : DecodeChain.Caches stages n), ChainLoaded M K stages ws → ChainHolds stages hs c → ShapesOk ws hs
  | [], [], [], _, _, _ => trivial
  | [], [], _ :: _, _, _, _ => trivial
  | [], _ :: _, _, _, h, _ => h.elim
  | _ :: _, [], _, _, h, _ => h.elim
  | _ :: _, _ :: _, [], _, _, h => h.elim
  | s :: ss, w :: ws, hd :: hs, c, hl, hh => by
    refine ⟨?_, shapes_of_holds ss ws hs c.2 hl.2 hh.2⟩
    have h1 := hl.1
    have h2 := hh.1
    cases s with
    | delta l =>
      cases w with
      | delta w => exact h1.inputNorm.2.1
      | attention _ => exact h1.elim
    | attention l =>
      cases w with
      | delta _ => exact h1.elim
      | attention w =>
        cases hd with
        | delta _ _ => exact h2.elim
        | attention kb vb =>
          have buf : ∀ (b : Option Value) (rows), GlueKv.State b n rows → BufShape b := by
            intro b rows hb v hv
            subst hv
            obtain ⟨cap, _, hold⟩ := hb
            rw [hold.2.1]
            rfl
          exact ⟨h1.inputNorm.2.1, h1.qNorm.2.1, h1.kNorm.2.1, buf kb _ h2.1, buf vb _ h2.2⟩

/-- **One decode step of the FFI graph on the M1 Max.** Under
`GlueM1Max.contextStep`'s premises, if the FFI state's graph carries the
step's expected graph and its input carriers hold the step inputs (loaded
weights, head scales, carried caches, token ids), the FFI token node's
`item_uint32` is the reached context's next token and the FFI cache nodes
hold arrays that hold the context's next cache. -/
theorem ffi_context_step (p : TokenInference.Pipeline) (w : PipelineWeights) (hl : PipelineLoaded M K p w)
    (parameters : TokenSequenceRanges.Parameters p) (token : Fin 248320) (time : Nat) (supported : time + 1 ≤ 262144)
    (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).cache)
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (cert : List Nat)
    (hm : Matches G (stepGraphOf w hs time).1 cert = true)
    (hin : InputsHeld M K (stepEnv weights w ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).token.val hs)
      G (stepGraphOf w hs time).1 cert) :
    ∃ hs', (∃ r, evalR M K (stepEnv weights w ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).token.val hs)
        G (certAt cert (stepGraphOf w hs time).2.1) = some r ∧
        itemUint32 r = some ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).token.val) ∧
      ChainHolds p.graph.stages hs' ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).cache ∧
      ∀ q ∈ cacheFacts (stepGraphOf w hs time).2.2 hs',
        evalR M K (stepEnv weights w ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).token.val hs)
          G (certAt cert q.1) = some q.2 := by
  obtain ⟨hs', e, h'⟩ := GlueM1Max.contextStep M K p w hl parameters token time supported hs hh
  have hsh := shapes_of_holds M K _ _ _ _ (stages_loaded M K p w hl) hh
  obtain ⟨ht, hc⟩ := ffi_step M K weights w time _ hs hs' _ hl.finalNorm.2.1 hsh e G cert hm hin
  exact ⟨hs', ht, h', hc⟩

end

end Host.Mlx.FfiEval
