import host.sim.General
import host.simgraph.iter.BaseGx
import host.simgraph.iter.OrdinaryStep
import host.simgraph.iter.ClearStep
import host.simgraph.iter.FillStep
import host.simgraph.iter.GrowthStep
import host.simgraph.iter.FinalStep
import host.simgraph.iter.FinalC0Step
import host.simgraph.iter.FinalC1Step
import host.load.run.full.RecurrenceReadbacks
import host.load.run.tail.Short1
import host.load.run.tail.Short2
import host.simgraph.iter.ShortGFC
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (ForwardAt Gr GF GFC Gx tplInputs base_gx)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- Token `k` of the checkpoint recurrence (`0` past the context bound). -/
noncomputable def recToken (k : Nat) : Nat :=
  if h : k ≤ 262144 then ((firstContext M K env [] leaves typed parameters).run promptToken k h).token.val else 0

theorem recToken_eq (k : Nat) (h : k ≤ 262144) :
    recToken M K env leaves typed parameters k =
      ((firstContext M K env [] leaves typed parameters).run promptToken k h).token.val := dif_pos h

theorem recToken_lt (k : Nat) : recToken M K env leaves typed parameters k < 2 ^ 20 := by
  unfold recToken
  split
  · rename_i h
    have := ((firstContext M K env [] leaves typed parameters).run promptToken k h).token.isLt
    omega
  · decide

theorem recurrence_eq (T k : Nat) (h1 : 1 ≤ k) (hk : k ≤ 262144) :
    recurrenceValuation M K env leaves typed parameters T k = F64.ofNat (recToken M K env leaves typed parameters k) := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  simp only [recurrenceValuation, dif_pos hk, recToken]

theorem recurrence_nat (T : Nat) (hT : T ≤ 2 ^ 20) (j : Nat) :
    ∃ k ≤ 2 ^ 20, recurrenceValuation M K env leaves typed parameters T j = F64.ofNat k := by
  match j with
  | 0 => exact ⟨T, hT, rfl⟩
  | j + 1 =>
    by_cases h : j + 1 ≤ 262144
    · exact ⟨_, Nat.le_of_lt (recToken_lt M K env leaves typed parameters (j + 1)),
        recurrence_eq M K env leaves typed parameters T (j + 1) (by omega) h⟩
    · exact ⟨0, by decide, by simp only [recurrenceValuation, dif_neg h]⟩

/-- The conclusions of `source_tokens` for budget `T` at the valuation `ρ`. -/
def TokensRun (T : Nat) (hTb : T ≤ 262144) (ρ : Nat → F64) : Prop :=
  ∃ N final server, (∀ n, N ≤ n →
      ((bootL Route.cx (Tail.worldTail (Tpl.tailReads ρ T)) 2000).bind fun start =>
        runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (final, server)) ∧
    emittedNumbers final (entryEnv P.s0) server = some (List.ofFn fun i : Fin T =>
      F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) ∧
    firstPipeline M K env server.tab leaves typed = initialPipeline M K env [] leaves typed ∧
    (∀ time, 1 ≤ time → ∀ h2 : time ≤ T, ∃ caches output,
      ForwardAt M K env server.tab leaves typed (parameters_for_table M K env leaves typed parameters server.tab)
        time (by omega) caches output (Gr server.tab final.ffi.mlx)) ∧
    ReadbackValues M K env (CSrv.val server) (Gr server.tab final.ffi.mlx) final.ffi.mlx.items ∧
    (∃ caches output, Sim.ExtractSim.cachesT final (entryEnv P.s0) = some caches ∧
      ForwardAt M K env server.tab leaves typed (parameters_for_table M K env leaves typed parameters server.tab)
        T hTb caches output (Gr server.tab final.ffi.mlx)) ∧
    ∃ v, final.ctl = .halt (.normal v)

theorem notEos_tok {T : Nat} (hTb : T ≤ 262144)
    (notEos : ∀ i : Fin T, F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) =
        false) (k : Nat) (h1 : 1 ≤ k) (hk : k ≤ T) : recToken M K env leaves typed parameters k ≠ 248044 := by
  intro he
  obtain ⟨j, hj, hjk, h⟩ : ∃ j, ∃ hj : j ≤ 262144, j = k ∧ F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken j hj).token.val) = false :=
    ⟨_, _, by simp; omega, notEos ⟨k - 1, by omega⟩⟩
  subst hjk
  rw [← recToken_eq M K env leaves typed parameters j hj, he, Sim.fin_eq_ofNat 248044 (by decide) (by decide),
    Sim.test_eq_ofNat 248044 248044 (by decide) (by decide)] at h
  simp at h

