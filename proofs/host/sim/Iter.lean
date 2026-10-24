import host.sim.dispatch.Ok
import host.sim.RestartProof
import host.sim.Upd
namespace Host.Ts.Sim
open Host.Ts

/-! # One template iteration

A template iteration is a checked run (`runOk`) from the template start to its
end. `iter_run` transports it to every related target. At the end, the next
iteration's token is bound to a fresh end reference with a fresh template
variable (`Rel.extendVar`), so the restart (`restart`) sends the template's token
reference there and no reference of the template changes its meaning. -/

section
variable {F : Ffi} {FR FR' : Map → Nat → F.S → F.S → Prop} {M : Map} {ν ν' : Nat → F64} {K : Ctx}
  {s t : St F.S} {S S' : SSrv} {C : CSrv}

/-- The native relation can be replaced at a state. -/
theorem Rel.mapFR (h : Rel F FR M ν K s S t C) (hf : FR' M S.tab.length s.ffi t.ffi) :
    Rel F FR' M ν K s S t C :=
  { h with ffi := hf }

/-- Another server with the same table, and another valuation, under which the
numbers still correspond. -/
theorem Rel.srvSwap (h : Rel F FR M ν K s S t C) (hS : S'.tab = S.tab) (hs : Srv M ν' S' C) :
    Rel F FR M ν' K s S' t C := by
  obtain ⟨tab', o'⟩ := S'
  obtain ⟨tab, o⟩ := S
  simp only at hS
  subst hS
  exact { h with srv := hs }

/-- **Binding a fresh variable.** A target number `v` (of value `x`) becomes the
next reference of the source server, denoting a template variable `j` that no
entry or answer mentions; the valuation sends `j` to `x`. -/
theorem Rel.extendVar (hFR : FRLaws FR) (h : Rel F FR M ν K s S t C) {j : Nat} {v : NumV} {x : F64}
    (htab : ∀ e ∈ S.tab, e.noVar j = true) (hor : ∀ q ∈ S.oracle, q.noVar j = true)
    (hv : C.val v = some x) :
    Rel F FR (M.setNum S.tab.length v) (upd ν j x) K s ⟨S.tab ++ [.var j], S.oracle⟩ t C := by
  have hs0 : Srv M (upd ν j x) S C := by
    refine ⟨fun i e he => ?_, good_upd h.srv.good hor⟩
    rw [h.srv.num i e he, SymE.eval_upd ν j x e (htab e (nth?_mem_some he))]
  have h1 := h.srvSwap rfl hs0
  refine h1.extend (Map.setNum_ext M S.tab.length v) ⟨fun i e he => ?_, ?_⟩ (by simp)
    hFR.stable hFR.mono
  · by_cases hi : i < S.tab.length
    · have e1 : nth? (S.tab ++ [SymE.var j]) i = nth? S.tab i := nth?_append_lt _ _ i hi
      simp only at he
      rw [e1] at he
      have : (M.setNum S.tab.length v).num i = M.num i := (Map.setNum_ext M S.tab.length v).num i hi
      rw [this]
      exact hs0.num i e he
    · have hlt := nth?_lt _ i e he
      simp only [List.length_append, List.length_singleton] at hlt
      have hi' : i = S.tab.length := by omega
      subst hi'
      simp only at he
      rw [nth?_length_append] at he
      cases he
      rw [Map.setNum_self, hv]
      simp [SymE.eval, upd_self]
  · exact good_upd h.srv.good hor
end

/-! ## Running one iteration -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ok : St F.S → SSrv → Bool}
  {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}

/-- A checked template run from a related start reaches a related end, by the
same number of target steps. -/
theorem iter_run (hsim : Disp.StepSimXV F FR ok Kp VBOk) {M : Map} {ν : Nat → F64} {K : Ctx}
    {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv} {n : Nat} (hK : Kp K) (hν : VBOk ν)
    (h : Rel F FR M ν K s0 S0 t C) (hok : ok s0 S0 = true) (hrun : runOk F ok n s0 S0 = some (s1, S1))
    (hctl : ∀ v, s1.ctl ≠ .ret v) :
    ∃ M1 t1 C1, runC F n t C = some (t1, C1) ∧ Ext M M1 S0.tab.length ∧ Rel F FR M1 ν K s1 S1 t1 C1 := by
  obtain ⟨M1, t1, C1, hr, he, hx⟩ :=
    Disp.runOk_simXV F FR ok Kp VBOk hsim ν K hK hν n M s0 S0 t C s1 S1 (Or.inl h) hok hrun
  exact ⟨M1, t1, C1, hr, he, hx.rel hctl⟩
end

end Host.Ts.Sim

namespace Host.Ts.Sim
open Host.Ts

/-! ## One iteration up to the restart

`iter_restart` runs a template iteration on a related target, binds the target's
next number `v` (chosen from the reached target state by `next`) to the fresh end
reference with template variable `j`, and restarts: the reached target is related
to the template start under `(M₁.setNum ℓ v).after σ` at the substituted valuation,
for the restart's native relation `FRr`. -/

section
variable {F : Ffi} {FR FRr : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}

/-- The shift does not read the start server's oracle. -/
theorem Shift.withOracle {σ : Map} {θ : Nat → SymE} {K : Ctx} {s0 s1 : St F.S} {S0 S1 : SSrv}
    (h : Shift F FS σ θ K s0 S0 s1 S1) (o : List Ans) : Shift F FS σ θ K s0 ⟨S0.tab, o⟩ s1 S1 :=
  { h with }

theorem iter_restart (hsim : Disp.StepSimXV F FR ok Kp VBOk) (hFR : FRLaws FR)
    {M : Map} {ν : Nat → F64} {K : Ctx} {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv} {n : Nat}
    (hK : Kp K) (hν : VBOk ν) (h : Rel F FR M ν K s0 S0 t C) (hok : ok s0 S0 = true)
    (hrun : runOk F ok n s0 S0 = some (s1, S1)) (hctl : ∀ v, s1.ctl ≠ .ret v)
    {j : Nat} (htab : ∀ e ∈ S1.tab, e.noVar j = true) (hor : ∀ q ∈ S1.oracle, q.noVar j = true)
    {σ : Map} {θ : Nat → SymE}
    (hshift : Shift F FS σ θ K s0 S0 s1 ⟨S1.tab ++ [.var j], S1.oracle⟩)
    (hFS : ∀ M' x y z, FS σ x y → FRr M' (S1.tab.length + 1) y z → FRr (M'.after σ) S0.tab.length x z)
    (Q : Map → NumV → F64 → St F.S → CSrv → Prop)
    (next : ∀ M1 t1 C1, runC F n t C = some (t1, C1) → Ext M M1 S0.tab.length → Rel F FR M1 ν K s1 S1 t1 C1 →
      ∃ v x, C1.val v = some x ∧ t1.next - s0.next < Sim.bound ∧
        FRr (M1.setNum S1.tab.length v) (S1.tab.length + 1) s1.ffi t1.ffi ∧ Q M1 v x t1 C1) :
    ∃ M1 t1 C1 v x, runC F n t C = some (t1, C1) ∧ Ext M M1 S0.tab.length ∧ Q M1 v x t1 C1 ∧
      Rel F FRr ((M1.setNum S1.tab.length v).after σ) (Shift.valuation θ (upd ν j x))
        ⟨Shift.framedNext (M1.setNum S1.tab.length v) K s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 := by
  obtain ⟨M1, t1, C1, hr, he, h1⟩ := iter_run hsim hK hν h hok hrun hctl
  obtain ⟨v, x, hv, hroom, hf, hq⟩ := next M1 t1 C1 hr he h1
  have h2 := (h1.extendVar hFR htab hor hv).mapFR (FR' := FRr) (by simpa using hf)
  have h3 := restart (F := F) (FR := FRr) (FS := FS) _ σ _ θ K s0 s1 t1 ⟨S0.tab, []⟩ _ C1
    (fun x y z hxy hyz => by simpa using hFS _ x y z hxy (by simpa using hyz)) h2
    (hshift.withOracle []) (fun _ hq => by cases hq) hroom
  exact ⟨M1, t1, C1, v, x, hr, he, hq, h3⟩
end

end Host.Ts.Sim

namespace Host.Ts.Sim
open Host.Ts

/-! ## Framed arrays across a restart -/

section
variable {F : Ffi} {M : Map} {K : Ctx} {s1 : St F.S}

theorem framedNext_none_iff (a : Nat) : Shift.framedNext M K s1 a = none ↔ K.fr a = none := by
  unfold Shift.framedNext
  cases hk : K.fr a with
  | none => simp
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    simp only [reduceCtorEq, iff_false]
    split
    · split <;> simp
    · simp

/-- An array the iteration extended by `xs` gets `xs`'s images appended to its target prefix. -/
theorem framedNext_of {a : Nat} {pre pre' xs : List Val} {o : Obj} (hk : K.fr a = some (pre, pre'))
    (hg : s1.heap.get a = some (.obj o)) (hkind : o.kind = .array (pre ++ xs)) :
    Shift.framedNext M K s1 a = some (pre, pre' ++ M.vals xs) := by
  simp [Shift.framedNext, hk, hg, hkind]

/-- The dispatcher's context predicate survives the restart. -/
theorem Kp_restart {P : Disp.JSP F} (hK : Disp.Kp P K) (b b' : List Event) (D : Nat) :
    Disp.Kp P ⟨Shift.framedNext M K s1, b, b', D, K.lo, K.hi⟩ := by
  obtain ⟨hlo, hhi, hfr⟩ := hK
  refine ⟨hlo, hhi, fun a => ?_⟩
  show Shift.framedNext M K s1 a ≠ none ↔ a ∈ P.framed
  rw [← hfr a, Ne, Ne, framedNext_none_iff]
end

end Host.Ts.Sim

namespace Host.Ts.Sim
open Host.Ts

/-! ## Reading a framed array off a related target -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A framed source array holding its prefix and then `xs` is, in the target, the
target prefix followed by the images of `xs`. -/
theorem Rel.framed_target (h : Rel F FR M ν K s S t C) {a : Nat} {pre pre' xs : List Val} {o : Obj}
    (hk : K.fr a = some (pre, pre')) (hg : s.heap.get a = some (.obj o)) (hkind : o.kind = .array (pre ++ xs)) :
    ∃ o', t.heap.get (M.a a) = some (.obj o') ∧ o'.kind = .array (pre' ++ M.vals xs) := by
  have hs := (SlotW.of_w_none rfl).1 (h.heap a _ hg)
  unfold SlotOK at hs
  rw [hk] at hs
  obtain ⟨o1, o', e1, e2, ys, hk1, ho'⟩ := hs
  cases e1
  rw [hkind] at hk1
  simp only [Kind.array.injEq, List.append_cancel_left_eq] at hk1
  subst hk1
  exact ⟨o', e2, by rw [ho']⟩
end

end Host.Ts.Sim

namespace Host.Ts.Sim
open Host.Ts

/-- The JavaScript part of the relation ignores the source's native state. -/
theorem Rel.setSrcFfi {F : Ffi} {FR FR' : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv} (h : Rel F FR M ν K s S t C) (x : F.S)
    (hf : FR' M S.tab.length x t.ffi) : Rel F FR' M ν K (s.setFfi x) S t C :=
  { h with ffi := hf }

end Host.Ts.Sim
