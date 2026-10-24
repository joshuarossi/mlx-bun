import host.simgraph.mach.PreFamily
namespace Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Mlx.GlueStep Host.Ts
open Host.Mlx.GlueLayers
open Host.Mlx.SimGraph.Ref (refRows refNu refRows_o refRows_n gpuFamily rowSem rowIds handlesOf downPlan)
open Host.Ts.Sim.Prefill (Phase)

/-! # A GPU row step is defined on well-typed handles

`rowSem` of a GPU row family (`gpuFamily`: V23, V4, V58, VW at their rows) from the prefill handles at offset
`o` (`StagePre o`) on the loaded weights (`StageW` at every stage, `PipeTy`): the prompt ids of the rows (the
prompt's tokens below `2³¹`, rows within the prompt), the family's value instance, its caches as handles at
offset `o + n`, when the step grows the caches only at multiples of 256 (`Grows`). -/

/-! ## The prompt ids -/

theorem leBytes_length : ∀ (k v : Nat), (leBytes k v).length = k
  | 0, _ => rfl
  | k + 1, v => by simp [leBytes, leBytes_length k]

theorem i32Bytes_length (v : Int) : (i32Bytes v).length = 4 := leBytes_length 4 _

theorem leWord_shift (a rest : List Nat) (ha : a.length = 4) (j : Nat) :
    leWord (a ++ rest) 4 (j + 1) = leWord rest 4 j := by
  unfold leWord
  congr 1
  funext k acc
  rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_append_right (by rw [ha]; omega),
    ha, show (j + 1) * 4 + k - 4 = j * 4 + k by omega]

theorem leWord_first (a rest : List Nat) (ha : a.length = 4) : leWord (a ++ rest) 4 0 = leWord a 4 0 := by
  match a, ha with
  | [x0, x1, x2, x3], _ => rfl

theorem modNat_lt (v : Int) : F64.modNat v (2 ^ 32) < 2 ^ 32 := by
  unfold F64.modNat
  have h1 := Int.emod_nonneg v (show ((2 ^ 32 : Nat) : Int) ≠ 0 by omega)
  have h2 := Int.emod_lt_of_pos v (show (0 : Int) < ((2 ^ 32 : Nat) : Int) by omega)
  omega

theorem leWord_cells : ∀ (vs : List Int) (j : Nat), j < vs.length →
    leWord (cellsBytes vs) 4 j = F64.modNat vs[j]! (2 ^ 32)
  | [], _, h => absurd h (by simp)
  | v :: vs, 0, _ => by
    rw [cellsBytes, List.flatMap_cons, leWord_first _ _ (i32Bytes_length v)]
    exact leWord_u32 _ (modNat_lt v)
  | v :: vs, j + 1, h => by
    rw [cellsBytes, List.flatMap_cons, leWord_shift _ _ (i32Bytes_length v)]
    exact leWord_cells vs j (by simp at h; omega)

theorem modNat_ofNat (t : Nat) (h : t < 2 ^ 32) : F64.modNat (Int.ofNat t) (2 ^ 32) = t := by
  unfold F64.modNat
  rw [Int.ofNat_eq_natCast, Int.emod_eq_of_lt (by omega) (by omega)]
  rfl

/-- **The prompt ids of rows `[o, o + n)`**: int32 `[1, n]`, each a prompt token. -/
theorem rowIds_ok (π : List Nat) (o n : Nat) (hπ : o + n ≤ π.length) (htok : ∀ t ∈ π, t < 2 ^ 31) :
    OkV (rowIds π o n) fun v => Ty v .int32 [1, n] ∧ ∀ j < n, v.elems j < 2 ^ 31 := by
  unfold rowIds cellsValue dataValue
  rw [show Dtype.ofCode Ffi.dtInt32 = some .int32 from rfl, show natShape [1, (n : Int)] = some [1, n] from by
    simp [natShape]]
  refine ⟨_, rfl, ⟨rfl, rfl⟩, fun j hj => ?_⟩
  have hl : (((π.drop o).take n).map Int.ofNat).length = n := by simp; omega
  show leWord _ (Dtype.bytes .int32) (j % extent [1, n]) < 2 ^ 31
  rw [show Dtype.bytes .int32 = 4 from rfl, show extent [1, n] = n by simp [extent], Nat.mod_eq_of_lt hj,
    leWord_cells _ j (by rw [hl]; exact hj)]
  have hmem : (((π.drop o).take n).map Int.ofNat)[j]! = Int.ofNat (π[o + j]!) := by
    rw [getElem!_pos _ _ (by rw [hl]; exact hj), List.getElem_map, List.getElem_take, List.getElem_drop,
      getElem!_pos _ _ (by omega)]
  have ht := htok (π[o + j]!) (by rw [getElem!_pos _ _ (by omega)]; exact List.getElem_mem _)
  rw [hmem, modNat_ofNat _ (by omega)]
  exact ht

