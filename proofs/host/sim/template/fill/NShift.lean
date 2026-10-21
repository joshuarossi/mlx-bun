import host.sim.template.fill.Shift
import host.sim.template.NShiftGen
import host.sim.template.ok.Ok
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of the shift of case `FILL`: `FILL.s150`'s native state holds a
copy of the template's under `FILL.σ` (`NShift loadP0`). Kernel checks over the
template's present handles, objects and nodes. -/

noncomputable abbrev FILL.X0 : NSt := Base.s0.ffi.mlx
noncomputable abbrev FILL.X1 : NSt := FILL.s150.ffi.mlx

kernel_rfl FILL.nh0_eq : FILL.R.data.nh0 = FILL.X0.next
kernel_rfl FILL.nh1_eq : FILL.R.data.nh1 = FILL.X1.next
kernel_rfl FILL.nn0_eq : FILL.R.data.nn0 = FILL.X0.nnext
kernel_rfl FILL.nn1_eq : FILL.R.data.nn1 = FILL.X1.nnext
kernel_rfl FILL.x0next : FILL.X0.next = 29302
kernel_rfl FILL.x0nnext : FILL.X0.nnext = 22539
kernel_rfl FILL.counters1 : Nat.ble FILL.X0.next FILL.X1.next = true
kernel_rfl FILL.counters2 : Nat.ble FILL.X0.nnext FILL.X1.nnext = true
kernel_rfl FILL.hbelow : FILL.R.data.checkHndBelow = true
kernel_rfl FILL.handles_check :
  (handlesOf FILL.X0).all (handleOK FILL.σ 25000 FILL.X0 FILL.X1) = true
kernel_rfl FILL.hren_check : checkRenG FILL.R.data.hnd FILL.R.hinv (phB FILL.X0) = true
kernel_rfl FILL.objs_check :
  (PTrie.keys FILL.X0.objs).map (fun h => FILL.X1.objs.get (FILL.σ.handle h)) =
    (PTrie.keys FILL.X0.objs).map (fun h => (FILL.X0.objs.get h).map FILL.σ.nobj)
kernel_rfl FILL.objok_check : (PTrie.keys FILL.X0.objs).all (objOK FILL.σ 20000 FILL.X0) = true
kernel_rfl FILL.nodes_check :
  (PTrie.keys FILL.X0.nodes).all (nodeOK FILL.σ 20000 FILL.X0 FILL.X1) = true
kernel_rfl FILL.prims_check :
  (fullKeys 20000 FILL.X0).map (fun i => (FILL.X1.nodes.get (FILL.σ.node i)).map Node.prim) =
    (fullKeys 20000 FILL.X0).map (fun i => (FILL.X0.nodes.get i).map fun nd => FILL.σ.prim nd.prim)
kernel_rfl FILL.nren_check : checkRenG FILL.R.data.node FILL.R.ninv (pnB FILL.X0) = true
kernel_rfl FILL.nlow_check : (PTrie.keys FILL.R.data.node).all
  (fun k => Nat.ble 20000 k && Nat.blt (FILL.R.data.nodeF k) FILL.X1.nnext) = true
kernel_rfl FILL.items0 : PTrie.keys FILL.X0.items = []
kernel_rfl FILL.ssT : checkSSt Base.n FILL.X0 = true
kernel_rfl FILL.absent0a : FILL.X0.arrs.get 0 = none
kernel_rfl FILL.absent0b : FILL.X0.objs.get 0 = none
kernel_rfl FILL.tokens1 : FILL.X1.tokens = []
kernel_rfl FILL.pending_eq : FILL.X1.pending = FILL.X0.pending.map FILL.σ.pend
kernel_rfl FILL.errh_eq : FILL.X1.errh = FILL.X0.errh.map FILL.σ.arg
kernel_rfl FILL.files_eq : FILL.X1.files = FILL.X0.files
kernel_rfl FILL.arch_eq : FILL.X1.arch = FILL.X0.arch
kernel_rfl FILL.sizes_eq : FILL.X1.deviceSizes = FILL.X0.deviceSizes
kernel_rfl FILL.wired_eq : FILL.X1.wired = FILL.X0.wired
kernel_rfl FILL.host_eq : FILL.s150.ffi.host = Base.s0.ffi.host
kernel_rfl FILL.nh1_pos : Nat.blt 0 FILL.R.data.nh1 = true

section
open RData

private theorem FILL.hOK {h : Nat} (hp : PH FILL.X0 h) :
    handleOK FILL.σ 25000 FILL.X0 FILL.X1 h = true :=
  List.all_eq_true.mp FILL.handles_check h (mem_handlesOf hp)

