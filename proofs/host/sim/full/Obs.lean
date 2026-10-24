import host.sim.full.Rel
import host.sim.full.Keep
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep)
open Host.Mlx.Ffi (Cfg)

/-! # The observers under the relation

One call of the template and of the target, with the general relation before and after under maps
with the same names (`ObsPost`), keeps the observer relations: the liveness layer's verdicts on an
object free, an array free and every other call (`live_step`), and the kernel-recording layer's on a
configuration's creation and template arguments and a launch (`kern_step`). The observers are pure
functions of the state before, the arguments and the return; the target's arguments are the images
of the template's and its return the image of the template's. -/

/-- What an observer step knows of a call from `x` to `x'` (template) and `y` to `y'` (target). -/
structure ObsPost (P : LoadP) (NB : Nat) (M M' : Map) (n n' : Nat) (x y x' y' : NSt) : Prop where
  pre : G.MR P NB M n x y
  post : G.MR P NB M' n' x' y'
  ext : Ext M M' n
  len : n ≤ n'
  kx : Keep x x'
  ky : Keep y y'

section
variable {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {x y x' y' : NSt}

theorem ObsPost.handle (h : ObsPost P NB M M' n n' x y x' y') (k : Nat) : M'.handle k = M.handle k := by
  simp [Map.handle, h.ext.big]

/-- An object of `x'` that `x` does not have is fresh: its image is at or above `y`'s counter. -/
theorem ObsPost.fresh (h : ObsPost P NB M M' n n' x y x' y') {k : Nat} (hk : (x'.objs.get k).isSome = true)
    (hn : (x.objs.get k).isSome = false) : y.next ≤ M.handle k := by
  have h1 : x.next ≤ k := by
    rcases h.kx.fresh k hk with e | e
    · rw [hn] at e; cases e
    · exact e
  have h2 : k < x'.next := h.post.hlt k (.inr hk)
  have h3 : x'.next ≤ P.E := h.post.hroom.1
  have e := h.pre.hfreshB (k - x.next) (by omega)
  rw [show x.next + (k - x.next) = k by omega] at e
  show y.next ≤ (M.big (Int.ofNat k)).toNat
  rw [e, show (Int.ofNat (y.next + (k - x.next))).toNat = y.next + (k - x.next) from rfl]
  omega

theorem ObsPost.objLt (h : ObsPost P NB M M' n n' x y x' y') {k : Nat} (hk : (x.objs.get k).isSome = true) :
    k < 2 ^ 64 ∧ M.handle k < 2 ^ 64 := by
  have hp : PH x k := .inr hk
  have := h.pre.hlt k hp
  have := h.pre.himg k hp
  have := h.pre.hnext
  have := h.pre.hroom
  omega

theorem ObsPost.objLt' (h : ObsPost P NB M M' n n' x y x' y') {k : Nat} (hk : (x'.objs.get k).isSome = true) :
    M.handle k < y'.next ∧ y'.next < 2 ^ 64 := by
  have hp : PH x' k := .inr hk
  have h1 := h.post.himg k hp
  rw [h.handle] at h1
  have := h.post.hroom
  omega

theorem ObsPost.handle_inj (h : ObsPost P NB M M' n n' x y x' y') {j k : Nat} (hj : (x'.objs.get j).isSome = true)
    (hk : (x'.objs.get k).isSome = true) (hjk : j ≠ k) : M.handle j ≠ M.handle k := fun e =>
  hjk (h.post.hinj j k (.inr hj) (.inr hk) (by rw [h.handle, h.handle]; exact e))

/-! ## Liveness -/

theorem none_of_obj {fx : PTrie Unit} {k : Nat} (hobj : ∀ h, fx.get h = some () → (x.objs.get h).isSome = true)
    (hn : (x.objs.get k).isSome = false) : fx.get k = none := by
  cases e : fx.get k with
  | none => rfl
  | some u => cases u; rw [hobj k e] at hn; cases hn

/-- **A call that frees nothing.** -/
theorem FreedR.keep {fx fy : PTrie Unit} (hf : FreedR M x y fx fy) (h : ObsPost P NB M M' n n' x y x' y') :
    FreedR M' x' y' fx fy where
  obj k hk := h.kx.objs k (hf.obj k hk)
  img k hk := by
    rw [h.handle]
    cases hx : (x.objs.get k).isSome
    · have hge := h.fresh hk hx
      have e2 : fy.get (M.handle k) = none := by
        cases e : fy.get (M.handle k) with
        | none => rfl
        | some u => cases u; have := hf.lt _ e; omega
      rw [none_of_obj hf.obj hx, e2]
    · exact hf.img k hx
  lt k hk := Nat.lt_of_lt_of_le (hf.lt k hk) h.ky.next

/-- **An object free.** -/
theorem FreedR.free {fx fy : PTrie Unit} (hf : FreedR M x y fx fy) (h : ObsPost P NB M M' n n' x y x' y') {k : Nat}
    (hk : (x.objs.get k).isSome = true) : FreedR M' x' y' (fx.set k ()) (fy.set (M.handle k) ()) where
  obj j hj := by
    rcases PTrie.get_set_some hj with e | ⟨rfl, -⟩
    · exact h.kx.objs j (hf.obj j e)
    · exact h.kx.objs j hk
  img j hj := by
    have hb := h.objLt hk
    by_cases hjk : j = k
    · subst hjk
      rw [h.handle, PTrie.get_set_u64 _ _ _ hb.2, PTrie.get_set_u64 _ _ _ hb.1]
      simp
    · rw [h.handle, PTrie.get_set_ne' _ _ _ _ (h.handle_inj hj (h.kx.objs k hk) hjk), PTrie.get_set_ne' _ _ _ _ hjk]
      have := (hf.keep h).img j hj
      rwa [h.handle] at this
  lt j hj := by
    rcases PTrie.get_set_some hj with e | ⟨rfl, -⟩
    · exact Nat.lt_of_lt_of_le (hf.lt j e) h.ky.next
    · have := h.pre.himg k (.inr hk)
      exact Nat.lt_of_lt_of_le this.2 h.ky.next

end

/-! ### The liveness layer's verdicts -/

theorem liveCall_obj_some {freed : PTrie Unit} {m : Host.Mlx.Ffi.St} {name : Name} {a : Arg} {s : Host.Mlx.Ffi.Sym} {h : Nat} {o : Host.Mlx.Ffi.Obj}
    (hs : Host.Mlx.Ffi.symOf name = some s) (hx : isObjFree s = true) (ha : Host.Mlx.Ffi.argNat a = some h) (hz : h ≠ 0)
    (h1 : m.arrs.get h = none) (h2 : m.objs.get h = some o) (h3 : freed.get h = none) (h4 : freeKind s o = true) :
    liveCall freed m name [a] = some (freed.set h ()) := by
  obtain ⟨k, rfl⟩ : ∃ k, h = k + 1 := ⟨h - 1, by omega⟩
  unfold liveCall; rw [hs]
  simp only [liveFree, hx, Bool.cond_true, ha, h1, h2, h3, h4]

theorem liveCall_arr {freed f' : PTrie Unit} {m : Host.Mlx.Ffi.St} {name : Name} {a : Arg}
    (hs : Host.Mlx.Ffi.symOf name = some .arrayFree) (hl : liveCall freed m name [a] = some f') : f' = freed := by
  unfold liveCall at hl; rw [hs] at hl
  simp only [liveFree, isObjFree, isArrFree, Bool.cond_false, Bool.cond_true] at hl
  revert hl
  cases Host.Mlx.Ffi.argNat a with
  | none => intro hl; cases hl
  | some k =>
    cases k with
    | zero => intro hl; exact (Option.some.inj hl).symm
    | succ j =>
      intro hl
      simp only at hl
      cases e : (m.node? (j + 1)).isSome <;> simp only [e, Bool.cond_true, Bool.cond_false, reduceCtorEq, Option.some.injEq] at hl
      exact hl.symm

theorem liveCall_arr_some {freed : PTrie Unit} {m : Host.Mlx.Ffi.St} {name : Name} {a : Arg} {h : Nat}
    (hs : Host.Mlx.Ffi.symOf name = some .arrayFree) (ha : Host.Mlx.Ffi.argNat a = some h) (hn : (m.node? h).isSome = true) :
    liveCall freed m name [a] = some freed := by
  unfold liveCall; rw [hs]
  simp only [liveFree, isObjFree, isArrFree, Bool.cond_false, Bool.cond_true, ha]
  cases h with
  | zero => rfl
  | succ k => simp only [hn, Bool.cond_true]

theorem liveCall_other (freed : PTrie Unit) (m : Host.Mlx.Ffi.St) (name : Name) (args : List Arg)
    (h : ∀ s a, Host.Mlx.Ffi.symOf name = some s → args = [a] → isObjFree s = false ∧ isArrFree s = false) :
    liveCall freed m name args = some freed := by
  unfold liveCall
  cases hs : Host.Mlx.Ffi.symOf name with
  | none => rfl
  | some s =>
    match args, h with
    | [], _ => rfl
    | [a], h =>
      obtain ⟨h1, h2⟩ := h s a hs rfl
      simp only [liveFree, h1, h2, Bool.cond_false]
    | _ :: _ :: _, _ => rfl

/-! ### The liveness step -/

/-- The liveness layer's condition beyond the load world's acceptance: an object free names a
present handle (`hdOk`, as the load world's array free does). -/
def obsOk (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name, args with
  | some s, [a] => !isObjFree s || hdOk x a
  | _, _ => true

theorem freeKind_nobj (M : Map) (s : Host.Mlx.Ffi.Sym) (o : Host.Mlx.Ffi.Obj) :
    freeKind s (M.nobj o) = freeKind s o := by
  cases o <;> cases s <;> rfl

theorem obsOk_one {x : NSt} {name : Name} {s : Host.Mlx.Ffi.Sym} (a : Arg) (hs : Host.Mlx.Ffi.symOf name = some s) :
    obsOk x name [a] = (!isObjFree s || hdOk x a) := by
  unfold obsOk; rw [hs]

theorem eq_arrayFree {s : Host.Mlx.Ffi.Sym} (h : isArrFree s = true) : s = .arrayFree := by
  unfold isArrFree at h; split at h
  · rfl
  · cases h

theorem liveCall_arr_node {freed f' : PTrie Unit} {m : Host.Mlx.Ffi.St} {name : Name} {a : Arg} {k : Nat}
    (hs : Host.Mlx.Ffi.symOf name = some .arrayFree) (ha : Host.Mlx.Ffi.argNat a = some k) (hz : k ≠ 0)
    (hl : liveCall freed m name [a] = some f') : (m.node? k).isSome = true := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  unfold liveCall at hl; rw [hs] at hl
  simp only [liveFree, isObjFree, isArrFree, Bool.cond_false, Bool.cond_true, ha] at hl
  cases e : (m.node? (j + 1)).isSome
  · rw [e] at hl; cases hl
  · rfl

section
variable {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {x y x' y' : NSt}

/-- **The liveness layer's step.** -/
theorem live_step {ex ey : Option (PTrie Unit)} {name : Name} {args : List Arg}
    (hl : LiveR M x y ex ey) (h : ObsPost P NB M M' n n' x y x' y') (hobs : obsOk x name args = true)
    (harr : Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk x a = true) :
    LiveR M' x' y' (ex.bind fun e => liveCall e x name args) (ey.bind fun e => liveCall e y name (args.map M.arg)) := by
  intro fx' hx'
  cases hex : ex with
  | none => rw [hex] at hx'; cases hx'
  | some fx =>
    rw [hex, Option.bind_some] at hx'
    obtain ⟨fy, hey, hf⟩ := hl fx hex
    rw [hey, Option.bind_some]
    cases hs : Host.Mlx.Ffi.symOf name with
    | none =>
      rw [liveCall_other fx x name args (fun s a e _ => by rw [hs] at e; cases e)] at hx'
      cases hx'
      exact ⟨fy, liveCall_other fy y name _ (fun s a e _ => by rw [hs] at e; cases e), hf.keep h⟩
    | some s =>
      match args, hobs, harr, hx' with
      | [], _, _, hx' =>
        rw [liveCall_other fx x name [] (fun _ _ _ e => by cases e)] at hx'
        cases hx'
        exact ⟨fy, liveCall_other fy y name _ (fun _ _ _ e => by cases e), hf.keep h⟩
      | _ :: _ :: _, _, _, hx' =>
        rw [liveCall_other fx x name _ (fun _ _ _ e => by cases e)] at hx'
        cases hx'
        exact ⟨fy, liveCall_other fy y name _ (fun _ _ _ e => by cases e), hf.keep h⟩
      | [a], hobs, harr, hx' =>
        cases ho : isObjFree s
        · cases ha : isArrFree s
          · have hother : ∀ s' a', Host.Mlx.Ffi.symOf name = some s' → [a] = [a'] →
                isObjFree s' = false ∧ isArrFree s' = false := fun s' a' e _ => by
              rw [hs] at e; cases e; exact ⟨ho, ha⟩
            rw [liveCall_other fx x name [a] hother] at hx'
            cases hx'
            exact ⟨fy, liveCall_other fy y name _ fun s' a' e _ => by rw [hs] at e; cases e; exact ⟨ho, ha⟩,
              hf.keep h⟩
          · have hsa : s = .arrayFree := by cases s <;> first | rfl | cases ha
            subst hsa
            obtain ⟨k, rfl, hp, hm⟩ := h.pre.hdOk_spec (harr hs a rfl)
            have e := liveCall_arr hs hx'
            subst e
            have hnd := liveCall_arr_node hs (argNat_nat k) (h.pre.PH_ne_zero hp) hx'
            obtain ⟨nd, hnd'⟩ := Option.isSome_iff_exists.mp hnd
            obtain ⟨_, nd', -, -, hy, -⟩ := h.pre.node? hnd'
            refine ⟨fy, ?_, hf.keep h⟩
            simp only [List.map_cons, List.map_nil, hm]
            exact liveCall_arr_some hs (argNat_nat _) (by rw [hy]; rfl)
        · have hd : hdOk x a = true := by
            rw [obsOk_one a hs, ho] at hobs
            exact hobs
          obtain ⟨k, rfl, hp, hm⟩ := h.pre.hdOk_spec hd
          have hz := h.pre.PH_ne_zero hp
          obtain ⟨o, h1, h2, h3, h4, rfl⟩ := liveCall_obj hs ho (argNat_nat k) hz hx'
          have hko : (x.objs.get k).isSome = true := by rw [h2]; rfl
          refine ⟨_, ?_, hf.free h hko⟩
          simp only [List.map_cons, List.map_nil, hm]
          refine liveCall_obj_some hs ho (argNat_nat _) (h.pre.handle_pos hp) ?_ ?_ ?_ (o := M.nobj o) ?_
          · rw [h.pre.arrs k hp, h1]; rfl
          · rw [h.pre.objs k hp, h2]; rfl
          · rw [hf.img k hko, h3]
          · rw [freeKind_nobj]; exact h4

end

/-! ## Kernel recording -/

theorem isSome_set_inv' {α : Type} {t : PTrie α} {n : Nat} {v : α} {m : Nat} (h : ((t.set n v).get m).isSome = true) :
    (t.get m).isSome = true ∨ m = n :=
  Host.Mlx.Ffi.FullKeep.isSome_set_inv t n v m h

theorem all_targ (M : Map) (p : List Char × TArg → Bool) (hp : ∀ t, p (targ M t) = p t) :
    ∀ l : List (List Char × TArg), (l.map (targ M)).all p = l.all p
  | [] => rfl
  | t :: l => by simp only [List.map_cons, List.all_cons, hp t, all_targ M p hp l]

theorem ordered_targ (M : Map) : ∀ l : List (List Char × TArg), ordered (l.map (targ M)) = ordered l
  | [] => rfl
  | (nm, .dtype d) :: l => by
    show ordered (l.map (targ M)) = ordered l
    exact ordered_targ M l
  | (nm, .int v) :: l => by
    show ((nm, TArg.int (M.nv v)) :: l.map (targ M)).all _ = ((nm, TArg.int v) :: l).all _
    simp only [List.all_cons]
    rw [all_targ M _ (fun t => by obtain ⟨_, t⟩ := t; cases t <;> rfl) l]

theorem dtypesOf_targ (M : Map) : ∀ l : List (List Char × TArg), dtypesOf (l.map (targ M)) = dtypesOf l
  | [] => rfl
  | (nm, .dtype d) :: l => by
    show (nm, d) :: dtypesOf (l.map (targ M)) = (nm, d) :: dtypesOf l
    rw [dtypesOf_targ M l]
  | (nm, .int v) :: l => by
    show dtypesOf (l.map (targ M)) = dtypesOf l
    exact dtypesOf_targ M l

theorem intsOf_targ (M : Map) : ∀ l : List (List Char × TArg),
    intsOf (l.map (targ M)) = (intsOf l).map fun (n, v) => (n, M.nv v)
  | [] => rfl
  | (nm, .dtype d) :: l => by
    show intsOf (l.map (targ M)) = (intsOf l).map _
    exact intsOf_targ M l
  | (nm, .int v) :: l => by
    show (nm, M.nv v) :: intsOf (l.map (targ M)) = (nm, M.nv v) :: (intsOf l).map _
    rw [intsOf_targ M l]

theorem cfgOk_spec {x : NSt} {a : Arg} (h : cfgOk x a = true) :
    ∃ k c, a = .big (Int.ofNat k) ∧ x.obj? k = some (.cfg c) := by
  unfold cfgOk at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨h1, h2⟩ := h
  cases a with
  | big i =>
    simp only [hdOk, Bool.and_eq_true, decide_eq_true_eq] at h1
    refine ⟨i.toNat, ?_⟩
    have ei : i = Int.ofNat i.toNat := by rw [Int.ofNat_eq_natCast, Int.toNat_of_nonneg h1.1]
    rw [ei, argNat_nat, Option.bind_some] at h2
    split at h2
    · rename_i c hc; exact ⟨c, congrArg Arg.big ei, hc⟩
    · cases h2
  | _ => cases h1

theorem kernOk_spec {x : NSt} {a : Arg} (h : kernOk x a = true) :
    ∃ k nm sc hd u v, a = .big (Int.ofNat k) ∧ x.obj? k = some (.kernel nm sc hd u v) := by
  unfold kernOk at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨h1, h2⟩ := h
  cases a with
  | big i =>
    simp only [hdOk, Bool.and_eq_true, decide_eq_true_eq] at h1
    refine ⟨i.toNat, ?_⟩
    have ei : i = Int.ofNat i.toNat := by rw [Int.ofNat_eq_natCast, Int.toNat_of_nonneg h1.1]
    rw [ei, argNat_nat, Option.bind_some] at h2
    split at h2
    · rename_i nm sc hd u v hk; exact ⟨nm, sc, hd, u, v, congrArg Arg.big ei, hk⟩
    · cases h2
  | _ => cases h1

section
variable {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {x y x' y' : NSt}

/-- **A call recording nothing.** -/
theorem KRecR.keep {kx ky : KRec} (hk : KRecR M n x y kx ky) (h : ObsPost P NB M M' n n' x y x' y') :
    KRecR M' n' x' y' kx ky where
  flagsObj j hj := h.kx.objs j (hk.flagsObj j hj)
  targsObj j hj := h.kx.objs j (hk.targsObj j hj)
  flags j hj := by
    rw [h.handle]
    cases hx : (x.objs.get j).isSome
    · have hge := h.fresh hj hx
      have e1 : kx.flags.get j = none := by
        cases e : kx.flags.get j with
        | none => rfl
        | some _ => have := hk.flagsObj j (by rw [e]; rfl); rw [hx] at this; cases this
      have e2 : ky.flags.get (M.handle j) = none := by
        cases e : ky.flags.get (M.handle j) with
        | none => rfl
        | some _ => have := hk.flagsLt _ (by rw [e]; rfl); omega
      rw [e1, e2]
    · exact hk.flags j hx
  targs j hj := by
    rw [h.handle]
    cases hx : (x.objs.get j).isSome
    · have hge := h.fresh hj hx
      have e1 : kx.targs.get j = none := by
        cases e : kx.targs.get j with
        | none => rfl
        | some _ => have := hk.targsObj j (by rw [e]; rfl); rw [hx] at this; cases this
      have e2 : ky.targs.get (M.handle j) = none := by
        cases e : ky.targs.get (M.handle j) with
        | none => rfl
        | some _ => have := hk.targsLt _ (by rw [e]; rfl); omega
      rw [e1, e2]; rfl
    · rw [hk.targs j hx]
      cases e : kx.targs.get j with
      | none => rfl
      | some l => simp only [Option.map_some, targ_agree (NAgree.ofExt h.ext) (hk.cl j l e)]
  flagsLt j hj := Nat.lt_of_lt_of_le (hk.flagsLt j hj) h.ky.next
  targsLt j hj := Nat.lt_of_lt_of_le (hk.targsLt j hj) h.ky.next
  cl j l e := (hk.cl j l e).mono fun _ hi => Nat.lt_of_lt_of_le hi h.len

/-- **A configuration created** at the template's handle counter. -/
theorem KRecR.cfgNew {kx ky : KRec} (hk : KRecR M n x y kx ky) (h : ObsPost P NB M M' n n' x y x' y')
    (hobj : (x'.objs.get x.next).isSome = true) :
    KRecR M' n' x' y' { kx with targs := kx.targs.set x.next [] } { ky with targs := ky.targs.set (M.handle x.next) [] } := by
  have hkp := hk.keep h
  have hb : x.next < 2 ^ 64 := by have := h.pre.hnext; have := h.pre.hroom; omega
  have hb' := h.objLt' hobj
  exact
  { hkp with
    targsObj := fun j hj => by
      rcases isSome_set_inv' hj with e | e
      · exact hkp.targsObj j e
      · rw [e]; exact hobj
    targs := fun j hj => by
      by_cases hjk : j = x.next
      · subst hjk
        show (ky.targs.set (M.handle x.next) []).get (M'.handle x.next) =
          ((kx.targs.set x.next []).get x.next).map _
        rw [h.handle, PTrie.get_set_u64 _ _ _ (by omega), PTrie.get_set_u64 _ _ _ hb]
        simp
      · show (ky.targs.set (M.handle x.next) []).get (M'.handle j) = ((kx.targs.set x.next []).get j).map _
        rw [PTrie.get_set_ne' _ _ _ _ hjk, h.handle, PTrie.get_set_ne' _ _ _ _ (h.handle_inj hj hobj hjk)]
        have := hkp.targs j hj
        rwa [h.handle] at this
    targsLt := fun j hj => by
      rcases isSome_set_inv' hj with e | e
      · exact hkp.targsLt j e
      · rw [e]; exact hb'.1
    cl := fun j l e => by
      rcases PTrie.get_set_some e with e' | ⟨-, rfl⟩
      · exact hkp.cl j l e'
      · intro _ _ hv; cases hv }

/-- **A kernel created** at the template's handle counter, its flags recorded. -/
theorem KRecR.kernelNew {kx ky : KRec} (hk : KRecR M n x y kx ky) (h : ObsPost P NB M M' n n' x y x' y')
    (hobj : (x'.objs.get x.next).isSome = true) (fl : Bool × Bool) :
    KRecR M' n' x' y' { kx with flags := kx.flags.set x.next fl }
      { ky with flags := ky.flags.set (M.handle x.next) fl } := by
  have hkp := hk.keep h
  have hb : x.next < 2 ^ 64 := by have := h.pre.hnext; have := h.pre.hroom; omega
  have hb' := h.objLt' hobj
  exact
  { hkp with
    flagsObj := fun j hj => by
      rcases isSome_set_inv' hj with e | e
      · exact hkp.flagsObj j e
      · rw [e]; exact hobj
    flags := fun j hj => by
      by_cases hjk : j = x.next
      · subst hjk
        show (ky.flags.set (M.handle x.next) fl).get (M'.handle x.next) = (kx.flags.set x.next fl).get x.next
        rw [h.handle, PTrie.get_set_u64 _ _ _ (by omega), PTrie.get_set_u64 _ _ _ hb]
        simp
      · show (ky.flags.set (M.handle x.next) fl).get (M'.handle j) = (kx.flags.set x.next fl).get j
        rw [PTrie.get_set_ne' _ _ _ _ hjk, h.handle, PTrie.get_set_ne' _ _ _ _ (h.handle_inj hj hobj hjk)]
        have := hkp.flags j hj
        rwa [h.handle] at this
    flagsLt := fun j hj => by
      rcases isSome_set_inv' hj with e | e
      · exact hkp.flagsLt j e
      · rw [e]; exact hb'.1 }

/-- **A template argument appended** to a configuration's record. -/
theorem KRecR.upd {kx ky : KRec} (hk : KRecR M n x y kx ky) (h : ObsPost P NB M M' n n' x y x' y') {k : Nat}
    (hko : (x.objs.get k).isSome = true) {l : List (List Char × TArg)} (hl : kx.targs.get k = some l)
    (t : List Char × TArg) (ht : STargs (· < n) [t]) :
    KRecR M' n' x' y' { kx with targs := kx.targs.set k (l ++ [t]) }
      { ky with targs := ky.targs.set (M.handle k) (l.map (targ M) ++ [targ M t]) } := by
  have hkp := hk.keep h
  have hb := h.objLt hko
  have hko' := h.kx.objs k hko
  have hcl : STargs (· < n) (l ++ [t]) := fun nm v hv => by
    rcases List.mem_append.mp hv with hv | hv
    · exact hk.cl k l hl nm v hv
    · exact ht nm v hv
  exact
  { hkp with
    targsObj := fun j hj => by
      rcases isSome_set_inv' hj with e | e
      · exact hkp.targsObj j e
      · rw [e]; exact hko'
    targs := fun j hj => by
      by_cases hjk : j = k
      · subst hjk
        show (ky.targs.set (M.handle j) _).get (M'.handle j) = ((kx.targs.set j (l ++ [t])).get j).map _
        rw [h.handle, PTrie.get_set_u64 _ _ _ hb.2, PTrie.get_set_u64 _ _ _ hb.1]
        simp only [ite_true, Option.map_some, Option.some.injEq]
        rw [targ_agree (NAgree.ofExt h.ext) hcl, List.map_append]
        rfl
      · show (ky.targs.set (M.handle k) _).get (M'.handle j) = ((kx.targs.set k (l ++ [t])).get j).map _
        rw [PTrie.get_set_ne' _ _ _ _ hjk, h.handle, PTrie.get_set_ne' _ _ _ _ (h.handle_inj hj hko' hjk)]
        have := hkp.targs j hj
        rwa [h.handle] at this
    targsLt := fun j hj => by
      rcases isSome_set_inv' hj with e | e
      · exact hkp.targsLt j e
      · rw [e]
        have := h.pre.himg k (.inr hko)
        exact Nat.lt_of_lt_of_le this.2 h.ky.next
    cl := fun j l' e => by
      rcases PTrie.get_set_some e with e' | ⟨-, rfl⟩
      · exact hkp.cl j l' e'
      · exact hcl.mono fun _ hi => Nat.lt_of_lt_of_le hi h.len }

end

/-! ### The kernel-recording layer's verdicts -/

theorem kernCall_other (k : KRec) (m : Host.Mlx.Ffi.St) (name : Name) (args : List Arg) (r : Ret) {s : Host.Mlx.Ffi.Sym}
    (hs : Host.Mlx.Ffi.symOf name = some s) (h1 : s ≠ .kernelNew) (h2 : s ≠ .cfgNew) (h3 : s ≠ .cfgDtype)
    (h4 : s ≠ .cfgInt) (h5 : s ≠ .kernelApply) : kernCall k m name args r = some k := by
  unfold kernCall; rw [hs]
  split
  all_goals first | rfl | (exfalso; simp_all)

theorem kernCall_none (k : KRec) (m : Host.Mlx.Ffi.St) (name : Name) (args : List Arg) (r : Ret)
    (hs : Host.Mlx.Ffi.symOf name = none) : kernCall k m name args r = some k := by
  unfold kernCall; rw [hs]

theorem kernCall_cfgNew_cons (k : KRec) (m : Host.Mlx.Ffi.St) (name : Name) (a : Arg) (as : List Arg) (r : Ret)
    (hs : Host.Mlx.Ffi.symOf name = some .cfgNew) : kernCall k m name (a :: as) r = some k := by
  unfold kernCall; rw [hs]

theorem kernCall_cfgNew (k : KRec) (m : Host.Mlx.Ffi.St) (name : Name) (h : Nat)
    (hs : Host.Mlx.Ffi.symOf name = some .cfgNew) :
    kernCall k m name [] (.big (Int.ofNat h)) = some { k with targs := k.targs.set h [] } := by
  unfold kernCall; rw [hs]; rfl

theorem argBool_map (M : Map) (a : Arg) : Host.Mlx.Ffi.argBool (M.arg a) = Host.Mlx.Ffi.argBool a := by
  cases a <;> rfl

theorem kernCall_kernelNew_some {k : KRec} {m : Host.Mlx.Ffi.St} {name : Name} {a0 a1 a2 a3 a4 rc ao : Arg} {h : Nat}
    {b1 b2 : Bool} (hs : Host.Mlx.Ffi.symOf name = some .kernelNew) (h1 : Host.Mlx.Ffi.argBool rc = some b1)
    (h2 : Host.Mlx.Ffi.argBool ao = some b2) :
    kernCall k m name [a0, a1, a2, a3, a4, rc, ao] (.big (Int.ofNat h)) =
      some { k with flags := k.flags.set h (b1, b2) } := by
  unfold kernCall; rw [hs]; simp only [h1, h2]; rfl

theorem kernCall_kernelNew_none {k : KRec} {m : Host.Mlx.Ffi.St} {name : Name} {a0 a1 a2 a3 a4 rc ao : Arg} {h : Nat}
    (hs : Host.Mlx.Ffi.symOf name = some .kernelNew)
    (hn : Host.Mlx.Ffi.argBool rc = none ∨ Host.Mlx.Ffi.argBool ao = none) :
    kernCall k m name [a0, a1, a2, a3, a4, rc, ao] (.big (Int.ofNat h)) = none := by
  unfold kernCall; rw [hs]
  rcases hn with hn | hn
  · simp only [hn]
  · simp only [hn]; cases Host.Mlx.Ffi.argBool rc <;> rfl

theorem kernCall_launch_some {k : KRec} {m : Host.Mlx.Ffi.St} {name : Name} {o kha v cha st : Arg} {r : Ret}
    {kh ch : Nat} {fl : Bool × Bool} {l : List (List Char × TArg)} {c : Cfg}
    (hs : Host.Mlx.Ffi.symOf name = some .kernelApply) (hkh : Host.Mlx.Ffi.argNat kha = some kh)
    (hch : Host.Mlx.Ffi.argNat cha = some ch) (h1 : k.flags.get kh = some fl) (h2 : k.targs.get ch = some l)
    (h3 : m.obj? ch = some (.cfg c)) (h4 : ordered l = true) (h5 : c.dtypes = dtypesOf l) (h6 : c.ints = intsOf l) :
    kernCall k m name [o, kha, v, cha, st] r = some k := by
  unfold kernCall; rw [hs]
  simp only [hkh, hch, h1, h2, h3, h4, h5, h6, decide_true, Bool.and_self, Bool.cond_true]

theorem cdtype_spec {P : LoadP} {x : NSt} {args : List Arg} (h : NativeOk.cdtype P x args = true) :
    ∃ c nm dt, args = [c, nm, dt] ∧ cfgOk x c = true ∧ natOk P dt = true := by
  unfold NativeOk.cdtype at h
  split at h
  · rename_i c nm dt
    simp only [Bool.and_eq_true] at h
    exact ⟨c, nm, dt, rfl, h.1, h.2⟩
  · cases h

theorem cint_spec {x : NSt} {args : List Arg} (h : NativeOk.cint x args = true) :
    ∃ c nm v, args = [c, nm, .num v] ∧ cfgOk x c = true := by
  unfold NativeOk.cint at h
  split at h
  · rename_i c nm v
    exact ⟨c, nm, v, rfl, h⟩
  · cases h

theorem kapply_spec {P : LoadP} {x : NSt} {args : List Arg} (h : NativeOk.kapply P x args = true) :
    ∃ o k v c st, args = [o, k, v, c, st] ∧ kernOk x k = true ∧ cfgOk x c = true := by
  unfold NativeOk.kapply at h
  split at h
  · rename_i o k v c st
    simp only [Bool.and_eq_true] at h
    exact ⟨o, k, v, c, st, rfl, h.1.1.1.1.2, h.1.1.2⟩
  · cases h

section
variable {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {x y x' y' : NSt}

theorem MR.big_arg (hr : G.MR P NB M n x y) {k : Nat} (hp : PH x k) :
    M.arg (.big (Int.ofNat k)) = .big (Int.ofNat (M.handle k)) := by
  show Arg.big (M.big (Int.ofNat k)) = _
  rw [(hr.present k hp).1]

theorem isSome_obj {x : NSt} {k : Nat} {o : Host.Mlx.Ffi.Obj} (h : x.obj? k = some o) : (x.objs.get k).isSome = true := by
  rw [show x.objs.get k = x.obj? k from rfl, h]; rfl

/-- What the kernel-recording step needs of the load world's acceptance: a kernel is created with its
seven arguments, and the configuration updates and launches pass the load world's checks. -/
def KernAcc (P : LoadP) (x : NSt) (name : Name) (args : List Arg) : Prop :=
  ∀ s, Host.Mlx.Ffi.symOf name = some s → (s = .kernelNew → args.length = 7) ∧
    ((s = .cfgDtype ∨ s = .cfgInt ∨ s = .kernelApply) → NativeOk.sym P x name s args = true)

theorem kern_cfgDtype {kx ky kx' : KRec} {name : Name} {args : List Arg} {r r' : Ret}
    (hr : KRecR M n x y kx ky) (h : ObsPost P NB M M' n n' x y x' y')
    (hs : Host.Mlx.Ffi.symOf name = some .cfgDtype) (hc : NativeOk.cdtype P x args = true)
    (hx' : kernCall kx x name args r = some kx') :
    ∃ ky', kernCall ky y name (args.map M.arg) r' = some ky' ∧ KRecR M' n' x' y' kx' ky' := by
  obtain ⟨c, nm, dt, rfl, hcf, hdt⟩ := cdtype_spec hc
  obtain ⟨k, cf, rfl, hko⟩ := cfgOk_spec hcf
  have hko' := isSome_obj hko
  unfold kernCall at hx' ⊢; rw [hs] at hx' ⊢
  simp only [argNat_nat] at hx'
  cases enm : Host.Mlx.Ffi.cstrArg nm with
  | none => rw [enm] at hx'; cases hx'
  | some nn =>
    cases edt : Host.Mlx.Ffi.argNat dt with
    | none => rw [enm, edt] at hx'; cases hx'
    | some d =>
      rw [enm, edt] at hx'
      dsimp only at hx'
      cases el : kx.targs.get k with
      | none => rw [el] at hx'; cases hx'
      | some l =>
        rw [el] at hx'
        cases hx'
        simp only [List.map_cons, List.map_nil, MR.big_arg h.pre (.inr hko'), argNat_nat, cstrArg_map, enm,
          h.pre.natOk_argNat hdt, edt, hr.targs k hko', el, Option.map_some]
        exact ⟨_, rfl, hr.upd h hko' el (nn, .dtype d) (fun _ _ hv => by simp at hv)⟩

theorem kern_cfgInt {kx ky kx' : KRec} {name : Name} {args : List Arg} {r r' : Ret}
    (hr : KRecR M n x y kx ky) (h : ObsPost P NB M M' n n' x y x' y')
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) n a)
    (hs : Host.Mlx.Ffi.symOf name = some .cfgInt) (hc : NativeOk.cint x args = true)
    (hx' : kernCall kx x name args r = some kx') :
    ∃ ky', kernCall ky y name (args.map M.arg) r' = some ky' ∧ KRecR M' n' x' y' kx' ky' := by
  obtain ⟨c, nm, v, rfl, hcf⟩ := cint_spec hc
  obtain ⟨k, cf, rfl, hko⟩ := cfgOk_spec hcf
  have hko' := isSome_obj hko
  have hv : SN (· < n) v := SN.of_supp (A := fun _ => True) (hsupp (.num v) (by simp))
  unfold kernCall at hx' ⊢; rw [hs] at hx' ⊢
  simp only [argNat_nat] at hx'
  cases enm : Host.Mlx.Ffi.cstrArg nm with
  | none => rw [enm] at hx'; cases hx'
  | some nn =>
    rw [enm] at hx'
    dsimp only at hx'
    cases el : kx.targs.get k with
    | none => rw [el] at hx'; cases hx'
    | some l =>
      rw [el] at hx'
      cases hx'
      simp only [List.map_cons, List.map_nil, MR.big_arg h.pre (.inr hko'), argNat_nat, cstrArg_map, enm,
        show M.arg (.num v) = .num (M.nv v) from rfl, hr.targs k hko', el, Option.map_some]
      refine ⟨_, rfl, hr.upd h hko' el (nn, .int v) (fun nm' v' hv' => ?_)⟩
      simp only [List.mem_singleton, Prod.mk.injEq, TArg.int.injEq] at hv'
      obtain ⟨-, rfl⟩ := hv'
      exact hv

theorem kern_launch {kx ky kx' : KRec} {name : Name} {args : List Arg} {r r' : Ret}
    (hr : KRecR M n x y kx ky) (h : ObsPost P NB M M' n n' x y x' y')
    (hs : Host.Mlx.Ffi.symOf name = some .kernelApply) (hc : NativeOk.kapply P x args = true)
    (hx' : kernCall kx x name args r = some kx') :
    ∃ ky', kernCall ky y name (args.map M.arg) r' = some ky' ∧ KRecR M' n' x' y' kx' ky' := by
  obtain ⟨o, kh, v, c, st, rfl, hkk, hcf⟩ := kapply_spec hc
  obtain ⟨k1, nm, sc, hd, u, w, rfl, hk1⟩ := kernOk_spec hkk
  obtain ⟨k2, cf, rfl, hk2⟩ := cfgOk_spec hcf
  obtain ⟨fl, l, c', h1, h2, h3, h4, h5, h6, rfl⟩ := kernCall_launch hs (argNat_nat k1) (argNat_nat k2) hx'
  rw [hk2] at h3
  cases h3
  have hp1 := isSome_obj hk1
  have hp2 := isSome_obj hk2
  refine ⟨ky, ?_, hr.keep h⟩
  simp only [List.map_cons, List.map_nil, MR.big_arg h.pre (.inr hp1), MR.big_arg h.pre (.inr hp2)]
  refine kernCall_launch_some hs (argNat_nat _) (argNat_nat _) (by rw [hr.flags k1 hp1, h1])
    (by rw [hr.targs k2 hp2, h2]; rfl) (by rw [h.pre.obj? (.inr hp2), hk2]; rfl)
    (by rw [ordered_targ]; exact h4) (by rw [dtypesOf_targ]; exact h5) ?_
  show cf.ints.map _ = _
  rw [intsOf_targ, h6]

/-- **The kernel-recording layer's step.** -/
theorem kern_step {ex ey : Option KRec} {name : Name} {args : List Arg} {r : Ret}
    (hk : KernR M n x y ex ey) (h : ObsPost P NB M M' n n' x y x' y')
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) n a) (hacc : KernAcc P x name args)
    (hnew : Host.Mlx.Ffi.symOf name = some .cfgNew → args = [] →
      r = .big (Int.ofNat x.next) ∧ (x'.objs.get x.next).isSome = true)
    (hnewK : Host.Mlx.Ffi.symOf name = some .kernelNew → args.length = 7 →
      r = .big (Int.ofNat x.next) ∧ (x'.objs.get x.next).isSome = true) :
    KernR M' n' x' y' (ex.bind fun e => kernCall e x name args r)
      (ey.bind fun e => kernCall e y name (args.map M.arg) (M'.ret r)) := by
  intro kx' hx'
  cases hex : ex with
  | none => rw [hex] at hx'; cases hx'
  | some kx =>
    rw [hex, Option.bind_some] at hx'
    obtain ⟨ky, hey, hr⟩ := hk kx hex
    rw [hey, Option.bind_some]
    cases hs : Host.Mlx.Ffi.symOf name with
    | none =>
      rw [kernCall_none _ _ _ _ _ hs] at hx'
      cases hx'
      exact ⟨ky, kernCall_none _ _ _ _ _ hs, hr.keep h⟩
    | some s =>
      obtain ⟨hkl, hchk⟩ := hacc s hs
      by_cases e0 : s = .kernelNew
      · subst e0
        have hl := hkl rfl
        obtain ⟨rfl, hobj⟩ := hnewK hs hl
        rcases args with _ | ⟨a0, _ | ⟨a1, _ | ⟨a2, _ | ⟨a3, _ | ⟨a4, _ | ⟨rc, _ | ⟨ao, _ | ⟨_, _⟩⟩⟩⟩⟩⟩⟩⟩ <;>
          try (simp only [List.length_cons, List.length_nil] at hl; omega)
        have hb : M'.big (Int.ofNat x.next) = Int.ofNat (M'.handle x.next) := (h.post.present _ (.inr hobj)).1
        cases hb1 : Host.Mlx.Ffi.argBool rc with
        | none => rw [kernCall_kernelNew_none hs (.inl hb1)] at hx'; cases hx'
        | some b1 =>
          cases hb2 : Host.Mlx.Ffi.argBool ao with
          | none => rw [kernCall_kernelNew_none hs (.inr hb2)] at hx'; cases hx'
          | some b2 =>
            rw [kernCall_kernelNew_some hs hb1 hb2] at hx'
            cases hx'
            refine ⟨_, ?_, hr.kernelNew h hobj (b1, b2)⟩
            show kernCall ky y name [M.arg a0, M.arg a1, M.arg a2, M.arg a3, M.arg a4, M.arg rc, M.arg ao]
              (.big (M'.big (Int.ofNat x.next))) = _
            rw [hb, kernCall_kernelNew_some hs (by rw [argBool_map]; exact hb1) (by rw [argBool_map]; exact hb2),
              h.handle]
      have hnk : s ≠ .kernelNew := e0
      by_cases e1 : s = .cfgNew
      · subst e1
        cases args with
        | cons a as =>
          rw [kernCall_cfgNew_cons _ _ _ _ _ _ hs] at hx'
          cases hx'
          exact ⟨ky, kernCall_cfgNew_cons _ _ _ _ _ _ hs, hr.keep h⟩
        | nil =>
          obtain ⟨rfl, hobj⟩ := hnew hs rfl
          rw [kernCall_cfgNew _ _ _ _ hs] at hx'
          cases hx'
          have hb : M'.big (Int.ofNat x.next) = Int.ofNat (M'.handle x.next) := (h.post.present _ (.inr hobj)).1
          have ht : kernCall ky y name (([] : List Arg).map M.arg) (M'.ret (.big (Int.ofNat x.next))) =
              some { ky with targs := ky.targs.set (M.handle x.next) [] } := by
            show kernCall ky y name [] (.big (M'.big (Int.ofNat x.next))) = _
            rw [hb, kernCall_cfgNew _ _ _ _ hs, h.handle]
          exact ⟨_, ht, hr.cfgNew h hobj⟩
      · by_cases e2 : s = .cfgDtype
        · subst e2; exact kern_cfgDtype hr h hs (hchk (.inl rfl)) hx'
        · by_cases e3 : s = .cfgInt
          · subst e3; exact kern_cfgInt hr h hsupp hs (hchk (.inr (.inl rfl))) hx'
          · by_cases e4 : s = .kernelApply
            · subst e4; exact kern_launch hr h hs (hchk (.inr (.inr rfl))) hx'
            · rw [kernCall_other _ _ _ _ _ hs hnk e1 e2 e3 e4] at hx'
              cases hx'
              exact ⟨ky, kernCall_other _ _ _ _ _ hs hnk e1 e2 e3 e4, hr.keep h⟩

end

/-! ## Pending traces' result regions along a call -/

/-- **The pending traces' result regions after a call** that keeps the model's objects and pending
traces (`Keep`): old traces keep their regions, new ones are fresh, and the fresh regions continue
in order since handles are allocated in step (`G.MR.hfreshR` before and after); a new trace's id and
its tracer vector's are fresh, so their images stay adjacent. -/
theorem _root_.Host.Ts.Sim.G.PendReg.step {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {x y x' y' : NSt}
    (hp : G.PendReg M x y) (hr : G.MR P NB M n x y) (hr' : G.MR P NB M' n' x' y') (he : Ext M M' n)
    (hk : Keep x x') : G.PendReg M' x' y' := by
  have hb : M'.big = M.big := he.big
  have hreg : M'.region = M.region := he.region
  have hh : ∀ h, M'.handle h = M.handle h := fun h => by simp only [Map.handle, hb]
  have r0 := hr.hroom
  have r1 := hr'.hroom
  have hx : x.next ≤ x'.next := hk.next
  -- handles are allocated in step
  have hy : y'.next = y.next + (x'.next - x.next) := by
    have e1 := (hr.hfreshR (x'.next - x.next) (by omega)).1
    rw [show x.next + (x'.next - x.next) = x'.next by omega] at e1
    have e2 := (hr'.hfreshR 0 (by omega)).1
    rw [hreg] at e2
    simp only [Nat.add_zero] at e2
    omega
  refine ⟨fun p hpp => ?_, fun k hk' => ?_⟩
  · rcases hk.pend p hpp with ⟨q, hq, e⟩ | ⟨f1, f2⟩
    · obtain ⟨l1, l2, l3⟩ := hp.reg q hq
      rw [← e]
      exact ⟨Nat.lt_of_lt_of_le l1 hx, by rw [hreg, hh]; exact l2, by rw [hh, hh]; exact l3⟩
    · have fresh : ∀ j, x.next ≤ j → j < x'.next → M'.handle j = y.next + (j - x.next) := by
        intro j h1 h2
        have hbig := hr.hfreshB (j - x.next) (by omega)
        rw [show x.next + (j - x.next) = j by omega] at hbig
        rw [hh]; show (M.big (Int.ofNat j)).toNat = _; rw [hbig]; rfl
      have hf := hp.fresh (p.id - x.next) (by omega)
      rw [show x.next + (p.id - x.next) = p.id by omega] at hf
      refine ⟨f2, by rw [hreg, fresh p.id (by omega) f2]; exact hf, ?_⟩
      rw [fresh p.id (by omega) f2, fresh (p.id - 1) (by omega) (by omega)]
      omega
  · have hf := hp.fresh (x'.next - x.next + k) (by omega)
    rw [show x.next + (x'.next - x.next + k) = x'.next + k by omega,
      show y.next + (x'.next - x.next + k) = y'.next + k by omega] at hf
    rw [hreg]; exact hf

end Host.Ts.Sim.Full
