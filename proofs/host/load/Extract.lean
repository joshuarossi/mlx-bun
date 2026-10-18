import host.load.World
import host.ts.Harness
namespace Host.Load.Extract
open Host.Ts

/-! Read-only projections of the objects the source loader constructed. The
functions execute no getters or methods: a missing field, ambiguous private
name, non-array handle, or absent graph node makes extraction fail. Concrete
summaries are checked against the final load state by kernel reduction. -/

def object (s : St LSt) : Val → Option Obj
  | .obj a => s.obj? a
  | _ => none

def data : PropV → Option Val
  | .data v _ _ => some v
  | _ => none

def own (s : St LSt) (v : Val) (n : List Char) : Option Val :=
  (object s v).bind fun o => (findProp (.str n) o.props).bind data

/-- Private fields carry a brand; names are accepted only when unique. -/
def privateField (s : St LSt) (v : Val) (n : List Char) : Option Val := do
  let o ← object s v
  let [(_, p)] := o.priv.filter (fun ((_, k), _) => nameEq n k) | none
  data p

def elements (s : St LSt) (v : Val) : Option (List Val) := do
  let o ← object s v
  match o.kind with | .array es => some es | _ => none

def closureBinding (s : St LSt) (v : Val) (n : List Char) : Option Val := do
  let o ← object s v
  match o.kind with
  | .fn (.closure _ env _ _) => bindingOf s env n
  | _ => none

/-- A named class constructor keeps its self binding first in its class
scope. Check that binding points back to the actual prototype constructor;
this does not depend on an unmodelled Function.name property. -/
def className (s : St LSt) (v : Val) : Option (List Char) := do
  let o ← object s v
  let .obj c ← own s o.proto chars!"constructor" | none
  let co ← s.obj? c
  match co.kind with
  | .fn (.klass _ ((n, cell) :: _) _ _) => match s.cell? cell with
    | some (some (.obj d)) => bif Nat.beq c d then some n else none
    | _ => none
  | _ => none

def nat : Val → Option Nat
  | .big (.ofNat n) => some n
  | .num (.lit x) => F64.toIndex? x
  | _ => none

structure Tensor where
  handle : Nat
  node : Nat
  value : Host.Mlx.Ffi.Node

/-- The actual MLX array handle and producing graph node. -/
def tensor (s : St LSt) (v : Val) : Option Tensor := do
  let h ← (privateField s v chars!"handle").bind nat
  let i ← s.ffi.mlx.nodeId? h
  let nd ← s.ffi.mlx.nodes.get i
  pure ⟨h, i, nd⟩

def fieldTensor (s : St LSt) (v : Val) (n : List Char) : Option Tensor := (own s v n).bind (tensor s)
def norm (s : St LSt) (v : Val) : Option Tensor := fieldTensor s v chars!"weight"

structure Linear where
  operation : List Char
  words : Tensor
  scales : Tensor
  biases : Option Tensor
  bits : Nat
  group : Nat
  mode : List Char

def optionalTensor (s : St LSt) : Val → Option (Option Tensor)
  | .null => some none
  | v => (tensor s v).map some

/-- QuantizedLinear's stored fields, without invoking its public getters. -/
def quantized (s : St LSt) (v : Val) (operation : List Char) : Option Linear := do
  let w ← fieldTensor s v chars!"_w"
  let sc ← fieldTensor s v chars!"_scales"
  let b ← (own s v chars!"_biases").bind (optionalTensor s)
  let spec ← own s v chars!"_spec"
  let bits ← (own s spec chars!"bits").bind nat
  let group ← (own s spec chars!"groupSize").bind nat
  let .str mode ← own s spec chars!"mode" | none
  pure ⟨operation, w, sc, b, bits, group, mode⟩

def projection (s : St LSt) (v : Val) : Option Linear := do
  let cls ← className s v
  let q ← (own s v chars!"base").orElse fun _ => own s v chars!"linear"
  quantized s q cls

structure Trellis where
  codes : Tensor
  scales : Tensor
  bits : Nat

def trellis (s : St LSt) (v : Val) : Option Trellis := do
  let codes ← fieldTensor s v chars!"codes"
  let scales ← fieldTensor s v chars!"scales"
  let spec ← own s v chars!"spec"
  let bits ← (own s spec chars!"bits").bind nat
  pure ⟨codes, scales, bits⟩

structure Mlp where
  norm : Tensor
  gate : Trellis
  up : Trellis
  down : Trellis
  gateOperation : List Char
  downOperation : List Char

