import host.sim.steps.Builtins
namespace Host.Ts.Sim
open Host.Ts

/-! # `Map.prototype.set`, `has` and `get` by string key

Memo code (`const b = cache.get(k); if (!b) { b = …; cache.set(k, b); }`) reads and writes a `Map`
by string key. With a string key `k` (code `c = pack k`) the interpreter's `findEntry` is the
first entry at `c` (`findEntry_string`), so

* `set` replaces the first entry at `c` or appends one: `upsert c (k, v)` (`setEntries_eq`);
* `has` is whether an entry at `c` exists (`firstCode_isSome`);
* `get` is the first value at `c` (`mapEntryValue_str`).

On each kind of `Map` the relation allows, the two sides agree:

* an unframed `Map` (the target's entries are the images): every string-key `set` and `has`
  (`step_map_set`, `step_map_has`);
* a `Map` by key (`mapKeys gs`: the source's string-key entries have their images, any value at
  the ghost codes `gs`, the target may hold more): every string-key `set`, and `has` of a key the
  source holds (`get` of one is `step_map_get_keys`);
* a `Map` memo (`memo gs`: a `Map` by key whose target holds no other string key outside `gs`):
  every string-key `set`, and `has` and `get` of every key that is no ghost, held or not
  (`step_map_get_memo`).

On an unframed `Map`, `set` with any key every entry key compares with alike (`SvzOK`, as for
`get`) finds the same entry on both sides (`step_map_set_svz`).

`set` keeps each relation (`MapW.upsert`, `MapNone.upsert`). -/

/-! ## Entry lists -/

/-- The entries after `set` of a string key at code `c`: the first entry at `c` replaced by `x`,
or `x` appended. -/
def upsert (c : Nat) (x : Val × Val) : List (Val × Val) → List (Val × Val)
  | [] => [x]
  | (.str a, w) :: es => bif Nat.beq (pack a) c then x :: es else (.str a, w) :: upsert c x es
  | p :: es => p :: upsert c x es

/-- `set`'s entry update is `upsert`. -/
theorem setEntries_eq (d x : Val × Val) (c : Nat) : ∀ es : List (Val × Val),
    (match StringIndex.firstCode c es 0 with
      | some i => setNth d es i x
      | none => es ++ [x]) = upsert c x es
  | [] => rfl
  | (k, w) :: es => by
    have ih := setEntries_eq d x c es
    cases k with
    | str a =>
      simp only [StringIndex.firstCode, upsert]
      cases hb : Nat.beq (pack a) c
      · simp only [Bool.cond_false]
        rw [StringIndex.firstCode_succ, ← ih]
        cases StringIndex.firstCode c es 0 <;> rfl
      · rfl
    | _ =>
      simp only [StringIndex.firstCode, upsert]
      rw [StringIndex.firstCode_succ, ← ih]
      cases StringIndex.firstCode c es 0 <;> rfl

theorem upsert_mem {c : Nat} {x : Val × Val} : ∀ {es : List (Val × Val)} {p : Val × Val},
    p ∈ upsert c x es → p = x ∨ p ∈ es
  | [], p, hp => by simp [upsert] at hp; exact .inl hp
  | (k, w) :: es, p, hp => by
    cases k with
    | str a =>
      simp only [upsert] at hp
      cases hb : Nat.beq (pack a) c
      · rw [hb] at hp
        simp only [Bool.cond_false, List.mem_cons] at hp
        rcases hp with rfl | hp
        · exact .inr (List.mem_cons_self ..)
        · rcases upsert_mem hp with h | h
          · exact .inl h
          · exact .inr (List.mem_cons_of_mem _ h)
      · rw [hb] at hp
        simp only [Bool.cond_true, List.mem_cons] at hp
        rcases hp with rfl | hp
        · exact .inl rfl
        · exact .inr (List.mem_cons_of_mem _ hp)
    | _ =>
      simp only [upsert, List.mem_cons] at hp
      rcases hp with rfl | hp
      · exact .inr (List.mem_cons_self ..)
      · rcases upsert_mem hp with h | h
        · exact .inl h
        · exact .inr (List.mem_cons_of_mem _ h)

theorem beq_false_of_ne {x y : Nat} (h : x ≠ y) : Nat.beq x y = false :=
  Bool.eq_false_iff.2 fun he => h (Nat.eq_of_beq_eq_true he)

/-- After `set` of `k` the first value at `k`'s code is the new one, elsewhere unchanged. -/
theorem firstValue_upsert {cs : List Char} {v : Val} (c' : Nat) : ∀ es : List (Val × Val),
    StringIndex.firstValue c' (upsert (pack cs) (.str cs, v) es) =
      if c' = pack cs then some v else StringIndex.firstValue c' es
  | [] => by
    by_cases h : c' = pack cs
    · subst h; simp [upsert, StringIndex.firstValue]
    · have : Nat.beq (pack cs) c' = false := beq_false_of_ne (Ne.symm h)
      simp [upsert, StringIndex.firstValue, this, h]
  | (k, w) :: es => by
    have ih := firstValue_upsert (cs := cs) (v := v) c' es
    cases k with
    | str a =>
      simp only [upsert]
      cases hb : Nat.beq (pack a) (pack cs)
      · simp only [Bool.cond_false, StringIndex.firstValue]
        rw [ih]
        have hne : pack a ≠ pack cs := Nat.ne_of_beq_eq_false hb
        by_cases h : c' = pack cs
        · subst h
          have : Nat.beq (pack a) (pack cs) = false := hb
          simp [this]
        · simp only [h, ite_false]
      · simp only [Bool.cond_true, StringIndex.firstValue]
        have he : pack a = pack cs := Nat.eq_of_beq_eq_true hb
        by_cases h : c' = pack cs
        · subst h; simp
        · have h1 : Nat.beq (pack cs) c' = false := beq_false_of_ne (Ne.symm h)
          have h2 : Nat.beq (pack a) c' = false := by rw [he]; exact h1
          simp [h1, h2, h]
    | _ =>
      simp only [upsert, StringIndex.firstValue]
      exact ih

/-- Images commute with `upsert` (string keys map to themselves, other keys to non-strings). -/
theorem pairs_upsert (M : Map) (c : Nat) (k v : Val) : ∀ es : List (Val × Val),
    M.pairs (upsert c (k, v) es) = upsert c (M.val k, M.val v) (M.pairs es)
  | [] => rfl
  | (k0, w) :: es => by
    have ih := pairs_upsert M c k v es
    cases k0 with
    | str a =>
      show M.pairs (bif Nat.beq (pack a) c then (k, v) :: es else (.str a, w) :: upsert c (k, v) es) =
        bif Nat.beq (pack a) c then (M.val k, M.val v) :: M.pairs es
          else (.str a, M.val w) :: upsert c (M.val k, M.val v) (M.pairs es)
      cases Nat.beq (pack a) c
      · show (.str a, M.val w) :: M.pairs (upsert c (k, v) es) = _
        rw [ih]; rfl
      · rfl
    | _ => show _ :: M.pairs (upsert c (k, v) es) = _; rw [ih]; rfl

theorem firstCode_pairs (M : Map) (c : Nat) : ∀ (es : List (Val × Val)) (i : Nat),
    StringIndex.firstCode c (M.pairs es) i = StringIndex.firstCode c es i
  | [], _ => rfl
  | (k, w) :: es, i => by
    have ih := firstCode_pairs M c es
    cases k with
    | str a =>
      show (bif Nat.beq (pack a) c then some i else StringIndex.firstCode c (M.pairs es) (i + 1)) = _
      rw [ih]; rfl
    | _ => show StringIndex.firstCode c (M.pairs es) (i + 1) = _; rw [ih]; rfl

/-- `has` is whether a first value exists. -/
theorem firstCode_isSome (c : Nat) : ∀ (es : List (Val × Val)) (i : Nat),
    (StringIndex.firstCode c es i).isSome = (StringIndex.firstValue c es).isSome
  | [], _ => rfl
  | (k, w) :: es, i => by
    have ih := firstCode_isSome c es
    cases k with
    | str a =>
      simp only [StringIndex.firstCode, StringIndex.firstValue]
      cases Nat.beq (pack a) c
      · simp only [Bool.cond_false]; exact ih (i + 1)
      · rfl
    | _ => simp only [StringIndex.firstCode, StringIndex.firstValue]; exact ih (i + 1)

/-- `set` keeps a `Map` by key. -/
theorem MapW.upsert {M : Map} {gs : List Nat} {es es' : List (Val × Val)} (h : MapW M gs es es')
    (cs : List Char) (v : Val) :
    MapW M gs (upsert (pack cs) (.str cs, v) es) (upsert (pack cs) (.str cs, M.val v) es') := by
  intro c w hw
  rw [firstValue_upsert] at hw ⊢
  by_cases hc : c = pack cs
  · simp only [hc, ite_true, Option.some.injEq] at hw ⊢
    exact ⟨_, rfl, .inr (by rw [hw])⟩
  · simp only [hc, ite_false] at hw ⊢
    exact h c w hw

/-- `set` keeps the absence of other keys. -/
theorem MapNone.upsert {gs : List Nat} {es es' : List (Val × Val)} (h : MapNone gs es es') (cs : List Char)
    (v v' : Val) : MapNone gs (upsert (pack cs) (.str cs, v) es) (upsert (pack cs) (.str cs, v') es') := by
  intro c hg hn
  rw [firstValue_upsert] at hn ⊢
  by_cases hc : c = pack cs
  · simp [hc] at hn
  · simp only [hc, ite_false] at hn ⊢
    exact h c hg hn

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
  {fa : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}

/-- `m.set(k, v)` with a string key: the entries are `upsert`. -/
theorem mapN_set_str (s : St F.S) (a : Nat) (mo : Obj) (es : List (Val × Val)) (cs : List Char) (v : Val)
    (args : List Val) (harg : arg args 0 = .str cs) (harg1 : arg args 1 = v)
    (hm : mapOf F s (.obj a) = some (a, mo, es)) :
    mapN F s (.obj a) args .set =
      retS F (s.setObj a { mo with kind := .map (upsert (pack cs) (.str cs, v) es) }) (.obj a) := by
  simp only [mapN, mapN.withMap, hm, harg, findEntry_string, M_bind_pure]
  rw [← harg1, ← setEntries_eq (.undef, .undef) (.str cs, arg args 1) (pack cs) es]
  cases StringIndex.firstCode (pack cs) es 0 <;> rfl

theorem mapN_has_str (s : St F.S) (a : Nat) (mo : Obj) (es : List (Val × Val)) (cs : List Char)
    (args : List Val) (harg : arg args 0 = .str cs) (hm : mapOf F s (.obj a) = some (a, mo, es)) :
    mapN F s (.obj a) args .has =
      retS F s (.bool (StringIndex.firstValue (pack cs) es).isSome) := by
  simp only [mapN, mapN.withMap, hm, harg, findEntry_string, M_bind_pure, firstCode_isSome]

/-- The target's object of a source `Map` under a `Map` frame (by key or memo). -/
theorem RelB.mapFrame (h : RelB F FR W stk M ν K s S t C) {a : Nat} {mo : Obj} {es : List (Val × Val)}
    {gs : List Nat} (hmo : s.obj? a = some mo) (hmk : mo.kind = .map es) (hfr : K.fr a ≠ none)
    (hw : W a = some (.mapKeys gs) ∨ W a = some (.memo gs)) :
    ∃ es', t.obj? (M.a a) = some { M.obj mo with kind := .map es' } ∧ MapW M gs es es' ∧
      (W a = some (.memo gs) → MapNone gs es es') := by
  obtain ⟨p, hp⟩ := Option.ne_none_iff_exists'.1 hfr
  rcases hw with hw | hw
  · have hs := (SlotW.of_wide hp hw).1 (h.heap a _ (obj?_iff.1 hmo))
    rcases hy : t.heap.get (M.a a) with _ | ⟨_ | mo'⟩ <;> rw [hy] at hs
    · exact hs.elim
    · exact hs.elim
    obtain ⟨es0, es', hk0, rfl, hmw⟩ := hs
    rw [hmk] at hk0; cases hk0
    exact ⟨es', obj?_iff.2 hy, hmw, fun hw' => by rw [hw] at hw'; cases hw'⟩
  · have hs := (SlotW.of_wide hp hw).1 (h.heap a _ (obj?_iff.1 hmo))
    rcases hy : t.heap.get (M.a a) with _ | ⟨_ | mo'⟩ <;> rw [hy] at hs
    · exact hs.elim
    · exact hs.elim
    obtain ⟨es0, es', hk0, rfl, hmw, hnone⟩ := hs
    rw [hmk] at hk0; cases hk0
    exact ⟨es', obj?_iff.2 hy, hmw, fun _ => hnone⟩

/-- **`m.set(k, v)`** with a string key on an unframed `Map`, a `Map` by key or a memo: both sides
`upsert`; the relation is kept (images, `MapW.upsert`, `MapNone.upsert`). -/
theorem step_map_set (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.map .set) data)) (hn : s.next < Sim.bound)
    {a : Nat} {mo : Obj} {es : List (Val × Val)} {cs : List Char}
    (hthis : this = .obj a) (hmo : s.obj? a = some mo) (hmk : mo.kind = .map es) (harg : arg args 0 = .str cs)
    (hfr : K.fr a = none ∨ ∃ gs, K.fr a ≠ none ∧ (W a = some (.mapKeys gs) ∨ W a = some (.memo gs))) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  have hms : mapOf F s (.obj a) = some (a, mo, es) := by simp only [mapOf, hmo, hmk]
  have hva : arg (M.vals args) 0 = .str cs := by rw [bi_arg_map, harg]; rfl
  have hva1 : arg (M.vals args) 1 = M.val (arg args 1) := bi_arg_map M args 1
  have ha : Present s a := Present.of_get (obj?_iff.1 hmo)
  have ha64 : a < 2 ^ 64 := by
    have := h.presentBound a ha; have hb : Sim.bound = 2 ^ 61 := rfl; omega
  have hsupp := h.obj?_supp hmo
  have hv : Supp.val (Present s) S.tab.length (arg args 1) := bi_arg_supp 1 hargs
  let o1 : Obj := { mo with kind := .map (upsert (pack cs) (.str cs, arg args 1) es) }
  have hso : Supp.obj (Present s) S.tab.length o1 := by
    refine ⟨fun p hp => ?_, hsupp.2.1, hsupp.2.2.1, hsupp.2.2.2⟩
    rcases upsert_mem hp with rfl | hp
    · exact ⟨trivial, hv⟩
    · have := hsupp.1; rw [hmk] at this; exact this p hp
  have hP : Present (s.setObj a o1) a := Present.set _ ha64 ha
  show MSim _ S C (callNative F s (.map .set) data (.obj a) args)
    (callNative F t (.map .set) (M.vals data) (.obj (M.a a)) (M.vals args))
  simp only [callNative]
  rw [mapN_set_str s a mo es cs (arg args 1) args harg rfl hms]
  rcases hfr with hfr0 | ⟨gs, hfr, hw⟩
  · have hmo' := h.obj? hmo hfr0
    have hmt : mapOf F t (.obj (M.a a)) = some (M.a a, M.obj mo, M.pairs es) := by
      simp only [mapOf, hmo', Map.obj, Map.kind, hmk]
    rw [mapN_set_str t (M.a a) (M.obj mo) (M.pairs es) cs (M.val (arg args 1)) (M.vals args) hva hva1 hmt]
    have e : upsert (pack cs) (.str cs, M.val (arg args 1)) (M.pairs es) =
        M.pairs (upsert (pack cs) (.str cs, arg args 1) es) := (pairs_upsert M (pack cs) (.str cs) (arg args 1) es).symm
    rw [e]
    exact bi_ret (h.setObj o1 hn ha hfr0 hso) (.obj a) hP
  · obtain ⟨es', hmo', hmw, hnone⟩ := h.mapFrame hmo hmk hfr hw
    have hmt : mapOf F t (.obj (M.a a)) = some (M.a a, { M.obj mo with kind := .map es' }, es') := by
      simp only [mapOf, hmo']
    rw [mapN_set_str t (M.a a) _ es' cs (M.val (arg args 1)) (M.vals args) hva hva1 hmt]
    obtain ⟨p, hp⟩ := Option.ne_none_iff_exists'.1 hfr
    let o1' : Obj := { M.obj o1 with kind := .map (upsert (pack cs) (.str cs, M.val (arg args 1)) es') }
    have hwide : ∀ w, W a = some w → (w = .mapKeys gs ∨ w = .memo gs) → WideOK M w (.obj o1) (some (.obj o1')) := by
      rintro w hwa (rfl | rfl)
      · exact ⟨_, _, rfl, rfl, hmw.upsert cs (arg args 1)⟩
      · exact ⟨_, _, rfl, rfl, hmw.upsert cs (arg args 1), (hnone hwa).upsert cs _ _⟩
    have hslot : SlotW M K.fr W a (.obj o1) (some (.obj o1')) := by
      rcases hw with hw | hw
      · exact (SlotW.of_wide hp hw).2 (hwide _ hw (.inl rfl))
      · exact (SlotW.of_wide hp hw).2 (hwide _ hw (.inr rfl))
    have r1 := h.write (.obj o1) (.obj o1') hn ha hslot hso
    exact bi_ret r1 (.obj a) hP

theorem mem_setNth {α : Type} {d a x : α} : ∀ {l : List α} {i : Nat}, x ∈ setNth d l i a → x = d ∨ x = a ∨ x ∈ l
  | [], 0, h => by simp only [setNth, List.mem_singleton] at h; exact .inr (.inl h)
  | [], i + 1, h => by
    simp only [setNth, List.mem_cons] at h
    rcases h with h | h
    · exact .inl h
    · rcases mem_setNth h with h | h | h
      · exact .inl h
      · exact .inr (.inl h)
      · exact nomatch h
  | _ :: _, 0, h => by
    simp only [setNth, List.mem_cons] at h
    rcases h with h | h
    · exact .inr (.inl h)
    · exact .inr (.inr (List.mem_cons_of_mem _ h))
  | b :: l, i + 1, h => by
    simp only [setNth, List.mem_cons] at h
    rcases h with h | h
    · subst h; exact .inr (.inr (List.mem_cons_self ..))
    · rcases mem_setNth h with h | h | h
      · exact .inl h
      · exact .inr (.inl h)
      · exact .inr (.inr (List.mem_cons_of_mem _ h))

/-- **`m.set(k, v)`** on an unframed `Map` whose entry keys compare with `k` alike: both sides find the
same entry (`bi_findEntry`) and replace it or append. -/
theorem step_map_set_svz (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.map .set) data)) (hn : s.next < Sim.bound)
    {a : Nat} {mo : Obj} {es : List (Val × Val)}
    (hthis : this = .obj a) (hmo : s.obj? a = some mo) (hmk : mo.kind = .map es) (hfr0 : K.fr a = none)
    (hok : ∀ p ∈ es, SvzOK K p.1 (arg args 0)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  have hms : mapOf F s (.obj a) = some (a, mo, es) := by simp only [mapOf, hmo, hmk]
  have hmo' := h.obj? hmo hfr0
  have hmt : mapOf F t (.obj (M.a a)) = some (M.a a, M.obj mo, M.pairs es) := by
    simp only [mapOf, hmo', Map.obj, Map.kind, hmk]
  have ha : Present s a := Present.of_get (obj?_iff.1 hmo)
  have ha64 : a < 2 ^ 64 := by
    have := h.presentBound a ha; have hb : Sim.bound = 2 ^ 61 := rfl; omega
  have hsupp := h.obj?_supp hmo
  have hes : Supp.pairs (Present s) S.tab.length es := by have := hsupp.1; rw [hmk] at this; exact this
  have hk0 := bi_arg_supp 0 hargs
  have hv := bi_arg_supp 1 hargs
  have hP : ∀ o1 : Obj, Present (s.setObj a o1) a := fun _ => Present.set _ ha64 ha
  show MSim _ S C (callNative F s (.map .set) data (.obj a) args)
    (callNative F t (.map .set) (M.vals data) (.obj (M.a a)) (M.vals args))
  simp only [callNative, mapN, mapN.withMap, hms, hmt, bi_arg_map]
  refine bi_bind (bi_findEntry hFR es 0 h hk0 hes hok) (fun _ _ _ _ _ hp => hp.2) ?_
  rintro M' S' C' r r' ⟨hr, g⟩
  rw [hr]
  have h' := h.grow hFR g
  have ea : M'.a a = M.a a := by rw [g.ext.a]
  have eo : M'.obj mo = M.obj mo := (Map.obj_agree g.ext.agree hsupp).symm
  have ees : M'.pairs es = M.pairs es := (Map.pairs_agree g.ext.agree hes).symm
  have ek : M'.val (arg args 0) = M.val (arg args 0) := g.bi_val hk0
  have ev : M'.val (arg args 1) = M.val (arg args 1) := g.bi_val hv
  rw [← ea, ← eo, ← ees, ← ek, ← ev]
  have hkv : ∀ p, p = (arg args 0, arg args 1) → Supp.val (Present s) S'.tab.length p.1 ∧
      Supp.val (Present s) S'.tab.length p.2 := by
    rintro p rfl; exact ⟨bi_supp_grow g hk0, bi_supp_grow g hv⟩
  have hes' : Supp.pairs (Present s) S'.tab.length es := Supp.pairs_mono (fun _ h => h) g.len hes
  cases r with
  | some i =>
    let o1 : Obj := { mo with kind := .map (setNth (.undef, .undef) es i (arg args 0, arg args 1)) }
    have hso : Supp.obj (Present s) S'.tab.length o1 := by
      have hs' := Supp.obj_mono (fun _ h => h) g.len hsupp
      refine ⟨fun p hp => ?_, hs'.2.1, hs'.2.2.1, hs'.2.2.2⟩
      rcases mem_setNth hp with rfl | rfl | hp
      · exact ⟨trivial, trivial⟩
      · exact hkv _ rfl
      · exact hes' p hp
    have e : setNth (Val.undef, Val.undef) (M'.pairs es) i (M'.val (arg args 0), M'.val (arg args 1)) =
        M'.pairs (setNth (.undef, .undef) es i (arg args 0, arg args 1)) :=
      (setNth_map (fun (x, y) => (M'.val x, M'.val y)) (Val.undef, Val.undef) es i (arg args 0, arg args 1)).symm
    dsimp only
    rw [e]
    exact bi_ret (h'.setObj o1 hn ha hfr0 hso) (.obj a) (hP o1)
  | none =>
    let o1 : Obj := { mo with kind := .map (es ++ [(arg args 0, arg args 1)]) }
    have hso : Supp.obj (Present s) S'.tab.length o1 := by
      have hs' := Supp.obj_mono (fun _ h => h) g.len hsupp
      refine ⟨fun p hp => ?_, hs'.2.1, hs'.2.2.1, hs'.2.2.2⟩
      rcases List.mem_append.1 hp with hp | hp
      · exact hes' p hp
      · exact hkv _ (List.mem_singleton.1 hp)
    have e : M'.pairs es ++ [(M'.val (arg args 0), M'.val (arg args 1))] =
        M'.pairs (es ++ [(arg args 0, arg args 1)]) := by
      simp only [Map.pairs, List.map_append, List.map_cons, List.map_nil]
    dsimp only
    rw [e]
    exact bi_ret (h'.setObj o1 hn ha hfr0 hso) (.obj a) (hP o1)

/-- **`m.has(k)`** with a string key: on an unframed `Map`; on a `Map` by key when the source holds
`k`; on a memo when `k` is no ghost. -/
theorem step_map_has (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.map .has) data))
    {a : Nat} {mo : Obj} {es : List (Val × Val)} {cs : List Char}
    (hthis : this = .obj a) (hmo : s.obj? a = some mo) (hmk : mo.kind = .map es) (harg : arg args 0 = .str cs)
    (hfr : K.fr a = none ∨ ∃ gs, K.fr a ≠ none ∧
      ((W a = some (.mapKeys gs) ∧ (StringIndex.firstValue (pack cs) es).isSome = true) ∨
        (W a = some (.memo gs) ∧ pack cs ∉ gs))) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  have hms : mapOf F s (.obj a) = some (a, mo, es) := by simp only [mapOf, hmo, hmk]
  have hva : arg (M.vals args) 0 = .str cs := by rw [bi_arg_map, harg]; rfl
  show MSim _ S C (callNative F s (.map .has) data (.obj a) args)
    (callNative F t (.map .has) (M.vals data) (.obj (M.a a)) (M.vals args))
  simp only [callNative]
  rw [mapN_has_str s a mo es cs args harg hms]
  rcases hfr with hfr0 | ⟨gs, hfr, hw⟩
  · have hmo' := h.obj? hmo hfr0
    have hmt : mapOf F t (.obj (M.a a)) = some (M.a a, M.obj mo, M.pairs es) := by
      simp only [mapOf, hmo', Map.obj, Map.kind, hmk]
    rw [mapN_has_str t (M.a a) (M.obj mo) (M.pairs es) cs (M.vals args) hva hmt, ← firstCode_isSome _ _ 0,
      ← firstCode_isSome _ _ 0, firstCode_pairs]
    exact bi_ret h (.bool _) trivial
  · obtain ⟨es', hmo', hmw, hnone⟩ := h.mapFrame hmo hmk hfr (hw.imp And.left And.left)
    have hmt : mapOf F t (.obj (M.a a)) = some (M.a a, { M.obj mo with kind := .map es' }, es') := by
      simp only [mapOf, hmo']
    rw [mapN_has_str t (M.a a) _ es' cs (M.vals args) hva hmt]
    have hb : (StringIndex.firstValue (pack cs) es').isSome = (StringIndex.firstValue (pack cs) es).isSome := by
      rcases hw with ⟨-, hs⟩ | ⟨hwm, hg⟩
      · obtain ⟨v, hv⟩ := Option.isSome_iff_exists.1 hs
        obtain ⟨v', hv', -⟩ := hmw _ v hv
        rw [hv, hv']; rfl
      · cases hv : StringIndex.firstValue (pack cs) es with
        | none => rw [hnone hwm _ hg hv]
        | some v =>
          obtain ⟨v', hv', -⟩ := hmw _ v hv
          rw [hv']; rfl
    rw [hb]
    exact bi_ret h (.bool _) trivial

/-- **`m.get(k)`** on a memo with a string key that is no ghost, held or not: the image of the
source's value, or `undefined` on both sides. -/
theorem step_map_get_memo (h : RelB F FR W stk M ν K s S t C)
    (hc : s.ctl = .call (.obj fa) this args) (ho : s.obj? fa = some o)
    (hk : o.kind = .fn (.native (.map .get) data))
    {a : Nat} {mo : Obj} {es : List (Val × Val)} {gs : List Nat} {cs : List Char}
    (hthis : this = .obj a) (hmo : s.obj? a = some mo) (hmk : mo.kind = .map es) (hfr : K.fr a ≠ none)
    (hw : W a = some (.memo gs)) (harg : arg args 0 = .str cs) (hng : pack cs ∉ gs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs⟩ := h.bi_native hc ho hk
  rw [e1, e2]
  subst hthis
  obtain ⟨es', hmo', hmw, hnone⟩ := h.mapFrame hmo hmk hfr (.inr hw)
  have hes : Supp.pairs (Present s) S.tab.length es := by
    have := (h.obj?_supp hmo).1; rw [hmk] at this; exact this
  have hms : mapOf F s (.obj a) = some (a, mo, es) := by simp only [mapOf, hmo, hmk]
  have hmt : mapOf F t (.obj (M.a a)) = some (M.a a, { M.obj mo with kind := .map es' }, es') := by
    simp only [mapOf, hmo']
  have hva : arg (M.vals args) 0 = .str cs := by rw [bi_arg_map, harg]; rfl
  show MSim _ S C (callNative F s (.map .get) data (.obj a) args)
    (callNative F t (.map .get) (M.vals data) (.obj (M.a a)) (M.vals args))
  simp only [callNative, mapN, mapN.withMap, hms, hmt, hva, harg, mapEntryValue_str, M_bind_pure]
  cases hv : StringIndex.firstValue (pack cs) es with
  | none =>
    rw [hnone hw _ hng hv]
    exact bi_ret h .undef trivial
  | some v =>
    obtain ⟨v', hv', hor⟩ := hmw _ v hv
    rw [hv', hor.resolve_left hng]
    obtain ⟨k0, hk0⟩ := firstValue_mem hv
    exact bi_ret h v (hes _ hk0).2

end

end Host.Ts.Sim
