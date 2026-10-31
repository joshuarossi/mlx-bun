import host.sim.footprint.HeapExpr
import host.sim.steps.Stmt

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim StmtSim

variable {S : Type}

/-- Lexical cells are allocated at successive fresh addresses. -/
theorem allocCells_fresh (s : St S) (names : List Name) (env : Env) :
    Fresh s (allocCells s names env).2 := by
  induction names generalizing s env with
  | nil => exact Fresh.refl s
  | cons n ns ih =>
    rw [cells_cons]
    exact (Fresh.alloc s _).trans (ih _ _)

/-- Every declared name shadows the incoming environment with a fresh cell. -/
theorem allocCells_lookup_fresh (s : St S) (names : List Name) (env : Env)
    {n : Name} {c : Nat} (hm : n ∈ names)
    (hl : lookupEnv n (allocCells s names env).1 = some c) : s.next ≤ c := by
  obtain ⟨pre, he, hnames, hfresh, _⟩ := cells_shape names s env
  have hm' : n ∈ pre.map Prod.fst := by
    rw [hnames]
    exact List.mem_reverse.2 hm
  obtain ⟨c', hl'⟩ := lookupEnv_of_mem hm'
  rw [he, lookupEnv_append_some env hl'] at hl
  cases hl
  obtain ⟨m, hmc⟩ := env_lookup_mem hl'
  exact hfresh _ hmc

/-- Hoisted functions write their freshly shadowing lexical cells. -/
theorem initFuncs_fresh {s : St S} (env : Env) : ∀ (ss : List Stmt) (u : St S),
    Fresh s u →
    (∀ n c, n ∈ blockNames ss → lookupEnv n env = some c → s.next ≤ c) →
    Fresh s (initFuncs u env ss)
  | [], _, h, _ => h
  | st :: ss, u, h, he => by
    have he' : ∀ n c, n ∈ blockNames ss → lookupEnv n env = some c → s.next ≤ c :=
      fun n c hm hl => he n c (List.mem_append_right _ hm) hl
    cases hst : isFuncDecl st with
    | false =>
      rw [initF_other _ _ _ _ hst]
      exact initFuncs_fresh env ss u h he'
    | true =>
      cases st
      case func f =>
        obtain ⟨nm, ps, r, b, a, g, pr⟩ := f
        cases nm with
        | none => cases hst
        | some n =>
          cases hl : lookupEnv n env with
          | none =>
            rw [initF_none _ _ _ _ _ _ _ _ _ _ hl]
            exact initFuncs_fresh env ss u h he'
          | some c =>
            rw [initF_some _ _ _ _ _ _ _ _ _ _ hl]
            have hc := he n c (by simp [blockNames, stmtNames]) hl
            exact initFuncs_fresh env ss _ ((h.trans (Fresh.alloc u _)).write hc _) he'
      all_goals cases hst

/-- Hoisting only allocates and initializes addresses above the incoming counter. -/
theorem hoist_fresh (s : St S) (ss : List Stmt) (env : Env) :
    Fresh s (hoist s ss env).2 := by
  rw [hoist_cond]
  cases (blockNames ss).isEmpty
  · exact initFuncs_fresh _ ss _ (allocCells_fresh s _ env)
      (fun _ _ hm hl => allocCells_lookup_fresh s _ env hm hl)
  · exact Fresh.refl s

theorem enterBlock_fresh (s : St S) (ss : List Stmt) (env : Env) :
    Fresh s (enterBlock s ss env) :=
  (hoist_fresh s ss env).trans (Fresh.of_same ⟨rfl, rfl⟩)

end Host.Ts.Sim.HeapFoot
