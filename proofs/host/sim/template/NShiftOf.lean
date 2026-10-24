import host.sim.template.NShiftGen
import host.sim.conv.Compact
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim
open Host.Mlx.Ffi (Node)

/-! # The native shift from its kernel checks

`mshift_of`/`nshift_of`: `MShift P n0 σ x0 x1` and `NShift` from the Boolean checks and list equalities
of `MChecks` (each a kernel evaluation of a generated module), for any load parameters `P` and any map
`σ` whose native parts are an `RData`'s (`D.big`, `D.region`, `D.nodeF`): a restart map (`R.data.map`,
every part by `rfl`) or a compaction map (`Conv.Map.compact … D.big D.region D.nodeF`, its addresses
`D.a` by `compact_a_eq`). It is the proof the loop cases' NShift modules spell out
(`template/ordinary/NShift.lean`), with the start's full nodes from `P.N0` on (a template whose node
counter is past `P.N0`): their images keep the order (`nord`, checked against the renamed nodes only:
the others are fixed) and stay full. -/

/-! ## Keys in linear time

`PTrie.keys` (`entriesK`) builds its list with nested appends and carries the entries' values: over a native
state's stores (15 000 arrays, as many nodes) its kernel evaluation alone takes 6.6 GB. `PTrie.keysA` pushes the
keys only onto an accumulator (`trieFoldK`); `PTrie.mem_keysA` is `PTrie.mem_keys` for it. -/

/-- A fold over a trie's entries (keys from `base`, a child digit `d` adding `mul * d`) onto an accumulator. -/
def trieFoldK {β : Type} (f : Nat → β → List Nat → List Nat) : Trie β → Nat → Nat → List Nat → List Nat
  | .nil, _, _, acc => acc
  | .node v a b c e, base, mul, acc =>
    let acc := trieFoldK f a base (mul * 4) (trieFoldK f b (base + mul) (mul * 4)
      (trieFoldK f c (base + mul * 2) (mul * 4) (trieFoldK f e (base + mul * 3) (mul * 4) acc)))
    match v with
    | some x => f base x acc
    | none => acc

section
variable {β : Type} {f : Nat → β → List Nat → List Nat}

theorem trieFoldK_acc (hf : ∀ k x acc m, m ∈ acc → m ∈ f k x acc) :
    ∀ (t : Trie β) (base mul : Nat) (acc : List Nat) (m : Nat), m ∈ acc → m ∈ trieFoldK f t base mul acc
  | .nil, _, _, _, _, h => h
  | .node v a b c e, base, mul, acc, m, h => by
    have h1 := trieFoldK_acc hf e (base + mul * 3) (mul * 4) acc m h
    have h2 := trieFoldK_acc hf c (base + mul * 2) (mul * 4) _ m h1
    have h3 := trieFoldK_acc hf b (base + mul) (mul * 4) _ m h2
    have h4 := trieFoldK_acc hf a base (mul * 4) _ m h3
    cases v with
    | none => exact h4
    | some x => exact hf _ _ _ _ h4

private theorem keySplitA (base mul n d : Nat) (hd : n % 4 = d) :
    base + mul * d + mul * 4 * (n / 4) = base + mul * n := by
  have h := Nat.mod_add_div n 4
  rw [hd] at h
  conv => rhs; rw [← h]
  rw [Nat.mul_add, Nat.mul_assoc, Nat.add_assoc]

