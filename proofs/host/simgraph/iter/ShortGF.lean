import host.simgraph.iter.BaseGx
import host.simgraph.iter.Final
import host.simgraph.iter.ShortChecks1
import host.simgraph.iter.ShortChecks2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tail
open Inference.Models.Qwen

/-! # The graph conclusions of the short budgets `T = 1, 2`

The halted states `Short1.s4` and `Short2.s2` agree with the five-token terminal state
`P.s3573` on their nodes and hold its kernel objects, so the terminal forward results of
times `1` (and `2`) hold on their graphs; their memo entries are those times' tokens. -/

theorem nodes_of_check (X : Ffi.St) (N : Nat)
    (hc : (List.range N).map (fun j => X.nodes.get j) = (List.range N).map (fun j => X5.nodes.get j)) :
    ∀ j, j < N → X.nodes.get j = X5.nodes.get j := by
  intro j hj
  have h := congrArg (·[j]?) hc
  simp only [List.getElem?_map, List.getElem?_range hj, Option.map_some] at h
  exact Option.some.inj h

theorem kernels_of_check (X : Ffi.St)
    (hc : (Sim.Template.PTrie.keys X5.objs).map (fun k => atKernel (X5.objs.get k) (X5.objs.get k)) =
      (Sim.Template.PTrie.keys X5.objs).map (fun k => atKernel (X5.objs.get k) (X.objs.get k))) :
    ∀ k name, kernelName? SourceKernels.sources X5 k = some name → kernelName? SourceKernels.sources X k = some name := by
  intro k name hk
  unfold kernelName? at hk ⊢
  cases ho : X5.obj? k with
  | none => rw [ho] at hk; cases hk
  | some o =>
    cases o with
    | kernel nm sc hd a b =>
      have hget : X5.objs.get k = some (.kernel nm sc hd a b) := ho
      have h := (List.map_eq_map_iff.mp hc) k (Sim.Template.PTrie.mem_keys _ k _ hget)
      simp only [hget, atKernel] at h
      have h3 : X.obj? k = some (.kernel nm sc hd a b) := h.symm
      rw [ho] at hk
      rw [h3]
      exact hk
    | _ => rw [ho] at hk; cases hk

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- A forward result of the terminal graph on any state agreeing with it below `N`. -/
theorem forward_shrink (X : Ffi.St) (N : Nat) (hn : ∀ j, j < N → X.nodes.get j = X5.nodes.get j)
    (hk : ∀ k name, kernelName? SourceKernels.sources X5 k = some name → kernelName? SourceKernels.sources X k = some name)
    (tab : List F64) (hp : TokenSequenceRanges.Parameters (firstPipeline M K env tab leaves typed)) (time : Nat)
    (supported : time ≤ 262144) (cs : List Cache) (out : Nat)
    (h : ForwardResult M K env tab leaves typed hp time supported cs out) (hout : out < N)
    (hcs : cachesBelowB cs N = true) :
    ForwardAt M K env tab leaves typed hp time supported cs out (Gr tab X) := by
  have ev : ∀ i, i < N → ∀ v, evalR M K env (terminalGraph tab) i = some v → evalR M K env (Gr tab X) i = some v :=
    fun i hi v hv => evalR_extend M K env (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources X5 X i
      (fun j hj => hn j (by omega)) hk v hv
  have hbl := cachesBelow_of_B cs N hcs
  obtain ⟨hs, ⟨r, hr, hi⟩, hh, hc⟩ := h
  refine ⟨hs, ⟨r, ev out hout r hr, hi⟩, hh, ?_⟩
  unfold CacheValues at hc ⊢
  clear hh hcs
  induction hc with
  | nil => exact .nil
  | @cons c h cs hs hx _ ih =>
    obtain ⟨ta, tb, a, b, h1, h2, h3, h4, h5⟩ := hx
    exact .cons ⟨ta, tb, a, b, h1, h2, h3, ev _ (hbl c List.mem_cons_self ta (.inl h1)) _ h4,
      ev _ (hbl c List.mem_cons_self tb (.inr h2)) _ h5⟩
      (ih (fun c' hc' t ht => hbl c' (List.mem_cons_of_mem _ hc') t ht))

