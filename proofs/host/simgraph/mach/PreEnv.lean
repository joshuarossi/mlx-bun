import host.simgraph.mach.PreAttn
import host.simgraph.mach.Total
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Mlx.GlueStep
open Host.Mlx.GlueLayers
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)

/-! # A GPU row step's environment is typed

The step environment (`stepEnv`: the decode step's inputs from the handles, the prompt ids, the
dimension-valued data) at a chain position holds the stage's weights and caches: from the weights' types
(`StageTy`, the MLP widths a route pair), the handles' prefill types (`StagePre`: KV buffers at the prefill's
capacity `256·⌈o/256⌉`, `KvPre`) and the step's rows, the stage's environment facts (`DeltaEnv`, `AttnEnv`). -/

/-- A stage's weights for the prefill: typed, the MLP's gate and up widths a route pair. -/
def StageW : StageWeights → Prop
  | .delta w => DeltaTy w ∧ GateUpRoute w.mlp.gateBits w.mlp.upBits
  | .attention w => AttnTy w ∧ GateUpRoute w.mlp.gateBits w.mlp.upBits

/-! ## Projections and MLPs from the weights' types -/

theorem linTy_bits {kind : Projector} {l : Linear} {steps rows : Nat} (h : LinTy kind l steps rows) :
    l.bits = 3 ∨ l.bits = 4 := by
  cases kind
  · exact h.1
  · exact .inr h.1

theorem linTy_affine {l : Linear} {steps rows : Nat} (h : LinTy .affineRow l steps rows) :
    (steps = 10 ∧ rows = 10240) ∨ (steps = 10 ∧ rows = 6144) ∨ (steps = 12 ∧ rows = 5120) ∨
      (steps = 10 ∧ rows = 248320) := by
  obtain ⟨_, _, _, _, blocks, hr, hroute⟩ := h
  rcases KernelGpu.affine_route hroute with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> omega

/-- A projection of `rows` outputs off the head's (not `248320`) is at 4 bits if its rows are not an affine row
route's. -/
theorem linTy_plain4 {kind : Projector} {l : Linear} {steps rows : Nat} (h : LinTy kind l steps rows)
    (hr : rows ≠ 10240 ∧ rows ≠ 6144 ∧ rows ≠ 5120 ∧ rows ≠ 248320) : l.bits = 4 := by
  cases kind
  · rcases linTy_affine h with ⟨_, rfl⟩ | ⟨_, rfl⟩ | ⟨_, rfl⟩ | ⟨_, rfl⟩ <;> simp at hr
  · exact h.1

theorem linOk_of {κ : Type} {env : Env κ} {kind : Projector} {l : Linear} {steps rows : Nat} {key : LinKey → κ}
    (h : LinTy kind l steps rows) (hroute : SplitRoute rows (steps * 512) l.bits)
    (hin : ∀ k, env.inputs (key k) = linGet k l) :
    LinOk env (linLayout kind l) key ∧ (linLayout kind l).rows = rows ∧ (linLayout kind l).cols = steps * 512 := by
  have hw : Ty l.w .uint32 [rows, steps * (16 * l.bits)] := by
    cases kind
    · exact h.2.1
    · rw [h.1]; exact h.2.1
  have hs : Ty l.scales .bfloat16 [rows, steps * 8] := by cases kind; exacts [h.2.2.1, h.2.2.1]
  have hb : Ty l.biases .bfloat16 [rows, steps * 8] := by cases kind; exacts [h.2.2.2.1, h.2.2.2]
  have hrows : (linLayout kind l).rows = rows := by simp [linLayout, hs.2]
  have hcols : (linLayout kind l).cols = steps * 512 := by simp [linLayout, hs.2]; ring
  have hbits : (linLayout kind l).bits = l.bits := rfl
  have e1 : steps * 512 * l.bits / 32 = steps * (16 * l.bits) := by
    rw [show steps * 512 * l.bits = steps * (16 * l.bits) * 32 by ring, Nat.mul_div_cancel _ (by decide)]
  have e2 : steps * 512 / 64 = steps * 8 := by omega
  refine ⟨⟨by rw [hbits]; exact linTy_bits h, by rw [hrows, hcols, hbits]; exact hroute, ?_, ?_, ?_⟩, hrows, hcols⟩
  · exact ⟨l.w, hin .w, hw.1, by rw [hw.2, hrows, hcols, hbits, e1]⟩
  · exact ⟨l.scales, hin .scales, hs.1, by rw [hs.2, hrows, hcols, e2]⟩
  · exact ⟨l.biases, hin .biases, hb.1, by rw [hb.2, hrows, hcols, e2]⟩

