import host.sim.template.clear.Shift
import host.sim.template.NShiftGen
import host.sim.template.ok.Ok
import host.sim.template.base.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of the shift of case `CLEAR`: `CLEAR.s150`'s native state holds a
copy of the template's under `CLEAR.σ` (`NShift loadP0`). Kernel checks over the
template's present handles, objects and nodes. -/

noncomputable abbrev CLEAR.X0 : NSt := Base.s0.ffi.mlx
noncomputable abbrev CLEAR.X1 : NSt := CLEAR.s150.ffi.mlx

kernel_rfl CLEAR.nh0_eq : CLEAR.R.data.nh0 = CLEAR.X0.next
kernel_rfl CLEAR.nh1_eq : CLEAR.R.data.nh1 = CLEAR.X1.next
kernel_rfl CLEAR.nn0_eq : CLEAR.R.data.nn0 = CLEAR.X0.nnext
kernel_rfl CLEAR.nn1_eq : CLEAR.R.data.nn1 = CLEAR.X1.nnext
kernel_rfl CLEAR.x0next : CLEAR.X0.next = 29302
kernel_rfl CLEAR.x0nnext : CLEAR.X0.nnext = 22539
kernel_rfl CLEAR.counters1 : Nat.ble CLEAR.X0.next CLEAR.X1.next = true
kernel_rfl CLEAR.counters2 : Nat.ble CLEAR.X0.nnext CLEAR.X1.nnext = true
kernel_rfl CLEAR.hbelow : CLEAR.R.data.checkHndBelow = true
kernel_rfl CLEAR.handles_check :
  (handlesOf CLEAR.X0).all (handleOK CLEAR.σ 25000 CLEAR.X0 CLEAR.X1) = true
kernel_rfl CLEAR.hren_check : checkRenG CLEAR.R.data.hnd CLEAR.R.hinv (phB CLEAR.X0) = true
kernel_rfl CLEAR.objs_check :
  (PTrie.keys CLEAR.X0.objs).map (fun h => CLEAR.X1.objs.get (CLEAR.σ.handle h)) =
    (PTrie.keys CLEAR.X0.objs).map (fun h => (CLEAR.X0.objs.get h).map CLEAR.σ.nobj)
kernel_rfl CLEAR.objok_check : (PTrie.keys CLEAR.X0.objs).all (objOK CLEAR.σ 20000 CLEAR.X0) = true
kernel_rfl CLEAR.nodes_check :
  (PTrie.keys CLEAR.X0.nodes).all (nodeOK CLEAR.σ 20000 CLEAR.X0 CLEAR.X1) = true
kernel_rfl CLEAR.prims_check :
  (fullKeys 20000 CLEAR.X0).map (fun i => (CLEAR.X1.nodes.get (CLEAR.σ.node i)).map Node.prim) =
    (fullKeys 20000 CLEAR.X0).map (fun i => (CLEAR.X0.nodes.get i).map fun nd => CLEAR.σ.prim nd.prim)
kernel_rfl CLEAR.nren_check : checkRenG CLEAR.R.data.node CLEAR.R.ninv (pnB CLEAR.X0) = true
kernel_rfl CLEAR.nlow_check : (PTrie.keys CLEAR.R.data.node).all
  (fun k => Nat.ble 20000 k && Nat.blt (CLEAR.R.data.nodeF k) CLEAR.X1.nnext) = true
