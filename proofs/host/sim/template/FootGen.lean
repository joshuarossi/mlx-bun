import host.sim.conv.ObsFoot
import host.sim.template.FullShiftGen
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

/-! # A compaction's observer shift from its footprint, as the chain generator states it

`Conv.freed_of_foot` and `Conv.krec_of_foot` take per-handle facts over the changed handles `lh`;
here they are Boolean checks over `lh` (`freedLB`, `krecLB`), and `liveShift_foot`, `kernShift_foot`
assemble `LiveShift` and `KernShift` at concrete layer states (`genChain.ts`, the site's SiteS module). -/

/-- `freed_of_foot`'s facts at the changed handles. -/
def freedLB (σ : Map) (x0 : NSt) (fx0 fx1 : PTrie Unit) (lh : List Nat) : Bool :=
  lh.all fun h => (!(fx0.get h).isSome || (x0.objs.get h).isSome) &&
    (!(x0.objs.get h).isSome || decide (fx1.get (σ.handle h) = fx0.get h))

theorem freedL_of {σ : Map} {x0 : NSt} {fx0 fx1 : PTrie Unit} {lh : List Nat} (h : freedLB σ x0 fx0 fx1 lh = true) :
    ∀ k ∈ lh, (fx0.get k = some () → (x0.objs.get k).isSome = true) ∧
      ((x0.objs.get k).isSome = true → fx1.get (σ.handle k) = fx0.get k) := by
  intro k hk
  have hc := List.all_eq_true.mp h k hk
  simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq] at hc
  obtain ⟨h1, h2⟩ := hc
  refine ⟨fun hf => ?_, fun hp => ?_⟩
  · rcases h1 with h1 | h1
    · rw [hf] at h1; cases h1
    · exact h1
  · rcases h2 with h2 | h2
    · rw [hp] at h2; cases h2
    · exact h2

