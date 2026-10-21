import host.sim.template.ordinary.Shift
import host.sim.template.NShiftGen
import host.sim.template.ok.Ok
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of the shift of case `ORDINARY`: `ORDINARY.s150`'s native state holds a
copy of the template's under `ORDINARY.σ` (`NShift loadP0`). Kernel checks over the
template's present handles, objects and nodes. -/

noncomputable abbrev ORDINARY.X0 : NSt := Base.s0.ffi.mlx
noncomputable abbrev ORDINARY.X1 : NSt := ORDINARY.s150.ffi.mlx

kernel_rfl ORDINARY.nh0_eq : ORDINARY.R.data.nh0 = ORDINARY.X0.next
kernel_rfl ORDINARY.nh1_eq : ORDINARY.R.data.nh1 = ORDINARY.X1.next
kernel_rfl ORDINARY.nn0_eq : ORDINARY.R.data.nn0 = ORDINARY.X0.nnext
kernel_rfl ORDINARY.nn1_eq : ORDINARY.R.data.nn1 = ORDINARY.X1.nnext
kernel_rfl ORDINARY.x0next : ORDINARY.X0.next = 29302
kernel_rfl ORDINARY.x0nnext : ORDINARY.X0.nnext = 22539
kernel_rfl ORDINARY.counters1 : Nat.ble ORDINARY.X0.next ORDINARY.X1.next = true
kernel_rfl ORDINARY.counters2 : Nat.ble ORDINARY.X0.nnext ORDINARY.X1.nnext = true
kernel_rfl ORDINARY.hbelow : ORDINARY.R.data.checkHndBelow = true
kernel_rfl ORDINARY.handles_check :
  (handlesOf ORDINARY.X0).all (handleOK ORDINARY.σ 25000 ORDINARY.X0 ORDINARY.X1) = true
kernel_rfl ORDINARY.hren_check : checkRenG ORDINARY.R.data.hnd ORDINARY.R.hinv (phB ORDINARY.X0) = true
kernel_rfl ORDINARY.objs_check :
  (PTrie.keys ORDINARY.X0.objs).map (fun h => ORDINARY.X1.objs.get (ORDINARY.σ.handle h)) =
    (PTrie.keys ORDINARY.X0.objs).map (fun h => (ORDINARY.X0.objs.get h).map ORDINARY.σ.nobj)
kernel_rfl ORDINARY.objok_check : (PTrie.keys ORDINARY.X0.objs).all (objOK ORDINARY.σ 20000 ORDINARY.X0) = true
kernel_rfl ORDINARY.nodes_check :
  (PTrie.keys ORDINARY.X0.nodes).all (nodeOK ORDINARY.σ 20000 ORDINARY.X0 ORDINARY.X1) = true
kernel_rfl ORDINARY.prims_check :
  (fullKeys 20000 ORDINARY.X0).map (fun i => (ORDINARY.X1.nodes.get (ORDINARY.σ.node i)).map Node.prim) =
    (fullKeys 20000 ORDINARY.X0).map (fun i => (ORDINARY.X0.nodes.get i).map fun nd => ORDINARY.σ.prim nd.prim)
kernel_rfl ORDINARY.nren_check : checkRenG ORDINARY.R.data.node ORDINARY.R.ninv (pnB ORDINARY.X0) = true
kernel_rfl ORDINARY.nlow_check : (PTrie.keys ORDINARY.R.data.node).all
  (fun k => Nat.ble 20000 k && Nat.blt (ORDINARY.R.data.nodeF k) ORDINARY.X1.nnext) = true