theorem mlpOk_of {κ : Type} {env : Env κ} {m : MlpWeights} {key : MlpKey → κ} (h : MlpTy m)
    (hg : GateUpRoute m.gateBits m.upBits) (hin : ∀ k, env.inputs (key k) = mlpGet k m) :
    MlpOk env (mlpLayout m) key where
  route := hg
  downBits := h.downBits
  norm := ⟨_, hin .norm, h.norm⟩
  gateCodes := ⟨_, hin .gateCodes, h.gateCodes⟩
  gateScales := ⟨_, hin .gateScales, h.gateScales⟩
  upCodes := ⟨_, hin .upCodes, h.upCodes⟩
  upScales := ⟨_, hin .upScales, h.upScales⟩
  downCodes := ⟨_, hin .downCodes, h.downCodes⟩
  downScales := ⟨_, hin .downScales, h.downScales⟩

/-! ## The step environment -/

section
variable (weights : List Char → List Char → Option Value) (w : PipelineWeights) (o n : Nat) (ids : Value)
  (hs : List Handles)

theorem stepEnv_stage (p : Nat) {s : StageWeights} {h : Handles} (hws : (stageWeights w)[p]? = some s)
    (hhs : hs[p]? = some h) (k : SKey) :
    (Ref.stepEnv weights w o n ids hs).inputs (stageKey p k) = stageInput s h k := by
  simp [Ref.stepEnv, promptInputs, stageKey, stepInputs, hws, hhs]

theorem cells_ty' (vs shape : List Int) (sh : List Nat) (h : shape = sh.map Int.ofNat) :
    OkV (cellsValue vs shape) fun v => Ty v .int32 sh := by
  subst h; exact cells_ty vs sh

theorem stepEnv_tin (rd : Read) (p : Nat) (hn : n < 2 ^ 32) :
    (Ref.stepEnv weights w o n ids hs).inputs (auxKey refRows rd p 0) = some (tinValue n) := by
  simp only [Ref.stepEnv, promptInputs, auxKey, List.map_cons, List.map_nil, refRows_n]
  exact cells_tin n hn

theorem stepEnv_folded (p : Nat) :
    FoldedEnv (Ref.stepEnv weights w o n ids hs) (auxKey refRows (.folded n) p) o n := by
  constructor
  · simp only [Ref.stepEnv, promptInputs, auxKey]
    exact cells_ty' _ _ _ (by simp [refRows_on])
  · simp only [Ref.stepEnv, promptInputs, auxKey]
    exact cells_ty' _ _ _ (by simp [PDim.eval])

end

/-! ## A stage's environment -/

theorem capL_ge (o : Nat) : o ≤ capL o := by unfold capL; omega

section
variable {κ : Type} (env : Env κ) (o n : Nat) (key : SKey → κ) (aux : Nat → κ)