/-- **The liveness layer's shift from the footprint**, at the layers' states `fxC` (call), `fx0`
(canonical), `fx1` (merged). -/
theorem liveShift_foot {P : LoadP} {n0 : Nat} {σ : Map} {D : RData} {hinv ninv : PTrie Nat} {xC x0 x1 x1' : NSt}
    {cC : Conv.Cnt} {lh ln li wS nS iS : List Nat} (c : Conv.MFoot P n0 σ D hinv ninv xC x0 x1 cC lh ln li wS nS iS)
    {x0' : NSt} (he : x0'.objs = x0.objs) {e0 e1 : Option (PTrie Unit)} {fxC fx0 fx1 : PTrie Unit} (h0 : e0 = some fx0) (h1 : e1 = some fx1)
    (hobjC : ∀ h, fxC.get h = some () → (xC.objs.get h).isSome = true)
    (kf0 : fx0 = Stage.setAll fxC (lh.filterMap fun i => (fx0.get i).map (i, ·)))
    (kf1 : fx1 = Stage.setAll fxC (wS.filterMap fun i => (fx1.get i).map (i, ·)))
    (hck : freedLB σ x0 fx0 fx1 lh = true) : LiveShift σ x0' x1' e0 e1 := by
  intro f hf
  rw [h0] at hf; cases hf
  have r := Conv.freed_of_foot c hobjC kf0 kf1 (freedL_of hck)
  exact ⟨fx1, h1, fun h hf => he ▸ r.1 h hf, fun h hp => r.2 h (he ▸ hp)⟩

/-- `krec_of_foot`'s facts at the changed handles. -/
def krecLB (σ : Map) (n0 : Nat) (x0 : NSt) (k0 k1 : KRec) (lh : List Nat) : Bool :=
  lh.all fun h => (!(k0.flags.get h).isSome || (x0.objs.get h).isSome) &&
    (!(k0.targs.get h).isSome || (x0.objs.get h).isSome) &&
    (!(x0.objs.get h).isSome || (decide (k1.flags.get (σ.handle h) = k0.flags.get h) &&
      otargsEqB (k1.targs.get (σ.handle h)) ((k0.targs.get h).map (List.map (targ σ))))) &&
    (k0.targs.get h).all (stargsB n0)

theorem krecL_of {σ : Map} {n0 : Nat} {x0 : NSt} {k0 k1 : KRec} {lh : List Nat} (h : krecLB σ n0 x0 k0 k1 lh = true) :
    ∀ k ∈ lh, ((k0.flags.get k).isSome = true → (x0.objs.get k).isSome = true) ∧
      ((k0.targs.get k).isSome = true → (x0.objs.get k).isSome = true) ∧
      ((x0.objs.get k).isSome = true → k1.flags.get (σ.handle k) = k0.flags.get k ∧
        k1.targs.get (σ.handle k) = (k0.targs.get k).map (List.map (targ σ))) ∧
      (∀ l, k0.targs.get k = some l → STargs (· < n0) l) := by
  intro k hk
  have hc := List.all_eq_true.mp h k hk
  simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at hc
  obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hc
  refine ⟨fun hf => ?_, fun ht => ?_, fun hp => ?_, fun l hl => ?_⟩
  · rcases h1 with h1 | h1
    · rw [hf] at h1; cases h1
    · exact h1
  · rcases h2 with h2 | h2
    · rw [ht] at h2; cases h2
    · exact h2
  · rcases h3 with h3 | h3
    · rw [hp] at h3; cases h3
    · simp only [Bool.and_eq_true, decide_eq_true_eq] at h3
      exact ⟨h3.1, otargsEqB_sound h3.2⟩
  · rw [hl] at h4
    exact stargs_of h4

/-- **The kernel-recording layer's shift from the footprint**, at the layers' states `kC` (call), `k0`
(canonical), `k1` (merged). -/
theorem kernShift_foot {P : LoadP} {n0 : Nat} {σ : Map} {D : RData} {hinv ninv : PTrie Nat} {xC x0 x1 x1' : NSt}
    {cC : Conv.Cnt} {lh ln li wS nS iS : List Nat} (c : Conv.MFoot P n0 σ D hinv ninv xC x0 x1 cC lh ln li wS nS iS)
    {x0' : NSt} (he : x0'.objs = x0.objs) {n' : Nat} {e0 e1 : Option KRec} {kC k0 k1 : KRec} (h0 : e0 = some k0) (h1 : e1 = some k1) (hn : cC.n ≤ n')
    (hfC : ∀ h, (kC.flags.get h).isSome = true → (xC.objs.get h).isSome = true)
    (htC : ∀ h, (kC.targs.get h).isSome = true → (xC.objs.get h).isSome = true)
    (hclC : ∀ h l, kC.targs.get h = some l → STargs (· < cC.n) l)
    (kf0 : k0.flags = Stage.setAll kC.flags (lh.filterMap fun i => (k0.flags.get i).map (i, ·)))
    (kt0 : k0.targs = Stage.setAll kC.targs (lh.filterMap fun i => (k0.targs.get i).map (i, ·)))
    (kf1 : k1.flags = Stage.setAll kC.flags (wS.filterMap fun i => (k1.flags.get i).map (i, ·)))
    (kt1 : k1.targs = Stage.setAll kC.targs (wS.filterMap fun i => (k1.targs.get i).map (i, ·)))
    (hck : krecLB σ n' x0 k0 k1 lh = true) : KernShift σ n' x0' x1' e0 e1 := by
  intro k hk
  rw [h0] at hk; cases hk
  have r := Conv.krec_of_foot c hn hfC htC hclC kf0 kt0 kf1 kt1 (krecL_of hck)
  exact ⟨k1, h1, fun h hf => he ▸ r.1 h hf, fun h ht => he ▸ r.2.1 h ht, fun h hp => r.2.2.1 h (he ▸ hp),
    fun h hp => r.2.2.2.1 h (he ▸ hp), r.2.2.2.2⟩


/-! ## The renamed nodes' order, linearly

`Conv.MFoot.cnord` checks every renamed node against every key of the map (quadratic in the canonical nodes). The
canonical nodes are a range `[a, a + n)` with the map increasing along it (`incrB`): the order follows (`cnord_of`). -/

/-- `f` increases along the list. -/
def incrB (f : Nat → Nat) : List Nat → Bool
  | a :: b :: l => Nat.blt (f a) (f b) && incrB f (b :: l)
  | _ => true

theorem incr_range {f : Nat → Nat} (n : Nat) : ∀ a, incrB f (List.range' a n) = true →
    ∀ i j, a ≤ i → i < j → j < a + n → f i < f j := by
  induction n with
  | zero => intro a _ i j _ _ hj; omega
  | succ n ih =>
    intro a h i j hi hij hj
    cases n with
    | zero => omega
    | succ m =>
      have h' : incrB f (a :: (a + 1) :: List.range' (a + 1 + 1) m) = true := by
        rw [List.range'_succ, List.range'_succ] at h; exact h
      simp only [incrB, Bool.and_eq_true] at h'
      have h0 := Nat.blt_eq.mp h'.1
      have ih' := ih (a + 1) (by rw [List.range'_succ]; exact h'.2)
      by_cases hia : i = a
      · subst hia
        by_cases hja : j = i + 1
        · subst hja; exact h0
        · exact Nat.lt_trans h0 (ih' (i + 1) j (Nat.le_refl _) (by omega) (by omega))
      · exact ih' i j (by omega) hij (by omega)

theorem nodeF_hi {D : RData} {i : Nat} (h : D.nn0 ≤ i) : D.nodeF i = i - D.nn0 + D.nn1 := by
  unfold RData.nodeF
  rw [show Nat.ble D.nn0 i = true from Nat.ble_eq.mpr h]
  rfl

/-- **The renamed nodes' order** (`Conv.MFoot.cnord`) from the map increasing along the canonical range `[a, a + n)`,
its keys there, and each renamed node in the range or past the map's counter. -/
theorem cnord_of {D : RData} {P : LoadP} {x1 : NSt} {ln : List Nat} {a n : Nat}
    (hnl : (PTrie.keysA D.node).all (fun k => Nat.ble P.NL k && Nat.blt (D.nodeF k) x1.nnext) = true)
    (hn1 : D.nn1 = x1.nnext) (hinc : incrB D.nodeF (List.range' a n) = true)
    (hks : (PTrie.keysA D.node).all (fun k => Nat.ble a k && Nat.blt k (a + n)) = true)
    (hl : (ln.filter (Nat.ble P.N0)).all (fun i => Nat.ble i (D.nodeF i) && (Nat.blt i (a + n) || Nat.ble D.nn0 i)) = true) :
    (ln.filter (Nat.ble P.N0)).all (fun i => Nat.ble i (D.nodeF i) &&
      (PTrie.keysA D.node).all fun k => !Nat.blt k i || Nat.blt (D.nodeF k) (D.nodeF i)) = true := by
  refine List.all_eq_true.mpr fun i hi => ?_
  have h1 := List.all_eq_true.mp hl i hi
  simp only [Bool.and_eq_true, Bool.or_eq_true] at h1
  obtain ⟨hle, hcase⟩ := h1
  simp only [Bool.and_eq_true]
  refine ⟨hle, List.all_eq_true.mpr fun k hk => ?_⟩
  have hk1 := List.all_eq_true.mp hks k hk
  simp only [Bool.and_eq_true] at hk1
  have ha := Nat.le_of_ble_eq_true hk1.1
  cases hlt : Nat.blt k i
  · rfl
  · have hki := Nat.blt_eq.mp hlt
    simp only [Bool.not_true, Bool.false_or]
    apply Nat.blt_eq.mpr
    rcases hcase with hc | hc
    · exact incr_range n a hinc k i ha hki (Nat.blt_eq.mp hc)
    · have hge := Nat.le_of_ble_eq_true hc
      have hn := List.all_eq_true.mp hnl k hk
      simp only [Bool.and_eq_true] at hn
      have hkx := Nat.blt_eq.mp hn.2
      rw [nodeF_hi hge]
      omega

end Host.Ts.Sim.Template
