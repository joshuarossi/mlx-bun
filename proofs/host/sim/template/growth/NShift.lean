import host.sim.template.growth.Shift
import host.sim.template.NShiftGen
import host.sim.template.ok.Ok
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of the shift of case `GROWTH`: `GROWTH.s153`'s native state holds a
copy of the template's under `GROWTH.σ` (`NShift loadP0`). Kernel checks over the
template's present handles, objects and nodes. -/

noncomputable abbrev GROWTH.X0 : NSt := Base.s0.ffi.mlx
noncomputable abbrev GROWTH.X1 : NSt := GROWTH.s153.ffi.mlx

kernel_rfl GROWTH.nh0_eq : GROWTH.R.data.nh0 = GROWTH.X0.next
kernel_rfl GROWTH.nh1_eq : GROWTH.R.data.nh1 = GROWTH.X1.next
kernel_rfl GROWTH.nn0_eq : GROWTH.R.data.nn0 = GROWTH.X0.nnext
kernel_rfl GROWTH.nn1_eq : GROWTH.R.data.nn1 = GROWTH.X1.nnext
kernel_rfl GROWTH.x0next : GROWTH.X0.next = 29302
kernel_rfl GROWTH.x0nnext : GROWTH.X0.nnext = 22539
kernel_rfl GROWTH.counters1 : Nat.ble GROWTH.X0.next GROWTH.X1.next = true
kernel_rfl GROWTH.counters2 : Nat.ble GROWTH.X0.nnext GROWTH.X1.nnext = true
kernel_rfl GROWTH.hbelow : GROWTH.R.data.checkHndBelow = true
kernel_rfl GROWTH.handles_check :
  (handlesOf GROWTH.X0).all (handleOK GROWTH.σ 25000 GROWTH.X0 GROWTH.X1) = true
kernel_rfl GROWTH.hren_check : checkRenG GROWTH.R.data.hnd GROWTH.R.hinv (phB GROWTH.X0) = true
kernel_rfl GROWTH.objs_check :
  (PTrie.keys GROWTH.X0.objs).map (fun h => GROWTH.X1.objs.get (GROWTH.σ.handle h)) =
    (PTrie.keys GROWTH.X0.objs).map (fun h => (GROWTH.X0.objs.get h).map GROWTH.σ.nobj)
kernel_rfl GROWTH.objok_check : (PTrie.keys GROWTH.X0.objs).all (objOK GROWTH.σ 20000 GROWTH.X0) = true
kernel_rfl GROWTH.nodes_check :
  (PTrie.keys GROWTH.X0.nodes).all (nodeOK GROWTH.σ 20000 GROWTH.X0 GROWTH.X1) = true
kernel_rfl GROWTH.prims_check :
  (fullKeys 20000 GROWTH.X0).map (fun i => (GROWTH.X1.nodes.get (GROWTH.σ.node i)).map Node.prim) =
    (fullKeys 20000 GROWTH.X0).map (fun i => (GROWTH.X0.nodes.get i).map fun nd => GROWTH.σ.prim nd.prim)
kernel_rfl GROWTH.nren_check : checkRenG GROWTH.R.data.node GROWTH.R.ninv (pnB GROWTH.X0) = true
kernel_rfl GROWTH.nlow_check : (PTrie.keys GROWTH.R.data.node).all
  (fun k => Nat.ble 20000 k && Nat.blt (GROWTH.R.data.nodeF k) GROWTH.X1.nnext) = true
