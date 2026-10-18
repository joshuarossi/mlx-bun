import host.load.Extract
import host.mlx.FfiEval
namespace Host.Load.Extract
open Host.Mlx.FfiEval Host.Mlx.GlueLayers Host.Mlx.GlueStep Host.Ts

def namedTensor (xs : List (List Char × Tensor)) (n : List Char) : Option Tensor :=
  (xs.find? fun (k, _) => nameEq k n).map Prod.snd

def linearNode (l : Linear) : LinKey → Option Nat
  | .w => some l.words.node
  | .scales => some l.scales.node
  | .biases => l.biases.map Tensor.node

def mlpNode (m : Mlp) : MlpKey → Nat
  | .norm => m.norm.node
  | .gateCodes => m.gate.codes.node
  | .gateScales => m.gate.scales.node
  | .upCodes => m.up.codes.node
  | .upScales => m.up.scales.node
  | .downCodes => m.down.codes.node
  | .downScales => m.down.scales.node

def stageNode (st : Stage) (cache : Cache) : SKey → Option Nat
  | .inputNorm => some st.inputNorm.node
  | .lin j k => (st.linears[j]?).bind fun (_, l) => linearNode l k
  | .conv => (namedTensor st.tensors chars!"convWeight").map Tensor.node
  | .aLog => (namedTensor st.tensors chars!"aLog").map Tensor.node
  | .dtBias => (namedTensor st.tensors chars!"dtBias").map Tensor.node
  | .norm => (namedTensor st.tensors chars!"normWeight").map Tensor.node
  | .qScale => (namedTensor st.tensors chars!"qScale").map Tensor.node
  | .kScale => (namedTensor st.tensors chars!"kScale").map Tensor.node
  | .qNorm => (namedTensor st.tensors chars!"qNorm").map Tensor.node
  | .kNorm => (namedTensor st.tensors chars!"kNorm").map Tensor.node
  | .mlp k => some (mlpNode st.mlp k)
  | .cache 0 => cache.first.map Tensor.node
  | .cache 1 => cache.second.map Tensor.node
  | .cache _ => none

/-- Carrier node ids are read from the loaded model and the current caches.
`token` is the actual array supplied to the decode call. -/
def inputNode (l : Loaded) (token : Tensor) : InKey → Option Nat
  | .tokenIds => some token.node
  | .embedWords => (namedTensor l.model.embedding chars!"w").map Tensor.node
  | .embedScales => (namedTensor l.model.embedding chars!"scales").map Tensor.node
  | .embedBiases => (namedTensor l.model.embedding chars!"biases").map Tensor.node
  | .finalNorm => some l.model.finalNorm.node
  | .head k => linearNode l.model.head k
  | .stage p k => do stageNode (← l.model.stages[p]?) (← l.cache[p]?) k

/-- The operation class is inspected on the actual projection wrapper. -/
def projector (cs : List Char) : Option Projector :=
  bif nameEq cs chars!"QuantizedLinearPlain" then some .plain
  else bif nameEq cs chars!"AffineRowLinear" then some .affineRow
  else none

def dimNat : Host.Mlx.Ffi.Dim → Option Nat
  | .lit (.ofNat n) => some n
  | _ => none

def linearLayout (l : Linear) : Option LinLayout := do
  let p ← projector l.operation
  let rows ← (l.scales.value.shape[0]?).bind dimNat
  let groups ← (l.scales.value.shape[1]?).bind dimNat
  bif l.group == 64 then pure ⟨p, l.bits, rows, groups * 64⟩ else none

def mlpLayout (m : Mlp) : MlpLayout := ⟨m.gate.bits, m.up.bits, m.down.bits⟩

def capacity : Option Tensor → Option (Option Nat)
  | none => some none
  | some t => ((t.value.shape[2]?).bind dimNat).map some

def stageLayout (st : Stage) (cache : Cache) : Option StageLayout := do
  let ls ← st.linears.mapM (fun (_, l) => linearLayout l)
  bif st.attention then
    match ls with
    | [q, k, v, o] => do pure (.attention ⟨q, k, v, o, mlpLayout st.mlp, ← capacity cache.first, ← capacity cache.second⟩)
    | _ => none
  else match ls with
    | [qkv, z, a, b, out] => pure (.delta ⟨qkv, z, a, b, out, mlpLayout st.mlp, cache.first.isSome, cache.second.isSome⟩)
    | _ => none

def layouts (l : Loaded) : Option (List StageLayout) :=
  bif l.model.stages.length == l.cache.length then
    (l.model.stages.zip l.cache).mapM fun (st, c) => stageLayout st c
  else none

end Host.Load.Extract
