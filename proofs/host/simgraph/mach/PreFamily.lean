import host.simgraph.mach.PreEnv
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Mlx.GlueStep
open Host.Mlx.GlueLayers
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n)

/-! # A GPU row family's layers are defined on well-typed handles

`rowTpl refRows pk mk rd` (V23, V4, V58, VW) at the value backend: each layer of the chain, at its stage's
weights and prefill handles (`StageW`, `StagePre o`), on the family's rows (`FamRows`), gives the hidden state
and the stage's new caches at offset `o + n` (`CacheOk`; the KV buffers at the prefill's capacity when the step
grows only at multiples of 256, `kvCapP_ceil`). -/

/-- The projection kind's rows. -/
def ProjRows : ProjKind → Nat → Prop
  | .rows, n => n = 2 ∨ n = 3
  | .split, n => 4 ≤ n ∧ n ≤ 223

/-- The MLP kind's rows. -/
def MlpRows : MlpKind → Nat → Prop
  | .codebook, n => 2 ≤ n ∧ n ≤ 8
  | .wide mt pass, n => 9 ≤ n ∧ n ≤ 223 ∧ mt = Metal.Kernels.GateUpMmaWide.rowBlocks n ∧
      ∀ k, (k = 2 ∨ k = 4) → DownRoute k pass.s pass.mt

/-- A GPU row family's rows. -/
structure FamRows (pk : ProjKind) (mk : MlpKind) (rd : Read) (n : Nat) : Prop where
  proj : ProjRows pk n
  mlp : MlpRows mk n
  read : ∀ r, rd = .folded r → r = n ∧ 6 ≤ n
  lo : 2 ≤ n
  hi : n ≤ 223