private theorem FILL.hOK' {h : Nat} (hp : PH FILL.X0 h) :
    h < FILL.X0.next ∧ h < bigHi ∧ phB FILL.X1 (FILL.σ.handle h) = true ∧
      FILL.X1.arrs.get (FILL.σ.handle h) = (FILL.X0.arrs.get h).map FILL.σ.node ∧
      (FILL.X1.objs.get (FILL.σ.handle h)).isSome = (FILL.X0.objs.get h).isSome ∧
      (25000 ≤ h → 25000 ≤ FILL.σ.handle h) := by
  have := FILL.hOK hp
  simp only [handleOK, Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true, Bool.not_eq_true', Nat.blt_eq,
    Nat.ble_eq] at this
  obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := this
  refine ⟨h1, h2, h3, h4, h5, fun hl => ?_⟩
  rcases h6 with h6 | h6
  · rw [Nat.ble_eq_true_of_le hl] at h6; cases h6
  · exact h6

private theorem FILL.handle_eq {h : Nat} (hp : PH FILL.X0 h) :
    FILL.σ.handle h = FILL.R.data.hd h :=
  handle_small _ (FILL.hOK' hp).2.1

private theorem FILL.nOK {i : Nat} {nd : Node} (hg : FILL.X0.nodes.get i = some nd) :
    nodeOK FILL.σ 20000 FILL.X0 FILL.X1 i = true :=
  List.all_eq_true.mp FILL.nodes_check i (PTrie.mem_keys _ _ _ hg)

private theorem FILL.nlow {k y : Nat} (hg : FILL.R.data.node.get k = some y) :
    20000 ≤ k ∧ FILL.R.data.nodeF k < FILL.X1.nnext := by
  have := List.all_eq_true.mp FILL.nlow_check k (PTrie.mem_keys _ _ _ hg)
  simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this
  exact this

private theorem FILL.node_id {j : Nat} (hj : j < 20000) : FILL.σ.node j = j := by
  show FILL.R.data.nodeF j = j
  have hn0 : j < FILL.R.data.nn0 := by rw [FILL.nn0_eq, FILL.x0nnext]; omega
  rw [node_old _ hn0]
  cases hg : FILL.R.data.node.get j with
  | none => rfl
  | some y => have := (FILL.nlow hg).1; omega

theorem FILL.mshift : MShift loadP0 Base.S0.tab.length FILL.σ FILL.X0 FILL.X1 where
  bigFix := by
    intro i hi
    refine big_fixed _ FILL.band_check (Nat.le_of_ble_eq_true FILL.nh0_check) (by decide) i ?_
    show i < 0 ∨ (0 ≤ i ∧ i < 25000) ∨ _
    have : i < 25000 := hi
    omega
  bigFixHi := by
    intro i hi hi2
    exact big_fixed _ FILL.band_check (Nat.le_of_ble_eq_true FILL.nh0_check) (by decide) i
      (Or.inr (Or.inr ⟨hi, hi2⟩))
  nonneg := fun h => big_nonneg _ h
  present := by
    intro h hp
    obtain ⟨_, h2, h3, -, -, -⟩ := FILL.hOK' hp
    refine ⟨?_, phB_iff.mp h3⟩
    rw [FILL.handle_eq hp]
    refine ⟨big_small _ h2, ?_, ?_⟩
    · show FILL.R.data.region (4 * h + 0) = 4 * FILL.R.data.hd h + 0
      exact region_hd FILL.R.data (by decide) (by unfold bigHi at h2; omega)
    · exact region_hd FILL.R.data (by decide) (by unfold bigHi at h2; omega)
  hinj := by
    intro a b ha hb he
    rw [FILL.handle_eq ha, FILL.handle_eq hb] at he
    refine ren_inj (f := FILL.R.data.hd) (fun x hx => ?_) FILL.hren_check a b (phB_iff.mpr ha) (phB_iff.mpr hb) he
    have := (FILL.hOK' (phB_iff.mp hx)).1
    exact hd_old _ (by rw [FILL.nh0_eq]; exact this)
  hlt := fun h hp => (FILL.hOK' hp).1
  hband := by
    intro h hp hl
    exact (FILL.hOK' hp).2.2.2.2.2 hl
  hfreshR := by
    intro k hk
    have hc := Nat.le_of_ble_eq_true FILL.counters1
    have e0 := FILL.nh0_eq
    have e1 := FILL.nh1_eq
    have r0 := region_fresh FILL.R.data k 0 (by decide) (by rw [e0]; omega)
    have r1 := region_fresh FILL.R.data k 1 (by decide) (by rw [e0]; omega)
    rw [e0, e1] at r0 r1
    exact ⟨r0, r1⟩
  zero := big_zero _ FILL.band_check FILL.hbelow (by decide) (Nat.le_of_ble_eq_true FILL.nh0_check)
    (Nat.le_of_ble_eq_true FILL.nh1_pos)
  hnext := ⟨by show 25000 ≤ _; rw [FILL.x0next]; decide, Nat.le_of_ble_eq_true FILL.counters1⟩
  absent0 := ⟨FILL.absent0a, FILL.absent0b⟩
  arrs := by
    intro h hp
    exact (FILL.hOK' hp).2.2.2.1
  objs := by
    intro h hp
    cases ho : FILL.X0.objs.get h with
    | none =>
      have := (FILL.hOK' hp).2.2.2.2.1
      rw [ho] at this
      simpa using this
    | some o =>
      have hm := PTrie.mem_keys _ _ _ ho
      have := List.map_inj_left.mp FILL.objs_check h hm
      rw [ho] at this
      exact this
  cfgCanon := by
    intro h c hc p hp d hd
    have := List.all_eq_true.mp FILL.objok_check h (PTrie.mem_keys _ _ _ hc)
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  traced := by
    intro h o ho i hi
    have := List.all_eq_true.mp FILL.objok_check h (PTrie.mem_keys _ _ _ ho)
    simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq] at this
    exact this.1 i hi
  node0 := FILL.node_id (by decide)
  nid := fun j hj => FILL.node_id hj
  nall := by
    intro j hj
    show FILL.R.data.nodeF j < _
    have hn0 : j < FILL.R.data.nn0 := by rw [FILL.nn0_eq]; exact hj
    rw [node_old _ hn0]
    cases hg : FILL.R.data.node.get j with
    | none =>
      have hc := Nat.le_of_ble_eq_true FILL.counters2
      simp only [Option.getD_none]; omega
    | some y =>
      have := (FILL.nlow hg).2
      rw [node_old _ hn0, hg] at this
      simpa using this
  norder := by
    intro i hp hf j hj
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := FILL.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    have hi : i < 20000 := by
      rcases hf with hf | hf
      · exact hf
      · have : (22539 : Nat) ≤ i := hf
        have := this; have h2 := FILL.x0nnext; omega
    rw [FILL.node_id hi, FILL.node_id (by omega)]
    exact hj
  nfull := by
    intro i hp hf
    rcases hf with hf | hf
    · left; rw [FILL.node_id hf]; exact hf
    · obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
      have := FILL.nOK hg
      simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
      have h2 := FILL.x0nnext
      have : (22539 : Nat) ≤ i := hf
      omega
  nodes := by
    intro i nd hg
    have := FILL.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : FILL.X1.nodes.get (FILL.σ.node i) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq, Nat.beq_eq, List.all_eq_true, Bool.or_eq_true,
        Bool.not_eq_true', Nat.blt_eq] at hrest
      obtain ⟨⟨⟨⟨hs, hd⟩, hc⟩, hin⟩, _⟩ := hrest
      refine ⟨nd1, rfl, hs, hd, hc, fun hf => ?_⟩
      have hi : i < 20000 := by
        rcases hf with hf | hf
        · exact hf
        · have := (FILL.nOK hg); simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
          have h2 := FILL.x0nnext; have : (22539 : Nat) ≤ i := hf; omega
      refine ⟨?_, ?_⟩
      · have hm : i ∈ fullKeys 20000 FILL.X0 := by
          simp only [fullKeys, List.mem_filter, Nat.blt_eq]
          exact ⟨PTrie.mem_keys _ _ _ hg, hi⟩
        have := List.map_inj_left.mp FILL.prims_check i hm
        rw [h1, hg] at this
        simpa using this
      · rcases hin with hin | hin
        · rw [Nat.blt_eq.mpr hi] at hin; cases hin
        · exact hin
  ninj := by
    intro a b ha hb he
    refine ren_inj (f := FILL.R.data.nodeF) (fun x hx => ?_) FILL.nren_check a b ha hb he
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hx
    have := FILL.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact node_old _ (by rw [FILL.nn0_eq]; exact this.1)
  nlt := by
    intro i hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := FILL.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact this.1
  nfresh := by
    intro k
    show FILL.R.data.nodeF _ = _
    rw [← FILL.nn0_eq, node_fresh, FILL.nn1_eq]
  nband := by show 20000 ≤ 22539 ∧ 22539 ≤ FILL.X0.nnext; rw [FILL.x0nnext]; decide
  nle := Nat.le_of_ble_eq_true FILL.counters2
  tokens := FILL.tokens1
  items := by
    intro k hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := FILL.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : FILL.X1.nodes.get (FILL.σ.node k) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hrest
      exact hrest.2
  itemsPresent := by
    intro k hk
    obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hk
    have := PTrie.mem_keys _ _ _ ht
    rw [FILL.items0] at this
    cases this
  pending := FILL.pending_eq
  errh := FILL.errh_eq
  files := FILL.files_eq
  arch := FILL.arch_eq
  sizes := FILL.sizes_eq
  wired := FILL.wired_eq
  cl := by rw [Base.tab_len]; exact checkSSt_sound FILL.ssT

/-- **The native shift of case `FILL`.** -/
theorem FILL.nshift : NShift loadP0 Base.S0.tab.length FILL.σ Base.s0.ffi FILL.s150.ffi where
  host := FILL.host_eq
  hostReg := fun _ hh => region_host _ hh
  cbr := fun a => region_cb _ a
  mlx := FILL.mshift

end

end Host.Load.Run.Tpl