/-! ## The handles after a step -/

theorem handlesOf_ok {o' : Nat} (ho : 0 < o') : ∀ (ws : List StageWeights) (cs : List (Value × Value)),
    List.Forall₂ (CacheOk o') ws cs → ∃ hs', handlesOf ws cs = some hs' ∧ List.Forall₂ (StagePre o') ws hs'
  | [], [], .nil => ⟨[], rfl, .nil⟩
  | .delta _ :: ws, (a, b) :: cs, .cons h hr => by
    obtain ⟨hs', e, hh⟩ := handlesOf_ok ho ws cs hr
    exact ⟨_, by rw [handlesOf, e]; rfl, .cons (show StagePre o' (.delta _) (.delta (some a) (some b)) from
      ⟨fun v hv => by cases hv; exact h.1, fun v hv => by cases hv; exact h.2⟩) hh⟩
  | .attention _ :: ws, (a, b) :: cs, .cons h hr => by
    obtain ⟨hs', e, hh⟩ := handlesOf_ok ho ws cs hr
    exact ⟨_, by rw [handlesOf, e]; rfl, .cons (show StagePre o' (.attention _) (.attention (some a) (some b)) from
      ⟨⟨ho, h.1⟩, ⟨ho, h.2⟩⟩) hh⟩

/-! ## The family's step -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} (env : Env κ) (o n : Nat)

theorem ok_embedT (idk : κ) (bkey : InKey → κ) {ids : Value} (hids : env.inputs idk = some ids) (hty : Ty ids .int32 [1, n])
    (hb : ∀ j < n, ids.elems j < 2 ^ 31) (h2 : 2 ≤ n)
    (hwd : OkV (env.inputs (bkey .embedWords)) fun v => Ty v .uint32 [248320, 640])
    (hsc : OkV (env.inputs (bkey .embedScales)) fun v => Ty v .bfloat16 [248320, 80])
    (hbi : OkV (env.inputs (bkey .embedBiases)) fun v => Ty v .bfloat16 [248320, 80]) :
    OkV (embedT (valueB P K.toKernelContract env (ksR P K env)) idk bkey)
      fun u => Ty u .bfloat16 [1, n, 5120] := by
  unfold embedT
  refine OkV.bind (⟨ids, hids, rfl⟩ : OkV (env.inputs idk) (· = ids)) fun i hi => ?_
  subst hi
  refine OkV.bind hwd fun wd hwd => ?_
  refine OkV.bind hsc fun sc hsc => ?_
  refine OkV.bind hbi fun bi hbi => ?_
  refine OkV.bind (ok_take P K.toKernelContract env (ksR P K env) hwd hty hb) fun rows hrows => ?_
  refine OkV.bind (ok_take P K.toKernelContract env (ksR P K env) hsc hty hb) fun s hs => ?_
  refine OkV.bind (ok_take P K.toKernelContract env (ksR P K env) hbi hty hb) fun b hb' => ?_
  exact ok_dequantizeRows P K.toKernelContract env (ksR P K env) hrows hs hb' h2

end

/-! ## The step -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (w : PipelineWeights) (o n : Nat) (ids : Value) (hs : List Handles)

