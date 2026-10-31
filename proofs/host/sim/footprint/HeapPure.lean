import host.sim.footprint.HeapBasic

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv
open Host.Mlx.Ffi.FullKeep (AllX)

/-- Expression transitions that only arrange the next control and stack. -/
def controlExpr : Expr → Bool
  | .super | .member .. | .priv .. | .index .. | .new .. | .chain ..
  | .bin .. | .log .. | .cond .. | .seq .. | .yield .. | .await .. => true
  | .template (some _) _ _ => true
  | _ => false

/-- The actual expression evaluator preserves the heap on these transitions. -/
theorem evStep_same (F : Ffi) (s : St F.S) (e : Expr) (env : Env) (he : controlExpr e = true) :
    AllX (Same s) (evStep F s e env) := by
  cases e <;> simp only [controlExpr, Bool.false_eq_true] at he
  all_goals try first
    | exact AllX.pure ⟨rfl, rfl⟩
    | exact allX_fail _ _
  case template tag quasis subs =>
    cases tag with
    | none => cases he
    | some tag => exact AllX.pure ⟨rfl, rfl⟩
  case priv obj prop optional =>
    dsimp only [evStep]
    cases lookupEnv (privName prop) env with
    | none => exact allX_fail _ _
    | some b => exact AllX.pure ⟨rfl, rfl⟩
  case yield arg delegate =>
    cases arg <;> exact AllX.pure ⟨rfl, rfl⟩

theorem step_ev_same (F : Ffi) {s : St F.S} {e : Expr} {env : Env}
    (hc : s.ctl = .ev e env) (he : controlExpr e = true) : AllX (Same s) (step F s) := by
  simp only [step, hc]
  exact evStep_same F s e env he

/-- Accepted expression-control steps have the caller footprint without any native premise. -/
theorem step_ev_foot {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t s1 t1 : St F.S} {S S1 : SSrv} {C C1 : CSrv} {e : Expr} {env : Env}
    (h : RelXB F FR W stk M ν K s S t C) (hc : s.ctl = .ev e env) (he : controlExpr e = true)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have hr := RelXB.rel h (by intro v hv; rw [hc] at hv; cases hv)
  have ht : t.ctl = .ev e (M.env env) := by rw [hr.ctl, hc]; rfl
  exact same_foot ((step_ev_same F hc he).1 S s1 S1 hsrun)
    ((step_ev_same F ht he).2 C t1 C1 htrun)

/-- Statement transitions that do not enter a block or allocate bindings. -/
def controlStmt : Stmt → Bool
  | .expr .. | .func .. | .cls .. | .ret .. | .if_ .. | .forIn ..
  | .throw .. | .break .. | .continue .. | .empty => true
  | _ => false

theorem exStep_same (F : Ffi) (s : St F.S) (st : Stmt) (env : Env) (he : controlStmt st = true) :
    AllX (Same s) (exStep F s st env) := by
  cases st <;> simp only [controlStmt, Bool.false_eq_true] at he
  all_goals try first
    | exact AllX.pure ⟨rfl, rfl⟩
    | exact allX_fail _ _
  case cls c =>
    cases c with
    | mk name heritage members => cases name <;> exact AllX.pure ⟨rfl, rfl⟩
  case ret arg =>
    cases arg <;> exact AllX.pure ⟨rfl, rfl⟩

theorem step_ex_same (F : Ffi) {s : St F.S} {st : Stmt} {env : Env}
    (hc : s.ctl = .ex st env) (he : controlStmt st = true) : AllX (Same s) (step F s) := by
  simp only [step, hc]
  exact exStep_same F s st env he

theorem step_ex_foot {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t s1 t1 : St F.S} {S S1 : SSrv} {C C1 : CSrv} {st : Stmt} {env : Env}
    (h : RelXB F FR W stk M ν K s S t C) (hc : s.ctl = .ex st env) (he : controlStmt st = true)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have hr := RelXB.rel h (by intro v hv; rw [hc] at hv; cases hv)
  have ht : t.ctl = .ex st (M.env env) := by rw [hr.ctl, hc]; rfl
  exact same_foot ((step_ex_same F hc he).1 S s1 S1 hsrun)
    ((step_ex_same F ht he).2 C t1 C1 htrun)

end Host.Ts.Sim.HeapFoot
