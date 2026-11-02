import host.sim.conv.CompactBridge
import host.sim.steps.Builtins
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.StringIndex

/-- The entries of a map without the string keys `gs`. -/
def dropCodes (gs : List Nat) : List (Val × Val) → List (Val × Val)
  | [] => []
  | (.str cs, v) :: es => bif gs.contains (pack cs) then dropCodes gs es else (.str cs, v) :: dropCodes gs es
  | p :: es => p :: dropCodes gs es

theorem firstValue_dropCodes_off {gs : List Nat} {c : Nat} (hc : c ∉ gs) :
    ∀ es, firstValue c (dropCodes gs es) = firstValue c es
  | [] => rfl
  | (k, v) :: es => by
    have ih := firstValue_dropCodes_off hc es
    cases k with
    | str cs =>
      simp only [dropCodes]
      cases hg : gs.contains (pack cs) with
      | true =>
        have hm : pack cs ∈ gs := List.contains_iff_mem.mp hg
        have hne : pack cs ≠ c := fun e => hc (e ▸ hm)
        simp only [cond_true, firstValue, Bool.not_eq_true]
        rw [ih]
        have hb : Nat.beq (pack cs) c = false := by
          cases e : Nat.beq (pack cs) c with
          | false => rfl
          | true => exact absurd (Nat.eq_of_beq_eq_true e) hne
        rw [hb]
        rfl
      | false =>
        simp only [cond_false, firstValue]
        rw [ih]
    | _ => simpa only [dropCodes, firstValue] using ih

theorem firstValue_dropCodes_on {gs : List Nat} {c : Nat} (hc : c ∈ gs) :
    ∀ es, firstValue c (dropCodes gs es) = none
  | [] => rfl
  | (k, v) :: es => by
    have ih := firstValue_dropCodes_on hc es
    cases k with
    | str cs =>
      simp only [dropCodes]
      cases hg : gs.contains (pack cs) with
      | true =>
        simp only [cond_true]
        exact ih
      | false =>
        have hne : pack cs ≠ c := fun e => by
          have : gs.contains (pack cs) = true := List.contains_iff_mem.mpr (e ▸ hc)
          rw [hg] at this
          cases this
        have hb : Nat.beq (pack cs) c = false := by
          cases e : Nat.beq (pack cs) c with
          | false => rfl
          | true => exact absurd (Nat.eq_of_beq_eq_true e) hne
        simp only [cond_false, firstValue]
        rw [hb]
        exact ih
    | _ => simpa only [dropCodes, firstValue] using ih

end Host.Ts.StringIndex

namespace Host.Ts.Sim
open Host.Ts

/-! # The restart into a template the classes share

