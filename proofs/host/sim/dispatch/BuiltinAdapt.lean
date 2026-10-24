import host.sim.steps.All
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Builtins without a step lemma in steps/Builtins.lean

`Math.floor` (the proof of `step_math_ceil` with `.floor`) and `performance.now()`
(the model returns `0`). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

theorem step_math_floor (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.math .floor) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  simp only [callNative, mathN, mathN.un, bi_arg_map]
  refine ESim.bind (bi_toNum (bi_arg_supp 0 hargs)) ?_
  rintro r r' ⟨rfl, hs⟩
  cases r with
  | none => exact MSim.fail _ _
  | some x =>
    simp only [Option.map_some]
    refine bi_bind (numUn_supp_sim (Present s) h.srv .floor x) (fun _ _ _ _ _ hp => hp.2.1) ?_
    intro M' S' C' r r' hp
    obtain ⟨e, g, hs'⟩ := hp
    rw [e]
    exact bi_ret (h.grow hFR g) (.num r) hs'

theorem step_fn_perfNow (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .call (.obj fa) this args)
    (ho : s.obj? fa = some o) (hk : o.kind = .fn (.native (.fn .perfNow) data)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, _⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  exact bi_ret h (.num zeroN) trivial

end
end Host.Ts.Sim.Disp
