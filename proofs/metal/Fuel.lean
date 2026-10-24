import metal.Group
import metal.Steps

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Fuel chosen after the state

The library's SIMD-group, threadgroup and launch lemmas (Group.lean) take one fixed fuel. A kernel proof
finds each lane's, SIMD-group's and threadgroup's run within fuel that may depend on the memory it starts
from; monotonicity in fuel (`runThread_mono`, …) then gives one bound for all. Three equivalent forms:
`Ev` (a property of every large enough fuel), an explicit bound valid above (`_bound`), and a launch with
an existential fuel (`launch_run_fuel`). Also the GPU's contents of a set of buffers and launches of
threadgroups along x (`Launch.Strip`). -/


/-! ## Eventually in fuel -/

section Ev
/-- `P m` holds for every large enough `m`: a bound on fuel, chosen after the state a run starts from. -/
def Ev (P : Nat → Prop) : Prop := ∃ n, ∀ m, n ≤ m → P m

theorem Ev.and {P Q : Nat → Prop} (hp : Ev P) (hq : Ev Q) : Ev fun m => P m ∧ Q m := by
  obtain ⟨a, ha⟩ := hp
  obtain ⟨b, hb⟩ := hq
  exact ⟨max a b, fun m hm => ⟨ha m (le_trans (le_max_left a b) hm), hb m (le_trans (le_max_right a b) hm)⟩⟩

theorem Ev.mono {P Q : Nat → Prop} (hp : Ev P) (h : ∀ m, P m → Q m) : Ev Q := by
  obtain ⟨a, ha⟩ := hp
  exact ⟨a, fun m hm => h m (ha m hm)⟩

theorem Ev.const {P : Prop} (h : P) : Ev fun _ => P := ⟨0, fun _ _ => h⟩

/-- A run that reaches `t₂` keeps every eventual result of `t₂`. -/
theorem Reaches.ev {C : M1Max.Contract} {t₁ t₂ : Thread} {sh₁ sh₂ : Shared} {r : Thread × Shared}
    (h : Reaches C t₁ sh₁ t₂ sh₂) (h2 : Ev fun m => (runThread C m t₂).run sh₂ = some r) :
    Ev fun m => (runThread C m t₁).run sh₁ = some r := by
  obtain ⟨n, hn⟩ := h.fuel
  obtain ⟨b, hb⟩ := h2
  refine ⟨n + b, fun m hm => ?_⟩
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hm
  rw [show n + b + k = n + (b + k) by omega, hn]
  exact hb _ (by omega)

/-- A run that reaches a stopped thread gives it at every large enough fuel. -/
theorem Reaches.ev_stop {C : M1Max.Contract} {t₁ t₂ : Thread} {sh₁ sh₂ : Shared} (h : Reaches C t₁ sh₁ t₂ sh₂)
    (hs : isRunning t₂.status = false) : Ev fun m => (runThread C m t₁).run sh₁ = some (t₂, sh₂) :=
  h.run hs

variable (C : M1Max.Contract)