kernel_rfl GROWTH.items0 : PTrie.keys GROWTH.X0.items = []
kernel_rfl GROWTH.ssT : checkSSt Base.n GROWTH.X0 = true
kernel_rfl GROWTH.absent0a : GROWTH.X0.arrs.get 0 = none
kernel_rfl GROWTH.absent0b : GROWTH.X0.objs.get 0 = none
kernel_rfl GROWTH.tokens1 : GROWTH.X1.tokens = []
kernel_rfl GROWTH.pending_eq : GROWTH.X1.pending = GROWTH.X0.pending.map GROWTH.σ.pend
kernel_rfl GROWTH.errh_eq : GROWTH.X1.errh = GROWTH.X0.errh.map GROWTH.σ.arg
kernel_rfl GROWTH.files_eq : GROWTH.X1.files = GROWTH.X0.files
kernel_rfl GROWTH.arch_eq : GROWTH.X1.arch = GROWTH.X0.arch
kernel_rfl GROWTH.sizes_eq : GROWTH.X1.deviceSizes = GROWTH.X0.deviceSizes
kernel_rfl GROWTH.wired_eq : GROWTH.X1.wired = GROWTH.X0.wired
kernel_rfl GROWTH.host_eq : GROWTH.s153.ffi.host = Base.s0.ffi.host
kernel_rfl GROWTH.nh1_pos : Nat.blt 0 GROWTH.R.data.nh1 = true

section
open RData

private theorem GROWTH.hOK {h : Nat} (hp : PH GROWTH.X0 h) :
    handleOK GROWTH.σ 25000 GROWTH.X0 GROWTH.X1 h = true :=
  List.all_eq_true.mp GROWTH.handles_check h (mem_handlesOf hp)

private theorem GROWTH.hOK' {h : Nat} (hp : PH GROWTH.X0 h) :
    h < GROWTH.X0.next ∧ h < bigHi ∧ phB GROWTH.X1 (GROWTH.σ.handle h) = true ∧
      GROWTH.X1.arrs.get (GROWTH.σ.handle h) = (GROWTH.X0.arrs.get h).map GROWTH.σ.node ∧
      (GROWTH.X1.objs.get (GROWTH.σ.handle h)).isSome = (GROWTH.X0.objs.get h).isSome ∧
      (25000 ≤ h → 25000 ≤ GROWTH.σ.handle h) := by
  have := GROWTH.hOK hp
  simp only [handleOK, Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true, Bool.not_eq_true', Nat.blt_eq,
    Nat.ble_eq] at this
  obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := this
  refine ⟨h1, h2, h3, h4, h5, fun hl => ?_⟩
  rcases h6 with h6 | h6
  · rw [Nat.ble_eq_true_of_le hl] at h6; cases h6
  · exact h6

