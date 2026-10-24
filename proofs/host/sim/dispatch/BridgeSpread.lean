import host.sim.dispatch.SpreadFramed
import host.sim.Wide
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Bridge B-spread: `[...promptTokens, ...forwarded]`

`cacheTokens: [...promptTokens, ...forwarded]` (`generation/autoregressive.ts:266`, also
`:774`) spreads the framed prompt first. The interpreter runs (`Machine.lean`, `arrayNext`,
`retL`, `spreadElems`):

1. `.ev (.array [.spread promptTokens, .spread forwarded]) env` pushes
   `LitF.spread [] [.spread forwarded] env` and evaluates `promptTokens` (accepted);
2. reading `promptTokens` returns the framed prompt `.obj aP` (accepted);
3. the spread frame receives it: the accumulator takes the prompt's elements, `[]` on the
   template, `π.map natV` on the target, and `forwarded` is evaluated under
   `LitF.spread acc [] env` (`step_spread_open`: `RelF` to `RelSp` with a framed accumulator);
4. reading `forwarded` (`step_id_spread`: `RelSp` kept);
5. the spread frame receives the framed `forwarded` and allocates the literal's array
   (`step_spread_close`: `RelSp` to `RelF`, framing the new array; with an unframed accumulator
   this is `step_spread_framed`).

`bridge_of_msim` turns each into the target step of `StepSimXV`'s conclusion. -/

