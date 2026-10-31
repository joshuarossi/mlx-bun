import host.sim.full.BridgeBack

/-! # The bridge's log and lock flags are a frame

No machine step reads the bridge's log or its programs' lock flags (`inLocked`, `outLocked`): each operation only
prepends to the log, and the flags are only written. So an operation on a bridge whose log ends in `L` and whose
programs differ only in their lock flags (`fB`, `SameP`) acts as on the bridge without them: `classify_fB`,
`schedule_fB`, `after_fB`, `wrap_fB`, and the program calls `input_fB`, `output_fB`, `evalAsync_fB`, `wait_fB`,
`free_fB`. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim
open Host.Mlx.FfiAne (Effect Program)

/-- A program without its lock flags. -/
def stripP (p : Program) : Program := { p with inLocked := [], outLocked := false }

/-- A bridge with `L` after its log (the log is newest first, so `L` is older) and programs `ps`. -/
def fB (L : List Effect) (ps : List Program) (b : BSt) : BSt := { b with programs := ps, log := b.log ++ L }

/-- `ps` are the bridge's programs up to lock flags. -/
def SameP (ps : List Program) (b : BSt) : Prop := ps.map stripP = b.programs.map stripP

theorem nth?_map_strip {l l' : List Program} (h : l'.map stripP = l.map stripP) (q : Nat) :
    (nth? l' q).map stripP = (nth? l q).map stripP := by
  induction l generalizing l' q with
  | nil => cases l' with
    | nil => rfl
    | cons _ _ => simp at h
  | cons a as ih => cases l' with
    | nil => simp at h
    | cons a' as' =>
      simp only [List.map_cons, List.cons.injEq] at h
      cases q with
      | zero => show some (stripP a') = some (stripP a); rw [h.1]
      | succ q => exact ih h.2 q

theorem setAt_map_strip {l l' : List Program} (h : l'.map stripP = l.map stripP) (q : Nat) {p p' : Program}
    (hp : stripP p' = stripP p) :
    (Host.Mlx.Ffi.setAt l' q p').map stripP = (Host.Mlx.Ffi.setAt l q p).map stripP := by
  induction l generalizing l' q with
  | nil => cases l' with
    | nil => rfl
    | cons _ _ => simp at h
  | cons a as ih => cases l' with
    | nil => simp at h
    | cons a' as' =>
      simp only [List.map_cons, List.cons.injEq] at h
      cases q with
      | zero => simp only [Host.Mlx.Ffi.setAt, List.map_cons, hp, h.2]
      | succ q => simp only [Host.Mlx.Ffi.setAt, List.map_cons, h.1, ih h.2 q]

theorem strip_holders {p p' : Program} (h : stripP p' = stripP p) : p'.holders = p.holders := congrArg (·.holders) h

section
variable {L : List Effect} {ps : List Program} {b : BSt}

/-! ## The operations that read no program -/

theorem aliasIns_fB : ∀ l : List Nat, Host.Mlx.FfiAne.aliasIns (fB L ps b) l = Host.Mlx.FfiAne.aliasIns b l
  | [] => rfl
  | i :: is => by
    have e : (fB L ps b).aliasOf i = b.aliasOf i := rfl
    simp only [Host.Mlx.FfiAne.aliasIns, e, aliasIns_fB is]

theorem classifyNode_fB (s : Host.Mlx.Ffi.St) (n : Nat) :
    Host.Mlx.FfiAne.classifyNode (fB L ps b) s n = (Host.Mlx.FfiAne.classifyNode b s n).map (fB L ps) := by
  unfold Host.Mlx.FfiAne.classifyNode
  cases s.nodes.get n with
  | none => rfl
  | some nd =>
    dsimp only
    rw [aliasIns_fB]
    cases Host.Mlx.FfiAne.aliasIns b nd.ins with
    | nil => rfl
    | cons a as =>
      dsimp only
      repeat' split
      all_goals first
        | rfl
        | (simp only [Bool.cond_eq_ite]; split <;> rfl)

theorem classify_fB (s : Host.Mlx.Ffi.St) : ∀ (f : Nat) (b : BSt) (n : Nat),
    Host.Mlx.FfiAne.classify (fB L ps b) s f n = (Host.Mlx.FfiAne.classify b s f n).map (fB L ps)
  | 0, _, _ => rfl
  | f + 1, b, n => by
    simp only [Host.Mlx.FfiAne.classify]
    cases Nat.blt n s.nnext
    · rfl
    · simp only [Bool.cond_true]
      rw [classifyNode_fB]
      cases Host.Mlx.FfiAne.classifyNode b s n with
      | none => rfl
      | some b1 => simpa only [Option.map_some, Option.bind_some] using classify_fB s f b1 (n + 1)

theorem wrap_fB (s : Host.Mlx.Ffi.St) (args : List Arg) :
    Host.Mlx.FfiAne.wrap (fB L ps b) s args =
      (Host.Mlx.FfiAne.wrap b s args).map fun q => (q.1, fB L ps q.2.1, q.2.2) := by
  have hs : ∀ a, Host.Mlx.FfiAne.surfaceOf (fB L ps b) a = Host.Mlx.FfiAne.surfaceOf b a := fun _ => rfl
  have hz : ∀ i, (fB L ps b).surfaceSize i = b.surfaceSize i := fun _ => rfl
  unfold Host.Mlx.FfiAne.wrap
  match args with
  | [p, sh, nd, dt, _, _] =>
    dsimp only
    rw [hs]
    cases Host.Mlx.FfiAne.surfaceOf b p with
    | none => rfl
    | some sid =>
      cases Host.Mlx.Ffi.dimsArg sh nd with
      | none => rfl
      | some shape =>
        cases Host.Mlx.Ffi.argNat dt with
        | none => rfl
        | some d =>
          dsimp only
          cases Host.Mlx.Ffi.natsOfDims shape with
          | none => rfl
          | some ds =>
            dsimp only
            rw [hz]
            cases Nat.beq (ds.foldr (· * ·) 1 * Host.Mlx.Ffi.dtSize d) (b.surfaceSize sid) <;> rfl
  | [] | [_] | [_, _] | [_, _, _] | [_, _, _, _] | [_, _, _, _, _] | _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ => rfl

/-! ## What reads a program reads no lock flag -/

theorem any_strip (f : Program → Bool) (hf : ∀ p, f (stripP p) = f p) (l : List Program) :
    (l.map stripP).any f = l.any f := by
  induction l with
  | nil => rfl
  | cons a as ih => simp only [List.map_cons, List.any_cons, hf, ih]

theorem zipIdx_all_strip (g : Program × Nat → Bool) (hg : ∀ p i, g (stripP p, i) = g (p, i)) (l : List Program) (n : Nat) :
    ((l.map stripP).zipIdx n).all g = (l.zipIdx n).all g := by
  induction l generalizing n with
  | nil => rfl
  | cons a as ih => simp only [List.map_cons, List.zipIdx_cons, List.all_cons, hg, ih]

theorem pendingClash_fB (h : SameP ps b) (X : Nat) (w : Bool) :
    Host.Mlx.FfiAne.pendingClash (fB L ps b) X w = Host.Mlx.FfiAne.pendingClash b X w := by
  unfold Host.Mlx.FfiAne.pendingClash
  show ps.any _ = b.programs.any _
  rw [← any_strip _ (fun _ => rfl) ps, ← any_strip _ (fun _ => rfl) b.programs, h]

theorem eventOk_fB (h : SameP ps b) (newly : List Nat) :
    Host.Mlx.FfiAne.eventOk (fB L ps b) newly = Host.Mlx.FfiAne.eventOk b newly := by
  unfold Host.Mlx.FfiAne.eventOk
  simp only [pendingClash_fB h]
  rfl

theorem schedule_fB (h : SameP ps b) (s : Host.Mlx.Ffi.St) (roots : List Nat) (bl : Bool) :
    Host.Mlx.FfiAne.schedule (fB L ps b) s roots bl = (Host.Mlx.FfiAne.schedule b s roots bl).map (fB L ps) := by
  unfold Host.Mlx.FfiAne.schedule
  have hu : (fB L ps b).unscheduled = b.unscheduled := rfl
  have hr : (fB L ps b).running = b.running := rfl
  simp only [hu, hr, eventOk_fB h]
  cases (b.unscheduled.isEmpty && (!bl || b.running.isEmpty))
  · simp only [Bool.cond_false]
    cases b.unscheduled ++ b.running with
    | nil => rfl
    | cons t ts =>
      dsimp only
      cases Host.Mlx.FfiAne.reachOf s (Host.Mlx.FfiAne.minL t ts) roots with
      | none => rfl
      | some seen =>
        dsimp only
        cases Host.Mlx.FfiAne.eventOk b (b.unscheduled.filter fun n => (seen.get n).isSome)
        · rfl
        · cases (b.unscheduled.filter fun n => (seen.get n).isSome).isEmpty <;> rfl
  · rfl

theorem after_fB (h : SameP ps b) (s s' : Host.Mlx.Ffi.St) (name : Name) (args : List Arg) :
    Host.Mlx.FfiAne.after (fB L ps b) s s' name args = (Host.Mlx.FfiAne.after b s s' name args).map (fB L ps) := by
  unfold Host.Mlx.FfiAne.after
  cases Host.Mlx.FfiAne.evalCall s name args with
  | roots ns bl => exact schedule_fB h s ns bl
  | all => rfl
  | other => exact classify_fB s' _ b _

/-! ## The program calls -/

/-- The program a handle names is the same up to lock flags. -/
theorem program?_fB (h : SameP ps b) (n : Nat) {q : Nat} {p : Program} (e : Host.Mlx.FfiAne.program? b n = some (q, p)) :
    ∃ p', Host.Mlx.FfiAne.program? (fB L ps b) n = some (q, p') ∧ stripP p' = stripP p := by
  unfold Host.Mlx.FfiAne.program? at e ⊢
  show ∃ p', (match b.handles.get n with
    | some q => match nth? ps q with
      | some p => bif Nat.beq p.holders 0 then none else some (q, p)
      | none => none
    | none => none) = some (q, p') ∧ _
  cases hh : b.handles.get n with
  | none => rw [hh] at e; cases e
  | some q0 =>
    rw [hh] at e
    dsimp only at e ⊢
    have hm := nth?_map_strip h q0
    cases hn : nth? b.programs q0 with
    | none => rw [hn] at e; cases e
    | some p0 =>
      rw [hn] at e hm
      dsimp only at e
      cases hn' : nth? ps q0 with
      | none => rw [hn'] at hm; cases hm
      | some p1 =>
        rw [hn'] at hm
        have hs : stripP p1 = stripP p0 := by simpa using hm
        dsimp only
        rw [strip_holders hs]
        cases hb : Nat.beq p0.holders 0
        · rw [hb, Bool.cond_false] at e
          simp only [Option.some.injEq, Prod.mk.injEq] at e
          obtain ⟨rfl, rfl⟩ := e
          exact ⟨p1, by rw [Bool.cond_false], hs⟩
        · rw [hb, Bool.cond_true] at e; cases e

theorem same_set (h : SameP ps b) (q : Nat) {p p' : Program} (hs : stripP p' = stripP p) :
    SameP (Host.Mlx.Ffi.setAt ps q p') (Host.Mlx.FfiAne.setProgram b q p) :=
  setAt_map_strip h q hs

theorem input_fB (h : SameP ps b) {n : Nat} {i : Arg} {b1 : BSt} {r : Ret} (e : Host.Mlx.FfiAne.input b n i = some (b1, r)) :
    ∃ ps1, Host.Mlx.FfiAne.input (fB L ps b) n i = some (fB L ps1 b1, r) ∧ SameP ps1 b1 := by
  unfold Host.Mlx.FfiAne.input at e ⊢
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    obtain ⟨q, p⟩ := qp
    obtain ⟨p', hp', hs⟩ := program?_fB (L := L) h n hp
    obtain ⟨pr, is, o, ho, pe, il, ol⟩ := p
    obtain ⟨pr', is', o', ho', pe', il', ol'⟩ := p'
    simp only [stripP, Program.mk.injEq, and_true] at hs
    obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := hs
    rw [hp] at e
    rw [hp']
    cases hi : Host.Mlx.Ffi.argInt i with
    | none => rw [hi] at e; cases e
    | some j =>
      rw [hi] at e
      dsimp only at e ⊢
      cases hc : (decide (0 ≤ j) && Nat.blt j.toNat (Host.Ts.len is'))
      · rw [hc, Bool.cond_false] at e
        simp only [Option.some.injEq, Prod.mk.injEq] at e
        obtain ⟨rfl, rfl⟩ := e
        exact ⟨ps, by rw [Bool.cond_false], h⟩
      · rw [hc, Bool.cond_true] at e
        simp only [Option.some.injEq, Prod.mk.injEq] at e
        obtain ⟨rfl, rfl⟩ := e
        exact ⟨Host.Mlx.Ffi.setAt ps q ⟨pr', is', o', ho', pe', Host.Mlx.Ffi.setAt il' j.toNat true, ol'⟩,
          by rw [Bool.cond_true]; rfl, same_set h q rfl⟩

theorem output_fB (h : SameP ps b) {n : Nat} {b1 : BSt} {r : Ret} (e : Host.Mlx.FfiAne.output b n = some (b1, r)) :
    ∃ ps1, Host.Mlx.FfiAne.output (fB L ps b) n = some (fB L ps1 b1, r) ∧ SameP ps1 b1 := by
  unfold Host.Mlx.FfiAne.output at e ⊢
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    obtain ⟨q, p⟩ := qp
    obtain ⟨p', hp', hs⟩ := program?_fB (L := L) h n hp
    obtain ⟨pr, is, o, ho, pe, il, ol⟩ := p
    obtain ⟨pr', is', o', ho', pe', il', ol'⟩ := p'
    simp only [stripP, Program.mk.injEq, and_true] at hs
    obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := hs
    rw [hp] at e
    rw [hp']
    simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    exact ⟨Host.Mlx.Ffi.setAt ps q ⟨pr', is', o', ho', pe', il', true⟩, rfl, same_set h q rfl⟩

theorem startOk_fB (h : SameP ps b) (q : Nat) (p : Program) :
    Host.Mlx.FfiAne.startOk (fB L ps b) q p = Host.Mlx.FfiAne.startOk b q p := by
  unfold Host.Mlx.FfiAne.startOk
  show (_ && _ && (ps.zipIdx 0).all _) = (_ && _ && (b.programs.zipIdx 0).all _)
  rw [← zipIdx_all_strip _ (fun _ _ => rfl) ps, ← zipIdx_all_strip _ (fun _ _ => rfl) b.programs, h]
  rfl

theorem startOk_locks (b : BSt) (q : Nat) (pr : Host.Mlx.AneProgram) (is : List Nat) (o ho : Nat) (pe : Bool)
    (il il' : List Bool) (ol ol' : Bool) :
    Host.Mlx.FfiAne.startOk b q ⟨pr, is, o, ho, pe, il', ol'⟩ = Host.Mlx.FfiAne.startOk b q ⟨pr, is, o, ho, pe, il, ol⟩ := rfl

theorem evalAsync_fB (h : SameP ps b) {n : Nat} {b1 : BSt} {r : Ret} (e : Host.Mlx.FfiAne.evalAsync b n = some (b1, r)) :
    ∃ ps1, Host.Mlx.FfiAne.evalAsync (fB L ps b) n = some (fB L ps1 b1, r) ∧ SameP ps1 b1 := by
  unfold Host.Mlx.FfiAne.evalAsync at e ⊢
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    obtain ⟨q, p⟩ := qp
    obtain ⟨p', hp', hs⟩ := program?_fB (L := L) h n hp
    obtain ⟨pr, is, o, ho, pe, il, ol⟩ := p
    obtain ⟨pr', is', o', ho', pe', il', ol'⟩ := p'
    simp only [stripP, Program.mk.injEq, and_true] at hs
    obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := hs
    rw [hp] at e
    rw [hp']
    dsimp only at e ⊢
    rw [startOk_fB h q, startOk_locks b q pr' is' o' ho' pe' il il' ol ol']
    cases pe'
    · rw [Bool.cond_false] at e
      rw [Bool.cond_false]
      cases hso : Host.Mlx.FfiAne.startOk b q ⟨pr', is', o', ho', false, il, ol⟩
      · rw [hso, Bool.cond_false] at e; cases e
      · rw [hso, Bool.cond_true] at e
        simp only [Option.some.injEq, Prod.mk.injEq] at e
        obtain ⟨rfl, rfl⟩ := e
        exact ⟨Host.Mlx.Ffi.setAt ps q ⟨pr', is', o', ho', true, il'.map fun _ => false, false⟩,
          by rw [Bool.cond_true]; rfl, same_set h q rfl⟩
    · rw [Bool.cond_true] at e
      simp only [Option.some.injEq, Prod.mk.injEq] at e
      obtain ⟨rfl, rfl⟩ := e
      exact ⟨ps, by rw [Bool.cond_true], h⟩

theorem wait_fB (h : SameP ps b) {n : Nat} {b1 : BSt} {r : Ret} (e : Host.Mlx.FfiAne.wait b n = some (b1, r)) :
    ∃ ps1, Host.Mlx.FfiAne.wait (fB L ps b) n = some (fB L ps1 b1, r) ∧ SameP ps1 b1 := by
  unfold Host.Mlx.FfiAne.wait at e ⊢
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    obtain ⟨q, p⟩ := qp
    obtain ⟨p', hp', hs⟩ := program?_fB (L := L) h n hp
    obtain ⟨pr, is, o, ho, pe, il, ol⟩ := p
    obtain ⟨pr', is', o', ho', pe', il', ol'⟩ := p'
    simp only [stripP, Program.mk.injEq, and_true] at hs
    obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := hs
    rw [hp] at e
    rw [hp']
    dsimp only at e ⊢
    cases pe'
    · rw [Bool.cond_false] at e
      simp only [Option.some.injEq, Prod.mk.injEq] at e
      obtain ⟨rfl, rfl⟩ := e
      exact ⟨ps, by rw [Bool.cond_false], h⟩
    · rw [Bool.cond_true] at e
      simp only [Option.some.injEq, Prod.mk.injEq] at e
      obtain ⟨rfl, rfl⟩ := e
      exact ⟨Host.Mlx.Ffi.setAt ps q ⟨pr', is', o', ho', false, il', ol'⟩,
        by rw [Bool.cond_true]; rfl, same_set h q rfl⟩

theorem free_fB (h : SameP ps b) {n : Nat} {b1 : BSt} {r : Ret} (e : Host.Mlx.FfiAne.free b n = some (b1, r)) :
    ∃ ps1, Host.Mlx.FfiAne.free (fB L ps b) n = some (fB L ps1 b1, r) ∧ SameP ps1 b1 := by
  unfold Host.Mlx.FfiAne.free at e ⊢
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    obtain ⟨q, p⟩ := qp
    obtain ⟨p', hp', hs⟩ := program?_fB (L := L) h n hp
    obtain ⟨pr, is, o, ho, pe, il, ol⟩ := p
    obtain ⟨pr', is', o', ho', pe', il', ol'⟩ := p'
    simp only [stripP, Program.mk.injEq, and_true] at hs
    obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := hs
    rw [hp] at e
    rw [hp']
    simp only [Option.map_some, Option.some.injEq] at e ⊢
    cases hh : Nat.beq ho' 1
    · simp only [hh, Bool.cond_false] at e ⊢
      simp only [Prod.mk.injEq] at e
      obtain ⟨rfl, rfl⟩ := e
      exact ⟨Host.Mlx.Ffi.setAt ps q ⟨pr', is', o', ho' - 1, pe', il', ol'⟩, rfl, same_set h q rfl⟩
    · simp only [hh, Bool.cond_true] at e ⊢
      simp only [Prod.mk.injEq] at e
      obtain ⟨rfl, rfl⟩ := e
      refine ⟨Host.Mlx.Ffi.setAt ps q ⟨pr', is', o', 0, false, il'.map fun _ => false, false⟩, ?_, same_set h q rfl⟩
      cases pe' <;> rfl

end

end Host.Ts.Sim.Full
