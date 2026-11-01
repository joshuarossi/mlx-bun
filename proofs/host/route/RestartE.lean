import host.sim.conv.HandOff
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim

/-! # The restart without `grows`

`ShiftD` asks the template to grow: `s0.next ≤ s1.next`. Its proofs use that only for the target's counter offset, which needs
`s0.next ≤ t.next`. POST's framed chain allocates 13 cells fewer than the concrete run the decode template was cut from, and the
context's offset pays for them, so here the target's bound replaces it. `ShiftE`, `restartDropE`, `compactE` and
`Conv.full_handoffTbE` are `ShiftD`, `restartDrop`, `compact` and `Conv.full_handoffTb` with that one change. -/

structure ShiftE (F : Ffi) (FS : Map → F.S → F.S → Prop) (σ : Map) (θ : Nat → SymE) (kp : Nat → Bool)
    (W0 : Nat → Option WFrame) (K1 : Ctx) (s0 : St F.S) (S0 : SSrv) (s1 : St F.S) (S1 : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S1.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → kp a = false → W0 a = none → s1.heap.get (σ.a a) = some (σ.hobj h)
  unfr : ∀ a h, s0.heap.get a = some h → kp a = false → W0 a = none → K1.fr (σ.a a) = none
  framed : ∀ a, kp a = true → σ.a a = a ∧ ∃ pre pre' o xs, K1.fr a = some (pre, pre') ∧
    s0.heap.get a = some (.obj o) ∧ o.kind = .array pre ∧
    s1.heap.get a = some (.obj { σ.obj o with kind := .array (pre ++ xs) })
  wide : ∀ a w, W0 a = some w → kp a = false ∧ σ.a a = a ∧ K1.fr a ≠ none ∧ Present s0 a ∧
    (∀ h, s0.heap.get a = some h → s1.heap.get a = some (σ.hobj h)) ∧ WFix σ (Present s0) w
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

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop} {W0 W1 : Nat → Option WFrame}

private theorem obj_withKind' (M : Map) (o : Obj) (k k' : Kind) :
    { M.obj { o with kind := k } with kind := k' } = { M.obj o with kind := k' } := rfl