kernel_rfl ORDINARY.items0 : PTrie.keys ORDINARY.X0.items = []
kernel_rfl ORDINARY.ssT : checkSSt Base.n ORDINARY.X0 = true
kernel_rfl ORDINARY.absent0a : ORDINARY.X0.arrs.get 0 = none
kernel_rfl ORDINARY.absent0b : ORDINARY.X0.objs.get 0 = none
kernel_rfl ORDINARY.tokens1 : ORDINARY.X1.tokens = []
kernel_rfl ORDINARY.pending_eq : ORDINARY.X1.pending = ORDINARY.X0.pending.map ORDINARY.σ.pend
kernel_rfl ORDINARY.errh_eq : ORDINARY.X1.errh = ORDINARY.X0.errh.map ORDINARY.σ.arg
kernel_rfl ORDINARY.files_eq : ORDINARY.X1.files = ORDINARY.X0.files
kernel_rfl ORDINARY.arch_eq : ORDINARY.X1.arch = ORDINARY.X0.arch
kernel_rfl ORDINARY.sizes_eq : ORDINARY.X1.deviceSizes = ORDINARY.X0.deviceSizes
kernel_rfl ORDINARY.wired_eq : ORDINARY.X1.wired = ORDINARY.X0.wired
kernel_rfl ORDINARY.host_eq : ORDINARY.s150.ffi.host = Base.s0.ffi.host
kernel_rfl ORDINARY.nh1_pos : Nat.blt 0 ORDINARY.R.data.nh1 = true

section
open RData

private theorem ORDINARY.hOK {h : Nat} (hp : PH ORDINARY.X0 h) :
    handleOK ORDINARY.σ 25000 ORDINARY.X0 ORDINARY.X1 h = true :=
  List.all_eq_true.mp ORDINARY.handles_check h (mem_handlesOf hp)

private theorem ORDINARY.hOK' {h : Nat} (hp : PH ORDINARY.X0 h) :
    h < ORDINARY.X0.next ∧ h < bigHi ∧ phB ORDINARY.X1 (ORDINARY.σ.handle h) = true ∧
      ORDINARY.X1.arrs.get (ORDINARY.σ.handle h) = (ORDINARY.X0.arrs.get h).map ORDINARY.σ.node ∧
      (ORDINARY.X1.objs.get (ORDINARY.σ.handle h)).isSome = (ORDINARY.X0.objs.get h).isSome ∧
      (25000 ≤ h → 25000 ≤ ORDINARY.σ.handle h) := by
  have := ORDINARY.hOK hp
  simp only [handleOK, Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true, Bool.not_eq_true', Nat.blt_eq,
    Nat.ble_eq] at this
  obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := this
  refine ⟨h1, h2, h3, h4, h5, fun hl => ?_⟩
  rcases h6 with h6 | h6
  · rw [Nat.ble_eq_true_of_le hl] at h6; cases h6
  · exact h6

