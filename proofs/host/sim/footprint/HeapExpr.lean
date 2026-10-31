import host.sim.footprint.HeapExprBasic
import host.sim.dispatch.Ev

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv BufSim Disp
open Host.Mlx.Ffi.FullKeep (AllX)

/-- Compose the per-side footprint with the already performed prefix. -/
theorem Fresh.after {S : Type} {s u : St S} {m : Host.Ts.M (St S)}
    (h : Fresh s u) (hm : AllX (Fresh u) m) : AllX (Fresh s) m :=
  ⟨fun S v S' hv => h.trans (hm.1 S v S' hv),
   fun C v C' hv => h.trans (hm.2 C v C' hv)⟩

theorem methodProp_fresh (F : Ffi) {s u : St F.S} (h : Fresh s u) {o : Nat}
    (ho : s.next ≤ o) (k : PKey) (kind : MethodKind) (fn : Func) (env : Env) (enum : Bool) :
    Fresh s (methodProp F u o k kind fn env enum) := by
  rw [methodProp_eq]
  unfold addMethod
  split
  · exact (h.trans (Fresh.alloc _ _)).write ho _
  · exact h.trans (Fresh.alloc _ _)

/-- Leading methods update only the fresh object allocated by the expression step. -/
theorem objNext_fresh (F : Ffi) {s : St F.S} : ∀ (rest : List Property) (u : St F.S)
    (o : Nat) (env : Env), Fresh s u → s.next ≤ o → AllX (Fresh s) (objNext F u o rest env)
  | [], _, _, _, h, _ => AllX.pure (h.trans (Fresh.of_same ⟨rfl, rfl⟩))
  | p :: rest, u, o, env, h, ho => by
    cases p with
    | init k e =>
      simp only [objNext]
      split
      · exact AllX.pure (h.trans (Fresh.of_same ⟨rfl, rfl⟩))
      · split
        · exact AllX.pure (h.trans (Fresh.of_same ⟨rfl, rfl⟩))
        · exact allX_fail _ _
    | short n =>
      simp only [objNext]
      exact (h.trans (Fresh.of_same (u := u.push _) ⟨rfl, rfl⟩)).after (readVar_fresh _ _ _ _)
    | method kind k fn =>
      simp only [objNext]
      split
      · exact objNext_fresh F rest _ o env (methodProp_fresh F h ho _ _ _ _ _) ho
      · split
        · exact AllX.pure (h.trans (Fresh.of_same ⟨rfl, rfl⟩))
        · exact allX_fail _ _
    | spread e => exact AllX.pure (h.trans (Fresh.of_same ⟨rfl, rfl⟩))

theorem argsNext_fresh (F : Ffi) (s : St F.S) (kind : Nat) (fn this : Val) :
    ∀ (rest : List Elem) (acc : List Val) (env : Env),
      AllX (Fresh s) (argsNext F s kind fn this acc rest env)
  | [], _, _ => by
    simp only [argsNext]
    repeat' first
      | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
      | exact allX_fail _ _
      | split
  | .hole :: r, acc, env => argsNext_fresh F s kind fn this r (.undef :: acc) env
  | .expr _ :: _, _, _ => AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | .spread _ :: _, _, _ => AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)

theorem evCall_fresh (F : Ffi) (s : St F.S) (callee : Expr) (args : List Elem)
    (opt : Bool) (env : Env) : AllX (Fresh s) (evCall F s callee args opt env) := by
  cases callee <;> simp only [evCall]
  all_goals repeat' first
    | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    | exact allX_fail _ _
    | exact argsNext_fresh _ _ _ _ _ _ _ _
    | split

theorem readVar_push_fresh (F : Ffi) (s : St F.S) (f : Frame) (n : Name) (env : Env) :
    AllX (Fresh s) (readVar F (s.push f) n env) :=
  (Fresh.of_same (s := s) (u := s.push f) ⟨rfl, rfl⟩).after (readVar_fresh _ _ _ _)

