import host.sim.conv.NFix
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # The native shift of a compaction from its footprint

`Template.mshift_of` builds `MShift` from `MChecks`, whose handle, object, node, primitive, order and item
checks run over every key of the canonical native state (A4's 33 chunk modules per site). `MFacts` is
`MChecks` with those checks as per-key facts, and `mshift_of_facts` its `mshift_of`;
`MChecks.toFacts` is the agreement (the full checks give the facts). A compaction gets the facts from its
footprint (`mfacts_of_foot`): the canonical state keeps the call's entries off its changed lists (the
written caller handles and items, the results), the merged state keeps them off the stage's footprint,
the compaction map fixes the call's names (`FixOld`) and the call's entries mention only those
(`NClean`), so only the changed lists are checked (`MFoot`). -/

section
variable (P : LoadP) (n0 : Nat) (σ : Map) (D : RData) (hinv ninv : PTrie Nat) (x0 x1 : NSt)

/-- **The native shift's facts**: `MChecks` with the per-key checks as facts. -/
structure MFacts : Prop where
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
  handles : ∀ h, PH x0 h → handleOK σ P.lo x0 x1 h = true
  hren : checkRenG D.hnd hinv (phB x0) = true
  band : D.checkBand P.lo = true
  nh1_pos : Nat.blt 0 D.nh1 = true
  objs : ∀ h o, x0.objs.get h = some o → x1.objs.get (σ.handle h) = some (σ.nobj o)
  objok : ∀ h o, x0.objs.get h = some o → objOK σ P.NL x0 h = true
  nodes : ∀ i nd, x0.nodes.get i = some nd → nodeOKF σ P x0 x1 i = true
  prims : ∀ i nd, x0.nodes.get i = some nd → Full P i →
    (x1.nodes.get (σ.node i)).map Node.prim = some (σ.prim nd.prim)
  nren : checkRenG D.node ninv (pnB x0) = true
  nlow : (PTrie.keysA D.node).all (fun k => Nat.ble P.NL k && Nat.blt (D.nodeF k) x1.nnext) = true
  nord : ∀ i nd, x0.nodes.get i = some nd → P.N0 ≤ i →
    i ≤ D.nodeF i ∧ ∀ k ∈ PTrie.keysA D.node, k < i → D.nodeF k < D.nodeF i
  items : ∀ k v, x0.items.get k = some v → PN x0 k
  cl : SSt (· < n0) x0
  absent0a : x0.arrs.get 0 = none
  absent0b : x0.objs.get 0 = none
  tokens : x1.tokens = []
  pending : x1.pending = x0.pending.map σ.pend
  errh : x1.errh = x0.errh.map σ.arg
  files : x1.files = x0.files
  arch : x1.arch = x0.arch
  sizes : x1.deviceSizes = x0.deviceSizes
  wired : x1.wired = x0.wired

end

section
variable {P : LoadP} {n0 : Nat} {σ : Map} {D : RData} {hinv ninv : PTrie Nat} {x0 x1 : NSt}

/-- **The full checks give the facts** (agreement with `MChecks`). -/
theorem MChecks.toFacts (c : MChecks P n0 σ D hinv ninv x0 x1) : MFacts P n0 σ D hinv ninv x0 x1 where
  big := c.big
  region := c.region
  node := c.node
  nh0 := c.nh0
  nh1 := c.nh1
  nn0 := c.nn0
  nn1 := c.nn1
  lo := c.lo
  counters := c.counters
  nband := c.nband
  hbelow := c.hbelow
  handles h hp := List.all_eq_true.mp c.handles h (mem_handlesOfA hp)
  hren := c.hren
  band := c.band
  nh1_pos := c.nh1_pos
  objs h o ho := by
    have := List.map_inj_left.mp c.objs h (PTrie.mem_keysA _ _ _ ho)
    rw [ho] at this
    exact this
  objok h o ho := List.all_eq_true.mp c.objok h (PTrie.mem_keysA _ _ _ ho)
  nodes i nd hg := List.all_eq_true.mp c.nodes _ (PTrie.mem_keysA _ _ _ hg)
  prims i nd hg hf := by
    have hm : i ∈ fullKeysF P x0 := List.mem_filter.mpr ⟨PTrie.mem_keysA _ _ _ hg, fullB_of hf⟩
    have := List.map_inj_left.mp c.prims i hm
    rw [hg] at this
    exact this
  nren := c.nren
  nlow := c.nlow
  nord i nd hg hi := by
    have hm : i ∈ fullAbove P x0 := List.mem_filter.mpr ⟨PTrie.mem_keysA _ _ _ hg, Nat.ble_eq_true_of_le hi⟩
    have := List.all_eq_true.mp c.nord i hm
    simp only [Bool.and_eq_true, Nat.ble_eq, List.all_eq_true] at this
    exact ⟨this.1, fun k hk hki => Nat.blt_eq.mp (or_not_true (this.2 k hk) (Nat.blt_eq.mpr hki))⟩
  items k v hk := List.all_eq_true.mp c.items k (PTrie.mem_keysA _ _ _ hk)
  cl := checkSSt_sound c.ssT
  absent0a := c.absent0a
  absent0b := c.absent0b
  tokens := c.tokens
  pending := c.pending
  errh := c.errh
  files := c.files
  arch := c.arch
  sizes := c.sizes
  wired := c.wired