theorem emitted_ofFn {T : Nat} (hTb : T ≤ 262144) :
    (List.range T).map (fun k => recurrenceValuation M K env leaves typed parameters T (k + 1)) =
      List.ofFn fun i : Fin T =>
        F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val := by
  apply List.ext_getElem (by simp)
  intro i h1 h2
  simp only [List.getElem_map, List.getElem_range, List.getElem_ofFn]
  simp at h1
  rw [recurrence_eq M K env leaves typed parameters T (i + 1) (by omega) (by omega),
    recToken_eq M K env leaves typed parameters (i + 1) (by omega)]

/-- The route for budgets `3 ≤ T`: boot prefix, loop, final case. -/
theorem tokens_loop (T : Nat) (hT : 3 ≤ T) (supported : T ≤ 262144)
    (notEos : ∀ i : Fin T, F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) =
        false) :
    TokensRun M K env leaves typed parameters T supported (recurrenceValuation M K env leaves typed parameters T) := by
  let ρ := recurrenceValuation M K env leaves typed parameters T
  let tk := recToken M K env leaves typed parameters
  have htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val :=
    recToken_eq M K env leaves typed parameters
  have hρ : ∀ k, 1 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k) :=
    fun k h1 hk => recurrence_eq M K env leaves typed parameters T k h1 (by omega)
  obtain ⟨N, tF, CF, hrun, hhalt, hem, ⟨hfw, hrd⟩, hcache⟩ :=
    Tpl.loop_source (Gx := Gx M K env leaves typed parameters tplInputs)
      (G := fun tF CF => GFC M K env leaves typed parameters T CF.tab tF) T hT supported ρ tk rfl hρ
      (recurrence_nat M K env leaves typed parameters T (by omega))
      (fun k _ => Nat.le_of_lt (recToken_lt M K env leaves typed parameters k))
      (notEos_tok M K env leaves typed parameters supported notEos)
      (base_gx M K env leaves typed parameters _ ρ tk htk (hρ 1 le_rfl (by omega)))
      (fun i hi1 hiT => by
        rcases Tpl.loopSel_cases i with ⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩ | ⟨_, h3, h4, e⟩ <;> rw [e]
        · exact SimGraph.Iter.CLEAR.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) (by omega) (by omega)
        · exact SimGraph.Iter.FILL.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) h
        · exact SimGraph.Iter.GROWTH.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) h
        · exact SimGraph.Iter.ORDINARY.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) h3 h4)
      (fun _ _ => SimGraph.Iter.FINAL.fgstep M K env leaves typed parameters Tpl.loopFixC ρ T tk _ htk (by omega) supported (by decide))
      (fun _ => SimGraph.Iter.FINALC0.fgstep M K env leaves typed parameters Tpl.loopFixC ρ T tk _ htk (by omega) supported (by decide))
      (fun _ => SimGraph.Iter.FINALC1.fgstep M K env leaves typed parameters Tpl.loopFixC ρ T tk _ htk (by omega) supported (by decide))
  refine ⟨N, tF, CF, hrun, ?_, (initial_pipeline_first M K env [] CF.tab leaves typed).symm,
    fun time h1 h2 => hfw time h1 h2 (by omega), hrd, hcache supported, hhalt⟩
  rw [hem, emitted_ofFn M K env leaves typed parameters supported]

/-- The route for budget 1. -/
theorem tokens_one
    (notEos : ∀ i : Fin 1, F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) =
        false) :
    TokensRun M K env leaves typed parameters 1 (by decide) (recurrenceValuation M K env leaves typed parameters 1) := by
  let ρ := recurrenceValuation M K env leaves typed parameters 1
  have h1 := recurrence_eq M K env leaves typed parameters 1 1 le_rfl (by decide)
  obtain ⟨N, hrun, hhalt, hem⟩ := Tail.source_T1 ρ (Tail.good_answersT1 rfl h1
    (notEos_tok M K env leaves typed parameters (by decide) notEos 1 le_rfl le_rfl)
    (by have := recToken_lt M K env leaves typed parameters 1; omega))
  obtain ⟨⟨hfw, hrd⟩, hcache⟩ := SimGraph.Iter.short1_gfc M K env leaves typed parameters ρ _
    (recToken_eq M K env leaves typed parameters) h1
  refine ⟨N, _, _, hrun, ?_, (initial_pipeline_first M K env [] _ leaves typed).symm,
    fun time h1 h2 => hfw time h1 h2 (by omega), hrd, hcache (by decide), hhalt⟩
  rw [hem, ← emitted_ofFn M K env leaves typed parameters (T := 1) (by decide)]
  rfl