kernel_rfl CLEAR.items0 : PTrie.keys CLEAR.X0.items = []
kernel_rfl CLEAR.ssT : checkSSt Base.n CLEAR.X0 = true
kernel_rfl CLEAR.absent0a : CLEAR.X0.arrs.get 0 = none
kernel_rfl CLEAR.absent0b : CLEAR.X0.objs.get 0 = none
kernel_rfl CLEAR.tokens1 : CLEAR.X1.tokens = []
kernel_rfl CLEAR.pending_eq : CLEAR.X1.pending = CLEAR.X0.pending.map CLEAR.σ.pend
kernel_rfl CLEAR.errh_eq : CLEAR.X1.errh = CLEAR.X0.errh.map CLEAR.σ.arg
kernel_rfl CLEAR.files_eq : CLEAR.X1.files = CLEAR.X0.files
kernel_rfl CLEAR.arch_eq : CLEAR.X1.arch = CLEAR.X0.arch
kernel_rfl CLEAR.sizes_eq : CLEAR.X1.deviceSizes = CLEAR.X0.deviceSizes
kernel_rfl CLEAR.wired_eq : CLEAR.X1.wired = CLEAR.X0.wired
kernel_rfl CLEAR.host_eq : CLEAR.s150.ffi.host = Base.s0.ffi.host
kernel_rfl CLEAR.nh1_pos : Nat.blt 0 CLEAR.R.data.nh1 = true

section
open RData

private theorem CLEAR.hOK {h : Nat} (hp : PH CLEAR.X0 h) :
    handleOK CLEAR.σ 25000 CLEAR.X0 CLEAR.X1 h = true :=
  List.all_eq_true.mp CLEAR.handles_check h (mem_handlesOf hp)

private theorem CLEAR.hOK' {h : Nat} (hp : PH CLEAR.X0 h) :
    h < CLEAR.X0.next ∧ h < bigHi ∧ phB CLEAR.X1 (CLEAR.σ.handle h) = true ∧
      CLEAR.X1.arrs.get (CLEAR.σ.handle h) = (CLEAR.X0.arrs.get h).map CLEAR.σ.node ∧
      (CLEAR.X1.objs.get (CLEAR.σ.handle h)).isSome = (CLEAR.X0.objs.get h).isSome ∧
      (25000 ≤ h → 25000 ≤ CLEAR.σ.handle h) := by
  have := CLEAR.hOK hp
  simp only [handleOK, Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true, Bool.not_eq_true', Nat.blt_eq,
    Nat.ble_eq] at this
  obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := this
  refine ⟨h1, h2, h3, h4, h5, fun hl => ?_⟩
  rcases h6 with h6 | h6
  · rw [Nat.ble_eq_true_of_le hl] at h6; cases h6
  · exact h6

