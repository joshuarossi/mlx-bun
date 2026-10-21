import host.sim.Restart
import host.sim.template.Check
import Lean.Elab.Tactic.Omega

/-! # Explicit cross-iteration maps

`RData` holds a restart map as data: the renamed heap addresses, handles and
nodes (each a paged store of exceptions to the identity; fresh addresses and
nodes continue in order from the counters), and the images of number
references. `RData.map` is the `Map`; bigints follow handles below `2 ^ 56`,
JavaScript pointers (`2 ^ 56 + b·2^32 + off`) their buffer address, and native
pointers (`2 ^ 62 + r·2^24 + off`) their region. The general facts the shift and
the base relation need are proved here once; the case-specific ones are Boolean
checks the kernel evaluates (`check*`, with soundness lemmas). -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

structure RData where
  n0 : Nat
  n1 : Nat
  heap : PTrie Nat
  hnd : PTrie Nat
  nh0 : Nat
  nh1 : Nat
  nn0 : Nat
  nn1 : Nat
  node : PTrie Nat
  num : PTrie NumV

namespace RData
variable (D : RData)

def a (x : Nat) : Nat := bif Nat.ble D.n0 x then x - D.n0 + D.n1 else (D.heap.get x).getD x

def hd (h : Nat) : Nat := bif Nat.ble D.nh0 h then h - D.nh0 + D.nh1 else (D.hnd.get h).getD h

def region (r : Nat) : Nat :=
  bif Nat.ble (2 ^ 48) r then D.a (r - 2 ^ 48) + 2 ^ 48
  else bif Nat.beq (r % 4) 3 then r else 4 * D.hd (r / 4) + r % 4

/-- The renamed-handle band ends here: bigints from it on are fixed below `2 ^ 62`. -/
def bigHi : Nat := 131072

def bigN (k : Nat) : Int :=
  bif Nat.ble (2 ^ 62) k then Int.ofNat (2 ^ 62 + D.region ((k - 2 ^ 62) / 2 ^ 24) * 2 ^ 24 + (k - 2 ^ 62) % 2 ^ 24)
  else bif Nat.blt k bigHi then Int.ofNat (D.hd k) else Int.ofNat k

def big : Int → Int
  | .ofNat k => D.bigN k
  | .negSucc m => .negSucc m

def nodeF (n : Nat) : Nat := bif Nat.ble D.nn0 n then n - D.nn0 + D.nn1 else (D.node.get n).getD n

def numF (i : Nat) : NumV := (D.num.get i).getD (.ref i)

def map : Map := ⟨D.a, D.numF, D.big, D.region, D.nodeF⟩

/-! ## General facts -/

theorem ble_true {a b : Nat} (h : a ≤ b) : Nat.ble a b = true := Nat.ble_eq_true_of_le h

theorem ble_false {a b : Nat} (h : b < a) : Nat.ble a b = false := by
  cases h' : Nat.ble a b
  · rfl
  · have := Nat.le_of_ble_eq_true h'; omega

theorem blt_true {a b : Nat} (h : a < b) : Nat.blt a b = true := ble_true h

theorem a_fresh (k : Nat) : D.a (D.n0 + k) = D.n1 + k := by
  simp only [a, ble_true (Nat.le_add_right D.n0 k), Bool.cond_true]
  omega

theorem a_old {x : Nat} (hx : x < D.n0) : D.a x = (D.heap.get x).getD x := by
  simp only [a, ble_false hx, Bool.cond_false]

private theorem ofNat_cast (n : Nat) : ((n : Nat) : Int) = Int.ofNat n := rfl

theorem big_ext (r off : Nat) (ho : off < 2 ^ 24) :
    D.big (ptrInt (.ext r) off) = ptrInt (.ext (D.region r)) off := by
  simp only [ptrInt, ofNat_cast, big, bigN]
  simp only [Nat.reducePow] at *
  have e1 : (4611686018427387904 + r * 16777216 + off - 4611686018427387904) / 16777216 = r := by omega
  have e2 : (4611686018427387904 + r * 16777216 + off - 4611686018427387904) % 16777216 = off := by omega
  rw [ble_true (by omega), e1, e2]
  rfl

