import host.sim.dispatch.DecideExpr
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.StmtSim

/-! # Deciders for the side conditions of steps/Stmt.lean and steps/Loop.lean

Allocation counts of block entry (one cell per lexical name, one closure per
named function declaration), `for (let …)` copies and `catch` parameters. -/

section
variable {S' : Type}

/-- Block entry: few names, and the function prototype present if it declares functions. -/
def blockB (s : St S') (ss : List Stmt) : Bool :=
  Nat.ble ((blockNames ss).length + ss.length) two20 && (!(ss.any isFuncDecl) || presB s aFunctionProto)

theorem blockB_sound {s : St S'} {ss : List Stmt} (h : blockB s ss = true) :
    (blockNames ss).length + ss.length ≤ 2 ^ 20 ∧ (ss.any isFuncDecl = true → Present s aFunctionProto) := by
  simp only [blockB, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  refine ⟨le20 h.1, fun hf => ?_⟩
  rcases h.2 with h2 | h2
  · rw [hf] at h2; cases h2
  · exact h2

/-- An optional `finally` block. -/
def finB (s : St S') : Option (List Stmt) → Bool
  | some ss => blockB s ss
  | none => true

theorem finB_sound {s : St S'} {fin : Option (List Stmt)} (h : finB s fin = true) :
    (∀ ss, fin = some ss → (blockNames ss).length + ss.length ≤ 2 ^ 20) ∧
    (∀ ss, fin = some ss → ss.any isFuncDecl = true → Present s aFunctionProto) := by
  constructor
  · rintro ss rfl; exact (blockB_sound h).1
  · rintro ss rfl; exact (blockB_sound h).2

/-- A `catch` handler: its block and its parameter's names. -/
def handlerB (s : St S') : Option (Option Pat × List Stmt) → Bool
  | some (q, body) => blockB s body && (match q with
    | some p => Nat.ble (patNames p).length two20
    | none => true)
  | none => true

theorem handlerB_sound {s : St S'} {hd : Option (Option Pat × List Stmt)} (h : handlerB s hd = true) :
    (∀ q body, hd = some (q, body) →
      (blockNames body).length + body.length ≤ 2 ^ 20 ∧ ∀ p, q = some p → (patNames p).length ≤ 2 ^ 20) ∧
    (∀ q ss, hd = some (q, ss) → ss.any isFuncDecl = true → Present s aFunctionProto) := by
  constructor
  · rintro q body rfl
    simp only [handlerB, Bool.and_eq_true] at h
    refine ⟨(blockB_sound h.1).1, ?_⟩
    rintro p rfl
    exact le20 h.2
  · rintro q ss rfl
    simp only [handlerB, Bool.and_eq_true] at h
    exact (blockB_sound h.1).2

/-- The `hI` premise of `step_abr_try` from the two deciders. -/
theorem tryI_sound {s : St S'} {hd : Option (Option Pat × List Stmt)} {fin : Option (List Stmt)}
    (h1 : finB s fin = true) (h2 : handlerB s hd = true) :
    ∀ ss, (fin = some ss ∨ ∃ q, hd = some (q, ss)) → ss.any isFuncDecl = true → Present s aFunctionProto := by
  rintro ss (hf | ⟨q, hq⟩)
  · exact (finB_sound h1).2 ss hf
  · exact (handlerB_sound h2).2 q ss hq

/-- `for (let …)` declarations. -/
def forInitB : Option ForHead → Bool
  | some (.decl _ ds) => Nat.ble (declsNames ds).length two20
  | _ => true

theorem forInitB_sound {init : Option ForHead} (h : forInitB init = true) :
    ∀ k ds, init = some (.decl k ds) → (declsNames ds).length ≤ 2 ^ 20 := by
  rintro k ds rfl
  exact le20 h

end
end Host.Ts.Sim.Disp
