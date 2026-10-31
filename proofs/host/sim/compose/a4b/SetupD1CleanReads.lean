import host.sim.template.a4pre_d1_clean_reads.Dispatch
import host.sim.template.a4pre_d1_clean_reads.Facts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1CleanReads
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Load.Run.Prompt Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Template

/-- Internal provenance attached to the unchanged loaded cut. -/
noncomputable def ldCleanCut (π : List Nat) (T : Nat) (tk : Nat → Nat) : ICut FF :=
  withReadGrowth (mlxOf (ldStT (π.map natV) (machReads T tk)).ffi) (routeServer T tk)
    (ldCut 15235 setupP wideP (ldStT [] []) T tk 1)

/-- The existing saved-input cut retains its exact witnesses and the whole native growth. -/
noncomputable def forwardCleanInputCut (π : List Nat) (T : Nat) (tk : Nat → Nat) : ICut FF :=
  withReadGrowth (mlxOf (ldStT (π.map natV) (machReads T tk)).ffi) (routeServer T tk)
    (SetupD1SavedCells.forwardSavedInputCut 15235 T tk)

/-- The checked 900 + 101 + 1407 + 603 producer, including source compaction. -/
theorem ldCleanCut_forward (π : List Nat) {T : Nat} {tk : Nat → Nat}
    (hctx : 1 + T ≤ 262144) :
    CutStep (ldCleanCut π T tk) (forwardCleanInputCut π T tk) 3011 :=
  ((ldCut_next_clean hctx _ _).trans (dispatch_input_clean _ _)).cast rfl rfl rfl

/-- The actual load's weak certificate acquires only constructor-derived bookkeeping. -/
theorem concrete_loaded_initial (π : List Nat) {T : Nat} {tk : Nat → Nat}
    (hload : (ldCut 15235 setupP wideP (ldStT [] []) T tk 1).Inv
      (ldStT (π.map natV) (machReads T tk)) (routeServer T tk)) :
    (ldCleanCut π T tk).Inv (ldStT (π.map natV) (machReads T tk)) (routeServer T tk) :=
  loaded_initial π hload

/-- The source and its suffix give the target queue's length, independent of map values. -/
theorem forward_queue_length (π : List Nat) {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hr : (SetupD1SavedCells.forwardSavedInputCut 15235 T tk).R x
      D1Call.s1 ⟨D1Call.S1.tab, []⟩) :
    (mlxOf (ldStT (π.map natV) (machReads T tk)).ffi).tokens.length =
      (mlxOf x.t.ffi).tokens.length := by
  obtain ⟨π', K0, hrel, hbook, hinput, hreserved, hemitted⟩ := hr
  obtain ⟨P', hP, hn⟩ := hrel.ffi.1
  have hrest : P'.rest = machReads T tk := by
    rcases hP with rfl | ⟨k, _, _, rfl⟩ <;> rfl
  have ht := hn.load.mlx.tokensX
  change (mlxOf x.t.ffi).tokens = (mlxOf D1Call.s1.ffi).tokens.map x.M.nv ++ P'.rest at ht
  rw [forward_tokens, hrest] at ht
  rw [loaded_tokens, ht]
  simp only [List.length_cons, List.length_append, List.length_map, List.length_nil]
  omega

/-- Equal queues force zero pops and preserve the entire concrete loaded item trie. -/
theorem forward_clean_items {π : List Nat} {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hr : (forwardCleanInputCut π T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩) :
    (mlxOf x.t.ffi).items = .nil :=
  empty_of_queue_length hr.2.native (forward_queue_length π hr.1) (loaded_items _ _)

/-- Recover every original forward witness, with the exact input node and saved binding. -/
theorem forward_witness {π0 : List Nat} {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hr : (forwardCleanInputCut π0 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩) :
    ∃ π K0,
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } 15235))
        (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1Call.s1 ⟨D1Call.S1.tab, []⟩ x.t x.C ∧
      SetupD1.ForwardBook π K0 x ∧ SetupD1Input.InputAt π (x.M.node 15235) x.t x.C ∧
      SetupD1SavedCells.Reserved T tk x.ν ∧ x.M.a 2590 = 2590 ∧
      Host.Mlx.Ffi.NGrow (mlxOf (ldStT (π0.map natV) (machReads T tk)).ffi) (mlxOf x.t.ffi) ∧
      (mlxOf x.t.ffi).items = .nil := by
  obtain ⟨π, K0, hrel, hbook, hinput, hreserved, hemitted⟩ := hr.1
  exact ⟨π, K0, hrel, hbook, hinput, hreserved, hemitted, hr.2.native, forward_clean_items hr⟩

/-- Forgetting cleanliness preserves the exact saved-input witness. -/
theorem forward_forget (π : List Nat) (T : Nat) (tk : Nat → Nat) :
    CutConv (forwardCleanInputCut π T tk) (SetupD1SavedCells.forwardSavedInputCut 15235 T tk) :=
  withReadGrowth_forget _ _ _

/-- Internal producer adapter from the existing concrete weak load certificate. No new
route field, readback premise, or run/future-result premise is introduced. -/
theorem producer (π : List Nat) {T : Nat} {tk : Nat → Nat} (hctx : 1 + T ≤ 262144)
    (hload : (ldCut 15235 setupP wideP (ldStT [] []) T tk 1).Inv
      (ldStT (π.map natV) (machReads T tk)) (routeServer T tk)) :
    ∃ x : SegInst FF,
      runC FF 3011 (ldStT (π.map natV) (machReads T tk)) (routeServer T tk) = some (x.t, x.C) ∧
      (SetupD1SavedCells.forwardSavedInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩ ∧
      (SetupD1SavedCells.forwardSavedInputCut 15235 T tk).B x ∧
      Host.Mlx.Ffi.NGrow (mlxOf (ldStT (π.map natV) (machReads T tk)).ffi) (mlxOf x.t.ffi) ∧
      CSrv.Le (routeServer T tk) x.C ∧
      (mlxOf (ldStT (π.map natV) (machReads T tk)).ffi).tokens.length = (mlxOf x.t.ffi).tokens.length ∧
      (mlxOf x.t.ffi).items = .nil := by
  obtain ⟨t', C', hrun, x, ht, hc, hr, hb⟩ :=
    ldCleanCut_forward π hctx _ _ (concrete_loaded_initial π hload)
  rw [← ht, ← hc] at hrun
  exact ⟨x, hrun, hr.1, hb.1, hr.2.native, hr.2.server, forward_queue_length π hr.1, forward_clean_items hr⟩

end Host.Ts.Sim.Compose.SetupD1CleanReads