theorem evAssign_fresh (F : Ffi) (s : St F.S) (op : AsgOp) (target : Pat) (v : Expr)
    (env : Env) : AllX (Fresh s) (evAssign F s op target v env) := by
  unfold evAssign
  repeat' first
    | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    | exact allX_fail _ _
    | exact readVar_push_fresh _ _ _ _ _
    | unfold asgTarget
    | unfold readTarget
    | split

theorem evUpdate_fresh (F : Ffi) (s : St F.S) (inc pre : Bool) (target : Expr)
    (env : Env) : AllX (Fresh s) (evUpdate F s inc pre target env) := by
  unfold evUpdate
  repeat' first
    | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    | exact allX_fail _ _
    | exact readVar_push_fresh _ _ _ _ _
    | split

/-- All expression forms accepted by `okEv` only touch fresh heap addresses. The unsupported
class-without-heritage branch is excluded here and rejected by the unchanged dispatcher below. -/
theorem evStep_fresh (F : Ffi) (s : St F.S) (e : Expr) (env : Env)
    (he : ∀ name members, e ≠ .cls (.mk name none members)) : AllX (Fresh s) (evStep F s e env) := by
  cases e with
  | lit l => exact evLit_fresh _ _ _
  | id n => exact readVar_fresh _ _ _ _
  | this => exact readVar_fresh _ _ _ _
  | array elems => exact arrayNext_fresh _ _ _ _ _
  | object props => exact objNext_fresh F props _ _ env (Fresh.alloc _ _) (Nat.le_refl _)
  | func fn => exact AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))
  | arrow fn => exact AllX.pure ((Fresh.alloc _ _).trans (Fresh.of_same ⟨rfl, rfl⟩))
  | cls c =>
    obtain ⟨name, heritage, members⟩ := c
    cases heritage with
    | none => exact (he name members rfl).elim
    | some sup => exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | call callee args opt => exact evCall_fresh _ _ _ _ _ _
  | assign op target v => exact evAssign_fresh _ _ _ _ _ _
  | update inc pre target => exact evUpdate_fresh _ _ _ _ _ _
  | template tag quasis subs =>
    cases tag with
    | some tag => exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    | none =>
      cases quasis with
      | nil => exact allX_fail _ _
      | cons q qs =>
        cases hq : cook q with
        | none => simp only [evStep, hq]; exact allX_fail _ _
        | some cs =>
          cases subs <;> simp only [evStep, hq, tmplNext] <;>
            exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | unary op x =>
    cases op <;> simp only [evStep]
    all_goals try exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
    all_goals try exact allX_fail _ _
    case typeof =>
      cases x
      all_goals try exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
      case id n =>
        dsimp only
        split
        · exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
        · refine AllX.bind' (getChain_lawful _ _ _ _ _) fun r => ?_
          cases r <;> exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
  | _ =>
    all_goals simp only [evStep]
    all_goals repeat' first
      | exact AllX.pure (Fresh.of_same ⟨rfl, rfl⟩)
      | exact allX_fail _ _
      | split

/-- The actual expression dispatcher footprint, with exactly its existing acceptance test. -/
theorem step_ev_all_foot {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t s1 t1 : St F.S} {S S1 : SSrv} {C C1 : CSrv} {P : JSP F} {e : Expr} {env : Env}
    (h : RelXB F FR W stk M ν K s S t C) (hc : s.ctl = .ev e env)
    (hok : okEv P s e env = true)
    (hsrun : interpS (step F s).run S = some (s1, S1))
    (htrun : interpC (step F t).run C = some (t1, C1)) : HeapStepFoot M s t s1 t1 := by
  have hr := RelXB.rel h (by intro v hv; rw [hc] at hv; cases hv)
  have ht : t.ctl = .ev e (M.env env) := by rw [hr.ctl, hc]; rfl
  have he : ∀ name members, e ≠ .cls (.mk name none members) := by
    intro name members heq
    rw [heq] at hok
    cases hok
  rw [step_ev_eq hc] at hsrun
  rw [step_ev_eq ht] at htrun
  exact Fresh.foot ((evStep_fresh F s e env he).1 S s1 S1 hsrun)
    ((evStep_fresh F t e (M.env env) he).2 C t1 C1 htrun)

end Host.Ts.Sim.HeapFoot
