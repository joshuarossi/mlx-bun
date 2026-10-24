import host.load.boot.ld.NC
import host.sim.native.gen.Rel
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The native relation at `loadDone`

`Ld.loadR`: under the identity map, the template's native state at `loadDone` (`Ld.Xl`, the readbacks
`.ref 1, .ref 2`) is related by the general native relation (`G.LoadR`) to the target's for every unread
readback suffix `τ` (`Ld.Y τ`), with the target's remaining readbacks `τ` (`rest := τ`), for any load
parameters `P0` whose handle band starts at or below the boot's handle counter (18151), whose end
counters leave room, and whose node bands are the boot's node counter (15235). -/

/-- The target's MLX state for the unread readback suffix `τ`. -/
noncomputable abbrev Ld.Yn (τ : List NumV) : NSt := { Ld.X0 with tokens := NumV.ref 1 :: NumV.ref 2 :: τ }

theorem Ld.Y_mlx (τ : List NumV) : (Ld.Y τ).mlx = Ld.Yn τ := by rw [Ld.Y_eq]
theorem Ld.Y_host (τ : List NumV) : (Ld.Y τ).host = Ld.Xl.host := by rw [Ld.Y_eq]

private theorem Ld.hOK {h : Nat} (hp : PH Ld.X0 h) : handleOK Map.id 1 Ld.X0 Ld.X0 h = true :=
  List.all_eq_true.mp Ld.handles_check h (mem_handlesOf hp)

theorem Ld.hlt {h : Nat} (hp : PH Ld.X0 h) : h < Ld.X0.next := by
  have := Ld.hOK hp
  simp only [handleOK, Bool.and_eq_true, Nat.blt_eq] at this
  exact this.1.1.1.1.1

theorem Ld.hpos {h : Nat} (hp : PH Ld.X0 h) : 0 < h := by
  rcases Nat.eq_zero_or_pos h with rfl | hpos
  · rcases hp with hp | hp
    · rw [Ld.absent0a] at hp; cases hp
    · rw [Ld.absent0b] at hp; cases hp
  · exact hpos

private theorem Ld.nOK {i : Nat} {nd : Node} (hg : Ld.X0.nodes.get i = some nd) :
    nodeOK Map.id 15235 Ld.X0 Ld.X0 i = true :=
  List.all_eq_true.mp Ld.nodes_check i (PTrie.mem_keys _ _ _ hg)

theorem Ld.present_lt {i : Nat} (hp : PN Ld.X0 i) : i < 15235 := by
  obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
  have := Ld.nOK hg
  simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
  rw [← Ld.x0nnext]; exact this.1

theorem Ld.objsOf {h : Nat} {o : Host.Mlx.Ffi.Obj} (ho : Ld.X0.objs.get h = some o) : Map.id.nobj o = o := by
  have := List.map_inj_left.mp Ld.objs_check h (PTrie.mem_keys _ _ _ ho)
  rw [show Map.id.handle h = h from rfl, ho] at this
  exact (Option.some.inj this).symm

theorem Ld.itemOK {k : Nat} (hk : k ∈ PTrie.keys Ld.X0.items) :
    (Ld.X0.nodes.get k).isSome = true ∧ k < 15235 := by
  have := List.all_eq_true.mp Ld.items_check k hk
  simpa [Nat.blt_eq] using this