theorem deltaEnv_of {dw : DeltaWeights} {conv rec : Option Value}
    (hin : ∀ k, env.inputs (key k) = deltaInput dw conv rec k)
    (htin : env.inputs (aux 0) = some (tinValue n)) (hw : StageW (.delta dw))
    (hc : OptTy conv .bfloat16 [1, 3, 10240]) (hr : OptTy rec .float32 [1, 48, 128, 128]) :
    DeltaEnv env key aux (deltaLayout dw conv rec) n := by
  obtain ⟨hw, hg⟩ := hw
  have q := linOk_of (env := env) (key := key ∘ .lin 0) hw.qkv
    (by rcases linTy_bits hw.qkv with h | h <;> rw [h] <;> simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have z := linOk_of (env := env) (key := key ∘ .lin 1) hw.z
    (by rcases linTy_bits hw.z with h | h <;> rw [h] <;> simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have a := linOk_of (env := env) (key := key ∘ .lin 2) hw.a
    (by rw [linTy_plain4 hw.a (by decide)]; simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have b := linOk_of (env := env) (key := key ∘ .lin 3) hw.b
    (by rw [linTy_plain4 hw.b (by decide)]; simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have out := linOk_of (env := env) (key := key ∘ .lin 4) hw.out
    (by rcases linTy_bits hw.out with h | h <;> rw [h] <;> simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  exact {
    inputNorm := ⟨_, hin .inputNorm, hw.inputNorm⟩
    qkv := q.1, z := z.1, a := a.1, b := b.1, out := out.1
    dims := ⟨q.2.1, q.2.2, z.2.1, z.2.2, a.2.1, a.2.2, b.2.1, b.2.2, out.2.1, out.2.2⟩
    conv := ⟨_, hin .conv, hw.conv⟩
    aLog := ⟨_, hin .aLog, hw.aLog⟩
    dtBias := ⟨_, hin .dtBias, hw.dtBias⟩
    norm := ⟨_, hin .norm, hw.norm⟩
    qScale := ⟨_, hin .qScale, hw.qScale⟩
    kScale := ⟨_, hin .kScale, hw.kScale⟩
    mlp := mlpOk_of hw.mlp hg fun k => by rw [Function.comp, hin]; cases k <;> rfl
    cache0 := fun h => by
      obtain ⟨v, rfl⟩ := Option.isSome_iff_exists.mp h
      exact ⟨v, hin (.cache 0), hc v rfl⟩
    cache1 := fun h => by
      obtain ⟨v, rfl⟩ := Option.isSome_iff_exists.mp h
      exact ⟨v, hin (.cache 1), hr v rfl⟩
    tin := htin }

theorem attnEnv_of (rd : Read) {aw : AttentionWeights} {kb vb : Option Value}
    (hin : ∀ k, env.inputs (key k) = attnInput aw kb vb k)
    (hrd : ∀ r, rd = .folded r → r = n ∧ 6 ≤ n ∧ FoldedEnv env aux o n)
    (hw : StageW (.attention aw)) (hk : KvPre o kb) (hv : KvPre o vb) :
    AttnEnv env key aux (attnLayout aw kb vb) rd o n := by
  obtain ⟨hw, hg⟩ := hw
  have q := linOk_of (env := env) (key := key ∘ .lin 0) hw.q
    (by rw [linTy_plain4 hw.q (by decide)]; simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have k := linOk_of (env := env) (key := key ∘ .lin 1) hw.k
    (by rw [linTy_plain4 hw.k (by decide)]; simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have v := linOk_of (env := env) (key := key ∘ .lin 2) hw.v
    (by rw [linTy_plain4 hw.v (by decide)]; simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have out := linOk_of (env := env) (key := key ∘ .lin 3) hw.o
    (by rcases linTy_bits hw.o with h | h <;> rw [h] <;> simp [SplitRoute]) fun k => by rw [Function.comp, hin]; cases k <;> rfl
  have hbuf : ∀ {b : Option Value} (j : Nat), KvPre o b → env.inputs (key (.cache j)) = b →
      ((capOf b = none → o = 0) ∧ ∀ c, capOf b = some c → o ≤ c ∧
        OkV (env.inputs (key (.cache j))) fun u => Ty u .bfloat16 [1, 4, c, 256]) := by
    intro b j hb he
    cases b with
    | none => exact ⟨fun _ => hb, fun c h => (nomatch h)⟩
    | some u =>
      refine ⟨fun h => (nomatch h), fun c hc => ?_⟩
      have hcu : c = capL o := by
        simp only [capOf, Option.map_some, Option.some.injEq] at hc
        rw [← hc, hb.2.2]; rfl
      subst hcu
      exact ⟨capL_ge o, u, he, hb.2⟩
  have kk := hbuf 0 hk (hin (.cache 0))
  have vv := hbuf 1 hv (hin (.cache 1))
  exact {
    inputNorm := ⟨_, hin .inputNorm, hw.inputNorm⟩
    q := q.1, k := k.1, v := v.1, out := out.1
    dims := ⟨q.2.1, q.2.2, k.2.1, k.2.2, v.2.1, v.2.2, out.2.1, out.2.2⟩
    qNorm := ⟨_, hin .qNorm, hw.qNorm⟩
    kNorm := ⟨_, hin .kNorm, hw.kNorm⟩
    mlp := mlpOk_of hw.mlp hg fun k => by rw [Function.comp, hin]; cases k <;> rfl
    knone := kk.1, kbuf := kk.2, vnone := vv.1, vbuf := vv.2
    read := hrd }

end

end Host.Mlx.SimGraph.Mach