theorem token_value (ρ : Nat → F64) (tk : Nat → Nat) (S : List SymE) (tab : List F64) (j : Nat) (hj : j ≤ 262144)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ : ρ j = F64.ofNat (tk j)) (hS : nth? S j = some (.var j)) (htab : tab = S.map (SymE.eval ρ)) :
    CSrv.val ⟨tab⟩ (.ref j) = some (F64.ofNat ((firstContext M K env tab leaves typed
      (hpOf M K env leaves typed parameters tab)).run promptToken j hj).token.val) := by
  subst htab
  show nth? (S.map (SymE.eval ρ)) j = _
  rw [nth?_map, hS]
  show some (ρ j) = _
  rw [hρ, htk j hj, recurrence_token_table_eq M K env [] _ leaves typed parameters
    (hpOf M K env leaves typed parameters _) j hj]

/-- **The graph conclusions of the one-token budget.** -/
theorem short1_gf (ρ : Nat → F64) (tk : Nat → Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ1 : ρ 1 = F64.ofNat (tk 1)) :
    GF M K env leaves typed parameters 1 (Short1.S4.tab.map (SymE.eval ρ)) Short1.s4 := by
  let tab := Short1.S4.tab.map (SymE.eval ρ)
  have hn := nodes_of_check _ _ short1_nodes_check
  have hk := kernels_of_check _ short1_kernels_check
  obtain ⟨one, -, -, -, -⟩ := terminal_all_five M K env tab leaves typed (hpOf M K env leaves typed parameters tab)
  have f1 := forward_shrink M K env leaves typed _ _ hn hk tab _ _ _ _ _ one (by decide) short1_below1
  refine ⟨?_, ?_⟩
  · intro k h1 h2 hb
    obtain rfl : k = 1 := by omega
    exact ⟨_, _, f1⟩
  · refine (congrArg (ReadbackValues M K env _ _) short1_items_eq).mpr ?_
    obtain ⟨_, ⟨r, hr, hi⟩, _, _⟩ := f1
    refine ReadbackValues.set M K env _ _ (ReadbackValues.empty M K env _ _) 17776 (.ref 1) _ (by decide) ?_
      ⟨⟨r, hr, hi⟩, token_value M K env leaves typed parameters ρ tk _ tab 1 (by decide) htk hρ1 short1_ref1 rfl⟩
    have := ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
      promptToken 1 (by decide)).token.isLt
    omega

/-- **The graph conclusions of the two-token budget.** -/
theorem short2_gf (ρ : Nat → F64) (tk : Nat → Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hρ1 : ρ 1 = F64.ofNat (tk 1)) (hρ2 : ρ 2 = F64.ofNat (tk 2)) :
    GF M K env leaves typed parameters 2 (Short2.S2.tab.map (SymE.eval ρ)) Short2.s2 := by
  let tab := Short2.S2.tab.map (SymE.eval ρ)
  have hn := nodes_of_check _ _ short2_nodes_check
  have hk := kernels_of_check _ short2_kernels_check
  obtain ⟨one, two, -, -, -⟩ := terminal_all_five M K env tab leaves typed (hpOf M K env leaves typed parameters tab)
  have f1 := forward_shrink M K env leaves typed _ _ hn hk tab _ _ _ _ _ one (by decide) short2_below1
  have f2 := forward_shrink M K env leaves typed _ _ hn hk tab _ _ _ _ _ two (by decide) short2_below2
  refine ⟨?_, ?_⟩
  · intro k h1 h2 hb
    rcases (by omega : k = 1 ∨ k = 2) with rfl | rfl
    · exact ⟨_, _, f1⟩
    · exact ⟨_, _, f2⟩
  · refine (congrArg (ReadbackValues M K env _ _) short2_items_eq).mpr ?_
    obtain ⟨_, ⟨r1, hr1, hi1⟩, _, _⟩ := f1
    obtain ⟨_, ⟨r2, hr2, hi2⟩, _, _⟩ := f2
    have b1 := ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
      promptToken 1 (by decide)).token.isLt
    have b2 := ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
      promptToken 2 (by decide)).token.isLt
    refine ReadbackValues.set M K env _ _
      (ReadbackValues.set M K env _ _ (ReadbackValues.empty M K env _ _) 17776 (.ref 1) _ (by decide) (by omega)
        ⟨⟨r1, hr1, hi1⟩, token_value M K env leaves typed parameters ρ tk _ tab 1 (by decide) htk hρ1 short2_ref1 rfl⟩)
      20157 (.ref 2) _ (by decide) (by omega)
      ⟨⟨r2, hr2, hi2⟩, token_value M K env leaves typed parameters ρ tk _ tab 2 (by decide) htk hρ2 short2_ref2 rfl⟩

end Host.Mlx.SimGraph.Iter
