import host.sim.dispatch.Ret1
import host.sim.dispatch.DecideFn
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Dispatch of `.ret v` under function frames (`FnF`)

Rejected: a non-delegating `yield` or a `yield*` iterator outside a generator
(the source step fails), `yield*` results that are not ordinary objects with an
own data `done`, and builtin frames other than `AsyncLocalStorage.run` and
`new Promise`. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {P : JSP F}

/-- The generator a `yield` suspends: async generators need `%Promise.prototype%`, sync ones
`%Object.prototype%`. -/
def yieldB (s : St F.S) (fs : List Frame) : Bool :=
  match nearestGen fs with
  | some (g, _) => match genOf s g with
    | some (_, true) => presB s aPromiseProto
    | _ => presB s aObjectProto
  | none => false

def ystarItB (P : JSP F) (s : St F.S) (fs : List Frame) : Bool :=
  match nearestGen fs with
  | some (g, _) => match genOf s g with
    | some (_, true) => presB s aObjectProto && presB s aFunctionProto
    | _ => noWideB P
  | none => false

def okRetK (P : JSP F) (s : St F.S) (n : Nat) (v : Val) (fs : List Frame) : FnF → Bool
  | .fn b => match b with
    | .call => true
    | .ctor _ => true
    | .derived tc => presB s aReferenceErrorProto && nwB P tc
    | .async _ => true
    | .gen _ => presB s aObjectProto && presB s aFunctionProto
  | .params fn _ _ _ => intrB s 39 && Nat.ble (fnBlockNames fn).length two20
  | .paramDflt _ _ _ _ _ => true
  | .classHeritage _ _ => presB s aObjectProto && presB s aFunctionProto && presB s aTypeErrorProto && noWideB P
  | .classMembers f p ms _ _ => frB P f && frB P p && presB s aFunctionProto && Nat.ble ms.length two20
  | .classKey f p _ ms _ _ => frB P f && frB P p && presB s aFunctionProto && bfVB P v && Nat.ble ms.length two20
  | .classStatic f p _ ms _ _ => frB P f && frB P p && presB s aFunctionProto && Nat.ble ms.length two20
  | .fields o _ _ => frB P o
  | .fieldVal o _ _ _ => frB P o
  | .privVal o _ _ _ _ => frB P o
  | .ctorBody _ fn _ _ => Nat.ble (paramNames fn).length two20
  | .superRet tc _ _ => (s.cell? tc).isSome && presB s aReferenceErrorProto && nwB P tc
  | .paramProps o ns env => presB s aTypeErrorProto && presB s aRangeErrorProto && paramPropsB P s n o ns env
  | .native nt data => match nt, data with
    | .ctl .alsRun, _ => true
    | .ctl .promiseCtor, [_] => true
    | _, _ => false
  | .promiseThen _ => true
  | .yield d => match d with
    | false => yieldB s fs
    | true => presB s aTypeErrorProto && presB s aArrayIterProto && noWideB P
  | .ystarIt => ystarItB P s fs
  | .ystarNext _ _ => doneB P s v && noWideB P
  | .ystarResume _ _ => true
  | .ystarAIt => noWideB P
  | .ystarAResult _ _ => presB s aObjectProto && presB s aFunctionProto && doneB P s v && noWideB P
  | .ystarAResume _ _ => true
  | .ystarAReturned _ _ => presB s aObjectProto && presB s aFunctionProto && doneB P s v && noWideB P
  | .ystarAReturn => true
  | .await => presB s aPromiseProto
  | .modules _ => true

variable {okBack : F.S → Arg → Bool}

