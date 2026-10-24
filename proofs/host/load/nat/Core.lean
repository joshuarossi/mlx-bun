import host.ts.Run
import host.load.nat.Attr
namespace Host.Ts.FfiNat

/-! # Relating machine computations of two FFI worlds

The machine (`Host.Ts.step`) is a function of its FFI world `F`. Two worlds
`F1`, `F2` and a relation `FfiRel.R` between their native states relate
machine states that agree on the JavaScript side (`StRel`: the second is the
first with its native state replaced, `St.reFfi`) and whose native states are
related.

`TR Q t1 t2`: every successful server run of the request tree `t1` (symbolic
or concrete server) is a successful run of `t2` with the same final server and
a `Q`-related result. `MR R m1 m2` lifts this to machine computations
(continuation-passing): related continuations give related trees. A failing
left computation is related to anything. `CRel` assigns each pair of types
its canonical relation (equality, `StRel` on machine states, `FfiRel.R` on
native states, componentwise on products and options, `MR` on computations,
pointwise on functions). -/

universe u v w

/-! ## Request trees -/

structure TR {γ1 γ2 : Type} (Q : γ1 → γ2 → Prop) (t1 : Free γ1) (t2 : Free γ2) : Prop where
  s : ∀ S v1 S', interpS t1 S = some (v1, S') → ∃ v2, interpS t2 S = some (v2, S') ∧ Q v1 v2
  c : ∀ C v1 C', interpC t1 C = some (v1, C') → ∃ v2, interpC t2 C = some (v2, C') ∧ Q v1 v2

namespace TR
variable {γ1 γ2 : Type} {Q : γ1 → γ2 → Prop}

theorem pure {a : γ1} {b : γ2} (h : Q a b) : TR Q (.pure a) (.pure b) := by
  refine ⟨fun S v1 S' e => ?_, fun C v1 C' e => ?_⟩
  · rw [interpS_pure, Option.some.injEq, Prod.mk.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    exact ⟨_, rfl, h⟩
  · rw [interpC_pure, Option.some.injEq, Prod.mk.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    exact ⟨_, rfl, h⟩

theorem fail {m : String} {t : Free γ2} : TR Q (.fail m) t := by
  refine ⟨fun S v1 S' e => ?_, fun C v1 C' e => ?_⟩
  · rw [interpS_fail] at e; cases e
  · rw [interpC_fail] at e; cases e

theorem bin {op : NBin} {a b : NumV} {k1 : Nat → Free γ1} {k2 : Nat → Free γ2} (h : ∀ i, TR Q (k1 i) (k2 i)) :
    TR Q (.bin op a b k1) (.bin op a b k2) := by
  refine ⟨fun S v1 S' e => ?_, fun C v1 C' e => ?_⟩
  · rw [interpS_bin] at e ⊢
    cases ha : S.val a <;> cases hb : S.val b <;> simp only [ha, hb] at e ⊢ <;> try cases e
    exact (h _).s _ _ _ e
  · rw [interpC_bin] at e ⊢
    cases ha : C.val a <;> cases hb : C.val b <;> simp only [ha, hb] at e ⊢ <;> try cases e
    exact (h _).c _ _ _ e

theorem un {op : NUn} {a : NumV} {k1 : Nat → Free γ1} {k2 : Nat → Free γ2} (h : ∀ i, TR Q (k1 i) (k2 i)) :
    TR Q (.un op a k1) (.un op a k2) := by
  refine ⟨fun S v1 S' e => ?_, fun C v1 C' e => ?_⟩
  · rw [interpS_un] at e ⊢
    cases ha : S.val a <;> simp only [ha] at e ⊢ <;> try cases e
    exact (h _).s _ _ _ e
  · rw [interpC_un] at e ⊢
    cases ha : C.val a <;> simp only [ha] at e ⊢ <;> try cases e
    exact (h _).c _ _ _ e

theorem test {op : NTest} {a b : NumV} {k1 : Bool → Free γ1} {k2 : Bool → Free γ2} (h : ∀ r, TR Q (k1 r) (k2 r)) :
    TR Q (.test op a b k1) (.test op a b k2) := by
  refine ⟨fun S v1 S' e => ?_, fun C v1 C' e => ?_⟩
  · rw [interpS_test] at e ⊢
    cases ha : S.val a <;> cases hb : S.val b <;> simp only [ha, hb] at e ⊢ <;> try cases e
    rename_i x y
    cases hc : S.answer op x y with
    | none => simp only [hc] at e; cases e
    | some p =>
      obtain ⟨r, c'⟩ := p
      simp only [hc] at e ⊢
      exact (h _).s _ _ _ e
  · rw [interpC_test] at e ⊢
    cases ha : C.val a <;> cases hb : C.val b <;> simp only [ha, hb] at e ⊢ <;> try cases e
    exact (h _).c _ _ _ e

theorem conc {a : NumV} {k1 : F64 → Free γ1} {k2 : F64 → Free γ2} (h : ∀ x, TR Q (k1 x) (k2 x)) :
    TR Q (.conc a k1) (.conc a k2) := by
  refine ⟨fun S v1 S' e => ?_, fun C v1 C' e => ?_⟩
  · rw [interpS_conc] at e ⊢
    split at e
    · exact (h _).s _ _ _ e
    · cases e
  · rw [interpC_conc] at e ⊢
    cases ha : C.val a <;> simp only [ha] at e ⊢ <;> try cases e
    exact (h _).c _ _ _ e

end TR

/-! ## Machine computations -/

structure MR {α1 α2 : Type} (R : α1 → α2 → Prop) (m1 : M α1) (m2 : M α2) : Prop where
  run : ∀ (γ1 γ2 : Type) (Q : γ1 → γ2 → Prop) (k1 : α1 → Free γ1) (k2 : α2 → Free γ2),
    (∀ a1 a2, R a1 a2 → TR Q (k1 a1) (k2 a2)) → TR Q (m1 γ1 k1) (m2 γ2 k2)

namespace MR
variable {α1 α2 β1 β2 : Type} {R : α1 → α2 → Prop} {R' : β1 → β2 → Prop}

theorem pure {a1 : α1} {a2 : α2} (h : R a1 a2) : MR R (M.pure a1) (M.pure a2) :=
  ⟨fun _ _ _ _ _ hk => hk _ _ h⟩

theorem fail {m : String} {m2 : M α2} : MR R (M.fail (α := α1) m) m2 :=
  ⟨fun _ _ _ _ _ _ => TR.fail⟩

theorem bind {m1 : M α1} {m2 : M α2} {f1 : α1 → M β1} {f2 : α2 → M β2} (h : MR R m1 m2)
    (hf : ∀ a1 a2, R a1 a2 → MR R' (f1 a1) (f2 a2)) : MR R' (M.bind m1 f1) (M.bind m2 f2) :=
  ⟨fun γ1 γ2 Q k1 k2 hk => h.run γ1 γ2 Q _ _ fun a1 a2 ha => (hf a1 a2 ha).run γ1 γ2 Q k1 k2 hk⟩

theorem mono {m1 : M α1} {m2 : M α2} {S : α1 → α2 → Prop} (h : MR R m1 m2) (hRS : ∀ a1 a2, R a1 a2 → S a1 a2) :
    MR S m1 m2 :=
  ⟨fun γ1 γ2 Q k1 k2 hk => h.run γ1 γ2 Q k1 k2 fun a1 a2 ha => hk a1 a2 (hRS a1 a2 ha)⟩

theorem cond (c : Bool) {a1 b1 : M α1} {a2 b2 : M α2} (ha : MR R a1 a2) (hb : MR R b1 b2) :
    MR R (bif c then a1 else b1) (bif c then a2 else b2) := by
  cases c <;> assumption

theorem bin {op : NBin} {a b : NumV} {k1 : Nat → M α1} {k2 : Nat → M α2} (h : ∀ i, MR R (k1 i) (k2 i)) :
    MR R (M.bin op a b k1) (M.bin op a b k2) :=
  ⟨fun γ1 γ2 Q c1 c2 hk => TR.bin fun i => (h i).run γ1 γ2 Q c1 c2 hk⟩

theorem un {op : NUn} {a : NumV} {k1 : Nat → M α1} {k2 : Nat → M α2} (h : ∀ i, MR R (k1 i) (k2 i)) :
    MR R (M.un op a k1) (M.un op a k2) :=
  ⟨fun γ1 γ2 Q c1 c2 hk => TR.un fun i => (h i).run γ1 γ2 Q c1 c2 hk⟩

theorem test {op : NTest} {a b : NumV} {k1 : Bool → M α1} {k2 : Bool → M α2} (h : ∀ r, MR R (k1 r) (k2 r)) :
    MR R (M.test op a b k1) (M.test op a b k2) :=
  ⟨fun γ1 γ2 Q c1 c2 hk => TR.test fun r => (h r).run γ1 γ2 Q c1 c2 hk⟩

theorem conc {a : NumV} {k1 : F64 → M α1} {k2 : F64 → M α2} (h : ∀ x, MR R (k1 x) (k2 x)) :
    MR R (M.conc a k1) (M.conc a k2) :=
  ⟨fun γ1 γ2 Q c1 c2 hk => TR.conc fun x => (h x).run γ1 γ2 Q c1 c2 hk⟩

/-- A computation's result relation, read off its runs. -/
theorem run_rel {m1 : M α1} {m2 : M α2} (h : MR R m1 m2) : TR R m1.run m2.run :=
  h.run α1 α2 R Free.pure Free.pure fun _ _ ha => TR.pure ha

end MR

/-! ## Canonical relations -/

class CRel (α : Sort u) (β : Sort v) where
  r : α → β → Prop

instance (priority := high) CRel.eq {α : Sort u} : CRel α α := ⟨Eq⟩

instance CRel.prod {α1 α2 : Type u} {β1 β2 : Type v} [CRel α1 α2] [CRel β1 β2] : CRel (α1 × β1) (α2 × β2) :=
  ⟨fun p q => CRel.r p.1 q.1 ∧ CRel.r p.2 q.2⟩

instance CRel.option {α1 α2 : Type u} [CRel α1 α2] : CRel (Option α1) (Option α2) :=
  ⟨fun o1 o2 => match o1, o2 with
    | some a1, some a2 => CRel.r a1 a2
    | none, none => True
    | _, _ => False⟩

instance CRel.m {α1 α2 : Type} [CRel α1 α2] : CRel (M α1) (M α2) := ⟨MR CRel.r⟩

instance CRel.arrow {α1 α2 : Sort u} {β1 β2 : Sort v} [CRel α1 α2] [CRel β1 β2] : CRel (α1 → β1) (α2 → β2) :=
  ⟨fun f g => ∀ a b, CRel.r a b → CRel.r (f a) (g b)⟩

/-! ## Machine states -/

/-- `s` with native state `x` (the JavaScript side unchanged). -/
def _root_.Host.Ts.St.reFfi {S T : Type} (s : St S) (x : T) : St T :=
  ⟨s.heap, s.next, s.ctl, s.stack, ⟨s.aux.jobs, x, s.aux.trace, s.aux.stores⟩⟩

class FfiRel (F1 F2 : Ffi) where
  R : F1.S → F2.S → Prop

/-- Machine states agreeing on the JavaScript side with related native states. -/
def StRel {S1 S2 : Type} (R : S1 → S2 → Prop) (s1 : St S1) (s2 : St S2) : Prop :=
  ∃ x, s2 = s1.reFfi x ∧ R s1.ffi x

instance CRel.st {F1 F2 : Ffi} [FfiRel F1 F2] : CRel (St F1.S) (St F2.S) := ⟨StRel FfiRel.R⟩

instance CRel.ffi {F1 F2 : Ffi} [FfiRel F1 F2] : CRel F1.S F2.S := ⟨FfiRel.R⟩

theorem StRel.mk {S1 S2 : Type} {R : S1 → S2 → Prop} {s : St S1} {x : S2} (h : R s.ffi x) : StRel R s (s.reFfi x) :=
  ⟨x, rfl, h⟩

@[simp, rel_simp] theorem reFfi_heap {S T : Type} (s : St S) (x : T) : (s.reFfi x).heap = s.heap := rfl
@[simp, rel_simp] theorem reFfi_next {S T : Type} (s : St S) (x : T) : (s.reFfi x).next = s.next := rfl
@[simp, rel_simp] theorem reFfi_ctl {S T : Type} (s : St S) (x : T) : (s.reFfi x).ctl = s.ctl := rfl
@[simp, rel_simp] theorem reFfi_stack {S T : Type} (s : St S) (x : T) : (s.reFfi x).stack = s.stack := rfl
@[simp, rel_simp] theorem reFfi_ffi {S T : Type} (s : St S) (x : T) : (s.reFfi x).ffi = x := rfl
@[simp, rel_simp] theorem reFfi_jobs {S T : Type} (s : St S) (x : T) : (s.reFfi x).jobs = s.jobs := rfl
@[simp, rel_simp] theorem reFfi_trace {S T : Type} (s : St S) (x : T) : (s.reFfi x).trace = s.trace := rfl
@[simp, rel_simp] theorem reFfi_stores {S T : Type} (s : St S) (x : T) : (s.reFfi x).stores = s.stores := rfl
@[simp, rel_simp] theorem reFfi_aux_jobs {S T : Type} (s : St S) (x : T) : (s.reFfi x).aux.jobs = s.aux.jobs := rfl
@[simp, rel_simp] theorem reFfi_aux_ffi {S T : Type} (s : St S) (x : T) : (s.reFfi x).aux.ffi = x := rfl
@[simp, rel_simp] theorem reFfi_aux_trace {S T : Type} (s : St S) (x : T) : (s.reFfi x).aux.trace = s.aux.trace := rfl
@[simp, rel_simp] theorem reFfi_aux_stores {S T : Type} (s : St S) (x : T) : (s.reFfi x).aux.stores = s.aux.stores := rfl
@[simp, rel_simp] theorem reFfi_reFfi {S T U : Type} (s : St S) (x : T) (y : U) : (s.reFfi x).reFfi y = s.reFfi y := rfl
theorem reFfi_self {S : Type} (s : St S) : s.reFfi s.ffi = s := rfl

/-- A structure update of a state's JavaScript side. -/
@[rel_simp] theorem mk_reFfi_aux {S T : Type} (s : St S) (x : T) (h : PTrie HObj) (n : Nat) (c : Ctl) (st : List Frame) :
    St.mk h n c st (s.reFfi x).aux = (St.mk h n c st s.aux).reFfi x := rfl

@[rel_simp] theorem stRel_iff {S1 S2 : Type} {R : S1 → S2 → Prop} {s : St S1} {x : S2} :
    StRel R s (s.reFfi x) ↔ R s.ffi x :=
  ⟨fun ⟨_, e, h⟩ => by cases e; exact h, fun h => ⟨x, rfl, h⟩⟩

/-! ## Option and list reductions -/

section
variable {α β : Type u} (f : α → β) (a : α)
@[rel_simp] theorem omap_some : Option.map f (some a) = some (f a) := rfl
@[rel_simp] theorem omap_none : Option.map f none = none := rfl
@[rel_simp] theorem obind_some (g : α → Option β) : (some a).bind g = g a := rfl
@[rel_simp] theorem obind_none (g : α → Option β) : (none : Option α).bind g = none := rfl
@[rel_simp] theorem lmap_nil : List.map f [] = [] := rfl
@[rel_simp] theorem lmap_cons (l : List α) : List.map f (a :: l) = f a :: List.map f l := rfl
end

/-! ## Simulating worlds -/

abbrev Writes := List (Nat × Nat × List Byte)

/-- The left continuation fails on a stuck native call (the machine's `ffiDone`). -/
def FailsNone {γ : Type} {α : Type} (k : Option α → Free γ) : Prop :=
  (∀ S, interpS (k none) S = none) ∧ (∀ C, interpC (k none) C = none)

/-- A native call of the first world simulated by the second's: related continuations that fail
on a stuck call give related trees. -/
structure CallSim {F1 F2 : Ffi} [FfiRel F1 F2] (m1 : M (Option (F1.S × Ret × Writes)))
    (m2 : M (Option (F2.S × Ret × Writes))) : Prop where
  run : ∀ (γ1 γ2 : Type) (Q : γ1 → γ2 → Prop) (k1 : Option (F1.S × Ret × Writes) → Free γ1)
    (k2 : Option (F2.S × Ret × Writes) → Free γ2), FailsNone k1 →
    (∀ o1 o2, CRel.r o1 o2 → TR Q (k1 o1) (k2 o2)) → TR Q (m1 γ1 k1) (m2 γ2 k2)

/-- Memory reads and symbol addresses agree on related native states (all a pure function needs). -/
class FfiReadSim (F1 F2 : Ffi) [FfiRel F1 F2] : Prop where
  read : ∀ x1 x2, FfiRel.R x1 x2 → F1.read x1 = F2.read x2
  addr : F1.addr = F2.addr

/-- The second world simulates the first on related native states: memory reads agree, symbol
addresses agree, and calls and trace continuations are simulated. -/
class FfiSim (F1 F2 : Ffi) [FfiRel F1 F2] : Prop extends FfiReadSim F1 F2 where
  call : ∀ x1 x2 name args, FfiRel.R x1 x2 → CallSim (F1.call x1 name args) (F2.call x2 name args)
  back : ∀ x1 x2 a, FfiRel.R x1 x2 → CallSim (F1.back x1 a) (F2.back x2 a)

@[rel_simp] theorem rel_addr {F1 F2 : Ffi} [FfiRel F1 F2] [FfiReadSim F1 F2] (name : Name) :
    F2.addr name = F1.addr name := by
  rw [FfiReadSim.addr (F1 := F1) (F2 := F2)]

/-- A world related to itself by equality of native states. -/
@[reducible] def idRel (F : Ffi) : FfiRel F F := ⟨Eq⟩

theorem idReadSim (F : Ffi) : @FfiReadSim F F (idRel F) :=
  @FfiReadSim.mk F F (idRel F) (fun _ _ h => by cases h; rfl) rfl

/-- A world with native states `S` (for statements about functions polymorphic in the state type). -/
def stateFfi (S : Type) : Ffi := ⟨S, fun _ _ _ => M.pure none, fun _ _ _ _ => none, fun _ => 0, fun _ _ => M.pure none⟩

/-- A native call followed by a continuation failing on a stuck call (the machine's `ffiDone`). -/
theorem MR.callSite {F1 F2 : Ffi} [FfiRel F1 F2] {β1 β2 : Type} {R : β1 → β2 → Prop}
    {m1 : M (Option (F1.S × Ret × Writes))} {m2 : M (Option (F2.S × Ret × Writes))}
    {k1 : Option (F1.S × Ret × Writes) → M β1} {k2 : Option (F2.S × Ret × Writes) → M β2}
    (hm : CallSim m1 m2) (hk : ∀ o1 o2, CRel.r o1 o2 → MR R (k1 o1) (k2 o2)) (hn : ∃ msg, k1 none = M.fail msg) :
    MR R (M.bind m1 k1) (M.bind m2 k2) := by
  obtain ⟨msg, hmsg⟩ := hn
  refine ⟨fun γ1 γ2 Q c1 c2 hc => ?_⟩
  show TR Q (m1 γ1 fun a => k1 a γ1 c1) (m2 γ2 fun a => k2 a γ2 c2)
  refine hm.run γ1 γ2 Q _ _ ⟨fun S => ?_, fun C => ?_⟩ fun o1 o2 h => (hk o1 o2 h).run γ1 γ2 Q c1 c2 hc
  · show interpS (k1 none γ1 c1) S = none
    rw [hmsg]; rfl
  · show interpC (k1 none γ1 c1) C = none
    rw [hmsg]; rfl

end Host.Ts.FfiNat