/-- The handle band check: every renamed handle and its image lie in `[lo, bigHi)`. -/
def checkBand (lo : Nat) : Bool :=
  (PTrie.keys D.hnd).all fun h => Nat.ble lo h && Nat.blt h bigHi && Nat.ble lo (D.hd h) && Nat.blt (D.hd h) bigHi

theorem big_fixed {lo : Nat} (hc : D.checkBand lo = true) (hlo : lo ≤ D.nh0) (hlo2 : lo ≤ bigHi) (i : Int)
    (hf : BigFixed lo bigHi i) : D.big i = i := by
  have hnone : ∀ k, k < lo → D.hnd.get k = none := by
    intro k hk
    cases hg : D.hnd.get k with
    | none => rfl
    | some x =>
      have hm := PTrie.mem_keys D.hnd k x hg
      simp only [checkBand, List.all_eq_true, Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at hc
      have := hc k hm
      omega
  cases i with
  | negSucc m => rfl
  | ofNat k =>
    simp only [BigFixed, bigHi, Int.ofNat_eq_coe, Nat.reducePow] at hf hlo2 ⊢
    rcases (show k < lo ∨ (131072 ≤ k ∧ k < 72057594037927936) by omega) with hk | ⟨hk1, hk2⟩
    · simp only [big, bigN, bigHi, Nat.reducePow, ble_false (show k < 4611686018427387904 by omega),
        blt_true (show k < 131072 by omega), Bool.cond_false, Bool.cond_true, hd, ble_false (show k < D.nh0 by omega),
        hnone k hk, Option.getD_none]
      rfl
    · simp only [big, bigN, bigHi, Nat.reducePow, ble_false (show k < 4611686018427387904 by omega),
        show Nat.blt k 131072 = false from ble_false (by omega), Bool.cond_false]
      rfl

/-- Fresh native handles' shape and string regions continue in order (below the callback range). -/
theorem region_fresh (k c : Nat) (hc : c < 2) (hr : 4 * (D.nh0 + k) + c < 2 ^ 48) :
    D.region (4 * (D.nh0 + k) + c) = 4 * (D.nh1 + k) + c := by
  have h1 : (4 * (D.nh0 + k) + c) % 4 = c := by omega
  have h2 : (4 * (D.nh0 + k) + c) / 4 = D.nh0 + k := by omega
  have h3 : Nat.beq c 3 = false := by cases h : Nat.beq c 3 <;> simp_all [Nat.beq_eq] <;> omega
  simp only [region, ble_false hr, Bool.cond_false, h1, h2, h3, hd, ble_true (Nat.le_add_right D.nh0 k), Bool.cond_true]
  omega

theorem big_nonneg (h : Nat) : 0 ≤ D.big (Int.ofNat h) := by
  simp only [big, bigN]
  cases Nat.ble (2 ^ 62) h <;> cases Nat.blt h bigHi <;> simp <;> omega

end RData

/-! ## Heap images over explicit address lists -/

/-- Every listed address of `s1` holds the image of the source's entry. -/
def HeapImg {S : Type} (σ : Map) (s0 s1 : St S) (l : List Nat) : Prop :=
  l.map (fun a => s1.heap.get (σ.a a)) = l.map (fun a => (s0.heap.get a).map σ.hobj)

theorem HeapImg.nil {S : Type} (σ : Map) (s0 s1 : St S) : HeapImg σ s0 s1 [] := rfl

theorem HeapImg.append {S : Type} {σ : Map} {s0 s1 : St S} {l1 l2 : List Nat}
    (h1 : HeapImg σ s0 s1 l1) (h2 : HeapImg σ s0 s1 l2) : HeapImg σ s0 s1 (l1 ++ l2) := by
  unfold HeapImg at *
  rw [List.map_append, List.map_append, h1, h2]

theorem HeapImg.mem {S : Type} {σ : Map} {s0 s1 : St S} {l : List Nat} (h : HeapImg σ s0 s1 l)
    {a : Nat} (ha : a ∈ l) : s1.heap.get (σ.a a) = (s0.heap.get a).map σ.hobj := by
  unfold HeapImg at h
  exact List.map_inj_left.mp h a ha

/-! ## Boolean checks -/

/-- Every present address is below the counter. -/
def checkBound {S : Type} (s : St S) : Bool := (PTrie.keys s.heap).all fun a => Nat.blt a s.next

theorem checkBound_sound {S : Type} {s : St S} (h : checkBound s = true) : ∀ a, Present s a → a < s.next := by
  intro a ha
  obtain ⟨o, ho⟩ := Present.get ha
  simp only [checkBound, List.all_eq_true, Nat.blt_eq] at h
  exact h a (PTrie.mem_keys s.heap a o ho)

/-- The unframed present addresses are exactly `l` (in key order). -/
def checkKeys {S : Type} (s : St S) (fr : List Nat) (l : List Nat) : Bool :=
  (PTrie.keys s.heap).filter (fun a => !fr.contains a) == l

theorem checkKeys_sound {S : Type} {s : St S} {fr l : List Nat} (h : checkKeys s fr l = true) :
    ∀ a o, s.heap.get a = some o → a ∉ fr → a ∈ l := by
  intro a o ho hf
  simp only [checkKeys, beq_iff_eq] at h
  rw [← h, List.mem_filter]
  refine ⟨PTrie.mem_keys s.heap a o ho, ?_⟩
  simp [hf]

/-- The renamed addresses: an inverse store certifies their images are distinct, and no
image is a present address the map fixes. -/
def checkRen {S : Type} (s : St S) (D : RData) (inv : PTrie Nat) : Bool :=
  (PTrie.keys D.heap).all fun x => match D.heap.get x with
    | some y => decide (inv.get y = some x) && (!(s.heap.get y).isSome || (D.heap.get y).isSome)
    | none => true

theorem a_inj {S : Type} {s : St S} {D : RData} {inv : PTrie Nat} (hb : ∀ x, Present s x → x < D.n0)
    (hc : checkRen s D inv = true) : ∀ x y, Present s x → Present s y → D.a x = D.a y → x = y := by
  have hent : ∀ x y, D.heap.get x = some y → inv.get y = some x ∧ (Present s y → (D.heap.get y).isSome = true) := by
    intro x y hxy
    simp only [checkRen, List.all_eq_true] at hc
    have := hc x (PTrie.mem_keys D.heap x y hxy)
    rw [hxy] at this
    simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true'] at this
    refine ⟨this.1, fun hp => ?_⟩
    rcases this.2 with h | h
    · unfold Present at hp; rw [hp] at h; cases h
    · exact h
  intro x y hx hy hxy
  rw [RData.a_old D (hb x hx), RData.a_old D (hb y hy)] at hxy
  cases gx : D.heap.get x with
  | none =>
    cases gy : D.heap.get y with
    | none => rw [gx, gy] at hxy; simpa using hxy
    | some y' =>
      rw [gx, gy] at hxy
      simp only [Option.getD_none, Option.getD_some] at hxy
      subst hxy
      have := (hent y x gy).2 hx
      rw [gx] at this; cases this
  | some x' =>
    cases gy : D.heap.get y with
    | none =>
      rw [gx, gy] at hxy
      simp only [Option.getD_none, Option.getD_some] at hxy
      rw [hxy] at gx
      have := (hent x y gx).2 hy
      rw [gy] at this; cases this
    | some y' =>
      rw [gx, gy] at hxy
      simp only [Option.getD_some] at hxy
      subst hxy
      have h1 := (hent x x' gx).1
      have h2 := (hent y x' gy).1
      rw [h1] at h2
      exact Option.some.inj h2

/-- Number images: every template entry's image holds the entry substituted by `θ`. -/
def checkNum (σ : Map) (θ : Nat → SymE) (S0 S1 : SSrv) : Bool :=
  (List.range S0.tab.length).all fun i => match nth? S0.tab i with
    | some e => decide (S1.val (σ.num i) = some (e.subst θ))
    | none => true

theorem checkNum_sound {σ : Map} {θ : Nat → SymE} {S0 S1 : SSrv} (h : checkNum σ θ S0 S1 = true) :
    ∀ i e, nth? S0.tab i = some e → S1.val (σ.num i) = some (e.subst θ) := by
  intro i e he
  simp only [checkNum, List.all_eq_true, List.mem_range] at h
  have := h i (nth?_lt S0.tab i e he)
  rw [he] at this
  simpa using this

/-- An explicit substitution: listed variables, the rest fixed. -/
def thetaOf (l : List (Nat × SymE)) (v : Nat) : SymE := ((l.find? fun p => p.1 == v).map Prod.snd).getD (.var v)

end Host.Ts.Sim.Template
