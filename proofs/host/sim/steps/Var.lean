import host.sim.Step
namespace Host.Ts.Sim

/-! # Variable reads -/

theorem lookupEnv_map (M : Map) (name : Name) (env : Env) :
    lookupEnv name (M.env env) = (lookupEnv name env).map M.a := by
  induction env with
  | nil => rfl
  | cons p env ih =>
    obtain ⟨n, a⟩ := p
    change brec (Nat.beq (pack name) (pack n)) (some (M.a a)) (lookupEnv name (M.env env)) =
      (brec (Nat.beq (pack name) (pack n)) (some a) (lookupEnv name env)).map M.a
    cases Nat.beq (pack name) (pack n) <;> simp only [brec, Option.map_some, ih]

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- An identifier bound to an initialized cell returns its value. -/
theorem step_id_local (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {c : Nat} {v : Val}
    (hc : s.ctl = .ev (.id n) env) (hl : lookupEnv n env = some c) (hv : s.cell? c = some (some v))
    (hn : NoW K W s c) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have htc : t.ctl = .ev (.id n) (M.env env) := by rw [h.ctl, hc]; rfl
  have hl' : lookupEnv n (M.env env) = some (M.a c) := by rw [lookupEnv_map, hl]; rfl
  have hv' : t.cell? (M.a c) = some (some (M.val v)) := h.cell? hv hn
  have e1 : step F s = retS F s v := by
    simp only [step, hc, evStep, readVar, hl, hv]
  have e2 : step F t = retS F t (M.val v) := by
    simp only [step, htc, evStep, readVar, hl', hv']
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h.ret v (h.cell?_supp hv)⟩

end
end Host.Ts.Sim