/-- `mapM_ofFn_spec` with eventual fuel. -/
theorem mapM_ofFn_ev {α β : Type} : ∀ {n : Nat} (T : Fin n → α) (f : Nat → α → M β) (I : Nat → Shared → Prop)
    (Q : Fin n → β → Prop),
    (∀ i : Fin n, ∀ sh, I i sh → ∃ u sh', (Ev fun m => (f m (T i)).run sh = some (u, sh')) ∧ I (i + 1) sh' ∧ Q i u) →
    ∀ sh, I 0 sh → ∃ (U : Fin n → β) (sh' : Shared),
      (Ev fun m => ((List.ofFn T).mapM (f m)).run sh = some (List.ofFn U, sh')) ∧ I n sh' ∧ ∀ i, Q i (U i)
  | 0, _, _, _, _, _, sh, h0 => ⟨Fin.elim0, sh, Ev.const rfl, h0, fun i => i.elim0⟩
  | n + 1, T, f, I, Q, h, sh, h0 => by
    obtain ⟨u, sh1, hr, h1, hq⟩ := h 0 sh h0
    obtain ⟨U, sh', hr', hn, hqs⟩ := mapM_ofFn_ev (fun i : Fin n => T i.succ) f (fun j => I (j + 1))
      (fun i => Q i.succ) (fun i sh hi => by simpa [Nat.add_assoc] using h i.succ sh hi) sh1 h1
    refine ⟨Fin.cons u U, sh', (hr.and hr').mono fun m hm => ?_, hn, fun i => ?_⟩
    · obtain ⟨e1, e2⟩ := hm
      rw [ofFn_cons, List.ofFn_succ, List.mapM_cons]
      simp only [StateT.run_bind] at e2 ⊢
      rw [e1]
      simp only [Option.bind_eq_bind, Option.bind_some]
      rw [e2]
      rfl
    · cases i using Fin.cases with
      | zero => simpa using hq
      | succ i => simpa using hqs i

/-- `runSimd_collective_inv` with eventual fuel. -/
theorem runSimd_collective_ev (r : Nat) (T : Fin 32 → Thread) (site slot : Nat) (op : Collective) (s : Scalar)
    (d : Nat) (x y : Fin 32 → Val) (hres : resolve C op s d (List.ofFn x) = some (List.ofFn y))
    (I : Nat → Shared → Prop) (P : Fin 32 → Thread → Prop) (J : Shared → Prop) (R : Fin 32 → Thread → Prop)
    (h : ∀ i : Fin 32, ∀ sh, I i sh → ∃ t sh', (Ev fun m => (runThread C m (T i)).run sh = some (t, sh')) ∧
      I (i + 1) sh' ∧ t.status = .collective site slot op s (x i) d ∧ P i t)
    (hnext : ∀ (U : Fin 32 → Thread) (sh : Shared), (∀ i, P i (U i)) → I 32 sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m r (List.ofFn fun i => { U i with status := .running }.set slot (y i))).run sh =
        some (List.ofFn V, sh')) ∧ J sh' ∧ ∀ i, R i (V i))
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (r + 1) (List.ofFn T)).run sh = some (List.ofFn V, sh')) ∧ J sh' ∧ ∀ i, R i (V i) := by
  obtain ⟨U, sh1, hrun, hI, hq⟩ := mapM_ofFn_ev T (runThread C) I
    (fun i t => t.status = .collective site slot op s (x i) d ∧ P i t) h sh h0
  obtain ⟨V, sh', hV, hJ, hR⟩ := hnext U sh1 (fun i => (hq i).2) hI
  refine ⟨V, sh', (hrun.and hV).mono fun m hm => ?_, hJ, hR⟩
  rw [runSimd_collective_ofFn C m r _ U sh sh1 site slot op s d x y hm.1 (fun i => (hq i).1) hres]
  exact hm.2

/-- `runSimd_blocked_inv` with eventual fuel. -/
theorem runSimd_blocked_ev (r : Nat) (T : Fin 32 → Thread) (I : Nat → Shared → Prop) (R : Fin 32 → Thread → Prop)
    (h : ∀ i : Fin 32, ∀ sh, I i sh → ∃ t sh', (Ev fun m => (runThread C m (T i)).run sh = some (t, sh')) ∧
      I (i + 1) sh' ∧ blocked t.status = true ∧ R i t)
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (r + 1) (List.ofFn T)).run sh = some (List.ofFn V, sh')) ∧ I 32 sh' ∧ ∀ i, R i (V i) := by
  obtain ⟨V, sh', hrun, hI, hq⟩ := mapM_ofFn_ev T (runThread C) I (fun i t => blocked t.status = true ∧ R i t) h sh h0
  exact ⟨V, sh', hrun.mono fun m hm => runSimd_blocked_ofFn C m r _ V sh sh' hm (fun i => (hq i).1), hI,
    fun i => (hq i).2⟩

/-- `simds_spec` with eventual fuel. -/
theorem simds_ev {k : Nat} (rounds : Nat) (T : Fin k → Fin 32 → Thread) (I : Nat → Shared → Prop)
    (P : Fin k → Fin 32 → Thread → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m rounds (List.ofFn (T j))).run sh = some (List.ofFn V, sh')) ∧ I (j + 1) sh' ∧
        ∀ i, P j i (V i))
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (U : Fin k → Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => ((List.ofFn fun j => List.ofFn (T j)).mapM (runSimd C m rounds)).run sh =
        some (List.ofFn fun j => List.ofFn (U j), sh')) ∧ I k sh' ∧ ∀ j i, P j i (U j i) := by
  obtain ⟨W, sh', hr, hk, hq⟩ := mapM_ofFn_ev (fun j => List.ofFn (T j)) (fun m => runSimd C m rounds) I
    (fun j u => ∃ V : Fin 32 → Thread, u = List.ofFn V ∧ ∀ i, P j i (V i))
    (fun j sh hj => by obtain ⟨V, sh', hr, hI, hP⟩ := h j sh hj; exact ⟨_, sh', hr, hI, V, rfl, hP⟩) sh h0
  choose U hU using hq
  refine ⟨U, sh', hr.mono fun m hm => ?_, hk, fun j i => (hU j).2 i⟩
  rw [hm, show W = fun j => List.ofFn (U j) from funext fun j => (hU j).1]

/-- `runGroup_done_inv` with eventual fuel. -/
theorem runGroup_done_ev {k : Nat} (rounds b : Nat) (T : Fin k → Fin 32 → Thread) (I : Nat → Shared → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m rounds (List.ofFn (T j))).run sh = some (List.ofFn V, sh')) ∧ I (j + 1) sh' ∧
        ∀ i, (V i).status = .done)
    (sh : Shared) (h0 : I 0 sh) :
    ∃ sh', (Ev fun m => (runGroup C m rounds (b + 1) (List.ofFn fun j => List.ofFn (T j))).run sh = some ((), sh')) ∧
      I k sh' := by
  obtain ⟨U, sh', hr, hk, hd⟩ := simds_ev C rounds T I (fun _ _ t => t.status = .done) h sh h0
  exact ⟨sh', hr.mono fun m hm => runGroup_done_ofFn C m rounds b _ U sh sh' hm hd, hk⟩

/-- `runGroup_barrier_inv` with eventual fuel. -/
theorem runGroup_barrier_ev {k : Nat} (hk : 0 < k) (rounds b : Nat) (T : Fin k → Fin 32 → Thread) (site : Nat)
    (d g : Bool) (I : Nat → Shared → Prop) (P : Fin k → Fin 32 → Thread → Prop) (Q : Shared → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m rounds (List.ofFn (T j))).run sh = some (List.ofFn V, sh')) ∧ I (j + 1) sh' ∧
        ∀ i, (V i).status = .barrier site d g ∧ P j i (V i))
    (hnext : ∀ (U : Fin k → Fin 32 → Thread) (sh : Shared), (∀ j i, P j i (U j i)) → I k sh → ∃ sh',
      (Ev fun m => (runGroup C m rounds b (List.ofFn fun j => List.ofFn fun i => { U j i with status := .running })).run
        (pass d g sh) = some ((), sh')) ∧ Q sh')
    (sh : Shared) (h0 : I 0 sh) :
    ∃ sh', (Ev fun m => (runGroup C m rounds (b + 1) (List.ofFn fun j => List.ofFn (T j))).run sh = some ((), sh')) ∧
      Q sh' := by
  obtain ⟨U, sh1, hr, hk1, hp⟩ := simds_ev C rounds T I (fun j i t => t.status = .barrier site d g ∧ P j i t) h sh h0
  obtain ⟨sh', hr', hq⟩ := hnext U sh1 (fun j i => (hp j i).2) hk1
  refine ⟨sh', (hr.and hr').mono fun m hm => ?_, hq⟩
  rw [runGroup_barrier_ofFn C hk m rounds b _ U sh sh1 site d g hm.1 (fun j i => (hp j i).1)]
  exact hm.2

