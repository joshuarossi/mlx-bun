import host.sim.compose.ResVal
import host.sim.conv.CallPieces
import host.sim.compose.ChainFill
import host.sim.full.Rel
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Conv Host.Ts.Sim.Full

/-- The checked values of a call's results at a row, by `resChk`. -/
def resChkAll (r : Row) (m : List (Nat × Q)) (Es : List (Option SymE)) (qs : List (Option Q)) : Bool :=
  (Es.zip qs).all fun p => match p.1 with
    | some E => resChk r m E p.2
    | none => false

theorem nth?_zip_some {α β : Type} : ∀ {l : List α} {r : List β} {j : Nat} {a : α} {b : β},
    nth? l j = some a → nth? r j = some b → (a, b) ∈ l.zip r
  | a0 :: l, b0 :: r, 0, a, b, h1, h2 => by
    cases h1; cases h2; simp
  | a0 :: l, b0 :: r, j + 1, a, b, h1, h2 => by
    simp only [List.zip_cons_cons, List.mem_cons]
    exact .inr (nth?_zip_some h1 h2)
  | [], _, j, _, _, h1, _ => by cases j <;> cases h1
  | _ :: _, [], j, _, _, _, h2 => by cases j <;> cases h2

theorem resChkAll_sound {r : Row} {m : List (Nat × Q)} {Es : List (Option SymE)} {qs : List (Option Q)}
    (h : resChkAll r m Es qs = true) {i : Cls.Inst} (hi : InRow r i) {ν : Nat → F64} (hν : MapOk ν i m)
    {j : Nat} {o : Option SymE} {oq : Option Q} (ho : nth? Es j = some o) (hq : nth? qs j = some oq) :
    ∃ E, o = some E ∧ (∃ k ≤ 2 ^ 20, E.eval ν = F64.ofNat k) ∧
      ∀ q, oq = some q → E.eval ν = F64.ofNat (i.get q) := by
  have hc := List.all_eq_true.mp h (o, oq) (nth?_zip_some ho hq)
  cases o with
  | none => cases hc
  | some E => exact ⟨E, rfl, resChk_sound hc hi hν⟩

/-- The valuation after a compacting call: results at their checked values, everything else kept. -/
theorem post_callV {ν : Nat → F64} {i : Cls.Inst} {m m' : List (Nat × Q)}
    {qs : List (Option Q)} {tab S2 Sm : List SymE} {ws cws nr : List Nat} {n0 : Nat}
    {Es : List (Option SymE)}
    (hVB : VBOkF loopVB ν)
    (hSm : Sm = tab ++ resTab ws) (hn0 : tab.length = n0)
    (hws : ws.length = S2.length - n0) (hnd : ws.Nodup)
    (hndc : cws.Nodup) (hlen : cws.length = nr.length) (hlq : qs.length = cws.length)
    (hnrLo : nr.all (Nat.ble n0) = true) (hnrHi : ∀ r ∈ nr, r < Sm.length)
    (hder : nr.map (fun r => nth? S2 r) = Es)
    (hEs : ∀ j o oq, nth? Es j = some o → nth? qs j = some oq →
      ∃ E, o = some E ∧ (∃ k ≤ 2 ^ 20, E.eval ν = F64.ofNat k) ∧
        ∀ q, oq = some q → E.eval ν = F64.ofNat (i.get q))
    (hm : MapOk ν i m)
    (hm0 : ∀ p ∈ m, idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hsub : ∀ p ∈ m', p ∈ m ∨ ∃ j, nth? cws j = some p.1 ∧ nth? qs j = some (some p.2)) :
    let θ := compactθZ cws (nr.map fun r => (nth? Sm r).getD (.var 0)) ws
    let ν' := resVal ν ws (resF SymE.var S2 n0 ν)
    VBOkF loopVB (Shift.valuation θ ν') ∧ MapOk (Shift.valuation θ ν') i m' := by
  intro θ ν'
  have hres : ∀ j rr, nth? nr j = some rr → ∀ oq, nth? qs j = some oq →
      ∃ E, nth? S2 rr = some E ∧ ((nth? Sm rr).getD (.var 0)).eval ν' = E.eval ν ∧
        (∃ k ≤ 2 ^ 20, E.eval ν = F64.ofNat k) ∧ ∀ q, oq = some q → E.eval ν = F64.ofNat (i.get q) := by
    intro j rr hrr oq hq
    have hE : nth? Es j = some (nth? S2 rr) := by rw [← hder, nth?_map, hrr]; rfl
    obtain ⟨E, hoE, hk, hqq⟩ := hEs j _ oq hE hq
    refine ⟨E, hoE, ?_, hk, hqq⟩
    have hlo := Nat.le_of_ble_eq_true (List.all_eq_true.mp hnrLo rr (nth?_mem_some hrr))
    have hhi := hnrHi rr (nth?_mem_some hrr)
    have hSl : Sm.length = tab.length + ws.length := by rw [hSm]; simp [resTab]
    subst hSm
    rw [crs_eval hn0 hnd hlo (by omega), hoE, Option.getD_some]
  have hout : ∀ v, ws.contains v = false → ν' v = ν v := fun v hv =>
    resVal_off (fun hm => by
      have hc := List.contains_iff_mem.mpr hm
      rw [hv] at hc
      cases hc)
  have hrs : ∀ j c r, nth? cws j = some c → nth? (nr.map fun r => (nth? Sm r).getD (.var 0)) j = some r →
      ∃ rr oq, nth? nr j = some rr ∧ nth? qs j = some oq ∧ r = (nth? Sm rr).getD (.var 0) := by
    intro j c r hc hr
    rw [nth?_map] at hr
    cases hrr : nth? nr j with
    | none => rw [hrr] at hr; cases hr
    | some rr =>
      rw [hrr] at hr
      cases hr
      have hj := nth?_lt _ _ _ hc
      obtain ⟨oq, hoq⟩ := nth?_some_of_lt (show j < qs.length by omega)
      exact ⟨rr, oq, rfl, hoq, rfl⟩
  constructor
  · refine vbOk_post (fun v hv => ?_) (fun j c r hc hr => ?_) (by rw [List.length_map]; omega)
    · rw [hout v hv]; exact hVB v
    · obtain ⟨rr, oq, hrr, hoq, rfl⟩ := hrs j c r hc hr
      obtain ⟨E, _, he, ⟨k, hkle, hk⟩, _⟩ := hres j rr hrr oq hoq
      exact ⟨k, hkle, by rw [he]; exact hk⟩
  · refine mapOk_iff'.2 fun p hp => ?_
    rcases hsub p hp with hpm | ⟨j, hj, hqj⟩
    · rw [valuation_compactθZ_out (hm0 p hpm).1 (hm0 p hpm).2, hout p.1 (hm0 p hpm).2]
      exact (mapOk_iff'.1 hm) p hpm
    · have hjl := nth?_lt _ _ _ hj
      obtain ⟨rr, hrr⟩ := nth?_some_of_lt (show j < nr.length by omega)
      have hr : nth? (nr.map fun r => (nth? Sm r).getD (.var 0)) j = some ((nth? Sm rr).getD (.var 0)) := by
        rw [nth?_map, hrr]; rfl
      rw [valuation_compactθZ_res (idx?_nth hndc hj) hr]
      obtain ⟨E, _, he, _, hq⟩ := hres j rr hrr _ hqj
      rw [he]
      exact hq p.2 rfl

end Host.Ts.Sim.Compose