/-- A stage's caches after a step to offset `o'`. -/
def CacheOk (o' : Nat) : StageWeights → Value × Value → Prop
  | .delta _, (a, b) => Ty a .bfloat16 [1, 3, 10240] ∧ Ty b .float32 [1, 48, 128, 128]
  | .attention _, (a, b) => Ty a .bfloat16 [1, 4, capL o', 256] ∧ Ty b .bfloat16 [1, 4, capL o', 256]

/-- The step grows the caches only at multiples of 256 (the schedule's appends, `sched_ok`). -/
def Grows (o n : Nat) : Prop := o % 256 = 0 ∨ o + n ≤ capL o

theorem kvCapP_pre {o n : Nat} {b : Option Value} (hb : KvPre o b) (hg : Grows o n) :
    kvCapP (capOf b) o n = capL (o + n) := by
  unfold capL
  apply kvCapP_ceil
  · cases b with
    | none => have : o = 0 := hb; simp [capOf, this]
    | some v =>
      have hv := hb.2.2
      simp [capOf, hv, show o ≠ 0 by have := hb.1; omega, capL]
  · intro c hc hlt
    rcases hg with h | h
    · exact h
    · cases b with
      | none => cases hc
      | some v =>
        have hc' : c = capL o := by
          simp only [capOf, Option.map_some, Option.some.injEq] at hc
          rw [← hc, hb.2.2]; rfl
        omega

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (env : Env PKey) (o n : Nat)

theorem ok_projT (pk : ProjKind) (hpk : ProjRows pk n) (lay : LinLayout) (key : LinKey → PKey) (hl : LinOk env lay key)
    {x : Value} (hx : Ty x .bfloat16 [1, n, lay.cols]) :
    OkV (projT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows pk lay key x)
      fun u => Ty u .bfloat16 [1, n, lay.rows] := by
  cases pk
  · exact ok_rowsProjT P K env o n lay key hl hpk hx
  · exact ok_splitProjT P K env o n lay key hl hpk.1 hpk.2 hx

theorem ok_mlpT (mk : MlpKind) (hmk : MlpRows mk n) (mlay : MlpLayout) (key : MlpKey → PKey)
    (hm : MlpOk env mlay key) {x : Value} (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV (mlpT (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) refRows mk mlay key x)
      fun u => Ty u .bfloat16 [1, n, 5120] := by
  cases mk with
  | codebook => exact ok_codebookMlpT P K env o n mlay key hm hmk.1 hmk.2 hx
  | wide mt pass =>
    obtain ⟨h9, h223, hmt, hroute⟩ := hmk
    refine ok_wideMlpT P K env o n mt pass mlay key hm h9 h223 hmt (fun h3 => hroute _ ?_) hx
    rcases hm.downBits with h | h | h
    · exact .inl h
    · exact absurd h h3
    · exact .inr h

/-- **A layer of a GPU row family** at chain position `p`, its stage's weights and prefill handles. -/
theorem ok_rowLayer (pk : ProjKind) (mk : MlpKind) (rd : Read) (hf : FamRows pk mk rd n) (p : Nat)
    {s : StageWeights} {h : Handles} (hs : StageW s) (hp : StagePre o s h) (hg : Grows o n)
    (hin : ∀ k, env.inputs (stageKey p k) = stageInput s h k)
    (htin : env.inputs (auxKey refRows rd p 0) = some (tinValue n))
    (hfold : ∀ r, rd = .folded r → FoldedEnv env (auxKey refRows rd p) o n) {x : Value}
    (hx : Ty x .bfloat16 [1, n, 5120]) :
    OkV ((rowTpl refRows pk mk rd).layer (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) o n p
      (stageLayout s h) x) fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ CacheOk (o + n) s (r.2.1, r.2.2) := by
  have hproj := fun lay key x (hl : LinOk env lay key) (hx : Ty x .bfloat16 [1, n, lay.cols]) =>
    ok_projT P K env o n pk hf.proj lay key hl hx
  have hmlp := fun mlay key x (hm : MlpOk env mlay key) (hx : Ty x .bfloat16 [1, n, 5120]) =>
    ok_mlpT P K env o n mk hf.mlp mlay key hm hx
  cases s with
  | delta dw =>
    cases h with
    | attention _ _ => exact hp.elim
    | delta conv rec =>
      have he := deltaEnv_of env n (stageKey p) (auxKey refRows rd p) hin htin hs hp.1 hp.2
      exact (ok_deltaLayerT P K env o n _ _ hproj hmlp _ _ _ he hf.lo (by have := hf.hi; omega) hx).mono
        fun r hr => ⟨hr.1, hr.2.1, hr.2.2⟩
  | attention aw =>
    cases h with
    | delta _ _ => exact hp.elim
    | attention kb vb =>
      have he := attnEnv_of env o n (stageKey p) (auxKey refRows rd p) rd hin (fun r hr => ⟨(hf.read r hr).1, (hf.read r hr).2, hfold r hr⟩) hs hp.1 hp.2
      refine (ok_attentionLayerT P K env o n _ _ hproj hmlp rd _ _ _ he hf.lo hx).mono fun r hr => ⟨hr.1, ?_, ?_⟩
      · exact hr.2.1.cast (by rw [show (attnLayout aw kb vb).kcap = capOf kb from rfl, kvCapP_pre hp.1 hg])
      · exact hr.2.2.cast (by rw [show (attnLayout aw kb vb).vcap = capOf vb from rfl, kvCapP_pre hp.2 hg])

/-- **The chain of a GPU row family** from position `p`, its stages' weights and prefill handles. -/
theorem ok_chainT (pk : ProjKind) (mk : MlpKind) (rd : Read) (hf : FamRows pk mk rd n) (hg : Grows o n)
    (ws : List StageWeights) (hs : List Handles)
    (hin : ∀ p s h, ws[p]? = some s → hs[p]? = some h → ∀ k, env.inputs (stageKey p k) = stageInput s h k)
    (htin : ∀ p, env.inputs (auxKey refRows rd p 0) = some (tinValue n))
    (hfold : ∀ p r, rd = .folded r → FoldedEnv env (auxKey refRows rd p) o n) :
    ∀ (p : Nat) (ws' : List StageWeights) (hs' : List Handles), ws.drop p = ws' → hs.drop p = hs' →
      (∀ s ∈ ws', StageW s) → List.Forall₂ (StagePre o) ws' hs' → ∀ x, Ty x .bfloat16 [1, n, 5120] →
      OkV (chainT (rowTpl refRows pk mk rd) (valueB P K.toKernelContract env (ksR P K env)) (PDim.eval (refNu o n)) o n p
        (chainLayout ws' hs') x) fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ List.Forall₂ (CacheOk (o + n)) ws' r.2
  | _, [], [], _, _, _, _, x, hx => OkV.pure ⟨hx, .nil⟩
  | p, s :: ws', h :: hs', hw, hh, hsw, .cons hp hrest, x, hx => by
    have hws : ws[p]? = some s := by rw [← List.head?_drop, hw]; rfl
    have hhs : hs[p]? = some h := by rw [← List.head?_drop, hh]; rfl
    have hw' : ws.drop (p + 1) = ws' := by rw [← List.drop_drop, hw]; rfl
    have hh' : hs.drop (p + 1) = hs' := by rw [← List.drop_drop, hh]; rfl
    refine OkV.bind (ok_rowLayer P K env o n pk mk rd hf p (hsw s (List.mem_cons.2 (.inl rfl))) hp hg
      (hin p s h hws hhs) (htin p) (hfold p) hx) fun r hr => ?_
    obtain ⟨y, c1, c2⟩ := r
    dsimp only
    refine OkV.bind (ok_chainT pk mk rd hf hg ws hs hin htin hfold (p + 1) ws' hs' hw' hh'
      (fun s' m => hsw s' (List.mem_cons.2 (.inr m))) hrest y hr.1) fun r2 hr2 => ?_
    obtain ⟨z, cs⟩ := r2
    exact OkV.pure ⟨hr2.1, .cons hr.2 hr2.2⟩
  | _, [], _ :: _, _, _, _, h, _, _ => nomatch h
  | _, _ :: _, [], _, _, _, h, _, _ => nomatch h

end

end Host.Mlx.SimGraph.Mach
