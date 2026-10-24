import host.simgraph.mach.AneStepOk
import host.simgraph.mach.Widths
namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Ref (RSt AneNet routeStep drainStep tailStep gpuFamily aneTplOf)
open Host.Ts.Sim.Prefill (PStep Phase chunkC drains tailRows drains_tail chunkC_mem chunkSizes_cases sched_ok
  chunkC_le)

/-! # The prefill schedule's multi-row steps keep the prefill's handles typed

`scheduleTyped`: on the loaded checkpoint (`Leaves`, `TypedCheckpoint`), for a prompt of tokens below `248320` and
at most `349525` tokens, under the Neural Engine's success on the loaded programs (`NeuralEngine.Succeeds`) and the
loaded model's Neural Engine side (`AneNetOk`), every whole chunk (64, 128 rows: VW; 256–2048: a Neural Engine
bucket) and the tail when it has two rows or more (2–223: V23, V4, V58, VW; 224 on: a Neural Engine bucket) keeps
the prefill's handles typed (`ScheduleTyped`). -/

theorem gpuFamily_none {ph : Phase} {n : Nat} (h : gpuFamily ph n = none) (hph : ph = .chunk → n = 64 ∨ n = 128 ∨ 224 ≤ n) :
    224 ≤ n := by
  cases ph with
  | chunk =>
    rcases hph rfl with rfl | rfl | h'
    · simp [gpuFamily] at h
    · simp [gpuFamily] at h
    · exact h'
  | tail =>
    simp only [gpuFamily] at h
    split_ifs at h
    omega
  | decode =>
    simp only [gpuFamily] at h
    split_ifs at h
    omega

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **A step of 2–2048 rows** (a GPU row family, else a Neural Engine bucket) from the prefill handles. -/
theorem routeStep_rows (tab : List F64)
    (hnet : AneNetOk net (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))))
    (hNE : NE.Succeeds net) (hpw : PipeTy (weights (firstValues P.toMlxContract KR.toKernelContract env tab)))
    (hw : ∀ s ∈ stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)), StageW s)
    (htok : ∀ t ∈ π, t < 2 ^ 31) (st : PStep) (s : RSt) (h2 : 2 ≤ st.stop - st.start)
    (h2048 : st.stop - st.start ≤ 2048)
    (hph : st.phase = .chunk → st.stop - st.start = 64 ∨ st.stop - st.start = 128 ∨ 224 ≤ st.stop - st.start)
    (hg : Grows st.start (st.stop - st.start)) (hπ : st.stop ≤ π.length)
    (hh : List.Forall₂ (StagePre st.start)
      (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs) :
    ∃ s', routeStep P KR NE KR.inPlace net env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))
        π st s = some s' ∧
      List.Forall₂ (StagePre st.stop) (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)))
        s'.hs := by
  have hstop : st.start + (st.stop - st.start) = st.stop := by omega
  dsimp only [routeStep]
  rw [ite_eq_right (by omega)]
  cases hT : gpuFamily st.phase (st.stop - st.start) with
  | some T =>
    obtain ⟨pk, mk, rd, rfl, hf⟩ := gpuFamily_rows hT h2
    obtain ⟨hs', e, hh'⟩ := rowSem_ok P KR env.weights _ st.start (st.stop - st.start) s.hs π pk mk rd hf hg hpw hw hh
      (by omega) htok
    exact ⟨{ s with hs := hs' }, by dsimp only; rw [e]; rfl, by rw [← hstop]; exact hh'⟩
  | none =>
    have h224 := gpuFamily_none hT hph
    obtain ⟨s', e, hh'⟩ := aneStep_ok (P := P) (K := KR) (NE := NE) (weights := env.weights) π hnet hNE h224 h2048 hg
      hpw hw s hh (by omega) htok
    refine ⟨s', ?_, by rw [← hstop]; exact hh'⟩
    dsimp only
    rw [aneTplOf_eq h224 h2048]
    exact e

theorem grows_sched {Cn j r : Nat} (hC : Cn ∈ Host.Ts.Sim.Prefill.chunkSizes) (hr : r ≤ Cn) : Grows (j * Cn) r := by
  have := sched_ok (j := j) hC hr
  unfold Host.Ts.Sim.capL at this
  unfold Grows capL
  exact this

/-- **The prefill schedule's multi-row steps keep the prefill's handles typed**, on the loaded checkpoint, for a
prompt of at most `349525` tokens below `248320`, under the Neural Engine's success on the loaded programs and the
loaded model's Neural Engine side. -/
theorem scheduleTyped (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (hL : π.length ≤ 349525)
    (htok : ∀ t ∈ π, t < 248320) (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)))) :
    ScheduleTyped P KR NE KR.inPlace net env π := by
  intro tab
  have hpw := pipeTy_of_loaded P.toMlxContract KR.toKernelContract
    (firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed)
  have hw := stageW_loaded _ hpw
  have htok' : ∀ t ∈ π, t < 2 ^ 31 := fun t ht => by have := htok t ht; omega
  have hC := chunkC_mem hL
  have hCle := chunkC_le hL
  have hC64 : 64 ≤ chunkC π.length := by rcases chunkSizes_cases hC with h | h | h | h | h | h <;> omega
  have hCph : chunkC π.length = 64 ∨ chunkC π.length = 128 ∨ 224 ≤ chunkC π.length := by
    rcases chunkSizes_cases hC with h | h | h | h | h | h <;> omega
  refine ⟨fun j hj s hh => ?_, fun h2 s hh => ?_⟩
  · have hn : (drainStep (chunkC π.length) j).stop - (drainStep (chunkC π.length) j).start = chunkC π.length := by
      show (j + 1) * chunkC π.length - j * chunkC π.length = chunkC π.length
      rw [Nat.succ_mul]; omega
    have hdj : (j + 1) * chunkC π.length ≤ π.length - 1 := by
      have h1 := Nat.div_mul_le_self (π.length - 1) (chunkC π.length)
      have h2 : (j + 1) * chunkC π.length ≤ (π.length - 1) / chunkC π.length * chunkC π.length :=
        Nat.mul_le_mul_right _ (show j + 1 ≤ drains π.length from hj)
      omega
    exact routeStep_rows P KR NE net env π tab (hnet tab) hNE hpw hw htok' (drainStep (chunkC π.length) j) s
      (by rw [hn]; omega) (by rw [hn]; exact hCle) (fun _ => by rw [hn]; exact hCph)
      (by rw [hn]; exact grows_sched hC (le_refl _)) (by show (j + 1) * chunkC π.length ≤ π.length; omega) hh
  · have ht := drains_tail π.length
    have hlt : tailRows π.length < chunkC π.length := Nat.mod_lt _ (by omega)
    have hn : (tailStep π.length).stop - (tailStep π.length).start = tailRows π.length := by
      show π.length - 1 - drains π.length * chunkC π.length = tailRows π.length
      omega
    have hph : (tailStep π.length).phase ≠ .chunk := by
      show (if tailRows π.length = 1 then Phase.decode else Phase.tail) ≠ .chunk
      split <;> simp
    exact routeStep_rows P KR NE net env π tab (hnet tab) hNE hpw hw htok' (tailStep π.length) s
      (by rw [hn]; exact h2) (by rw [hn]; omega) (fun h => absurd h hph)
      (by rw [hn]; exact grows_sched hC (Nat.le_of_lt hlt)) (by show π.length - 1 ≤ π.length; omega) hh

end

end Host.Mlx.SimGraph.Mach
