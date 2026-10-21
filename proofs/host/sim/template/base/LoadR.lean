import host.sim.template.base.LoadRB
import host.sim.template.base.LoadRC
import host.sim.template.base.LoadRD
import host.sim.template.base.LoadRE
import host.sim.template.base.Fresh
import host.sim.template.base.Facts
import host.sim.LoadSim
import host.sim.LoopInv
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
open Host.Load.Run.Full (P.s3272)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The native part of the base relation: the template's native state is related to the
actual cut's (`P.s3272`) with any unread token suffix `τ` (the boot-tail agent's
`P.ta3272 τ`: only `mlx.tokens` differs, `.ref 2 :: τ`), under the identity names and the
template's number map `Base.M`. And the loop's start conditions (`LoopStart`). -/

private theorem Base.handle_id (h : Nat) : Base.M.handle h = h := rfl

private theorem Base.hOK {h : Nat} (hp : PH Base.X0 h) :
    h < Base.X0.next ∧ phB Base.Y0 h = true ∧ Base.Y0.arrs.get h = Base.X0.arrs.get h ∧
      (Base.Y0.objs.get h).isSome = (Base.X0.objs.get h).isSome := by
  have := List.all_eq_true.mp Base.handles_check h (mem_handlesOf hp)
  simp only [handleOK, Bool.and_eq_true, beq_iff_eq, Nat.blt_eq, Base.handle_id] at this
  obtain ⟨⟨⟨⟨⟨h1, _⟩, h3⟩, h4⟩, h5⟩, _⟩ := this
  refine ⟨h1, h3, ?_, h5⟩
  rw [h4]; cases Base.X0.arrs.get h <;> rfl

private theorem Base.nOK {i : Nat} {nd : Node} (hg : Base.X0.nodes.get i = some nd) :
    nodeOK Base.M 20000 Base.X0 Base.Y0 i = true :=
  List.all_eq_true.mp Base.nodes_check i (PTrie.mem_keys _ _ _ hg)

private theorem Base.present_lt {i : Nat} (hp : PN Base.X0 i) : i < 22539 := by
  obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
  have := Base.nOK hg
  simp only [nodeOK, hg, Bool.and_eq_true, Nat.blt_eq] at this
  rw [← Base.x0nnext]; exact this.1