/-- **A GPU row family's value instance** at the step environment, from the prefill handles. -/
theorem ok_rowForward (pk : ProjKind) (mk : MlpKind) (rd : Read) (hf : FamRows pk mk rd n) (hg : Grows o n)
    (hpw : PipeTy w) (hw : ∀ s ∈ stageWeights w, StageW s) (hh : List.Forall₂ (StagePre o) (stageWeights w) hs)
    (hids : Ty ids .int32 [1, n]) (hb : ∀ j < n, ids.elems j < 2 ^ 31) :
    OkV (forwardT (rowTpl refRows pk mk rd)
        (valueB P K.toKernelContract (Ref.stepEnv weights w o n ids hs) (ksR P K (Ref.stepEnv weights w o n ids hs)))
        (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs))
      fun r => Ty r.1 .bfloat16 [1, n, 5120] ∧ List.Forall₂ (CacheOk (o + n)) (stageWeights w) r.2 := by
  have hfold : ∀ p r, rd = .folded r → FoldedEnv (Ref.stepEnv weights w o n ids hs) (auxKey refRows rd p) o n := by
    intro p r hr
    obtain ⟨rfl, _⟩ := hf.read r hr
    subst hr
    exact stepEnv_folded weights w o r ids hs p
  unfold forwardT
  refine OkV.bind (ok_embedT P K (Ref.stepEnv weights w o n ids hs) n PKey.promptIds PKey.base rfl hids hb hf.lo ⟨_, rfl, hpw.words⟩
    ⟨_, rfl, hpw.scales⟩ ⟨_, rfl, hpw.biases⟩) fun x hx => ?_
  refine OkV.bind (ok_chainT P K (Ref.stepEnv weights w o n ids hs) o n pk mk rd hf hg (stageWeights w) hs
    (fun p s h hws hhs k => stepEnv_stage weights w o n ids hs p hws hhs k)
    (fun p => stepEnv_tin weights w o n ids hs rd p (by have := hf.hi; omega)) hfold 0 _ _ rfl rfl hw hh x hx)
    fun r hr => ?_
  obtain ⟨y, cs⟩ := r
  dsimp only
  exact OkV.bind (ok_normT P K (Ref.stepEnv weights w o n ids hs) (PKey.base .finalNorm) hr.1 ⟨_, rfl, hpw.finalNorm⟩ rfl
    (Or.inl rfl))
    fun out hout => OkV.pure ⟨hout, hr.2⟩

/-- **A GPU row step from the prefill handles**: defined, its handles at offset `o + n`. -/
theorem rowSem_ok (π : List Nat) (pk : ProjKind) (mk : MlpKind) (rd : Read) (hf : FamRows pk mk rd n) (hg : Grows o n)
    (hpw : PipeTy w) (hw : ∀ s ∈ stageWeights w, StageW s) (hh : List.Forall₂ (StagePre o) (stageWeights w) hs)
    (hπ : o + n ≤ π.length) (htok : ∀ t ∈ π, t < 2 ^ 31) :
    ∃ hs', rowSem P K weights w π (rowTpl refRows pk mk rd) o n hs = some hs' ∧
      List.Forall₂ (StagePre (o + n)) (stageWeights w) hs' := by
  obtain ⟨ids, eids, hids, hb⟩ := rowIds_ok π o n hπ htok
  obtain ⟨r, er, hr⟩ := ok_rowForward P K weights w o n ids hs pk mk rd hf hg hpw hw hh hids hb
  obtain ⟨hs', eh, hh'⟩ := handlesOf_ok (by have := hf.lo; omega) _ _ hr.2
  refine ⟨hs', ?_, hh'⟩
  unfold rowSem
  rw [eids]
  dsimp only [bind, Option.bind]
  rw [er]
  exact eh

end

/-! ## The GPU classes -/

theorem ite_prop {α : Type} {p : Prop} [Decidable p] {Q : α → Prop} {a b : α} (ha : Q a) (hb : Q b) :
    Q (if p then a else b) := by
  split <;> assumption

/-- The down passes the plan reaches. -/
def DownOk (x : DownPass) : Prop := x = ⟨16, 1⟩ ∨ x = ⟨8, 2⟩ ∨ x = ⟨8, 3⟩

