import host.sim.Restart
namespace Host.Ts.Sim

/-! # Proof of the restart -/

/-- Mapping an object with a replaced kind replaces the image's kind. -/
private theorem obj_withKind (M : Map) (o : Obj) (k k' : Kind) :
    { M.obj { o with kind := k } with kind := k' } = { M.obj o with kind := k' } := rfl

/-- The framed prefixes after the iteration are the old ones, the target prefix
extended by the image of the appended elements. -/
private theorem framedNext_eq {F : Ffi} {M : Map} {K : Ctx} {s1 : St F.S} {a : Nat}
    {pre pre' xs : List Val} {o : Obj} (hk : K.fr a = some (pre, pre'))
    (hs : s1.heap.get a = some (.obj { o with kind := .array (pre ++ xs) })) :
    Shift.framedNext M K s1 a = some (pre, pre' ++ M.vals xs) := by
  simp only [Shift.framedNext, hk, hs, List.drop_left]

private theorem framedNext_some {F : Ffi} {M : Map} {K : Ctx} {s1 : St F.S} {a : Nat}
    {p : List Val × List Val} (h : Shift.framedNext M K s1 a = some p) : ∃ q, K.fr a = some q := by
  unfold Shift.framedNext at h
  cases hk : K.fr a with
  | none => simp [hk] at h
  | some q => exact ⟨q, rfl⟩

theorem restart {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop} :
    RestartStatement F FR FS := by
  intro M σ ν θ K s0 s1 t S0 S1 C hFS hr hs hg hroom
  have hpres0 : ∀ a h, s0.heap.get a = some h → Present s0 a := fun a h ha => by
    simp [Present, ha]
  -- Present unframed addresses map to unframed addresses.
  have hunfr : ∀ a h, s0.heap.get a = some h → K.fr a = none → K.fr (σ.a a) = none := by
    intro a h ha hk
    cases hk' : K.fr (σ.a a) with
    | none => rfl
    | some p =>
      have hp := hs.framedPresent _ _ hk'
      have hfix := (hs.framed (σ.a a) p.1 p.2 hk').1
      have heq := hs.inj a (σ.a a) (hpres0 a h ha) hp hfix.symm
      rw [← heq, hk] at hk'
      cases hk'
  refine
    { srv := ⟨fun i e he => ?_, hg⟩
      heap := fun a h ha => ?_
      next := fun k => ?_
      offset := ?_
      room := hroom
      bigFixed := fun i hi => ?_
      bigExt := fun r off hoff => ?_
      band := hr.band
      intr := fun a ha => by
        show M.a (σ.a a) = a
        rw [hs.intr a ha, hr.intr a ha]
      bound := fun a ha => hr.bound _ (hs.present a ha)
      inj := fun a b ha hb hab => hs.inj a b ha hb (hr.inj _ _ (hs.present a ha) (hs.present b hb) hab)
      presentBound := hs.presentBound
      framedPresent := fun a p hp => ?_
      ctl := ?_
      stack := ?_
      jobs := ?_
      stores := ?_
      ffi := hFS _ _ _ hs.ffi hr.ffi
      trace := ⟨[], by simp, by simp⟩
      heapSupp := hs.heapSupp
      ctlSupp := hs.ctlSupp
      stackSupp := hs.stackSupp
      jobsSupp := hs.jobsSupp
      storesSupp := hs.storesSupp
      traceSupp := ⟨[], by simp, by simp⟩ }
  · -- srv
    have h1 := hr.srv.num.val (hs.num i e he)
    rw [SymE.eval_subst] at h1
    exact h1
  · -- heap
    refine (SlotW.of_w_none rfl).2 ?_
    show SlotOK (M.after σ) (Shift.framedNext M K s1) a h (t.heap.get (M.a (σ.a a)))
    cases hk : K.fr a with
    | none =>
      have hk1 := hunfr a h ha hk
      have h1 := (SlotW.of_w_none rfl).1 (hr.heap _ _ (hs.heap a h ha hk))
      have hn : Shift.framedNext M K s1 a = none := by simp [Shift.framedNext, hk]
      simp only [SlotOK, hk1] at h1
      simp only [SlotOK, hn, h1, Map.hobj_after]
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      obtain ⟨hfix, o, xs, ho, hkind, hs1⟩ := hs.framed a pre pre' hk
      rw [ho] at ha
      cases ha
      have h1 := (SlotW.of_w_none rfl).1 (hr.heap _ _ hs1)
      rw [hfix]
      simp only [SlotOK, hk] at h1
      obtain ⟨o1, o', he1, ht, ys, hys, ho'⟩ := h1
      cases he1
      simp only at hys
      have hxy : ys = xs := (List.append_cancel_left (Kind.array.inj hys)).symm
      subst hxy
      simp only [SlotOK, framedNext_eq (M := M) hk hs1]
      refine ⟨o, o', rfl, ht, [], by rw [hkind, List.append_nil], ?_⟩
      rw [ho', obj_withKind, Map.obj_after]
      simp only [Map.vals, List.map_nil, List.append_nil]
  · -- next
    show M.a (σ.a (s0.next + k)) = t.next + k
    rw [hs.next, hr.next]
  · -- offset
    have := hr.offset
    have := hs.grows
    show t.next = s0.next + (t.next - s0.next)
    omega
  · -- bigFixed
    show M.big (σ.big i) = i
    rw [hs.bigFixed i hi, hr.bigFixed i hi]
  · -- bigExt
    show M.big (σ.big (ptrInt (.ext r) off)) = ptrInt (.ext (M.region (σ.region r))) off
    rw [hs.bigExt r off hoff, hr.bigExt _ off hoff]
  · -- framedPresent
    obtain ⟨q, hq⟩ := framedNext_some hp
    exact hs.framedPresent a q hq
  · -- ctl
    rw [hr.ctl, hs.ctl, Map.ctl_after]
  · -- stack
    rw [hr.stack, hs.stack, List.map_map]
    exact congrArg (· ++ []) (List.map_congr_left fun f _ => Map.frame_after M σ f)
  · -- jobs
    rw [hr.jobs, hs.jobs, List.map_map]
    exact List.map_congr_left fun j _ => Map.job_after M σ j
  · -- stores
    rw [hr.stores, hs.stores, Map.stores_after]

end Host.Ts.Sim
