import host.load.Inputs
namespace Host.Load.Extract
open Host.Mlx.GlueLayers Host.Mlx.GlueStep Host.Mlx

/-- Interpret the producing node of each extracted array. Checkpoint payloads
enter through this function; all handles and quantization choices come from
`loaded`, rather than from a separately assembled parameter table. -/
abbrev TensorValues := Tensor → Value

/-- Array contents can be left abstract while their dtype and dimensions are
read from the checked load metadata. The concrete summary checks every
parameter has a supported dtype and literal nonnegative dimensions. A caller
connecting these Values to FFI evaluation must prove that interpretation;
this function alone makes no claim about external payload bytes. -/
def headerValues (contents : Nat → Nat → Nat) (t : Tensor) : Value :=
  ⟨(Dtype.ofCode t.value.dtype).getD .uint8,
    t.value.shape.map (fun d => match d with | .lit n => n.toNat | .sym _ => 0),
    contents t.node⟩

def linearWeights (value : TensorValues) (l : Linear) : Option GlueLayers.Linear := do
  let b ← l.biases
  let _ ← linearLayout l
  bif Host.Ts.nameEq l.mode chars!"affine" then
    pure ⟨value l.words, value l.scales, value b, l.bits⟩
  else none

def mlpWeights (value : TensorValues) (m : Mlp) : GlueLayers.MlpWeights :=
  ⟨value m.norm, value m.gate.codes, value m.gate.scales,
    value m.up.codes, value m.up.scales, value m.down.codes,
    value m.down.scales, m.gate.bits, m.up.bits, m.down.bits⟩

def deltaWeights (value : TensorValues) (s : Stage) : Option GlueLayers.DeltaWeights := do
  bif s.attention then none else do
    let [(_, qkv), (_, z), (_, a), (_, b), (_, out)] := s.linears | none
    let qa ← projector a.operation
    let qb ← projector b.operation
    if qa ≠ .plain ∨ qb ≠ .plain then none else do
      pure ⟨value s.inputNorm, ← linearWeights value qkv, ← linearWeights value z,
        ← linearWeights value a, ← linearWeights value b, ← linearWeights value out,
        ← projector qkv.operation, ← projector z.operation, ← projector out.operation,
        value (← namedTensor s.tensors chars!"convWeight"),
        value (← namedTensor s.tensors chars!"aLog"),
        value (← namedTensor s.tensors chars!"dtBias"),
        value (← namedTensor s.tensors chars!"normWeight"),
        value (← namedTensor s.tensors chars!"qScale"),
        value (← namedTensor s.tensors chars!"kScale"), mlpWeights value s.mlp⟩

def attentionWeights (value : TensorValues) (s : Stage) : Option GlueLayers.AttentionWeights := do
  bif s.attention then do
    let [(_, q), (_, k), (_, v), (_, o)] := s.linears | none
    pure ⟨value s.inputNorm, ← linearWeights value q, ← linearWeights value k,
      ← linearWeights value v, ← linearWeights value o,
      ← projector q.operation, ← projector k.operation, ← projector v.operation, ← projector o.operation,
      value (← namedTensor s.tensors chars!"qNorm"),
      value (← namedTensor s.tensors chars!"kNorm"), mlpWeights value s.mlp⟩
  else none

def deltaPosition (i : Fin 48) : Nat := 4 * (i.val / 3) + i.val % 3
def attentionPosition (i : Fin 16) : Nat := 4 * i.val + 3

/-- Construct all 64 stage weights in the source graph's order. A missing
stage, unexpected stage kind, unsupported projector, missing bias, or
non-affine/group-64 linear makes construction fail explicitly. -/
def pipelineWeights (l : Loaded) (value : TensorValues) : Option GlueStep.PipelineWeights := do
  if l.model.stages.length ≠ 64 then none else do
    let ds ← (List.ofFn deltaPosition).mapM fun p => (l.model.stages[p]?).bind (deltaWeights value)
    let ats ← (List.ofFn attentionPosition).mapM fun p => (l.model.stages[p]?).bind (attentionWeights value)
    if hd : ds.length = 48 then
      if ha : ats.length = 16 then
        pure ⟨value (← namedTensor l.model.embedding chars!"w"),
          value (← namedTensor l.model.embedding chars!"scales"),
          value (← namedTensor l.model.embedding chars!"biases"),
          (fun i => ds.get ⟨i.val, by omega⟩),
          (fun i => ats.get ⟨i.val, by omega⟩), value l.model.finalNorm,
          ← linearWeights value l.model.head⟩
      else none
    else none

end Host.Load.Extract