theorem Ld.mrw (P0 : LoadP) (NB : Nat) (hlo : 0 < P0.lo ∧ P0.lo ≤ 18151) (hE : 18151 ≤ P0.E ∧ P0.E < 2 ^ 46)
    (hN : P0.NL = 15235 ∧ P0.N0 = 15235) (hNE : 15235 ≤ P0.NE ∧ P0.NE < 2 ^ 61) (hNB : NB ≤ P0.NL) (τ : List NumV) :
    G.MRw { P0 with rest := τ } NB Map.id Ld.S0.tab.length Ld.X0 (Ld.Yn τ) where
  lo := hlo.1
  bigFix := fun _ _ => rfl
  bigFixHi := fun _ _ _ => rfl
  present := fun _ _ => ⟨rfl, rfl, rfl⟩
  hinj := fun _ _ _ _ he => he
  hlt := fun _ hp => Ld.hlt hp
  himg := fun _ hp => ⟨Ld.hpos hp, Ld.hlt hp⟩
  hband := fun _ _ hl => hl
  hfreshR := fun _ _ => ⟨rfl, rfl⟩
  zero := fun _ => rfl
  hnext := by show P0.lo ≤ Ld.X0.next ∧ Ld.X0.next ≤ Ld.X0.next; rw [Ld.x0next]; exact ⟨hlo.2, Nat.le_refl _⟩
  hroom := by
    show Ld.X0.next ≤ P0.E ∧ Ld.X0.next + (P0.E - Ld.X0.next) < 2 ^ 46
    rw [Ld.x0next]; omega
  absent0 := ⟨Ld.absent0a, Ld.absent0b, Ld.absent0b⟩
  yabsent := by
    intro h hh
    change Ld.X0.next ≤ h at hh
    show Ld.X0.arrs.get h = none ∧ Ld.X0.objs.get h = none
    constructor
    · cases hg : Ld.X0.arrs.get h with
      | none => rfl
      | some n => exact absurd (Ld.hlt (Or.inl (by rw [hg]; rfl))) (by omega)
    · cases hg : Ld.X0.objs.get h with
      | none => rfl
      | some o => exact absurd (Ld.hlt (Or.inr (by rw [hg]; rfl))) (by omega)
  arrs := fun h _ => by show Ld.X0.arrs.get h = _; cases Ld.X0.arrs.get h <;> rfl
  objs := by
    intro h _
    show Ld.X0.objs.get h = _
    cases ho : Ld.X0.objs.get h with
    | none => rfl
    | some o => rw [Option.map_some, Ld.objsOf ho]
  cfgCanon := by
    intro h c hc p hp d hd
    have := List.all_eq_true.mp Ld.objok_check h (PTrie.mem_keys _ _ _ hc)
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  traced := by
    intro h o ho i hi
    have := List.all_eq_true.mp Ld.objok_check h (PTrie.mem_keys _ _ _ ho)
    simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq] at this
    show i < P0.NL
    rw [hN.1]; exact this.1 i hi
  node0 := rfl
  nid := fun _ _ => rfl
  nbl := hNB
  nall := fun _ hj => hj
  norder := fun _ _ _ _ hj => hj
  nodes := by
    intro i nd hg
    have := Ld.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    rw [show Map.id.node i = i from rfl, hg] at hrest
    simp only [Bool.and_eq_true, decide_eq_true_eq, Nat.beq_eq, List.all_eq_true, Bool.or_eq_true,
      Bool.not_eq_true', Nat.blt_eq] at hrest
    obtain ⟨⟨⟨⟨hs, _⟩, hc⟩, _⟩, _⟩ := hrest
    refine ⟨nd, hg, hs, rfl, hc, fun _ => ⟨.inl ?_, (List.map_id'' (fun _ => rfl) _).symm⟩⟩
    have hi : i < 15235 := Ld.present_lt (show PN Ld.X0 i by unfold PN; rw [hg]; rfl)
    have hm : i ∈ fullKeys 15235 Ld.X0 := by
      simp only [fullKeys, List.mem_filter, Nat.blt_eq]
      exact ⟨PTrie.mem_keys _ _ _ hg, hi⟩
    have := List.map_inj_left.mp Ld.prims_check i hm
    rw [show Map.id.node i = i from rfl, hg] at this
    simpa using this
  ninj := fun _ _ _ _ h => h
  nlt := fun i hp => by rw [Ld.x0nnext]; exact Ld.present_lt hp
  nimg := fun i hp => by show i < Ld.X0.nnext; rw [Ld.x0nnext]; exact Ld.present_lt hp
  nfresh := fun _ => rfl
  nband := by show P0.NL ≤ P0.N0 ∧ P0.N0 ≤ Ld.X0.nnext; rw [Ld.x0nnext, hN.1, hN.2]; exact ⟨Nat.le_refl _, Nat.le_refl _⟩
  nroom := by
    show Ld.X0.nnext ≤ Ld.X0.nnext ∧ Ld.X0.nnext ≤ P0.NE ∧ Ld.X0.nnext + (P0.NE - Ld.X0.nnext) < 2 ^ 62
    rw [Ld.x0nnext]; omega
  tokens := ⟨τ, by
    show NumV.ref 1 :: NumV.ref 2 :: τ = Ld.X0.tokens.map Map.id.nv ++ τ
    rw [Ld.tokens_val]; rfl⟩
  items := by
    intro k _
    show Ld.X0.items.get k = (Ld.X0.items.get k).map Map.id.nv
    cases Ld.X0.items.get k with
    | none => rfl
    | some t => rw [Option.map_some, Map.nv_id]
  itemsPresent := by
    intro k hk
    obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hk
    exact (Ld.itemOK (PTrie.mem_keys _ _ _ ht)).1
  yitems := by
    intro k hk
    change Ld.X0.nnext ≤ k at hk
    show Ld.X0.items.get k = none
    cases hg : Ld.X0.items.get k with
    | none => rfl
    | some t =>
      have := (Ld.itemOK (PTrie.mem_keys _ _ _ hg)).2
      rw [Ld.x0nnext] at hk
      omega
  pending := by show Ld.X0.pending = Ld.X0.pending.map Map.id.pend; rw [Ld.pending_val]; rfl
  errh := by
    show Ld.X0.errh = Ld.X0.errh.map Map.id.arg
    cases Ld.X0.errh with
    | none => rfl
    | some a => rw [Option.map_some, Map.arg_id]
  files := rfl
  arch := rfl
  sizes := rfl
  wired := rfl
  cl := checkSSt_sound Ld.ssT

/-- **The native relation at `loadDone`**, for every unread readback suffix `τ`. -/
theorem Ld.loadR (P0 : LoadP) (NB : Nat) (hlo : 0 < P0.lo ∧ P0.lo ≤ 18151) (hE : 18151 ≤ P0.E ∧ P0.E < 2 ^ 46)
    (hN : P0.NL = 15235 ∧ P0.N0 = 15235) (hNE : 15235 ≤ P0.NE ∧ P0.NE < 2 ^ 61) (hNB : NB ≤ P0.NL) (τ : List NumV) :
    G.LoadR { P0 with rest := τ } NB Map.id Ld.S0.tab.length Ld.Xl (Ld.Y τ) where
  host := Ld.Y_host τ
  hostReg := fun _ _ => rfl
  hostLt := by
    intro h hh
    obtain ⟨o, ho⟩ := Option.isSome_iff_exists.mp hh
    have hm := mem_entriesK _ h 0 1 o ho
    simp only [Nat.zero_add, Nat.one_mul] at hm
    have := List.all_eq_true.mp Ld.hostLt_check (h, o) hm
    simpa using this
  cbr := fun _ => rfl
  mlx := by
    rw [Ld.Y_mlx]
    exact { Ld.mrw P0 NB hlo hE hN hNE hNB τ with
      hfreshB := fun _ _ => rfl
      tokensX := by
        show NumV.ref 1 :: NumV.ref 2 :: τ = Ld.X0.tokens.map Map.id.nv ++ τ
        rw [Ld.tokens_val]; rfl }

end Host.Load.Run.Prompt
