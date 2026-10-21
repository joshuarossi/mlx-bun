import host.sim.steps.All
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Bridge: the last-element spread of a framed array into a new array literal

`[...xs, ...out]` with `out` framed: the spread frame `LitF.spread acc [] env`
receives `out` and allocates the literal's array in the same step (`arrayNext … []`).
The new array holds `acc.reverse ++ pre ++ xs` on the source and
`M.vals acc.reverse ++ pre' ++ M.vals xs` on the target, so the resulting states are
related under the context that also frames the new address `s.next` with prefixes
`(acc.reverse ++ pre, M.vals acc.reverse ++ pre')` (`Ctx.frameAt`). -/

/-- The context `K` with address `a` framed by `p`. -/
def Ctx.frameAt (K : Ctx) (a : Nat) (p : List Val × List Val) : Ctx :=
  ⟨fun x => bif Nat.beq x a then some p else K.fr x, K.base, K.base', K.D, K.lo, K.hi⟩

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

theorem SlotOK.congr_fr {M : Map} {fr fr' : Nat → Option (List Val × List Val)} {a : Nat} {h : HObj}
    {h' : Option HObj} (e : fr' a = fr a) (hs : SlotOK M fr a h h') : SlotOK M fr' a h h' := by
  unfold SlotOK at hs ⊢
  rw [e]
  exact hs

/-- Allocation of an object whose target image is framed by `(pre, pre')` at the new address. -/
theorem Rel.allocFramed (h : Rel F FR M ν K s S t C) (o o' : Obj) {pre pre' : List Val}
    (hn : s.next < Sim.bound) (hfo : FramedObj M pre pre' o o')
    (ho : Supp.obj (Present (s.alloc (.obj o)).2) S.tab.length o) :
    (t.alloc (.obj o')).1 = M.a (s.alloc (.obj o)).1 ∧
      Rel F FR M ν (Ctx.frameAt K s.next (pre, pre')) (s.alloc (.obj o)).2 S (t.alloc (.obj o')).2 C := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  have htn : t.next < 2 ^ 62 := h.tnext hn
  have hs64 : s.next < 2 ^ 64 := by rw [hb] at hn; omega
  have ht64 : t.next < 2 ^ 64 := by omega
  have hat : M.a s.next = t.next := by simpa using h.next 0
  have hP : ∀ a, Present s a → Present (s.alloc (.obj o)).2 a := fun _ hp => Present.alloc _ hs64 hp
  have hP' : ∀ a, Present (s.alloc (.obj o)).2 a → a = s.next ∨ Present s a :=
    fun _ hp => Present.of_alloc hs64 hp
  have hle : S.tab.length ≤ S.tab.length := Nat.le_refl _
  have hfrA : ∀ a, a ≠ s.next → (Ctx.frameAt K s.next (pre, pre')).fr a = K.fr a := by
    intro a ha
    show (bif Nat.beq a s.next then some (pre, pre') else K.fr a) = K.fr a
    have : Nat.beq a s.next = false := by
      cases e : Nat.beq a s.next
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true e) ha
    rw [this]; rfl
  have hfrN : (Ctx.frameAt K s.next (pre, pre')).fr s.next = some (pre, pre') := by
    show (bif Nat.beq s.next s.next then some (pre, pre') else K.fr s.next) = _
    rw [Nat.beq_refl]; rfl
  obtain ⟨fresh, hs, hsupp⟩ := h.traceSupp
  refine ⟨hat.symm, ?_⟩
  exact {
    srv := h.srv
    bigFixed := h.bigFixed
    bigExt := h.bigExt
    band := h.band
    intr := h.intr
    heap := fun a o0 hg => by
      rw [alloc_get s _ hs64] at hg
      by_cases ha : a = s.next
      · subst ha
        rw [ite_eq_left rfl] at hg
        obtain rfl := Option.some.inj hg
        refine (SlotOK.some_iff hfrN).2 ⟨o, o', rfl, ?_, hfo⟩
        rw [hat, alloc_get t _ ht64, ite_eq_left rfl]
      · rw [ite_eq_right ha] at hg
        have hne : M.a a ≠ t.next := Nat.ne_of_lt (h.bound a (Present.of_get hg))
        refine SlotOK.congr_fr (hfrA a ha) ?_
        rw [alloc_get t _ ht64, ite_eq_right hne]
        exact h.heap a o0 hg
    next := fun k => by
      show M.a (s.next + 1 + k) = t.next + 1 + k
      rw [show s.next + 1 + k = s.next + (k + 1) by omega, h.next (k + 1),
        show t.next + (k + 1) = t.next + 1 + k by omega]
    offset := by
      show t.next + 1 = s.next + 1 + K.D
      have := h.offset
      omega
    room := h.room
    bound := fun a hp => by
      show M.a a < t.next + 1
      rcases hP' a hp with rfl | hp
      · omega
      · have := h.bound a hp
        omega
    inj := fun a b hpa hpb he => by
      rcases hP' a hpa with rfl | hpa <;> rcases hP' b hpb with rfl | hpb
      · rfl
      · have := h.bound b hpb
        omega
      · have := h.bound a hpa
        omega
      · exact h.inj a b hpa hpb he
    presentBound := fun a hp => by
      show a < s.next + 1
      rcases hP' a hp with rfl | hp
      · omega
      · have := h.presentBound a hp
        omega
    framedPresent := fun a p hf => by
      by_cases ha : a = s.next
      · subst ha; exact Present.alloc_next s _ hs64
      · rw [hfrA a ha] at hf
        exact hP a (h.framedPresent a p hf)
    ctl := h.ctl
    stack := h.stack
    jobs := h.jobs
    stores := h.stores
    ffi := h.ffi
    trace := h.trace
    heapSupp := fun a o0 hg => by
      rw [alloc_get s _ hs64] at hg
      by_cases ha : a = s.next
      · rw [ite_eq_left ha] at hg
        obtain rfl := Option.some.inj hg
        exact ho
      · rw [ite_eq_right ha] at hg
        exact Supp.hobj_mono hP hle (h.heapSupp a o0 hg)
    ctlSupp := Supp.ctl_mono hP hle h.ctlSupp
    stackSupp := fun f hf => Supp.frame_mono hP hle (h.stackSupp f hf)
    jobsSupp := fun j hj => Supp.job_mono hP hle (h.jobsSupp j hj)
    storesSupp := Supp.stores_mono hP hle h.storesSupp
    traceSupp := ⟨fresh, hs, fun e he => Supp.event_mono hP hle (hsupp e he)⟩ }

/-- The last-element spread of a framed array `b` into an array literal (`[...acc, ...b]`):
the new array at `s.next` is framed in the resulting relation; the target's FFI state is unchanged. -/
theorem step_spread_framed (h : Rel F FR M ν K s S t C) {b : Nat} {acc : List Val} {env : Env}
    {fs : List Frame} {pre pre' : List Val}
    (hc : s.ctl = .ret (.obj b)) (hst : s.stack = .l (.spread acc [] env) :: fs)
    (hb : K.fr b = some (pre, pre')) (hn : s.next + margin < Sim.bound) (hp : Present s aArrayProto) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      Rel F FR M' ν ⟨fun a => bif Nat.beq a s.next then some (acc.reverse ++ pre, M.vals acc.reverse ++ pre')
        else K.fr a, K.base, K.base', K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧ t1.ffi = t.ffi) S C (step F s) (step F t) := by
  have hn' : s.next < Sim.bound := Nat.lt_of_le_of_lt (Nat.le_add_right _ _) hn
  obtain ⟨e1, e2, hr, _, hf⟩ := h.rfRetFrame hc hst
  obtain ⟨hh, hg⟩ := Present.get (h.framedPresent b _ hb)
  obtain ⟨o, o', rfl, ht, xs, hk, rfl⟩ := (SlotOK.some_iff hb).1 (h.heap b _ hg)
  have hso := h.obj?_supp (obj?_iff.2 hg)
  obtain ⟨kd, pr, ps, pv, ex⟩ := o
  simp only at hk
  subst hk
  have hsoS : ({ s with stack := fs } : St F.S).obj? b = some ⟨.array (pre ++ xs), pr, ps, pv, ex⟩ :=
    obj?_iff.2 hg
  have htoT : ({ t with stack := fs.map M.frame } : St F.S).obj? (M.a b) =
      some ⟨.array (pre' ++ M.vals xs), M.val pr, M.props ps, M.privs pv, ex⟩ := obj?_iff.2 ht
  rw [e1, e2]
  show MSim _ S C (spreadElems F { s with stack := fs } (.obj b) (.l (.spread acc [] env))
      fun es => arrayNext F { s with stack := fs } (es.reverse ++ acc) [] env)
    (spreadElems F { t with stack := fs.map M.frame } (.obj (M.a b)) (.l (.spread (M.vals acc) [] (M.env env)))
      fun es => arrayNext F { t with stack := fs.map M.frame } (es.reverse ++ M.vals acc) [] (M.env env))
  simp only [spreadElems, elemsOf, hsoS, htoT]
  show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure _)
  -- the new arrays
  have hrev : ((pre ++ xs).reverse ++ acc).reverse = acc.reverse ++ pre ++ xs := by simp
  have hrev' : ((pre' ++ M.vals xs).reverse ++ M.vals acc).reverse = M.vals acc.reverse ++ pre' ++ M.vals xs := by
    simp [Map.vals, List.map_reverse]
  simp only [hrev, hrev']
  have hS : Supp.vals (Present s) S.tab.length (acc.reverse ++ pre ++ xs) := by
    intro v hv
    rcases List.mem_append.1 hv with hv | hv
    · rcases List.mem_append.1 hv with hv | hv
      · exact hf.1 v (List.mem_reverse.1 hv)
      · exact hso.1 v (List.mem_append_left _ hv)
    · exact hso.1 v (List.mem_append_right _ hv)
  have hs64 : s.next < 2 ^ 64 := by have : Sim.bound = 2 ^ 61 := rfl; omega
  have hPs : ∀ a, Present s a → Present (({ s with stack := fs } : St F.S).alloc
      (.obj ⟨.array (acc.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩)).2 a :=
    fun a ha => Present.alloc (s := { s with stack := fs }) _ hs64 ha
  have hfo : FramedObj M (acc.reverse ++ pre) (M.vals acc.reverse ++ pre')
      ⟨.array (acc.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩
      ⟨.array (M.vals acc.reverse ++ pre' ++ M.vals xs), .obj aArrayProto, [], [], true⟩ := by
    refine ⟨xs, by simp, ?_⟩
    have hI : M.a aArrayProto = aArrayProto := h.intr _ (by decide)
    simp only [Map.obj, Map.val, hI, Map.props, List.map_nil, List.append_assoc]
  obtain ⟨ea, hr1⟩ := Rel.allocFramed hr _ _ hn' hfo
    ⟨Supp.vals_mono hPs (Nat.le_refl _) hS, hPs _ hp, fun _ hx => by simp at hx, fun _ hx => by simp at hx⟩
  have hv : Supp.val (Present (({ s with stack := fs } : St F.S).alloc
      (.obj ⟨.array (acc.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩)).2) S.tab.length
      (.obj (({ s with stack := fs } : St F.S).alloc
        (.obj ⟨.array (acc.reverse ++ pre ++ xs), .obj aArrayProto, [], [], true⟩)).1) :=
    Present.alloc_next (s := { s with stack := fs }) _ hs64
  have := hr1.ret _ hv
  simp only [Map.val] at this
  rw [← ea] at this
  exact MSim.pure ⟨Grow.refl h.srv, this, rfl⟩

end
end Host.Ts.Sim.Disp