/-- `forM_inv` with eventual fuel. -/
theorem forM_ev {α : Type} (f : Nat → α → M Unit) (I : Nat → Shared → Prop) :
    ∀ (xs : List α) (k : Nat), (∀ i (hi : i < xs.length), ∀ sh, I (k + i) sh →
      ∃ sh', (Ev fun m => (f m xs[i]).run sh = some ((), sh')) ∧ I (k + i + 1) sh') →
    ∀ sh, I k sh → ∃ sh', (Ev fun m => (xs.forM (f m)).run sh = some ((), sh')) ∧ I (k + xs.length) sh'
  | [], k, _, sh, h0 => ⟨sh, Ev.const rfl, by simpa using h0⟩
  | x :: xs, k, h, sh, h0 => by
    obtain ⟨sh1, hr, h1⟩ := h 0 (by simp) sh (by simpa using h0)
    obtain ⟨sh', hr', hn⟩ := forM_ev f I xs (k + 1) (fun i hi sh hi' => by
      have := h (i + 1) (by simp; omega) sh (by simpa [Nat.add_assoc, Nat.add_comm 1] using hi')
      simpa [Nat.add_assoc, Nat.add_comm 1] using this) sh1 h1
    refine ⟨sh', (hr.and hr').mono fun m hm => ?_, by simpa [Nat.add_assoc, Nat.add_comm 1] using hn⟩
    have hr0 : (f m x).run sh = some ((), sh1) := hm.1
    show (f m x >>= fun _ => xs.forM (f m)).run sh = _
    rw [StateT.run_bind, hr0]
    exact hm.2

/-- `Launch.Tiles.launch_run` with eventual fuel: each threadgroup's run from the state the previous ones leave. -/
theorem Launch.Tiles.launch_run_ev {L : Launch} {tx ty tz gx gy gz k : Nat} (h : L.Tiles tx ty tz gx gy gz k)
    (fuse : Nat → Bool) (garbage : Garbage) (rounds barriers : Nat) (I : Nat → Shared → Prop)
    (h0 : I 0 (L.initial garbage))
    (hg : ∀ bx byy bz, bx < gx → byy < gy → bz < gz → ∀ sh, I (bx + byy * gx + bz * gx * gy) sh → ∃ sh',
      (Ev fun m => (runGroup C m rounds barriers (List.ofFn fun s : Fin k => List.ofFn (L.lanes fuse bx byy bz s))).run
        { sh with bytes := L.resetGroup garbage (bx + byy * gx + bz * gx * gy) sh.bytes } = some ((), sh')) ∧
        I (bx + byy * gx + bz * gx * gy + 1) sh') :
    ∃ sh, I (gx * gy * gz) sh ∧ Ev fun m => runLaunch C fuse L garbage m rounds barriers = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨-, hx, hy, hz⟩ := h.pos
  obtain ⟨sh', hrun, hI⟩ := forM_ev (fun m (x : Nat × Nat × Nat) => (do
      modify fun (sh : Shared) => { sh with bytes := L.resetGroup garbage (x.1 + x.2.1 * gx + x.2.2 * gx * gy) sh.bytes }
      runGroup C m rounds barriers (Launch.chunks 32 (L.threads fuse x.1 x.2.1 x.2.2)) : M Unit))
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
      refine ⟨sh2, h2.mono fun m hm => ?_, by rw [hb] at hI2; exact hI2⟩
      simp only [StateT.run_bind]
      exact hm) (L.initial garbage) h0
  refine ⟨sh', by simpa using hI, hrun.mono fun m hm => ?_⟩
  simp only [runLaunch, h.groups]
  rw [hm]
  rfl

end Ev

/-! ## Explicit bounds -/

section Bound
variable (C : M1Max.Contract)