private theorem ORDINARY.handle_eq {h : Nat} (hp : PH ORDINARY.X0 h) :
    ORDINARY.σ.handle h = ORDINARY.R.data.hd h :=
  handle_small _ (ORDINARY.hOK' hp).2.1

private theorem ORDINARY.nOK {i : Nat} {nd : Node} (hg : ORDINARY.X0.nodes.get i = some nd) :
    nodeOK ORDINARY.σ 20000 ORDINARY.X0 ORDINARY.X1 i = true :=
  List.all_eq_true.mp ORDINARY.nodes_check i (PTrie.mem_keys _ _ _ hg)

private theorem ORDINARY.nlow {k y : Nat} (hg : ORDINARY.R.data.node.get k = some y) :
    20000 ≤ k ∧ ORDINARY.R.data.nodeF k < ORDINARY.X1.nnext := by
  have := List.all_eq_true.mp ORDINARY.nlow_check k (PTrie.mem_keys _ _ _ hg)
  simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this
  exact this

private theorem ORDINARY.node_id {j : Nat} (hj : j < 20000) : ORDINARY.σ.node j = j := by
  show ORDINARY.R.data.nodeF j = j
  have hn0 : j < ORDINARY.R.data.nn0 := by rw [ORDINARY.nn0_eq, ORDINARY.x0nnext]; omega
  rw [node_old _ hn0]
  cases hg : ORDINARY.R.data.node.get j with
  | none => rfl
  | some y => have := (ORDINARY.nlow hg).1; omega

theorem ORDINARY.mshift : MShift loadP0 Base.S0.tab.length ORDINARY.σ ORDINARY.X0 ORDINARY.X1 where
  bigFix := by
    intro i hi
    refine big_fixed _ ORDINARY.band_check (Nat.le_of_ble_eq_true ORDINARY.nh0_check) (by decide) i ?_
    show i < 0 ∨ (0 ≤ i ∧ i < 25000) ∨ _
    have : i < 25000 := hi
    omega
  bigFixHi := by
    intro i hi hi2
    exact big_fixed _ ORDINARY.band_check (Nat.le_of_ble_eq_true ORDINARY.nh0_check) (by decide) i
      (Or.inr (Or.inr ⟨hi, hi2⟩))
  nonneg := fun h => big_nonneg _ h
  present := by
    intro h hp
    obtain ⟨_, h2, h3, -, -, -⟩ := ORDINARY.hOK' hp
    refine ⟨?_, phB_iff.mp h3⟩
    rw [ORDINARY.handle_eq hp]
    refine ⟨big_small _ h2, ?_, ?_⟩
    · show ORDINARY.R.data.region (4 * h + 0) = 4 * ORDINARY.R.data.hd h + 0
      exact region_hd ORDINARY.R.data (by decide) (by unfold bigHi at h2; omega)
    · exact region_hd ORDINARY.R.data (by decide) (by unfold bigHi at h2; omega)
  hinj := by
    intro a b ha hb he
    rw [ORDINARY.handle_eq ha, ORDINARY.handle_eq hb] at he
    refine ren_inj (f := ORDINARY.R.data.hd) (fun x hx => ?_) ORDINARY.hren_check a b (phB_iff.mpr ha) (phB_iff.mpr hb) he
    have := (ORDINARY.hOK' (phB_iff.mp hx)).1
    exact hd_old _ (by rw [ORDINARY.nh0_eq]; exact this)
  hlt := fun h hp => (ORDINARY.hOK' hp).1
  hband := by
    intro h hp hl
    exact (ORDINARY.hOK' hp).2.2.2.2.2 hl
  hfreshR := by
    intro k hk
    have hc := Nat.le_of_ble_eq_true ORDINARY.counters1
    have e0 := ORDINARY.nh0_eq
    have e1 := ORDINARY.nh1_eq
    have r0 := region_fresh ORDINARY.R.data k 0 (by decide) (by rw [e0]; omega)
    have r1 := region_fresh ORDINARY.R.data k 1 (by decide) (by rw [e0]; omega)
    rw [e0, e1] at r0 r1
    exact ⟨r0, r1⟩
  zero := big_zero _ ORDINARY.band_check ORDINARY.hbelow (by decide) (Nat.le_of_ble_eq_true ORDINARY.nh0_check)
    (Nat.le_of_ble_eq_true ORDINARY.nh1_pos)
  hnext := ⟨by show 25000 ≤ _; rw [ORDINARY.x0next]; decide, Nat.le_of_ble_eq_true ORDINARY.counters1⟩
  absent0 := ⟨ORDINARY.absent0a, ORDINARY.absent0b⟩
  arrs := by
    intro h hp
    exact (ORDINARY.hOK' hp).2.2.2.1
  objs := by
    intro h hp
    cases ho : ORDINARY.X0.objs.get h with
    | none =>
      have := (ORDINARY.hOK' hp).2.2.2.2.1
      rw [ho] at this
      simpa using this
    | some o =>
      have hm := PTrie.mem_keys _ _ _ ho
      have := List.map_inj_left.mp ORDINARY.objs_check h hm
      rw [ho] at this
      exact this
  cfgCanon := by
    intro h c hc p hp d hd
    have := List.all_eq_true.mp ORDINARY.objok_check h (PTrie.mem_keys _ _ _ hc)
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  traced := by
    intro h o ho i hi
    have := List.all_eq_true.mp ORDINARY.objok_check h (PTrie.mem_keys _ _ _ ho)
    simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq] at this
    exact this.1 i hi
  node0 := ORDINARY.node_id (by decide)
  nid := fun j hj => ORDINARY.node_id hj
  nall := by
    intro j hj
    show ORDINARY.R.data.nodeF j < _
    have hn0 : j < ORDINARY.R.data.nn0 := by rw [ORDINARY.nn0_eq]; exact hj
    rw [node_old _ hn0]
    cases hg : ORDINARY.R.data.node.get j with
    | none =>
      have hc := Nat.le_of_ble_eq_true ORDINARY.counters2
      simp only [Option.getD_none]; omega
    | some y =>
      have := (ORDINARY.nlow hg).2
      rw [node_old _ hn0, hg] at this
      simpa using this
  norder := by
    intro i hp hf j hj
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := ORDINARY.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    have hi : i < 20000 := by
      rcases hf with hf | hf
      · exact hf
      · have : (22539 : Nat) ≤ i := hf
        have := this; have h2 := ORDINARY.x0nnext; omega
    rw [ORDINARY.node_id hi, ORDINARY.node_id (by omega)]
    exact hj
  nfull := by
    intro i hp hf
    rcases hf with hf | hf
    · left; rw [ORDINARY.node_id hf]; exact hf
    · obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
      have := ORDINARY.nOK hg
      simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
      have h2 := ORDINARY.x0nnext
      have : (22539 : Nat) ≤ i := hf
      omega
  nodes := by
    intro i nd hg
    have := ORDINARY.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : ORDINARY.X1.nodes.get (ORDINARY.σ.node i) with
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
        · have := (ORDINARY.nOK hg); simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
          have h2 := ORDINARY.x0nnext; have : (22539 : Nat) ≤ i := hf; omega
      refine ⟨?_, ?_⟩
      · have hm : i ∈ fullKeys 20000 ORDINARY.X0 := by
          simp only [fullKeys, List.mem_filter, Nat.blt_eq]
          exact ⟨PTrie.mem_keys _ _ _ hg, hi⟩
        have := List.map_inj_left.mp ORDINARY.prims_check i hm
        rw [h1, hg] at this
        simpa using this
      · rcases hin with hin | hin
        · rw [Nat.blt_eq.mpr hi] at hin; cases hin
        · exact hin
  ninj := by
    intro a b ha hb he
    refine ren_inj (f := ORDINARY.R.data.nodeF) (fun x hx => ?_) ORDINARY.nren_check a b ha hb he
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hx
    have := ORDINARY.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact node_old _ (by rw [ORDINARY.nn0_eq]; exact this.1)
  nlt := by
    intro i hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := ORDINARY.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact this.1
  nfresh := by
    intro k
    show ORDINARY.R.data.nodeF _ = _
    rw [← ORDINARY.nn0_eq, node_fresh, ORDINARY.nn1_eq]
  nband := by show 20000 ≤ 22539 ∧ 22539 ≤ ORDINARY.X0.nnext; rw [ORDINARY.x0nnext]; decide
  nle := Nat.le_of_ble_eq_true ORDINARY.counters2
  tokens := ORDINARY.tokens1
  items := by
    intro k hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := ORDINARY.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : ORDINARY.X1.nodes.get (ORDINARY.σ.node k) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hrest
      exact hrest.2
  itemsPresent := by
    intro k hk
    obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hk
    have := PTrie.mem_keys _ _ _ ht
    rw [ORDINARY.items0] at this
    cases this
  pending := ORDINARY.pending_eq
  errh := ORDINARY.errh_eq
  files := ORDINARY.files_eq
  arch := ORDINARY.arch_eq
  sizes := ORDINARY.sizes_eq
  wired := ORDINARY.wired_eq
  cl := by rw [Base.tab_len]; exact checkSSt_sound ORDINARY.ssT

/-- **The native shift of case `ORDINARY`.** -/
theorem ORDINARY.nshift : NShift loadP0 Base.S0.tab.length ORDINARY.σ Base.s0.ffi ORDINARY.s150.ffi where
  host := ORDINARY.host_eq
  hostReg := fun _ hh => region_host _ hh
  cbr := fun a => region_cb _ a
  mlx := ORDINARY.mshift

end

end Host.Load.Run.Tpl