/-- **The mlx part of the native shift from its facts** (`Template.mshift_of`). -/
theorem mshift_of_facts (c : MFacts P n0 σ D hinv ninv x0 x1) : MShift P n0 σ x0 x1 := by
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
    have := c.handles h hp
    simp only [handleOK, Bool.and_eq_true, beq_iff_eq, Nat.blt_eq] at this
    obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := this
    exact ⟨h1, h2, h3, h4, h5, fun hl' => Nat.le_of_ble_eq_true (or_not_true h6 (Nat.ble_eq_true_of_le hl'))⟩
  have handle_eq : ∀ {h}, PH x0 h → σ.handle h = D.hd h := fun hp => by
    show (σ.big (Int.ofNat _)).toNat = _
    rw [c.big, D.big_small (hOK hp).2.1]; rfl
  have nOK : ∀ {i nd}, x0.nodes.get i = some nd → nodeOKF σ P x0 x1 i = true := fun hg => c.nodes _ _ hg
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
      i ≤ D.nodeF i ∧ ∀ k ∈ PTrie.keysA D.node, k < i → D.nodeF k < D.nodeF i := fun {i} {nd} hg hi =>
    c.nord i nd hg hi
  refine
    { bigFix := ?_, bigFixHi := ?_, nonneg := ?_, present := ?_, hinj := ?_, hlt := fun h hp => (hOK hp).1,
      hband := fun h hp hl' => (hOK hp).2.2.2.2.2 hl', hfreshR := ?_, zero := ?_, hnext := ⟨hlox, hc1⟩,
      absent0 := ⟨c.absent0a, c.absent0b⟩, arrs := fun h hp => (hOK hp).2.2.2.1, objs := ?_, cfgCanon := ?_,
      traced := ?_, node0 := ?_, nid := ?_, nall := ?_, norder := ?_, nfull := ?_, nodes := ?_, ninj := ?_,
      nlt := ?_, nfresh := ?_, nband := ⟨hNL, hN0⟩, nle := hc2, tokens := c.tokens, items := ?_,
      itemsPresent := ?_, pending := c.pending, errh := c.errh, files := c.files, arch := c.arch,
      sizes := c.sizes, wired := c.wired, cl := c.cl }
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
    | some o => exact c.objs h o ho
  · intro h cf hc p hp d hd
    have := c.objok h _ hc
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  · intro h o ho i hi
    have := c.objok h o ho
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
      · have := c.prims i nd hg hf
        rw [h1] at this
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
    exact c.items k t ht

/-- **The native shift from its facts**, the map's addresses `D.a`'s (`Template.nshift_of`). -/
theorem nshift_of_facts {y0 y1 : Host.Load.LSt} (c : MFacts P n0 σ D hinv ninv y0.mlx y1.mlx)
    (hhost : y1.host = y0.host) (ha : ∀ a, σ.a a = D.a a) : NShift P n0 σ y0 y1 where
  host := hhost
  hostReg := fun _ hh => by rw [c.region]; exact D.region_host hh
  cbr := fun a => by rw [c.region, ha]; exact D.region_cb a
  mlx := mshift_of_facts c

end

/-! ## The facts from the footprint -/