`restartDrop` restarts into a copy of the end state. A shared template isn't one. Each class created only the kernels its row counts
used, so at some cells the template and the class hold different things, and from here on those cells are framed (`WFrame.ghost`, the
memo's ghost keys). A template may also sit above the class's address counter, so `s0.next ≤ s1.next` can fail, and only the target's
counter need be above it.

So `ShiftW` is `ShiftD` with `grows` gone and `wide` read through `WideImg`, and the frames after the restart are the kept arrays and
all of `W0`, framed before or not (`frW`). -/

/-- The entries `a`'s frame relates: the template's image `h`, the class's `h1`. -/
def WideImg : WFrame → HObj → HObj → Prop
  | .ghost, .cell _, .cell _ => True
  | .ghost, .obj o, .obj o1 => Wideable o.kind ∧ ∃ es, o1.kind = .map es
  | .memo gs, .obj o, .obj o1 => ∃ es, o1.kind = .map es ∧ o = { o1 with kind := .map (StringIndex.dropCodes gs es) }
  | _, _, _ => False

/-- The target's entry for the class's is one for the template's. -/
theorem WideImg.keep {M : Map} {w : WFrame} {h h1 : HObj} {fr : Nat → Option (List Val × List Val)} {W1 : Nat → Option WFrame}
    {a : Nat} {tv : Option HObj} (hi : WideImg w h h1) (hc : fr a = none ∨ W1 a = some w)
    (hs : SlotW M fr W1 a h1 tv) : WideOK M w h tv := by
  by_cases hfr : fr a = none
  · have ht := (SlotW.of_fr_none hfr).1 hs
    subst ht
    cases w with
    | ghost =>
      cases h with
      | cell v => cases h1 with
        | cell v1 => trivial
        | obj o1 => exact hi.elim
      | obj o => cases h1 with
        | cell v1 => exact hi.elim
        | obj o1 =>
          obtain ⟨hw, es, he⟩ := hi
          refine ⟨hw, ?_⟩
          change Wideable (M.kind o1.kind)
          rw [he]
          trivial
    | memo gs =>
      cases h with
      | cell v => cases h1 <;> exact hi.elim
      | obj o => cases h1 with
        | cell v1 => exact hi.elim
        | obj o1 =>
          obtain ⟨es, he, rfl⟩ := hi
          refine ⟨StringIndex.dropCodes gs es, M.pairs es, rfl, ?_, ?_, ?_⟩
          · obtain ⟨kd, pr, ps, pv, ex⟩ := o1
            cases he
            rfl
          · intro c v hv
            by_cases hcg : c ∈ gs
            · rw [StringIndex.firstValue_dropCodes_on hcg] at hv
              cases hv
            · rw [StringIndex.firstValue_dropCodes_off hcg] at hv
              refine ⟨M.val v, ?_, .inr rfl⟩
              rw [bi_firstValue, hv]
              rfl
          · intro c hcg hv
            rw [StringIndex.firstValue_dropCodes_off hcg] at hv
            rw [bi_firstValue, hv]
            rfl
    | _ => exact hi.elim
  · obtain ⟨p, hp⟩ := Option.ne_none_iff_exists'.1 hfr
    have hw : W1 a = some w := hc.resolve_left hfr
    have hk := (SlotW.of_wide hp hw).1 hs
    cases w with
    | ghost =>
      cases h with
      | cell v => cases h1 with
        | cell v1 =>
          cases tv with
          | none => exact hk.elim
          | some x => cases x with
            | cell _ => trivial
            | obj _ => exact hk.elim
        | obj o1 => exact hi.elim
      | obj o => cases h1 with
        | cell v1 => exact hi.elim
        | obj o1 =>
          cases tv with
          | none => exact hk.elim
          | some x => cases x with
            | cell _ => exact hk.elim
            | obj o' => exact ⟨hi.1, hk.2⟩
    | memo gs =>
      cases h with
      | cell v => cases h1 <;> exact hi.elim
      | obj o => cases h1 with
        | cell v1 => exact hi.elim
        | obj o1 =>
          obtain ⟨es, he, rfl⟩ := hi
          cases tv with
          | none => exact hk.elim
          | some x => cases x with
            | cell _ => exact hk.elim
            | obj o' =>
              obtain ⟨es1, es', hk1, rfl, hm, hn⟩ := hk
              have hes : es1 = es := by
                rw [he] at hk1
                exact (Kind.map.inj hk1).symm
              subst hes
              refine ⟨StringIndex.dropCodes gs es1, es', rfl, ?_, ?_, ?_⟩
              · obtain ⟨kd, pr, ps, pv, ex⟩ := o1
                rfl
              · intro c v hv
                by_cases hcg : c ∈ gs
                · rw [StringIndex.firstValue_dropCodes_on hcg] at hv
                  cases hv
                · rw [StringIndex.firstValue_dropCodes_off hcg] at hv
                  exact hm c v hv
              · intro c hcg hv
                rw [StringIndex.firstValue_dropCodes_off hcg] at hv
                exact hn c hcg hv
    | _ => exact hi.elim

structure ShiftW (F : Ffi) (FS : Map → F.S → F.S → Prop) (σ : Map) (θ : Nat → SymE) (kp : Nat → Bool)
    (W0 W1 : Nat → Option WFrame) (K1 : Ctx) (s0 : St F.S) (S0 : SSrv) (s1 : St F.S) (S1 : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S1.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → kp a = false → W0 a = none → s1.heap.get (σ.a a) = some (σ.hobj h)
  unfr : ∀ a h, s0.heap.get a = some h → kp a = false → W0 a = none → K1.fr (σ.a a) = none
  framed : ∀ a, kp a = true → σ.a a = a ∧ ∃ pre pre' o xs, K1.fr a = some (pre, pre') ∧
    s0.heap.get a = some (.obj o) ∧ o.kind = .array pre ∧
    s1.heap.get a = some (.obj { σ.obj o with kind := .array (pre ++ xs) })
  /-- A frame after the restart: a ghost or memo, framed before or not. -/
  wide : ∀ a w, W0 a = some w → kp a = false ∧ σ.a a = a ∧ Present s0 a ∧ WFix σ (Present s0) w ∧
    (K1.fr a = none ∨ W1 a = some w) ∧
    ∀ h, s0.heap.get a = some h → ∃ h1, s1.heap.get a = some h1 ∧ WideImg w (σ.hobj h) h1
  next : ∀ k, σ.a (s0.next + k) = s1.next + k
  present : ∀ a, Present s0 a → Present s1 (σ.a a)
  inj : ∀ a b, Present s0 a → Present s0 b → σ.a a = σ.a b → a = b
  presentBound : ∀ a, Present s0 a → a < s0.next
  ctl : s1.ctl = σ.ctl s0.ctl
  stack : s1.stack = s0.stack.map σ.frame
  jobs : s1.jobs = s0.jobs.map σ.job
  stores : s1.stores = σ.stores s0.stores
  ffi : FS σ s0.ffi s1.ffi
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) S0.tab.length h
  ctlSupp : Supp.ctl (Present s0) S0.tab.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) S0.tab.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) S0.tab.length j
  storesSupp : Supp.stores (Present s0) S0.tab.length s0.stores
  bigFixed : ∀ i, BigFixed K1.lo K1.hi i → σ.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → σ.big (ptrInt (.ext r) off) = ptrInt (.ext (σ.region r)) off
  intr : ∀ a, a < aFirst → σ.a a = a