/-- The unadapted LoraOperation closure captures the actual GateDownMLP as `plain`. -/
def mlp (s : St LSt) (layer : Val) : Option Mlp := do
  let n ← (own s layer chars!"postAttnNorm").bind (norm s)
  let op ← own s layer chars!"mlp"
  let f ← privateField s op chars!"forward"
  let plain ← closureBinding s f chars!"plain"
  let gu ← own s plain chars!"gateUp"
  let dn ← own s plain chars!"down"
  let g ← (own s gu chars!"gate").bind (trellis s)
  let u ← (own s gu chars!"up").bind (trellis s)
  let d ← (own s dn chars!"down").bind (trellis s)
  pure ⟨n, g, u, d, ← className s gu, ← className s dn⟩

structure Stage where
  attention : Bool
  layerOperation : List Char
  mixerOperation : List Char
  inputNorm : Tensor
  linears : List (List Char × Linear)
  tensors : List (List Char × Tensor)
  mlp : Mlp

def stage (s : St LSt) (v : Val) : Option Stage := do
  let mixer ← own s v chars!"mixer"
  let attn := (own s mixer chars!"qProj").isSome
  let ps := bif attn then [chars!"qProj", chars!"kProj", chars!"vProj", chars!"oProj"]
    else [chars!"inProjQkv", chars!"inProjZ", chars!"inProjA", chars!"inProjB", chars!"outProj"]
  let linears ← ps.mapM fun n => ((own s mixer n).bind (projection s)).map (n, ·)
  let ts ← bif attn then
      [chars!"qNorm", chars!"kNorm"].mapM fun n => ((own s mixer n).bind (norm s)).map (n, ·)
    else do
      let ts ← [chars!"convWeight", chars!"aLog", chars!"dtBias", chars!"normWeight"].mapM fun n => (fieldTensor s mixer n).map (n, ·)
      let qk ← own s mixer chars!"qkScale"
      let q ← fieldTensor s qk chars!"q"
      let k ← fieldTensor s qk chars!"k"
      pure (ts ++ [(chars!"qScale", q), (chars!"kScale", k)])
  pure ⟨attn, ← className s v, ← className s mixer, ← (own s v chars!"inputNorm").bind (norm s), linears, ts, ← mlp s v⟩

structure Model where
  embedding : List (List Char × Tensor)
  finalNorm : Tensor
  head : Linear
  stages : List Stage

def model (s : St LSt) (v : Val) : Option Model := do
  let e ← own s v chars!"embed"
  let embedding ← [chars!"w", chars!"scales", chars!"biases"].mapM fun n => (fieldTensor s e n).map (n, ·)
  let f ← (own s v chars!"finalNorm").bind (norm s)
  let logits ← own s v chars!"logits"
  let h1 ← own s logits chars!"1"
  let rowHead ← closureBinding s h1 chars!"rowHead"
  let one ← (privateField s v chars!"one").bind (elements s)
  pure ⟨embedding, f, ← projection s rowHead, ← one.mapM (stage s)⟩

structure Cache where
  operation : List Char
  offset : Nat
  first : Option Tensor
  second : Option Tensor

def cache (s : St LSt) (v : Val) : Option Cache := do
  let cls ← className s v
  let off ← (own s v chars!"offset").bind nat
  let first ← ((privateField s v chars!"conv").orElse fun _ => own s v chars!"keys").bind (optionalTensor s)
  let second ← ((privateField s v chars!"recurrent").orElse fun _ => own s v chars!"values").bind (optionalTensor s)
  pure ⟨cls, off, first, second⟩

structure Loaded where
  model : Model
  cache : List Cache

/-- Entry bindings use the initial linked entry environment, retained after halt. -/
def loaded (s : St LSt) (env : Env) : Option Loaded := do
  let m ← (bindingOf s env chars!"model").bind (model s)
  let cs ← ((bindingOf s env chars!"cache").bind (elements s)).bind (List.mapM (cache s))
  pure ⟨m, cs⟩

/-- Array nodes which are directly checkpoint loads, retaining the declared
file, key, dimensions and dtype from the actual load state. Derived nodes
remain explicit in `Tensor.value` and are evaluated by `FfiEval`. -/
def checkpoint (t : Tensor) : Option (List Char × List Char × List Host.Mlx.Ffi.Dim × Nat) :=
  match t.value.prim with
  | .load f k => some (f, k, t.value.shape, t.value.dtype)
  | _ => none

end Host.Load.Extract
