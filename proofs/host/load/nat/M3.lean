import host.load.nat.M2
namespace Host.Ts.FfiNat
open Host.Ts
set_option maxHeartbeats 4000000

rel_derive retE
rel_derive_ffi retE
rel_derive startIter
rel_derive_ffi startIter
rel_derive spreadElems
rel_derive_ffi spreadElems
rel_derive retC
rel_derive_ffi retC
rel_derive taggedNext
rel_derive_ffi taggedNext
rel_derive retL
rel_derive_ffi retL
rel_derive writeVar
rel_derive_ffi writeVar
rel_derive_indep numCell
rel_derive_indep toCell
rel_derive typedPut
rel_derive_ffi typedPut
rel_derive putV.putOrd
rel_derive_ffi putV.putOrd
rel_derive putV
rel_derive_ffi putV
rel_derive privPutV
rel_derive_ffi privPutV
rel_derive storeTarget
rel_derive_ffi storeTarget
rel_derive retA
rel_derive_ffi retA
rel_derive finOrResume
rel_derive_ffi finOrResume
rel_derive runCases
rel_derive_ffi runCases
rel_derive switchNext
rel_derive_ffi switchNext
rel_derive retSt
rel_derive_ffi retSt
rel_derive copyIter
rel_derive_ffi copyIter
rel_derive nextIter
rel_derive_ffi nextIter
rel_derive forTestStep
rel_derive_ffi forTestStep
rel_derive forOfStep.forOfBind
rel_derive_ffi forOfStep.forOfBind
rel_derive forOfStep
rel_derive_ffi forOfStep
rel_derive retLp
rel_derive_ffi retLp
rel_derive arrNext
rel_derive_ffi arrNext
rel_derive restObj
rel_derive_ffi restObj
rel_derive objPatNext
rel_derive_ffi objPatNext
rel_derive retB
rel_derive_ffi retB
rel_derive_state agenDrain

@[rel_simp] theorem agenDrain_ffi {S : Type} (s : St S) (g : Nat) : (agenDrain s g).ffi = s.ffi := by
  have h := @rel_agenDrain (stateFfi S) (stateFfi S) (idRel _) (idReadSim _) s s.ffi rfl g
  have h2 := congrArg St.ffi h
  exact h2

rel_derive agenComplete
rel_derive_ffi agenComplete
rel_derive boundaryRet
rel_derive_ffi boundaryRet
rel_derive startBody
rel_derive_ffi startBody
rel_derive enterBody
rel_derive_ffi enterBody
rel_derive paramsNext
rel_derive_ffi paramsNext
rel_derive setKlassInst
rel_derive_ffi setKlassInst
rel_derive privMethodProp
rel_derive_ffi privMethodProp
rel_derive thisEnv
rel_derive_ffi thisEnv
rel_derive classNext
rel_derive_ffi classNext
rel_derive classKeyed
rel_derive_ffi classKeyed
rel_derive fieldsNext
rel_derive_ffi fieldsNext
rel_derive enterClosure
rel_derive_ffi enterClosure
rel_derive applyWrites
rel_derive_ffi applyWrites
rel_derive ffiCallback
rel_derive_ffi ffiCallback
theorem applyWrites_ffi (F : Ffi) : ∀ (s : St F.S) (ws : List (Nat × Nat × List Byte)) (t : St F.S),
    applyWrites F s ws = some t → t.ffi = s.ffi
  | s, [], t, h => by cases h; rfl
  | s, (b, off, bytes) :: ws, t, h => by
    unfold applyWrites at h
    split at h
    · split at h
      · exact (applyWrites_ffi F _ ws t h).trans rfl
      · cases h
    · cases h

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]

/-- A native call's result, related results (the second world's state rebuilt on the first's). -/
theorem rel_ffiDone (a0 : St F1.S) (a0_x : F2.S) (a0_hx : FfiRel.R a0.ffi a0_x) (a1 : Name) (a2 : List Arg)
    (a3 : Option (F1.S × Ret × List (Nat × Nat × List Byte))) (a3' : Option (F2.S × Ret × List (Nat × Nat × List Byte)))
    (a3_h : CRel.r a3 a3') : MR CRel.r (ffiDone F1 a0 a1 a2 a3) (ffiDone F2 (a0.reFfi a0_x) a1 a2 a3') := by
  rcases a3 with _ | ⟨st1, r1, ws1⟩ <;> rcases a3' with _ | ⟨st2, r2, ws2⟩
  · exact MR.fail
  · exact a3_h.elim
  · exact a3_h.elim
  · obtain ⟨h1, h2⟩ : FfiRel.R st1 st2 ∧ (r1, ws1) = (r2, ws2) := a3_h
    cases h2
    show MR CRel.r (ffiDone F1 a0 a1 a2 (some (st1, r1, ws1)))
      (ffiDone F2 ((a0.setFfi st1).reFfi st2) a1 a2 (some (st2, r1, ws1)))
    unfold ffiDone
    dsimp only
    cases hw : applyWrites F1 (a0.setFfi st1) ws1 with
    | none =>
      have hx : FfiRel.R (a0.setFfi st1).ffi st2 := h1
      rel_auto
    | some s =>
      have hx : FfiRel.R (a0.setFfi st1).ffi st2 := h1
      have hs : FfiRel.R s.ffi st2 := by rw [applyWrites_ffi F1 _ _ _ hw]; exact h1
      rel_auto

end

rel_derive decodeArg
rel_derive_ffi decodeArg
rel_derive jsonResume
rel_derive_ffi jsonResume
rel_derive nativeRet
rel_derive_ffi nativeRet

end Host.Ts.FfiNat