private theorem CLEAR.handle_eq {h : Nat} (hp : PH CLEAR.X0 h) :
    CLEAR.σ.handle h = CLEAR.R.data.hd h :=
  handle_small _ (CLEAR.hOK' hp).2.1

private theorem CLEAR.nOK {i : Nat} {nd : Node} (hg : CLEAR.X0.nodes.get i = some nd) :
    nodeOK CLEAR.σ 20000 CLEAR.X0 CLEAR.X1 i = true :=
  List.all_eq_true.mp CLEAR.nodes_check i (PTrie.mem_keys _ _ _ hg)

private theorem CLEAR.nlow {k y : Nat} (hg : CLEAR.R.data.node.get k = some y) :
    20000 ≤ k ∧ CLEAR.R.data.nodeF k < CLEAR.X1.nnext := by
  have := List.all_eq_true.mp CLEAR.nlow_check k (PTrie.mem_keys _ _ _ hg)
  simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this
  exact this

private theorem CLEAR.node_id {j : Nat} (hj : j < 20000) : CLEAR.σ.node j = j := by
  show CLEAR.R.data.nodeF j = j
  have hn0 : j < CLEAR.R.data.nn0 := by rw [CLEAR.nn0_eq, CLEAR.x0nnext]; omega
  rw [node_old _ hn0]
  cases hg : CLEAR.R.data.node.get j with
  | none => rfl
  | some y => have := (CLEAR.nlow hg).1; omega

theorem CLEAR.mshift : MShift loadP0 Base.S0.tab.length CLEAR.σ CLEAR.X0 CLEAR.X1 where
  bigFix := by
    intro i hi
    refine big_fixed _ CLEAR.band_check (Nat.le_of_ble_eq_true CLEAR.nh0_check) (by decide) i ?_
    show i < 0 ∨ (0 ≤ i ∧ i < 25000) ∨ _
    have : i < 25000 := hi
    omega
  bigFixHi := by
    intro i hi hi2
    exact big_fixed _ CLEAR.band_check (Nat.le_of_ble_eq_true CLEAR.nh0_check) (by decide) i
      (Or.inr (Or.inr ⟨hi, hi2⟩))
  nonneg := fun h => big_nonneg _ h
  present := by
    intro h hp
    obtain ⟨_, h2, h3, -, -, -⟩ := CLEAR.hOK' hp
    refine ⟨?_, phB_iff.mp h3⟩
    rw [CLEAR.handle_eq hp]
    refine ⟨big_small _ h2, ?_, ?_⟩
    · show CLEAR.R.data.region (4 * h + 0) = 4 * CLEAR.R.data.hd h + 0
      exact region_hd CLEAR.R.data (by decide) (by unfold bigHi at h2; omega)
    · exact region_hd CLEAR.R.data (by decide) (by unfold bigHi at h2; omega)
  hinj := by
    intro a b ha hb he
    rw [CLEAR.handle_eq ha, CLEAR.handle_eq hb] at he
    refine ren_inj (f := CLEAR.R.data.hd) (fun x hx => ?_) CLEAR.hren_check a b (phB_iff.mpr ha) (phB_iff.mpr hb) he
    have := (CLEAR.hOK' (phB_iff.mp hx)).1
    exact hd_old _ (by rw [CLEAR.nh0_eq]; exact this)
  hlt := fun h hp => (CLEAR.hOK' hp).1
  hband := by
    intro h hp hl
    exact (CLEAR.hOK' hp).2.2.2.2.2 hl
  hfreshR := by
    intro k hk
    have hc := Nat.le_of_ble_eq_true CLEAR.counters1
    have e0 := CLEAR.nh0_eq
    have e1 := CLEAR.nh1_eq
    have r0 := region_fresh CLEAR.R.data k 0 (by decide) (by rw [e0]; omega)
    have r1 := region_fresh CLEAR.R.data k 1 (by decide) (by rw [e0]; omega)
    rw [e0, e1] at r0 r1
    exact ⟨r0, r1⟩
  zero := big_zero _ CLEAR.band_check CLEAR.hbelow (by decide) (Nat.le_of_ble_eq_true CLEAR.nh0_check)
    (Nat.le_of_ble_eq_true CLEAR.nh1_pos)
  hnext := ⟨by show 25000 ≤ _; rw [CLEAR.x0next]; decide, Nat.le_of_ble_eq_true CLEAR.counters1⟩
  absent0 := ⟨CLEAR.absent0a, CLEAR.absent0b⟩
  arrs := by
    intro h hp
    exact (CLEAR.hOK' hp).2.2.2.1
  objs := by
    intro h hp
    cases ho : CLEAR.X0.objs.get h with
    | none =>
      have := (CLEAR.hOK' hp).2.2.2.2.1
      rw [ho] at this
      simpa using this
    | some o =>
      have hm := PTrie.mem_keys _ _ _ ho
      have := List.map_inj_left.mp CLEAR.objs_check h hm
      rw [ho] at this
      exact this
  cfgCanon := by
    intro h c hc p hp d hd
    have := List.all_eq_true.mp CLEAR.objok_check h (PTrie.mem_keys _ _ _ hc)
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  traced := by
    intro h o ho i hi
    have := List.all_eq_true.mp CLEAR.objok_check h (PTrie.mem_keys _ _ _ ho)
    simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq] at this
    exact this.1 i hi
  node0 := CLEAR.node_id (by decide)
  nid := fun j hj => CLEAR.node_id hj
  nall := by
    intro j hj
    show CLEAR.R.data.nodeF j < _
    have hn0 : j < CLEAR.R.data.nn0 := by rw [CLEAR.nn0_eq]; exact hj
    rw [node_old _ hn0]
    cases hg : CLEAR.R.data.node.get j with
    | none =>
      have hc := Nat.le_of_ble_eq_true CLEAR.counters2
      simp only [Option.getD_none]; omega
    | some y =>
      have := (CLEAR.nlow hg).2
      rw [node_old _ hn0, hg] at this
      simpa using this
  norder := by
    intro i hp hf j hj
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := CLEAR.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    have hi : i < 20000 := by
      rcases hf with hf | hf
      · exact hf
      · have : (22539 : Nat) ≤ i := hf
        have := this; have h2 := CLEAR.x0nnext; omega
    rw [CLEAR.node_id hi, CLEAR.node_id (by omega)]
    exact hj
  nfull := by
    intro i hp hf
    rcases hf with hf | hf
    · left; rw [CLEAR.node_id hf]; exact hf
    · obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
      have := CLEAR.nOK hg
      simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
      have h2 := CLEAR.x0nnext
      have : (22539 : Nat) ≤ i := hf
      omega
  nodes := by
    intro i nd hg
    have := CLEAR.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : CLEAR.X1.nodes.get (CLEAR.σ.node i) with
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
        · have := (CLEAR.nOK hg); simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
          have h2 := CLEAR.x0nnext; have : (22539 : Nat) ≤ i := hf; omega
      refine ⟨?_, ?_⟩
      · have hm : i ∈ fullKeys 20000 CLEAR.X0 := by
          simp only [fullKeys, List.mem_filter, Nat.blt_eq]
          exact ⟨PTrie.mem_keys _ _ _ hg, hi⟩
        have := List.map_inj_left.mp CLEAR.prims_check i hm
        rw [h1, hg] at this
        simpa using this
      · rcases hin with hin | hin
        · rw [Nat.blt_eq.mpr hi] at hin; cases hin
        · exact hin
  ninj := by
    intro a b ha hb he
    refine ren_inj (f := CLEAR.R.data.nodeF) (fun x hx => ?_) CLEAR.nren_check a b ha hb he
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hx
    have := CLEAR.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact node_old _ (by rw [CLEAR.nn0_eq]; exact this.1)
  nlt := by
    intro i hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := CLEAR.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
    exact this.1
  nfresh := by
    intro k
    show CLEAR.R.data.nodeF _ = _
    rw [← CLEAR.nn0_eq, node_fresh, CLEAR.nn1_eq]
  nband := by show 20000 ≤ 22539 ∧ 22539 ≤ CLEAR.X0.nnext; rw [CLEAR.x0nnext]; decide
  nle := Nat.le_of_ble_eq_true CLEAR.counters2
  tokens := CLEAR.tokens1
  items := by
    intro k hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := CLEAR.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : CLEAR.X1.nodes.get (CLEAR.σ.node k) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hrest
      exact hrest.2
  itemsPresent := by
    intro k hk
    obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hk
    have := PTrie.mem_keys _ _ _ ht
    rw [CLEAR.items0] at this
    cases this
  pending := CLEAR.pending_eq
  errh := CLEAR.errh_eq
  files := CLEAR.files_eq
  arch := CLEAR.arch_eq
  sizes := CLEAR.sizes_eq
  wired := CLEAR.wired_eq
  cl := by rw [Base.tab_len]; exact checkSSt_sound CLEAR.ssT

/-- **The native shift of case `CLEAR`.** -/
theorem CLEAR.nshift : NShift loadP0 Base.S0.tab.length CLEAR.σ Base.s0.ffi CLEAR.s150.ffi where
  host := CLEAR.host_eq
  hostReg := fun _ hh => region_host _ hh
  cbr := fun a => region_cb _ a
  mlx := CLEAR.mshift

end

end Host.Load.Run.Tpl
