import host.sim.steps.All
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Bridge B-len: `.length` of a framed array

`promptTokens.length` (`generation/autoregressive.ts:137, 169, 185, 186, 194, 256, 257, 263,
278, 483, 486, 492, 498, 516`) and `chunk.length` (`generation/prefill.ts:24`, twice) read
`length` of a framed array: the prompt (template prefix `[]`, target prefix `π.map natV`) or
the chunk `prompt.slice(start, end)` (B-slice). The interpreter evaluates `x.length` in three
steps: push `ExprF.member length`, read `x`, and receive the array in that frame (`retE` →
`getV` → `ownGet`, `Props.lean:55`). The acceptance rejects the third step on a framed
array, since the two sides' lengths differ (`ChainOK`). That step is this bridge: the template
is patched to return a number reference whose target image is the literal length,
either a fresh table entry `e` (`bridge_len`) or an existing one (`bridge_len_at`). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A fresh table entry `e` with the literal target image `x` of its value. -/
theorem _root_.Host.Ts.Sim.Srv.pushLit (hs : Srv M ν S C) (e : SymE) (x : F64) (he : e.eval ν = x) :
    Srv (M.setNum S.tab.length (.lit x)) ν { S with tab := S.tab ++ [e] } C := by
  refine ⟨?_, hs.good⟩
  intro i e' hi
  rcases nth?_append_eq S.tab e i e' hi with ⟨hlt, hi'⟩ | ⟨rfl, rfl⟩
  · rw [(M.setNum_ext S.tab.length _).num i hlt]
    exact hs.num i e' hi'
  · rw [M.setNum_self]
    show some x = some (e'.eval ν)
    rw [he]

theorem keyIndex_length : keyIndex kLength = none := rfl
theorem keyEq_length : keyEq kLength kLength = true := rfl

/-- The target's step: the framed array's own length. -/
theorem step_len_target (h : RelB F FR W stk M ν K s S t C) {a : Nat} {opt : Bool} {fs : List Frame}
    {pre pre' : List Val} {o : Obj}
    (hc : s.ctl = .ret (.obj a)) (hst : s.stack = .e (.member kLength opt) :: fs)
    (hfr : K.fr a = some (pre, pre')) (ho : s.obj? a = some o) (hw : W a = none) :
    ∃ xs, o.kind = .array (pre ++ xs) ∧
      step F t = Host.Ts.M.pure ({ t with stack := fs.map M.frame ++ stk }.ret (natV (pre'.length + xs.length))) := by
  obtain ⟨-, e2, -, -, -⟩ := h.rfRetFrame hc hst
  obtain ⟨o', ho', xs, hk, rfl⟩ := h.obj?_framed ho hfr hw
  refine ⟨xs, hk, ?_⟩
  rw [e2]
  have ht : ({ t with stack := fs.map M.frame ++ stk } : St F.S).obj? (M.a a) =
      some { M.obj o with kind := .array (pre' ++ M.vals xs) } := ho'
  have hlen : len (pre' ++ M.vals xs) = pre'.length + xs.length := by
    rw [bi_len]; simp [Map.vals]
  have hg : retStep F { t with stack := fs.map M.frame ++ stk } (M.frame (.e (.member kLength opt))) (M.val (.obj a)) =
      getV F { t with stack := fs.map M.frame ++ stk } (.obj (M.a a)) kLength := by
    cases opt <;> rfl
  rw [hg]
  simp only [getV, lookup, getChain.eq_2, ht, ownGet, keyIndex_length, keyEq_length, Bool.cond_true, hlen]
  rfl

/-- **B-len**, fresh entry. From a related state receiving framed array `a` in a
`length` member frame, the target's step returns the array's own length; the template,
patched to return the fresh reference `S.tab.length` with entry `e`, stays related under the
map extended by the literal length. `e` must denote the target length at `ν`. -/
theorem bridge_len (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {a : Nat} {opt : Bool}
    {fs : List Frame} {pre pre' xs : List Val} {o : Obj}
    (hc : s.ctl = .ret (.obj a)) (hst : s.stack = .e (.member kLength opt) :: fs)
    (hfr : K.fr a = some (pre, pre')) (ho : s.obj? a = some o) (hk : o.kind = .array (pre ++ xs))
    (e : SymE) (he : e.eval ν = F64.ofNat (pre'.length + xs.length)) :
    interpC (step F t).run C =
        some ({ t with stack := fs.map M.frame ++ stk }.ret (natV (pre'.length + xs.length)), C) ∧
      Ext M (M.setNum S.tab.length (.lit (F64.ofNat (pre'.length + xs.length)))) S.tab.length ∧
      RelB F FR W stk (M.setNum S.tab.length (.lit (F64.ofNat (pre'.length + xs.length)))) ν K
        ({ s with stack := fs }.ret (.num (.ref S.tab.length))) { S with tab := S.tab ++ [e] }
        ({ t with stack := fs.map M.frame ++ stk }.ret (natV (pre'.length + xs.length))) C := by
  obtain ⟨xs', hk', hstep⟩ := step_len_target h hc hst hfr ho (h.w_none (.of_array ho hk) hfr)
  have hxs : xs' = xs := by
    rw [hk] at hk'
    injection hk' with hk'
    exact (List.append_cancel_left hk').symm
  subst hxs
  obtain ⟨-, -, hr, -, -⟩ := h.rfRetFrame hc hst
  have hext := M.setNum_ext S.tab.length (.lit (F64.ofNat (pre'.length + xs'.length)))
  have hr' := hr.extend hext (h.srv.pushLit e _ he) (by simp) hFR.stable hFR.mono
  refine ⟨by rw [hstep]; rfl, hext, ?_⟩
  have hv : Supp.val (Present { s with stack := fs }) ({ S with tab := S.tab ++ [e] } : SSrv).tab.length
      (.num (.ref S.tab.length)) := by
    show S.tab.length < (S.tab ++ [e]).length
    simp
  have := hr'.ret _ hv
  simp only [Map.val, Map.nv, Map.setNum_self] at this
  exact this

/-- **B-len** at an existing entry `k` whose target image is already the literal length. -/
theorem bridge_len_at (h : RelB F FR W stk M ν K s S t C) {a : Nat} {opt : Bool}
    {fs : List Frame} {pre pre' xs : List Val} {o : Obj} {k : Nat}
    (hc : s.ctl = .ret (.obj a)) (hst : s.stack = .e (.member kLength opt) :: fs)
    (hfr : K.fr a = some (pre, pre')) (ho : s.obj? a = some o) (hk : o.kind = .array (pre ++ xs))
    (hkS : k < S.tab.length) (hM : M.num k = .lit (F64.ofNat (pre'.length + xs.length))) :
    interpC (step F t).run C =
        some ({ t with stack := fs.map M.frame ++ stk }.ret (natV (pre'.length + xs.length)), C) ∧
      RelB F FR W stk M ν K ({ s with stack := fs }.ret (.num (.ref k))) S
        ({ t with stack := fs.map M.frame ++ stk }.ret (natV (pre'.length + xs.length))) C := by
  obtain ⟨xs', hk', hstep⟩ := step_len_target h hc hst hfr ho (h.w_none (.of_array ho hk) hfr)
  have hxs : xs' = xs := by
    rw [hk] at hk'
    injection hk' with hk'
    exact (List.append_cancel_left hk').symm
  subst hxs
  obtain ⟨-, -, hr, -, -⟩ := h.rfRetFrame hc hst
  refine ⟨by rw [hstep]; rfl, ?_⟩
  have := hr.ret (.num (.ref k)) (show k < S.tab.length from hkS)
  simp only [Map.val, Map.nv, hM] at this
  exact this

/-- The `length` read of an array, on any state. -/
theorem step_len_eq {u : St F.S} {a : Nat} {opt : Bool} {fs : List Frame} {o : Obj} {es : List Val}
    (hc : u.ctl = .ret (.obj a)) (hst : u.stack = .e (.member kLength opt) :: fs) (ho : u.obj? a = some o)
    (hk : o.kind = .array es) :
    step F u = Host.Ts.M.pure ({ u with stack := fs }.ret (natV (len es))) := by
  have e : step F u = retStep F { u with stack := fs } (.e (.member kLength opt)) (.obj a) := by
    simp only [step, hc, stepRet, hst]
  rw [e]
  have ht : ({ u with stack := fs } : St F.S).obj? a = some o := ho
  have hg : retStep F { u with stack := fs } (.e (.member kLength opt)) (.obj a) =
      getV F { u with stack := fs } (.obj a) kLength := by
    cases opt <;> rfl
  rw [hg]
  obtain ⟨kd, pr, ps, pv, ex⟩ := o
  simp only at hk
  subst hk
  simp only [getV, lookup, getChain.eq_2, ht, ownGet, keyIndex_length, keyEq_length, Bool.cond_true]
  rfl

end
end Host.Ts.Sim.Disp
