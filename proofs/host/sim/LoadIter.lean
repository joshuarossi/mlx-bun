import host.sim.Iter
import host.sim.Loop
import host.sim.BigFree
import host.sim.native.Shift
import host.sim.native.RebigR
namespace Host.Ts.Sim
open Host.Ts

/-! # One template iteration of the load world

`load_step` instantiates `iter_restart` with the native relation `LoadR`:
the target's remaining readbacks `v :: r` (`LoadP.rest`) supply the next token
`v`, the restart uses the weak native relation (`FRr`, tokens cleared) and the
native shift (`FSn`), and the fresh handle images are reassigned
(`Rel.rebig`, `LoadRw.rebig`). The target's counters advance by the
template's (`lockstep`), so the next iteration's room is arithmetic. -/

abbrev LF : Ffi := Host.Load.ffi

/-- The native relation with the target's remaining readbacks `r`. -/
abbrev LR (P : LoadP) (r : List NumV) : Map → Nat → Host.Load.LSt → Host.Load.LSt → Prop :=
  LoadR { P with rest := r }

/-- The restart's native shift, from the template start `x0`. -/
def FSn (P : LoadP) (n0 : Nat) (x0 : Host.Load.LSt) : Map → Host.Load.LSt → Host.Load.LSt → Prop :=
  fun σ x y => x = x0 ∧ NShift P n0 σ x y

/-- The restart's native relation: the weak relation with tokens cleared, and room for
one more iteration from `x0`. -/
def FRr (P : LoadP) (x0 : Host.Load.LSt) : Map → Nat → Host.Load.LSt → Host.Load.LSt → Prop :=
  fun M n x z => LoadRw P M n (clearTokens x) z ∧ NRoom P x0 z

/-- The native shift does not read the target's remaining readbacks. -/
theorem NShift.withRest {P : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : Host.Load.LSt} (h : NShift P n0 σ x0 x1)
    (r : List NumV) : NShift { P with rest := r } n0 σ x0 x1 :=
  { h with mlx := { h.mlx with } }

theorem clearTokens_nil {x : Host.Load.LSt} (h : x.mlx.tokens = []) : clearTokens x = x := by
  obtain ⟨m, hst⟩ := x
  obtain ⟨nx, nodes, nn, arrs, objs, toks, files, pend, errh, arch, ds, wired, items⟩ := m
  simp only at h
  subst h
  rfl

theorem fsn_compose {P : LoadP} {n0 n1 : Nat} {x0 : Host.Load.LSt} {σ : Map} :
    ∀ M x y z, FSn P n0 x0 σ x y → FRr P x0 M n1 y z → FRr P x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨rfl, hs⟩ ⟨hr, hroom⟩
  rw [clearTokens_nil hs.mlx.tokens] at hr
  exact ⟨loadRw_restart hs hr hroom, hroom⟩

/-- The symbolic table only grows along a checked run. -/
theorem interpS_runOk_len {F : Ffi} {ok : St F.S → SSrv → Bool} :
    ∀ {n : Nat} {s s' : St F.S} {S S' : SSrv}, runOk F ok n s S = some (s', S') → S.tab.length ≤ S'.tab.length
  | 0, s, s', S, S', h => by
    rw [runOk_zero] at h
    cases h
    exact Nat.le_refl _
  | n + 1, s, s', S, S', h => by
    rw [runOk_succ] at h
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs] at h
        cases hk : ok s1 S1
        · simp [hk] at h
        · simp only [hk, Bool.cond_true, St.rebuild_eq] at h
          exact Nat.le_trans (interpS_len _ _ _ _ hs) (interpS_runOk_len h)
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact Nat.le_refl _

