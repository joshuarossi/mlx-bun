import host.sim.footprint.HeapStmtBasic
import host.sim.dispatch.Ex

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv StmtSim Disp
open Host.Mlx.Ffi.FullKeep (AllX)

theorem declNext_fresh (F : Ffi) (s : St F.S) (kind : DeclKind)
    (ds : List (Pat × Option Expr)) (env : Env) : AllX (Fresh s) (declNext F s kind ds env) := by
  cases ds with
  | nil => exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | cons d ds =>
    obtain ⟨p, e⟩ := d
    cases e <;> exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)

theorem forStart_fresh (F : Ffi) (s : St F.S) (init : Option ForHead)
    (test update : Option Expr) (body : Stmt) (env : Env) (labels : List Name) :
    AllX (Fresh s) (forStart F s init test update body env labels) := by
  cases init with
  | none => exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | some init =>
    cases init with
    | expr e => exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    | decl kind ds =>
      cases kind <;> simp only [forStart]
      all_goals first
        | exact allX_fail _ _
        | refine Fresh.after (u := (allocCells s (declsNames ds) env).2.push
            (.lp (.forTest true test update body (allocCells s (declsNames ds) env).1
              (declsNames ds) labels))) ?_ (declNext_fresh _ _ _ _ _)
          exact (allocCells_fresh s _ env).trans (Fresh.of_same ⟨rfl, rfl⟩)

theorem labelFrames_same {S : Type} (s : St S) (labels : List Name) :
    Same s (labels.foldl (fun s l => s.push (.s (.label l))) s) := by
  induction labels generalizing s with
  | nil => exact ⟨rfl, rfl⟩
  | cons l ls ih => exact ih (s.push (.s (.label l)))

/-- Label traversal either prepares one loop or changes only control and stack. -/
theorem exLoopF_fresh (F : Ffi) (s : St F.S) : ∀ (fuel : Nat) (st : Stmt)
    (env : Env) (labels : List Name), AllX (Fresh s) (exLoopF F s fuel st env labels)
  | 0, _, _, _ => allX_fail _ _
  | fuel + 1, st, env, labels => by
    cases st <;> simp only [exLoopF]
    all_goals first
      | exact forStart_fresh _ _ _ _ _ _ _ _
      | exact exLoopF_fresh F s fuel _ _ _
      | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
      | exact AllX.pure ((Fresh.of_same (labelFrames_same s labels)).trans
          (Fresh.of_same ⟨rfl, rfl⟩))

theorem exLoop_fresh (F : Ffi) (s : St F.S) (st : Stmt) (env : Env) (labels : List Name) :
    AllX (Fresh s) (exLoop F s st env labels) := exLoopF_fresh F s 8 st env labels

/-- Every non-enum statement step only allocates or writes freshly allocated cells.
Class declarations schedule expression evaluation; this step does not evaluate their class bodies. -/
theorem exStep_fresh (F : Ffi) (s : St F.S) (st : Stmt) (env : Env)
    (he : ∀ constant name members, st ≠ .enum constant name members) :
    AllX (Fresh s) (exStep F s st env) := by
  cases st with
  | decl kind ds => exact declNext_fresh _ _ _ _ _
  | enum constant name members => exact (he constant name members rfl).elim
  | block ss => exact AllX.pure (enterBlock_fresh _ _ _)
  | switch d cs =>
    exact AllX.pure ((hoist_fresh s (caseStmts cs) env).trans (Fresh.of_same ⟨rfl, rfl⟩))
  | try_ b hd fin =>
    exact AllX.pure ((Fresh.of_same (s := s) (u := s.push _) ⟨rfl, rfl⟩).trans
      (enterBlock_fresh _ b env))
  | for_ init test update body => exact exLoop_fresh _ _ _ _ _
  | forOf aw kind p e body => exact exLoop_fresh _ _ _ _ _
  | while_ c body => exact exLoop_fresh _ _ _ _ _
  | doWhile body c => exact exLoop_fresh _ _ _ _ _
  | labeled l st => exact exLoop_fresh _ _ _ _ _
  | cls c =>
    obtain ⟨name, heritage, members⟩ := c
    cases name <;> exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | ret arg => cases arg <;> exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | _ =>
    all_goals first
      | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
      | exact allX_fail _ _

/-- The actual statement dispatcher footprint under its unchanged acceptance test. -/
theorem step_ex_all_foot {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t s1 t1 : St F.S} {S S1 : SSrv} {C C1 : CSrv} {st : Stmt} {env : Env}
    (h : RelXB F FR W stk M ν K s S t C) (hc : s.ctl = .ex st env)
    (hok : okEx s st = true)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have hr := RelXB.rel h (by intro v hv; rw [hc] at hv; cases hv)
  have ht : t.ctl = .ex st (M.env env) := by rw [hr.ctl, hc]; rfl
  have he : ∀ constant name members, st ≠ .enum constant name members := by
    intro constant name members heq
    rw [heq] at hok
    cases hok
  rw [step_ex_eq hc] at hsrun
  rw [step_ex_eq ht] at htrun
  exact Fresh.foot ((exStep_fresh F s st env he).1 S s1 S1 hsrun)
    ((exStep_fresh F t st (M.env env) he).2 C t1 C1 htrun)

end Host.Ts.Sim.HeapFoot
