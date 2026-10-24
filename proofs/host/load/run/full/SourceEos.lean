import host.load.run.full.SourceTokens
import host.sim.GeneralEos
import host.simgraph.iter.EOSXStep
import host.simgraph.iter.FinalEStep
import host.simgraph.iter.FinalEC0Step
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (ForwardAt Gr GF GFC Gx tplInputs base_gx)

/-! # The source route's EOS stop for budgets `T ≥ 3`

At the recurrence's valuation, token `k` (`2 ≤ k ≤ T`) is EOS and tokens `1 … k - 1` are
not: `Tpl.loop_source_eos` with the loop's graph invariant and the EOS cases' graph steps
(`EOSX.egstep` for `k < T`, `FINALE.fgstep`/`FINALEC0.fgstep` for `k = T`). The route halts
after emitting tokens `1 … k - 1`, with `finishReason = "stop"`, and the forward results of
times `1 … min (k + 1) T` (the run's last forward) hold on its native graph. -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

theorem notEos_tok_lt {T k : Nat} (hkT : k ≤ T) (hTb : T ≤ 262144)
    (notEos : ∀ i : Fin (k - 1), F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) =
        false) (j : Nat) (h1 : 1 ≤ j) (hj : j < k) : recToken M K env leaves typed parameters j ≠ 248044 := by
  intro he
  obtain ⟨j', hj', hjj, h⟩ : ∃ j', ∃ hj' : j' ≤ 262144, j' = j ∧ F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken j' hj').token.val) = false :=
    ⟨_, _, by simp; omega, notEos ⟨j - 1, by omega⟩⟩
  subst hjj
  rw [← recToken_eq M K env leaves typed parameters j' hj', he, Sim.fin_eq_ofNat 248044 (by decide) (by decide),
    Sim.test_eq_ofNat 248044 248044 (by decide) (by decide)] at h
  simp at h

theorem eos_tok_at {k : Nat} (hk : k ≤ 262144)
    (eos : F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken k hk).token.val) = true) :
    recToken M K env leaves typed parameters k = 248044 := by
  rw [recToken_eq M K env leaves typed parameters k hk]
  exact Sim.eos_tok (by have := recToken_lt M K env leaves typed parameters k; rw [recToken_eq M K env leaves typed
    parameters k hk] at this; omega) eos

theorem emitted_ofFn_take {T m : Nat} (hm : m ≤ T) (hTb : T ≤ 262144) :
    (List.range m).map (fun j => recurrenceValuation M K env leaves typed parameters T (j + 1)) =
      List.ofFn fun i : Fin m =>
        F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val := by
  apply List.ext_getElem (by simp)
  intro i h1 h2
  simp only [List.getElem_map, List.getElem_range, List.getElem_ofFn]
  simp at h1
  rw [recurrence_eq M K env leaves typed parameters T (i + 1) (by omega) (by omega),
    recToken_eq M K env leaves typed parameters (i + 1) (by omega)]

/-- **The source route's EOS stop for budgets `3 ≤ T`.** Booting the actual source with token
budget `T` at the recurrence's valuation, where token `k` (`2 ≤ k ≤ T`) is EOS and tokens
`1 … k - 1` are not: the route halts normally for every run length past the route's, emits
tokens `1 … k - 1` of the checkpoint recurrence, its `generation.stats.finishReason` is
`"stop"`, and the graph goal (`GFC`) holds for times `1 … min (k + 1) T`. -/
theorem tokens_eos (T : Nat) (hT : 3 ≤ T) (supported : T ≤ 262144) (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (notEos : ∀ i : Fin (k - 1), F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) =
        false)
    (eos : F64.test .eq (.fin false 248044 0)
      (F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken k (by omega)).token.val) = true) :
    let ρ := recurrenceValuation M K env leaves typed parameters T
    ∃ N final server, (∀ n, N ≤ n →
        ((bootL Route.cx (Tail.worldTail (Tpl.tailReads ρ T)) 2000).bind fun start =>
          runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (final, server)) ∧
      emittedNumbers final (entryEnv P.s0) server = some (List.ofFn fun i : Fin (k - 1) =>
        F64.ofNat ((firstContext M K env [] leaves typed parameters).run promptToken (i.val + 1) (by omega)).token.val) ∧
      Stop.statsField final (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop") ∧
      GFC M K env leaves typed parameters (min (k + 1) T) server.tab final ∧
      ∃ v, final.ctl = .halt (.normal v) := by
  intro ρ
  let tk := recToken M K env leaves typed parameters
  have htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val :=
    recToken_eq M K env leaves typed parameters
  have hρ : ∀ j, 1 ≤ j → j ≤ T → ρ j = F64.ofNat (tk j) :=
    fun j h1 hj => recurrence_eq M K env leaves typed parameters T j h1 (by omega)
  obtain ⟨N, tF, CF, hrun, hhalt, hem, hgoal, hstop⟩ :=
    Tpl.loop_source_eos (Gx := Gx M K env leaves typed parameters tplInputs)
      (G := fun tF CF => GFC M K env leaves typed parameters (min (k + 1) T) CF.tab tF) T hT supported ρ tk rfl hρ
      (recurrence_nat M K env leaves typed parameters T (by omega))
      (fun j _ => Nat.le_of_lt (recToken_lt M K env leaves typed parameters j)) k hk2 hkT
      (notEos_tok_lt M K env leaves typed parameters hkT supported notEos)
      (eos_tok_at M K env leaves typed parameters (by omega) eos)
      (base_gx M K env leaves typed parameters _ ρ tk htk (hρ 1 le_rfl (by omega)))
      (fun i hi1 _ hiT => by
        rcases Tpl.loopSel_cases i with ⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩ | ⟨_, h3, h4, e⟩ <;> rw [e]
        · exact SimGraph.Iter.CLEAR.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) (by omega) (by omega)
        · exact SimGraph.Iter.FILL.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) h
        · exact SimGraph.Iter.GROWTH.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) h
        · exact SimGraph.Iter.ORDINARY.gstep M K env leaves typed parameters ρ T tk _ i htk (by omega) h3 h4)
      (fun hk => by
        rw [show min (k + 1) T = k - 1 + 2 by omega]
        exact SimGraph.Iter.EOSX.egstep M K env leaves typed parameters Tpl.loopFixE ρ T tk _ (k - 1) htk (by omega)
          (by decide))
      (fun hk _ => by
        rw [show min (k + 1) T = T by omega]
        exact SimGraph.Iter.FINALE.fgstep M K env leaves typed parameters Tpl.loopFixE ρ T tk _ htk (by omega)
          supported (by decide))
      (fun hk _ => by
        rw [show min (k + 1) T = T by omega]
        exact SimGraph.Iter.FINALEC0.fgstep M K env leaves typed parameters Tpl.loopFixE ρ T tk _ htk (by omega)
          supported (by decide))
  refine ⟨N, tF, CF, hrun, ?_, hstop, hgoal, hhalt⟩
  rw [hem, emitted_ofFn_take M K env leaves typed parameters (by omega) supported]

end Host.Load.Run.Full