theorem Base.mrw (τ : List NumV) :
    MRw { loadP0 with rest := τ } Base.M Base.S0.tab.length Base.X0 (Base.Y τ).mlx where
  lo := by show 0 < 25000; decide
  bigFix := fun _ _ => rfl
  bigFixHi := fun _ _ _ => rfl
  present := fun h _ => ⟨by simp [Base.handle_id]; rfl, by rw [Base.handle_id]; rfl, by rw [Base.handle_id]; rfl⟩
  hinj := fun a b _ _ he => by rwa [Base.handle_id, Base.handle_id] at he
  hlt := fun h hp => (Base.hOK hp).1
  himg := by
    intro h hp
    rw [Base.handle_id]
    refine ⟨?_, by show h < Base.Y0.next; rw [Base.next_same]; exact (Base.hOK hp).1⟩
    rcases Nat.eq_zero_or_pos h with rfl | hpos
    · rcases hp with hp | hp
      · rw [Base.absent0a] at hp; cases hp
      · rw [Base.absent0b] at hp; cases hp
    · exact hpos
  hband := fun h _ hl => by rw [Base.handle_id]; exact hl
  hfreshR := fun k _ => by
    show 4 * (Base.X0.next + k) = 4 * (Base.Y0.next + k) ∧ 4 * (Base.X0.next + k) + 1 = 4 * (Base.Y0.next + k) + 1
    rw [Base.next_same]; exact ⟨rfl, rfl⟩
  zero := fun _ => rfl
  hnext := by
    show 25000 ≤ Base.X0.next ∧ Base.X0.next ≤ Base.Y0.next
    rw [Base.next_same, Base.x0next]; decide
  hroom := by
    show Base.X0.next ≤ 131072 ∧ Base.Y0.next + (131072 - Base.X0.next) < 2 ^ 46
    rw [Base.next_same, Base.x0next]; decide
  absent0 := ⟨Base.absent0a, Base.absent0b, Base.absent0c⟩
  yabsent := by
    intro h hh
    change Base.Y0.next ≤ h at hh
    show Base.Y0.arrs.get h = none ∧ Base.Y0.objs.get h = none
    have hc := Base.yabsent_check
    constructor
    · cases hg : Base.Y0.arrs.get h with
      | none => rfl
      | some n =>
        have := List.all_eq_true.mp hc h (mem_handlesOf (Or.inl (by rw [hg]; rfl)))
        simp only [Nat.blt_eq] at this
        exact absurd hh (by show ¬ Base.Y0.next ≤ h; omega)
    · cases hg : Base.Y0.objs.get h with
      | none => rfl
      | some o =>
        have := List.all_eq_true.mp hc h (mem_handlesOf (Or.inr (by rw [hg]; rfl)))
        simp only [Nat.blt_eq] at this
        exact absurd hh (by show ¬ Base.Y0.next ≤ h; omega)
  arrs := fun h hp => by
    rw [Base.handle_id]; show Base.Y0.arrs.get h = _; rw [(Base.hOK hp).2.2.1]; cases Base.X0.arrs.get h <;> rfl
  objs := by
    intro h hp
    rw [Base.handle_id]
    show Base.Y0.objs.get h = _
    cases ho : Base.X0.objs.get h with
    | none =>
      have := (Base.hOK hp).2.2.2
      rw [ho] at this
      simpa using this
    | some o =>
      have := List.map_inj_left.mp Base.objs_check h (PTrie.mem_keys _ _ _ ho)
      rw [ho] at this
      exact this
  cfgCanon := by
    intro h c hc p hp d hd
    have := List.all_eq_true.mp Base.objok_check h (PTrie.mem_keys _ _ _ hc)
    simp only [objOK, hc, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.2 p hp d hd
  traced := by
    intro h o ho i hi
    have := List.all_eq_true.mp Base.objok_check h (PTrie.mem_keys _ _ _ ho)
    simp only [objOK, ho, Bool.and_eq_true, List.all_eq_true, Nat.blt_eq] at this
    exact this.1 i hi
  node0 := rfl
  nid := fun _ _ => rfl
  nall := fun j hj => by show j < Base.Y0.nnext; rw [Base.nnext_same]; exact hj
  norder := fun _ _ _ _ hj => hj
  nodes := by
    intro i nd hg
    have := Base.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : Base.Y0.nodes.get (Base.M.node i) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq, Nat.beq_eq, List.all_eq_true, Bool.or_eq_true,
        Bool.not_eq_true', Nat.blt_eq] at hrest
      obtain ⟨⟨⟨⟨hs, hd⟩, hc⟩, hin⟩, _⟩ := hrest
      refine ⟨nd1, h1, hs, hd, hc, fun hf => ?_⟩
      have hi : i < 20000 := by
        rcases hf with hf | hf
        · exact hf
        · have := Base.present_lt (show PN Base.X0 i by unfold PN; rw [hg]; rfl)
          have : (22539 : Nat) ≤ i := hf
          omega
      refine ⟨?_, ?_⟩
      · have hm : i ∈ fullKeys 20000 Base.X0 := by
          simp only [fullKeys, List.mem_filter, Nat.blt_eq]
          exact ⟨PTrie.mem_keys _ _ _ hg, hi⟩
        have := List.map_inj_left.mp Base.prims_check i hm
        rw [h1, hg] at this
        simpa using this
      · rcases hin with hin | hin
        · rw [Nat.blt_eq.mpr hi] at hin; cases hin
        · exact hin
  ninj := fun _ _ _ _ h => h
  nlt := fun i hp => by rw [Base.x0nnext]; exact Base.present_lt hp
  nimg := fun i hp => by
    show i < Base.Y0.nnext; rw [Base.nnext_same, Base.x0nnext]; exact Base.present_lt hp
  nfresh := fun k => by show Base.X0.nnext + k = Base.Y0.nnext + k; rw [Base.nnext_same]
  nband := by show 20000 ≤ 22539 ∧ 22539 ≤ Base.X0.nnext; rw [Base.x0nnext]; decide
  nroom := by
    show Base.X0.nnext ≤ Base.Y0.nnext ∧ Base.X0.nnext ≤ 2 ^ 40 ∧ Base.Y0.nnext + (2 ^ 40 - Base.X0.nnext) < 2 ^ 62
    rw [Base.nnext_same, Base.x0nnext]; decide
  tokens := ⟨τ, by
    show .ref 2 :: τ = Base.X0.tokens.map Base.M.nv ++ τ
    rw [show Base.X0.tokens = [.ref 79] from Base.tokens_val]
    show _ = [Base.M.nv (.ref 79)] ++ τ
    (rw [Base.num79]) <;> rfl⟩
  items := by
    intro k hp
    obtain ⟨nd, hg⟩ := Option.isSome_iff_exists.mp hp
    have := Base.nOK hg
    simp only [nodeOK, hg, Bool.and_eq_true] at this
    obtain ⟨_, hrest⟩ := this
    cases h1 : Base.Y0.nodes.get (Base.M.node k) with
    | none => rw [h1] at hrest; cases hrest
    | some nd1 =>
      rw [h1] at hrest
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hrest
      exact hrest.2
  itemsPresent := by
    intro k hk
    obtain ⟨t, ht⟩ := Option.isSome_iff_exists.mp hk
    have := PTrie.mem_keys _ _ _ ht
    rw [Base.items0] at this
    cases this
  yitems := by
    intro k hk
    change Base.Y0.nnext ≤ k at hk
    show Base.Y0.items.get k = none
    cases hg : Base.Y0.items.get k with
    | none => rfl
    | some t =>
      have := List.all_eq_true.mp Base.yitems_check k (PTrie.mem_keys _ _ _ hg)
      simp only [Nat.blt_eq] at this
      exact absurd hk (by show ¬ Base.Y0.nnext ≤ k; omega)
  pending := Base.pending_eq
  errh := Base.errh_eq
  files := Base.files_eq
  arch := Base.arch_eq
  sizes := Base.sizes_eq
  wired := Base.wired_eq
  cl := by rw [Base.tab_len]; exact checkSSt_sound Base.ssT

/-- **The native base relation**, for every unread token suffix `τ`. -/
theorem Base.loadR (τ : List NumV) :
    LoadR { loadP0 with rest := τ } Base.M Base.S0.tab.length Base.s0.ffi (Base.Y τ) where
  host := Base.host_eq
  hostReg := fun _ _ => rfl
  hostLt := by
    intro h hh
    obtain ⟨o, ho⟩ := Option.isSome_iff_exists.mp hh
    have hm := mem_entriesK _ h 0 1 o ho
    simp only [Nat.zero_add, Nat.one_mul] at hm
    have := List.all_eq_true.mp Base.hostLt_check (h, o) hm
    simpa using this
  cbr := fun _ => rfl
  mlx := { Base.mrw τ with
    hfreshB := fun k _ => by
      show Int.ofNat (Base.X0.next + k) = Int.ofNat (Base.Y0.next + k); rw [Base.next_same]
    tokensX := by
      show .ref 2 :: τ = Base.X0.tokens.map Base.M.nv ++ τ
      rw [show Base.X0.tokens = [.ref 79] from Base.tokens_val]
      show _ = [Base.M.nv (.ref 79)] ++ τ
      (rw [Base.num79]) <;> rfl }

/-- The loop's start conditions. -/
theorem Base.loopStart : LoopStart loadP0 Base.s0 Base.S0.tab where
  tok := Base.tokens_val
  h79 := by rw [Base.tab_len]; decide
  big := by show bigsOutB Base.s0.ffi.mlx.next 131072 Base.s0.ffi.mlx = true; rw [Base.mnext_val]; exact Base.nativeFresh
  free := by
    have := Base.noBigFresh
    show NoBigSt (fun i => ((Base.s0.ffi.mlx.next : Nat) : Int) ≤ i ∧ i < 131072) Base.s0.trace Base.s0
    rw [Base.mnext_val]; exact this
  lo := by show 25000 ≤ Base.s0.ffi.mlx.next; rw [Base.mnext_val]; decide
  hi := by decide

end Host.Load.Run.Tpl