theorem downPlan_cases (r : Nat) : DownOk (downPlan r) := by
  unfold downPlan
  repeat (first | exact Or.inl rfl | exact Or.inr (Or.inl rfl) | exact Or.inr (Or.inr rfl) | apply ite_prop)

theorem downPlan_route (r k : Nat) (hk : k = 2 ∨ k = 4) : DownRoute k (downPlan r).s (downPlan r).mt := by
  rcases downPlan_cases r with h | h | h <;> rw [h] <;> rcases hk with rfl | rfl <;> simp [DownRoute]

theorem famRows_vw {n : Nat} (h9 : 9 ≤ n) (h223 : n ≤ 223) :
    FamRows .split (.wide (Metal.Kernels.GateUpMmaWide.rowBlocks n) (downPlan n)) .causal n :=
  { proj := ⟨by omega, h223⟩, mlp := ⟨h9, h223, rfl, fun k hk => downPlan_route n k hk⟩,
    read := fun _ h => (nomatch h), lo := by omega, hi := h223 }

/-- **The GPU class of a step** of `n ≥ 2` rows is a row family on its rows. -/
theorem gpuFamily_rows {ph : Phase} {n : Nat} {T : RowTpl PKey} (hT : gpuFamily ph n = some T) (h2 : 2 ≤ n) :
    ∃ pk mk rd, T = rowTpl refRows pk mk rd ∧ FamRows pk mk rd n := by
  cases ph with
  | chunk =>
    dsimp only [gpuFamily] at hT
    by_cases h : n = 64 ∨ n = 128
    · rw [ite_eq_left h] at hT; cases hT; exact ⟨_, _, _, rfl, famRows_vw (by omega) (by omega)⟩
    · rw [ite_eq_right h] at hT; cases hT
  | tail | decode =>
    dsimp only [gpuFamily] at hT
    have nf : ∀ r, Read.causal = Read.folded r → r = n ∧ 6 ≤ n := fun _ h => (nomatch h)
    by_cases h3 : n ≤ 3
    · rw [ite_eq_left h3] at hT; cases hT
      have hp : ProjRows .rows n := (show n = 2 ∨ n = 3 by omega)
      have hm : MlpRows .codebook n := ⟨h2, by omega⟩
      exact ⟨_, _, _, rfl, ⟨hp, hm, nf, h2, by omega⟩⟩
    rw [ite_eq_right h3] at hT
    by_cases h4 : n = 4
    · rw [ite_eq_left h4] at hT; cases hT
      have hp : ProjRows .split n := ⟨by omega, by omega⟩
      have hm : MlpRows .codebook n := ⟨h2, by omega⟩
      exact ⟨_, _, _, rfl, ⟨hp, hm, nf, h2, by omega⟩⟩
    rw [ite_eq_right h4] at hT
    by_cases h5 : n = 5
    · rw [ite_eq_left h5] at hT; cases hT
      have hp : ProjRows .split n := ⟨by omega, by omega⟩
      have hm : MlpRows .codebook n := ⟨h2, by omega⟩
      exact ⟨_, _, _, rfl, ⟨hp, hm, nf, h2, by omega⟩⟩
    rw [ite_eq_right h5] at hT
    by_cases h8 : n ≤ 8
    · rw [ite_eq_left h8] at hT; cases hT
      have hp : ProjRows .split n := ⟨by omega, by omega⟩
      have hm : MlpRows .codebook n := ⟨h2, by omega⟩
      have hr : ∀ r, Read.folded n = Read.folded r → r = n ∧ 6 ≤ n := fun r hr => by cases hr; omega
      exact ⟨_, _, _, rfl, ⟨hp, hm, hr, h2, by omega⟩⟩
    rw [ite_eq_right h8] at hT
    by_cases h223 : n ≤ 223
    · rw [ite_eq_left h223] at hT; cases hT; exact ⟨_, _, _, rfl, famRows_vw (by omega) h223⟩
    · rw [ite_eq_right h223] at hT; cases hT

end Host.Mlx.SimGraph.Mach
