import host.sim.dispatch.DecideProps
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the side conditions of steps/Fn.lean and steps/Async.lean

Parameter properties (`PutOK` of the next property), iterator results of
`yield*` (an ordinary object with an own data `done` whose bigint is fixed), and
`StartOK` of a generator about to start. -/

section
variable {F : Ffi} (P : JSP F)

/-- The `PutOK` condition of `step_ret_paramProps`. -/
def paramPropsB (s : St F.S) (n : Nat) (o : Val) (ns : List Name) (env : Env) : Bool :=
  match ns with
  | nm :: _ => match cellVal? F s nm env with
    | some x => putB P s n o (.str nm) x
    | none => true
  | [] => true

/-- An iterator result: an ordinary object with an own data property `done` (a fixed bigint if one). -/
def doneB (s : St F.S) (v : Val) : Bool :=
  match v with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .ordinary => match findProp kDone o.props with
        | some (.data dv _ _) => bfVB P dv
        | _ => false
      | _ => false
    | none => false
  | _ => false

end

/-- `StartOK`. -/
def startB {F : Ffi} (P : JSP F) (body : List Stmt) (env : Env) : Bool :=
  Nat.ble ((blockNames body).length + body.length) two20 && allB (fun x => frB P x.2) env

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

theorem Kp.paramProps (hK : Kp P K) {s : St F.S} {S : SSrv} {o : Val} {ns : List Name} {env : Env}
    (h : paramPropsB P s S.tab.length o ns env = true) :
    ∀ n r, ns = n :: r → ∀ x, cellVal? F s n env = some x → PutOK F K s S o (.str n) x := by
  rintro n r rfl x hx
  simp only [paramPropsB, hx] at h
  exact hK.put h

theorem Kp.done (hK : Kp P K) {s : St F.S} {v : Val} (h : doneB P s v = true) :
    ∃ a o dv w e, v = .obj a ∧ s.obj? a = some o ∧ o.kind = .ordinary ∧
      findProp kDone o.props = some (.data dv w e) ∧ ∀ i, dv = .big i → BigFixed K.lo K.hi i := by
  cases v with
  | obj a =>
    simp only [doneB] at h
    cases ho : s.obj? a with
    | none => simp [ho] at h
    | some o =>
      simp only [ho] at h
      cases hk : o.kind with
      | ordinary =>
        simp only [hk] at h
        cases hd : findProp kDone o.props with
        | none => simp [hd] at h
        | some p =>
          cases p with
          | data dv w e =>
            simp only [hd] at h
            exact ⟨a, o, dv, w, e, rfl, ho, hk, hd, hK.bfBig h⟩
          | acc _ _ _ => simp [hd] at h
      | _ => simp [hk] at h
  | _ => simp [doneB] at h

theorem Kp.start (hK : Kp P K) {body : List Stmt} {env : Env} (h : startB P body env = true) :
    StartOK K body env := by
  simp only [startB, Bool.and_eq_true] at h
  exact ⟨le20 h.1, fun x hx => hK.fr_none (allB_sound h.2 x hx)⟩

end
end Host.Ts.Sim.Disp
