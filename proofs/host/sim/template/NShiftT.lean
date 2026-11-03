import host.sim.template.NShiftOf
import host.sim.conv.TraceShift

/-! # A native shift renaming nodes above `NB`, from its checks

`MChecks` for `Conv.TraceMShift`, the shift of a class whose compiled traces sit at other node numbers than the template's. Renames start at `NB`, and
the order is checked along each present node's inputs. The band is empty, so every node corresponds fully. -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Conv

/-- A present node's image is positive, and each input below it maps below it. -/
def edgeOK (σ : Map) (x0 : NSt) (i : Nat) : Bool :=
  (Nat.beq i 0 || Nat.blt 0 (σ.node i)) && match x0.nodes.get i with
    | some nd => nd.ins.all fun j => !Nat.blt j i || Nat.blt (σ.node j) (σ.node i)
    | none => true

/-- The kernel checks of a native shift renaming nodes above `NB`. -/
structure TChecks (P : LoadP) (NB n0 : Nat) (σ : Map) (D : RData) (hinv ninv : PTrie Nat) (x0 x1 : NSt) : Prop where
  big : σ.big = D.big
  region : σ.region = D.region
  node : σ.node = D.nodeF
  nh0 : D.nh0 = x0.next
  nh1 : D.nh1 = x1.next
  nn0 : D.nn0 = x0.nnext
  nn1 : D.nn1 = x1.nnext
  lo : (Nat.blt 0 P.lo && Nat.ble P.lo x0.next && Nat.ble P.lo RData.bigHi && Nat.ble RData.bigHi P.E) = true
  counters : (Nat.ble x0.next x1.next && Nat.ble x0.nnext x1.nnext) = true
  nband : (Nat.blt 0 NB && Nat.ble NB P.NL && Nat.ble P.NL P.N0 && Nat.ble P.N0 x0.nnext && Nat.beq P.NL P.N0) = true
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
  nlow : (PTrie.keysA D.node).all (fun k => Nat.ble NB k && Nat.blt (D.nodeF k) x1.nnext) = true
  edges : (PTrie.keysA x0.nodes).all (edgeOK σ x0) = true
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

section
variable {P : LoadP} {NB n0 : Nat} {σ : Map} {D : RData} {hinv ninv : PTrie Nat} {x0 x1 : NSt}

/-- **The mlx part of the shift from its checks.** -/
theorem traceMShift_of (c : TChecks P NB n0 σ D hinv ninv x0 x1) : TraceMShift P NB n0 σ x0 x1 := by
  have hl := c.lo
  simp only [Bool.and_eq_true, Nat.blt_eq, Nat.ble_eq] at hl
  obtain ⟨⟨⟨hlo, hlox⟩, hlohi⟩, hE⟩ := hl
  have hc := c.counters
  simp only [Bool.and_eq_true, Nat.ble_eq] at hc
  obtain ⟨hc1, hc2⟩ := hc
  have hb := c.nband
  simp only [Bool.and_eq_true, Nat.blt_eq, Nat.ble_eq, Nat.beq_eq] at hb
  obtain ⟨⟨⟨⟨hNB0, hNB⟩, hNL⟩, hN0⟩, hfree⟩ := hb
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
  have nlow : ∀ {k y}, D.node.get k = some y → NB ≤ k ∧ D.nodeF k < x1.nnext := fun hg => by
    have := List.all_eq_true.mp c.nlow _ (PTrie.mem_keysA _ _ _ hg)
    simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this
    exact this
  have nid : ∀ {j}, j < NB → D.nodeF j = j := fun {j} hj => by
    have hn0 : j < D.nn0 := by rw [c.nn0]; omega
    rw [D.node_old hn0]
    cases hg : D.node.get j with
    | none => rfl
    | some y => have := (nlow hg).1; omega
  refine
    { bigFix := ?_, bigFixHi := ?_, nonneg := ?_, present := ?_, hinj := ?_, hlt := fun h hp => (hOK hp).1,
      hband := fun h hp hl' => (hOK hp).2.2.2.2.2 hl', hfreshR := ?_, zero := ?_, hnext := ⟨hlox, hc1⟩,
      absent0 := ⟨c.absent0a, c.absent0b⟩, arrs := fun h hp => (hOK hp).2.2.2.1, objs := ?_, cfgCanon := ?_,
      traced := ?_, node0 := ?_, nid := ?_, nbl := hNB, nall := ?_, norder := ?_, nfull := ?_, nodes := ?_, ninj := ?_,
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
  · rw [c.node]; exact nid hNB0
  · intro j hj; rw [c.node]; exact nid hj
  · intro j hj
    rw [c.node]
    have hn0 : j < D.nn0 := by rw [c.nn0]; exact hj
    cases hg : D.node.get j with
    | none => rw [D.node_old hn0, hg]; simp only [Option.getD_none]; omega
    | some y => exact (nlow hg).2
  · intro i hp _ j hj hq
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := List.all_eq_true.mp c.edges i (PTrie.mem_keysA _ _ _ hg)
    simp only [edgeOK, hg, Bool.and_eq_true, Bool.or_eq_true, Nat.beq_eq, Nat.blt_eq, List.all_eq_true] at this
    obtain ⟨h0, hE'⟩ := this
    rcases hq with rfl | ⟨nd', hg', hm⟩
    · have e0 : σ.node 0 = 0 := by rw [c.node]; exact nid hNB0
      rw [e0]
      rcases h0 with h0 | h0
      · omega
      · exact h0
    · rw [hg] at hg'
      obtain rfl := Option.some.inj hg'
      rcases hE' j hm with h | h
      · rw [Nat.blt_eq.mpr hj] at h; exact absurd h (by decide)
      · exact h
  · intro i _ _
    rcases Nat.lt_or_ge (σ.node i) P.NL with h | h
    · exact .inl h
    · exact .inr (by omega)
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

/-- **The shift from its checks**, the map's addresses `D.a`'s. -/
theorem traceNShift_of {y0 y1 : Host.Load.LSt} (c : TChecks P NB n0 σ D hinv ninv y0.mlx y1.mlx) (hhost : y1.host = y0.host)
    (ha : ∀ a, σ.a a = D.a a) : TraceNShift P NB n0 σ y0 y1 where
  host := hhost
  hostReg := fun _ hh => by rw [c.region]; exact D.region_host hh
  cbr := fun a => by rw [c.region, ha]; exact D.region_cb a
  mlx := traceMShift_of c

end

end Host.Ts.Sim.Template