/-- Concrete servers only grow along a run. -/
theorem runC_le {F : Ffi} : ∀ (n : Nat) (t : St F.S) (C : CSrv) (t' : St F.S) (C' : CSrv),
    runC F n t C = some (t', C') → CSrv.Le C C'
  | 0, t, C, t', C', h => by
    simp only [runC, runWith] at h
    cases h
    exact CSrv.Le.refl _
  | n + 1, t, C, t', C', h => by
    simp only [runC, runWith_succ] at h
    cases hh : isHalt t.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpC (step F t).run C with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨t1, C1⟩ := p
        simp only [hs, St.rebuild_eq] at h
        exact (interpC_le _ _ _ _ hs).trans (runC_le n t1 C1 t' C' h)
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact CSrv.Le.refl _

/-- Native handle and node counters advance in lockstep within an iteration. -/
theorem lockstep {P P' : LoadP} {M M1 : Map} {n n1 : Nat} {x0 x1 y0 y1 : Host.Load.LSt}
    (h0 : LoadR P M n x0 y0) (h1 : LoadR P' M1 n1 x1 y1) (he : Ext M M1 n) (hE : P'.E = P.E)
    (hle : x0.mlx.next ≤ x1.mlx.next) (hlt : x1.mlx.next < P.E) (hnle : x0.mlx.nnext ≤ x1.mlx.nnext) :
    y1.mlx.next = y0.mlx.next + (x1.mlx.next - x0.mlx.next) ∧
      y1.mlx.nnext = y0.mlx.nnext + (x1.mlx.nnext - x0.mlx.nnext) := by
  constructor
  · have e1 := h1.mlx.hfreshB 0 (by rw [hE]; omega)
    have e0 := h0.mlx.hfreshB (x1.mlx.next - x0.mlx.next) (by omega)
    rw [he.big] at e1
    simp only [Nat.add_zero] at e1
    rw [show x0.mlx.next + (x1.mlx.next - x0.mlx.next) = x1.mlx.next by omega, e1] at e0
    exact Int.ofNat.inj e0
  · have e1 := h1.mlx.nfresh 0
    have e0 := h0.mlx.nfresh (x1.mlx.nnext - x0.mlx.nnext)
    rw [he.node] at e1
    simp only [Nat.add_zero] at e1
    rw [show x0.mlx.nnext + (x1.mlx.nnext - x0.mlx.nnext) = x1.mlx.nnext by omega, e1] at e0
    exact e0

/-- **One iteration.** From the template start related to the target (the target's next
readbacks after the current token are `v :: r`), the checked template run reaches its end,
and the reached target is related to the template start again: under the restart map with
the fresh handles reassigned, at the substituted valuation with `v`'s value bound to `v17`,
for the remaining readbacks `r`. The target's counters advance by the template's; the
relation at the template's end (before the restart) is returned too. -/
theorem load_step {P : LoadP} {ok : St LF.S → SSrv → Bool} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}
    {r0 : List NumV} (hsim : Disp.StepSimXV LF (LR P r0) ok Kp VBOk)
    {M : Map} {ν : Nat → F64} {K : Ctx} {s0 s1 t : St LF.S} {S0 S1 : SSrv} {C : CSrv} {n : Nat}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hK : Kp K) (hν : VBOk ν) (h : Rel LF (LR P r0) M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hok : ok s0 S0 = true) (hrun : runOk LF ok n s0 S0 = some (s1, S1)) (hctl : ∀ v, s1.ctl ≠ .ret v)
    (htab : ∀ e ∈ S1.tab, e.noVar 17 = true) (hor : ∀ q ∈ S1.oracle, q.noVar 17 = true)
    (hshift : Shift LF (FSn { P with rest := r0 } S0.tab.length s0.ffi) σ θ K s0 S0 s1
      ⟨S1.tab ++ [.var 17], S1.oracle⟩)
    (hσ : σ.num 79 = .ref S1.tab.length) (htok : s0.ffi.mlx.tokens = [.ref 79]) (h79 : 79 < S0.tab.length)
    (hbig : bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true)
    (hfree : NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x)
    (hE : s1.ffi.mlx.next < P.E)
    (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hroomN : t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62) :
    ∃ M1 t1 C1, runC LF n t C = some (t1, C1) ∧ Ext M M1 S0.tab.length ∧
      t1.next = t.next + (s1.next - s0.next) ∧
      t1.ffi.mlx.next = t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) ∧
      t1.ffi.mlx.nnext = t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) ∧
      Rel LF (LR P r)
        ((((M1.setNum S1.tab.length v).after σ)).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next)
        (Shift.valuation θ (upd ν 17 x))
        ⟨Shift.framedNext (M1.setNum S1.tab.length v) K s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 ∧
      Rel LF (LR P (v :: r)) M1 ν K s1 S1 t1 C1 := by
  subst hr0
  have hns : NShift { P with rest := v :: r } S0.tab.length σ s0.ffi s1.ffi := hshift.ffi.2
  -- the run and the restart
  obtain ⟨M1, t1, C1, v', x', hrc, he, ⟨hv', hoff, hH, hN, hvv, hxx, htk, hpre⟩, hrel⟩ :=
    iter_restart (FRr := FRr { P with rest := v :: r } s0.ffi) hsim (loadR_laws _) hK hν h hok hrun hctl
      htab hor hshift (fun M' x y z hxy hyz => fsn_compose M' x y z hxy hyz)
      (fun M1 v' x' t1 C1 => C1.val v' = some x' ∧ t1.next = t.next + (s1.next - s0.next) ∧
        t1.ffi.mlx.next = t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) ∧
        t1.ffi.mlx.nnext = t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) ∧
        v' = v ∧ x' = x ∧ t1.ffi.mlx.tokens = v :: r ∧ Rel LF (LR P (v :: r)) M1 ν K s1 S1 t1 C1)
      (fun M1 t1 C1 hrc hext h1 => by
        have hl := lockstep h.ffi h1.ffi hext rfl hns.mlx.hnext.2 hE hns.mlx.nle
        have hoff : t1.next = t.next + (s1.next - s0.next) := by
          have := h1.offset; have := h.offset; have := hshift.grows; omega
        have htk : t1.ffi.mlx.tokens = v :: r := by
          have := h1.ffi.mlx.tokensX
          rw [hns.mlx.tokens] at this
          simpa using this
        have hvx : C1.val v = some x := (runC_le n t C t1 C1 hrc).val hx
        have hw : LoadRw { P with rest := v :: r } (M1.setNum S1.tab.length v) (S1.tab.length + 1)
            (clearTokens s1.ffi) t1.ffi := by
          rw [clearTokens_nil hns.mlx.tokens]
          exact (((loadR_laws _).stable _ _ _ _ _ h1.ffi (Map.setNum_ext M1 S1.tab.length v)).mono
            (Nat.le_succ _)).weak
        refine ⟨v, x, hvx, ?_, ⟨hw, ?_, ?_⟩, hvx, hoff, hl.1, hl.2, rfl, rfl, htk, h1⟩
        · rw [hoff]; have := h.offset; have := hshift.grows; omega
        · show t1.ffi.mlx.next + (P.E - s0.ffi.mlx.next) < 2 ^ 46
          rw [hl.1]; omega
        · show t1.ffi.mlx.nnext + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62
          rw [hl.2]; omega)
  rw [hvv, hxx] at hrel
  refine ⟨M1, t1, C1, hrc, he, hoff, hH, hN, ?_, hpre⟩
  -- reassign the fresh handle images
  have hw0 := hrel.ffi.1
  have hz : t1.ffi.mlx.tokens = s0.ffi.mlx.tokens.map ((M1.setNum S1.tab.length v).after σ).nv ++ r := by
    rw [htk, htok]
    simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, Map.nv]
    show v :: r = (M1.setNum S1.tab.length v).nv (σ.num 79) :: r
    rw [hσ]
    simp [Map.nv, Map.setNum_self]
  have hffi := LoadRw.rebig hw0 hbig (fun t ht => by rw [htok] at ht; simp at ht; subst ht; exact h79) hz
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

end Host.Ts.Sim
