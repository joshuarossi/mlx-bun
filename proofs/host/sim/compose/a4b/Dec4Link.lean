import host.sim.compose.CallGrow
import host.sim.compose.ShortFix
import host.sim.template.DecOk
import host.sim.template.EndGenG
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false

/-! # The decode chains over a template with abstracted dims and ghosts

`host.sim.compose.ChainFill`, `CallLink` and `CallGrow` at `DecOk.decJ` and the valuations `DecOk.VP`, over the frames `framesG`, `wideG`.
A call's results include dims of the convolution caches, a form of an abstracted dim whose value is a constant no quantity holds, so a
result here is a quantity or a constant (`RV`), and a cut carries the constants next to the quantities (`CMapOk`). -/

namespace Host.Ts.Sim.Compose.Dec4
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers
open Host.Ts.Sim.Template Host.Ts.Sim.Compose
open Host.Load.Run.Tpl (wideG wideList wideListOf ghostAddrs causalKey decVal)
open Host.Load.Run.Tpl.DecOk (VP pin eval_pin)

/-! ## A call's results -/

/-- A result's value at a step: a quantity, or a constant. -/
abbrev RV := Q ⊕ Nat

def rval (i : Cls.Inst) : RV → Nat
  | .inl q => i.get q
  | .inr k => k

/-- The results held at quantities. -/
def qzip : List Nat → List RV → List (Nat × Q)
  | c :: cs, .inl q :: rs => (c, q) :: qzip cs rs
  | _ :: cs, .inr _ :: rs => qzip cs rs
  | _, _ => []

/-- The results held at constants. -/
def kzip : List Nat → List RV → List (Nat × Nat)
  | c :: cs, .inr k :: rs => (c, k) :: kzip cs rs
  | _ :: cs, .inl _ :: rs => kzip cs rs
  | _, _ => []

theorem nth?_of_qzip {c : Nat} {q : Q} : ∀ {cs : List Nat} {rs : List RV}, (c, q) ∈ qzip cs rs →
    ∃ j, nth? cs j = some c ∧ nth? rs j = some (.inl q)
  | [], _, h => by cases h
  | _ :: _, [], h => by cases h
  | c' :: cs, .inl q' :: rs, h => by
    rcases List.mem_cons.mp h with e | h
    · cases e; exact ⟨0, rfl, rfl⟩
    · obtain ⟨j, h1, h2⟩ := nth?_of_qzip h
      exact ⟨j + 1, h1, h2⟩
  | _ :: cs, .inr _ :: rs, h => by
    obtain ⟨j, h1, h2⟩ := nth?_of_qzip (cs := cs) (rs := rs) h
    exact ⟨j + 1, h1, h2⟩

theorem nth?_of_kzip {c k : Nat} : ∀ {cs : List Nat} {rs : List RV}, (c, k) ∈ kzip cs rs →
    ∃ j, nth? cs j = some c ∧ nth? rs j = some (.inr k)
  | [], _, h => by cases h
  | _ :: _, [], h => by cases h
  | c' :: cs, .inr k' :: rs, h => by
    rcases List.mem_cons.mp h with e | h
    · cases e; exact ⟨0, rfl, rfl⟩
    · obtain ⟨j, h1, h2⟩ := nth?_of_kzip h
      exact ⟨j + 1, h1, h2⟩
  | _ :: cs, .inl _ :: rs, h => by
    obtain ⟨j, h1, h2⟩ := nth?_of_kzip (cs := cs) (rs := rs) h
    exact ⟨j + 1, h1, h2⟩

/-- A valuation at constants. -/
def CMapOk (ν : Nat → F64) (cm : List (Nat × Nat)) : Prop := ∀ p ∈ cm, ν p.1 = F64.ofNat p.2