/-- A bridge in `MSim` form gives the target step for the template's step. -/
theorem bridge_of_msim {F : Ffi} {M : Map} {ν : Nat → F64} {S S1 : SSrv} {C : CSrv} {s s1 t : St F.S}
    {R : Map → SSrv → CSrv → St F.S → St F.S → Prop}
    (hm : MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧ R M' S' C' s1 t1) S C (step F s) (step F t))
    (hs : interpS (step F s).run S = some (s1, S1)) :
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧ R M' S1 C1 s1 t1 := by
  obtain ⟨M', t1, C1, ht, hg, hr⟩ := MSim.run hm s1 S1 hs
  exact ⟨M', t1, C1, ht, hg.ext, hr⟩

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- The framed array received by a frame, on both sides. -/
private theorem framed_recv (h : RelB F FR W stk M ν K s S t C) {b : Nat} {pre pre' : List Val}
    (hb : K.fr b = some (pre, pre')) (hw : W b = none) : ∃ xs pr ps pv ex,
    s.heap.get b = some (.obj ⟨.array (pre ++ xs), pr, ps, pv, ex⟩) ∧
    t.heap.get (M.a b) = some (.obj ⟨.array (pre' ++ M.vals xs), M.val pr, M.props ps, M.privs pv, ex⟩) := by
  obtain ⟨hh, hg⟩ := Present.get (h.framedPresent b _ hb)
  obtain ⟨o, o', rfl, ht, xs, hk, rfl⟩ := (SlotOK.some_iff hb).1 ((SlotW.of_w_none hw).1 (h.heap b _ hg))
  obtain ⟨kd, pr, ps, pv, ex⟩ := o
  simp only at hk
  subst hk
  exact ⟨xs, pr, ps, pv, ex, hg, ht⟩

/-- **B-spread, open.** A framed array spread first into an array literal with a spread
next: the accumulator is framed with the array's prefixes. -/
theorem step_spread_open (h : RelB F FR W stk M ν K s S t C) {b : Nat} {e2 : Expr} {r : List Elem} {env : Env}
    {fs : List Frame} {pre pre' : List Val}
    (hc : s.ctl = .ret (.obj b)) (hst : s.stack = .l (.spread [] (.spread e2 :: r) env) :: fs)
    (hb : K.fr b = some (pre, pre')) (hwb : W b = none) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelSp F FR W stk M' ν K (some (pre.reverse, pre'.reverse)) s1 S' t1 C') S C (step F s) (step F t) := by
  obtain ⟨e1, e2', hr, _, hf⟩ := h.rfRetFrame hc hst
  obtain ⟨xs, pr, ps, pv, ex, hg, ht⟩ := framed_recv h hb hwb
  have hso := h.obj?_supp (obj?_iff.2 hg)
  have hsoS : ({ s with stack := fs } : St F.S).obj? b = some ⟨.array (pre ++ xs), pr, ps, pv, ex⟩ :=
    obj?_iff.2 hg
  have htoT : ({ t with stack := fs.map M.frame ++ stk } : St F.S).obj? (M.a b) =
      some ⟨.array (pre' ++ M.vals xs), M.val pr, M.props ps, M.privs pv, ex⟩ := obj?_iff.2 ht
  rw [e1, e2']
  show MSim _ S C (spreadElems F { s with stack := fs } (.obj b) (.l (.spread [] (.spread e2 :: r) env))
      fun es => arrayNext F { s with stack := fs } (es.reverse ++ []) (.spread e2 :: r) env)
    (spreadElems F { t with stack := fs.map M.frame ++ stk } (.obj (M.a b)) (.l (.spread (M.vals []) (.spread e2 :: r) (M.env env)))
      fun es => arrayNext F { t with stack := fs.map M.frame ++ stk } (es.reverse ++ M.vals []) (.spread e2 :: r) (M.env env))
  simp only [spreadElems, elemsOf, hsoS, htoT, arrayNext]
  refine MSim.pure ⟨Grow.refl h.srv, ?_⟩
  -- the pushed accumulator and the next element
  have hacc : Supp.vals (Present { s with stack := fs }) S.tab.length ((pre ++ xs).reverse ++ []) := by
    intro v hv
    simp only [List.append_nil, List.mem_reverse] at hv
    exact hso.1 v hv
  have henv : Supp.env (Present { s with stack := fs }) S.tab.length env := hf.2
  have h1 := (hr.push (.l (.spread ((pre ++ xs).reverse ++ []) r env)) ⟨hacc, henv⟩).go (.ev e2 env) henv
  refine ⟨h1.heapCongr (fun _ => rfl) rfl rfl rfl rfl, xs.reverse, r, env, fs, by simp [St.push, St.go], ?_⟩
  show Frame.l (.spread ((pre' ++ M.vals xs).reverse ++ M.vals []) r (M.env env)) :: (fs.map M.frame ++ stk) = _
  simp [Map.vals, List.map_reverse]

/-- **B-spread, the next element.** Reading an initialized variable keeps a framed
accumulator. -/
theorem step_id_spread {sp : Option (List Val × List Val)} (h : RelSp F FR W stk M ν K sp s S t C)
    {n : Name} {env : Env} {c : Nat} {v : Val}
    (hc : s.ctl = .ev (.id n) env) (hl : lookupEnv n env = some c) (hv : s.cell? c = some (some v))
    (hn : NoW K W s c) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧ RelSp F FR W stk M' ν K sp s1 S' t1 C') S C
      (step F s) (step F t) := by
  obtain ⟨hb, hst⟩ := h
  have htc : t.ctl = .ev (.id n) (M.env env) := by rw [show t.ctl = _ from hb.ctl, hc]; rfl
  have hl' : lookupEnv n (M.env env) = some (M.a c) := by rw [lookupEnv_map, hl]; rfl
  have hv' : t.cell? (M.a c) = some (some (M.val v)) := hb.cell? hv hn
  have e1 : step F s = retS F s v := by simp only [step, hc, evStep, readVar, hl, hv]
  have e2 : step F t = retS F t (M.val v) := by simp only [step, htc, evStep, readVar, hl', hv']
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl hb.srv, hb.ret v (hb.cell?_supp hv), hst⟩

/-- **B-spread, close.** A framed array spread last into an array literal whose accumulator
is framed `(P, E)`: the literal's array is framed with prefixes
`(P.reverse ++ A.reverse ++ pre, E.reverse ++ M.vals A.reverse ++ pre')`. With `P = E = []` this is
`step_spread_framed`. -/
theorem step_spread_close {P E : List Val} (h : RelSp F FR W stk M ν K (some (P, E)) s S t C) {b : Nat}
    {A : List Val} {env : Env} {fs : List Frame} {pre pre' : List Val}
    (hc : s.ctl = .ret (.obj b)) (hst : s.stack = .l (.spread (A ++ P) [] env) :: fs)
    (hb : K.fr b = some (pre, pre')) (hn : s.next + margin < Sim.bound) (hp : Present s aArrayProto)
    (hwb : W b = none) (hwn : W s.next = none) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB F FR W stk M' ν (Ctx.frameAt K s.next (P.reverse ++ A.reverse ++ pre, E.reverse ++ M.vals A.reverse ++ pre'))
        s1 S' t1 C' ∧ t1.ffi = t.ffi) S C (step F s) (step F t) := by
  obtain ⟨hb0, hst0⟩ := h
  obtain ⟨A', rest, env', fs', hs1, ht1⟩ := hst0
  rw [hst] at hs1
  injection hs1 with hf1 hfs
  injection hf1 with hf1
  injection hf1 with hA hrest henv
  have hA' : A = A' := List.append_cancel_right hA
  subst hA' hrest henv hfs
  -- the target, popped, is the virtual target, popped
  have hagree : ∀ y, t.heap.get y = ({ t with stack := s.stack.map M.frame ++ stk } : St F.S).heap.get y :=
    fun _ => rfl
  have htv : ({ t with stack := s.stack.map M.frame ++ stk } : St F.S).ctl = .ret (M.val (.obj b)) := by
    rw [hb0.ctl, hc]; rfl
  obtain ⟨e1, -, hr0, -, hf⟩ := hb0.rfRetFrame hc hst
  have hr : RelB F FR W stk M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C :=
    hr0.heapCongr (fun y => hagree y) rfl rfl rfl rfl
  obtain ⟨xs, pr, ps, pv, ex, hg, ht⟩ := framed_recv hb0 hb hwb
  have ht' : t.heap.get (M.a b) = _ := (hagree _).trans ht
  have hso := hb0.obj?_supp (obj?_iff.2 hg)
  have hsoS : ({ s with stack := fs } : St F.S).obj? b = some ⟨.array (pre ++ xs), pr, ps, pv, ex⟩ :=
    obj?_iff.2 hg
  have htoT : ({ t with stack := fs.map M.frame ++ stk } : St F.S).obj? (M.a b) =
      some ⟨.array (pre' ++ M.vals xs), M.val pr, M.props ps, M.privs pv, ex⟩ := obj?_iff.2 ht'
  have htc : t.ctl = .ret (.obj (M.a b)) := by rw [show t.ctl = _ from htv]; rfl
  have e2 : step F t = retStep F { t with stack := fs.map M.frame ++ stk }
      (.l (.spread (M.vals A ++ E) [] (M.env env))) (.obj (M.a b)) := by
    simp only [step, htc, stepRet, ht1]
  rw [e1, e2]
  show MSim _ S C (spreadElems F { s with stack := fs } (.obj b) (.l (.spread (A ++ P) [] env))
      fun es => arrayNext F { s with stack := fs } (es.reverse ++ (A ++ P)) [] env)
    (spreadElems F { t with stack := fs.map M.frame ++ stk } (.obj (M.a b)) (.l (.spread (M.vals A ++ E) [] (M.env env)))
      fun es => arrayNext F { t with stack := fs.map M.frame ++ stk } (es.reverse ++ (M.vals A ++ E)) [] (M.env env))
  simp only [spreadElems, elemsOf, hsoS, htoT]
  show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure _)
  have hrev : ((pre ++ xs).reverse ++ (A ++ P)).reverse = P.reverse ++ A.reverse ++ pre ++ xs := by simp
  have hrev' : ((pre' ++ M.vals xs).reverse ++ (M.vals A ++ E)).reverse =
      E.reverse ++ M.vals A.reverse ++ pre' ++ M.vals xs := by
    simp [Map.vals, List.map_reverse]
  simp only [hrev, hrev']
  have hS : Supp.vals (Present s) S.tab.length (P.reverse ++ A.reverse ++ pre ++ xs) := by
    have hfa : Supp.vals (Present s) S.tab.length (A ++ P) := hf.1
    intro v hv
    simp only [List.mem_append, List.mem_reverse] at hv
    rcases hv with ((hv | hv) | hv) | hv
    · exact hfa v (List.mem_append_right _ hv)
    · exact hfa v (List.mem_append_left _ hv)
    · exact hso.1 v (List.mem_append_left _ hv)
    · exact hso.1 v (List.mem_append_right _ hv)
  have hs64 : s.next < 2 ^ 64 := by have : Sim.bound = 2 ^ 61 := rfl; omega
  have hn' : s.next < Sim.bound := Nat.lt_of_le_of_lt (Nat.le_add_right _ _) hn
  have hPs : ∀ a, Present s a → Present (({ s with stack := fs } : St F.S).alloc
      (.obj ⟨.array (P.reverse ++ A.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩)).2 a :=
    fun a ha => Present.alloc (s := { s with stack := fs }) _ hs64 ha
  have hfo : FramedObj M (P.reverse ++ A.reverse ++ pre) (E.reverse ++ M.vals A.reverse ++ pre')
      ⟨.array (P.reverse ++ A.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩
      ⟨.array (E.reverse ++ M.vals A.reverse ++ pre' ++ M.vals xs), .obj aArrayProto, [], [], true⟩ := by
    refine ⟨xs, by simp, ?_⟩
    have hI : M.a aArrayProto = aArrayProto := hb0.intr _ (by decide)
    simp only [Map.obj, Map.val, hI, Map.props, List.map_nil, List.append_assoc]
  obtain ⟨ea, hr1⟩ := RelB.allocFramed hr _ _ hn' hfo
    ⟨Supp.vals_mono hPs (Nat.le_refl _) hS, hPs _ hp, fun _ hx => by simp at hx, fun _ hx => by simp at hx⟩ hwn
  have hv : Supp.val (Present (({ s with stack := fs } : St F.S).alloc
      (.obj ⟨.array (P.reverse ++ A.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩)).2) S.tab.length
      (.obj (({ s with stack := fs } : St F.S).alloc
        (.obj ⟨.array (P.reverse ++ A.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩)).1) :=
    Present.alloc_next (s := { s with stack := fs }) _ hs64
  have := hr1.ret _ hv
  simp only [Map.val] at this
  rw [← ea] at this
  exact MSim.pure ⟨Grow.refl hb0.srv, this, rfl⟩

end
end Host.Ts.Sim.Disp