private theorem GROWTH.handle_eq {h : Nat} (hp : PH GROWTH.X0 h) :
    GROWTH.σ.handle h = GROWTH.R.data.hd h :=
  handle_small _ (GROWTH.hOK' hp).2.1

private theorem GROWTH.nOK {i : Nat} {nd : Node} (hg : GROWTH.X0.nodes.get i = some nd) :
    nodeOK GROWTH.σ 20000 GROWTH.X0 GROWTH.X1 i = true :=
  List.all_eq_true.mp GROWTH.nodes_check i (PTrie.mem_keys _ _ _ hg)

private theorem GROWTH.nlow {k y : Nat} (hg : GROWTH.R.data.node.get k = some y) :
    20000 ≤ k ∧ GROWTH.R.data.nodeF k < GROWTH.X1.nnext := by
  have := List.all_eq_true.mp GROWTH.nlow_check k (PTrie.mem_keys _ _ _ hg)
  simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this
  exact this

private theorem GROWTH.node_id {j : Nat} (hj : j < 20000) : GROWTH.σ.node j = j := by
  show GROWTH.R.data.nodeF j = j
  have hn0 : j < GROWTH.R.data.nn0 := by rw [GROWTH.nn0_eq, GROWTH.x0nnext]; omega
  rw [node_old _ hn0]
  cases hg : GROWTH.R.data.node.get j with
  | none => rfl
  | some y => have := (GROWTH.nlow hg).1; omega

theorem GROWTH.mshift : MShift loadP0 Base.S0.tab.length GROWTH.σ GROWTH.X0 GROWTH.X1 where
  bigFix := by
    intro i hi
    refine big_fixed _ GROWTH.band_check (Nat.le_of_ble_eq_true GROWTH.nh0_check) (by decide) i ?_
    show i < 0 ∨ (0 ≤ i ∧ i < 25000) ∨ _
    have : i < 25000 := hi
    omega
  bigFixHi := by
    intro i hi hi2
    exact big_fixed _ GROWTH.band_check (Nat.le_of_ble_eq_true GROWTH.nh0_check) (by decide) i
      (Or.inr (Or.inr ⟨hi, hi2⟩))
  nonneg := fun h => big_nonneg _ h
  present := by
    intro h hp
    obtain ⟨_, h2, h3, -, -, -⟩ := GROWTH.hOK' hp
    refine ⟨?_, phB_iff.mp h3⟩
    rw [GROWTH.handle_eq hp]
    refine ⟨big_small _ h2, ?_, ?_⟩
    · show GROWTH.R.data.region (4 * h + 0) = 4 * GROWTH.R.data.hd h + 0
      exact region_hd GROWTH.R.data (by decide) (by unfold bigHi at h2; omega)
    · exact region_hd GROWTH.R.data (by decide) (by unfold bigHi at h2; omega)
  hinj := by
    intro a b ha hb he
    rw [GROWTH.handle_eq ha, GROWTH.handle_eq hb] at he
    refine ren_inj (f := GROWTH.R.data.hd) (fun x hx => ?_) GROWTH.hren_check a b (phB_iff.mpr ha) (phB_iff.mpr hb) he
    have := (GROWTH.hOK' (phB_iff.mp hx)).1
    exact hd_old _ (by rw [GROWTH.nh0_eq]; exact this)
  hlt := fun h hp => (GROWTH.hOK' hp).1
  hband := by
    intro h hp hl
    exact (GROWTH.hOK' hp).2.2.2.2.2 hl
  hfreshR := by
    intro k hk
    have hc := Nat.le_of_ble_eq_true GROWTH.counters1
    have e0 := GROWTH.nh0_eq
    have e1 := GROWTH.nh1_eq
    have r0 := region_fresh GROWTH.R.data k 0 (by decide) (by rw [e0]; omega)
    have r1 := region_fresh GROWTH.R.data k 1 (by decide) (by rw [e0]; omega)
    rw [e0, e1] at r0 r1
    exact ⟨r0, r1⟩
  zero := big_zero _ GROWTH.band_check GROWTH.hbelow (by decide) (Nat.le_of_ble_eq_true GROWTH.nh0_check)
    (Nat.le_of_ble_eq_true GROWTH.nh1_pos)
  hnext := ⟨by show 25000 ≤ _; rw [GROWTH.x0next]; decide, Nat.le_of_ble_eq_true GROWTH.counters1⟩
  absent0 := ⟨GROWTH.absent0a, GROWTH.absent0b⟩
  arrs := by
    intro h hp
    exact (GROWTH.hOK' hp).2.2.2.1
  objs := by
    intro h hp
    cases ho : GROWTH.X0.objs.get h with
    | none =>
      have := (GROWTH.hOK' hp).2.2.2.2.1
      rw [ho] at this
      simpa using this
    | some o =>
      have hm := PTrie.mem_keys _ _ _ ho
      have := List.map_inj_left.mp GROWTH.objs_check h hm
      rw [ho] at this
      exact this
  cfgCanon := by
    intro h c hc p hp d hd
    have := List.all_eq_true.mp GROWTH.objok_check h (PTrie.mem_keys _ _ _ hc)
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  traced := by
    intro h o ho i hi
    have := List.all_eq_true.mp GROWTH.objok_check h (PTrie.mem_keys _ _ _ ho)
    simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq] at this
    exact this.1 i hi
  node0 := GROWTH.node_id (by decide)
  nid := fun j hj => GROWTH.node_id hj
  nall := by
    intro j hj
    show GROWTH.R.data.nodeF j < _
    have hn0 : j < GROWTH.R.data.nn0 := by rw [GROWTH.nn0_eq]; exact hj
    rw [node_old _ hn0]
    cases hg : GROWTH.R.data.node.get j with
    | none =>
      have hc := Nat.le_of_ble_eq_true GROWTH.counters2
      simp only [Option.getD_none]; omega
    | some y =>
      have := (GROWTH.nlow hg).2
      rw [node_old _ hn0, hg] at this
      simpa using this
  norder := by
    intro i hp hf j hj
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := GROWTH.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    have hi : i < 20000 := by
      rcases hf with hf | hf
      · exact hf
      · have : (22539 : Nat) ≤ i := hf
        have := this; have h2 := GROWTH.x0nnext; omega
    rw [GROWTH.node_id hi, GROWTH.node_id (by omega)]
    exact hj
  nfull := by
    intro i hp hf
    rcases hf with hf | hf
    · left; rw [GROWTH.node_id hf]; exact hf
    · obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
      have := GROWTH.nOK hg
      simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
      have h2 := GROWTH.x0nnext
      have : (22539 : Nat) ≤ i := hf
      omega
  nodes := by
    intro i nd hg
    have := GROWTH.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : GROWTH.X1.nodes.get (GROWTH.σ.node i) with
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
        · have := (GROWTH.nOK hg); simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
          have h2 := GROWTH.x0nnext; have : (22539 : Nat) ≤ i := hf; omega
      refine ⟨?_, ?_⟩
      · have hm : i ∈ fullKeys 20000 GROWTH.X0 := by
          simp only [fullKeys, List.mem_filter, Nat.blt_eq]
          exact ⟨PTrie.mem_keys _ _ _ hg, hi⟩
        have := List.map_inj_left.mp GROWTH.prims_check i hm
        rw [h1, hg] at this
        simpa using this
      · rcases hin with hin | hin
        · rw [Nat.blt_eq.mpr hi] at hin; cases hin
        · exact hin
  ninj := by
    intro a b ha hb he
    refine ren_inj (f := GROWTH.R.data.nodeF) (fun x hx => ?_) GROWTH.nren_check a b ha hb he
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hx
    have := GROWTH.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact node_old _ (by rw [GROWTH.nn0_eq]; exact this.1)
  nlt := by
    intro i hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := GROWTH.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact this.1
  nfresh := by
    intro k
    show GROWTH.R.data.nodeF _ = _
    rw [← GROWTH.nn0_eq, node_fresh, GROWTH.nn1_eq]
  nband := by show 20000 ≤ 22539 ∧ 22539 ≤ GROWTH.X0.nnext; rw [GROWTH.x0nnext]; decide
  nle := Nat.le_of_ble_eq_true GROWTH.counters2
  tokens := GROWTH.tokens1
  items := by
    intro k hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := GROWTH.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : GROWTH.X1.nodes.get (GROWTH.σ.node k) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hrest
      exact hrest.2
  itemsPresent := by
    intro k hk
    obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hk
    have := PTrie.mem_keys _ _ _ ht
    rw [GROWTH.items0] at this
    cases this
  pending := GROWTH.pending_eq
  errh := GROWTH.errh_eq
  files := GROWTH.files_eq
  arch := GROWTH.arch_eq
  sizes := GROWTH.sizes_eq
  wired := GROWTH.wired_eq
  cl := by rw [Base.tab_len]; exact checkSSt_sound GROWTH.ssT

/-- **The native shift of case `GROWTH`.** -/
theorem GROWTH.nshift : NShift loadP0 Base.S0.tab.length GROWTH.σ Base.s0.ffi GROWTH.s153.ffi where
  host := GROWTH.host_eq
  hostReg := fun _ hh => region_host _ hh
  cbr := fun a => region_cb _ a
  mlx := GROWTH.mshift

end

end Host.Load.Run.Tpl
