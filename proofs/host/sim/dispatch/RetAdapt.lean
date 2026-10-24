import host.sim.dispatch.Base
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Adapter: truthiness of renamed bigints

`step_retE_logL` and `step_retE_cond` ask the tested value to be a fixed bigint
(`BigFixedV`). Truthiness only needs the map to keep zeroness
(`NativeFacts.zero`); `step_retE_logLZ`/`step_retE_condZ` take that instead (the
proofs are those of the originals with `rf_truthyZ`). -/

section
variable {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv}

theorem rf_truthyZ (hs : Srv M ν S C) (v : Val) (hz : ∀ i, (M.big i == 0) = (i == 0)) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (truthy v) (truthy (M.val v)) := by
  cases v with
  | num x => exact numTest_sim hs .truthy x zeroN
  | big i =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure (!(M.big i == 0)))
    rw [hz i]
    exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl hs⟩

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {v : Val} {fs : List Frame}

theorem step_retE_logLZ (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {op : LogOp} {b : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.logL op b env) :: fs) (hz : ∀ i, (M.big i == 0) = (i == 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  cases op with
  | and =>
    show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
    refine rf_bind (rf_truthyZ h.srv v hz) fun M' S' C' r r' hrr g => ?_
    subst hrr
    have h' := hr.grow hFR g
    rw [g.rfEnv he, g.rfVal hv]
    cases r'
    · exact rf_ret h' v (rf_vmono g.len hv)
    · exact rf_rel (h'.go (.ev b env) (Supp.env_mono (fun _ h => h) g.len he))
  | or =>
    show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
    refine rf_bind (rf_truthyZ h.srv v hz) fun M' S' C' r r' hrr g => ?_
    subst hrr
    have h' := hr.grow hFR g
    rw [g.rfEnv he, g.rfVal hv]
    cases r'
    · exact rf_rel (h'.go (.ev b env) (Supp.env_mono (fun _ h => h) g.len he))
    · exact rf_ret h' v (rf_vmono g.len hv)
  | nullish =>
    show MSim _ S C (bif isNullish v then _ else _) (bif isNullish (M.val v) then _ else _)
    rw [rf_isNullish]
    exact MSim.cond _ (rf_rel (hr.go (.ev b env) he)) (rf_ret hr v hv)

theorem step_retE_condZ (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {a b : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.cond a b env) :: fs) (hz : ∀ i, (M.big i == 0) = (i == 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
  refine rf_bind (rf_truthyZ h.srv v hz) fun M' S' C' r r' hrr g => ?_
  subst hrr
  have h' := hr.grow hFR g
  rw [g.rfEnv he]
  cases r' <;> exact rf_rel (h'.go (.ev _ env) (Supp.env_mono (fun _ h => h) g.len he))

end
end Host.Ts.Sim.Disp
