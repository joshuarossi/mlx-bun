import host.sim.Seg
namespace Host.Ts.Sim
open Host.Ts

/-! # Restarting with frames dropped and frames kept

A drain of the prefill chain creates frames (the chunk's buffer and typed array, sliced
arrays) that the next cut's template start does not hold; a run may also carry frames it keeps
(ghost slots). `ShiftD` is `Shift` from the template start `s0` to an end `s1` whose context
`K1` (and frames `W1`, `RelF`) may frame more than the start keeps:

* the kept framed arrays `kp` hold their template prefix at the start and keep their address;
* the kept frames `W0` keep their address and their source entry (up to `σ`), with their frame
  data fixed by `σ` (`WFix`; a frame's target entry is then related at the start by
  `WideOK.after`);
* every other address the start holds maps to an address `K1` leaves unframed (`unfr`).

The end's other frames are not reached from the start (the target may hold more), so
`restartDrop` relates the target to the start under `RelF … W0` with the kept frames only
(`dropNext`). With `W0 = noFrames` it drops every frame beyond the kept arrays; with `kp` all
framed arrays of `K1 = K` and `W0 = W1` it keeps every frame (`dropNext_keep`: the context is
`Shift.framedNext`'s, as `restart`'s). `ShiftD.ofJS` is the shift from the template fact
`ShiftJS` at the start's context without the kept frames' addresses (`Ctx.unW`).
`load_restart_drop` is `load_restart` for it. -/

/-! ## Frames across a shift -/

/-- What a restart needs of the shift `σ` at a kept frame: a typed array's buffer and the ghost
private names' brands are fixed (the brands present, `A`), the ghost keys are strings. -/
def WFix (σ : Map) (A : Nat → Prop) : WFrame → Prop
  | .typed _ b _ _ => σ.a b = b
  | .fields ks ps => (∀ k ∈ ks, ∃ cs, k = .str cs) ∧ ∀ p ∈ ps, σ.a p.1 = p.1 ∧ A p.1
  | _ => True

theorem Map.key_eq_str {σ : Map} {k : PKey} {cs : List Char} (h : σ.key k = .str cs) : k = .str cs := by
  cases k with
  | str c => exact h
  | sym i => cases h

theorem Kind.ordinary_of_map {σ : Map} {k : Kind} (h : σ.kind k = .ordinary) : k = .ordinary := by
  cases k <;> first | rfl | cases h

theorem Kind.map_of_map {σ : Map} {k : Kind} {es : List (Val × Val)} (h : σ.kind k = .map es) :
    ∃ es0, k = .map es0 ∧ es = σ.pairs es0 := by
  cases k with
  | map m => exact ⟨m, rfl, (Kind.map.inj h).symm⟩
  | _ => cases h

theorem Wideable.of_map {σ : Map} {k : Kind} (h : Wideable (σ.kind k)) : Wideable k := by
  cases k <;> first | trivial | exact (h : False).elim