theorem restartDropE {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {kp : Nat → Bool} {K1 : Ctx}
    {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv}
    (hFS : ∀ x y z, FS σ x y → FR M S1.tab.length y z → FR (M.after σ) S0.tab.length x z)
    (hr : RelF F FR W1 M ν K1 s1 S1 t C) (hs : ShiftE F FS σ θ kp W0 K1 s0 S0 s1 S1)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) (hge : s0.next ≤ t.next) :
    RelF F FR W0 (M.after σ) (Shift.valuation θ ν)
      ⟨dropNext M K1 kp W0 s1, s0.trace, t.trace, t.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t C := by
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
  · show SlotW (M.after σ) (dropNext M K1 kp W0 s1) W0 a h (t.heap.get (M.a (σ.a a)))
    cases hk : kp a with
    | false =>
      cases hw0 : W0 a with
      | none =>
        have hk1 := hs.unfr a h ha hk hw0
        have h1 := (SlotW.of_fr_none hk1).1 (hr.heap _ _ (hs.heap a h ha hk hw0))
        have hn : dropNext M K1 kp W0 s1 a = none := by simp [dropNext, hk, hw0]
        rw [SlotW.of_fr_none hn, h1, Map.hobj_after]
      | some w =>
        obtain ⟨-, hfix, hK1, -, hkeep, hwf⟩ := hs.wide a w hw0
        obtain ⟨p, hp⟩ := Option.ne_none_iff_exists'.1 hK1
        have hdn : dropNext M K1 kp W0 s1 a = some p := by simp [dropNext, hk, hw0, hp]
        have h1 := (SlotW.of_wide hp (hW a w hw0)).1 (hr.heap _ _ (hkeep h ha))
        rw [hfix]
        exact (SlotW.of_wide hdn hw0).2 (WideOK.after hwf hs.inj (hs.heapSupp a h ha) h1)
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
      have hdn : dropNext M K1 kp W0 s1 a = some (pre, pre' ++ M.vals ys) := by
        rw [dropNext_eq hk]
        simp only [Shift.framedNext, hfr, hs1, List.drop_left]
      refine (SlotW.of_w_none hw0).2 ((SlotOK.some_iff hdn).2 ⟨o, o', rfl, ht, [], by rw [hkind, List.append_nil], ?_⟩)
      rw [ho', obj_withKind', Map.obj_after]
      simp only [Map.vals, List.map_nil, List.append_nil]
  · show M.a (σ.a (s0.next + k)) = t.next + k
    rw [hs.next, hr.next]
  · have := hr.offset
    have := hge
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
      | none => simp [dropNext, hka, hw0] at hp
      | some w => exact (hs.wide a w hw0).2.2.2.1
  · rw [hr.ctl, hs.ctl, Map.ctl_after]
  · rw [hr.stack, hs.stack, List.map_map]
    exact congrArg (· ++ []) (List.map_congr_left fun f _ => Map.frame_after M σ f)
  · rw [hr.jobs, hs.jobs, List.map_map]
    exact List.map_congr_left fun j _ => Map.job_after M σ j
  · rw [hr.stores, hs.stores, Map.stores_after]

/-! ## `Iter`'s steps under frames -/

theorem compactE {W : Nat → Option WFrame} {M κ : Map} {ν : Nat → F64} {θ : Nat → SymE} {K1 : Ctx}
    {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv}
    (hFS : ∀ x y z, FS κ x y → FR M S1.tab.length y z → FR (M.after κ) S0.tab.length x z)
    (hr : RelF F FR W M ν K1 s1 S1 t C) (hs : ShiftE F FS κ θ (kpOf K1 W) W K1 s0 S0 s1 S1)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) (hge : s0.next ≤ t.next) :
    RelF F FR W (M.after κ) (Shift.valuation θ ν)
      ⟨Shift.framedNext M K1 s1, s0.trace, t.trace, t.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t C := by
  have h := restartDropE (kp := kpOf K1 W) (W0 := W) hFS hr hs (fun _ _ hw => hw) hg hroom hge
  rwa [dropNext_keep hr] at h

end

namespace Conv
open Host.Ts Host.Ts.Sim.Full Host.Load.Layers

theorem full_handoffE (NB : Nat) {Pp P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    (hb : Pp.NL = Pp.N0) (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 t1 C1) (hne : s1.ffi ≠ s0.ffi)
    (hshift : ShiftE FF (fun σ x y => x = s0.ffi ∧ FullShiftH P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P0.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound) (hge : s0.next ≤ t1.next)
    (hroomN : NRoom P0 (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRF { P0 with rest := r } NB) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  have hsh : FullShiftH { P0 with rest := r } S0.tab.length κ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  obtain ⟨P1, hP1, h1f⟩ := h1.ffi
  have hb1 : P1.E = Pp.E ∧ P1.NE = Pp.NE := by
    rcases hP1 with rfl | ⟨k, -, -, rfl⟩ <;> exact ⟨rfl, rfl⟩
  have hroomN1 : NRoom P1 (toLoad s0.ffi) (toLoad t1.ffi) := by
    unfold NRoom at hroomN ⊢; rw [hb1.1, hb1.2, ← hE, ← hNE]; exact hroomN
  have hf : FRrH { Pp with rest := r } { P0 with rest := r } NB s0.ffi M1 S1.tab.length s1.ffi t1.ffi :=
    ⟨fun h => absurd h hne, fun _ => ⟨P1, hP1, ⟨h1f.load.weak.clear, hroomN1⟩, h1f.bridge, h1f.live, h1f.kern,
      h1f.pend⟩⟩
  have h2 := h1.mapFR' (FR' := FRrH { Pp with rest := r } { P0 with rest := r } NB s0.ffi) hf
  have hshift' : ShiftE FF (FSnH { P0 with rest := r } S0.tab.length s0.ffi) κ θ (kpOf K1 W) W K1 s0 S0 s1 S1 :=
    { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := compactE (FS := FSnH { P0 with rest := r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => fsnH_compose (Pp := { Pp with rest := r }) (P0 := { P0 with rest := r }) hb hlo hE hNE hNB _ x y z hxy hyz) h2
    hshift' hg hroom hge
  obtain ⟨⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi.1 rfl
  have hz : (toLoad t1.ffi).mlx.tokens = (toLoad s0.ffi).mlx.tokens.map (M1.after κ).nv ++ r := by
    have h' : (mlxOf t1.ffi).tokens = (mlxOf s1.ffi).tokens.map M1.nv ++ P1.rest := h1f.load.mlx.tokensX
    rw [show P1.rest = r from hP1.rest, hsh.tokens, List.map_map] at h'
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map (M1.after κ).nv ++ r
    rw [h']
    congr 1
    exact List.map_congr_left fun t _ => Map.nv_after M1 κ t
  have hld := G.LoadRw.rebig hw0 hbig hsh.tokSupp hz
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next).handle h = (M1.after κ).handle h :=
    fun h hh => rebig_handle _ _ _ _ (hw0.mlx.hlt h (.inr hh))
  have hffi : FullRF { P0 with rest := r } NB ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next)
      S0.tab.length s0.ffi t1.ffi :=
    ⟨hld, bridgeF_names _ _ _ _ hb0 rfl, hl0.rebig hobj, hk0.rebig hobj rfl, hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

/-- **The hand-off from the prefill's last cut with the template's readback suffix**: the suffix `τ`
after the queue's head `tk` moves into the target's remaining readbacks (`RelF.dropTokensX`), then
`full_handoff` from the end with the head alone. -/
theorem full_handoffTE (NB : Nat) {Pp P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    {tk : NumV} {τ : List NumV}
    (hb : Pp.NL = Pp.N0) (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hx : (mlxOf s1.ffi).tokens = [tk] ++ τ)
    (hne : (s1.setFfi (fullSetTokens s1.ffi [tk])).ffi ≠ s0.ffi)
    (hshift : ShiftE FF (fun σ x y => x = s0.ffi ∧ FullShiftH P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 (s1.setFfi (fullSetTokens s1.ffi [tk])) S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P0.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound) (hge : s0.next ≤ t1.next)
    (hroomN : NRoom P0 (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRF { P0 with rest := τ.map M1.nv ++ r } NB) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 (s1.setFfi (fullSetTokens s1.ffi [tk])), s0.trace, t1.trace, t1.next - s0.next,
        K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  full_handoffE NB hb hlo hE hNE hNB (RelF.dropTokensX h1 hx) hne hshift hbig hfree hband hg hroom hge hroomN

/-- `full_handoffT` with the target's bridge pinned to its value at the hand-off (`fullWorldFb`). -/
theorem full_handoffTbE (NB : Nat) {Pp P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    {tk : NumV} {τ : List NumV}
    (hb : Pp.NL = Pp.N0) (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hx : (mlxOf s1.ffi).tokens = [tk] ++ τ)
    (hne : (s1.setFfi (fullSetTokens s1.ffi [tk])).ffi ≠ s0.ffi)
    (hshift : ShiftE FF (fun σ x y => x = s0.ffi ∧ FullShiftH P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 (s1.setFfi (fullSetTokens s1.ffi [tk])) S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P0.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound) (hge : s0.next ≤ t1.next)
    (hroomN : NRoom P0 (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRFb (bridgeOf t1.ffi) { P0 with rest := τ.map M1.nv ++ r } NB) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 (s1.setFfi (fullSetTokens s1.ffi [tk])), s0.trace, t1.trace, t1.next - s0.next,
        K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  have h := full_handoffTE NB hb hlo hE hNE hNB h1 hx hne hshift hbig hfree hband hg hroom hge hroomN
  { h with ffi := h.ffi.pin }


end Conv

end Host.Ts.Sim