/-- **The canonical valuation after a call**: `Conv.post_call_valQ` with each result a quantity or a constant. -/
theorem post_call_valC {VB : Nat → Nat} {ν : Nat → F64} {i : Cls.Inst} {m : List (Nat × Q)} {cm : List (Nat × Nat)}
    {qs : List RV} {tab S2 S5 : List SymE} {ws cws nr : List Nat} {n0 : Nat} {Es : List (Option SymE)}
    (hVB : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (hm : MapOk ν i m) (hc : CMapOk ν cm)
    (hm0 : ∀ p ∈ m, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hc0 : ∀ p ∈ cm, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hS5 : S5 = tab ++ Conv.resTab ws) (hn0 : tab.length = n0) (hws : ws.length = S2.length - n0) (hnd : ws.Nodup)
    (hndc : cws.Nodup) (hlen : cws.length = nr.length) (hlq : qs.length = cws.length)
    (hnrLo : nr.all (Nat.ble n0) = true) (hder : nr.map (fun r => nth? S2 r) = Es)
    (hEs : ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧ nth? qs j = some q ∧ E.eval ν = F64.ofNat (rval i q))
    (hq : ∀ j c q, nth? cws j = some c → nth? qs j = some q → rval i q ≤ VB c) :
    let crs := nr.map fun r => (nth? S5 r).getD (.var 0)
    let ν' := Conv.resVal ν ws (Conv.resF SymE.var S2 n0 ν)
    (∀ v, ∃ k ≤ VB v, Shift.valuation (Conv.compactθZ cws crs ws) ν' v = F64.ofNat k) ∧
      MapOk (Shift.valuation (Conv.compactθZ cws crs ws) ν') i (m ++ qzip cws qs) ∧
      CMapOk (Shift.valuation (Conv.compactθZ cws crs ws) ν') (cm ++ kzip cws qs) := by
  intro crs ν'
  have hres : ∀ j r q, nth? crs j = some r → nth? qs j = some q → r.eval ν' = F64.ofNat (rval i q) := by
    intro j r q hr hqj
    rw [nth?_map] at hr
    cases hrr : nth? nr j with
    | none => rw [hrr] at hr; cases hr
    | some rr =>
      rw [hrr] at hr
      cases hr
      have hlo := Nat.le_of_ble_eq_true (List.all_eq_true.mp hnrLo rr (nth?_mem_some hrr))
      have hE : nth? Es j = some (nth? S2 rr) := by rw [← hder, nth?_map, hrr]; rfl
      cases hS2 : nth? S2 rr with
      | none =>
        rw [hS2] at hE
        obtain ⟨E, _, hE1, -⟩ := hEs j none hE
        cases hE1
      | some E =>
        rw [hS2] at hE
        have hlt := nth?_lt _ _ _ hS2
        rw [hS5, Conv.crs_eval hn0 hnd hlo (by omega), hS2, Option.getD_some]
        obtain ⟨E', q', hE1, hq', hE2⟩ := hEs j (some E) hE
        cases hE1
        rw [hqj] at hq'
        cases hq'
        exact hE2
  have hoff : ∀ v, Conv.idx? v cws = none → ws.contains v = false →
      Shift.valuation (Conv.compactθZ cws crs ws) ν' v = ν v := by
    intro v h1 h2
    have hv' : v ∉ ws := fun h => by rw [List.contains_iff_mem.mpr h] at h2; cases h2
    rw [Conv.valuation_compactθZ_out h1 h2]
    exact Conv.resVal_off hv'
  have hat : ∀ j c q, nth? cws j = some c → nth? qs j = some q →
      Shift.valuation (Conv.compactθZ cws crs ws) ν' c = F64.ofNat (rval i q) := by
    intro j c q hjc hjq
    have hjl := nth?_lt _ _ _ hjc
    have hcl : crs.length = cws.length := by simp [crs, hlen]
    obtain ⟨r, hr⟩ := Conv.nth?_some_of_lt (show j < crs.length by omega)
    rw [Conv.valuation_compactθZ_res (Conv.idx?_nth hndc hjc) hr]
    exact hres j r q hr hjq
  refine ⟨Conv.vbOk_post (fun v hv => ?_) (fun j c r hc hr => ?_) (by simp [crs, hlen]), ?_, ?_⟩
  · have hv' : v ∉ ws := fun h => by rw [List.contains_iff_mem.mpr h] at hv; cases hv
    show ∃ k ≤ VB v, Conv.resVal ν ws _ v = _
    rw [Conv.resVal_off hv']; exact hVB v
  · obtain ⟨q, hqj⟩ := Conv.nth?_some_of_lt (show j < qs.length by rw [hlq]; exact nth?_lt _ _ _ hc)
    exact ⟨rval i q, hq j c q hc hqj, hres j r q hr hqj⟩
  · refine Conv.mapOk_iff'.2 fun p hp => ?_
    rcases List.mem_append.1 hp with hp | hp
    · rw [hoff p.1 (hm0 p hp).1 (hm0 p hp).2]
      exact (Conv.mapOk_iff'.1 hm) p hp
    · obtain ⟨c, q⟩ := p
      obtain ⟨j, hjc, hjq⟩ := nth?_of_qzip hp
      exact hat j c (.inl q) hjc hjq
  · intro p hp
    rcases List.mem_append.1 hp with hp | hp
    · rw [hoff p.1 (hc0 p hp).1 (hc0 p hp).2]
      exact hc p hp
    · obtain ⟨c, k⟩ := p
      obtain ⟨j, hjc, hjq⟩ := nth?_of_kzip hp
      exact hat j c (.inr k) hjc hjq

/-! ## The results' forms -/

def closedB : SymE → Bool
  | .lit _ => true
  | .var _ => false
  | .bin _ a b => closedB a && closedB b
  | .un _ a => closedB a

theorem eval_closed : ∀ {e : SymE}, closedB e = true → ∀ ν ν' : Nat → F64, e.eval ν = e.eval ν'
  | .lit _, _, _, _ => rfl
  | .var _, h, _, _ => by cases h
  | .bin _ a b, h, ν, ν' => by
    simp only [closedB, Bool.and_eq_true] at h
    simp only [SymE.eval, eval_closed h.1 ν ν', eval_closed h.2 ν ν']
  | .un _ a, h, ν, ν' => by
    simp only [closedB] at h
    simp only [SymE.eval, eval_closed h ν ν']

/-- A form of the abstracted dims: its value at theirs. -/
def constOf (E : SymE) : Option Nat :=
  bif closedB (E.subst pin) then
    match F64.toIndex? ((E.subst pin).eval fun _ => F64.zero false) with
    | some k => bif decide (((E.subst pin).eval fun _ => F64.zero false) = F64.ofNat k) then some k else none
    | none => none
  else none

theorem constOf_eval {E : SymE} {k : Nat} {ν : Nat → F64} (hν : VP ν) (h : constOf E = some k) :
    E.eval ν = F64.ofNat k := by
  unfold constOf at h
  cases hc : closedB (E.subst pin) with
  | false => rw [hc] at h; cases h
  | true =>
    rw [hc, Bool.cond_true] at h
    split at h
    · rename_i k' _
      cases hd : decide ((E.subst pin).eval (fun _ => F64.zero false) = F64.ofNat k') with
      | false => rw [hd] at h; cases h
      | true =>
        rw [hd, Bool.cond_true] at h
        cases h
        rw [← eval_pin hν, eval_closed hc ν (fun _ => F64.zero false)]
        exact of_decide_eq_true hd
    · cases h

/-- A result's form: a quantity by `dq`, else a form of the abstracted dims. -/
def decC (dq : SymE → Option Q) (E : SymE) : Option RV :=
  match dq E with
  | some q => some (.inl q)
  | none => (constOf E).map .inr

theorem decC_eval {dq : SymE → Option Q} {i : Cls.Inst} {ν : Nat → F64} (hν : VP ν)
    (hdq : ∀ E q, dq E = some q → E.eval ν = F64.ofNat (i.get q)) {E : SymE} {q : RV} (h : decC dq E = some q) :
    E.eval ν = F64.ofNat (rval i q) := by
  unfold decC at h
  cases hq : dq E with
  | some q' =>
    rw [hq] at h
    cases h
    exact hdq E q' hq
  | none =>
    rw [hq] at h
    cases hk : constOf E with
    | none => rw [hk] at h; cases h
    | some k =>
      rw [hk] at h
      cases h
      exact constOf_eval hν hk

/-- The results' forms from a check of their entries. -/
theorem hEs_of_form {dq : SymE → Option Q} {i : Cls.Inst} {ν : Nat → F64} {Es : List (Option SymE)} (hν : VP ν)
    (hdq : ∀ E q, dq E = some q → E.eval ν = F64.ofNat (i.get q))
    (hall : Es.all (fun o => (o.bind (decC dq)).isSome) = true) :
    ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧
      nth? (Es.map fun o => (o.bind (decC dq)).getD (.inl .o)) j = some q ∧ E.eval ν = F64.ofNat (rval i q) := by
  intro j o ho
  have hs := List.all_eq_true.mp hall o (nth?_mem_some ho)
  cases o with
  | none => cases hs
  | some E =>
    cases hq : decC dq E with
    | none => simp [Option.bind, hq] at hs
    | some q =>
      refine ⟨E, q, rfl, ?_, decC_eval hν hdq hq⟩
      rw [nth?_map, ho]; simp [Option.bind, hq]

section
variable {L T : Nat} {tk : Nat → Nat} {uses : List Row} {R : List (Nat × Q)} {u c : Nat} {Es : List (Option SymE)}

/-- The results' values at an admitted step whose map holds `u` at the offset. -/
theorem hEs_dec (hR : (u, Q.o) ∈ R) (hall : Es.all (fun o => (o.bind (decC (Conv.decQ u))).isSome) = true) :
    ∀ r ∈ uses, ∀ (i : Cls.Inst), InRow r i → ∀ (ν : Nat → F64), DecAt L T tk i → MapOk ν i R → VP ν →
      ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧
        nth? (Es.map fun o => (o.bind (decC (Conv.decQ u))).getD (.inl .o)) j = some q ∧ E.eval ν = F64.ofNat (rval i q) :=
  fun _ _ _ _ _ hadm hmap hν => hEs_of_form hν
    (fun _ _ h => Conv.decQ_eval h (mapOk_iff.1 hmap _ hR) (DecAt.get_e hadm) (DecAt.o_succ_lt31 hadm)) hall

/-- The same at a growing row, the map holding `c` at the capacity. -/
theorem hEs_decC (hcap : ∀ r ∈ uses, ∀ i, InRow r i → i.get .cap1 = i.get .cap + 256 ∧ i.get .cap1 ≤ 2 ^ 20)
    (hR : (u, Q.o) ∈ R) (hc : (c, Q.cap) ∈ R)
    (hall : Es.all (fun o => (o.bind (decC (Conv.decQC u c))).isSome) = true) :
    ∀ r ∈ uses, ∀ (i : Cls.Inst), InRow r i → ∀ (ν : Nat → F64), DecAt L T tk i → MapOk ν i R → VP ν →
      ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧
        nth? (Es.map fun o => (o.bind (decC (Conv.decQC u c))).getD (.inl .o)) j = some q ∧
          E.eval ν = F64.ofNat (rval i q) :=
  fun r hr i hin _ hadm hmap hν =>
    have hk := hcap r hr i hin
    hEs_of_form hν (fun _ _ h => Conv.decQC_eval h (mapOk_iff.1 hmap _ hR) (DecAt.get_e hadm) (DecAt.o_succ_lt31 hadm)
      (mapOk_iff.1 hmap _ hc) hk.1 (by omega)) hall

/-- A check of a result's value bound. -/
def rvLe (grows : Bool) : RV → Bool
  | .inl q => decide (q = .o ∨ q = .e) || (grows && decide (q = .cap1))
  | .inr k => Nat.ble k (2 ^ 20)

/-- **The results' values are within the bound** at an admitted step. -/
theorem qs_leV {qs : List RV} {cws : List Nat} (hqs : qs.all (rvLe false) = true) :
    ∀ r ∈ uses, ∀ i, InRow r i → DecAt L T tk i → ∀ j c q, nth? cws j = some c → nth? qs j = some q →
      rval i q ≤ loopVB c := by
  intro _ _ i _ h j c q _ hq
  have hm := List.all_eq_true.mp hqs q (nth?_mem_some hq)
  cases q with
  | inl q =>
    simp only [rvLe, Bool.false_and, Bool.or_false, decide_eq_true_eq] at hm
    exact DecAt.get_le h (hm.elim .inl fun he => .inr (.inl he))
  | inr k => exact Nat.le_of_ble_eq_true hm

/-- The same at a growing row. -/
theorem qs_leVC {qs : List RV} {cws : List Nat}
    (hcap : ∀ r ∈ uses, ∀ i, InRow r i → i.get .cap1 = i.get .cap + 256 ∧ i.get .cap1 ≤ 2 ^ 20)
    (hqs : qs.all (rvLe true) = true) :
    ∀ r ∈ uses, ∀ i, InRow r i → DecAt L T tk i → ∀ j c q, nth? cws j = some c → nth? qs j = some q →
      rval i q ≤ loopVB c := by
  intro r hr i hin h j c q _ hq
  have hm := List.all_eq_true.mp hqs q (nth?_mem_some hq)
  cases q with
  | inl q =>
    simp only [rvLe, Bool.true_and, Bool.or_eq_true, decide_eq_true_eq] at hm
    rcases hm with hm | e
    · exact DecAt.get_le h (hm.elim .inl fun he => .inr (.inl he))
    · subst e; exact (hcap r hr i hin).2
  | inr k => exact Nat.le_of_ble_eq_true hm

/-- A check of an end result against a cut's maps. -/
def endOk (dq : SymE → Option Q) (m : List (Nat × Q)) (cm : List (Nat × Nat)) (p : Nat × SymE) : Bool :=
  match decC dq p.2 with
  | some (.inl q) => m.contains (p.1, q)
  | some (.inr k) => cm.contains (p.1, k)
  | none => false

theorem nth?_zip' {α β : Type} : ∀ {xs : List α} {ys : List β} {j : Nat} {a : α} {b : β}, nth? xs j = some a →
    nth? ys j = some b → (a, b) ∈ xs.zip ys := fun ha hb => nth?_mem_some (nth?_zip ha hb)

/-- **The end results back to their terms** at a valuation: each a quantity or a constant the cut holds it at. -/
theorem decanon_of {dq : SymE → Option Q} {i : Cls.Inst} {ν : Nat → F64} {m : List (Nat × Q)} {cm : List (Nat × Nat)}
    {vs : List Nat} {es : List SymE} (hν : VP ν) (hdq : ∀ E q, dq E = some q → E.eval ν = F64.ofNat (i.get q))
    (hm : MapOk ν i m) (hc : CMapOk ν cm) (h : (vs.zip es).all (endOk dq m cm) = true) :
    ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν := by
  intro j v e hv he
  have hk := List.all_eq_true.mp h (v, e) (nth?_zip' hv he)
  unfold endOk at hk
  dsimp only at hk
  cases hd : decC dq e with
  | none => rw [hd] at hk; cases hk
  | some q =>
    rw [hd] at hk
    rw [decC_eval hν hdq hd]
    cases q with
    | inl q => exact (mapOk_iff.1 hm) (v, q) (List.contains_iff_mem.mp hk)
    | inr k => exact hc (v, k) (List.contains_iff_mem.mp hk)

/-- The end results' terms at an admitted step, the map holding `u` at the offset. -/
theorem hde_dec {m : List (Nat × Q)} {cm : List (Nat × Nat)} {vs : List Nat} {es : List SymE}
    (h : (vs.zip es).all (endOk (Conv.decQ u) m cm) = true) (hu : (u, Q.o) ∈ m) :
    ∀ r ∈ uses, ∀ i, InRow r i → DecAt L T tk i → ∀ ν, MapOk ν i m → VP ν → CMapOk ν cm →
      ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν :=
  fun _ _ _ _ hadm _ hm hν hc => decanon_of hν
    (fun _ _ hq => Conv.decQ_eval hq (mapOk_iff.1 hm _ hu) (DecAt.get_e hadm) (DecAt.o_succ_lt31 hadm)) hm hc h

/-- The same at a growing row. -/
theorem hde_decC {m : List (Nat × Q)} {cm : List (Nat × Nat)} {vs : List Nat} {es : List SymE}
    (hcap : ∀ r ∈ uses, ∀ i, InRow r i → i.get .cap1 = i.get .cap + 256 ∧ i.get .cap1 ≤ 2 ^ 20)
    (h : (vs.zip es).all (endOk (Conv.decQC u c) m cm) = true) (hu : (u, Q.o) ∈ m) (hc : (c, Q.cap) ∈ m) :
    ∀ r ∈ uses, ∀ i, InRow r i → DecAt L T tk i → ∀ ν, MapOk ν i m → VP ν → CMapOk ν cm →
      ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν :=
  fun r hr i hin hadm _ hm hν hk =>
    have hk' := hcap r hr i hin
    decanon_of hν (fun _ _ hq => Conv.decQC_eval hq (mapOk_iff.1 hm _ hu) (DecAt.get_e hadm) (DecAt.o_succ_lt31 hadm)
      (mapOk_iff.1 hm _ hc) hk'.1 (by omega)) hm hk h

end

/-- A cut's constants apart from a call's results and fresh variables. -/
theorem cm0_of_all {cm : List (Nat × Nat)} {cws ws : List Nat}
    (h : (cm.all fun p => (Conv.idx? p.1 cws).isNone && !ws.contains p.1) = true) :
    ∀ p ∈ cm, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false := by
  intro p hp
  have h1 := List.all_eq_true.mp h p hp
  simp only [Bool.and_eq_true, Option.isNone_iff_eq_none, Bool.not_eq_true'] at h1
  exact h1

/-- The abstracted dims apart from a call's results and fresh variables. -/
theorem dv_of_all {cws ws : List Nat}
    (h : ((cws ++ ws).all fun v => (decVal v).isNone) = true) :
    ∀ v k, decVal v = some k → Conv.idx? v cws = none ∧ ws.contains v = false := by
  intro v k hv
  have hn : v ∉ cws ++ ws := fun hm => by
    have := List.all_eq_true.mp h v hm
    rw [hv] at this
    cases this
  refine ⟨Conv.idx?_none fun hc => hn (List.mem_append_left _ hc), ?_⟩
  cases hc : ws.contains v with
  | false => rfl
  | true => exact absurd (List.mem_append_right _ (List.contains_iff_mem.mp hc)) hn

/-! ## The frames -/

/-- The fixed addresses of these chains. -/
def fix4 : List Nat := [2586, 2589] ++ Template.fixP

theorem short_sub : ∀ a ∈ shortFixP, a ∈ fix4 := by decide

/-- An iteration end at `fix4`, its data the given end's. -/
noncomputable def endAt4 {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE}
    (e : IterEndW Wd A P s0 tab0 Template.fixP) (hc : e.σ.a 2586 = 2586) (hg : e.σ.a 2589 = 2589) :
    IterEndW Wd A P s0 tab0 fix4 where
  s1 := e.s1
  S1 := e.S1
  σ := e.σ
  θ := e.θ
  grow := e.grow
  xs := e.xs
  eR := e.eR
  tlen := e.tlen
  noVarTab := e.noVarTab
  noVarOr := e.noVarOr
  nshift := e.nshift
  num := e.num
  hE := e.hE
  theta := e.theta
  fwd := e.fwd
  emit := e.emit
  fix := fun a ha => by
    rcases List.mem_append.mp ha with ha | ha
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact hc
      · exact hg
    · exact e.fix a ha

/-- The framed addresses of these chains. -/
abbrev frG : List Nat := [2673448, 12504, 2665] ++ 4910 :: ghostAddrs

/-- The kept arrays: the framed addresses off the wide frames. -/
theorem xs_wideG (a : Nat) : a ∈ [2673448, 12504, 2665] ↔ a ∈ frG ∧ wideG a = none := by
  constructor
  · intro h
    refine ⟨List.mem_append_left _ h, ?_⟩
    simp only [List.mem_cons, List.not_mem_nil, or_false] at h
    rcases h with rfl | rfl | rfl <;> rfl
  · rintro ⟨h, hw⟩
    rcases List.mem_append.mp h with h | h
    · exact h
    · have := (wideG_mem_iff a).mpr h
      rw [hw] at this
      cases this

/-- The wide frames are framed. -/
theorem wfr_wideG (a : Nat) (w : WFrame) (hw : wideG a = some w) : a ∈ frG :=
  List.mem_append_right _ ((wideG_mem_iff a).mp (by rw [hw]; rfl))

/-- The further frames' prefixes are the chain start's arrays. -/
theorem hX_framesG {S : Type} {s0 : St S} {q : List Val} (h : (ghostAddrs.all fun a => (arrOf s0 a).isEmpty) = true)
    (h4910 : arrOf s0 4910 = []) : ∀ a pre pre', (framesG s0 q).X a = some (pre, pre') → pre = arrOf s0 a := by
  intro a pre pre' hx
  change (bif Nat.beq a 2665 then some (arrOf s0 2665, q) else bif (wideG a).isSome then some ([], []) else none) = _ at hx
  cases h1 : Nat.beq a 2665 with
  | true =>
    rw [h1] at hx
    cases hx
    rw [Nat.eq_of_beq_eq_true h1]
  | false =>
    rw [h1] at hx
    cases h2 : (wideG a).isSome with
    | false => rw [h2] at hx; cases hx
    | true =>
      rw [h2] at hx
      cases hx
      rcases List.mem_cons.mp ((wideG_mem_iff a).mp h2) with e | hm
      · rw [e, h4910]
      · have he := List.all_eq_true.mp h a hm
        exact (List.isEmpty_iff.mp he).symm

/-- The wide frames present. -/
theorem wg_present {S : Type} {s : St S} (h : ((4910 :: ghostAddrs).all fun a => (s.heap.get a).isSome) = true) :
    ∀ a w, wideG a = some w → Present s a :=
  fun a _ hw => List.all_eq_true.mp h a ((wideG_mem_iff a).mp (by rw [hw]; rfl))

/-- The wide frames' shift facts: memo and ghost frames have none. -/
theorem wf_wideG {κ : Map} {A : Nat → Prop} : ∀ a w, wideG a = some w → WFix κ A w := by
  intro a w hw
  rcases List.mem_cons.mp (lookupW_mem hw) with e | hm
  · cases e; trivial
  · obtain ⟨_, _, e⟩ := List.mem_map.mp hm
    cases e; trivial

/-! ## The chains' acceptance and cuts -/

section
variable (b0 : BSt) (NB : Nat) (Pw : LoadP) (fr : List Nat) (wd : List (Nat × WFrame)) (W : Nat → Option WFrame) (A : Addr)
  (Fr : LoopFramesA A) (s0 : St FF.S) (tab0 : List SymE) (fixA : List Nat) (toks : List NumV)

/-- A chain's acceptance parameters. -/
abbrev J : Disp.JSP FF := Host.Load.Run.Tpl.DecOk.decJ Pw fr wd

/-- A chain's acceptance. -/
abbrev ok : St FF.S → SSrv → Bool := Disp.okJSK (J Pw fr wd) (fun _ _ => false)

/-- The run's predicate at a cut. -/
def DQ (m : List (Nat × Q)) (cm : List (Nat × Nat)) (i : Cls.Inst) (x : SegInst FF) : Prop :=
  VP x.ν ∧ Disp.Kp (J Pw fr wd) x.K ∧ MapOk x.ν i m ∧ CMapOk x.ν cm

/-- **A chain's cut at a template boundary.** -/
def bdCut (ΔJ ΔH ΔN : Nat) (θ : Nat → SymE) (g : GhostP) (m : List (Nat × Q)) (cm : List (Nat × Nat)) (s : St FF.S) (S : SSrv)
    (i : Cls.Inst) (x0 : SegInst FF) : ICut FF :=
  (Cut.mk s S.tab (Conv.relB FF (FLRb b0 Pw NB (toks.drop i.k)) W [] (DQ Pw fr wd m cm i))).with
    fun x => IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0 x ∧ Bud Pw s0 ΔJ ΔH ΔN x0

/-- **The pinned decode world's simulation at a chain's acceptance.** -/
theorem sim (hW : Disp.Wp (J Pw fr wd) W) (r : List NumV) (stk : List Frame) :
    Disp.StepSimXLB FF (FLRb b0 Pw NB r) (ok Pw fr wd) (Disp.Kp (J Pw fr wd)) W stk VP :=
  Host.Load.Run.Tpl.DecOk.stepSim { Pw with rest := r } NB (J Pw fr wd) (okCallFSS_rest Pw r).symm rfl rfl rfl rfl b0 stk hW

/-- That simulation with the target's growth. -/
theorem simQ (hW : Disp.Wp (J Pw fr wd) W) (r : List NumV) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FLRb b0 Pw NB r) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) (ok Pw fr wd)
      (Disp.Kp (J Pw fr wd)) W stk VP :=
  Host.Load.Run.Tpl.DecOk.stepSimQ { Pw with rest := r } NB (J Pw fr wd) (okCallFSS_rest Pw r).symm rfl rfl rfl rfl b0 stk hW y0

end

variable {b0 : BSt} {NB : Nat} {Pw : LoadP} {fr : List Nat} {wd : List (Nat × WFrame)} {W : Nat → Option WFrame}

/-- The target's mlx state grows along a site instance's run. -/
theorem call_ngrow (hW : Disp.Wp (J Pw fr wd) W) (I : Stage.StageTpl FF (okLocal (ok Pw fr wd)))
    {sa : St FF.S} {wr : List Nat} (hs0 : I.s0 = { sa with stack := [] }) (hfoot : Conv.StageFoot wr I.s0 I.s2)
    (hnd : wr.Nodup) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31) (htr : ∃ fr, I.s2.trace = fr ++ I.s0.trace) :
    ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VP c.ν →
      Disp.Kp (J Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa I.S0 c.t c.C →
      runC FF (I.n + 1) c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi) := by
  intro r c t' C' hν hK hr ht
  have hsim : ∀ stk, Disp.StepSimXLB FF (FRQ (FLRb b0 Pw NB r) fun y => Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf y))
      (okLocal (ok Pw fr wd)) (Disp.Kp (J Pw fr wd)) W stk VP := fun stk =>
    (simQ b0 NB Pw fr wd W hW r stk (mlxOf c.t.ffi)).mono fun s S h => by
      simp only [okLocal, Bool.and_eq_true] at h; exact h.1
  obtain ⟨M', t1, C1, hrun, -, h2⟩ := Conv.site_merge I hs0 rfl hsim okLocal_localB hK hν hfoot hnd hbd htr 0
    (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))
  rw [ht] at hrun
  cases hrun
  exact h2.ffi.2

section
variable {A : Addr} {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {toks : List NumV}
  {L T : Nat} {tk : Nat → Nat} {uses : List Row} {ΔJ ΔH ΔN : Nat}

/-- **A glue piece into the next call as a link.** -/
def glueLinkCall {m m' : List (Nat × Q)} {cm : List (Nat × Nat)} {θ : Nat → SymE} {g : GhostP} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    {n : Nat} (O : List Ans) (hW : Disp.Wp (J Pw fr wd) W)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O)
    (hok : ok Pw fr wd sa Sa = true)
    (hrun : runOk FF (ok Pw fr wd) n sa Sa = some (sb, Sb))
    (hokb : ok Pw fr wd sb Sb = true) (hhalt : isHalt sb.ctl = false)
    (hstep : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hlen : tab0.length ≤ Sa.tab.length) (hsub : ∀ p ∈ m', p ∈ m)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VP c.ν →
      Disp.Kp (J Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa Sa c.t c.C →
      runC FF (n + 1) c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ g m cm sa Sa)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ g m' cm sc Sc) where
  n := n + 1
  O := O
  chk := hchk
  ok _ _ i _ hobl _ x0 := cut_glueCall (sim b0 NB Pw fr wd W hW _ []) hok hrun hokb hhalt hstep htop
    (fun _ hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2.1)
    (fun c _ t' _ hq hb hc he hr h2 => ⟨⟨h2.withOracle (fun q hq => nomatch hq), hq.1, hq.2.1, MapOk.sub hq.2.2.1 hsub, hq.2.2.2⟩,
      hb.1.conv (he.mono hlen) rfl (fun _ _ _ => rfl) (fun _ _ _ _ => rfl) (hgrow _ c t' _ hq.1 hq.2.1 hc hr), hb.2⟩)

/-- **The last glue piece as a link**, to the iteration's end cut at the end template `e`. -/
def glueLinkEnd {m : List (Nat × Q)} {cm : List (Nat × Nat)} {e : IterEndW (fullWorldFb b0 NB) A Pw s0 tab0 fixA} {g : GhostP} {sa sb : St FF.S}
    {Sa Sb : SSrv} {n : Nat} (O : List Ans) (hW : Disp.Wp (J Pw fr wd) W)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O)
    (hok : ok Pw fr wd sa Sa = true)
    (hrun : runOk FF (ok Pw fr wd) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) (he1 : e.s1 = sb) (hS1 : e.S1 = Sb)
    (hlen : tab0.length ≤ Sa.tab.length)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VP c.ν →
      Disp.Kp (J Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa Sa c.t c.C →
      runC FF n c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN e.θ g m cm sa Sa)
      (fun i x0 => iterEndCW (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA toks e g i.k x0) where
  n := n
  O := O
  chk := hchk
  ok _ _ i _ hobl _ x0 := cut_glue (sim b0 NB Pw fr wd W hW _ []) hok hrun htop
    (fun _ hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2.1)
    (fun c _ t' _ hq hb hc he hr h2 => ⟨by show RelF FF (FLRb b0 Pw NB _) W _ _ _ e.s1 e.S1 _ _; rw [he1, hS1]; exact h2,
      hb.1.conv (he.mono hlen) rfl (fun _ _ _ => rfl) (fun _ _ _ _ => rfl) (hgrow _ c t' _ hq.1 hq.2.1 hc hr)⟩)

/-- **The last glue piece with the end table de-canonicalized.** -/
def glueLinkEndD {m : List (Nat × Q)} {cm : List (Nat × Nat)} {e : IterEndW (fullWorldFb b0 NB) A Pw s0 tab0 fixA} {g : GhostP} {sa sb : St FF.S}
    {Sa Sb : SSrv} {n : Nat} (O : List Ans) (hW : Disp.Wp (J Pw fr wd) W)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O)
    (hok : ok Pw fr wd sa Sa = true)
    (hrun : runOk FF (ok Pw fr wd) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) (vs : List Nat) (es : List SymE) (he1 : e.s1 = sb)
    (hS1 : e.S1 = ⟨Sb.tab.map (·.subst (Conv.compactθ vs es)), Sb.oracle⟩)
    (hde : ∀ r ∈ uses, ∀ i, InRow r i → DecAt L T tk i → ∀ ν, MapOk ν i m → VP ν → CMapOk ν cm →
      ∀ j v e, nth? vs j = some v → nth? es j = some e → ν v = e.eval ν) (hlen : tab0.length ≤ Sa.tab.length)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VP c.ν →
      Disp.Kp (J Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa Sa c.t c.C →
      runC FF n c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN e.θ g m cm sa Sa)
      (fun i x0 => iterEndCW (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA toks e g i.k x0) where
  n := n
  O := O
  chk := hchk
  ok r hru i hin hobl hadm x0 := cut_glue (sim b0 NB Pw fr wd W hW _ []) hok hrun htop
    (fun _ hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2.1)
    (fun c _ t' _ hq hb hc he hr h2 => ⟨by
        show RelF FF (FLRb b0 Pw NB _) W _ _ _ e.s1 e.S1 _ _
        rw [he1, hS1]
        exact h2.decanon (hde r hru i hin hadm _ hq.2.2.1 hq.1 hq.2.2.2),
      hb.1.conv (he.mono hlen) rfl (fun _ _ _ => rfl) (fun _ _ _ _ => rfl) (hgrow _ c t' _ hq.1 hq.2.1 hc hr)⟩)

/-- **The first link**, valuations given at the iterations `DecAt` supports. -/
def startLink {E0 : List Val} {B : LoopBase} {ρ : Nat → F64} {m : List (Nat × Q)} {θ : Nat → SymE}
    {sst : St FF.S} {Sst : SSrv} (O : List Ans) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hs : sst = s0) (hS : Sst.tab = tab0) (hfr : ∀ a, a ∈ A.fwd :: A.emit :: Fr.xs ↔ a ∈ fr)
    (hVP : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VP (valL ρ T tk L i nx))
    (hMap : ∀ i nx, MapOk (valL ρ T tk L i nx) (decI L T i (tk (i + 1))) m) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    DLink (DecAt L T tk) uses m []
      (fun i x0 => iterGhostW (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN θ i.k x0)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) s0) m [] sst Sst) where
  n := 0
  O := O
  chk := hchk
  ok _ _ i _ _ hadm x0 := CutConv.step fun x hR hB => by
    obtain ⟨hg, hν, hK, nx, p1, hν0, hfr0, hlo, hhi, -, -, hnx, -, hD, hHx, hNx, -⟩ := hB
    have hk := hadm.2.1
    have mJ : (i.k - 1 + 1) * ΔJ ≤ T * ΔJ := Nat.mul_le_mul_right _ (by omega)
    have mH : (i.k - 1 + 1) * ΔH ≤ T * ΔH := Nat.mul_le_mul_right _ (by omega)
    have mN : (i.k - 1 + 1) * ΔN ≤ T * ΔN := Nat.mul_le_mul_right _ (by omega)
    rw [Nat.add_one_mul] at mJ mH mN
    refine ⟨x, rfl, rfl, ⟨?_, ?_, ?_, ?_, fun _ h => nomatch h⟩, hg, ?_, ?_, ?_⟩
    · show RelB FF (FLRb b0 Pw NB _) W [] x.M x.ν x.K sst ⟨Sst.tab, []⟩ x.t x.C
      rw [hs, hS]; exact hR
    · rw [hν, hν0]; exact hVP _ nx hk hnx
    · rw [hK]
      exact ⟨hlo, hhi, fun a => by rw [hfr0]; exact (frA_ne_none A s0 Fr _ _ a).trans (hfr a)⟩
    · have h := hMap i.k nx
      rw [← hadm.1] at h
      rw [hν, hν0]; exact h
    · show x0.K.D + ΔJ < Sim.bound; omega
    · show (mlxOf x0.t.ffi).next + ΔH + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46
      have : (mlxOf x0.t.ffi).next ≤ (mlxOf s0.ffi).next + (i.k - 1) * ΔH + B.H := hHx
      omega
    · show (mlxOf x0.t.ffi).nnext + ΔN + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
      have : (mlxOf x0.t.ffi).nnext ≤ (mlxOf s0.ffi).nnext + (i.k - 1) * ΔN + B.N := hNx
      omega

/-- **The first link from the shorter decode cut.** -/
def startLinkS {fixS : List Nat} {E0 : List Val} {B : LoopBase} {ρ : Nat → F64} {m : List (Nat × Q)} {θ : Nat → SymE}
    {sst : St FF.S} {Sst : SSrv} (O : List Ans) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hs : sst = s0) (hS : Sst.tab = tab0) (hfr : ∀ a, a ∈ A.fwd :: A.emit :: Fr.xs ↔ a ∈ fr)
    (hVP : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VP (valL ρ T tk L i nx))
    (hMap : ∀ i nx, MapOk (valL ρ T tk L i nx) (decI L T i (tk (i + 1))) m) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    DLink (DecAt L T tk) uses m []
      (fun i x0 => iterGhostS (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA fixS (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN θ i.k x0)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) s0) m [] sst Sst) where
  n := 0
  O := O
  chk := hchk
  ok _ _ i _ _ hadm x0 := CutConv.step fun x hR hB => by
    obtain ⟨hg, hν, hK, nx, p1, hν0, hfr0, hlo, hhi, -, -, hnx, -, hD, hHx, hNx, -⟩ := hB
    have hk := hadm.2.1
    have mJ : (i.k - 1 + 1) * ΔJ ≤ T * ΔJ := Nat.mul_le_mul_right _ (by omega)
    have mH : (i.k - 1 + 1) * ΔH ≤ T * ΔH := Nat.mul_le_mul_right _ (by omega)
    have mN : (i.k - 1 + 1) * ΔN ≤ T * ΔN := Nat.mul_le_mul_right _ (by omega)
    rw [Nat.add_one_mul] at mJ mH mN
    refine ⟨x, rfl, rfl, ⟨?_, ?_, ?_, ?_, fun _ h => nomatch h⟩, hg, ?_, ?_, ?_⟩
    · show RelB FF (FLRb b0 Pw NB _) W [] x.M x.ν x.K sst ⟨Sst.tab, []⟩ x.t x.C
      rw [hs, hS]; exact hR
    · rw [hν, hν0]; exact hVP _ nx hk hnx
    · rw [hK]
      exact ⟨hlo, hhi, fun a => by rw [hfr0]; exact (frA_ne_none A s0 Fr _ _ a).trans (hfr a)⟩
    · have h := hMap i.k nx
      rw [← hadm.1] at h
      rw [hν, hν0]; exact h
    · show x0.K.D + ΔJ < Sim.bound; omega
    · show (mlxOf x0.t.ffi).next + ΔH + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46
      have : (mlxOf x0.t.ffi).next ≤ (mlxOf s0.ffi).next + (i.k - 1) * ΔH + B.H := hHx
      omega
    · show (mlxOf x0.t.ffi).nnext + ΔN + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
      have : (mlxOf x0.t.ffi).nnext ≤ (mlxOf s0.ffi).nnext + (i.k - 1) * ΔN + B.N := hNx
      omega

/-- **A call as a link**: `Compose.callLink` at the valuations `VP`, its results quantities or constants. -/
def callLink {m R R' : List (Nat × Q)} {cm cm' : List (Nat × Nat)} {qs : List RV} {θ : Nat → SymE} {g : GhostP} {sa sm sc : St FF.S} {Sa Sc : SSrv}
    {tabm : List SymE} {f eN : List Val}
    (I : Stage.StageTpl FF (Template.okLocal (ok Pw fr wd))) {wr ws cws nr : List Nat} {κ : Map}
    {Es : List (Option SymE)}
    (O : List Ans) (hW : Disp.Wp (J Pw fr wd) W) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hO : I.S0.oracle = O) (hmR : ∀ p ∈ m, p ∈ R)
    -- the instance and the merge
    (hs0 : I.s0 = { sa with stack := [] }) (htab : I.S0.tab = Sa.tab) (hfoot : Conv.StageFoot wr I.s0 I.s2)
    (hnd : wr.Nodup) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31) (htr : ∃ fr, I.s2.trace = fr ++ I.s0.trace)
    (hmer : ∀ (r : List NumV) {M : Map} {ν : Nat → F64} {K : Ctx} {S : SSrv} {t : St FF.S} {C : CSrv},
      RelB FF (FLRb b0 Pw NB r) W [] M ν K
        (Conv.mergeSt Map.id (Map.id.res Sa.tab.length Sa.tab.length) sa.stack wr sa I.s2 I.s0 I.s2.ffi) S t C →
      RelB FF (FLRb b0 Pw NB r) W [] M ν K sm S t C)
    (hmtab : tabm = Sa.tab ++ Conv.resTab ws) (hwsl : ws.length = I.S2.tab.length - Sa.tab.length)
    (hwsnd : ws.Nodup) (hfresh : ∀ e ∈ Sa.tab, ∀ w ∈ ws, e.noVar w = true)
    -- the ghost across the merge
    (hlen : tab0.length ≤ Sa.tab.length)
    (hgtab : ∀ j e, nth? tab0 j = some e → ∀ w, (w ∈ cws ∨ w ∈ ws) → e.noVar w = true)
    (hgθ : ∀ j e, nth? tab0 j = some e → ∀ w, (w ∈ cws ∨ w ∈ ws) → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VP c.ν →
      Disp.Kp (J Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa I.S0 c.t c.C →
      runC FF (I.n + 1) c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi))
    -- the compaction
    (hctab : Sc.tab = Sa.tab ++ cws.map SymE.var) (hdis : ∀ w ∈ cws, w ∉ ws)
    (hshift : ∀ x0 x : SegInst FF, Conv.CallFacts sa Sa.tab.length → Conv.FullShiftQ Pw Sc.tab.length κ sc.ffi sm.ffi →
      Disp.Kp (J Pw fr wd) x.K → IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0 x →
      ShiftD FF (fun _ _ _ => True) κ (Conv.compactθ cws (nr.map fun r => (nth? tabm r).getD (.var 0)))
        (kpOf x.K W) W x.K sc ⟨Sc.tab, []⟩ sm ⟨tabm, []⟩)
    (hffi : ∀ (r : List NumV) (M : Map) (y : FF.S), FLRb b0 Pw NB r M Sa.tab.length sa.ffi y →
      Conv.FullShiftQ Pw Sc.tab.length κ sc.ffi sm.ffi)
    (hbig : bigsOutB (mlxOf sc.ffi).next Pw.E (mlxOf sc.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < Pw.E) sc.trace sc)
    (hband : ∀ i : Int, ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < Pw.E →
      ¬ BigFixed (J Pw fr wd).lo (J Pw fr wd).hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (dJ dH dN : Nat) (hdJ : dJ ≤ ΔJ) (hdH : dH ≤ ΔH) (hdN : dN ≤ ΔN)
    (hcJ : sm.next + s0.next + g.dJ ≤ dJ + g.vJ + sc.next)
    (hcH : g.dH + (mlxOf sm.ffi).next + (mlxOf s0.ffi).next ≤ dH + g.vH + (mlxOf sc.ffi).next)
    (hcN : g.dN + (mlxOf sm.ffi).nnext + (mlxOf s0.ffi).nnext ≤ dN + g.vN + (mlxOf sc.ffi).nnext)
    (hs0E : (mlxOf s0.ffi).next ≤ Pw.E) (hscE : (mlxOf sc.ffi).next ≤ Pw.E)
    (hs0N : (mlxOf s0.ffi).nnext ≤ Pw.NE) (hscN : (mlxOf sc.ffi).nnext ≤ Pw.NE)
    (hκn : ∀ j, j < tab0.length → κ.num j = .ref j) (hκa : ∀ a ∈ fixA, κ.a a = a)
    (hκv : ∀ j, j < (mlxOf s0.ffi).nnext → κ.node j = j)
    (hfwd : ∃ o, sm.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ f))
    (hemit : ∃ o, sm.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ eN))
    (hkeep : KeepsAtW Fr sm) (heN : NumRefs tab0.length eN)
    (hJ : g.vJ ≤ sm.next) (hJc : sc.next ≤ sm.next) (hH : g.vH ≤ (mlxOf sm.ffi).next)
    (hHE : (mlxOf sm.ffi).next < Pw.E) (hN : g.vN ≤ (mlxOf sm.ffi).nnext)
    -- the post-call values
    (hm0 : ∀ p ∈ R, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hc0 : ∀ p ∈ cm, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hdv : ∀ v k, decVal v = some k → Conv.idx? v cws = none ∧ ws.contains v = false) (hndc : cws.Nodup)
    (hlenc : cws.length = nr.length) (hnrLo : nr.all (Nat.ble Sa.tab.length) = true)
    (hder : nr.map (fun r => nth? I.S2.tab r) = Es)
    (hlq : qs.length = cws.length)
    (hEs : ∀ r ∈ uses, ∀ (i : Cls.Inst), InRow r i → ∀ (ν : Nat → F64), DecAt L T tk i → MapOk ν i R → VP ν →
      ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧ nth? qs j = some q ∧ E.eval ν = F64.ofNat (rval i q))
    (hq : ∀ r ∈ uses, ∀ i, InRow r i → DecAt L T tk i → ∀ j c q, nth? cws j = some c → nth? qs j = some q →
      rval i q ≤ loopVB c)
    (hR' : ∀ p ∈ R', p ∈ R ++ qzip cws qs) (hC' : ∀ p ∈ cm', p ∈ cm ++ kzip cws qs) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ g R cm sa Sa)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ (GhostP.compact (fullWorldFb b0 NB) g sm sc eN) R' cm' sc Sc) where
  n := I.n + 1
  O := O
  chk := hchk
  ok r hr i hin hobl hadm x0 := CutStep.withP fun hbud => by
    let νr : (Nat → F64) → Nat → F64 := fun ν => Conv.resVal ν ws (Conv.resF SymE.var I.S2.tab Sa.tab.length ν)
    let Qm : SegInst FF → Prop := fun x =>
      ∃ ν, x.ν = νr ν ∧ VP ν ∧ MapOk ν i R ∧ CMapOk ν cm ∧ Disp.Kp (J Pw fr wd) x.K ∧ x.t.next = sm.next + x.K.D ∧
        (mlxOf x.t.ffi).next + g.vH ≤ (mlxOf x0.t.ffi).next + g.dH + (mlxOf sm.ffi).next ∧
        (mlxOf x.t.ffi).nnext + g.vN ≤ (mlxOf x0.t.ffi).nnext + g.dN + (mlxOf sm.ffi).nnext ∧ Conv.CallFacts sa Sa.tab.length ∧
        Conv.FullShiftQ Pw Sc.tab.length κ sc.ffi sm.ffi
    let crs := nr.map fun r => (nth? tabm r).getD (.var 0)
    have hstep := cut_siteMerge (FR := FLRb b0 Pw NB (toks.drop i.k)) (W := W)
      (Q := DQ Pw fr wd R cm i) (B := IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0) (Q' := Qm)
      (B' := IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0) I hs0 htab
      (fun stk => (sim b0 NB Pw fr wd W hW _ stk).mono fun s S h => by
        simp only [Template.okLocal, Bool.and_eq_true] at h; exact h.1)
      Template.okLocal_localB hfoot hnd hbd htr (hmer _) hwsl hwsnd hfresh
      (fun c hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν (MapOk.sub hq.2.2.1 hmR))
      (fun c M' t' C' hq hb h0 he hrun hm => by
        have hb' := hb.merge (V := (· ∈ ws)) (M' := M') (t' := t') (C' := C') (he.mono hlen)
          (fun v hv => Conv.resVal_off (ν := c.ν) (ws := ws) (f := Conv.resF SymE.var I.S2.tab Sa.tab.length c.ν) hv)
          (fun j e hj w hw => hgtab j e hj w (.inr hw)) (fun j e hj w hw => hgθ j e hj w (.inr hw))
          (hgrow _ c t' C' hq.1 hq.2.1 h0 hrun)
        have hc := IterGhostCW.counters (fullWorldFb_end b0 NB) hb' hm.ffi hH hHE hN
        exact ⟨⟨c.ν, rfl, hq.1, hq.2.2.1, hq.2.2.2, hq.2.1, hm.offset, hc.1, hc.2, htab ▸ Conv.CallFacts.of_rel h0,
          hffi _ _ _ (htab ▸ h0.ffi)⟩, hb'⟩)
    rw [← hmtab] at hstep
    refine hstep.convR (cut_compactQ b0 (V := fun v => v ∈ cws ∨ v ∈ ws) (θk := Conv.compactθZ cws crs ws)
      (Q := Qm) (Q' := DQ Pw fr wd R' cm' i) (f := f) (eN := eN)
      (fun x hx hB => ?_) hbig hfree (fun x hx _ => ?_) (fun x hx hB => ?_) (fun x hx hB => ?_)
      hκn hκa hκv (fun v hv => compactθZ_off hv) hgtab hgθ hfwd hemit hkeep heN hJ hJc hH hHE hN
      (fun x hx _ => ?_))
    · obtain ⟨-, -, -, -, -, hK, -, -, -, hcf, hfq⟩ := hx
      have hs := (hshift x0 x hcf hfq hK hB).retheta (θ' := Conv.compactθZ cws crs ws) (by
        rw [hctab]
        exact Conv.compactθZ_tab (fun e he z hz => hfresh e he z hz) hdis)
      exact { hs with ffi := ⟨rfl, hfq⟩ }
    · obtain ⟨-, -, -, -, -, ⟨hlo, hhi, -⟩, -⟩ := hx
      rw [hlo, hhi]
      exact hband
    · obtain ⟨-, -, -, -, -, -, hoff, -⟩ := hx
      have hD := hB.D
      have := hbud.1
      omega
    · obtain ⟨-, -, -, -, -, -, -, hxH, hxN, -⟩ := hx
      obtain ⟨-, hbH, hbN⟩ := hbud
      show (mlxOf x.t.ffi).next + (Pw.E - (mlxOf sc.ffi).next) < 2 ^ 46 ∧
        (mlxOf x.t.ffi).nnext + (Pw.NE - (mlxOf sc.ffi).nnext) < 2 ^ 62
      constructor <;> omega
    · obtain ⟨ν, hxν, hVP, hmap, hcm, ⟨hlo, hhi, hfr⟩, -⟩ := hx
      have hp := post_call_valC (VB := loopVB) (qs := qs) (S5 := tabm) (n0 := Sa.tab.length) hVP.1 hmap hcm hm0 hc0 hmtab
        rfl hwsl hwsnd hndc hlenc hlq hnrLo hder (hEs r hr i hin ν hadm hmap hVP) (hq r hr i hin hadm)
      refine ⟨⟨?_, fun v k hv => ?_⟩, ⟨hlo, hhi, fun a => ?_⟩, ?_, ?_⟩
      · show ∀ v, ∃ k ≤ loopVB v, Shift.valuation (Conv.compactθZ cws crs ws) x.ν v = F64.ofNat k
        rw [hxν]; exact hp.1
      · show Shift.valuation (Conv.compactθZ cws crs ws) x.ν v = F64.ofNat k
        have hd := hdv v k hv
        have hw : v ∉ ws := fun h => by have := hd.2; rw [List.contains_iff_mem.mpr h] at this; cases this
        rw [hxν, Conv.valuation_compactθZ_out hd.1 hd.2]
        show Conv.resVal ν ws _ v = _
        rw [Conv.resVal_off hw]
        exact hVP.2 v k hv
      · show Shift.framedNext x.M x.K sm a ≠ none ↔ _
        rw [framedNext_ne_none]; exact hfr a
      · show MapOk (Shift.valuation (Conv.compactθZ cws crs ws) x.ν) i R'
        rw [hxν]; exact MapOk.sub hp.2.1 hR'
      · show CMapOk (Shift.valuation (Conv.compactθZ cws crs ws) x.ν) cm'
        rw [hxν]; exact fun p hp' => hp.2.2 p (hC' p hp')

end

end Host.Ts.Sim.Compose.Dec4