theorem trieFoldK_get (hf : ∀ k x acc m, m ∈ acc → m ∈ f k x acc) {K : Nat} :
    ∀ (t : Trie β) (n base mul : Nat) (x : β) (acc : List Nat), t.get n = some x →
      (∀ acc, K ∈ f (base + mul * n) x acc) → K ∈ trieFoldK f t base mul acc
  | .nil, n, _, _, x, _, h, _ => by simp at h
  | .node v a b c e, n, base, mul, x, acc, h, hK => by
    rw [Trie.get_node] at h
    by_cases hn : n = 0
    · subst hn
      simp only [ite_true] at h
      subst h
      have := hK (trieFoldK f a base (mul * 4) (trieFoldK f b (base + mul) (mul * 4)
        (trieFoldK f c (base + mul * 2) (mul * 4) (trieFoldK f e (base + mul * 3) (mul * 4) acc))))
      simpa [trieFoldK] using this
    · simp only [hn, ite_false] at h
      have key : K ∈ trieFoldK f a base (mul * 4) (trieFoldK f b (base + mul) (mul * 4)
          (trieFoldK f c (base + mul * 2) (mul * 4) (trieFoldK f e (base + mul * 3) (mul * 4) acc))) := by
        have hd : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2 ∨ n % 4 = 3 := by omega
        rcases hd with hd | hd | hd | hd
        · rw [show Trie.pick (n % 4) a b c e = a by rw [hd]; rfl] at h
          refine trieFoldK_get hf a (n / 4) base (mul * 4) x _ h fun acc' => ?_
          rw [show base + mul * 4 * (n / 4) = base + mul * n by have := keySplitA base mul n 0 hd; simpa using this]
          exact hK acc'
        · rw [show Trie.pick (n % 4) a b c e = b by rw [hd]; rfl] at h
          refine trieFoldK_acc hf a base (mul * 4) _ K (trieFoldK_get hf b (n / 4) (base + mul) (mul * 4) x _ h fun acc' => ?_)
          rw [show base + mul + mul * 4 * (n / 4) = base + mul * n by have := keySplitA base mul n 1 hd; simpa using this]
          exact hK acc'
        · rw [show Trie.pick (n % 4) a b c e = c by rw [hd]; rfl] at h
          refine trieFoldK_acc hf a base (mul * 4) _ K (trieFoldK_acc hf b (base + mul) (mul * 4) _ K
            (trieFoldK_get hf c (n / 4) (base + mul * 2) (mul * 4) x _ h fun acc' => ?_))
          rw [keySplitA base mul n 2 hd]
          exact hK acc'
        · rw [show Trie.pick (n % 4) a b c e = e by rw [hd]; rfl] at h
          refine trieFoldK_acc hf a base (mul * 4) _ K (trieFoldK_acc hf b (base + mul) (mul * 4) _ K
            (trieFoldK_acc hf c (base + mul * 2) (mul * 4) _ K (trieFoldK_get hf e (n / 4) (base + mul * 3) (mul * 4) x _ h
              fun acc' => ?_)))
          rw [keySplitA base mul n 3 hd]
          exact hK acc'
      cases v with
      | none => simpa [trieFoldK] using key
      | some y => simpa [trieFoldK] using hf _ _ _ _ key

end

section
variable {α : Type}

def kInner (gi pi : Nat) : Nat → α → List Nat → List Nat := fun ei _ acc => (gi * 4096 + pi * 64 + ei) :: acc
def kMid (gi : Nat) : Nat → Trie α → List Nat → List Nat := fun pi p acc => trieFoldK (kInner gi pi) p 0 1 acc
def kOuter : Nat → Trie (Trie α) → List Nat → List Nat := fun gi g acc => trieFoldK (kMid gi) g 0 1 acc

theorem kInner_acc (gi pi : Nat) : ∀ k (x : α) acc m, m ∈ acc → m ∈ kInner gi pi k x acc :=
  fun _ _ _ _ h => List.mem_cons_of_mem _ h
theorem kMid_acc (gi : Nat) : ∀ k (x : Trie α) acc m, m ∈ acc → m ∈ kMid gi k x acc :=
  fun _ p acc m h => trieFoldK_acc (kInner_acc gi _) p 0 1 acc m h
theorem kOuter_acc : ∀ k (x : Trie (Trie α)) acc m, m ∈ acc → m ∈ kOuter k x acc :=
  fun gi g acc m h => trieFoldK_acc (kMid_acc gi) g 0 1 acc m h

end

/-- The addresses a paged store holds (`PTrie.keys`, in another order, in linear time). -/
def PTrie.keysA {α : Type} (t : PTrie α) : List Nat := trieFoldK kOuter t.root 0 1 []

theorem PTrie.mem_keysA {α : Type} (t : PTrie α) (n : Nat) (x : α) (h : t.get n = some x) : n ∈ PTrie.keysA t := by
  rw [Host.Ts.PTrie.get_eq] at h
  cases hg : t.root.get (n / 4096) with
  | none => simp [hg, Host.Ts.PTrie.orNil_none] at h
  | some g =>
    simp only [hg, Host.Ts.PTrie.orNil_some] at h
    cases hp : g.get ((n / 64) % 64) with
    | none => simp [hp, Host.Ts.PTrie.orNil_none] at h
    | some p =>
      simp only [hp, Host.Ts.PTrie.orNil_some] at h
      refine trieFoldK_get (f := kOuter) kOuter_acc t.root (n / 4096) 0 1 g [] hg fun acc => ?_
      show n ∈ trieFoldK (kMid (0 + 1 * (n / 4096))) g 0 1 acc
      refine trieFoldK_get (f := kMid _) (kMid_acc _) g ((n / 64) % 64) 0 1 p acc hp fun acc => ?_
      show n ∈ trieFoldK (kInner (0 + 1 * (n / 4096)) (0 + 1 * ((n / 64) % 64))) p 0 1 acc
      refine trieFoldK_get (f := kInner _ _) (kInner_acc _ _) p (n % 64) 0 1 x acc h fun acc => ?_
      show n ∈ ((0 + 1 * (n / 4096)) * 4096 + (0 + 1 * ((n / 64) % 64)) * 64 + (0 + 1 * (n % 64))) :: acc
      have e : (0 + 1 * (n / 4096)) * 4096 + (0 + 1 * ((n / 64) % 64)) * 64 + (0 + 1 * (n % 64)) = n := by omega
      rw [e]
      exact List.mem_cons.mpr (Or.inl rfl)

/-- A full node (`Full`), decided. -/
def fullB (P : LoadP) (i : Nat) : Bool := Nat.blt i P.NL || Nat.ble P.N0 i

theorem fullB_of {P : LoadP} {i : Nat} (h : Full P i) : fullB P i = true := by
  unfold fullB
  rcases h with h | h
  · rw [Nat.blt_eq.mpr h]; rfl
  · rw [Nat.ble_eq_true_of_le h, Bool.or_true]

/-- The source's present handles (`handlesOf` by `PTrie.keysA`). -/
def handlesOfA (x : NSt) : List Nat := PTrie.keysA x.arrs ++ PTrie.keysA x.objs

theorem mem_handlesOfA {x : NSt} {h : Nat} (hp : PH x h) : h ∈ handlesOfA x := by
  rcases hp with hp | hp
  · obtain ⟨n, hn⟩ := Option.isSome_iff_exists.mp hp
    exact List.mem_append_left _ (PTrie.mem_keysA _ _ _ hn)
  · obtain ⟨o, ho⟩ := Option.isSome_iff_exists.mp hp
    exact List.mem_append_right _ (PTrie.mem_keysA _ _ _ ho)

/-- The start's full present nodes. -/
def fullKeysF (P : LoadP) (x0 : NSt) : List Nat := (PTrie.keysA x0.nodes).filter (fullB P)

/-- The start's present nodes from `P.N0` on. -/
def fullAbove (P : LoadP) (x0 : NSt) : List Nat := (PTrie.keysA x0.nodes).filter fun i => Nat.ble P.N0 i

/-- The per-node facts (`nodeOK` with the full nodes of `P`). -/
def nodeOKF (σ : Map) (P : LoadP) (x0 x1 : NSt) (i : Nat) : Bool :=
  match x0.nodes.get i with
  | none => true
  | some nd => Nat.blt i x0.nnext && match x1.nodes.get (σ.node i) with
    | none => false
    | some nd1 => decide (nd1.shape = σ.dims nd.shape) && Nat.beq nd1.dtype nd.dtype &&
        nd.shape.all (fun d => decide ((σ.dim d).num = σ.nv d.num)) &&
        (!fullB P i || decide (nd1.ins = nd.ins.map σ.node)) &&
        decide (x1.items.get (σ.node i) = (x0.items.get i).map σ.nv)

/-- The kernel checks of a native shift (see the module doc). -/
structure MChecks (P : LoadP) (n0 : Nat) (σ : Map) (D : RData) (hinv ninv : PTrie Nat) (x0 x1 : NSt) : Prop where
  big : σ.big = D.big
  region : σ.region = D.region
  node : σ.node = D.nodeF
  nh0 : D.nh0 = x0.next
  nh1 : D.nh1 = x1.next
  nn0 : D.nn0 = x0.nnext
  nn1 : D.nn1 = x1.nnext
  lo : (Nat.blt 0 P.lo && Nat.ble P.lo x0.next && Nat.ble P.lo RData.bigHi && Nat.ble RData.bigHi P.E) = true
  counters : (Nat.ble x0.next x1.next && Nat.ble x0.nnext x1.nnext) = true
  nband : (Nat.blt 0 P.NL && Nat.ble P.NL P.N0 && Nat.ble P.N0 x0.nnext) = true
  hbelow : D.checkHndBelow = true
  handles : (handlesOfA x0).all (handleOK σ P.lo x0 x1) = true
  hren : checkRenG D.hnd hinv (phB x0) = true
  band : D.checkBand P.lo = true
  nh1_pos : Nat.blt 0 D.nh1 = true
  objs : ObjImg σ x0 x1 (PTrie.keysA x0.objs)
  objok : (PTrie.keysA x0.objs).all (objOK σ P.NL x0) = true
  nodes : (PTrie.keysA x0.nodes).all (nodeOKF σ P x0 x1) = true
  prims : PrimImg σ x0 x1 (fullKeysF P x0)
  nren : checkRenG D.node ninv (pnB x0) = true
  nlow : (PTrie.keysA D.node).all (fun k => Nat.ble P.NL k && Nat.blt (D.nodeF k) x1.nnext) = true
  nord : (fullAbove P x0).all (fun i => Nat.ble i (D.nodeF i) &&
    (PTrie.keysA D.node).all fun k => !Nat.blt k i || Nat.blt (D.nodeF k) (D.nodeF i)) = true
  items : (PTrie.keysA x0.items).all (pnB x0) = true
  ssT : checkSSt n0 x0 = true
  absent0a : x0.arrs.get 0 = none
  absent0b : x0.objs.get 0 = none
  tokens : x1.tokens = []
  pending : x1.pending = x0.pending.map σ.pend
  errh : x1.errh = x0.errh.map σ.arg
  files : x1.files = x0.files
  arch : x1.arch = x0.arch
  sizes : x1.deviceSizes = x0.deviceSizes
  wired : x1.wired = x0.wired

theorem or_not_true {a q : Bool} (h : (!a || q) = true) (ha : a = true) : q = true := by
  rw [ha] at h; simpa using h

section
variable {P : LoadP} {n0 : Nat} {σ : Map} {D : RData} {hinv ninv : PTrie Nat} {x0 x1 : NSt}

/-- **The mlx part of the native shift from its checks.** -/
theorem mshift_of (c : MChecks P n0 σ D hinv ninv x0 x1) : MShift P n0 σ x0 x1 := by
  have hl := c.lo
  simp only [Bool.and_eq_true, Nat.blt_eq, Nat.ble_eq] at hl
  obtain ⟨⟨⟨hlo, hlox⟩, hlohi⟩, hE⟩ := hl
  have hc := c.counters
  simp only [Bool.and_eq_true, Nat.ble_eq] at hc
  obtain ⟨hc1, hc2⟩ := hc
  have hb := c.nband
  simp only [Bool.and_eq_true, Nat.blt_eq, Nat.ble_eq] at hb
  obtain ⟨⟨hNL0, hNL⟩, hN0⟩ := hb
  have hlo0 : P.lo ≤ D.nh0 := by rw [c.nh0]; exact hlox
  have hOK : ∀ {h}, PH x0 h → h < x0.next ∧ h < RData.bigHi ∧ phB x1 (σ.handle h) = true ∧
      x1.arrs.get (σ.handle h) = (x0.arrs.get h).map σ.node ∧
      (x1.objs.get (σ.handle h)).isSome = (x0.objs.get h).isSome ∧ (P.lo ≤ h → P.lo ≤ σ.handle h) := by
    intro h hp
    have := List.all_eq_true.mp c.handles h (mem_handlesOfA hp)
    simp only [handleOK, Bool.and_eq_true, beq_iff_eq, Nat.blt_eq] at this
    obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := this
    exact ⟨h1, h2, h3, h4, h5, fun hl' => Nat.le_of_ble_eq_true (or_not_true h6 (Nat.ble_eq_true_of_le hl'))⟩
  have handle_eq : ∀ {h}, PH x0 h → σ.handle h = D.hd h := fun hp => by
    show (σ.big (Int.ofNat _)).toNat = _
    rw [c.big, D.big_small (hOK hp).2.1]; rfl
  have nOK : ∀ {i nd}, x0.nodes.get i = some nd → nodeOKF σ P x0 x1 i = true := fun hg =>
    List.all_eq_true.mp c.nodes _ (PTrie.mem_keysA _ _ _ hg)
  have nlt : ∀ {i nd}, x0.nodes.get i = some nd → i < x0.nnext := fun hg => by
    have := nOK hg
    simp only [nodeOKF, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact this.1
  have nlow : ∀ {k y}, D.node.get k = some y → P.NL ≤ k ∧ D.nodeF k < x1.nnext := fun hg => by
    have := List.all_eq_true.mp c.nlow _ (PTrie.mem_keysA _ _ _ hg)
    simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this
    exact this
  have nid : ∀ {j}, j < P.NL → D.nodeF j = j := fun {j} hj => by
    have hn0 : j < D.nn0 := by rw [c.nn0]; omega
    rw [D.node_old hn0]
    cases hg : D.node.get j with
    | none => rfl
    | some y => have := (nlow hg).1; omega
  have ordAt : ∀ {i nd}, x0.nodes.get i = some nd → P.N0 ≤ i →
      i ≤ D.nodeF i ∧ ∀ k ∈ PTrie.keysA D.node, k < i → D.nodeF k < D.nodeF i := fun {i} {_} hg hi => by
    have hm : i ∈ fullAbove P x0 := List.mem_filter.mpr ⟨PTrie.mem_keysA _ _ _ hg, Nat.ble_eq_true_of_le hi⟩
    have := List.all_eq_true.mp c.nord i hm
    simp only [Bool.and_eq_true, Nat.ble_eq, List.all_eq_true] at this
    exact ⟨this.1, fun k hk hki => Nat.blt_eq.mp (or_not_true (this.2 k hk) (Nat.blt_eq.mpr hki))⟩
  refine
    { bigFix := ?_, bigFixHi := ?_, nonneg := ?_, present := ?_, hinj := ?_, hlt := fun h hp => (hOK hp).1,
      hband := fun h hp hl' => (hOK hp).2.2.2.2.2 hl', hfreshR := ?_, zero := ?_, hnext := ⟨hlox, hc1⟩,
      absent0 := ⟨c.absent0a, c.absent0b⟩, arrs := fun h hp => (hOK hp).2.2.2.1, objs := ?_, cfgCanon := ?_,
      traced := ?_, node0 := ?_, nid := ?_, nall := ?_, norder := ?_, nfull := ?_, nodes := ?_, ninj := ?_,
      nlt := ?_, nfresh := ?_, nband := ⟨hNL, hN0⟩, nle := hc2, tokens := c.tokens, items := ?_,
      itemsPresent := ?_, pending := c.pending, errh := c.errh, files := c.files, arch := c.arch,
      sizes := c.sizes, wired := c.wired, cl := checkSSt_sound c.ssT }
  · intro i hi
    rw [c.big]
    exact D.big_fixed c.band hlo0 hlohi i (by unfold BigFixed; omega)
  · intro i hi hi2
    rw [c.big]
    exact D.big_fixed c.band hlo0 hlohi i (by unfold BigFixed; omega)
  · intro h; rw [c.big]; exact D.big_nonneg h
  · intro h hp
    obtain ⟨_, h2, h3, -, -, -⟩ := hOK hp
    refine ⟨?_, phB_iff.mp h3⟩
    rw [handle_eq hp]
    unfold RData.bigHi at h2
    refine ⟨by rw [c.big]; exact D.big_small h2, ?_, ?_⟩
    · show σ.region (4 * _ + 0) = 4 * D.hd _ + 0
      rw [c.region]; exact D.region_hd (by decide) (by omega)
    · rw [c.region]; exact D.region_hd (by decide) (by omega)
  · intro a b ha hb he
    rw [handle_eq ha, handle_eq hb] at he
    refine ren_inj (f := D.hd) (fun x hx => ?_) c.hren a b (phB_iff.mpr ha) (phB_iff.mpr hb) he
    exact D.hd_old (by rw [c.nh0]; exact (hOK (phB_iff.mp hx)).1)
  · intro k hk
    have r0 := D.region_fresh k 0 (by decide) (by rw [c.nh0]; omega)
    have r1 := D.region_fresh k 1 (by decide) (by rw [c.nh0]; omega)
    rw [c.nh0, c.nh1] at r0 r1
    rw [c.region]
    exact ⟨r0, r1⟩
  · rw [c.big]; exact D.big_zero c.band c.hbelow hlo hlo0 (Nat.blt_eq.mp c.nh1_pos)
  · intro h hp
    cases ho : x0.objs.get h with
    | none =>
      have := (hOK hp).2.2.2.2.1
      rw [ho] at this
      simpa using this
    | some o =>
      have := List.map_inj_left.mp c.objs h (PTrie.mem_keysA _ _ _ ho)
      rw [ho] at this
      exact this
  · intro h cf hc p hp d hd
    have := List.all_eq_true.mp c.objok h (PTrie.mem_keysA _ _ _ hc)
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  · intro h o ho i hi
    have := List.all_eq_true.mp c.objok h (PTrie.mem_keysA _ _ _ ho)
    simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq] at this
    exact this.1 i hi
  · rw [c.node]; exact nid hNL0
  · intro j hj; rw [c.node]; exact nid hj
  · intro j hj
    rw [c.node]
    have hn0 : j < D.nn0 := by rw [c.nn0]; exact hj
    cases hg : D.node.get j with
    | none => rw [D.node_old hn0, hg]; simp only [Option.getD_none]; omega
    | some y => exact (nlow hg).2
  · intro i hp hf j hj
    rw [c.node]
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    rcases hf with hf | hf
    · rw [nid hf, nid (by omega)]; exact hj
    · obtain ⟨hii, hk⟩ := ordAt hg hf
      have hj0 : j < D.nn0 := by rw [c.nn0]; have := nlt hg; omega
      cases hgj : D.node.get j with
      | none => rw [D.node_old hj0, hgj]; simp only [Option.getD_none]; omega
      | some y => exact hk j (PTrie.mem_keysA _ _ _ hgj) hj
  · intro i hp hf
    rw [c.node]
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    rcases hf with hf | hf
    · left; rw [nid hf]; exact hf
    · right; have := (ordAt hg hf).1; omega
  · intro i nd hg
    have := nOK hg
    simp only [nodeOKF, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : x1.nodes.get (σ.node i) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq, Nat.beq_eq, List.all_eq_true] at hrest
      obtain ⟨⟨⟨⟨hs, hd⟩, hcan⟩, hin⟩, _⟩ := hrest
      refine ⟨nd1, rfl, hs, hd, hcan, fun hf => ⟨?_, ?_⟩⟩
      · have hm : i ∈ fullKeysF P x0 := List.mem_filter.mpr ⟨PTrie.mem_keysA _ _ _ hg, fullB_of hf⟩
        have := List.map_inj_left.mp c.prims i hm
        rw [h1, hg] at this
        simpa using this
      · exact of_decide_eq_true (or_not_true hin (fullB_of hf))
  · intro a b ha hb he
    rw [c.node] at he
    refine ren_inj (f := D.nodeF) (fun x hx => ?_) c.nren a b ha hb he
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hx
    exact D.node_old (by rw [c.nn0]; exact nlt hg)
  · intro i hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    exact nlt hg
  · intro k; rw [c.node, ← c.nn0, D.node_fresh, c.nn1]
  · intro k hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := nOK hg
    simp only [nodeOKF, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : x1.nodes.get (σ.node k) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hrest
      exact hrest.2
  · intro k hk
    obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hk
    exact List.all_eq_true.mp c.items k (PTrie.mem_keysA _ _ _ ht)

/-- **The native shift from its checks**, the map's addresses `D.a`'s. -/
theorem nshift_of {y0 y1 : Host.Load.LSt} (c : MChecks P n0 σ D hinv ninv y0.mlx y1.mlx) (hhost : y1.host = y0.host)
    (ha : ∀ a, σ.a a = D.a a) : NShift P n0 σ y0 y1 where
  host := hhost
  hostReg := fun _ hh => by rw [c.region]; exact D.region_host hh
  cbr := fun a => by rw [c.region, ha]; exact D.region_cb a
  mlx := mshift_of c

end

/-! ## Checks in chunks

A check over a long list (a native state's 18 000 handles) as checks of its `take c` chunks along `drop c`, each its own
declaration (and module), so the kernel's caches stay per chunk. -/

theorem all_take_drop {p : Nat → Bool} {l : List Nat} (c : Nat) (h1 : (l.take c).all p = true)
    (h2 : (l.drop c).all p = true) : l.all p = true := by
  rw [← List.take_append_drop c l, List.all_append, h1, h2]; rfl

theorem all_of_nil {p : Nat → Bool} {l : List Nat} (h : l = []) : l.all p = true := by rw [h]; rfl

theorem map_take_drop {β : Type} {f g : Nat → β} {l : List Nat} (c : Nat) (h1 : (l.take c).map f = (l.take c).map g)
    (h2 : (l.drop c).map f = (l.drop c).map g) : l.map f = l.map g := by
  rw [← List.take_append_drop c l, List.map_append, List.map_append, h1, h2]

theorem map_of_nil {β : Type} {f g : Nat → β} {l : List Nat} (h : l = []) : l.map f = l.map g := by rw [h]; rfl

/-! ## Distinct lists -/

/-- No element repeats: each is absent from a store of the earlier ones (linear in the list, unlike `List.Nodup`'s
decision). -/
def nodupT : List Nat → PTrie Unit → Bool
  | [], _ => true
  | a :: l, t => (t.get a).isNone && Nat.blt (a / 4096) (4 ^ 31) && nodupT l (t.set a ())

theorem nodupT_sound : ∀ {l : List Nat} {t : PTrie Unit}, nodupT l t = true → (∀ a ∈ l, t.get a = none) ∧ l.Nodup
  | [], _, _ => ⟨fun _ h => (by cases h), List.nodup_nil⟩
  | a :: l, t, h => by
    simp only [nodupT, Bool.and_eq_true, Option.isNone_iff_eq_none, Nat.blt_eq] at h
    obtain ⟨⟨ha, hb⟩, hl⟩ := h
    obtain ⟨hn, hnd⟩ := nodupT_sound hl
    have hget : ∀ m, (t.set a ()).get m = if m = a then some () else t.get m := PTrie.get_set t a () hb
    refine ⟨fun b hb' => ?_, List.nodup_cons.mpr ⟨fun hm => ?_, hnd⟩⟩
    · rcases List.mem_cons.mp hb' with rfl | hm
      · exact ha
      · have := hn b hm
        rw [hget b] at this
        by_cases e : b = a
        · rw [if_pos e] at this; cases this
        · rwa [if_neg e] at this
    · have := hn a hm
      rw [hget a, if_pos rfl] at this
      cases this

/-! ## A compaction map's addresses -/

/-- The compaction map's addresses are an `RData`'s whose renamed addresses are the result places. -/
theorem compact_a_eq {n0 n1 nS : Nat} {pl : List Nat} {nr : List NumV} {big : Int → Int} {region node : Nat → Nat}
    {D : RData} (h0 : D.n0 = n0 + pl.length) (h1 : D.n1 = n1)
    (hk : (PTrie.keysA D.heap).all (fun x => Nat.ble n0 x) = true)
    (hv : (List.range pl.length).all (fun j => decide (D.heap.get (n0 + j) = nth? pl j)) = true) :
    ∀ x, (Conv.Map.compact n0 n1 nS pl nr big region node).a x = D.a x := by
  intro x
  show (if x < n0 then x else if x - n0 < pl.length then (nth? pl (x - n0)).getD 0 else n1 + (x - n0 - pl.length)) = _
  by_cases hx : x < n0
  · rw [if_pos hx, D.a_old (by omega)]
    cases hg : D.heap.get x with
    | none => rfl
    | some y =>
      have := List.all_eq_true.mp hk x (PTrie.mem_keysA _ _ _ hg)
      have := Nat.le_of_ble_eq_true this
      omega
  · rw [if_neg hx]
    by_cases hp : x - n0 < pl.length
    · rw [if_pos hp, D.a_old (by omega)]
      have := of_decide_eq_true (List.all_eq_true.mp hv (x - n0) (List.mem_range.mpr hp))
      rw [show n0 + (x - n0) = x by omega] at this
      obtain ⟨p, hp'⟩ := Conv.nth?_some_of_lt hp
      rw [this, hp']
      rfl
    · rw [if_neg hp]
      have e := D.a_fresh (x - D.n0)
      rw [show D.n0 + (x - D.n0) = x by omega] at e
      rw [e, h1]
      omega

end Host.Ts.Sim.Template