/-- Lanes run in order from an invariant at their index, each within its own fuel: one fuel serves all. -/
theorem lanes_bound : ∀ {n : Nat} (T : Fin n → Thread) (I : Nat → Shared → Prop) (Q : Fin n → Thread → Prop),
    (∀ i : Fin n, ∀ sh, I i sh → ∃ f t sh', (runThread C f (T i)).run sh = some (t, sh') ∧ I (i + 1) sh' ∧ Q i t) →
    ∀ sh, I 0 sh → ∃ (f : Nat) (U : Fin n → Thread) (sh' : Shared),
      (∀ m, f ≤ m → ((List.ofFn T).mapM (runThread C m)).run sh = some (List.ofFn U, sh')) ∧ I n sh' ∧
        ∀ i, Q i (U i)
  | 0, _, _, _, _, sh, h0 => ⟨0, Fin.elim0, sh, fun _ _ => rfl, h0, fun i => i.elim0⟩
  | n + 1, T, I, Q, h, sh, h0 => by
    obtain ⟨f0, u, sh1, hr, h1, hq⟩ := h 0 sh h0
    obtain ⟨f1, U, sh', hr', hn, hqs⟩ := lanes_bound (fun i : Fin n => T i.succ) (fun j => I (j + 1))
      (fun i => Q i.succ) (fun i sh hi => by simpa [Nat.add_assoc] using h i.succ sh hi) sh1 h1
    refine ⟨max f0 f1, Fin.cons u U, sh', fun m hm => ?_, hn, fun i => ?_⟩
    · have e0 := runThread_mono C (le_trans (le_max_left f0 f1) hm) (T 0) hr
      have e1 := hr' m (le_trans (le_max_right f0 f1) hm)
      rw [ofFn_cons, List.ofFn_succ, List.mapM_cons]
      simp only [StateT.run_bind] at e1 ⊢
      rw [e0]
      simp only [Option.bind_eq_bind, Option.bind_some]
      rw [e1]
      rfl
    · cases i using Fin.cases with
      | zero => simpa using hq
      | succ i => simpa using hqs i

/-- `runSimd_collective_inv` with each lane's own fuel and the rest's own bounds. -/
theorem simd_collective_bound (T : Fin 32 → Thread) (site slot : Nat) (op : Collective) (s : Scalar) (d : Nat)
    (x y : Fin 32 → Val) (hres : resolve C op s d (List.ofFn x) = some (List.ofFn y))
    (I : Nat → Shared → Prop) (P : Fin 32 → Thread → Prop) (J : Shared → Prop) (R : Fin 32 → Thread → Prop)
    (h : ∀ i : Fin 32, ∀ sh, I i sh → ∃ f t sh', (runThread C f (T i)).run sh = some (t, sh') ∧ I (i + 1) sh' ∧
      t.status = .collective site slot op s (x i) d ∧ P i t)
    (hnext : ∀ (U : Fin 32 → Thread) (sh : Shared), (∀ i, P i (U i)) → I 32 sh →
      ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
        (runSimd C f r (List.ofFn fun i => { U i with status := .running }.set slot (y i))).run sh =
          some (List.ofFn V, sh') ∧ J sh' ∧ ∀ i, R i (V i))
    (sh : Shared) (h0 : I 0 sh) :
    ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared), (runSimd C f r (List.ofFn T)).run sh = some (List.ofFn V, sh') ∧ J sh' ∧
      ∀ i, R i (V i) := by
  obtain ⟨f0, U, sh1, hrun, hI, hq⟩ :=
    lanes_bound C T I (fun i t => t.status = .collective site slot op s (x i) d ∧ P i t) h sh h0
  obtain ⟨f1, r1, V, sh', hr, hJ, hR⟩ := hnext U sh1 (fun i => (hq i).2) hI
  refine ⟨max f0 f1, r1 + 1, V, sh', ?_, hJ, hR⟩
  rw [runSimd_collective_ofFn C _ r1 _ U sh sh1 site slot op s d x y (hrun _ (le_max_left _ _))
    (fun i => (hq i).1) hres]
  exact runSimd_mono C (le_max_right _ _) le_rfl _ hr

/-- `runSimd_blocked_inv` with each lane's own fuel. -/
theorem simd_blocked_bound (T : Fin 32 → Thread) (I : Nat → Shared → Prop) (R : Fin 32 → Thread → Prop)
    (h : ∀ i : Fin 32, ∀ sh, I i sh → ∃ f t sh', (runThread C f (T i)).run sh = some (t, sh') ∧ I (i + 1) sh' ∧
      blocked t.status = true ∧ R i t) (sh : Shared) (h0 : I 0 sh) :
    ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared), (runSimd C f r (List.ofFn T)).run sh = some (List.ofFn V, sh') ∧ I 32 sh' ∧
      ∀ i, R i (V i) := by
  obtain ⟨f0, U, sh1, hrun, hI, hq⟩ := lanes_bound C T I (fun i t => blocked t.status = true ∧ R i t) h sh h0
  exact ⟨f0, 1, U, sh1, runSimd_blocked_ofFn C f0 0 _ U sh sh1 (hrun f0 le_rfl) (fun i => (hq i).1), hI,
    fun i => (hq i).2⟩

/-- A threadgroup's SIMD-groups run in order, each within its own bounds: one pair of bounds serves all. -/
theorem simds_bound : ∀ {k : Nat} (T : Fin k → Fin 32 → Thread) (I : Nat → Shared → Prop)
    (P : Fin k → Fin 32 → Thread → Prop),
    (∀ j : Fin k, ∀ sh, I j sh → ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn (T j))).run sh = some (List.ofFn V, sh') ∧ I (j + 1) sh' ∧ ∀ i, P j i (V i)) →
    ∀ sh, I 0 sh → ∃ (f r : Nat) (U : Fin k → Fin 32 → Thread) (sh' : Shared),
      (∀ f' r', f ≤ f' → r ≤ r' → ((List.ofFn fun j => List.ofFn (T j)).mapM (runSimd C f' r')).run sh =
        some (List.ofFn fun j => List.ofFn (U j), sh')) ∧ I k sh' ∧ ∀ j i, P j i (U j i)
  | 0, _, _, _, _, sh, h0 => ⟨0, 0, Fin.elim0, sh, fun _ _ _ _ => rfl, h0, fun j => j.elim0⟩
  | k + 1, T, I, P, h, sh, h0 => by
    obtain ⟨f0, r0, V, sh1, hr, h1, hp⟩ := h 0 sh h0
    obtain ⟨f1, r1, U, sh', hr', hk, hps⟩ := simds_bound (fun j : Fin k => T j.succ) (fun j => I (j + 1))
      (fun j => P j.succ) (fun j sh hj => by simpa [Nat.add_assoc] using h j.succ sh hj) sh1 h1
    refine ⟨max f0 f1, max r0 r1, Fin.cons V U, sh', fun f' r' hf hr2 => ?_, hk, fun j i => ?_⟩
    · have e0 := runSimd_mono C (le_trans (le_max_left f0 f1) hf) (le_trans (le_max_left r0 r1) hr2) _ hr
      have e1 := hr' f' r' (le_trans (le_max_right _ _) hf) (le_trans (le_max_right _ _) hr2)
      rw [List.ofFn_succ, List.mapM_cons]
      simp only [StateT.run_bind] at e1 ⊢
      rw [e0]
      simp only [Option.bind_eq_bind, Option.bind_some]
      rw [e1]
      simp only [Option.bind_some, List.ofFn_succ, Fin.cons_zero, Fin.cons_succ]
      rfl
    · cases j using Fin.cases with
      | zero => simpa using hp i
      | succ j => simpa using hps j i

/-- `runGroup_done_inv` with each SIMD-group's own bounds. -/
theorem group_done_bound {k : Nat} (T : Fin k → Fin 32 → Thread) (I : Nat → Shared → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn (T j))).run sh = some (List.ofFn V, sh') ∧ I (j + 1) sh' ∧ ∀ i, (V i).status = .done)
    (sh : Shared) (h0 : I 0 sh) :
    ∃ f r b sh', (runGroup C f r b (List.ofFn fun j => List.ofFn (T j))).run sh = some ((), sh') ∧ I k sh' := by
  obtain ⟨f, r, U, sh', hr, hk, hd⟩ := simds_bound C T I (fun _ _ t => t.status = .done) h sh h0
  exact ⟨f, r, 1, sh', runGroup_done_ofFn C f r 0 _ U sh sh' (hr f r le_rfl le_rfl) hd, hk⟩

/-- `runGroup_barrier_inv` with each SIMD-group's own bounds and the rest's own bounds. -/
theorem group_barrier_bound {k : Nat} (hk : 0 < k) (T : Fin k → Fin 32 → Thread) (site : Nat) (d g : Bool)
    (I : Nat → Shared → Prop) (P : Fin k → Fin 32 → Thread → Prop) (Q : Shared → Prop)
    (h : ∀ j : Fin k, ∀ sh, I j sh → ∃ (f r : Nat) (V : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn (T j))).run sh = some (List.ofFn V, sh') ∧ I (j + 1) sh' ∧
        ∀ i, (V i).status = .barrier site d g ∧ P j i (V i))
    (hnext : ∀ (U : Fin k → Fin 32 → Thread) (sh : Shared), (∀ j i, P j i (U j i)) → I k sh → ∃ f r b sh',
      (runGroup C f r b (List.ofFn fun j => List.ofFn fun i => { U j i with status := .running })).run
        (pass d g sh) = some ((), sh') ∧ Q sh')
    (sh : Shared) (h0 : I 0 sh) :
    ∃ f r b sh', (runGroup C f r b (List.ofFn fun j => List.ofFn (T j))).run sh = some ((), sh') ∧ Q sh' := by
  obtain ⟨f0, r0, U, sh1, hr, hk1, hp⟩ :=
    simds_bound C T I (fun j i t => t.status = .barrier site d g ∧ P j i t) h sh h0
  obtain ⟨f1, r1, b1, sh', hr', hq⟩ := hnext U sh1 (fun j i => (hp j i).2) hk1
  refine ⟨max f0 f1, max r0 r1, b1 + 1, sh', ?_, hq⟩
  rw [runGroup_barrier_ofFn C hk _ _ b1 _ U sh sh1 site d g (hr _ _ (le_max_left _ _) (le_max_left _ _))
    (fun j i => (hp j i).1)]
  exact runGroup_mono C (le_max_right _ _) (le_max_right _ _) le_rfl _ hr'

/-- `forM_inv` with each element's own bound. -/
theorem forM_bound {α : Type} (F : Nat → α → M Unit) (hF : ∀ x {n m}, n ≤ m → Extends (F n x) (F m x))
    (I : Nat → Shared → Prop) : ∀ (xs : List α) (k : Nat),
    (∀ i (hi : i < xs.length), ∀ sh, I (k + i) sh → ∃ n sh', (F n xs[i]).run sh = some ((), sh') ∧
      I (k + i + 1) sh') →
    ∀ sh, I k sh → ∃ n sh', (xs.forM (F n)).run sh = some ((), sh') ∧ I (k + xs.length) sh'
  | [], k, _, sh, h0 => ⟨0, sh, rfl, by simpa using h0⟩
  | x :: xs, k, h, sh, h0 => by
    obtain ⟨n0, sh1, hr, h1⟩ := h 0 (by simp) sh (by simpa using h0)
    obtain ⟨n1, sh', hr', hn⟩ := forM_bound F hF I xs (k + 1) (fun i hi sh hi' => by
      have := h (i + 1) (by simp; omega) sh (by simpa [Nat.add_assoc, Nat.add_comm 1] using hi')
      simpa [Nat.add_assoc, Nat.add_comm 1] using this) sh1 h1
    refine ⟨max n0 n1, sh', ?_, by simpa [Nat.add_assoc, Nat.add_comm 1] using hn⟩
    have hr0 : (F (max n0 n1) x).run sh = some ((), sh1) := hF x (le_max_left _ _) sh _ hr
    have hr1 := forM_extends (fun y => hF y (le_max_right n0 n1)) xs sh1 _ hr'
    show (F (max n0 n1) x >>= fun _ => xs.forM (F (max n0 n1))).run sh = _
    rw [StateT.run_bind, hr0]
    exact hr1

/-- `Launch.Tiles.launch_run` with each threadgroup's own bounds. -/
theorem launch_bound {L : Launch} {tx ty tz gx gy gz k : Nat} (h : L.Tiles tx ty tz gx gy gz k)
    (fuse : Nat → Bool) (garbage : Garbage) (I : Nat → Shared → Prop) (h0 : I 0 (L.initial garbage))
    (hg : ∀ bx byy bz, bx < gx → byy < gy → bz < gz → ∀ sh, I (bx + byy * gx + bz * gx * gy) sh → ∃ f r b sh',
      (runGroup C f r b (List.ofFn fun s : Fin k => List.ofFn (L.lanes fuse bx byy bz s))).run
        { sh with bytes := L.resetGroup garbage (bx + byy * gx + bz * gx * gy) sh.bytes } = some ((), sh') ∧
        I (bx + byy * gx + bz * gx * gy + 1) sh') :
    ∃ n sh, I (gx * gy * gz) sh ∧ runLaunch C fuse L garbage n n n = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨-, hx, hy, hz⟩ := h.pos
  simp only [runLaunch, h.groups]
  obtain ⟨n, sh', hrun, hI⟩ := forM_bound (fun n (x : Nat × Nat × Nat) => (do
      modify fun (sh : Shared) =>
        { sh with bytes := L.resetGroup garbage (x.1 + x.2.1 * gx + x.2.2 * gx * gy) sh.bytes }
      runGroup C n n n (Launch.chunks 32 (L.threads fuse x.1 x.2.1 x.2.2)) : M Unit))
    (fun x n m hnm => Extends.bind (Extends.refl _) fun _ => runGroup_extends C _ hnm hnm hnm)
    I ((List.range (gx * gy * gz)).map fun g => (g % gx, g / gx % gy, g / (gx * gy))) 0 (fun j hj sh hI => by
      simp only [List.length_map, List.length_range] at hj
      simp only [List.getElem_map, List.getElem_range, Nat.zero_add] at hI ⊢
      have hb := group_index gx gy j
      have bx : j % gx < gx := Nat.mod_lt _ hx
      have byy : j / gx % gy < gy := Nat.mod_lt _ hy
      have bz : j / (gx * gy) < gz := (Nat.div_lt_iff_lt_mul (Nat.mul_pos hx hy)).mpr
        (by rw [Nat.mul_comm gz]; exact hj)
      rw [h.chunks fuse bx byy bz]
      obtain ⟨f, r, b, sh2, h2, hI2⟩ := hg _ _ _ bx byy bz sh (by rw [hb]; exact hI)
      refine ⟨max f (max r b), sh2, ?_, by rw [hb] at hI2; exact hI2⟩
      simp only [StateT.run_bind]
      exact runGroup_mono C (le_max_left _ _) (le_trans (le_max_left _ _) (le_max_right _ _))
        (le_trans (le_max_right _ _) (le_max_right _ _)) _ h2) (L.initial garbage) h0
  refine ⟨n, sh', by simpa using hI, ?_⟩
  rw [hrun]
  rfl

/-! ## A launch with existential fuel -/

/-- `Launch.Tiles.launch_run` with each threadgroup's fuel bound existential (it may depend on the
state the threadgroup starts from): one bound serves the whole launch. -/
theorem launch_run_fuel {L : Launch} {tx ty tz gx gy gz k : Nat} (h : L.Tiles tx ty tz gx gy gz k)
    (fuse : Nat → Bool) (garbage : Garbage) (rounds barriers : Nat) (I : Nat → Shared → Prop)
    (h0 : I 0 (L.initial garbage))
    (hg : ∀ bx byy bz, bx < gx → byy < gy → bz < gz → ∀ sh, I (bx + byy * gx + bz * gx * gy) sh → ∃ sh',
      (∃ N, ∀ m ≥ N, (runGroup C m rounds barriers
        (List.ofFn fun s : Fin k => List.ofFn (L.lanes fuse bx byy bz s))).run
        { sh with bytes := L.resetGroup garbage (bx + byy * gx + bz * gx * gy) sh.bytes } = some ((), sh')) ∧
        I (bx + byy * gx + bz * gx * gy + 1) sh') :
    ∃ sh fuel, I (gx * gy * gz) sh ∧ runLaunch C fuse L garbage fuel rounds barriers = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨-, hx, hy, hz⟩ := h.pos
  simp only [runLaunch, h.groups]
  obtain ⟨sh', ⟨N, hrun⟩, hI⟩ := forM_ev (fun m (x : Nat × Nat × Nat) => (do
      modify fun (sh : Shared) => { sh with bytes := L.resetGroup garbage (x.1 + x.2.1 * gx + x.2.2 * gx * gy) sh.bytes }
      runGroup C m rounds barriers (Launch.chunks 32 (L.threads fuse x.1 x.2.1 x.2.2)) : M Unit))
    I ((List.range (gx * gy * gz)).map fun g => (g % gx, g / gx % gy, g / (gx * gy))) 0 (fun j hj sh hI => by
      simp only [List.length_map, List.length_range] at hj
      simp only [List.getElem_map, List.getElem_range, Nat.zero_add] at hI ⊢
      have hb := group_index gx gy j
      have bx : j % gx < gx := Nat.mod_lt _ hx
      have byy : j / gx % gy < gy := Nat.mod_lt _ hy
      have bz : j / (gx * gy) < gz := (Nat.div_lt_iff_lt_mul (Nat.mul_pos hx hy)).mpr
        (by rw [Nat.mul_comm gz]; exact hj)
      rw [h.chunks fuse bx byy bz]
      obtain ⟨sh2, ⟨N2, h2⟩, hI2⟩ := hg _ _ _ bx byy bz sh (by rw [hb]; exact hI)
      refine ⟨sh2, ⟨N2, fun m hm => ?_⟩, by rw [hb] at hI2; exact hI2⟩
      simp only [StateT.run_bind]
      exact h2 m hm) (L.initial garbage) h0
  refine ⟨sh', N, by simpa using hI, ?_⟩
  rw [hrun N le_rfl]
  rfl

end Bound

section Strips
variable (C : M1Max.Contract)

/-! ### The GPU's contents of a set of buffers -/

/-- **The GPU leaves a modeled launch's contents in a set `S` of its buffers** (`gpu_owned` for any buffers, an
input written through included). If for every initial content of the outputs and every garbage the model's run
completes with an ownership-disciplined log and contents `out i` within buffer `i`'s size for `i ∈ S`, the GPU's
run gives those contents (zero past the size). -/
theorem gpu_owned_set (G : Gpu C) {text : List Char} {kernel : Kernel} {grid tg : Nat × Nat × Nat}
    {inputs : List Buffer} {sizes : List Nat} (S : Nat → Prop) (out : Nat → ByteMemory.Bytes)
    (hc : compile text = some kernel) (hmax : tg.1 * tg.2.1 * tg.2.2 ≤ G.maxThreads text)
    (h : ∀ (initial : Nat → ByteMemory.Bytes) (garbage : Garbage), ∃ (fuel rounds barriers : Nat) (sh : Shared)
      (dev : Nat → Nat → Option Writer) (tgo : Nat → Nat → Nat → Nat → Option Nat),
      runLaunch C (G.fusion text) ⟨kernel, grid, tg, buffers inputs sizes 16 initial⟩ garbage fuel rounds barriers =
        some ⟨sh.bytes, sh.log⟩ ∧
      (∀ a ∈ sh.log, Owned ⟨kernel, grid, tg, buffers inputs sizes 16 initial⟩ dev tgo a) ∧
      ∀ i, S i → ∀ b, b < ((inputs.map (·.size) ++ sizes)[i]?.getD 0) → sh.bytes i b = out i b) :
    ∃ res, G.executeAll text grid tg inputs sizes = some res ∧ res.length = inputs.length + sizes.length ∧
      ∀ i (hi : i < res.length), S i →
        res[i] = fun b => if b < ((inputs.map (·.size) ++ sizes)[i]?.getD 0) then out i b else 0 := by
  apply G.runs_as_modeled text kernel grid tg inputs sizes S
    (fun i b => if b < ((inputs.map (·.size) ++ sizes)[i]?.getD 0) then out i b else 0) hc hmax
  intro initial garbage
  obtain ⟨fuel, rounds, barriers, sh, dev, tgo, hr, ho, hout⟩ := h initial garbage
  refine ⟨fuel, rounds, barriers, _, hr, raceFree_of_owned _ dev tgo _ ho, fun i hi => ?_⟩
  funext b
  show (if b < _ then sh.bytes i b else 0) = (if b < _ then out i b else 0)
  split_ifs with hb
  · exact hout i hi b hb
  · rfl

/-! ### Strips: threadgroups along x, the last of a row possibly partial -/

/-- A launch whose threadgroups are `tx` threads along x (a multiple of 32), over a grid of `X × Y` threads (`X`
a multiple of 32): the last threadgroup of each row may be partial. -/
structure Launch.Strip (L : Launch) (tx X Y : Nat) : Prop where
  threadgroup : L.threadgroup = (tx, 1, 1)
  grid : L.grid = (X, Y, 1)
  le : tx ≤ X
  pos : 0 < tx ∧ 0 < Y
  mult : tx % 32 = 0 ∧ X % 32 = 0

namespace Launch

/-- Thread `l` of threadgroup `(bx, by, 0)` of a strip with `gx` threadgroups a row, `ax` threads in this one (as
`threads` builds it). -/
def ctxStrip (L : Launch) (fuse : Nat → Bool) (tx gx Y bx byy ax l : Nat) : Ctx :=
  { thread := (bx + byy * gx + 0 * gx * Y) * tx + l
    group := bx + byy * gx + 0 * gx * Y
    coord := fun
      | .threadPositionInGrid => u32x3 (bx * tx + l % ax) (byy * 1 + l / ax % 1) (0 * 1 + l / ax)
      | .threadPositionInThreadgroup => u32x3 (l % ax) (l / ax % 1) (l / ax)
      | .threadgroupPositionInGrid => u32x3 bx byy 0
      | .threadsPerThreadgroup => u32x3 ax 1 1
      | .threadgroupsPerGrid => u32x3 gx Y 1
      | .threadsPerGrid => u32x3 L.grid.1 L.grid.2.1 L.grid.2.2
      | .threadIndexInSimdgroup => u32 (l % 32)
      | .simdgroupIndexInThreadgroup => u32 (l / 32)
      | .threadIndexInThreadgroup => u32 l
      | .simdgroupsPerThreadgroup => u32 (ceilDiv ax 32)
      | .threadsPerSimdgroup => u32 32
    threadArray := fun j => L.buffers.length + L.groupArrays + ((bx + byy * gx + 0 * gx * Y) * tx + l) *
      L.threadArrays + j
    groupArray := fun j => L.buffers.length + j
    fuse := fuse }

/-- What a strip thread's context says. -/
structure StripLane (L : Launch) (fuse : Nat → Bool) (gx tx bx byy l : Nat) (ctx : Ctx) : Prop where
  pos : ctx.coord .threadPositionInGrid = u32x3 (bx * tx + l) byy 0
  thread : ctx.thread = (bx + byy * gx) * tx + l
  group : ctx.group = bx + byy * gx
  threadArray : ∀ j, ctx.threadArray j =
    L.buffers.length + L.groupArrays + ((bx + byy * gx) * tx + l) * L.threadArrays + j
  fuse : ctx.fuse = fuse

namespace Strip
variable {L : Launch} {tx X Y : Nat}

theorem group (h : L.Strip tx X Y) : L.group = (tx, 1, 1) := by
  simp only [Launch.group, h.threadgroup, h.grid]
  rw [Nat.min_eq_left h.le, Nat.min_eq_left (show 1 ≤ Y from h.pos.2), Nat.min_self]

theorem groups (h : L.Strip tx X Y) : L.groups = (ceilDiv X tx, Y, 1) := by
  simp only [Launch.groups, h.group, h.grid]
  simp [ceilDiv]

theorem threads (h : L.Strip tx X Y) (fuse : Nat → Bool) {bx byy : Nat} (hy : byy < Y) :
    L.threads fuse bx byy 0 = (List.range (min tx (X - bx * tx))).map fun l =>
      L.start (L.ctxStrip fuse tx (ceilDiv X tx) Y bx byy (min tx (X - bx * tx)) l) := by
  unfold Launch.threads Launch.ctxStrip Launch.start
  rw [h.group, h.groups, h.grid]
  dsimp only
  rw [show min 1 (Y - byy * 1) = 1 by omega, show min 1 (1 - 0 * 1) = 1 by omega]
  simp only [Nat.mul_one]
  rfl

/-- The threads of threadgroup `bx` of a row: `32 k` of them. -/
theorem width (h : L.Strip tx X Y) {bx : Nat} (hx : bx < ceilDiv X tx) :
    min tx (X - bx * tx) = 32 * (min tx (X - bx * tx) / 32) ∧ 0 < min tx (X - bx * tx) := by
  have ht := h.pos.1
  have hm := h.mult
  have hlt : bx * tx < X := by
    unfold ceilDiv at hx
    have h1 := (Nat.le_div_iff_mul_le ht).mp (show bx + 1 ≤ (X + tx - 1) / tx by omega)
    rw [Nat.add_mul, Nat.one_mul] at h1
    omega
  have hb : bx * tx % 32 = 0 := by rw [Nat.mul_mod, hm.1, Nat.mul_zero, Nat.zero_mod]
  constructor <;> omega

/-- The SIMD-groups of threadgroup `(bx, by)`, `32 k` threads. -/
theorem chunks (h : L.Strip tx X Y) (fuse : Nat → Bool) {bx byy k : Nat} (hy : byy < Y)
    (hk : min tx (X - bx * tx) = 32 * k) :
    Launch.chunks 32 (L.threads fuse bx byy 0) = List.ofFn fun s : Fin k => List.ofFn fun i : Fin 32 =>
      L.start (L.ctxStrip fuse tx (ceilDiv X tx) Y bx byy (32 * k) (32 * s + i)) := by
  rw [h.threads fuse hy, hk, Launch.chunks_range]

theorem lane (fuse : Nat → Bool) (gx Y bx byy ax l : Nat) (hl : l < ax) :
    StripLane L fuse gx tx bx byy l (L.ctxStrip fuse tx gx Y bx byy ax l) := by
  refine ⟨?_, ?_, ?_, fun j => ?_, rfl⟩
  · show u32x3 (bx * tx + l % ax) (byy * 1 + l / ax % 1) (0 * 1 + l / ax) = _
    rw [Nat.mod_eq_of_lt hl, Nat.div_eq_of_lt hl]
    simp
  · show (bx + byy * gx + 0 * gx * Y) * tx + l = _
    simp
  · show bx + byy * gx + 0 * gx * Y = _
    simp
  · show L.buffers.length + L.groupArrays + ((bx + byy * gx + 0 * gx * Y) * tx + l) * L.threadArrays + j = _
    simp

end Strip
end Launch

/-- `Launch.Tiles.launch_run_ev` for any threadgroups: each threadgroup's run (its SIMD-groups as `runLaunch` chunks
them) from the state the previous ones leave. -/
theorem launch_run_groups_ev {L : Launch} {gx gy gz : Nat} (hgr : L.groups = (gx, gy, gz)) (hx : 0 < gx)
    (hy : 0 < gy) (fuse : Nat → Bool) (garbage : Garbage) (rounds barriers : Nat) (I : Nat → Shared → Prop)
    (h0 : I 0 (L.initial garbage))
    (hg : ∀ bx byy bz, bx < gx → byy < gy → bz < gz → ∀ sh, I (bx + byy * gx + bz * gx * gy) sh → ∃ sh',
      (Ev fun m => (runGroup C m rounds barriers (Launch.chunks 32 (L.threads fuse bx byy bz))).run
        { sh with bytes := L.resetGroup garbage (bx + byy * gx + bz * gx * gy) sh.bytes } = some ((), sh')) ∧
        I (bx + byy * gx + bz * gx * gy + 1) sh') :
    ∃ sh, I (gx * gy * gz) sh ∧ Ev fun m => runLaunch C fuse L garbage m rounds barriers = some ⟨sh.bytes, sh.log⟩ := by
  obtain ⟨sh', hrun, hI⟩ := forM_ev (fun m (x : Nat × Nat × Nat) => (do
      modify fun (sh : Shared) => { sh with bytes := L.resetGroup garbage (x.1 + x.2.1 * gx + x.2.2 * gx * gy) sh.bytes }
      runGroup C m rounds barriers (Launch.chunks 32 (L.threads fuse x.1 x.2.1 x.2.2)) : M Unit))
    I ((List.range (gx * gy * gz)).map fun g => (g % gx, g / gx % gy, g / (gx * gy))) 0 (fun j hj sh hI => by
      simp only [List.length_map, List.length_range] at hj
      simp only [List.getElem_map, List.getElem_range, Nat.zero_add] at hI ⊢
      have hb := group_index gx gy j
      have bx : j % gx < gx := Nat.mod_lt _ hx
      have byy : j / gx % gy < gy := Nat.mod_lt _ hy
      have bz : j / (gx * gy) < gz := (Nat.div_lt_iff_lt_mul (Nat.mul_pos hx hy)).mpr
        (by rw [Nat.mul_comm gz]; exact hj)
      obtain ⟨sh2, h2, hI2⟩ := hg _ _ _ bx byy bz sh (by rw [hb]; exact hI)
      refine ⟨sh2, h2.mono fun m hm => ?_, by rw [hb] at hI2; exact hI2⟩
      simp only [StateT.run_bind]
      exact hm) (L.initial garbage) h0
  refine ⟨sh', by simpa using hI, hrun.mono fun m hm => ?_⟩
  simp only [runLaunch, hgr]
  rw [hm]
  rfl

/-- **A strip launch runs threadgroup by threadgroup**, each its `32 k` lanes (`ctxStrip`), from the state the
previous ones leave. -/
theorem Launch.Strip.launch_run_ev {L : Launch} {tx X Y : Nat} (h : L.Strip tx X Y) (fuse : Nat → Bool)
    (garbage : Garbage) (rounds barriers : Nat) (I : Nat → Shared → Prop) (h0 : I 0 (L.initial garbage))
    (hg : ∀ bx byy k, bx < ceilDiv X tx → byy < Y → min tx (X - bx * tx) = 32 * k → ∀ sh,
      I (bx + byy * ceilDiv X tx) sh → ∃ sh',
      (Ev fun m => (runGroup C m rounds barriers (List.ofFn fun s : Fin k => List.ofFn fun i : Fin 32 =>
        L.start (L.ctxStrip fuse tx (ceilDiv X tx) Y bx byy (32 * k) (32 * s + i)))).run
        { sh with bytes := L.resetGroup garbage (bx + byy * ceilDiv X tx) sh.bytes } = some ((), sh')) ∧
        I (bx + byy * ceilDiv X tx + 1) sh') :
    ∃ sh, I (ceilDiv X tx * Y) sh ∧ Ev fun m => runLaunch C fuse L garbage m rounds barriers = some ⟨sh.bytes, sh.log⟩ := by
  have hgx : 0 < ceilDiv X tx := by
    unfold ceilDiv; exact Nat.div_pos (by have := h.le; omega) h.pos.1
  obtain ⟨sh, hI, hr⟩ := launch_run_groups_ev C h.groups hgx h.pos.2 fuse garbage rounds barriers I h0
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bz = 0 := by omega
      have hw := h.width hx
      rw [h.chunks fuse hy hw.1]
      simp only [Nat.zero_mul, Nat.add_zero] at hI ⊢
      exact hg bx byy _ hx hy hw.1 sh hI)
  exact ⟨sh, by simpa using hI, hr⟩

end Strips

end Metal
