import host.sim.dispatch.Ret1
import host.sim.dispatch.DecideStmt
import host.sim.dispatch.DecideLoop
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.StmtSim

/-! # Dispatch of `.abr a` by the top frame

Expression, call, literal and assignment frames let abrupt completions through
(`step_abr_e/c/l/a` below, adapters in the style of `step_abr_bind`). Rejected:
builtin frames other than `AsyncLocalStorage.run` and `new Promise`. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

theorem step_abr_e (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {x : ExprF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .e x :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩

theorem step_abr_c (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {x : CallF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .c x :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩

theorem step_abr_l (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {x : LitF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .l x :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩

theorem step_abr_a (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {x : AsgF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .a x :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩

def okAbrS (s : St F.S) : StmtF → Bool
  | .dispose _ _ => presB s aSuppressedProto
  | .try_ hd fin _ => finB s fin && handlerB s hd
  | .catch_ fin _ => finB s fin
  | _ => true

def okAbrLp (P : JSP F) (s : St F.S) (n : Nat) : LoopF → Bool
  | .forUpd _ _ _ env names _ => Nat.ble names.length two20 && namesNoWB P env names
  | .forOfBody src _ _ p _ _ _ => Nat.ble (patNames p).length two20 && srcIdxB P s n src && srcNoWB P s src
  | _ => true

def okAbrK (P : JSP F) (s : St F.S) : FnF → Bool
  | .fn b => match b with
    | .derived tc => presB s aTypeErrorProto && presB s aReferenceErrorProto && nwB P tc
    | .gen _ => presB s aObjectProto && presB s aFunctionProto
    | _ => true
  | .native nt data => match nt, data with
    | .ctl .alsRun, _ => true
    | .ctl .promiseCtor, [_] => true
    | _, _ => false
  | .ystarResume _ _ => noWideB P
  | .ystarAResume _ _ => presB s aPromiseProto && noWideB P
  | _ => true

def okAbr (P : JSP F) (s : St F.S) (n : Nat) : List Frame → Bool
  | [] => true
  | f :: _ => match f with
    | .s x => okAbrS s x
    | .lp x => okAbrLp P s n x
    | .k x => okAbrK P s x
    | _ => true

theorem simAbr {okBack : F.S → Arg → Bool} {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hK : Kp P K)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} (hc : s.ctl = .abr a)
    (hn : s.next + margin < Sim.bound) (hok : okAbr P s S.tab.length s.stack = true)
    (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases hs : s.stack with
  | nil => exact MSim.toX (step_abr_empty h (hloc.resolve_right fun hl => localB_nil_abr hl hs hc) hc hs)
  | cons f fs =>
    rw [hs] at hok
    cases f with
    | e x => exact MSim.toX (step_abr_e h hc hs)
    | c x => exact MSim.toX (step_abr_c h hc hs)
    | l x => exact MSim.toX (step_abr_l h hc hs)
    | a x => exact MSim.toX (step_abr_a h hc hs)
    | b x => exact MSim.toX (step_abr_bind h hc hs)
    | s x =>
      simp only [okAbr] at hok
      cases x with
      | block rest env => exact MSim.toX (step_abr_block h hc hs)
      | scope res => exact MSim.toX (step_abr_scope h hc hs)
      | dispose rest c => exact MSim.toX (step_abr_dispose h hc hs hn hok)
      | if_ st e env => exact MSim.toX (step_abr_if h hc hs)
      | decl kind p rest env => exact MSim.toX (step_abr_decl h hc hs)
      | declNext kind rest env => exact MSim.toX (step_abr_declNext h hc hs)
      | ret => exact MSim.toX (step_abr_ret h hc hs)
      | throw => exact MSim.toX (step_abr_throw h hc hs)
      | try_ hd fin env =>
        simp only [okAbrS, Bool.and_eq_true] at hok
        exact MSim.toX (step_abr_try h hc hs hn (finB_sound hok.1).1 (handlerB_sound hok.2).1
          (tryI_sound hok.1 hok.2))
      | catch_ fin env =>
        have hb := finB_sound hok
        exact MSim.toX (step_abr_catch h hc hs hn hb.1 hb.2)
      | finally_ c => exact MSim.toX (step_abr_finally h hc hs)
      | label l => exact MSim.toX (step_abr_label h hc hs)
      | switchD cs env => exact MSim.toX (step_abr_switchD h hc hs)
      | switchCase d cs all env => exact MSim.toX (step_abr_switchCase h hc hs)
      | switchBody => exact MSim.toX (step_abr_switchBody h hc hs)
    | lp x =>
      simp only [okAbr] at hok
      cases x with
      | forUpd test update body env names labels =>
        simp only [okAbrLp, Bool.and_eq_true] at hok
        exact MSim.toX (step_abr_forUpd h hc hs hn (le20 hok.1) (hK.namesNoW hW hok.2))
      | whileBody c body env labels => exact MSim.toX (step_abr_whileBody h hc hs)
      | doBody body c env labels => exact MSim.toX (step_abr_doBody h hc hs)
      | forOfBody src aw kind p body env labels =>
        simp only [okAbrLp, Bool.and_eq_true] at hok
        exact MSim.toX (step_abr_forOfBody h hF hc hs hn (le20 hok.1.1) (hK.srcIdx hok.1.2) (hK.srcNoW hW hok.2))
      | close c => exact MSim.toX (step_abr_close h hc hs)
      | _ => exact MSim.toX (step_abr_lp_pass h hc hs rfl)
    | k x =>
      simp only [okAbr] at hok
      cases x with
      | fn b =>
        cases b with
        | call => exact MSim.toX (step_abr_fn_call h hc hs)
        | ctor o => exact MSim.toX (step_abr_fn_ctor h hc hs)
        | derived tc =>
          simp only [okAbrK, Bool.and_eq_true] at hok
          exact MSim.toX (step_abr_fn_derived h hc hs hok.1.1 hok.1.2 hn (hK.nw hW hok.2))
        | async p => exact MSim.toX (step_abr_fn_async h hc hs hn)
        | gen g =>
          simp only [okAbrK, Bool.and_eq_true] at hok
          exact MSim.toX (step_abr_fn_gen h hok.1 hok.2 hc hs hn)
      | native nt data =>
        rcases nt with _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | cf | _ | _ <;> try simp [okAbrK] at hok
        cases cf with
        | alsRun => exact MSim.toX (step_abr_native_alsRun h hc hs)
        | promiseCtor =>
          rcases data with _ | ⟨p, _ | ⟨_, _⟩⟩ <;> simp at hok
          exact MSim.toX (step_abr_native_promiseCtor h hc hs hn)
        | _ => simp at hok
      | promiseThen p => exact MSim.toX (step_abr_promiseThen h hc hs hn)
      | modules r => exact MSim.toX (step_abr_modules h hc hs)
      | ystarResume it nx => exact MSim.toX (step_abr_ystarResume h hF hc hs (hW.noWide hok))
      | ystarAResume it nx =>
        simp only [okAbrK, Bool.and_eq_true] at hok
        exact MSim.toX (step_abr_ystarAResume h hF hok.1 hc hs hn (hW.noWide hok.2))
      | _ => exact MSim.toX (step_abr_k_pass h hc hs rfl)

end
end Host.Ts.Sim.Disp
