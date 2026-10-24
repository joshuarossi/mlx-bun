import metal.Logic
import metal.Launch
import metal.Gpu

namespace Metal
open Core Inference.Contracts.Mlx

/-! # SIMD-groups, threadgroups and launches

Lemmas above the thread level. Runs keep their results when their bounds
grow. A SIMD-group passes a collective, a threadgroup a barrier. A launch
whose threadgroups tile its grid has explicit threads, SIMD-groups and
coordinates; it runs from facts about each threadgroup; it is race-free when
its log keeps an ownership discipline; and the GPU then produces its outputs. -/

variable (C : M1Max.Contract)

/-! ## Larger bounds -/

/-- `b` gives every result `a` gives. -/
def Extends {α : Type} (a b : M α) : Prop := ∀ sh r, a.run sh = some r → b.run sh = some r

theorem Extends.refl {α : Type} (a : M α) : Extends a a := fun _ _ h => h

theorem failure_run {α : Type} (sh : Shared) : (failure : M α).run sh = none := rfl

theorem Extends.bind {α β : Type} {a a' : M α} {f f' : α → M β} (ha : Extends a a')
    (hf : ∀ x, Extends (f x) (f' x)) : Extends (a >>= f) (a' >>= f') := by
  intro sh r h
  rw [StateT.run_bind] at h ⊢
  cases h1 : a.run sh with
  | none => rw [h1] at h; exact absurd h (by simp)
  | some p => rw [h1] at h; rw [ha sh p h1]; exact hf p.1 p.2 r h

theorem mapM_extends {α β : Type} {f g : α → M β} (h : ∀ x, Extends (f x) (g x)) :
    ∀ xs : List α, Extends (xs.mapM f) (xs.mapM g)
  | [] => Extends.refl _
  | x :: xs => by
    rw [List.mapM_cons, List.mapM_cons]
    exact Extends.bind (h x) fun _ => Extends.bind (mapM_extends h xs) fun _ => Extends.refl _

theorem forM_extends {α : Type} {f g : α → M PUnit} (h : ∀ x, Extends (f x) (g x)) :
    ∀ xs : List α, Extends (xs.forM f) (xs.forM g)
  | [] => Extends.refl _
  | x :: xs => by
    show Extends (f x >>= fun _ => xs.forM f) (g x >>= fun _ => xs.forM g)
    exact Extends.bind (h x) fun _ => forM_extends h xs

theorem runThread_extends : ∀ {n m : Nat} (t : Thread), n ≤ m → Extends (runThread C n t) (runThread C m t)
  | 0, m, t, _ => by
    intro sh r h
    cases hr : isRunning t.status
    · rw [runThread_stop C 0 hr] at h; rw [runThread_stop C m hr]; exact h
    · have : runThread C 0 t = failure := by simp [runThread, hr]
      rw [this, failure_run] at h; cases h
  | _ + 1, 0, _, h => absurd h (by omega)
  | n + 1, m + 1, t, h => by
    intro sh r hr
    cases hs : isRunning t.status
    · rw [runThread_stop C _ hs] at hr; rw [runThread_stop C _ hs]; exact hr
    · rw [runThread_step C n hs] at hr; rw [runThread_step C m hs]
      exact Extends.bind (Extends.refl _) (fun t' => runThread_extends t' (by omega)) sh r hr

theorem blocked_of_collectiveOf {st : Status} {key : Nat × Collective × Scalar × Nat} (h : collectiveOf st = some key) :
    blocked st = false := by
  cases st <;> simp_all [collectiveOf, blocked]

theorem runSimd_extends : ∀ {f f' r r' : Nat} (lanes : List Thread), f ≤ f' → r ≤ r' →
    Extends (runSimd C f r lanes) (runSimd C f' r' lanes)
  | _, _, 0, _, _, _, _ => fun sh x h => by rw [runSimd, failure_run] at h; cases h
  | _, _, _ + 1, 0, _, _, h => absurd h (by omega)
  | f, f', r + 1, r' + 1, lanes, hf, hr => by
    rw [runSimd, runSimd]
    refine Extends.bind (mapM_extends (fun t => runThread_extends C t hf) lanes) (fun ls => ?_)
    by_cases hb : ls.all (blocked ·.status) = true
    · rw [ite_eq_left hb, ite_eq_left hb]; exact Extends.refl _
    · rw [ite_eq_right hb, ite_eq_right hb]
      generalize ls.map (collectiveOf ·.status) = keys
      rcases keys with _ | ⟨_ | key, rest⟩
      · exact Extends.refl _
      · exact Extends.refl _
      · dsimp only
        by_cases hc : rest.all (· = some key) = true
        · rw [ite_eq_left hc, ite_eq_left hc]
          obtain ⟨_, op, s, delta⟩ := key
          exact Extends.bind (Extends.refl _) fun _ => Extends.bind (Extends.refl _) fun _ =>
            Extends.bind (Extends.refl _) fun resumed => runSimd_extends resumed hf (by omega)
        · rw [ite_eq_right hc, ite_eq_right hc]; exact Extends.refl _

theorem runGroup_extends : ∀ {f f' r r' b b' : Nat} (simds : List (List Thread)), f ≤ f' → r ≤ r' → b ≤ b' →
    Extends (runGroup C f r b simds) (runGroup C f' r' b' simds)
  | _, _, _, _, 0, _, _, _, _, _ => fun sh x h => by rw [runGroup, failure_run] at h; cases h
  | _, _, _, _, _ + 1, 0, _, _, _, h => absurd h (by omega)
  | f, f', r, r', b + 1, b' + 1, simds, hf, hr, hb => by
    rw [runGroup, runGroup]
    refine Extends.bind (mapM_extends (fun lanes => runSimd_extends C lanes hf hr) simds) (fun ss => ?_)
    dsimp only
    by_cases hd : ss.flatten.all (isDone ·.status) = true
    · rw [ite_eq_left hd, ite_eq_left hd]; exact Extends.refl _
    · rw [ite_eq_right hd, ite_eq_right hd]
      generalize ss.flatten.map (barrierOf ·.status) = keys
      rcases keys with _ | ⟨_ | ⟨site, d, g⟩, rest⟩
      · exact Extends.refl _
      · exact Extends.refl _
      · dsimp only
        by_cases hc : rest.all (· = some (site, d, g)) = true
        · rw [ite_eq_left hc, ite_eq_left hc]
          exact Extends.bind (Extends.refl _) fun _ => runGroup_extends _ hf hr (by omega)
        · rw [ite_eq_right hc, ite_eq_right hc]; exact Extends.refl _

/-- More fuel keeps a thread's run. -/
theorem runThread_mono {n m : Nat} (h : n ≤ m) (t : Thread) {sh : Shared} {r : Thread × Shared}
    (hr : (runThread C n t).run sh = some r) : (runThread C m t).run sh = some r :=
  runThread_extends C t h sh r hr

/-- More fuel and rounds keep a SIMD-group's run. -/
theorem runSimd_mono {f f' r r' : Nat} (hf : f ≤ f') (hr : r ≤ r') (lanes : List Thread) {sh : Shared}
    {x : List Thread × Shared} (h : (runSimd C f r lanes).run sh = some x) : (runSimd C f' r' lanes).run sh = some x :=
  runSimd_extends C lanes hf hr sh x h

/-- More fuel, rounds and barriers keep a threadgroup's run. -/
theorem runGroup_mono {f f' r r' b b' : Nat} (hf : f ≤ f') (hr : r ≤ r') (hb : b ≤ b') (simds : List (List Thread))
    {sh : Shared} {x : Unit × Shared} (h : (runGroup C f r b simds).run sh = some x) :
    (runGroup C f' r' b' simds).run sh = some x :=
  runGroup_extends C simds hf hr hb sh x h

theorem bind_of_extends {α β : Type} {x y : Option α} {g : α → Option β} {r : β} (h : x >>= g = some r)
    (hxy : ∀ p, x = some p → y = some p) : y >>= g = some r := by
  cases hx : x with
  | none => rw [hx] at h; exact absurd h (by simp)
  | some p => rw [hx] at h; rw [hxy p hx]; exact h

/-- More fuel, rounds and barriers keep a launch's run. -/
theorem runLaunch_mono (fuse : Nat → Bool) (L : Launch) (garbage : Garbage) {f f' r r' b b' : Nat} (hf : f ≤ f')
    (hr : r ≤ r') (hb : b ≤ b') {res : Result} (h : runLaunch C fuse L garbage f r b = some res) :
    runLaunch C fuse L garbage f' r' b' = some res := by
  unfold runLaunch at h ⊢
  generalize L.groups = G at h ⊢
  obtain ⟨gx, gy, gz⟩ := G
  dsimp only at h ⊢
  refine bind_of_extends h (fun p hp => forM_extends (fun x => ?_) _ _ p hp)
  obtain ⟨bx, byy, bz⟩ := x
  exact Extends.bind (Extends.refl _) fun _ => runGroup_extends C _ hf hr hb

/-- Finitely many lower bounds have a common one. -/
theorem exists_bound : ∀ {n : Nat} (P : Fin n → Nat → Prop), (∀ i, ∃ b, ∀ m ≥ b, P i m) →
    ∃ b, ∀ i, ∀ m ≥ b, P i m
  | 0, _, _ => ⟨0, fun i => i.elim0⟩
  | n + 1, P, h => by
    obtain ⟨b0, h0⟩ := h 0
    obtain ⟨b1, h1⟩ := exists_bound (fun i : Fin n => P i.succ) (fun i => h i.succ)
    refine ⟨max b0 b1, fun i m hm => ?_⟩
    cases i using Fin.cases with
    | zero => exact h0 m (le_trans (le_max_left _ _) hm)
    | succ i => exact h1 i m (le_trans (le_max_right _ _) hm)

/-! ## Lists of runs -/

theorem mapM_eq_map {α β : Type} (f : α → Option β) (g : α → β) :
    ∀ xs : List α, (∀ x ∈ xs, f x = some (g x)) → xs.mapM f = some (xs.map g)
  | [], _ => rfl
  | x :: xs, h => by
    rw [List.mapM_cons, h x (by simp), mapM_eq_map f g xs (fun y hy => h y (by simp [hy]))]
    rfl

theorem zip_ofFn {α β : Type} {n : Nat} (x : Fin n → α) (y : Fin n → β) :
    (List.ofFn x).zip (List.ofFn y) = List.ofFn fun i => (x i, y i) := by
  apply List.ext_getElem <;> simp

theorem ofFn_cons {β : Type} {n : Nat} (u : β) (U : Fin n → β) :
    List.ofFn (Fin.cons u U : Fin (n + 1) → β) = u :: List.ofFn U := by
  rw [List.ofFn_succ]; simp

/-- Running a list in order, with an invariant indexed by position, gives a result for each element. -/
theorem mapM_ofFn_spec {α β : Type} : ∀ {n : Nat} (T : Fin n → α) (f : α → M β) (I : Nat → Shared → Prop)
    (Q : Fin n → β → Prop),
    (∀ i : Fin n, ∀ sh, I i sh → ∃ u sh', (f (T i)).run sh = some (u, sh') ∧ I (i + 1) sh' ∧ Q i u) →
    ∀ sh, I 0 sh → ∃ (U : Fin n → β) (sh' : Shared),
      ((List.ofFn T).mapM f).run sh = some (List.ofFn U, sh') ∧ I n sh' ∧ ∀ i, Q i (U i)
  | 0, _, _, _, _, _, sh, h0 => ⟨Fin.elim0, sh, rfl, h0, fun i => i.elim0⟩
  | n + 1, T, f, I, Q, h, sh, h0 => by
    obtain ⟨u, sh1, hr, h1, hq⟩ := h 0 sh h0
    obtain ⟨U, sh', hr', hn, hqs⟩ := mapM_ofFn_spec (fun i : Fin n => T i.succ) f (fun j => I (j + 1))
      (fun i => Q i.succ) (fun i sh hi => by simpa [Nat.add_assoc] using h i.succ sh hi) sh1 h1
    refine ⟨Fin.cons u U, sh', ?_, hn, fun i => ?_⟩
    · rw [ofFn_cons, List.ofFn_succ, List.mapM_cons]
      simp only [StateT.run_bind] at hr' ⊢
      rw [hr]
      simp only [Option.bind_eq_bind, Option.bind_some]
      rw [hr']
      rfl
    · cases i using Fin.cases with
      | zero => simpa using hq
      | succ i => simpa using hqs i

/-! ## SIMD-groups -/

/-- Lanes that all stop at the same collective resume with its results, each in its lane's slot. -/
theorem runSimd_collective (fuel r : Nat) (lanes ls : List Thread) (sh sh' : Shared) (site slot : Nat)
    (op : Collective) (s : Scalar) (d : Nat) (values results : List Val)
    (hrun : (lanes.mapM (runThread C fuel)).run sh = some (ls, sh'))
    (hst : ∀ t ∈ ls, collectiveOf t.status = some (site, op, s, d) ∧ slotOf t.status = some slot)
    (hv : ls.mapM (fun t => valueOf t.status) = some values)
    (hres : resolve C op s d values = some results) :
    (runSimd C fuel (r + 1) lanes).run sh =
      (runSimd C fuel r ((ls.zip results).map fun p => { p.1 with status := .running }.set slot p.2)).run sh' := by
  cases ls with
  | nil =>
    rw [List.mapM_nil] at hv
    obtain rfl : values = [] := (Option.some.inj hv).symm
    simp [resolve] at hres
  | cons t0 rest =>
    have h0 := hst t0 (by simp)
    have hb : ¬ ((t0 :: rest).all (blocked ·.status) = true) := by
      intro h
      have h1 := List.all_eq_true.mp h t0 (by simp)
      rw [blocked_of_collectiveOf h0.1] at h1
      cases h1
    have hall : (rest.map (collectiveOf ·.status)).all (· = some (site, op, s, d)) = true := by
      rw [List.all_eq_true]
      intro k hk
      obtain ⟨t, ht, rfl⟩ := List.mem_map.mp hk
      simp [(hst t (by simp [ht])).1]
    simp only [runSimd, StateT.run_bind, hrun]
    show Option.bind (some (_, sh')) _ = _
    simp only [Option.bind_some]
    rw [ite_eq_right hb, List.map_cons, h0.1]
    simp only [hall, ite_true]
    rw [hv]
    simp only [lift_some, pure_bind]
    rw [hres]
    simp only [lift_some, pure_bind]
    rw [mapM_eq_map _ (fun p : Thread × Val => { p.1 with status := .running }.set slot p.2) _ ?_]
    · simp only [lift_some, pure_bind]
    · rintro ⟨t, v⟩ hm
      have := (hst t (List.of_mem_zip hm).1).2
      simp [this]

/-- `runSimd_collective` for lanes given by `Fin 32`: lane `i` stopped with value `x i` resumes with `y i`. -/
theorem runSimd_collective_ofFn (fuel r : Nat) (lanes : List Thread) (T : Fin 32 → Thread) (sh sh' : Shared)
    (site slot : Nat) (op : Collective) (s : Scalar) (d : Nat) (x y : Fin 32 → Val)
    (hrun : (lanes.mapM (runThread C fuel)).run sh = some (List.ofFn T, sh'))
    (hst : ∀ i, (T i).status = .collective site slot op s (x i) d)
    (hres : resolve C op s d (List.ofFn x) = some (List.ofFn y)) :
    (runSimd C fuel (r + 1) lanes).run sh =
      (runSimd C fuel r (List.ofFn fun i => { T i with status := .running }.set slot (y i))).run sh' := by
  rw [runSimd_collective C fuel r lanes (List.ofFn T) sh sh' site slot op s d (List.ofFn x) (List.ofFn y) hrun
    (fun t ht => by obtain ⟨i, rfl⟩ := List.mem_ofFn.mp ht; simp [hst, collectiveOf, slotOf])
    (mapM_ofFn T _ x (fun i => by simp [hst, valueOf])) hres, zip_ofFn, List.map_ofFn]
  rfl

/-- Lanes given by `Fin n` that all stop done or at a barrier end the SIMD-group's run. -/
theorem runSimd_blocked_ofFn {n : Nat} (fuel r : Nat) (lanes : List Thread) (V : Fin n → Thread) (sh sh' : Shared)
    (hrun : (lanes.mapM (runThread C fuel)).run sh = some (List.ofFn V, sh'))
    (hb : ∀ i, blocked (V i).status = true) :
    (runSimd C fuel (r + 1) lanes).run sh = some (List.ofFn V, sh') :=
  runSimd_blocked C fuel r lanes _ sh sh' hrun (fun t ht => by obtain ⟨i, rfl⟩ := List.mem_ofFn.mp ht; exact hb i)

/-- A SIMD-group's last round: its lanes run in order, from an invariant at their index, to a barrier or the end. -/
theorem runSimd_blocked_inv (fuel r : Nat) (T : Fin 32 → Thread) (I : Nat → Shared → Prop)
    (R : Fin 32 → Thread → Prop)
    (h : ∀ i : Fin 32, ∀ sh, I i sh → ∃ t sh', (runThread C fuel (T i)).run sh = some (t, sh') ∧ I (i + 1) sh' ∧
      blocked t.status = true ∧ R i t)
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (runSimd C fuel (r + 1) (List.ofFn T)).run sh = some (List.ofFn V, sh') ∧
      I 32 sh' ∧ ∀ i, R i (V i) := by
  obtain ⟨V, sh', hrun, hI, hq⟩ := mapM_ofFn_spec T (runThread C fuel) I (fun i t => blocked t.status = true ∧ R i t)
    h sh h0
  exact ⟨V, sh', runSimd_blocked_ofFn C fuel r _ V sh sh' hrun (fun i => (hq i).1), hI, fun i => (hq i).2⟩

/-- A SIMD-group's round to a collective: its lanes run in order, from an invariant at their index, to the
collective with values `x`; the rest of the run continues from the lanes resumed with its results `y`. -/
theorem runSimd_collective_inv (fuel r : Nat) (T : Fin 32 → Thread) (site slot : Nat) (op : Collective) (s : Scalar)
    (d : Nat) (x y : Fin 32 → Val) (hres : resolve C op s d (List.ofFn x) = some (List.ofFn y))
    (I : Nat → Shared → Prop) (P : Fin 32 → Thread → Prop) (J : Shared → Prop) (R : Fin 32 → Thread → Prop)
    (h : ∀ i : Fin 32, ∀ sh, I i sh → ∃ t sh', (runThread C fuel (T i)).run sh = some (t, sh') ∧ I (i + 1) sh' ∧
      t.status = .collective site slot op s (x i) d ∧ P i t)
    (hnext : ∀ (U : Fin 32 → Thread) (sh : Shared), (∀ i, P i (U i)) → I 32 sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C fuel r (List.ofFn fun i => { U i with status := .running }.set slot (y i))).run sh =
        some (List.ofFn V, sh') ∧ J sh' ∧ ∀ i, R i (V i))
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (runSimd C fuel (r + 1) (List.ofFn T)).run sh = some (List.ofFn V, sh') ∧
      J sh' ∧ ∀ i, R i (V i) := by
  obtain ⟨U, sh1, hrun, hI, hq⟩ := mapM_ofFn_spec T (runThread C fuel) I
    (fun i t => t.status = .collective site slot op s (x i) d ∧ P i t) h sh h0
  rw [runSimd_collective_ofFn C fuel r _ U sh sh1 site slot op s d x y hrun (fun i => (hq i).1) hres]
  exact hnext U sh1 (fun i => (hq i).2) hI

/-- f32 `simd_sum`: every lane gets the sum. -/
theorem resolve_sum (d : Nat) (x : Fin 32 → Float32) :
    resolve C .sum .f32 d (List.ofFn fun i => .f32 (x i)) = some (List.ofFn fun _ : Fin 32 => .f32 (C.simdSum x)) := by
  have hsum : (C.simdSum fun i => (List.ofFn x).getD i.val (FloatMemory.decode 0)) = C.simdSum x := by
    congr 1; funext i; exact getD_ofFn x _ i
  simp only [resolve, List.length_ofFn, ne_eq, not_true_eq_false, ite_false]
  rw [mapM_ofFn (fun i => Val.f32 (x i)) _ x (fun i => rfl)]
  simp only [Option.bind_eq_bind, Option.bind_some, hsum]
  congr 1

/-- `simd_shuffle_down` by `d`: lane `i` gets lane `i + d`'s value, or keeps its own past the last lane. -/
def shuffle {α : Type} (x : Fin 32 → α) (d : Nat) (i : Fin 32) : α :=
  if h : i.val + d < 32 then x ⟨i.val + d, h⟩ else x i

theorem shuffle_of_lt {α : Type} (x : Fin 32 → α) (d : Nat) (i : Fin 32) (h : i.val + d < 32) :
    shuffle x d i = x ⟨i.val + d, h⟩ := dite_eq_left h

theorem shuffle_of_ge {α : Type} (x : Fin 32 → α) (d : Nat) (i : Fin 32) (h : 32 ≤ i.val + d) :
    shuffle x d i = x i := dite_eq_right (by omega)

theorem shuffle_map {α β : Type} (f : α → β) (x : Fin 32 → α) (d : Nat) (i : Fin 32) :
    shuffle (fun j => f (x j)) d i = f (shuffle x d i) := by
  unfold shuffle; split <;> rfl

theorem resolve_shuffle (s : Scalar) (d : Nat) (x : Fin 32 → Val) :
    resolve C .shuffleDown s d (List.ofFn x) = some (List.ofFn (shuffle x d)) := by
  simp only [resolve, List.length_ofFn, ne_eq, not_true_eq_false, ite_false]
  congr 1
  apply List.ext_getElem
  · simp
  · intro i h1 h2
    simp only [List.length_map, List.length_range] at h1
    simp only [List.getElem_map, List.getElem_range, List.getElem_ofFn]
    by_cases h : i + d < 32
    · rw [ite_eq_left h, shuffle_of_lt x d ⟨i, h1⟩ h]; exact getD_ofFn x default ⟨i + d, h⟩
    · rw [ite_eq_right h, shuffle_of_ge x d ⟨i, h1⟩ (show 32 ≤ i + d by omega)]; exact getD_ofFn x default ⟨i, h1⟩

theorem resolve_shuffle_f32 (d : Nat) (x : Fin 32 → Float32) :
    resolve C .shuffleDown .f32 d (List.ofFn fun i => .f32 (x i)) =
      some (List.ofFn fun i => .f32 (shuffle x d i)) := by
  rw [resolve_shuffle]; congr 2; funext i; exact shuffle_map _ x d i

theorem resolve_shuffle_u32 (d : Nat) (x : Fin 32 → Nat) :
    resolve C .shuffleDown .u32 d (List.ofFn fun i => .int .u32 (x i)) =
      some (List.ofFn fun i => .int .u32 (shuffle x d i)) := by
  rw [resolve_shuffle]; congr 2; funext i; exact shuffle_map _ x d i

/-! ### SIMD-group matrices -/

theorem regs_ofFn {α : Type} (x : Fin 32 → Fin 2 → α) (d : α) :
    regs (List.ofFn fun i => (x i 0, x i 1)) d = x := by
  funext l j
  simp only [regs]
  rw [getD_ofFn (fun i => (x i 0, x i 1)) (d, d) l]
  match j with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl

/-- Lane `i`'s `simdgroup_multiply_accumulate` value (the elaborated `.vector .f32 [A, B, C]`):
its `thread_elements()` of `A` (element type `sa`), `B` (`sb`) and `C`. -/
def mmaArg (sa sb : Scalar) (a b c : Val × Val) : Val :=
  .vec .f32 [.vec sa [a.1, a.2], .vec sb [b.1, b.2], .vec .f32 [c.1, c.2]]

/-- Every lane's result: its `D` registers. -/
def mmaOut (D : Fin 32 → Fin 2 → Float32) : List Val :=
  List.ofFn fun i => .vec .f32 [.f32 (D i 0), .f32 (D i 1)]

theorem pairs_ofFn {α : Type} {s : Scalar} (f : Val → Option α) (g : Val × Val × Val → Val) (T : Fin 32 → Val × Val × Val)
    (x : Fin 32 → Fin 2 → α) (y : Fin 32 → Fin 2 → Val) (hg : ∀ i, g (T i) = .vec s [y i 0, y i 1])
    (hf : ∀ i j, f (y i j) = some (x i j)) :
    (List.ofFn T).mapM (fun o => pairOf f (g o)) = some (List.ofFn fun i => (x i 0, x i 1)) :=
  mapM_ofFn T _ _ fun i => by simp [hg, pairOf, hf]

def mmaT (sa sb : Scalar) (a b c : Fin 32 → Fin 2 → Val) (i : Fin 32) : Val × Val × Val :=
  (.vec sa [a i 0, a i 1], .vec sb [b i 0, b i 1], .vec .f32 [c i 0, c i 1])

theorem mmaOps_ofFn (sa sb : Scalar) (a b c : Fin 32 → Fin 2 → Val) :
    (List.ofFn fun i => mmaArg sa sb (a i 0, a i 1) (b i 0, b i 1) (c i 0, c i 1)).mapM mmaOps =
      some (List.ofFn (mmaT sa sb a b c)) :=
  mapM_ofFn _ _ _ fun _ => rfl

/-- Float `A` and `B`: every lane gets its registers of `C.simdMma` on the lanes' registers. -/
theorem resolve_mma (d : Nat) (a b c : Fin 32 → Fin 2 → Float32) :
    resolve C (.mma .f32 .f32) .f32 d
      (List.ofFn fun i => mmaArg .f32 .f32 (.f32 (a i 0), .f32 (a i 1)) (.f32 (b i 0), .f32 (b i 1))
        (.f32 (c i 0), .f32 (c i 1))) = some (mmaOut (C.simdMma a b c)) := by
  let A : Fin 32 → Fin 2 → Val := fun i j => .f32 (a i j)
  let B : Fin 32 → Fin 2 → Val := fun i j => .f32 (b i j)
  let D : Fin 32 → Fin 2 → Val := fun i j => .f32 (c i j)
  have hops := mmaOps_ofFn .f32 .f32 A B D
  have hc := pairs_ofFn f32Of (·.2.2) (mmaT .f32 .f32 A B D) c (fun i j => .f32 (c i j)) (fun _ => rfl) (fun _ _ => rfl)
  have ha := pairs_ofFn f32Of (·.1) (mmaT .f32 .f32 A B D) a (fun i j => .f32 (a i j)) (fun _ => rfl) (fun _ _ => rfl)
  have hb := pairs_ofFn f32Of (·.2.1) (mmaT .f32 .f32 A B D) b (fun i j => .f32 (b i j)) (fun _ => rfl) (fun _ _ => rfl)
  dsimp only [A, B, D] at hops hc ha hb
  simp only [resolve, List.length_ofFn, ne_eq, not_true_eq_false, ite_false, hops, Option.bind_eq_bind,
    Option.bind_some, mma, hc, ha, hb, regs_ofFn]
  rfl

/-- Half `A`: `C.simdMmaHalfA`. -/
theorem resolve_mma_halfA (d : Nat) (a : Fin 32 → Fin 2 → Float16.Value) (b c : Fin 32 → Fin 2 → Float32) :
    resolve C (.mma .f16 .f32) .f32 d
      (List.ofFn fun i => mmaArg .f16 .f32 (.f16 (a i 0), .f16 (a i 1)) (.f32 (b i 0), .f32 (b i 1))
        (.f32 (c i 0), .f32 (c i 1))) = some (mmaOut (C.simdMmaHalfA a b c)) := by
  let A : Fin 32 → Fin 2 → Val := fun i j => .f16 (a i j)
  let B : Fin 32 → Fin 2 → Val := fun i j => .f32 (b i j)
  let D : Fin 32 → Fin 2 → Val := fun i j => .f32 (c i j)
  have hops := mmaOps_ofFn .f16 .f32 A B D
  have hc := pairs_ofFn f32Of (·.2.2) (mmaT .f16 .f32 A B D) c (fun i j => .f32 (c i j)) (fun _ => rfl) (fun _ _ => rfl)
  have ha := pairs_ofFn f16Of (·.1) (mmaT .f16 .f32 A B D) a (fun i j => .f16 (a i j)) (fun _ => rfl) (fun _ _ => rfl)
  have hb := pairs_ofFn f32Of (·.2.1) (mmaT .f16 .f32 A B D) b (fun i j => .f32 (b i j)) (fun _ => rfl) (fun _ _ => rfl)
  dsimp only [A, B, D] at hops hc ha hb
  simp only [resolve, List.length_ofFn, ne_eq, not_true_eq_false, ite_false, hops, Option.bind_eq_bind,
    Option.bind_some, mma, hc, ha, hb, regs_ofFn]
  rfl

/-- Half `B`: `C.simdMmaHalfB`. -/
theorem resolve_mma_halfB (d : Nat) (a : Fin 32 → Fin 2 → Float32) (b : Fin 32 → Fin 2 → Float16.Value)
    (c : Fin 32 → Fin 2 → Float32) :
    resolve C (.mma .f32 .f16) .f32 d
      (List.ofFn fun i => mmaArg .f32 .f16 (.f32 (a i 0), .f32 (a i 1)) (.f16 (b i 0), .f16 (b i 1))
        (.f32 (c i 0), .f32 (c i 1))) = some (mmaOut (C.simdMmaHalfB a b c)) := by
  let A : Fin 32 → Fin 2 → Val := fun i j => .f32 (a i j)
  let B : Fin 32 → Fin 2 → Val := fun i j => .f16 (b i j)
  let D : Fin 32 → Fin 2 → Val := fun i j => .f32 (c i j)
  have hops := mmaOps_ofFn .f32 .f16 A B D
  have hc := pairs_ofFn f32Of (·.2.2) (mmaT .f32 .f16 A B D) c (fun i j => .f32 (c i j)) (fun _ => rfl) (fun _ _ => rfl)
  have ha := pairs_ofFn f32Of (·.1) (mmaT .f32 .f16 A B D) a (fun i j => .f32 (a i j)) (fun _ => rfl) (fun _ _ => rfl)
  have hb := pairs_ofFn f16Of (·.2.1) (mmaT .f32 .f16 A B D) b (fun i j => .f16 (b i j)) (fun _ => rfl) (fun _ _ => rfl)
  dsimp only [A, B, D] at hops hc ha hb
  simp only [resolve, List.length_ofFn, ne_eq, not_true_eq_false, ite_false, hops, Option.bind_eq_bind,
    Option.bind_some, mma, hc, ha, hb, regs_ofFn]
  rfl

/-! ## Threadgroups -/

/-- The epochs after a barrier that orders device (`d`) and threadgroup (`g`) memory. -/
def pass (d g : Bool) (sh : Shared) : Shared :=
  { sh with
    deviceEpoch := if d then sh.deviceEpoch + 1 else sh.deviceEpoch,
    groupEpoch := if g then sh.groupEpoch + 1 else sh.groupEpoch }

theorem pass_regions (d g : Bool) (sh : Shared) : (pass d g sh).regions = sh.regions := rfl
theorem pass_bytes (d g : Bool) (sh : Shared) : (pass d g sh).bytes = sh.bytes := rfl
theorem pass_log (d g : Bool) (sh : Shared) : (pass d g sh).log = sh.log := rfl

/-- Threads that all end done end the threadgroup's run. -/
theorem runGroup_done (fuel rounds b : Nat) (simds ss : List (List Thread)) (sh sh' : Shared)
    (hrun : (simds.mapM (runSimd C fuel rounds)).run sh = some (ss, sh'))
    (hd : ∀ lanes ∈ ss, ∀ t ∈ lanes, t.status = .done) :
    (runGroup C fuel rounds (b + 1) simds).run sh = some ((), sh') := by
  have hall : (ss.flatten.all fun t => isDone t.status) = true := by
    simp only [List.all_eq_true, List.mem_flatten]
    rintro t ⟨lanes, hl, ht⟩
    simp [hd lanes hl t ht, isDone]
  simp only [runGroup, StateT.run_bind, hrun]
  show Option.bind (some (ss, sh')) _ = _
  simp only [Option.bind_some]
  rw [ite_eq_left hall]
  rfl

/-- Threads that all stop at the same barrier pass it: the epochs advance by its flags and the run
continues with every thread running and one barrier fewer. -/
theorem runGroup_barrier (fuel rounds b : Nat) (simds ss : List (List Thread)) (sh sh' : Shared) (site : Nat)
    (d g : Bool) (hrun : (simds.mapM (runSimd C fuel rounds)).run sh = some (ss, sh')) (hne : ss.flatten ≠ [])
    (hb : ∀ lanes ∈ ss, ∀ t ∈ lanes, t.status = .barrier site d g) :
    (runGroup C fuel rounds (b + 1) simds).run sh =
      (runGroup C fuel rounds b (ss.map (·.map fun t => { t with status := .running }))).run (pass d g sh') := by
  obtain ⟨t0, rest, hfl⟩ := List.exists_cons_of_ne_nil hne
  have hmem : ∀ t ∈ ss.flatten, t.status = .barrier site d g := by
    intro t ht
    obtain ⟨l, hl, ht⟩ := List.mem_flatten.mp ht
    exact hb l hl t ht
  have h0 : t0.status = .barrier site d g := hmem t0 (by rw [hfl]; simp)
  have hnd : ¬ (ss.flatten.all fun t => isDone t.status) = true := by
    rw [hfl]; intro h
    have := List.all_eq_true.mp h t0 (by simp)
    rw [h0] at this; cases this
  have hrest : (rest.map (barrierOf ·.status)).all (· = some (site, d, g)) = true := by
    rw [List.all_eq_true]
    intro k hk
    obtain ⟨t, ht, rfl⟩ := List.mem_map.mp hk
    simp [hmem t (by rw [hfl]; simp [ht]), barrierOf]
  simp only [runGroup, StateT.run_bind, hrun]
  show Option.bind (some (ss, sh')) _ = _
  simp only [Option.bind_some]
  rw [ite_eq_right hnd, hfl, List.map_cons, show barrierOf t0.status = some (site, d, g) by rw [h0]; rfl]
  simp only [hrest, ite_true]
  rfl

theorem runGroup_done_ofFn {k : Nat} (fuel rounds b : Nat) (simds : List (List Thread)) (U : Fin k → Fin 32 → Thread)
    (sh sh' : Shared)
    (hrun : (simds.mapM (runSimd C fuel rounds)).run sh = some (List.ofFn fun j => List.ofFn (U j), sh'))
    (hd : ∀ j i, (U j i).status = .done) :
    (runGroup C fuel rounds (b + 1) simds).run sh = some ((), sh') :=
  runGroup_done C fuel rounds b simds _ sh sh' hrun (fun lanes hl t ht => by
    obtain ⟨j, rfl⟩ := List.mem_ofFn.mp hl
    obtain ⟨i, rfl⟩ := List.mem_ofFn.mp ht
    exact hd j i)

theorem runGroup_barrier_ofFn {k : Nat} (hk : 0 < k) (fuel rounds b : Nat) (simds : List (List Thread))
    (U : Fin k → Fin 32 → Thread) (sh sh' : Shared) (site : Nat) (d g : Bool)
    (hrun : (simds.mapM (runSimd C fuel rounds)).run sh = some (List.ofFn fun j => List.ofFn (U j), sh'))
    (hb : ∀ j i, (U j i).status = .barrier site d g) :
    (runGroup C fuel rounds (b + 1) simds).run sh =
      (runGroup C fuel rounds b (List.ofFn fun j => List.ofFn fun i => { U j i with status := .running })).run
        (pass d g sh') := by
  rw [runGroup_barrier C fuel rounds b simds _ sh sh' site d g hrun ?_ ?_]
  · simp only [List.map_ofFn]; rfl
  · intro h
    have : U ⟨0, hk⟩ 0 ∈ (List.ofFn fun j => List.ofFn (U j)).flatten :=
      List.mem_flatten.mpr ⟨_, List.mem_ofFn.mpr ⟨⟨0, hk⟩, rfl⟩, List.mem_ofFn.mpr ⟨0, rfl⟩⟩
    rw [h] at this; simp at this
  · intro lanes hl t ht
    obtain ⟨j, rfl⟩ := List.mem_ofFn.mp hl
    obtain ⟨i, rfl⟩ := List.mem_ofFn.mp ht
    exact hb j i

/-- A threadgroup's SIMD-groups run in order, each from an invariant at its index, to `Fin 32`-indexed lanes. -/
theorem simds_spec {k : Nat} (fuel rounds : Nat) (T : Fin k → Fin 32 → Thread) (I : Nat → Shared → Prop)
    (P : Fin k → Fin 32 → Thread → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C fuel rounds (List.ofFn (T j))).run sh = some (List.ofFn V, sh') ∧ I (j + 1) sh' ∧ ∀ i, P j i (V i))
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (U : Fin k → Fin 32 → Thread) (sh' : Shared),
      ((List.ofFn fun j => List.ofFn (T j)).mapM (runSimd C fuel rounds)).run sh =
        some (List.ofFn fun j => List.ofFn (U j), sh') ∧ I k sh' ∧ ∀ j i, P j i (U j i) := by
  obtain ⟨W, sh', hr, hk, hq⟩ := mapM_ofFn_spec (fun j => List.ofFn (T j)) (runSimd C fuel rounds) I
    (fun j u => ∃ V : Fin 32 → Thread, u = List.ofFn V ∧ ∀ i, P j i (V i))
    (fun j sh hj => by obtain ⟨V, sh', hr, hI, hP⟩ := h j sh hj; exact ⟨_, sh', hr, hI, V, rfl, hP⟩) sh h0
  choose U hU using hq
  refine ⟨U, sh', ?_, hk, fun j i => (hU j).2 i⟩
  rw [hr, show W = fun j => List.ofFn (U j) from funext fun j => (hU j).1]

/-- A threadgroup's last phase: every SIMD-group runs to all lanes done. -/
theorem runGroup_done_inv {k : Nat} (fuel rounds b : Nat) (T : Fin k → Fin 32 → Thread) (I : Nat → Shared → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C fuel rounds (List.ofFn (T j))).run sh = some (List.ofFn V, sh') ∧ I (j + 1) sh' ∧
        ∀ i, (V i).status = .done)
    (sh : Shared) (h0 : I 0 sh) :
    ∃ sh', (runGroup C fuel rounds (b + 1) (List.ofFn fun j => List.ofFn (T j))).run sh = some ((), sh') ∧ I k sh' := by
  obtain ⟨U, sh', hr, hk, hd⟩ := simds_spec C fuel rounds T I (fun _ _ t => t.status = .done) h sh h0
  exact ⟨sh', runGroup_done_ofFn C fuel rounds b _ U sh sh' hr hd, hk⟩

/-- A threadgroup's phase up to a barrier: every SIMD-group runs to all lanes at it (with `P`), and the rest of the
run continues from the lanes, running, after the barrier. -/
theorem runGroup_barrier_inv {k : Nat} (hk : 0 < k) (fuel rounds b : Nat) (T : Fin k → Fin 32 → Thread) (site : Nat)
    (d g : Bool) (I : Nat → Shared → Prop) (P : Fin k → Fin 32 → Thread → Prop) (Q : Shared → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C fuel rounds (List.ofFn (T j))).run sh = some (List.ofFn V, sh') ∧ I (j + 1) sh' ∧
        ∀ i, (V i).status = .barrier site d g ∧ P j i (V i))
    (hnext : ∀ (U : Fin k → Fin 32 → Thread) (sh : Shared), (∀ j i, P j i (U j i)) → I k sh → ∃ sh',
      (runGroup C fuel rounds b (List.ofFn fun j => List.ofFn fun i => { U j i with status := .running })).run
        (pass d g sh) = some ((), sh') ∧ Q sh')
    (sh : Shared) (h0 : I 0 sh) :
    ∃ sh', (runGroup C fuel rounds (b + 1) (List.ofFn fun j => List.ofFn (T j))).run sh = some ((), sh') ∧ Q sh' := by
  obtain ⟨U, sh1, hr, hk1, hp⟩ := simds_spec C fuel rounds T I
    (fun j i t => t.status = .barrier site d g ∧ P j i t) h sh h0
  obtain ⟨sh', hr', hq⟩ := hnext U sh1 (fun j i => (hp j i).2) hk1
  refine ⟨sh', ?_, hq⟩
  rw [runGroup_barrier_ofFn C hk fuel rounds b _ U sh sh1 site d g hr (fun j i => (hp j i).1)]
  exact hr'

/-! ## Tiled launches -/

namespace Launch

/-- A thread at the start of `L`'s kernel. -/
def start (L : Launch) (ctx : Ctx) : Thread := { ctx := ctx, locals := fun _ => none, frames := [.block L.kernel.body] }

/-- Thread `l` of threadgroup `(bx, by, bz)`, in a full threadgroup (as `threads` builds it). -/
def ctxAt (L : Launch) (fuse : Nat → Bool) (bx byy bz l : Nat) : Ctx :=
  let (tx, ty, tz) := L.group
  let (gx, gy, gz) := L.groups
  let g := bx + byy * gx + bz * gx * gy
  let t := g * (tx * ty * tz) + l
  { thread := t
    group := g
    coord := fun
      | .threadPositionInGrid => u32x3 (bx * tx + l % tx) (byy * ty + l / tx % ty) (bz * tz + l / (tx * ty))
      | .threadPositionInThreadgroup => u32x3 (l % tx) (l / tx % ty) (l / (tx * ty))
      | .threadgroupPositionInGrid => u32x3 bx byy bz
      | .threadsPerThreadgroup => u32x3 tx ty tz
      | .threadgroupsPerGrid => u32x3 gx gy gz
      | .threadsPerGrid => u32x3 L.grid.1 L.grid.2.1 L.grid.2.2
      | .threadIndexInSimdgroup => u32 (l % 32)
      | .simdgroupIndexInThreadgroup => u32 (l / 32)
      | .threadIndexInThreadgroup => u32 l
      | .simdgroupsPerThreadgroup => u32 (ceilDiv (tx * ty * tz) 32)
      | .threadsPerSimdgroup => u32 32
    threadArray := fun j => L.buffers.length + L.groupArrays + t * L.threadArrays + j
    groupArray := fun j => L.buffers.length + j
    fuse := fuse }

/-- Lane `i` of SIMD-group `s` of threadgroup `(bx, by, bz)`, at the start. -/
def lanes (L : Launch) (fuse : Nat → Bool) (bx byy bz s : Nat) (i : Fin 32) : Thread :=
  L.start (L.ctxAt fuse bx byy bz (32 * s + i))

/-- The threadgroup `(tx, ty, tz)`, of `k` SIMD-groups, tiles the grid with `(gx, gy, gz)` threadgroups. -/
structure Tiles (L : Launch) (tx ty tz gx gy gz k : Nat) : Prop where
  threadgroup : L.threadgroup = (tx, ty, tz)
  grid : L.grid = (gx * tx, gy * ty, gz * tz)
  simds : tx * ty * tz = 32 * k
  pos : 0 < k ∧ 0 < gx ∧ 0 < gy ∧ 0 < gz

theorem le_mul_of_pos {a n : Nat} (h : 0 < n) : a ≤ n * a := by
  rcases n with _ | n
  · omega
  · rw [Nat.succ_mul]; omega

theorem min_sub_mul {t g b : Nat} (h : b < g) : min t (g * t - b * t) = t := by
  rw [← Nat.sub_mul]; exact Nat.min_eq_left (le_mul_of_pos (by omega))

theorem ceilDiv_mul (n : Nat) {t : Nat} (h : 0 < t) : ceilDiv (n * t) t = n := by
  unfold ceilDiv
  rw [show n * t + t - 1 = t - 1 + n * t by omega, Nat.add_mul_div_right _ _ h,
    Nat.div_eq_of_lt (show t - 1 < t by omega)]
  omega

theorem ceilDiv_32 (k : Nat) : ceilDiv (32 * k) 32 = k := by unfold ceilDiv; omega

namespace Tiles
variable {L : Launch} {tx ty tz gx gy gz k : Nat}

theorem dims_pos (h : L.Tiles tx ty tz gx gy gz k) : 0 < tx ∧ 0 < ty ∧ 0 < tz := by
  have hp : 0 < tx * ty * tz := by rw [h.simds]; have := h.pos.1; omega
  refine ⟨Nat.pos_of_ne_zero ?_, Nat.pos_of_ne_zero ?_, Nat.pos_of_ne_zero ?_⟩ <;> rintro rfl <;> simp at hp

theorem group (h : L.Tiles tx ty tz gx gy gz k) : L.group = (tx, ty, tz) := by
  simp only [Launch.group, h.threadgroup, h.grid]
  rw [Nat.min_eq_left (le_mul_of_pos h.pos.2.1), Nat.min_eq_left (le_mul_of_pos h.pos.2.2.1),
    Nat.min_eq_left (le_mul_of_pos h.pos.2.2.2)]

theorem groups (h : L.Tiles tx ty tz gx gy gz k) : L.groups = (gx, gy, gz) := by
  have hd := h.dims_pos
  simp only [Launch.groups, h.group, h.grid]
  rw [ceilDiv_mul _ hd.1, ceilDiv_mul _ hd.2.1, ceilDiv_mul _ hd.2.2]

/-- The threads of an in-range threadgroup. -/
theorem threads (h : L.Tiles tx ty tz gx gy gz k) (fuse : Nat → Bool) {bx byy bz : Nat} (hx : bx < gx)
    (hy : byy < gy) (hz : bz < gz) :
    L.threads fuse bx byy bz = (List.range (32 * k)).map fun l => L.start (L.ctxAt fuse bx byy bz l) := by
  unfold Launch.threads Launch.ctxAt Launch.start
  rw [h.group, h.groups, h.grid]
  dsimp only
  rw [min_sub_mul hx, min_sub_mul hy, min_sub_mul hz, h.simds]
  rfl

theorem threads_length (h : L.Tiles tx ty tz gx gy gz k) (fuse : Nat → Bool) {bx byy bz : Nat} (hx : bx < gx)
    (hy : byy < gy) (hz : bz < gz) : (L.threads fuse bx byy bz).length = 32 * k := by
  rw [h.threads fuse hx hy hz]; simp

theorem thread_get (h : L.Tiles tx ty tz gx gy gz k) (fuse : Nat → Bool) {bx byy bz : Nat} (hx : bx < gx)
    (hy : byy < gy) (hz : bz < gz) (l : Nat) (hl : l < (L.threads fuse bx byy bz).length) :
    (L.threads fuse bx byy bz)[l] = L.start (L.ctxAt fuse bx byy bz l) := by
  simp only [h.threads fuse hx hy hz, List.getElem_map, List.getElem_range]

end Tiles

theorem chunks_range {α : Type} (k : Nat) (f : Nat → α) :
    chunks 32 ((List.range (32 * k)).map f) = List.ofFn fun s : Fin k => List.ofFn fun i : Fin 32 => f (32 * s + i) := by
  apply List.ext_getElem
  · simp [chunks, ceilDiv]; omega
  · intro s h1 h2
    simp only [List.length_ofFn] at h2
    simp only [List.getElem_ofFn]
    apply List.ext_getElem
    · simp [chunks]; omega
    · intro i h3 h4
      simp only [List.length_ofFn] at h4
      simp only [chunks, List.getElem_map, List.getElem_range, List.getElem_take, List.getElem_drop,
        List.getElem_ofFn]
      congr 1; omega

/-- The SIMD-groups of an in-range threadgroup: SIMD-group `s` is threads `32 s + i`. -/
theorem Tiles.chunks {L : Launch} {tx ty tz gx gy gz k : Nat} (h : L.Tiles tx ty tz gx gy gz k) (fuse : Nat → Bool)
    {bx byy bz : Nat} (hx : bx < gx) (hy : byy < gy) (hz : bz < gz) :
    Launch.chunks 32 (L.threads fuse bx byy bz) = List.ofFn fun s : Fin k => List.ofFn (L.lanes fuse bx byy bz s) := by
  rw [h.threads fuse hx hy hz, chunks_range]; rfl

/-! ### Coordinates -/

section
variable (L : Launch) (fuse : Nat → Bool) (bx byy bz l : Nat)

theorem ctxAt_threadIndexInSimdgroup : (L.ctxAt fuse bx byy bz l).coord .threadIndexInSimdgroup = u32 (l % 32) := rfl
theorem ctxAt_simdgroupIndexInThreadgroup :
    (L.ctxAt fuse bx byy bz l).coord .simdgroupIndexInThreadgroup = u32 (l / 32) := rfl
theorem ctxAt_threadIndexInThreadgroup : (L.ctxAt fuse bx byy bz l).coord .threadIndexInThreadgroup = u32 l := rfl
theorem ctxAt_threadgroupPositionInGrid :
    (L.ctxAt fuse bx byy bz l).coord .threadgroupPositionInGrid = u32x3 bx byy bz := rfl
theorem ctxAt_threadsPerSimdgroup : (L.ctxAt fuse bx byy bz l).coord .threadsPerSimdgroup = u32 32 := rfl
theorem ctxAt_threadsPerGrid :
    (L.ctxAt fuse bx byy bz l).coord .threadsPerGrid = u32x3 L.grid.1 L.grid.2.1 L.grid.2.2 := rfl
theorem ctxAt_groupArray (j : Nat) : (L.ctxAt fuse bx byy bz l).groupArray j = L.buffers.length + j := rfl
theorem ctxAt_fuse : (L.ctxAt fuse bx byy bz l).fuse = fuse := rfl

theorem ctxAt_lane (s : Nat) (i : Fin 32) :
    (L.ctxAt fuse bx byy bz (32 * s + i)).coord .threadIndexInSimdgroup = u32 i := by
  rw [ctxAt_threadIndexInSimdgroup, show (32 * s + i.val) % 32 = i.val by omega]

theorem ctxAt_simd (s : Nat) (i : Fin 32) :
    (L.ctxAt fuse bx byy bz (32 * s + i)).coord .simdgroupIndexInThreadgroup = u32 s := by
  rw [ctxAt_simdgroupIndexInThreadgroup, show (32 * s + i.val) / 32 = s by omega]

theorem lanes_ctx (s : Nat) (i : Fin 32) : (L.lanes fuse bx byy bz s i).ctx = L.ctxAt fuse bx byy bz (32 * s + i) := rfl
end

namespace Tiles
variable {L : Launch} {tx ty tz gx gy gz k : Nat} (fuse : Nat → Bool) (bx byy bz l : Nat)

theorem thread (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).thread = (bx + byy * gx + bz * gx * gy) * (32 * k) + l := by
  simp only [Launch.ctxAt, h.group, h.groups, h.simds]

theorem group_id (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).group = bx + byy * gx + bz * gx * gy := by
  simp only [Launch.ctxAt, h.group, h.groups]

theorem threadPositionInGrid (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).coord .threadPositionInGrid =
      u32x3 (bx * tx + l % tx) (byy * ty + l / tx % ty) (bz * tz + l / (tx * ty)) := by
  simp only [Launch.ctxAt, h.group, h.groups]

theorem threadPositionInThreadgroup (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).coord .threadPositionInThreadgroup = u32x3 (l % tx) (l / tx % ty) (l / (tx * ty)) := by
  simp only [Launch.ctxAt, h.group, h.groups]

theorem threadsPerThreadgroup (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).coord .threadsPerThreadgroup = u32x3 tx ty tz := by
  simp only [Launch.ctxAt, h.group, h.groups]

theorem threadgroupsPerGrid (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).coord .threadgroupsPerGrid = u32x3 gx gy gz := by
  simp only [Launch.ctxAt, h.group, h.groups]

theorem threadsPerGrid (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).coord .threadsPerGrid = u32x3 (gx * tx) (gy * ty) (gz * tz) := by
  simp only [ctxAt_threadsPerGrid, h.grid]

theorem simdgroupsPerThreadgroup (h : L.Tiles tx ty tz gx gy gz k) :
    (L.ctxAt fuse bx byy bz l).coord .simdgroupsPerThreadgroup = u32 k := by
  simp only [Launch.ctxAt, h.group, h.groups, h.simds, ceilDiv_32]

theorem threadArray (h : L.Tiles tx ty tz gx gy gz k) (j : Nat) :
    (L.ctxAt fuse bx byy bz l).threadArray j =
      L.buffers.length + L.groupArrays + ((bx + byy * gx + bz * gx * gy) * (32 * k) + l) * L.threadArrays + j := by
  simp only [Launch.ctxAt, h.group, h.groups, h.simds]

end Tiles

/-! ### Regions -/

theorem regions_buffer (L : Launch) (i : Nat) (h : i < L.buffers.length) :
    L.regions i = some ⟨L.buffers[i].space, L.buffers[i].size, L.buffers[i].align⟩ := by
  simp only [regions, dite_eq_left h]

theorem regions_groupArray (L : Launch) (j : Nat) (t : Ty) (n : Nat) (h : L.kernel.threadgroupArrays[j]? = some (t, n)) :
    L.regions (L.buffers.length + j) = some ⟨.threadgroup, t.bytes * n, alignment t⟩ := by
  obtain ⟨hj, -⟩ := List.getElem?_eq_some_iff.mp h
  have hj' : L.buffers.length + j < L.buffers.length + L.groupArrays := by unfold groupArrays; omega
  simp only [regions, dite_eq_right (show ¬ L.buffers.length + j < L.buffers.length by omega), ite_eq_left hj',
    Nat.add_sub_cancel_left, h]
  rfl

theorem regions_threadArray (L : Launch) (th j : Nat) (t : Ty) (n : Nat) (h : L.kernel.threadArrays[j]? = some (t, n)) :
    L.regions (L.buffers.length + L.groupArrays + th * L.threadArrays + j) =
      some ⟨.thread, t.bytes * n, alignment t⟩ := by
  obtain ⟨hj, -⟩ := List.getElem?_eq_some_iff.mp h
  have hj' : j < L.threadArrays := hj
  have hne : L.threadArrays ≠ 0 := by omega
  have hm : (L.buffers.length + L.groupArrays + th * L.threadArrays + j - L.buffers.length - L.groupArrays) %
      L.threadArrays = j := by
    rw [show L.buffers.length + L.groupArrays + th * L.threadArrays + j - L.buffers.length - L.groupArrays =
      j + th * L.threadArrays by omega, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hj']
  have h1 : ¬ L.buffers.length + L.groupArrays + th * L.threadArrays + j < L.buffers.length := by omega
  have h2 : ¬ L.buffers.length + L.groupArrays + th * L.threadArrays + j < L.buffers.length + L.groupArrays := by omega
  simp only [regions, dite_eq_right h1, ite_eq_right h2, ite_eq_right hne, hm, h]
  rfl

theorem initial_buffer (L : Launch) (garbage : Garbage) (i : Nat) (h : i < L.buffers.length) :
    (L.initial garbage).bytes i = L.buffers[i].bytes := by
  simp only [initial, dite_eq_left h]

theorem initial_groupArray (L : Launch) (garbage : Garbage) (j : Nat) (h : j < L.groupArrays) :
    (L.initial garbage).bytes (L.buffers.length + j) = garbage.group 0 j := by
  simp only [initial, dite_eq_right (show ¬ L.buffers.length + j < L.buffers.length by omega),
    ite_eq_left (show L.buffers.length + j < L.buffers.length + L.groupArrays by omega), Nat.add_sub_cancel_left]

theorem resetGroup_buffer (L : Launch) (garbage : Garbage) (g : Nat) (bytes : Nat → ByteMemory.Bytes) (region : Nat)
    (h : region < L.buffers.length) : L.resetGroup garbage g bytes region = bytes region := by
  have h1 : ¬ (L.buffers.length ≤ region ∧ region < L.buffers.length + L.groupArrays) := by omega
  simp only [resetGroup, ite_eq_right h1]

theorem resetGroup_groupArray (L : Launch) (garbage : Garbage) (g : Nat) (bytes : Nat → ByteMemory.Bytes) (j : Nat)
    (h : j < L.groupArrays) : L.resetGroup garbage g bytes (L.buffers.length + j) = garbage.group g j := by
  simp only [resetGroup, ite_eq_left (show L.buffers.length ≤ L.buffers.length + j ∧
    L.buffers.length + j < L.buffers.length + L.groupArrays by omega), Nat.add_sub_cancel_left]

theorem resetGroup_none (L : Launch) (garbage : Garbage) (g : Nat) (bytes : Nat → ByteMemory.Bytes)
    (h : L.groupArrays = 0) : L.resetGroup garbage g bytes = bytes := by
  funext region
  unfold resetGroup
  rw [h, Nat.add_zero, ite_eq_right (show ¬ (L.buffers.length ≤ region ∧ region < L.buffers.length) by omega)]

end Launch

/-! ## Running a tiled launch -/

theorem group_index (gx gy g : Nat) : g % gx + g / gx % gy * gx + g / (gx * gy) * gx * gy = g := by
  conv_rhs => rw [← Nat.mod_add_div g gx, ← Nat.mod_add_div (g / gx) gy, Nat.div_div_eq_div_mul]
  ring

/-- **A tiled launch runs threadgroup by threadgroup.** An invariant at each threadgroup's linear index that
every threadgroup's run (after its threadgroup arrays are reset) carries to the next index holds at the end. -/
theorem Launch.Tiles.launch_run {L : Launch} {tx ty tz gx gy gz k : Nat} (h : L.Tiles tx ty tz gx gy gz k)
    (fuse : Nat → Bool) (garbage : Garbage) (fuel rounds barriers : Nat) (I : Nat → Shared → Prop)
    (h0 : I 0 (L.initial garbage))
    (hg : ∀ bx byy bz, bx < gx → byy < gy → bz < gz → ∀ sh, I (bx + byy * gx + bz * gx * gy) sh → ∃ sh',
      (runGroup C fuel rounds barriers (List.ofFn fun s : Fin k => List.ofFn (L.lanes fuse bx byy bz s))).run
        { sh with bytes := L.resetGroup garbage (bx + byy * gx + bz * gx * gy) sh.bytes } = some ((), sh') ∧
        I (bx + byy * gx + bz * gx * gy + 1) sh') :
    ∃ sh, I (gx * gy * gz) sh ∧ runLaunch C fuse L garbage fuel rounds barriers = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨-, hx, hy, hz⟩ := h.pos
  simp only [runLaunch, h.groups]
  obtain ⟨sh', hrun, hI⟩ := forM_inv (fun x : Nat × Nat × Nat => (do
      modify fun (sh : Shared) => { sh with bytes := L.resetGroup garbage (x.1 + x.2.1 * gx + x.2.2 * gx * gy) sh.bytes }
      runGroup C fuel rounds barriers (Launch.chunks 32 (L.threads fuse x.1 x.2.1 x.2.2)) : M Unit))
    I ((List.range (gx * gy * gz)).map fun g => (g % gx, g / gx % gy, g / (gx * gy))) 0 (fun j hj sh hI => by
      simp only [List.length_map, List.length_range] at hj
      simp only [List.getElem_map, List.getElem_range, Nat.zero_add] at hI ⊢
      have hb := group_index gx gy j
      have bx : j % gx < gx := Nat.mod_lt _ hx
      have byy : j / gx % gy < gy := Nat.mod_lt _ hy
      have bz : j / (gx * gy) < gz := (Nat.div_lt_iff_lt_mul (Nat.mul_pos hx hy)).mpr
        (by rw [Nat.mul_comm gz]; exact hj)
      rw [h.chunks fuse bx byy bz]
      obtain ⟨sh2, h2, hI2⟩ := hg _ _ _ bx byy bz sh (by rw [hb]; exact hI)
      refine ⟨sh2, ?_, by rw [hb] at hI2; exact hI2⟩
      simp only [StateT.run_bind]
      exact h2) (L.initial garbage) h0
  refine ⟨sh', by simpa using hI, ?_⟩
  rw [hrun]
  rfl

/-! ## Race freedom -/

/-- Whether a region is threadgroup memory (`Conflict`'s case split). -/
def isGroup : Option Region → Bool
  | some ⟨.threadgroup, _, _⟩ => true
  | _ => false

theorem isGroup_some (r : Region) : isGroup (some r) = decide (r.space = .threadgroup) := by
  obtain ⟨sp, _, _⟩ := r; cases sp <;> rfl

/-- The writer of a device byte: thread `thread` of threadgroup `group`, in device epochs up to `epoch`. -/
structure Writer where
  thread : Nat
  group : Nat
  epoch : Nat

/-- An access keeps an ownership discipline. Threadgroup memory: in each barrier epoch of each threadgroup, a
byte that `tg group epoch region byte` gives a thread is accessed by that thread only, any other byte only read.
Device memory: a byte that `dev region byte` gives a writer is written by it only, and accessed by other threads
only from its threadgroup in a later device epoch; any other byte is only read. -/
def Owned (L : Launch) (dev : Nat → Nat → Option Writer) (tg : Nat → Nat → Nat → Nat → Option Nat) (a : Access) :
    Prop :=
  if isGroup (L.regions a.region) then
    match tg a.group a.groupEpoch a.region a.byte with
    | some o => a.thread = o
    | none => a.write = false
  else
    match dev a.region a.byte with
    | some o => if a.thread = o.thread then (a.write = true → a.group = o.group ∧ a.deviceEpoch ≤ o.epoch)
      else a.write = false ∧ a.group = o.group ∧ o.epoch < a.deviceEpoch
    | none => a.write = false

theorem conflict_split (L : Launch) (a b : Access) (h : Conflict L a b) :
    a.region = b.region ∧ a.byte = b.byte ∧ a.thread ≠ b.thread ∧ (a.write = true ∨ b.write = true) ∧
      if isGroup (L.regions a.region) then a.group = b.group ∧ a.groupEpoch = b.groupEpoch
      else a.group ≠ b.group ∨ a.deviceEpoch = b.deviceEpoch := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := h
  refine ⟨h1, h2, h3, h4, ?_⟩
  revert h5
  cases L.regions a.region with
  | none => exact id
  | some R => obtain ⟨sp, _, _⟩ := R; cases sp <;> exact id

/-- **Race freedom from ownership.** -/
theorem raceFree_of_owned (L : Launch) (dev : Nat → Nat → Option Writer) (tg : Nat → Nat → Nat → Nat → Option Nat)
    (r : Result) (h : ∀ a ∈ r.log, Owned L dev tg a) : RaceFree L r := by
  intro a ha b hb hc
  obtain ⟨hreg, hbyte, hthr, hw, hm⟩ := conflict_split L a b hc
  have ga := h a ha
  have gb := h b hb
  unfold Owned at ga gb
  rw [← hreg, ← hbyte] at gb
  by_cases hG : isGroup (L.regions a.region) = true
  · rw [ite_eq_left hG] at ga gb hm
    obtain ⟨hgr, hep⟩ := hm
    rw [← hgr, ← hep] at gb
    revert ga gb
    cases tg a.group a.groupEpoch a.region a.byte with
    | none => intro ga gb; dsimp only at ga gb; rcases hw with hw | hw <;> simp_all
    | some o => intro ga gb; dsimp only at ga gb; exact hthr (ga.trans gb.symm)
  · rw [ite_eq_right hG] at ga gb hm
    revert ga gb
    cases dev a.region a.byte with
    | none => intro ga gb; dsimp only at ga gb; rcases hw with hw | hw <;> simp_all
    | some o =>
      intro ga gb
      dsimp only at ga gb
      by_cases ta : a.thread = o.thread <;> by_cases tb : b.thread = o.thread
      · exact hthr (ta.trans tb.symm)
      · rw [ite_eq_left ta] at ga; rw [ite_eq_right tb] at gb
        obtain ⟨wb, gb1, eb⟩ := gb
        have wa : a.write = true := by rcases hw with hw | hw; exact hw; simp [wb] at hw
        obtain ⟨ga1, ea⟩ := ga wa
        rcases hm with hm | hm
        · exact hm (ga1.trans gb1.symm)
        · omega
      · rw [ite_eq_right ta] at ga; rw [ite_eq_left tb] at gb
        obtain ⟨wa, ga1, ea⟩ := ga
        have wb : b.write = true := by rcases hw with hw | hw; simp [wa] at hw; exact hw
        obtain ⟨gb1, eb⟩ := gb wb
        rcases hm with hm | hm
        · exact hm (ga1.trans gb1.symm)
        · omega
      · rw [ite_eq_right ta] at ga; rw [ite_eq_right tb] at gb
        rcases hw with hw | hw
        · simp [ga.1] at hw
        · simp [gb.1] at hw

/-- A fact about every log entry survives a load's or a store's entries (`loadAt_run`, `storeAt_run`). -/
theorem forall_log {P : Access → Prop} (f : Nat → Access) (n : Nat) (log : List Access) (hf : ∀ i < n, P (f i))
    (hl : ∀ a ∈ log, P a) : ∀ a ∈ ((List.range n).map f).reverse ++ log, P a := by
  intro a ha
  simp only [List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at ha
  rcases ha with ⟨i, hi, rfl⟩ | ha
  · exact hf i hi
  · exact hl a ha

section
variable (L : Launch) (dev : Nat → Nat → Option Writer) (tg : Nat → Nat → Nat → Nat → Option Nat) (ctx : Ctx)
  (sh : Shared) (region byte : Nat) (r : Region) (hr : L.regions region = some r)
include hr

/-- An access to a threadgroup byte by its owner in the current epoch. -/
theorem owned_group (w : Bool) (hs : r.space = .threadgroup)
    (ho : tg ctx.group sh.groupEpoch region byte = some ctx.thread) : Owned L dev tg (entry ctx sh region byte w) := by
  simp [Owned, entry, hr, isGroup_some, hs, ho]

/-- A read of a threadgroup byte nobody owns in the current epoch. -/
theorem owned_group_read (hs : r.space = .threadgroup) (ho : tg ctx.group sh.groupEpoch region byte = none) :
    Owned L dev tg (entry ctx sh region byte false) := by
  simp [Owned, entry, hr, isGroup_some, hs, ho]

/-- An access to a device byte by its writer, within its epochs. -/
theorem owned_device (w : Bool) (hs : r.space ≠ .threadgroup) (o : Writer) (ho : dev region byte = some o)
    (ht : ctx.thread = o.thread) (hg : ctx.group = o.group) (he : sh.deviceEpoch ≤ o.epoch) :
    Owned L dev tg (entry ctx sh region byte w) := by
  simp [Owned, entry, hr, isGroup_some, hs, ho, ht, hg, he]

/-- A read of a device byte by its writer. -/
theorem owned_device_own (hs : r.space ≠ .threadgroup) (o : Writer) (ho : dev region byte = some o)
    (ht : ctx.thread = o.thread) : Owned L dev tg (entry ctx sh region byte false) := by
  simp [Owned, entry, hr, isGroup_some, hs, ho, ht]

/-- A read of a device byte from its writer's threadgroup after its epochs. -/
theorem owned_device_later (hs : r.space ≠ .threadgroup) (o : Writer) (ho : dev region byte = some o)
    (hg : ctx.group = o.group) (he : o.epoch < sh.deviceEpoch) : Owned L dev tg (entry ctx sh region byte false) := by
  by_cases ht : ctx.thread = o.thread <;> simp [Owned, entry, hr, isGroup_some, hs, ho, ht, hg, he]

/-- A read of a device byte nobody writes. -/
theorem owned_device_read (hs : r.space ≠ .threadgroup) (ho : dev region byte = none) :
    Owned L dev tg (entry ctx sh region byte false) := by
  simp [Owned, entry, hr, isGroup_some, hs, ho]
end

/-! ## The GPU's outputs -/

/-- Output contents `f i` of each output `i`, within its size. -/
def clip (sizes : List Nat) (f : Nat → ByteMemory.Bytes) : List ByteMemory.Bytes :=
  sizes.zipIdx.map fun (size, i) b => if b < size then f i b else 0

theorem outputs_eq (r : Result) (n : Nat) (sizes : List Nat) (f : Nat → ByteMemory.Bytes)
    (h : ∀ i (hi : i < sizes.length), ∀ b < sizes[i], r.buffers (n + i) b = f i b) :
    outputs r n sizes = clip sizes f := by
  unfold outputs clip
  apply List.ext_getElem
  · simp
  · intro i h1 h2
    simp only [List.length_map, List.length_zipIdx] at h1
    simp only [List.getElem_map, List.getElem_zipIdx, Nat.zero_add]
    funext b
    by_cases hb : b < sizes[i]
    · simp only [ite_eq_left hb]; exact h i h1 b hb
    · simp only [ite_eq_right hb]

section
variable {inputs : List Buffer} {sizes : List Nat} {align : Nat} {initial : Nat → ByteMemory.Bytes} {L : Launch}

theorem buffers_length : (buffers inputs sizes align initial).length = inputs.length + sizes.length := by
  simp [buffers]

theorem regions_input (hb : L.buffers = buffers inputs sizes align initial) (i : Nat) (h : i < inputs.length) :
    L.regions i = some ⟨inputs[i].space, inputs[i].size, inputs[i].align⟩ := by
  have hl : i < L.buffers.length := by rw [hb, buffers_length]; omega
  rw [Launch.regions_buffer L i hl]
  simp only [hb, buffers, List.getElem_append_left h]

theorem regions_output (hb : L.buffers = buffers inputs sizes align initial) (j : Nat) (h : j < sizes.length) :
    L.regions (inputs.length + j) = some ⟨.device, sizes[j], align⟩ := by
  have hl : inputs.length + j < L.buffers.length := by rw [hb, buffers_length]; omega
  rw [Launch.regions_buffer L _ hl]
  simp [hb, buffers, List.getElem_append_right]

theorem initial_input (hb : L.buffers = buffers inputs sizes align initial) (garbage : Garbage) (i : Nat)
    (h : i < inputs.length) : (L.initial garbage).bytes i = inputs[i].bytes := by
  have hl : i < L.buffers.length := by rw [hb, buffers_length]; omega
  rw [Launch.initial_buffer L garbage i hl]
  simp only [hb, buffers, List.getElem_append_left h]

theorem initial_output (hb : L.buffers = buffers inputs sizes align initial) (garbage : Garbage) (j : Nat)
    (h : j < sizes.length) : (L.initial garbage).bytes (inputs.length + j) = initial j := by
  have hl : inputs.length + j < L.buffers.length := by rw [hb, buffers_length]; omega
  rw [Launch.initial_buffer L garbage _ hl]
  simp [hb, buffers, List.getElem_append_right]
end

/-- **The GPU produces a modeled launch's outputs.** If for every initial content of the output buffers and every
garbage the model's run completes race-free with outputs `f` (independent of both), the GPU returns them. -/
theorem gpu_execute (G : Gpu C) {text : List Char} {kernel : Kernel} {grid tg : Nat × Nat × Nat}
    {inputs : List Buffer} {sizes : List Nat} (f : Nat → ByteMemory.Bytes)
    (hc : compile text = some kernel) (hmax : tg.1 * tg.2.1 * tg.2.2 ≤ G.maxThreads text)
    (h : ∀ (initial : Nat → ByteMemory.Bytes) (garbage : Garbage), ∃ fuel rounds barriers r,
      runLaunch C (G.fusion text) ⟨kernel, grid, tg, buffers inputs sizes 16 initial⟩ garbage fuel rounds barriers =
        some r ∧ RaceFree ⟨kernel, grid, tg, buffers inputs sizes 16 initial⟩ r ∧
      ∀ i (hi : i < sizes.length), ∀ b < sizes[i], r.buffers (inputs.length + i) b = f i b) :
    G.execute text grid tg inputs sizes = some (clip sizes f) := by
  apply G.runs_as_modeled_outputs _ kernel _ _ _ _ _ hc hmax
  intro initial garbage
  obtain ⟨fuel, rounds, barriers, r, hr, hrf, hout⟩ := h initial garbage
  exact ⟨fuel, rounds, barriers, r, hr, hrf, outputs_eq r _ sizes f hout⟩

/-- `gpu_execute` from a run's final state (`Launch.Tiles.launch_run`) whose log keeps an ownership discipline. -/
theorem gpu_owned (G : Gpu C) {text : List Char} {kernel : Kernel} {grid tg : Nat × Nat × Nat}
    {inputs : List Buffer} {sizes : List Nat} (f : Nat → ByteMemory.Bytes)
    (hc : compile text = some kernel) (hmax : tg.1 * tg.2.1 * tg.2.2 ≤ G.maxThreads text)
    (h : ∀ (initial : Nat → ByteMemory.Bytes) (garbage : Garbage), ∃ (fuel rounds barriers : Nat) (sh : Shared) (dev : Nat → Nat → Option Writer)
      (tgo : Nat → Nat → Nat → Nat → Option Nat),
      runLaunch C (G.fusion text) ⟨kernel, grid, tg, buffers inputs sizes 16 initial⟩ garbage fuel rounds barriers =
        some ⟨sh.bytes, sh.log⟩ ∧
      (∀ a ∈ sh.log, Owned ⟨kernel, grid, tg, buffers inputs sizes 16 initial⟩ dev tgo a) ∧
      ∀ i (hi : i < sizes.length), ∀ b < sizes[i], sh.bytes (inputs.length + i) b = f i b) :
    G.execute text grid tg inputs sizes = some (clip sizes f) := by
  apply gpu_execute C G f hc hmax
  intro initial garbage
  obtain ⟨fuel, rounds, barriers, sh, dev, tgo, hr, ho, hout⟩ := h initial garbage
  exact ⟨fuel, rounds, barriers, _, hr, raceFree_of_owned _ dev tgo _ ho, hout⟩

end Metal