/-- The frames after the restart: `Shift.framedNext` at the kept arrays, all of `W0`. -/
def frW {F : Ffi} (M : Map) (K1 : Ctx) (kp : Nat → Bool) (W0 : Nat → Option WFrame) (s1 : St F.S)
    (a : Nat) : Option (List Val × List Val) :=
  bif kp a then Shift.framedNext M K1 s1 a else bif (W0 a).isSome then some ([], []) else none

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop} {W0 W1 : Nat → Option WFrame}

private theorem obj_withKindW (M : Map) (o : Obj) (k k' : Kind) :
    { M.obj { o with kind := k } with kind := k' } = { M.obj o with kind := k' } := rfl

theorem restartW {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {kp : Nat → Bool} {K1 : Ctx}
    {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv}
    (hFS : ∀ x y z, FS σ x y → FR M S1.tab.length y z → FR (M.after σ) S0.tab.length x z)
    (hr : RelF F FR W1 M ν K1 s1 S1 t C) (hs : ShiftW F FS σ θ kp W0 W1 K1 s0 S0 s1 S1)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) (hge : s0.next ≤ t.next) :
    RelF F FR W0 (M.after σ) (Shift.valuation θ ν)
      ⟨frW M K1 kp W0 s1, s0.trace, t.trace, t.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t C := by
  refine
    { srv := ⟨fun i e he => ?_, hg⟩
      heap := fun a h ha => ?_
      next := fun k => ?_
      offset := ?_
      room := hroom
      bigFixed := fun i hi => ?_
      bigExt := fun r off hoff => ?_
      band := hr.band
      intr := fun a ha => by
        show M.a (σ.a a) = a
        rw [hs.intr a ha, hr.intr a ha]
      bound := fun a ha => hr.bound _ (hs.present a ha)
      inj := fun a b ha hb hab => hs.inj a b ha hb (hr.inj _ _ (hs.present a ha) (hs.present b hb) hab)
      presentBound := hs.presentBound
      framedPresent := fun a p hp => ?_
      ctl := ?_
      stack := ?_
      jobs := ?_
      stores := ?_
      ffi := hFS _ _ _ hs.ffi hr.ffi
      trace := ⟨[], by simp, by simp⟩
      heapSupp := hs.heapSupp
      ctlSupp := hs.ctlSupp
      stackSupp := hs.stackSupp
      jobsSupp := hs.jobsSupp
      storesSupp := hs.storesSupp
      traceSupp := ⟨[], by simp, by simp⟩ }
  · have h1 := hr.srv.num.val (hs.num i e he)
    rw [SymE.eval_subst] at h1
    exact h1
  · show SlotW (M.after σ) (frW M K1 kp W0 s1) W0 a h (t.heap.get (M.a (σ.a a)))
    cases hk : kp a with
    | false =>
      cases hw0 : W0 a with
      | none =>
        have hk1 := hs.unfr a h ha hk hw0
        have h1 := (SlotW.of_fr_none hk1).1 (hr.heap _ _ (hs.heap a h ha hk hw0))
        have hn : frW M K1 kp W0 s1 a = none := by simp [frW, hk, hw0]
        rw [SlotW.of_fr_none hn, h1, Map.hobj_after]
      | some w =>
        obtain ⟨-, hfix, -, hwf, hc, hkeep⟩ := hs.wide a w hw0
        obtain ⟨h1, hg1, hi⟩ := hkeep h ha
        have hdn : frW M K1 kp W0 s1 a = some ([], []) := by simp [frW, hk, hw0]
        have ht := hi.keep hc (hr.heap _ _ hg1)
        rw [hfix]
        exact (SlotW.of_wide hdn hw0).2 (WideOK.after hwf hs.inj (hs.heapSupp a h ha) ht)
    | true =>
      obtain ⟨hfix, pre, pre', o, xs, hfr, ho, hkind, hs1⟩ := hs.framed a hk
      rw [ho] at ha
      cases ha
      have hw0 : W0 a = none := by
        cases e : W0 a with
        | none => rfl
        | some w => rw [(hs.wide a w e).1] at hk; cases hk
      have hw : W1 a = none := hr.w_none (.of_array (obj?_iff.2 hs1) rfl) hfr
      have h1 := (SlotW.of_w_none hw).1 (hr.heap _ _ hs1)
      rw [hfix]
      obtain ⟨o1, o', he1, ht, ys, hys, ho'⟩ := (SlotOK.some_iff hfr).1 h1
      cases he1
      simp only at hys
      have hxy : ys = xs := (List.append_cancel_left (Kind.array.inj hys)).symm
      subst hxy
      have hdn : frW M K1 kp W0 s1 a = some (pre, pre' ++ M.vals ys) := by
        simp only [frW, hk, cond_true, Shift.framedNext, hfr, hs1, List.drop_left]
      refine (SlotW.of_w_none hw0).2 ((SlotOK.some_iff hdn).2 ⟨o, o', rfl, ht, [], by rw [hkind, List.append_nil], ?_⟩)
      rw [ho', obj_withKindW, Map.obj_after]
      simp only [Map.vals, List.map_nil, List.append_nil]
  · show M.a (σ.a (s0.next + k)) = t.next + k
    rw [hs.next, hr.next]
  · have := hr.offset
    show t.next = s0.next + (t.next - s0.next)
    omega
  · show M.big (σ.big i) = i
    rw [hs.bigFixed i hi, hr.bigFixed i hi]
  · show M.big (σ.big (ptrInt (.ext r) off)) = ptrInt (.ext (M.region (σ.region r))) off
    rw [hs.bigExt r off hoff, hr.bigExt _ off hoff]
  · cases hka : kp a with
    | true =>
      obtain ⟨-, pre, pre', o, xs, -, ho, -⟩ := hs.framed a hka
      exact Present.of_get ho
    | false =>
      cases hw0 : W0 a with
      | none => simp [frW, hka, hw0] at hp
      | some w => exact (hs.wide a w hw0).2.2.1
  · rw [hr.ctl, hs.ctl, Map.ctl_after]
  · rw [hr.stack, hs.stack, List.map_map]
    exact congrArg (· ++ []) (List.map_congr_left fun f _ => Map.frame_after M σ f)
  · rw [hr.jobs, hs.jobs, List.map_map]
    exact List.map_congr_left fun j _ => Map.job_after M σ j
  · rw [hr.stores, hs.stores, Map.stores_after]

end

namespace Conv
open Host.Ts.Sim.Full Host.Load.Layers

/-- **Compaction at a raise, into a template the classes share.** -/
theorem full_compactW (NB : Nat) {P P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W1 W0 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv}
    {θ : Nat → SymE} (hP0 : Raised P P0) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { P with rest := r } NB) W1 M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftW FF (fun σ x y => x = s0.ffi ∧ FullShiftQX P0 S0.tab.length σ x y) κ θ kp W0 W1 K1 s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound) (hge : s0.next ≤ t1.next)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRXD { P with rest := r } NB) W0 ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ ν)
      ⟨frW M1 K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  have hn := bridgeX_names
  have hc := shiftComp_X
  have hsh : FullShiftQB BridgeX { P0 with rest := r } S0.tab.length κ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  obtain ⟨P1, hP1, h1f⟩ := h1.ffi
  obtain ⟨-, hE1, hNE1, -⟩ := Raised.restart (.inl rfl) hP1
  have hroomN1 : NRoom P1 (toLoad s0.ffi) (toLoad t1.ffi) := by
    unfold NRoom at hroomN ⊢; rw [hE1, hNE1]; exact hroomN
  have hf : FRrFBD BridgeX { P with rest := r } NB s0.ffi M1 S1.tab.length s1.ffi t1.ffi :=
    ⟨P1, hP1, ⟨h1f.load.weak.clear, hroomN1⟩, h1f.bridge, h1f.live, h1f.kern, h1f.pend⟩
  have h2 := h1.mapFR' (FR' := FRrFBD BridgeX { P with rest := r } NB s0.ffi) hf
  have hshift' : ShiftW FF (FSnQB BridgeX { P0 with rest := r } S0.tab.length s0.ffi) κ θ kp W0 W1 K1 s0 S0 s1 S1 :=
    { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := restartW (FS := FSnQB BridgeX { P0 with rest := r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => fsnQBD_compose hc (hP0.withRest r) hNB _ x y z hxy hyz) h2 hshift' hg hroom hge
  obtain ⟨P2, hP2, ⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi
  obtain ⟨-, hE2, -, -⟩ := Raised.restart (.inl rfl) hP2
  have hz : (toLoad t1.ffi).mlx.tokens = (toLoad s0.ffi).mlx.tokens.map (M1.after κ).nv ++ r := by
    have h' : (mlxOf t1.ffi).tokens = (mlxOf s1.ffi).tokens.map M1.nv ++ P1.rest := h1f.load.mlx.tokensX
    rw [show P1.rest = r from hP1.rest, hsh.tokens, List.map_map] at h'
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map (M1.after κ).nv ++ r
    rw [h']
    congr 1
    exact List.map_congr_left fun t _ => Map.nv_after M1 κ t
  have hld : G.LoadR { P2 with rest := r } NB
      ((M1.after κ).rebig (mlxOf s0.ffi).next P2.E (mlxOf t1.ffi).next) S0.tab.length (toLoad s0.ffi)
      (toLoad t1.ffi) := G.LoadRw.rebig hw0 (by rw [hE2]; exact hbig) hsh.tokSupp hz
  have hmap : (M1.after κ).rebig (mlxOf s0.ffi).next P2.E (mlxOf t1.ffi).next =
      (M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next := by rw [hE2]
  rw [hmap] at hld
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next).handle h = (M1.after κ).handle h :=
    fun h hh => rebig_handle _ _ _ _ (hw0.mlx.hlt h (.inr hh))
  have hffi : FullRXD { P with rest := r } NB
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next) S0.tab.length s0.ffi t1.ffi :=
    ⟨{ P2 with rest := r }, hP2.withRest r, hld, hn _ _ _ _ hb0 rfl, hl0.rebig hobj, hk0.rebig hobj rfl,
      hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

end Conv
end Host.Ts.Sim
