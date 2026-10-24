import host.sim.conv.NShiftFoot
import host.sim.full.Rel
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Load.Layers

/-! # The observers' part of a compaction's shift from its footprint

`FreedShift` and `KRecShift` (`host.sim.full.Restart`) range over every object handle of the canonical
state. With the footprint of `MFoot` (the canonical state keeps the call's objects off `lh`, the merged
state off the stage's `wS`, the compaction map fixes the call's handles) and the observer layers'
footprints (the canonical and the merged layer keep the call's off the same lists), their facts follow
from the call's (`freed_of_foot`, `krec_of_foot`), checked on `lh` only. The results are the
structures' fields; `FreedShift`/`KRecShift` are their anonymous constructors. -/

section
variable {P : LoadP} {n0 : Nat} {σ : Map} {D : RData} {hinv ninv : PTrie Nat} {xC x0 x1 : NSt} {cC : Cnt}
  {lh ln li wS nS iS : List Nat}

/-- A canonical object handle off `lh` is the call's, off the stage's footprint, and fixed by `σ`. -/
theorem MFoot.keptObj (c : MFoot P n0 σ D hinv ninv xC x0 x1 cC lh ln li wS nS iS) {h : Nat} (hm : h ∉ lh)
    (hp : (x0.objs.get h).isSome = true) :
    x0.objs.get h = xC.objs.get h ∧ h < xC.next ∧ h ∉ wS ∧ σ.handle h = h := by
  have hbd := c.bounds
  simp only [List.all_append, Bool.and_eq_true] at hbd
  have eo0 := get_keep c.keep0o hbd.1.1.1.1.1 h hm
  have hpC : PH xC h := .inr (by rw [← eo0]; exact hp)
  have hlt := c.hltC h hpC
  have hle := c.le0
  simp only [Bool.and_eq_true, Nat.ble_eq] at hle
  refine ⟨eo0, hlt, fun hw => ?_, ?_⟩
  · have := List.all_eq_true.mp c.incW h hw
    rw [Nat.blt_eq.mpr hlt, Bool.not_true, Bool.false_or] at this
    exact hm (List.contains_iff_mem.mp this)
  · refine fix_handle c.fix ?_
    have hk : h < 2 ^ 62 := by have := hle.2; unfold RData.bigHi at this; omega
    rw [oldBigB_lo hk, c.cxn, Nat.blt_eq.mpr hlt, Bool.true_or]

/-- **The liveness layer's shift facts from the footprint.** -/
theorem freed_of_foot (c : MFoot P n0 σ D hinv ninv xC x0 x1 cC lh ln li wS nS iS) {fxC fx0 fx1 : PTrie Unit}
    (hobjC : ∀ h, fxC.get h = some () → (xC.objs.get h).isSome = true)
    (kf0 : fx0 = Stage.setAll fxC (lh.filterMap fun i => (fx0.get i).map (i, ·)))
    (kf1 : fx1 = Stage.setAll fxC (wS.filterMap fun i => (fx1.get i).map (i, ·)))
    (hck : ∀ h ∈ lh, (fx0.get h = some () → (x0.objs.get h).isSome = true) ∧
      ((x0.objs.get h).isSome = true → fx1.get (σ.handle h) = fx0.get h)) :
    (∀ h, fx0.get h = some () → (x0.objs.get h).isSome = true) ∧
      (∀ h, (x0.objs.get h).isSome = true → fx1.get (σ.handle h) = fx0.get h) := by
  have hbd := c.bounds
  simp only [List.all_append, Bool.and_eq_true] at hbd
  have k0 := get_keep kf0 hbd.1.1.1.1.1
  have k1 := get_keep kf1 hbd.1.1.2
  have eo := get_keep c.keep0o hbd.1.1.1.1.1
  refine ⟨fun h hf => ?_, fun h hp => ?_⟩
  · by_cases hm : h ∈ lh
    · exact (hck h hm).1 hf
    · rw [eo h hm]; exact hobjC h (by rw [← k0 h hm]; exact hf)
  · by_cases hm : h ∈ lh
    · exact (hck h hm).2 hp
    · obtain ⟨-, -, hw, he⟩ := c.keptObj hm hp
      rw [he, k1 h hw, k0 h hm]

theorem targ_fix {c : Cnt} (hf : FixOld c σ) {l : List (List Char × TArg)} (hl : STargs (· < c.n) l) :
    l.map (targ σ) = l := by
  refine (List.map_congr_left fun t ht => ?_).trans (List.map_id l)
  obtain ⟨nm, a⟩ := t
  cases a with
  | int v =>
    have hs := hl nm v ht
    show (nm, TArg.int (σ.nv v)) = (nm, TArg.int v)
    cases v with
    | lit _ => rfl
    | ref i => rw [show σ.nv (.ref i) = .ref i from hf.num i hs]
  | dtype d => rfl

/-- **The kernel-recording layer's shift facts from the footprint.** -/
theorem krec_of_foot (c : MFoot P n0 σ D hinv ninv xC x0 x1 cC lh ln li wS nS iS) {kC k0 k1 : KRec} {n' : Nat}
    (hn : cC.n ≤ n')
    (hfC : ∀ h, (kC.flags.get h).isSome = true → (xC.objs.get h).isSome = true)
    (htC : ∀ h, (kC.targs.get h).isSome = true → (xC.objs.get h).isSome = true)
    (hclC : ∀ h l, kC.targs.get h = some l → STargs (· < cC.n) l)
    (kf0 : k0.flags = Stage.setAll kC.flags (lh.filterMap fun i => (k0.flags.get i).map (i, ·)))
    (kt0 : k0.targs = Stage.setAll kC.targs (lh.filterMap fun i => (k0.targs.get i).map (i, ·)))
    (kf1 : k1.flags = Stage.setAll kC.flags (wS.filterMap fun i => (k1.flags.get i).map (i, ·)))
    (kt1 : k1.targs = Stage.setAll kC.targs (wS.filterMap fun i => (k1.targs.get i).map (i, ·)))
    (hck : ∀ h ∈ lh, ((k0.flags.get h).isSome = true → (x0.objs.get h).isSome = true) ∧
      ((k0.targs.get h).isSome = true → (x0.objs.get h).isSome = true) ∧
      ((x0.objs.get h).isSome = true → k1.flags.get (σ.handle h) = k0.flags.get h ∧
        k1.targs.get (σ.handle h) = (k0.targs.get h).map (List.map (targ σ))) ∧
      (∀ l, k0.targs.get h = some l → STargs (· < n') l)) :
    (∀ h, (k0.flags.get h).isSome = true → (x0.objs.get h).isSome = true) ∧
      (∀ h, (k0.targs.get h).isSome = true → (x0.objs.get h).isSome = true) ∧
      (∀ h, (x0.objs.get h).isSome = true → k1.flags.get (σ.handle h) = k0.flags.get h) ∧
      (∀ h, (x0.objs.get h).isSome = true → k1.targs.get (σ.handle h) = (k0.targs.get h).map (List.map (targ σ))) ∧
      (∀ h l, k0.targs.get h = some l → STargs (· < n') l) := by
  have hbd := c.bounds
  simp only [List.all_append, Bool.and_eq_true] at hbd
  have bl := hbd.1.1.1.1.1
  have bw := hbd.1.1.2
  have f0 := get_keep kf0 bl
  have t0 := get_keep kt0 bl
  have f1 := get_keep kf1 bw
  have t1 := get_keep kt1 bw
  have eo := get_keep c.keep0o bl
  refine ⟨fun h hf => ?_, fun h ht => ?_, fun h hp => ?_, fun h hp => ?_, fun h l hl => ?_⟩
  · by_cases hm : h ∈ lh
    · exact (hck h hm).1 hf
    · rw [eo h hm]; exact hfC h (by rw [← f0 h hm]; exact hf)
  · by_cases hm : h ∈ lh
    · exact (hck h hm).2.1 ht
    · rw [eo h hm]; exact htC h (by rw [← t0 h hm]; exact ht)
  · by_cases hm : h ∈ lh
    · exact ((hck h hm).2.2.1 hp).1
    · obtain ⟨-, -, hw, he⟩ := c.keptObj hm hp
      rw [he, f1 h hw, f0 h hm]
  · by_cases hm : h ∈ lh
    · exact ((hck h hm).2.2.1 hp).2
    · obtain ⟨-, -, hw, he⟩ := c.keptObj hm hp
      rw [he, t1 h hw, t0 h hm]
      cases e : kC.targs.get h with
      | none => rfl
      | some l => simp only [Option.map_some, targ_fix c.fix (hclC h l e)]
  · by_cases hm : h ∈ lh
    · exact (hck h hm).2.2.2 l hl
    · have hlC : kC.targs.get h = some l := by rw [← t0 h hm]; exact hl
      intro nm v hv
      have hs := hclC h l hlC nm v hv
      cases v with
      | lit _ => trivial
      | ref i => exact Nat.lt_of_lt_of_le hs hn

end

end Host.Ts.Sim.Conv