theorem PropsW.after {M σ : Map} {ks : List PKey} (hks : ∀ k ∈ ks, ∃ cs, k = .str cs) :
    ∀ {L l' : Props}, PropsW M ks L l' → ∀ l : Props, L = σ.props l → PropsW (M.after σ) ks l l' := by
  intro L l' h
  induction h with
  | nil =>
    intro l hl
    cases l with
    | nil => exact .nil
    | cons x l => simp [Map.props] at hl
  | both k p p' L L' hk hp _ ih =>
    intro l hl
    cases l with
    | nil => simp [Map.props] at hl
    | cons x l =>
      obtain ⟨k0, p0⟩ := x
      simp only [Map.props, List.map_cons, List.cons.injEq, Prod.mk.injEq] at hl
      obtain ⟨⟨rfl, rfl⟩, hL⟩ := hl
      rw [Map.key_after]
      refine .both k0 p0 p' l L' (fun hk0 => ?_) (by rw [hp, Map.prop_after]) (ih l hL)
      obtain ⟨cs, rfl⟩ := hks k0 hk0
      exact hk hk0
  | ghostL k p L L' hk _ ih =>
    intro l hl
    cases l with
    | nil => simp [Map.props] at hl
    | cons x l =>
      obtain ⟨k0, p0⟩ := x
      simp only [Map.props, List.map_cons, List.cons.injEq, Prod.mk.injEq] at hl
      obtain ⟨⟨rfl, rfl⟩, hL⟩ := hl
      obtain ⟨cs, hcs⟩ := hks _ hk
      obtain rfl := Map.key_eq_str hcs
      exact .ghostL _ p0 l L' hk (ih l hL)
  | ghostR k p' L L' hk _ ih =>
    intro l hl
    refine .ghostR k p' l L' ?_ (ih l hl)
    obtain ⟨k0, hk0, he⟩ := hk
    obtain ⟨cs, rfl⟩ := hks k0 hk0
    exact ⟨_, hk0, he⟩

theorem PrivsW.after {M σ : Map} {ps : List (Nat × Name)} {A : Nat → Prop}
    (hps : ∀ p ∈ ps, σ.a p.1 = p.1 ∧ A p.1) (hinj : ∀ a b, A a → A b → σ.a a = σ.a b → a = b) :
    ∀ {L l' : List ((Nat × Name) × PropV)}, PrivsW M ps L l' → ∀ l : List ((Nat × Name) × PropV),
      (∀ x ∈ l, A x.1.1) → L = σ.privs l → PrivsW (M.after σ) ps l l' := by
  intro L l' h
  induction h with
  | nil =>
    intro l _ hl
    cases l with
    | nil => exact .nil
    | cons x l => simp [Map.privs] at hl
  | both b n p p' L L' hbn hp _ ih =>
    intro l hA hl
    cases l with
    | nil => simp [Map.privs] at hl
    | cons x l =>
      obtain ⟨⟨b0, n0⟩, p0⟩ := x
      simp only [Map.privs, List.map_cons, List.cons.injEq, Prod.mk.injEq] at hl
      obtain ⟨⟨⟨rfl, rfl⟩, rfl⟩, hL⟩ := hl
      refine .both b0 n p0 p' l L' (fun hm => hbn ?_) (by rw [hp, Map.prop_after])
        (ih l (fun x hx => hA x (List.mem_cons_of_mem _ hx)) hL)
      rw [(hps _ hm).1]
      exact hm
  | ghostL b n p L L' hbn _ ih =>
    intro l hA hl
    cases l with
    | nil => simp [Map.privs] at hl
    | cons x l =>
      obtain ⟨⟨b0, n0⟩, p0⟩ := x
      simp only [Map.privs, List.map_cons, List.cons.injEq, Prod.mk.injEq] at hl
      obtain ⟨⟨⟨rfl, rfl⟩, rfl⟩, hL⟩ := hl
      have hq := hps _ hbn
      have hb0 : b0 = σ.a b0 := hinj _ _ (hA _ (List.mem_cons_self ..)) hq.2 hq.1.symm
      refine .ghostL b0 n p0 l L' ?_ (ih l (fun x hx => hA x (List.mem_cons_of_mem _ hx)) hL)
      rw [hb0]
      exact hbn
  | ghostR b' n p' L L' hb _ ih =>
    intro l hA hl
    refine .ghostR b' n p' l L' ?_ (ih l hA hl)
    obtain ⟨b, hbm, he⟩ := hb
    refine ⟨b, hbm, ?_⟩
    show M.a (σ.a b) = b'
    rw [(hps _ hbm).1]
    exact he

theorem MapW.after {M σ : Map} {gs : List Nat} {es0 es' : List (Val × Val)} (h : MapW M gs (σ.pairs es0) es') :
    MapW (M.after σ) gs es0 es' := by
  intro c v hv
  obtain ⟨v', h1, h2⟩ := h c (σ.val v) (by rw [bi_firstValue σ c es0, hv]; rfl)
  exact ⟨v', h1, h2.imp id fun e => by rw [e, Map.val_after]⟩

/-- **A frame's target entry at the end is one at the start**: a source entry kept up to `σ`
(`σ.hobj h` at the end, `h` at the start) under a frame whose data `σ` fixes. -/
theorem WideOK.after {M σ : Map} {A : Nat → Prop} {n : Nat} {w : WFrame} {h : HObj} {h' : Option HObj}
    (hfix : WFix σ A w) (hinj : ∀ a b, A a → A b → σ.a a = σ.a b → a = b) (hs : Supp.hobj A n h)
    (hw : WideOK M w (σ.hobj h) h') : WideOK (M.after σ) w h h' := by
  cases h with
  | cell v =>
    cases w with
    | ghost =>
      cases h' with
      | none => exact hw.elim
      | some x =>
        cases x with
        | cell _ => trivial
        | obj _ => exact hw.elim
    | _ =>
      cases h' with
      | none => exact hw.elim
      | some x => cases x <;> exact hw.elim
  | obj o =>
    cases h' with
    | none => cases w <;> exact hw.elim
    | some x =>
      cases x with
      | cell _ => cases w <;> exact hw.elim
      | obj o' =>
        obtain ⟨kd, pr, ps, pv, ex⟩ := o
        cases w with
        | buf bs' =>
          obtain ⟨hk, rfl⟩ := hw
          exact ⟨Kind.ordinary_of_map hk, by rw [Map.obj_after]⟩
        | typed k b off n' =>
          obtain ⟨hk, rfl⟩ := hw
          have hb : (M.after σ).a b = M.a b := by
            show M.a (σ.a b) = M.a b
            rw [show σ.a b = b from hfix]
          exact ⟨Kind.ordinary_of_map hk, by rw [Map.obj_after, hb]⟩
        | ghost => exact ⟨Wideable.of_map hw.1, hw.2⟩
        | fields ks qs =>
          obtain ⟨h1, h2, h3, h4, h5, h6⟩ := hw
          have hA : ∀ x ∈ pv, A x.1.1 := fun x hx => (hs.2.2.2 x hx).1
          refine ⟨Wideable.of_map h1, ?_, ?_, h4, PropsW.after hfix.1 h5 ps rfl,
            PrivsW.after hfix.2 hinj h6 pv hA rfl⟩
          · rw [h2]; exact Map.kind_after M σ kd
          · rw [h3]; exact Map.val_after M σ pr
        | mapKeys gs =>
          obtain ⟨es, es', hk, rfl, hm⟩ := hw
          obtain ⟨es0, rfl, rfl⟩ := Kind.map_of_map hk
          exact ⟨es0, es', rfl, by rw [Map.obj_after], MapW.after hm⟩
        | memo gs =>
          obtain ⟨es, es', hk, rfl, hm, hn⟩ := hw
          obtain ⟨es0, rfl, rfl⟩ := Kind.map_of_map hk
          refine ⟨es0, es', rfl, by rw [Map.obj_after], MapW.after hm, fun c hg h0 => hn c hg ?_⟩
          rw [bi_firstValue σ c es0, h0]; rfl

/-! ## Frames under a reassignment of the handles -/

section
variable {I : Int → Prop} {M : Map} {b : Int → Int}

theorem PropsW.rebig (hb : ∀ i, ¬ I i → b i = M.big i) {ks : List PKey} :
    ∀ {l l' : Props}, NoBig.props I l → PropsW M ks l l' → PropsW (M.withBig b) ks l l' := by
  intro l l' hx h
  induction h with
  | nil => exact .nil
  | both k p p' l l' hk hp _ ih =>
    have hpx : NoBig.prop I p := hx (k, p) (List.mem_cons_self ..)
    exact .both k p p' l l' hk (by rw [hp, Map.prop_rebig hb hpx])
      (ih fun x hm => hx x (List.mem_cons_of_mem _ hm))
  | ghostL k p l l' hk _ ih => exact .ghostL k p l l' hk (ih fun x hm => hx x (List.mem_cons_of_mem _ hm))
  | ghostR k p' l l' hk _ ih => exact .ghostR k p' l l' hk (ih hx)

theorem PrivsW.rebig (hb : ∀ i, ¬ I i → b i = M.big i) {ps : List (Nat × Name)} :
    ∀ {l l' : List ((Nat × Name) × PropV)}, (∀ x ∈ l, NoBig.prop I x.2) → PrivsW M ps l l' →
      PrivsW (M.withBig b) ps l l' := by
  intro l l' hx h
  induction h with
  | nil => exact .nil
  | both b0 n p p' l l' hk hp _ ih =>
    have hpx : NoBig.prop I p := hx ((b0, n), p) (List.mem_cons_self ..)
    exact .both b0 n p p' l l' hk (by rw [hp, Map.prop_rebig hb hpx])
      (ih fun x hm => hx x (List.mem_cons_of_mem _ hm))
  | ghostL b0 n p l l' hk _ ih => exact .ghostL b0 n p l l' hk (ih fun x hm => hx x (List.mem_cons_of_mem _ hm))
  | ghostR b' n p' l l' hk _ ih => exact .ghostR b' n p' l l' hk (ih hx)

theorem MapW.rebig (hb : ∀ i, ¬ I i → b i = M.big i) {gs : List Nat} {es es' : List (Val × Val)}
    (hx : NoBig.pairs I es) (h : MapW M gs es es') : MapW (M.withBig b) gs es es' := by
  intro c v hv
  obtain ⟨v', h1, h2⟩ := h c v hv
  obtain ⟨k, hk⟩ := firstValue_mem hv
  exact ⟨v', h1, h2.imp id fun e => by rw [e, Map.val_rebig hb (hx _ hk).2]⟩

theorem WideOK.rebig (hb : ∀ i, ¬ I i → b i = M.big i) {w : WFrame} {h : HObj} {h' : Option HObj}
    (hx : NoBig.hobj I h) (hw : WideOK M w h h') : WideOK (M.withBig b) w h h' := by
  cases h with
  | cell v =>
    cases w with
    | ghost => cases h' with
      | none => exact hw.elim
      | some x => cases x with
        | cell _ => trivial
        | obj _ => exact hw.elim
    | _ => cases h' with
      | none => exact hw.elim
      | some x => cases x <;> exact hw.elim
  | obj o =>
    cases h' with
    | none => cases w <;> exact hw.elim
    | some x =>
      cases x with
      | cell _ => cases w <;> exact hw.elim
      | obj o' =>
        cases w with
        | buf bs' => exact ⟨hw.1, by rw [hw.2, Map.obj_rebig hb hx]⟩
        | typed k b0 off n' => exact ⟨hw.1, by rw [hw.2, Map.obj_rebig hb hx]; rfl⟩
        | ghost => exact hw
        | fields ks ps =>
          obtain ⟨h1, h2, h3, h4, h5, h6⟩ := hw
          exact ⟨h1, by rw [h2, Map.kind_rebig hb hx.1], by rw [h3, Map.val_rebig hb hx.2.1], h4,
            PropsW.rebig hb hx.2.2.1 h5, PrivsW.rebig hb hx.2.2.2 h6⟩
        | mapKeys gs =>
          obtain ⟨es, es', hk, rfl, hm⟩ := hw
          have hp : NoBig.pairs I es := by have := hx.1; rw [hk] at this; exact this
          exact ⟨es, es', hk, by rw [Map.obj_rebig hb hx], MapW.rebig hb hp hm⟩
        | memo gs =>
          obtain ⟨es, es', hk, rfl, hm, hn⟩ := hw
          have hp : NoBig.pairs I es := by have := hx.1; rw [hk] at this; exact this
          exact ⟨es, es', hk, by rw [Map.obj_rebig hb hx], MapW.rebig hb hp hm, hn⟩

theorem SlotW.rebig (hb : ∀ i, ¬ I i → b i = M.big i) {fr : Nat → Option (List Val × List Val)}
    {W : Nat → Option WFrame} {a : Nat} {h : HObj} {h' : Option HObj}
    (hx : NoBig.hobj I h) (hok : SlotW M fr W a h h') : SlotW (M.withBig b) fr W a h h' := by
  cases hw : W a with
  | none => exact (SlotW.of_w_none hw).2 (SlotOK.rebig hb hx ((SlotW.of_w_none hw).1 hok))
  | some w =>
    cases hf : fr a with
    | none => exact (SlotW.of_fr_none hf).2 (by rw [(SlotW.of_fr_none hf).1 hok, Map.hobj_rebig hb hx])
    | some p => exact (SlotW.of_wide hf hw).2 (WideOK.rebig hb hx ((SlotW.of_wide hf hw).1 hok))

end

/-- `Rel.rebig` (`BigFree.lean`) under frames. -/
theorem RelF.rebig {F FR FR' W M ν K s S t C} {I : Int → Prop} {b : Int → Int}
    (h : RelF F FR W M ν K s S t C) (hb : ∀ i, ¬ I i → b i = M.big i)
    (hI : ∀ i, I i → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hfree : NoBigSt I K.base s)
    (hffi : FR' (M.withBig b) S.tab.length s.ffi t.ffi) :
    RelF F FR' W (M.withBig b) ν K s S t C := by
  obtain ⟨fresh, hs, ht⟩ := h.trace
  have hfresh : ∀ e ∈ fresh, NoBig.event I e := fun e he =>
    hfree.trace e (by rw [freshOf_eq hs]; exact he)
  have hge : ∀ r off : Nat, (2 : Int) ^ 56 ≤ ptrInt (.ext r) off := fun r off => by
    have : (2 : Nat) ^ 56 ≤ 2 ^ 62 + r * 2 ^ 24 + off :=
      Nat.le_trans (Nat.pow_le_pow_right (by decide) (by decide)) (Nat.le_add_right_of_le (Nat.le_add_right _ _))
    show ((2 : Nat) ^ 56 : Int) ≤ ((2 ^ 62 + r * 2 ^ 24 + off : Nat) : Int)
    exact Int.ofNat_le.mpr this
  exact {
    srv := ⟨fun i e he => h.srv.num i e he, h.srv.good⟩
    heap := fun a o hg => SlotW.rebig hb (hfree.heap a o hg) (h.heap a o hg)
    next := h.next
    offset := h.offset
    room := h.room
    bigFixed := fun i hi => by
      show b i = i
      rw [hb i fun hIi => (hI i hIi).1 hi]
      exact h.bigFixed i hi
    bigExt := fun r off ho => by
      show b (ptrInt (.ext r) off) = ptrInt (.ext (M.region r)) off
      have hn : ¬ I (ptrInt (.ext r) off) := fun hIi =>
        Int.lt_irrefl _ (Int.lt_of_lt_of_le (hI _ hIi).2.2 (hge r off))
      rw [hb _ hn]
      exact h.bigExt r off ho
    band := h.band
    intr := h.intr
    bound := h.bound
    inj := h.inj
    presentBound := h.presentBound
    framedPresent := h.framedPresent
    ctl := h.ctl.trans (Map.ctl_rebig hb hfree.ctl).symm
    stack := by
      rw [h.stack]
      exact congrArg (· ++ []) (List.map_congr_left fun f hf => (Map.frame_rebig hb (hfree.stack f hf)).symm)
    jobs := by
      rw [h.jobs]
      exact List.map_congr_left fun j hj => (Map.job_rebig hb (hfree.jobs j hj)).symm
    stores := h.stores.trans (Map.stores_rebig hb hfree.stores).symm
    ffi := hffi
    trace := ⟨fresh, hs, by
      rw [ht, List.map_congr_left fun e he => Map.event_rebig hb (hfresh e he)]⟩
    heapSupp := h.heapSupp
    ctlSupp := h.ctlSupp
    stackSupp := h.stackSupp
    jobsSupp := h.jobsSupp
    storesSupp := h.storesSupp
    traceSupp := h.traceSupp }

/-! ## The shift with kept frames -/

/-- `Shift` with kept framed arrays `kp` and kept frames `W0`, to the end context `K1`. -/
structure ShiftD (F : Ffi) (FS : Map → F.S → F.S → Prop) (σ : Map) (θ : Nat → SymE) (kp : Nat → Bool)
    (W0 : Nat → Option WFrame) (K1 : Ctx) (s0 : St F.S) (S0 : SSrv) (s1 : St F.S) (S1 : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S1.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → kp a = false → W0 a = none → s1.heap.get (σ.a a) = some (σ.hobj h)
  unfr : ∀ a h, s0.heap.get a = some h → kp a = false → W0 a = none → K1.fr (σ.a a) = none
  framed : ∀ a, kp a = true → σ.a a = a ∧ ∃ pre pre' o xs, K1.fr a = some (pre, pre') ∧
    s0.heap.get a = some (.obj o) ∧ o.kind = .array pre ∧
    s1.heap.get a = some (.obj { σ.obj o with kind := .array (pre ++ xs) })
  wide : ∀ a w, W0 a = some w → kp a = false ∧ σ.a a = a ∧ K1.fr a ≠ none ∧ Present s0 a ∧
    (∀ h, s0.heap.get a = some h → s1.heap.get a = some (σ.hobj h)) ∧ WFix σ (Present s0) w
  next : ∀ k, σ.a (s0.next + k) = s1.next + k
  grows : s0.next ≤ s1.next
  present : ∀ a, Present s0 a → Present s1 (σ.a a)
  inj : ∀ a b, Present s0 a → Present s0 b → σ.a a = σ.a b → a = b
  presentBound : ∀ a, Present s0 a → a < s0.next
  ctl : s1.ctl = σ.ctl s0.ctl
  stack : s1.stack = s0.stack.map σ.frame
  jobs : s1.jobs = s0.jobs.map σ.job
  stores : s1.stores = σ.stores s0.stores
  ffi : FS σ s0.ffi s1.ffi
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) S0.tab.length h
  ctlSupp : Supp.ctl (Present s0) S0.tab.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) S0.tab.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) S0.tab.length j
  storesSupp : Supp.stores (Present s0) S0.tab.length s0.stores
  bigFixed : ∀ i, BigFixed K1.lo K1.hi i → σ.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → σ.big (ptrInt (.ext r) off) = ptrInt (.ext (σ.region r)) off
  intr : ∀ a, a < aFirst → σ.a a = a

/-- The frames after the restart: `Shift.framedNext` at the kept arrays, the end's frame at the
kept frames, none elsewhere. -/
def dropNext {F : Ffi} (M : Map) (K1 : Ctx) (kp : Nat → Bool) (W0 : Nat → Option WFrame) (s1 : St F.S)
    (a : Nat) : Option (List Val × List Val) :=
  bif kp a then Shift.framedNext M K1 s1 a else bif (W0 a).isSome then K1.fr a else none

theorem ShiftD.withOracle {F : Ffi} {FS : Map → F.S → F.S → Prop} {σ : Map} {θ : Nat → SymE} {kp : Nat → Bool}
    {W0 : Nat → Option WFrame} {K1 : Ctx} {s0 s1 : St F.S} {S0 S1 : SSrv} (h : ShiftD F FS σ θ kp W0 K1 s0 S0 s1 S1)
    (o : List Ans) : ShiftD F FS σ θ kp W0 K1 s0 ⟨S0.tab, o⟩ s1 S1 :=
  { h with }

/-- The framed addresses after the restart: the kept arrays and the kept frames. -/
theorem dropNext_framed {F : Ffi} {M : Map} {K1 : Ctx} {kp : Nat → Bool} {W0 : Nat → Option WFrame} {s1 : St F.S}
    (hk : ∀ a, kp a = true → K1.fr a ≠ none) (hw : ∀ a w, W0 a = some w → K1.fr a ≠ none) (a : Nat) :
    dropNext M K1 kp W0 s1 a ≠ none ↔ kp a = true ∨ (W0 a).isSome = true := by
  unfold dropNext
  cases hka : kp a with
  | false =>
    cases hwa : W0 a with
    | none => simp
    | some w => simp only [Bool.cond_false, Option.isSome_some, Bool.cond_true]; simpa using hw a w hwa
  | true =>
    simp only [Bool.cond_true, true_or, iff_true]
    unfold Shift.framedNext
    cases hf : K1.fr a with
    | none => exact absurd hf (hk a hka)
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      simp only
      split
      · split <;> simp
      · simp

/-- At a kept array the frame is `framedNext`'s. -/
theorem dropNext_eq {F : Ffi} {M : Map} {K1 : Ctx} {kp : Nat → Bool} {W0 : Nat → Option WFrame} {s1 : St F.S}
    {a : Nat} (hk : kp a = true) : dropNext M K1 kp W0 s1 a = Shift.framedNext M K1 s1 a := by
  simp only [dropNext, hk, Bool.cond_true]

/-- The kept arrays of a context `K` under frames `W`: its framed addresses without a frame of `W`. -/
def kpOf (K : Ctx) (W : Nat → Option WFrame) (a : Nat) : Bool := (K.fr a).isSome && (W a).isNone

/-- `K` without the addresses of the frames `W`. -/
def Ctx.unW (K : Ctx) (W : Nat → Option WFrame) : Ctx :=
  ⟨fun a => bif (W a).isSome then none else K.fr a, K.base, K.base', K.D, K.lo, K.hi⟩

/-- **Keeping every frame**: with the kept arrays `kpOf K W` and the kept frames `W` of the end
relation's own context, the restarted context is `Shift.framedNext`'s. -/
theorem dropNext_keep {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {M M' : Map}
    {ν : Nat → F64} {K : Ctx} {s1 t : St F.S} {S1 : SSrv} {C : CSrv} (hr : RelF F FR W M ν K s1 S1 t C) :
    dropNext M' K (kpOf K W) W s1 = Shift.framedNext M' K s1 := by
  funext a
  unfold dropNext kpOf
  cases hf : K.fr a with
  | none =>
    have : Shift.framedNext M' K s1 a = none := by simp [Shift.framedNext, hf]
    rw [this]
    cases W a <;> rfl
  | some p =>
    cases hw : W a with
    | none => rfl
    | some w =>
      show some p = Shift.framedNext M' K s1 a
      obtain ⟨pre, pre'⟩ := p
      unfold Shift.framedNext
      rw [hf]
      cases hg : s1.heap.get a with
      | none => rfl
      | some x =>
        cases x with
        | cell _ => rfl
        | obj o =>
          simp only
          split
          · rename_i es hes
            exact (WideOK.not_array ((SlotW.of_wide hf hw).1 (hr.heap a _ hg)) hes).elim
          · rfl

/-- **The shift from the template fact `ShiftJS`** at the start's context `K` without the kept
frames' addresses, with the kept frames' facts; the end context `K1` keeps `K`'s frames, adds
frames only outside the image of the start, and has `K`'s band. -/
theorem ShiftD.ofJS {F : Ffi} {FS : Map → F.S → F.S → Prop} {σ : Map} {θ : Nat → SymE} {K K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 : St F.S} {S0 S1 : SSrv} (h : Template.ShiftJS F σ θ (K.unW W) s0 S0 s1 S1)
    (hffi : FS σ s0.ffi s1.ffi)
    (hwide : ∀ a w, W a = some w → K.fr a ≠ none ∧ σ.a a = a ∧ Present s0 a ∧ WFix σ (Present s0) w)
    (hkeep : ∀ a, K.fr a ≠ none → K1.fr a = K.fr a)
    (hnew : ∀ a, K1.fr a ≠ none → K.fr a = none → ∀ b, Present s0 b → σ.a b ≠ a)
    (hlo : K1.lo = K.lo) (hhi : K1.hi = K.hi) :
    ShiftD F FS σ θ (kpOf K W) W K1 s0 S0 s1 S1 := by
  have hu0 : ∀ a, W a = none → (K.unW W).fr a = K.fr a := fun a hw => by
    show (bif (W a).isSome then none else K.fr a) = K.fr a
    rw [hw]; rfl
  have hu1 : ∀ a w, W a = some w → (K.unW W).fr a = none := fun a w hw => by
    show (bif (W a).isSome then none else K.fr a) = none
    rw [hw]; rfl
  have hkpf : ∀ a, kpOf K W a = false → W a = none → K.fr a = none := fun a hk hw => by
    unfold kpOf at hk
    rw [hw] at hk
    cases hf : K.fr a with
    | none => rfl
    | some p => rw [hf] at hk; cases hk
  exact {
    num := h.num
    heap := fun a hh hg hk hw => h.heap a hh hg (by rw [hu0 a hw]; exact hkpf a hk hw)
    unfr := fun a hh hg hk hw => by
      have hKa := hkpf a hk hw
      have hpa : Present s0 a := Present.of_get hg
      cases hk1 : K1.fr (σ.a a) with
      | none => rfl
      | some p =>
        exfalso
        by_cases hK : K.fr (σ.a a) = none
        · exact hnew (σ.a a) (by rw [hk1]; simp) hK a hpa rfl
        · cases hw1 : W (σ.a a) with
          | some w =>
            obtain ⟨-, hfix, hp, -⟩ := hwide _ w hw1
            have e := h.inj a (σ.a a) hpa hp hfix.symm
            rw [← e, hw] at hw1
            cases hw1
          | none =>
            obtain ⟨q, hq⟩ := Option.ne_none_iff_exists'.1 hK
            obtain ⟨pre, pre'⟩ := q
            have hq0 : (K.unW W).fr (σ.a a) = some (pre, pre') := by rw [hu0 _ hw1, hq]
            have hfix := (h.framed (σ.a a) pre pre' hq0).1
            have e := h.inj a (σ.a a) hpa (h.framedPresent _ _ hq0) hfix.symm
            rw [← e, hKa] at hq
            cases hq
    framed := fun a hk => by
      unfold kpOf at hk
      simp only [Bool.and_eq_true, Option.isSome_iff_exists, Option.isNone_iff_eq_none] at hk
      obtain ⟨⟨p, hp⟩, hw⟩ := hk
      obtain ⟨pre, pre'⟩ := p
      have hq0 : (K.unW W).fr a = some (pre, pre') := by rw [hu0 a hw, hp]
      obtain ⟨hfix, o, xs, hg0, hko, hg1⟩ := h.framed a pre pre' hq0
      exact ⟨hfix, pre, pre', o, xs, by rw [hkeep a (by rw [hp]; simp), hp], hg0, hko, hg1⟩
    wide := fun a w hw => by
      obtain ⟨hK, hfix, hp, hwf⟩ := hwide a w hw
      refine ⟨by simp [kpOf, hw], hfix, by rw [hkeep a hK]; exact hK, hp, fun hh hg => ?_, hwf⟩
      have := h.heap a hh hg (hu1 a w hw)
      rwa [hfix] at this
    next := h.next
    grows := h.grows
    present := h.present
    inj := h.inj
    presentBound := h.presentBound
    ctl := h.ctl
    stack := h.stack
    jobs := h.jobs
    stores := h.stores
    ffi := hffi
    heapSupp := h.heapSupp
    ctlSupp := h.ctlSupp
    stackSupp := h.stackSupp
    jobsSupp := h.jobsSupp
    storesSupp := h.storesSupp
    bigFixed := fun i hi => h.bigFixed i (by rw [hlo, hhi] at hi; exact hi)
    bigExt := h.bigExt
    intr := h.intr }

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop} {W0 W1 : Nat → Option WFrame}

private theorem obj_withKind' (M : Map) (o : Obj) (k k' : Kind) :
    { M.obj { o with kind := k } with kind := k' } = { M.obj o with kind := k' } := rfl

/-- **The restart dropping frames.** A target related to the end of a segment under the end's
context `K1` and frames `W1` is related to the template start under `M.after σ`, at the
substituted valuation, with the kept arrays and the kept frames `W0` only (`dropNext`). -/
theorem restartDrop {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {kp : Nat → Bool} {K1 : Ctx}
    {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv}
    (hFS : ∀ x y z, FS σ x y → FR M S1.tab.length y z → FR (M.after σ) S0.tab.length x z)
    (hr : RelF F FR W1 M ν K1 s1 S1 t C) (hs : ShiftD F FS σ θ kp W0 K1 s0 S0 s1 S1)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) :
    RelF F FR W0 (M.after σ) (Shift.valuation θ ν)
      ⟨dropNext M K1 kp W0 s1, s0.trace, t.trace, t.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t C := by
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
  · have h1 := hr.srv.num.val (hs.num i e he)
    rw [SymE.eval_subst] at h1
    exact h1
  · show SlotW (M.after σ) (dropNext M K1 kp W0 s1) W0 a h (t.heap.get (M.a (σ.a a)))
    cases hk : kp a with
    | false =>
      cases hw0 : W0 a with
      | none =>
        have hk1 := hs.unfr a h ha hk hw0
        have h1 := (SlotW.of_fr_none hk1).1 (hr.heap _ _ (hs.heap a h ha hk hw0))
        have hn : dropNext M K1 kp W0 s1 a = none := by simp [dropNext, hk, hw0]
        rw [SlotW.of_fr_none hn, h1, Map.hobj_after]
      | some w =>
        obtain ⟨-, hfix, hK1, -, hkeep, hwf⟩ := hs.wide a w hw0
        obtain ⟨p, hp⟩ := Option.ne_none_iff_exists'.1 hK1
        have hdn : dropNext M K1 kp W0 s1 a = some p := by simp [dropNext, hk, hw0, hp]
        have h1 := (SlotW.of_wide hp (hW a w hw0)).1 (hr.heap _ _ (hkeep h ha))
        rw [hfix]
        exact (SlotW.of_wide hdn hw0).2 (WideOK.after hwf hs.inj (hs.heapSupp a h ha) h1)
    | true =>
      obtain ⟨hfix, pre, pre', o, xs, hfr, ho, hkind, hs1⟩ := hs.framed a hk
      rw [ho] at ha
      cases ha
      have hw0 : W0 a = none := by
        cases e : W0 a with
        | none => rfl
        | some w => rw [(hs.wide a w e).1] at hk; cases hk
      have hw : W1 a = none := hr.w_none (.of_array (obj?_iff.2 hs1) rfl) hfr
      have h1 := (SlotW.of_w_none hw).1 (hr.heap _ _ hs1)
      rw [hfix]
      obtain ⟨o1, o', he1, ht, ys, hys, ho'⟩ := (SlotOK.some_iff hfr).1 h1
      cases he1
      simp only at hys
      have hxy : ys = xs := (List.append_cancel_left (Kind.array.inj hys)).symm
      subst hxy
      have hdn : dropNext M K1 kp W0 s1 a = some (pre, pre' ++ M.vals ys) := by
        rw [dropNext_eq hk]
        simp only [Shift.framedNext, hfr, hs1, List.drop_left]
      refine (SlotW.of_w_none hw0).2 ((SlotOK.some_iff hdn).2 ⟨o, o', rfl, ht, [], by rw [hkind, List.append_nil], ?_⟩)
      rw [ho', obj_withKind', Map.obj_after]
      simp only [Map.vals, List.map_nil, List.append_nil]
  · show M.a (σ.a (s0.next + k)) = t.next + k
    rw [hs.next, hr.next]
  · have := hr.offset
    have := hs.grows
    show t.next = s0.next + (t.next - s0.next)
    omega
  · show M.big (σ.big i) = i
    rw [hs.bigFixed i hi, hr.bigFixed i hi]
  · show M.big (σ.big (ptrInt (.ext r) off)) = ptrInt (.ext (M.region (σ.region r))) off
    rw [hs.bigExt r off hoff, hr.bigExt _ off hoff]
  · cases hka : kp a with
    | true =>
      obtain ⟨-, pre, pre', o, xs, -, ho, -⟩ := hs.framed a hka
      exact Present.of_get ho
    | false =>
      cases hw0 : W0 a with
      | none => simp [dropNext, hka, hw0] at hp
      | some w => exact (hs.wide a w hw0).2.2.2.1
  · rw [hr.ctl, hs.ctl, Map.ctl_after]
  · rw [hr.stack, hs.stack, List.map_map]
    exact congrArg (· ++ []) (List.map_congr_left fun f _ => Map.frame_after M σ f)
  · rw [hr.jobs, hs.jobs, List.map_map]
    exact List.map_congr_left fun j _ => Map.job_after M σ j
  · rw [hr.stores, hs.stores, Map.stores_after]

/-! ## `Iter`'s steps under frames -/

theorem RelF.mapFR' {FR' : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv} (h : RelF F FR W1 M ν K s S t C) (hf : FR' M S.tab.length s.ffi t.ffi) :
    RelF F FR' W1 M ν K s S t C :=
  { h with ffi := hf }

theorem RelF.extendVar' {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
    (hFR : FRLaws FR) (h : RelF F FR W1 M ν K s S t C) {j : Nat} {v : NumV} {x : F64}
    (htab : ∀ e ∈ S.tab, e.noVar j = true) (hor : ∀ q ∈ S.oracle, q.noVar j = true)
    (hv : C.val v = some x) :
    RelF F FR W1 (M.setNum S.tab.length v) (upd ν j x) K s ⟨S.tab ++ [.var j], S.oracle⟩ t C := by
  have hs0 : Srv M (upd ν j x) S C := by
    refine ⟨fun i e he => ?_, good_upd h.srv.good hor⟩
    rw [h.srv.num i e he, SymE.eval_upd ν j x e (htab e (nth?_mem_some he))]
  have h1 : RelF F FR W1 M (upd ν j x) K s S t C := { h with srv := hs0 }
  refine h1.extend (Map.setNum_ext M S.tab.length v) ⟨fun i e he => ?_, ?_⟩ (by simp)
    hFR.stable hFR.mono
  · by_cases hi : i < S.tab.length
    · have e1 : nth? (S.tab ++ [SymE.var j]) i = nth? S.tab i := nth?_append_lt _ _ i hi
      simp only at he
      rw [e1] at he
      have : (M.setNum S.tab.length v).num i = M.num i := (Map.setNum_ext M S.tab.length v).num i hi
      rw [this]
      exact hs0.num i e he
    · have hlt := nth?_lt _ i e he
      simp only [List.length_append, List.length_singleton] at hlt
      have hi' : i = S.tab.length := by omega
      subst hi'
      simp only at he
      rw [nth?_length_append] at he
      cases he
      rw [Map.setNum_self, hv]
      simp [SymE.eval, upd_self]
  · exact good_upd h.srv.good hor

/-- `Rel.srvSwap` under frames. -/
theorem RelF.srvSwap {M : Map} {ν ν' : Nat → F64} {K : Ctx} {s t : St F.S} {S S' : SSrv} {C : CSrv}
    (h : RelF F FR W1 M ν K s S t C) (hS : S'.tab = S.tab) (hs : Srv M ν' S' C) : RelF F FR W1 M ν' K s S' t C := by
  obtain ⟨tab', o'⟩ := S'
  obtain ⟨tab, o⟩ := S
  simp only at hS
  subst hS
  exact { h with srv := hs }

end

/-! ## The load world's restart dropping frames -/

/-- **The load world's restart dropping frames** (`load_restart` with `ShiftD`): the end relation
under any frames `W1` and its own context `K1` (the start's offset and band), the kept arrays
`kp` and the kept frames `W0`. The restarted context's frames are `dropNext` (framed exactly at
the kept addresses, `dropNext_framed`). -/
theorem load_restart_drop {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {W W0 W1 : Nat → Option WFrame} {kp : Nat → Bool}
    {s0 s1 t t1 : St LF.S} {S0 S1 : SSrv} {C C1 : CSrv} {n : Nat}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (h : RelF LF (LR P r0) W M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC LF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF LF (LR P r0) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar 17 = true) (hor : ∀ q ∈ S1.oracle, q.noVar 17 = true)
    (hshift : ShiftD LF (FSn { P with rest := r0 } S0.tab.length s0.ffi) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var 17], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num 79 = .ref S1.tab.length) (htok : s0.ffi.mlx.tokens = [.ref 79]) (h79 : 79 < S0.tab.length)
    (hbig : bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true)
    (hfree : NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : s1.ffi.mlx.next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hroomN : t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62) :
    t1.next = t.next + (s1.next - s0.next) ∧
      t1.ffi.mlx.next = t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) ∧
      t1.ffi.mlx.nnext = t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) ∧
      RelF LF (LR P r) W0
        ((((M1.setNum S1.tab.length v).after σ)).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next)
        (Shift.valuation θ (upd ν 17 x))
        ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 := by
  subst hr0
  have hns : NShift { P with rest := v :: r } S0.tab.length σ s0.ffi s1.ffi := hshift.ffi.2
  have hl := lockstep h.ffi h1.ffi hext rfl hns.mlx.hnext.2 hE hns.mlx.nle
  have hoff : t1.next = t.next + (s1.next - s0.next) := by
    have e1 := h1.offset; rw [hKD] at e1; have := h.offset; have := hshift.grows; omega
  have htk : t1.ffi.mlx.tokens = v :: r := by
    have := h1.ffi.mlx.tokensX
    rw [hns.mlx.tokens] at this
    simpa using this
  have hvx : C1.val v = some x := (runC_le n t C t1 C1 hrc).val hx
  have hw : LoadRw { P with rest := v :: r } (M1.setNum S1.tab.length v) (S1.tab.length + 1)
      (clearTokens s1.ffi) t1.ffi := by
    rw [clearTokens_nil hns.mlx.tokens]
    exact (((loadR_laws _).stable _ _ _ _ _ h1.ffi (Map.setNum_ext M1 S1.tab.length v)).mono
      (Nat.le_succ _)).weak
  have hroom : t1.next - s0.next < Sim.bound := by
    rw [hoff]; have := h.offset; have := hshift.grows; omega
  have hf : FRr { P with rest := v :: r } s0.ffi (M1.setNum S1.tab.length v) (S1.tab.length + 1) s1.ffi t1.ffi := by
    refine ⟨hw, ?_, ?_⟩
    · show t1.ffi.mlx.next + (P.E - s0.ffi.mlx.next) < 2 ^ 46
      rw [hl.1]; omega
    · show t1.ffi.mlx.nnext + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62
      rw [hl.2]; omega
  have h2 := (h1.extendVar' (loadR_laws _) htab hor hvx).mapFR' (FR' := FRr { P with rest := v :: r } s0.ffi)
    (by simpa using hf)
  have hrel := restartDrop (F := LF) (FR := FRr { P with rest := v :: r } s0.ffi)
    (FS := FSn { P with rest := v :: r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => by simpa using fsn_compose _ x y z hxy (by simpa using hyz)) h2
    (hshift.withOracle []) hW (fun _ hq => by cases hq) hroom
  rw [hKlo, hKhi] at hrel
  refine ⟨hoff, hl.1, hl.2, ?_⟩
  have hw0 := hrel.ffi.1
  have hz : t1.ffi.mlx.tokens = s0.ffi.mlx.tokens.map ((M1.setNum S1.tab.length v).after σ).nv ++ r := by
    rw [htk, htok]
    simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, Map.nv]
    show v :: r = (M1.setNum S1.tab.length v).nv (σ.num 79) :: r
    rw [hσ]
    simp [Map.nv, Map.setNum_self]
  have hffi := LoadRw.rebig hw0 hbig (fun t ht => by rw [htok] at ht; simp at ht; subst ht; exact h79) hz
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

end Host.Ts.Sim