theorem simRetK {okCall0 : F.S → Name → List Arg → Bool} (hF : FfiSim F FR okCall0 okBack) (hFR : FRLaws FR) (hK : Kp P K)
    (hW : Wp P W) (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : FnF} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .k f :: fs) (hn : s.next + margin < Sim.bound) (hok : okRetK P s S.tab.length v fs f = true)
    (hloc : stk = [] ∨ localB s = true) :
    MSim (PX F FR W stk M ν K S C) S C (step F s) (step F t) := by
  cases f with
  | fn b =>
    cases b with
    | call => exact MSim.toX (step_ret_fn_call h hc hs)
    | ctor o => exact MSim.toX (step_ret_fn_ctor h hc hs)
    | derived tc =>
      simp only [okRetK, Bool.and_eq_true] at hok
      exact MSim.toX (step_ret_fn_derived h hc hs hok.1 hn (hK.nw hW hok.2))
    | async p => exact MSim.toX (step_ret_fn_async h hc hs hn)
    | gen g =>
      simp only [okRetK, Bool.and_eq_true] at hok
      exact MSim.toX (step_ret_fn_gen h hok.1 hok.2 hc hs hn)
  | params fn ps args env =>
    simp only [okRetK, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_params h hc hs (intrB_aFirst hok.1) (le20 hok.2) hn
      (hloc.imp id fun hl => localB_ne hl hs rfl))
  | paramDflt fn p ps args env => exact MSim.toX (step_ret_paramDflt h hc hs)
  | classHeritage c env =>
    simp only [okRetK, Bool.and_eq_true] at hok
    exact MSim.toX (step_ret_classHeritage h hF hc hs hok.1.1.1 hok.1.1.2 hok.1.2 hn (hW.noWide hok.2))
  | classMembers f p ms inst env =>
    simp only [okRetK, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    exact MSim.toX (step_ret_classMembers h hc hs (hK.fr_none h1) (hK.fr_none h2) h3 (le20 h4) hn)
  | classKey f p m ms inst env =>
    simp only [okRetK, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := hok
    exact MSim.toX (step_ret_classKey h hc hs (hK.fr_none h1) (hK.fr_none h2) h3 (hK.bfBig h4) (le20 h5) hn)
  | classStatic f p k ms inst env =>
    simp only [okRetK, Bool.and_eq_true] at hok
    obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
    exact MSim.toX (step_ret_classStatic h hc hs (hK.fr_none h1) (hK.fr_none h2) h3 (le20 h4) hn)
  | fields o ms env => exact MSim.toX (step_ret_fields h hc hs (hK.fr_none hok) hn)
  | fieldVal o k ms env => exact MSim.toX (step_ret_fieldVal h hc hs (hK.fr_none hok) hn)
  | privVal o b nm ms env => exact MSim.toX (step_ret_privVal h hc hs (hK.fr_none hok) hn)
  | ctorBody o fn env args => exact MSim.toX (step_ret_ctorBody h hc hs (le20 hok) hn)
  | superRet tc cls env =>
    simp only [okRetK, Bool.and_eq_true, Option.isSome_iff_exists] at hok
    exact MSim.toX (step_ret_super h hc hs hok.1.1 hok.1.2 hn (hK.nw hW hok.2))
  | paramProps o ns env =>
    simp only [okRetK, Bool.and_eq_true] at hok
    obtain ⟨⟨h1, h2⟩, h3⟩ := hok
    exact MSim.toX (step_ret_paramProps h hF hFR hc hs h1 h2 (hK.paramProps hW h3) hn (hK.paramCells hW h3))
  | native nt data =>
    rcases nt with _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | cf | _ | _ <;> try simp [okRetK] at hok
    cases cf with
    | alsRun => exact MSim.toX (step_ret_native_alsRun h hc hs)
    | promiseCtor =>
      rcases data with _ | ⟨p, _ | ⟨_, _⟩⟩ <;> simp at hok
      exact MSim.toX (step_ret_native_promiseCtor h hc hs)
    | _ => simp at hok
  | promiseThen p => exact MSim.toX (step_ret_promiseThen h hc hs hn)
  | yield d =>
    cases d with
    | false =>
      simp only [okRetK, yieldB] at hok
      cases hng : nearestGen fs with
      | none => simp [hng] at hok
      | some gb =>
        obtain ⟨g, b⟩ := gb
        simp only [hng] at hok
        cases hgo : genOf s g with
        | none =>
          simp only [hgo] at hok
          exact MSim.toX (step_ret_yield_sync h hok hc hs hng (by intro st h'; rw [hgo] at h'; cases h') hn)
        | some p =>
          obtain ⟨st, a⟩ := p
          cases a with
          | true =>
            simp only [hgo] at hok
            exact MSim.toX (step_ret_yield_async h hok hc hs hng hgo hn)
          | false =>
            simp only [hgo] at hok
            exact MSim.toX (step_ret_yield_sync h hok hc hs hng
              (by intro st' h'; rw [hgo] at h'; cases h') hn)
    | true =>
      simp only [okRetK, Bool.and_eq_true] at hok
      exact MSim.toX (step_ret_yield_delegate h hF hok.1.1 hok.1.2 hc hs hn (hW.noWide hok.2)
        (hloc.imp id fun hl => localB_tail hl hs rfl))
  | ystarIt =>
    simp only [okRetK, ystarItB] at hok
    cases hng : nearestGen fs with
    | none => simp [hng] at hok
    | some gb =>
      obtain ⟨g, b⟩ := gb
      simp only [hng] at hok
      cases hgo : genOf s g with
      | none =>
        simp only [hgo] at hok
        exact MSim.toX (step_ret_ystarIt_sync h hF hc hs hng (by intro st h'; rw [hgo] at h'; cases h')
          (hW.noWide hok))
      | some p =>
        obtain ⟨st, a⟩ := p
        cases a with
        | true =>
          simp only [hgo, Bool.and_eq_true] at hok
          exact MSim.toX (step_ret_ystarIt_async h hok.1 hok.2 hc hs hng hgo hn)
        | false =>
          simp only [hgo] at hok
          exact MSim.toX (step_ret_ystarIt_sync h hF hc hs hng (by intro st' h'; rw [hgo] at h'; cases h')
            (hW.noWide hok))
  | ystarNext it nx =>
    simp only [okRetK, Bool.and_eq_true] at hok
    obtain ⟨a, o, dv, w, e, rfl, ho, hk, hd, hb⟩ := hK.done hok.1
    exact MSim.toX (step_ret_ystarNext h hF hFR hc hs ho hk hd hb hn (hW.noWide hok.2))
  | ystarResume it nx => exact MSim.toX (step_ret_ystarResume h hc hs)
  | ystarAIt => exact MSim.toX (step_ret_ystarAIt h hF hc hs (hW.noWide hok))
  | ystarAResult it nx =>
    simp only [okRetK, Bool.and_eq_true] at hok
    obtain ⟨a, o, dv, w, e, rfl, ho, hk, hd, hb⟩ := hK.done hok.1.2
    exact MSim.toX (step_ret_ystarAResult h hF hFR hok.1.1.1 hok.1.1.2 hc hs ho hk hd hb hn (hW.noWide hok.2))
  | ystarAResume it nx => exact MSim.toX (step_ret_ystarAResume h hc hs)
  | ystarAReturned it nx =>
    simp only [okRetK, Bool.and_eq_true] at hok
    obtain ⟨a, o, dv, w, e, rfl, ho, hk, hd, hb⟩ := hK.done hok.1.2
    exact MSim.toX (step_ret_ystarAReturned h hF hFR hok.1.1.1 hok.1.1.2 hc hs ho hk hd hb hn (hW.noWide hok.2))
  | ystarAReturn => exact MSim.toX (step_ret_ystarAReturn h hc hs)
  | await => exact MSim.toX (step_ret_await h hok hc hs hn)
  | modules r => exact MSim.toX (step_ret_modules h hc hs)

end
end Host.Ts.Sim.Disp