section
variable (P : LoadP) (n0 : Nat) (σ : Map) (D : RData) (hinv ninv : PTrie Nat) (xC x0 x1 : NSt) (cC : Cnt)
  (lh ln li wS nS iS : List Nat)

/-- **A compaction's native footprint and its checks**: `MChecks`'s small checks; the call state `xC`
under the bookkeeping, its names fixed by `σ`, its own facts (from the call's relation); the canonical
state `x0` keeping the call's entries off `lh` (handles), `ln` (nodes), `li` (items), the merged state `x1`
keeping them off the stage's footprint `wS`, `nS`, `iS`; and the checks over the changed lists only. -/
structure MFoot : Prop where
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
  hren : checkRenG D.hnd hinv (phB x0) = true
  band : D.checkBand P.lo = true
  nh1_pos : Nat.blt 0 D.nh1 = true
  nren : checkRenG D.node ninv (pnB x0) = true
  nlow : (PTrie.keysA D.node).all (fun k => Nat.ble P.NL k && Nat.blt (D.nodeF k) x1.nnext) = true
  absent0a : x0.arrs.get 0 = none
  absent0b : x0.objs.get 0 = none
  tokens : x1.tokens = []
  pending : x1.pending = x0.pending.map σ.pend
  errh : x1.errh = x0.errh.map σ.arg
  files : x1.files = x0.files
  arch : x1.arch = x0.arch
  sizes : x1.deviceSizes = x0.deviceSizes
  wired : x1.wired = x0.wired
  /-- The call: its names fixed, its entries old, its own facts. -/
  fix : FixOld cC σ
  clean : NClean cC xC
  cxn : cC.xn = xC.next
  cnn : cC.nn = xC.nnext
  hltC : ∀ h, PH xC h → h < xC.next
  nltC : ∀ i, PN xC i → i < xC.nnext
  itemsC : ∀ k v, xC.items.get k = some v → PN xC k
  tracedC : ∀ h o, xC.objs.get h = some o → ∀ i ∈ objTraces o, i < P.NL
  cl : SSt (· < n0) x0
  le0 : (Nat.ble xC.next x0.next && Nat.ble xC.nnext x0.nnext && Nat.ble xC.next RData.bigHi) = true
  nodeKeys : (PTrie.keysA D.node).all (Nat.ble xC.nnext) = true
  /-- The footprints: the canonical and the merged state keep the call's entries off their lists. -/
  keep0a : x0.arrs = Stage.setAll xC.arrs (lh.filterMap fun i => (x0.arrs.get i).map (i, ·))
  keep0o : x0.objs = Stage.setAll xC.objs (lh.filterMap fun i => (x0.objs.get i).map (i, ·))
  keep0n : x0.nodes = Stage.setAll xC.nodes (ln.filterMap fun i => (x0.nodes.get i).map (i, ·))
  keep0i : x0.items = Stage.setAll xC.items (li.filterMap fun i => (x0.items.get i).map (i, ·))
  keep1a : x1.arrs = Stage.setAll xC.arrs (wS.filterMap fun i => (x1.arrs.get i).map (i, ·))
  keep1o : x1.objs = Stage.setAll xC.objs (wS.filterMap fun i => (x1.objs.get i).map (i, ·))
  keep1n : x1.nodes = Stage.setAll xC.nodes (nS.filterMap fun i => (x1.nodes.get i).map (i, ·))
  keep1i : x1.items = Stage.setAll xC.items (iS.filterMap fun i => (x1.items.get i).map (i, ·))
  bounds : (lh ++ ln ++ li ++ wS ++ nS ++ iS).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
  /-- The stage's written caller handles and items are on the canonical lists; its nodes and the
  canonical changed nodes are fresh. -/
  incW : wS.all (fun h => !Nat.blt h xC.next || lh.contains h) = true
  incI : iS.all (fun k => !Nat.blt k xC.nnext || li.contains k) = true
  incN : nS.all (Nat.ble xC.nnext) = true
  lnFresh : ln.all (Nat.ble xC.nnext) = true
  /-- The checks over the changed lists. -/
  chandles : lh.all (handleOK σ P.lo x0 x1) = true
  cobjs : lh.map (fun h => x1.objs.get (σ.handle h)) = lh.map (fun h => (x0.objs.get h).map σ.nobj)
  cobjok : lh.all (objOK σ P.NL x0) = true
  cnodes : ln.all (nodeOKF σ P x0 x1) = true
  cprims : (ln.filter (fullB P)).map (fun i => (x1.nodes.get (σ.node i)).map Node.prim) =
    (ln.filter (fullB P)).map (fun i => (x0.nodes.get i).map fun nd => σ.prim nd.prim)
  cnord : (ln.filter (Nat.ble P.N0)).all (fun i => Nat.ble i (D.nodeF i) &&
    (PTrie.keysA D.node).all fun k => !Nat.blt k i || Nat.blt (D.nodeF k) (D.nodeF i)) = true
  citems : li.all (pnB x0) = true
  citemsImg : li.all (fun k => decide (x1.items.get (σ.node k) = (x0.items.get k).map σ.nv)) = true

end

section
variable {P : LoadP} {n0 : Nat} {σ : Map} {D : RData} {hinv ninv : PTrie Nat} {xC x0 x1 : NSt} {cC : Cnt}
  {lh ln li wS nS iS : List Nat}

theorem dim_num_fix {c : Cnt} (hf : FixOld c σ) {d : Dim} (h : oldDimB c d = true) : σ.nv d.num = d.num := by
  rcases d with i | ⟨f | i⟩
  · rfl
  · rfl
  · exact fix_nv hf (x := .ref i) h

theorem not_mem_of_contains {l : List Nat} {a : Nat} (h : l.contains a = false) : a ∉ l := by
  intro hm
  have : l.contains a = true := List.contains_iff_mem.mpr hm
  rw [h] at this; cases this

/-- **The native shift's facts from the footprint.** -/
theorem mfacts_of_foot (c : MFoot P n0 σ D hinv ninv xC x0 x1 cC lh ln li wS nS iS) :
    MFacts P n0 σ D hinv ninv x0 x1 := by
  have hbd := c.bounds
  simp only [List.all_append, Bool.and_eq_true] at hbd
  obtain ⟨⟨⟨⟨⟨blh, bln⟩, bli⟩, bwS⟩, bnS⟩, biS⟩ := hbd
  have k0a := get_keep c.keep0a blh
  have k0o := get_keep c.keep0o blh
  have k0n := get_keep c.keep0n bln
  have k0i := get_keep c.keep0i bli
  have k1a := get_keep c.keep1a bwS
  have k1o := get_keep c.keep1o bwS
  have k1n := get_keep c.keep1n bnS
  have k1i := get_keep c.keep1i biS
  have hle := c.le0
  simp only [Bool.and_eq_true, Nat.ble_eq] at hle
  obtain ⟨⟨hle1, hle2⟩, hbig⟩ := hle
  -- a kept handle: below the call's counter, off the stage's footprint, fixed by `σ`
  have kh : ∀ h, h ∉ lh → PH x0 h → h < xC.next ∧ h ∉ wS ∧ σ.handle h = h := by
    intro h hm hp
    have hpC : PH xC h := by unfold PH at hp ⊢; rw [← k0a h hm, ← k0o h hm]; exact hp
    have hlt := c.hltC h hpC
    refine ⟨hlt, fun hw => ?_, ?_⟩
    · have := List.all_eq_true.mp c.incW h hw
      rw [Nat.blt_eq.mpr hlt, Bool.not_true, Bool.false_or] at this
      exact hm (List.contains_iff_mem.mp this)
    · refine fix_handle c.fix ?_
      have hk : h < 2 ^ 62 := by unfold RData.bigHi at hbig; omega
      rw [oldBigB_lo hk, c.cxn, Nat.blt_eq.mpr hlt, Bool.true_or]
  -- a kept node: below the call's counter, off the stage's nodes and the canonical ones, fixed
  have kn : ∀ i nd, i ∉ ln → x0.nodes.get i = some nd →
      xC.nodes.get i = some nd ∧ x1.nodes.get i = some nd ∧ i < xC.nnext ∧ σ.node i = i := by
    intro i nd hm hg
    have hgC : xC.nodes.get i = some nd := by rw [← k0n i hm]; exact hg
    have hlt := c.nltC i (by unfold PN; rw [hgC]; rfl)
    have hnS : i ∉ nS := fun hn => by
      have := Nat.le_of_ble_eq_true (List.all_eq_true.mp c.incN i hn); omega
    refine ⟨hgC, by rw [k1n i hnS]; exact hgC, hlt, c.fix.node i (by rw [c.cnn]; exact hlt)⟩
  -- a kept item: off the stage's items
  have ki : ∀ k, k ∉ li → k < xC.nnext → k ∉ iS := fun k hm hlt hi => by
    have := List.all_eq_true.mp c.incI k hi
    rw [Nat.blt_eq.mpr hlt, Bool.not_true, Bool.false_or] at this
    exact hm (List.contains_iff_mem.mp this)
  refine
    { big := c.big, region := c.region, node := c.node, nh0 := c.nh0, nh1 := c.nh1, nn0 := c.nn0, nn1 := c.nn1,
      lo := c.lo, counters := c.counters, nband := c.nband, hbelow := c.hbelow, handles := ?_, hren := c.hren,
      band := c.band, nh1_pos := c.nh1_pos, objs := ?_, objok := ?_, nodes := ?_, prims := ?_, nren := c.nren,
      nlow := c.nlow, nord := ?_, items := ?_, cl := c.cl, absent0a := c.absent0a, absent0b := c.absent0b,
      tokens := c.tokens, pending := c.pending, errh := c.errh, files := c.files, arch := c.arch,
      sizes := c.sizes, wired := c.wired }
  · -- handles
    intro h hp
    by_cases hm : h ∈ lh
    · exact List.all_eq_true.mp c.chandles h hm
    · obtain ⟨hlt, hw, he⟩ := kh h hm hp
      have ea0 := k0a h hm
      have eo0 := k0o h hm
      have ea1 := k1a h hw
      have eo1 := k1o h hw
      have harr : (xC.arrs.get h).map σ.node = xC.arrs.get h := by
        cases e : xC.arrs.get h with
        | none => rfl
        | some j => simp only [Option.map_some, c.fix.node j (c.clean.arrs h j e)]
      have hpC : PH xC h := by unfold PH at hp ⊢; rw [← ea0, ← eo0]; exact hp
      have hph : phB x1 h = true := by rw [phB_iff]; unfold PH; rw [ea1, eo1]; exact hpC
      have hb1 : Nat.blt h x0.next = true := Nat.blt_eq.mpr (Nat.lt_of_lt_of_le hlt hle1)
      have hb2 : Nat.blt h RData.bigHi = true := Nat.blt_eq.mpr (by unfold RData.bigHi at hbig ⊢; omega)
      have hbd : (!Nat.ble P.lo h || Nat.ble P.lo h) = true := by cases Nat.ble P.lo h <;> rfl
      show (Nat.blt h x0.next && Nat.blt h RData.bigHi && phB x1 (σ.handle h) &&
        (x1.arrs.get (σ.handle h) == (x0.arrs.get h).map σ.node) &&
        ((x1.objs.get (σ.handle h)).isSome == (x0.objs.get h).isSome) &&
        (!Nat.ble P.lo h || Nat.ble P.lo (σ.handle h))) = true
      rw [he, ea1, eo1, ea0, eo0, harr, hb1, hb2, hph, beq_self_eq_true, beq_self_eq_true, hbd]
      rfl
  · -- objects
    intro h o ho
    by_cases hm : h ∈ lh
    · have := List.map_inj_left.mp c.cobjs h hm
      rw [ho] at this
      exact this
    · obtain ⟨-, hw, he⟩ := kh h hm (.inr (by rw [ho]; rfl))
      have hoC : xC.objs.get h = some o := by rw [← k0o h hm]; exact ho
      rw [he, k1o h hw, hoC, fix_nobj c.fix (c.clean.objs h o hoC)]
  · -- per-object checks
    intro h o ho
    by_cases hm : h ∈ lh
    · exact List.all_eq_true.mp c.cobjok h hm
    · have hoC : xC.objs.get h = some o := by rw [← k0o h hm]; exact ho
      have htr := c.tracedC h o hoC
      have hold := c.clean.objs h o hoC
      simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq]
      refine ⟨htr, ?_⟩
      cases o with
      | cfg cf =>
        simp only [oldObjB, oldCfgB, Bool.and_eq_true, List.all_eq_true] at hold
        simp only [List.all_eq_true, decide_eq_true_eq]
        intro p hp d hd
        have hdo := hold.1.1.1.1 p hp d hd
        rw [fix_dim c.fix hdo, dim_num_fix c.fix hdo]
      | _ => rfl
  · -- per-node checks
    intro i nd hg
    by_cases hm : i ∈ ln
    · exact List.all_eq_true.mp c.cnodes i hm
    · obtain ⟨hgC, hg1, hlt, he⟩ := kn i nd hm hg
      have hold := c.clean.nodes i nd hgC
      simp only [oldNodeB, Bool.and_eq_true] at hold
      have hitem : x1.items.get (σ.node i) = (x0.items.get i).map σ.nv := by
        by_cases hli : i ∈ li
        · exact of_decide_eq_true (List.all_eq_true.mp c.citemsImg i hli)
        · rw [he, k1i i (ki i hli hlt), k0i i hli]
          cases e : xC.items.get i with
          | none => rfl
          | some v => simp only [Option.map_some, fix_nv c.fix (c.clean.items i v e)]
      have hsh : σ.dims nd.shape = nd.shape := fix_dims c.fix hold.2
      have hins : nd.ins.map σ.node = nd.ins := fix_nodes c.fix hold.1.2
      have hall : nd.shape.all (fun d => decide ((σ.dim d).num = σ.nv d.num)) = true :=
        List.all_eq_true.mpr fun d hd => by
          have hdo := List.all_eq_true.mp hold.2 d hd
          rw [fix_dim c.fix hdo, dim_num_fix c.fix hdo]; exact decide_eq_true rfl
      have hit : x1.items.get i = (x0.items.get i).map σ.nv := by have := hitem; rwa [he] at this
      have hb : Nat.blt i x0.nnext = true := Nat.blt_eq.mpr (Nat.lt_of_lt_of_le hlt hle2)
      simp [nodeOKF, hg, he, hg1, hsh, hins, hall, hit, hb]
  · -- full nodes' primitives
    intro i nd hg hf
    by_cases hm : i ∈ ln
    · have hmf : i ∈ ln.filter (fullB P) := List.mem_filter.mpr ⟨hm, fullB_of hf⟩
      have := List.map_inj_left.mp c.cprims i hmf
      rw [hg] at this
      exact this
    · obtain ⟨hgC, hg1, -, he⟩ := kn i nd hm hg
      have hold := c.clean.nodes i nd hgC
      simp only [oldNodeB, Bool.and_eq_true] at hold
      rw [he, hg1, Option.map_some, fix_prim c.fix hold.1.1]
  · -- the order of the renamed nodes
    intro i nd hg hi
    by_cases hm : i ∈ ln
    · have hmf : i ∈ ln.filter (Nat.ble P.N0) := List.mem_filter.mpr ⟨hm, Nat.ble_eq_true_of_le hi⟩
      have := List.all_eq_true.mp c.cnord i hmf
      simp only [Bool.and_eq_true, Nat.ble_eq, List.all_eq_true] at this
      exact ⟨this.1, fun k hk hki => Nat.blt_eq.mp (or_not_true (this.2 k hk) (Nat.blt_eq.mpr hki))⟩
    · obtain ⟨-, -, hlt, he⟩ := kn i nd hm hg
      rw [c.node] at he
      refine ⟨Nat.le_of_eq he.symm, fun k hk hki => ?_⟩
      have := Nat.le_of_ble_eq_true (List.all_eq_true.mp c.nodeKeys k hk)
      omega
  · -- readback items of present nodes
    intro k v hk
    by_cases hm : k ∈ li
    · exact List.all_eq_true.mp c.citems k hm
    · have hkC : xC.items.get k = some v := by rw [← k0i k hm]; exact hk
      have hpC := c.itemsC k v hkC
      have hlt := c.nltC k hpC
      have hln : k ∉ ln := fun hn => by
        have := Nat.le_of_ble_eq_true (List.all_eq_true.mp c.lnFresh k hn); omega
      unfold PN at hpC ⊢
      rw [k0n k hln]; exact hpC

/-- **A compaction's native shift from its footprint.** -/
theorem nshift_of_foot {y0 y1 : Host.Load.LSt}
    (c : MFoot P n0 σ D hinv ninv xC y0.mlx y1.mlx cC lh ln li wS nS iS) (hhost : y1.host = y0.host)
    (ha : ∀ a, σ.a a = D.a a) : NShift P n0 σ y0 y1 :=
  nshift_of_facts (mfacts_of_foot c) hhost ha

end

end Host.Ts.Sim.Conv
