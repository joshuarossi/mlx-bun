import host.sim.dispatch.BridgeLen
import host.sim.template.ChainLit
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # B-len with a literal length

A chain whose row count is known reads a framed array's length as the literal itself (`Bridge.lenLitPatch`), with no table entry. -/

namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim BufSim

variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- **B-len-lit.** From a related state receiving framed array `a` in a `length` member frame, the target's step returns the array's
own length, and the template, patched to return that length as a literal, stays related under the same map. -/
theorem bridge_len_lit (h : RelB F FR W stk M ν K s S t C) {a : Nat} {opt : Bool}
    {fs : List Frame} {pre pre' xs : List Val} {o : Obj}
    (hc : s.ctl = .ret (.obj a)) (hst : s.stack = .e (.member kLength opt) :: fs)
    (hfr : K.fr a = some (pre, pre')) (ho : s.obj? a = some o) (hk : o.kind = .array (pre ++ xs)) :
    interpC (step F t).run C =
        some ({ t with stack := fs.map M.frame ++ stk }.ret (natV (pre'.length + xs.length)), C) ∧
      RelB F FR W stk M ν K ({ s with stack := fs }.ret (.num (.lit (F64.ofNat (pre'.length + xs.length))))) S
        ({ t with stack := fs.map M.frame ++ stk }.ret (natV (pre'.length + xs.length))) C := by
  obtain ⟨xs', hk', hstep⟩ := step_len_target h hc hst hfr ho (h.w_none (.of_array ho hk) hfr)
  have hxs : xs' = xs := by
    rw [hk] at hk'
    injection hk' with hk'
    exact (List.append_cancel_left hk').symm
  subst hxs
  obtain ⟨-, -, hr, -, -⟩ := h.rfRetFrame hc hst
  refine ⟨by rw [hstep]; rfl, ?_⟩
  have := hr.ret (.num (.lit (F64.ofNat (pre'.length + xs'.length)))) trivial
  simp only [Map.val, Map.nv] at this
  exact this

end Host.Ts.Sim.Disp
