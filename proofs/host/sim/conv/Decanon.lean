import host.sim.conv.CallPieces
import host.sim.conv.Call
import host.sim.world.Book
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-! # De-canonicalizing a cut's table

A compaction leaves canonical result variables in the table (`cws`); where they equal terms of the
other variables at every pair of a cut (a result's derived value, `post_call_val`'s `MapOk`), the table
with each replaced by its term (`compactθ vs es`, its substitution) is related by the same pairs: the
numbers' values are unchanged (`valuation_decanon`), the relation reads the table only through them and
its length (`RelB.decanon`). As a cut conversion, `cut_decanon`: zero steps, the pair unchanged. -/

private theorem nth_of_idx? {v : Nat} : ∀ {l : List Nat} {k : Nat}, idx? v l = some k → nth? l k = some v
  | [], _, h => by cases h
  | w :: l, k, h => by
    simp only [idx?] at h
    cases hb : Nat.beq w v
    · rw [hb] at h
      simp only [Bool.cond_false] at h
      cases e : idx? v l with
      | none => rw [e] at h; cases h
      | some k' =>
        rw [e] at h; cases h
        show nth? l k' = some v
        exact nth_of_idx? e
    · rw [hb] at h; cases h
      show some w = some v
      rw [Nat.eq_of_beq_eq_true hb]

/-- The substitution by the canonical variables' terms keeps a valuation giving each its term's value. -/
theorem valuation_decanon {vs : List Nat} {es : List SymE} {ν : Nat → F64}
    (hdef : ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν) :
    ∀ v, (compactθ vs es v).eval ν = ν v := by
  intro v
  unfold compactθ
  cases hj : idx? v vs with
  | none => rfl
  | some j =>
    show SymE.eval ν ((nth? es j).getD (SymE.var v)) = ν v
    cases he : nth? es j with
    | none => rfl
    | some e => exact (hdef j v e (nth_of_idx? hj) he).symm

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}

/-- The relation at another server of the same table length whose numbers the target serves. -/
theorem _root_.Host.Ts.Sim.RelB.withTab {M : Map} {ν ν' : Nat → F64} {K : Ctx} {s t : St F.S} {S S' : SSrv}
    {C : CSrv} (h : RelB F FR W stk M ν K s S t C) (hl : S'.tab.length = S.tab.length) (hs : Srv M ν' S' C) :
    RelB F FR W stk M ν' K s S' t C :=
  { h with
    srv := hs
    ffi := hl ▸ h.ffi
    heapSupp := hl ▸ h.heapSupp
    ctlSupp := hl ▸ h.ctlSupp
    stackSupp := hl ▸ h.stackSupp
    jobsSupp := hl ▸ h.jobsSupp
    storesSupp := hl ▸ h.storesSupp
    traceSupp := hl ▸ h.traceSupp }

/-- **The relation at the de-canonicalized table**: each canonical variable of `vs` replaced by its
term in `es`, the valuation giving each its term's value. -/
theorem _root_.Host.Ts.Sim.RelB.decanon {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv}
    {C : CSrv} (h : RelB F FR W stk M ν K s S t C) {vs : List Nat} {es : List SymE}
    (hdef : ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν) :
    RelB F FR W stk M ν K s ⟨S.tab.map (·.subst (compactθ vs es)), S.oracle⟩ t C := by
  refine h.withTab (by simp) ⟨fun i e he => ?_, h.srv.good⟩
  have hv : (fun i => (compactθ vs es i).eval ν) = ν := funext (valuation_decanon hdef)
  rw [nth?_map] at he
  cases hi : nth? S.tab i with
  | none => rw [hi] at he; cases he
  | some e0 =>
    rw [hi] at he
    obtain rfl : e0.subst (compactθ vs es) = e := Option.some.inj he
    rw [h.srv.num i e0 hi, SymE.eval_subst, hv]

/-- **De-canonicalizing a cut** (a zero-step conversion, the pairs unchanged): at every pair of the cut
(its predicate `Q`, its bookkeeping `B`) each canonical variable of `vs` has its term's value in `es`. -/
theorem cut_decanon {Q B : SegInst F → Prop} {s : St F.S} {T : List SymE} {vs : List Nat} {es : List SymE}
    (hdef : ∀ x, Q x → B x → ∀ j v e, nth? vs j = some v → nth? es j = some e → x.ν v = e.eval x.ν) :
    CutConv ((Cut.mk s T (relB F FR W stk Q)).with B)
      ((Cut.mk s (T.map (·.subst (compactθ vs es))) (relB F FR W stk Q)).with B) := by
  rintro x ⟨hr, hq⟩ hb
  exact ⟨x, rfl, rfl, ⟨hr.decanon (hdef x hq hb), hq⟩, hb⟩

end


/-- The decode chains' canonical results `vs` (each at the quantity `q`) as the successor of the
variable `u` (at `qu`, with `q = qu + 1`): the generator's `cderived` form `u + 1`, from the cut's
quantities (`MapOk`). -/
theorem decanon_succ {ν : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst} {m : List (Nat × Host.Ts.Sim.Lin.Cls.Q)} {vs : List Nat}
    {q qu : Host.Ts.Sim.Lin.Cls.Q}
    {u : Nat} (hm : Host.Ts.Sim.Lin.Cls.MapOk ν i m) (hvs : ∀ v ∈ vs, (v, q) ∈ m) (hu : (u, qu) ∈ m) (hq : i.get q = i.get qu + 1)
    (hb : i.get qu + 1 < 2 ^ 53) :
    ∀ j v e, nth? vs j = some v → nth? (vs.map fun _ => SymE.bin .add (.var u) litOne) j = some e →
      ν v = e.eval ν := by
  intro j v e hv he
  rw [nth?_map, hv] at he
  obtain rfl := Option.some.inj he
  show ν v = (SymE.bin .add (.var u) litOne).eval ν
  rw [(mapOk_iff'.mp hm) _ (hvs v (nth?_mem_some hv)), hq,
    eval_succ_lit ((mapOk_iff'.mp hm) _ hu) hb]


/-- The decode chains' canonical results `vs` at their forms `es` (`decQ`: `u + 1`, `int32(u)`,
`int32(u + 1)`), each in the cut's map at its form's quantity, `u` at the offset. -/
theorem decanon_dec {ν : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst} {m : List (Nat × Host.Ts.Sim.Lin.Cls.Q)}
    {vs : List Nat} {es : List SymE} {u : Nat} (hm : Host.Ts.Sim.Lin.Cls.MapOk ν i m) (hu : (u, .o) ∈ m)
    (hn : i.get .e = i.get .o + 1) (hb : i.get .o + 1 < 2 ^ 31)
    (hvs : ∀ j v e, nth? vs j = some v → nth? es j = some e → ∃ q, decQ u e = some q ∧ (v, q) ∈ m) :
    ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν := by
  intro j v e hv he
  obtain ⟨q, hq, hvq⟩ := hvs j v e hv he
  rw [(mapOk_iff'.mp hm) _ hvq, decQ_eval hq ((mapOk_iff'.mp hm) _ hu) hn hb]

end Host.Ts.Sim.Conv
