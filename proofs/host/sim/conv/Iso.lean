import host.sim.Restart
import host.sim.conv.Frozen
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-! # Isolate: from a caller's relation at a stage call to the stage's isolated relation

At a stage call the caller's template state `s` holds a copy of the stage template's start `s0`
under a map `σ` (the caller's names for the template's resources: the callee frames, the heap they
reach and the static band), with the caller's own frames `rs` below the callee's (`Iso`, `Shift`
with a stack suffix and no framed arrays in the stage's footprint). `isolate` composes the caller's
relation with `σ`: the same target, with its stack base grown by the images of `rs`, is related to
the template start under `M.after σ`, at the substituted valuation `Shift.valuation θ ν`, with no
frames (the footprint is unframed in the caller), the events so far in the bases and the counter
offset the target's distance to the template. No target step: a conversion is a cut, the map
changes there.

What a conversion's kernel checks are: the fields of `Iso` for the concrete `σ`, `θ`, `s0`, `s`.
The closedness fields (`heapSupp` … `storesSupp`) are facts of the template alone, checked once per
stage template; the per-call checks are the number images (`checkNum`), the heap images of the
template's present addresses, the control, the stack split, jobs, stores, injectivity and the
native shift `FS`. -/

/-- **The call morphism**: the caller state `s` holds the stage template's start `s0` under `σ`,
the caller's own frames `rs` below the callee's; the template's numbers are the caller's
substituted by `θ`; the template's present addresses are unframed in the caller (`K.fr`). -/
structure Iso (F : Ffi) (FS : Map → F.S → F.S → Prop) (σ : Map) (θ : Nat → SymE) (K : Ctx) (rs : List Frame)
    (s0 : St F.S) (S0 : SSrv) (s : St F.S) (S : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → s.heap.get (σ.a a) = some (σ.hobj h)
  unfr : ∀ a, Present s0 a → K.fr (σ.a a) = none
  next : ∀ k, σ.a (s0.next + k) = s.next + k
  grows : s0.next ≤ s.next
  inj : ∀ a b, Present s0 a → Present s0 b → σ.a a = σ.a b → a = b
  presentBound : ∀ a, Present s0 a → a < s0.next
  ctl : s.ctl = σ.ctl s0.ctl
  stack : s.stack = s0.stack.map σ.frame ++ rs
  jobs : s.jobs = s0.jobs.map σ.job
  stores : s.stores = σ.stores s0.stores
  ffi : FS σ s0.ffi s.ffi
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) S0.tab.length h
  ctlSupp : Supp.ctl (Present s0) S0.tab.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) S0.tab.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) S0.tab.length j
  storesSupp : Supp.stores (Present s0) S0.tab.length s0.stores
  bigFixed : ∀ i, BigFixed K.lo K.hi i → σ.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → σ.big (ptrInt (.ext r) off) = ptrInt (.ext (σ.region r)) off
  intr : ∀ a, a < aFirst → σ.a a = a

section
variable {F : Ffi} {FS : Map → F.S → F.S → Prop} {σ : Map} {θ : Nat → SymE} {K : Ctx} {rs : List Frame}
  {s0 s : St F.S} {S0 S : SSrv}

theorem Iso.present (hs : Iso F FS σ θ K rs s0 S0 s S) {a : Nat} (ha : Present s0 a) : Present s (σ.a a) := by
  obtain ⟨h, hg⟩ := Present.get ha
  exact Present.of_get (hs.heap a h hg)

/-- The template's references are images of the caller's (literals or references of `S`). -/
theorem Iso.numSupp (hs : Iso F FS σ θ K rs s0 S0 s S) {A : Nat → Prop} {i : Nat} (hi : i < S0.tab.length) :
    Supp.nv A S.tab.length (σ.num i) := by
  obtain ⟨e, he⟩ : ∃ e, nth? S0.tab i = some e := by
    cases h : nth? S0.tab i with
    | none =>
      exfalso
      have : ∀ (l : List SymE) (j : Nat), j < l.length → nth? l j ≠ none := by
        intro l
        induction l with
        | nil => intro j hj; cases hj
        | cons x l ih =>
          intro j hj
          cases j with
          | zero => simp [nth?]
          | succ j => exact ih j (Nat.lt_of_succ_lt_succ hj)
      exact this _ _ hi h
    | some e => exact ⟨e, rfl⟩
  have hv := hs.num i e he
  cases hx : σ.num i with
  | lit _ => trivial
  | ref j =>
    rw [hx] at hv
    exact nth?_lt _ _ _ hv

end

/-- The context of the isolated relation: no frames, the bases at the call, the target's
distance to the template's counter, the caller's handle band. -/
def isoCtx {S : Type} (K : Ctx) (s0 : St S) (t : St S) : Ctx :=
  ⟨fun _ => none, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩

section
variable {F : Ffi} {FR FR0 : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W0 : Nat → Option WFrame} {stk : List Frame}
  {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {K : Ctx} {rs : List Frame} {s0 s t : St F.S} {S0 S : SSrv} {C : CSrv}

/-- **Isolate.** A target related to the caller at the call is related to the stage template's
start under `M.after σ`, at the substituted valuation, with the images of the caller's frames as a
target-only stack base. The native relation must compose with the native part of the morphism
(`hFS`); the template's oracle must hold at the new valuation (`hg`); the counter distance must
stay in range (`hroom`). -/
theorem isolate
    (hFS : ∀ x y z, FS σ x y → FR M S.tab.length y z → FR0 (M.after σ) S0.tab.length x z)
    (h : RelB F FR W stk M ν K s S t C) (hs : Iso F FS σ θ K rs s0 S0 s S)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) :
    RelB F FR0 W0 (rs.map M.frame ++ stk) (M.after σ) (Shift.valuation θ ν) (isoCtx K s0 t) s0 S0 t C := by
  refine
    { srv := ⟨fun i e he => ?_, hg⟩
      heap := fun a h' ha => ?_
      next := fun k => ?_
      offset := ?_
      room := hroom
      bigFixed := fun i hi => ?_
      bigExt := fun r off hoff => ?_
      band := h.band
      intr := fun a ha => by
        show M.a (σ.a a) = a
        rw [hs.intr a ha, h.intr a ha]
      bound := fun a ha => h.bound _ (hs.present ha)
      inj := fun a b ha hb hab => hs.inj a b ha hb (h.inj _ _ (hs.present ha) (hs.present hb) hab)
      presentBound := hs.presentBound
      framedPresent := fun a p hp => nomatch hp
      ctl := ?_
      stack := ?_
      jobs := ?_
      stores := ?_
      ffi := hFS _ _ _ hs.ffi h.ffi
      trace := ⟨[], by simp [isoCtx], by simp [isoCtx]⟩
      heapSupp := hs.heapSupp
      ctlSupp := hs.ctlSupp
      stackSupp := hs.stackSupp
      jobsSupp := hs.jobsSupp
      storesSupp := hs.storesSupp
      traceSupp := ⟨[], by simp [isoCtx], by simp⟩ }
  · have h1 := h.srv.num.val (hs.num i e he)
    rw [SymE.eval_subst] at h1
    exact h1
  · have hk := hs.unfr a (Present.of_get ha)
    have h1 := (SlotW.of_fr_none hk).1 (h.heap _ _ (hs.heap a h' ha))
    refine (SlotW.of_fr_none rfl).2 ?_
    show t.heap.get (M.a (σ.a a)) = some ((M.after σ).hobj h')
    rw [h1, Map.hobj_after]
  · show M.a (σ.a (s0.next + k)) = t.next + k
    rw [hs.next, h.next]
  · have := h.offset
    have := hs.grows
    show t.next = s0.next + (t.next - s0.next)
    omega
  · show M.big (σ.big i) = i
    rw [hs.bigFixed i hi, h.bigFixed i hi]
  · show M.big (σ.big (ptrInt (.ext r) off)) = ptrInt (.ext (M.region (σ.region r))) off
    rw [hs.bigExt r off hoff, h.bigExt _ off hoff]
  · rw [h.ctl, hs.ctl, Map.ctl_after]
  · rw [h.stack, hs.stack, List.map_append, List.map_map, List.append_assoc]
    exact congrArg (· ++ (rs.map M.frame ++ stk)) (List.map_congr_left fun f _ => Map.frame_after M σ f)
  · rw [h.jobs, hs.jobs, List.map_map]
    exact List.map_congr_left fun j _ => Map.job_after M σ j
  · rw [h.stores, hs.stores, Map.stores_after]

/-- **Isolate, then strip**: the target is the isolated target under the images of the caller's
frames, and the isolated target is related to the template's start without a stack base (the
stage contract's precondition, `StageTpl.contract`). -/
theorem isolate_under
    (hFS : ∀ x y z, FS σ x y → FR M S.tab.length y z → FR0 (M.after σ) S0.tab.length x z)
    (h : RelB F FR W stk M ν K s S t C) (hs : Iso F FS σ θ K rs s0 S0 s S)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) :
    t = Stage.under { t with stack := s0.stack.map (M.after σ).frame } (rs.map M.frame ++ stk) ∧
      RelF F FR0 W0 (M.after σ) (Shift.valuation θ ν) (isoCtx K s0 t) s0 S0
        { t with stack := s0.stack.map (M.after σ).frame } C :=
  Stage.RelB.strip (isolate (W0 := W0) hFS h hs hg hroom)

end

end Host.Ts.Sim.Conv