/-- The route for budget 2. -/
theorem tokens_two
    (notEos : ∀ i : Fin 2, F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) =
        false) :
    TokensRun M K env leaves typed parameters 2 (by decide) (recurrenceValuation M K env leaves typed parameters 2) := by
  let ρ := recurrenceValuation M K env leaves typed parameters 2
  have h1 := recurrence_eq M K env leaves typed parameters 2 1 le_rfl (by decide)
  have h2 := recurrence_eq M K env leaves typed parameters 2 2 (by decide) (by decide)
  obtain ⟨N, hrun, hhalt, hem⟩ := Tail.source_T2 ρ (Tail.good_answersT2 rfl h1 h2
    (notEos_tok M K env leaves typed parameters (by decide) notEos 1 le_rfl (by decide))
    (by have := recToken_lt M K env leaves typed parameters 1; omega)
    (notEos_tok M K env leaves typed parameters (by decide) notEos 2 (by decide) le_rfl)
    (by have := recToken_lt M K env leaves typed parameters 2; omega))
  obtain ⟨⟨hfw, hrd⟩, hcache⟩ := SimGraph.Iter.short2_gfc M K env leaves typed parameters ρ _
    (recToken_eq M K env leaves typed parameters) h1 h2
  refine ⟨N, _, _, hrun, ?_, (initial_pipeline_first M K env [] _ leaves typed).symm,
    fun time h1 h2 => hfw time h1 h2 (by omega), hrd, hcache (by decide), hhalt⟩
  rw [hem, ← emitted_ofFn M K env leaves typed parameters (T := 2) (by decide)]
  rfl

/-- **The complete source route for every token budget `1 ≤ T ≤ 262144`.** Booting the
actual source with token budget `T` loads the checkpoint, emits the `T` tokens of the
checkpoint recurrence and halts normally, for every run length past the route's. The
world's native readbacks are the recurrence's tokens (the first two through the table's
read symbols, the rest as literals); the only branch premise selects the non-EOS route.
At the halted state every forward result of times `1 … T` holds on the run's native graph
(the token at its output node and the cache values the recurrence computes), and every
memoized native read has its graph-computed value. -/
theorem source_tokens (T : Nat) (hT : 1 ≤ T) (supported : T ≤ 262144)
    (notEos : ∀ i : Fin T, F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) =
        false) :
    let ρ := recurrenceValuation M K env leaves typed parameters T
    ∃ N final server, (∀ n, N ≤ n →
        ((bootL Route.cx (Tail.worldTail (Tpl.tailReads ρ T)) 2000).bind fun start =>
          runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (final, server)) ∧
      emittedNumbers final (entryEnv P.s0) server = some (List.ofFn fun i : Fin T =>
        F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) ∧
      firstPipeline M K env server.tab leaves typed = initialPipeline M K env [] leaves typed ∧
      (∀ time, 1 ≤ time → ∀ h2 : time ≤ T, ∃ caches output,
        ForwardAt M K env server.tab leaves typed (parameters_for_table M K env leaves typed parameters server.tab)
          time (by omega) caches output (Gr server.tab final.ffi.mlx)) ∧
      ReadbackValues M K env (CSrv.val server) (Gr server.tab final.ffi.mlx) final.ffi.mlx.items ∧
      (∃ caches output, Sim.ExtractSim.cachesT final (entryEnv P.s0) = some caches ∧
        ForwardAt M K env server.tab leaves typed (parameters_for_table M K env leaves typed parameters server.tab)
          T supported caches output (Gr server.tab final.ffi.mlx)) ∧
      ∃ v, final.ctl = .halt (.normal v) := by
  intro ρ
  obtain rfl | rfl | h3 : T = 1 ∨ T = 2 ∨ 3 ≤ T := by omega
  · exact tokens_one M K env leaves typed parameters notEos
  · exact tokens_two M K env leaves typed parameters notEos
  · exact tokens_loop M K env leaves typed parameters T h3 supported notEos

end Host.Load.Run.Full
