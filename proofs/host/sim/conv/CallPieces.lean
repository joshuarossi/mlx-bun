import host.sim.conv.Compact
import host.sim.conv.Fresh
import host.sim.lin.Classes
import host.sim.LoopArith
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin.Cls

/-! # The pieces of a decode chain's call links

A call link (`host.sim.compose.ChainFill`'s cuts) runs the site instance (`site_merge`), binds the stage's
numbers past the call's table to fresh variables `ws` (`resVal`, the merged boundary's table
`tab ++ resTab ws`), and compacts (`cut_compactQ`), each cut with its run predicate: the valuation's bound
(`VBOkF`), the context, the iteration's quantities (`MapOk`).

* `Disp.StepSimXLB.mono`: the simulation under a stronger acceptance (a site instance's `okLocal` of the
  chain's acceptance, under any stack base).
* `compactθZ`: the compaction's substitution with the stage's other fresh variables sent to `0`; it agrees
  with `compactθ` on the canonical table (`ShiftD.retheta`, `subst_compactθZ`), and its valuation stays in
  the bound (`vbOk_post`): the stage's other numbers (unbounded) are not the canonical state's.
* `crs_eval`: a canonical result variable's value is its stage entry's at the call's valuation;
  `mapOk_post`: the post-call quantities (the call's, and the results' at their quantity). -/

/-- **The simulation under a stronger acceptance.** -/
theorem _root_.Host.Ts.Sim.Disp.StepSimXLB.mono {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {ok ok' : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {W : Nat → Option WFrame} {stk : List Frame}
    {VBOk : (Nat → F64) → Prop} (h : Disp.StepSimXLB F FR ok Kp W stk VBOk)
    (hok : ∀ s S, ok' s S = true → ok s S = true) : Disp.StepSimXLB F FR ok' Kp W stk VBOk :=
  fun M ν K s S t C s1 S1 hK hν hr hh hl hok' hs => h M ν K s S t C s1 S1 hK hν hr hh hl (hok s S hok') hs

/-! ## The compaction's substitution with the other fresh variables at `0` -/

/-- `compactθ ws rs` with the variables `zs` (the stage's other fresh variables) sent to `0`. -/
def compactθZ (ws : List Nat) (rs : List SymE) (zs : List Nat) (v : Nat) : SymE :=
  match idx? v ws with
  | some j => (nth? rs j).getD (.var v)
  | none => bif zs.contains v then .lit (F64.ofNat 0) else .var v

theorem subst_compactθZ {ws : List Nat} {rs : List SymE} {zs : List Nat} :
    ∀ e : SymE, (∀ z ∈ zs, e.noVar z = true) → e.subst (compactθZ ws rs zs) = e.subst (compactθ ws rs)
  | .lit _, _ => rfl
  | .var i, h => by
    show compactθZ ws rs zs i = compactθ ws rs i
    unfold compactθZ compactθ
    cases e : idx? i ws with
    | some j => rfl
    | none =>
      have hi : zs.contains i = false := by
        cases hc : zs.contains i with
        | false => rfl
        | true =>
          have := h i (List.contains_iff_mem.mp hc)
          simp [SymE.noVar] at this
      simp only [hi, Bool.cond_false]
  | .bin op a b, h => by
    show SymE.bin op (a.subst _) (b.subst _) = SymE.bin op (a.subst _) (b.subst _)
    rw [subst_compactθZ a fun z hz => by have := h z hz; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.1,
      subst_compactθZ b fun z hz => by have := h z hz; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.2]
  | .un op a, h => by
    show SymE.un op (a.subst _) = SymE.un op (a.subst _)
    rw [subst_compactθZ a fun z hz => by have := h z hz; simpa [SymE.noVar] using this]

/-- **A shift's substitution may change off the start's table.** -/
theorem _root_.Host.Ts.Sim.ShiftD.retheta {F : Ffi} {FS : Map → F.S → F.S → Prop} {σ : Map} {θ θ' : Nat → SymE}
    {kp : Nat → Bool} {W0 : Nat → Option WFrame} {K1 : Ctx} {s0 s1 : St F.S} {S0 S1 : SSrv}
    (h : ShiftD F FS σ θ kp W0 K1 s0 S0 s1 S1) (hθ : ∀ i e, nth? S0.tab i = some e → e.subst θ' = e.subst θ) :
    ShiftD F FS σ θ' kp W0 K1 s0 S0 s1 S1 :=
  { h with num := fun i e he => by rw [hθ i e he]; exact h.num i e he }

/-- On the canonical table (the call's, free of `zs`, and the result variables) the two agree. -/
theorem compactθZ_tab {ws : List Nat} {rs : List SymE} {zs : List Nat} {tab : List SymE}
    (hfree : ∀ e ∈ tab, ∀ z ∈ zs, e.noVar z = true) (hdis : ∀ w ∈ ws, w ∉ zs) :
    ∀ i e, nth? (tab ++ ws.map SymE.var) i = some e → e.subst (compactθZ ws rs zs) = e.subst (compactθ ws rs) := by
  intro i e he
  refine subst_compactθZ e fun z hz => ?_
  rcases List.mem_append.1 (nth?_mem_some he) with hm | hm
  · exact hfree e hm z hz
  · obtain ⟨w, hw, rfl⟩ := List.mem_map.1 hm
    have hne : w ≠ z := fun h => hdis w hw (h ▸ hz)
    simp only [SymE.noVar, Bool.not_eq_true']
    exact Bool.eq_false_iff.mpr fun h => hne (Nat.eq_of_beq_eq_true h)

/-! ## The post-call valuation -/

section
variable {ws zs : List Nat} {rs : List SymE} {ν' : Nat → F64}

theorem valuation_compactθZ_out {v : Nat} (hv : idx? v ws = none) (hz : zs.contains v = false) :
    Shift.valuation (compactθZ ws rs zs) ν' v = ν' v := by
  show (compactθZ ws rs zs v).eval ν' = _
  simp only [compactθZ, hv, hz, Bool.cond_false]; rfl

theorem valuation_compactθZ_zero {v : Nat} (hv : idx? v ws = none) (hz : zs.contains v = true) :
    Shift.valuation (compactθZ ws rs zs) ν' v = F64.ofNat 0 := by
  show (compactθZ ws rs zs v).eval ν' = _
  simp only [compactθZ, hv, hz, Bool.cond_true]; rfl

theorem valuation_compactθZ_res {v j : Nat} {r : SymE} (hv : idx? v ws = some j) (hr : nth? rs j = some r) :
    Shift.valuation (compactθZ ws rs zs) ν' v = r.eval ν' := by
  show (compactθZ ws rs zs v).eval ν' = _
  simp only [compactθZ, hv, hr, Option.getD_some]

private theorem idx?_lt' {v : Nat} : ∀ {l : List Nat} {k : Nat}, idx? v l = some k → k < l.length
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
        have := idx?_lt' e; simp only [List.length_cons]; omega
    · rw [hb] at h; cases h; simp

private theorem idx?_nth' {v : Nat} : ∀ {l : List Nat} {k : Nat}, idx? v l = some k → nth? l k = some v
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
        exact idx?_nth' e
    · rw [hb] at h; cases h
      show some w = some v
      rw [Nat.eq_of_beq_eq_true hb]

/-- **The post-call valuation is in the bound** (`VBOkF`, unfolded): off the stage's fresh variables it is
the bounded one, the result variables carry bounded values, the other fresh variables `0`. -/
theorem vbOk_post {VB : Nat → Nat} (hν : ∀ v, zs.contains v = false → ∃ k ≤ VB v, ν' v = F64.ofNat k)
    (hc : ∀ j c r, nth? ws j = some c → nth? rs j = some r → ∃ k ≤ VB c, r.eval ν' = F64.ofNat k)
    (hlen : ws.length ≤ rs.length) :
    ∀ v, ∃ k ≤ VB v, Shift.valuation (compactθZ ws rs zs) ν' v = F64.ofNat k := by
  intro v
  cases hv : idx? v ws with
  | some j =>
    have hj := idx?_lt' hv
    obtain ⟨r, hr⟩ := nth?_some_of_lt (show j < rs.length by omega)
    rw [valuation_compactθZ_res hv hr]
    exact hc j v r (idx?_nth' hv) hr
  | none =>
    cases hz : zs.contains v with
    | true => rw [valuation_compactθZ_zero hv hz]; exact ⟨0, Nat.zero_le _, rfl⟩
    | false => rw [valuation_compactθZ_out hv hz]; exact hν v hz

theorem mapOk_iff' {ρ : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst} :
    ∀ {m : List (Nat × Q)}, MapOk ρ i m ↔ ∀ p ∈ m, ρ p.1 = F64.ofNat (i.get p.2)
  | [] => by simp [MapOk]
  | (j, q) :: m => by simp [MapOk, mapOk_iff' (m := m)]

theorem nth?_of_mem {α : Type} : ∀ {l : List α} {a : α}, a ∈ l → ∃ j, nth? l j = some a
  | b :: l, a, h => by
    rcases List.mem_cons.1 h with h | h
    · exact ⟨0, by rw [h]; rfl⟩
    · obtain ⟨j, hj⟩ := nth?_of_mem h; exact ⟨j + 1, hj⟩

/-- **The post-call quantities**: the call's map `m` (off the fresh and result variables) and the result
variables at the quantity `q`. -/
theorem mapOk_post {i : Host.Ts.Sim.Lin.Cls.Inst} {m : List (Nat × Q)} {q : Q} (hm : MapOk ν' i m)
    (hm0 : ∀ p ∈ m, idx? p.1 ws = none ∧ zs.contains p.1 = false)
    (hc : ∀ j c r, nth? ws j = some c → nth? rs j = some r → r.eval ν' = F64.ofNat (i.get q))
    (hlen : ws.length ≤ rs.length) (hnd : ws.Nodup) :
    MapOk (Shift.valuation (compactθZ ws rs zs) ν') i (m ++ ws.map fun c => (c, q)) := by
  refine mapOk_iff'.2 fun p hp => ?_
  rcases List.mem_append.1 hp with hp | hp
  · rw [valuation_compactθZ_out (hm0 p hp).1 (hm0 p hp).2]
    exact (mapOk_iff'.1 hm) p hp
  · obtain ⟨c, hcm, rfl⟩ := List.mem_map.1 hp
    obtain ⟨j, hj⟩ := nth?_of_mem hcm
    have hjl := nth?_lt _ _ _ hj
    obtain ⟨r, hr⟩ := nth?_some_of_lt (show j < rs.length by omega)
    rw [valuation_compactθZ_res (idx?_nth hnd hj) hr]
    exact hc j c r hj hr

end

/-! ## A result variable's value -/

theorem nth?_append_len {α : Type} : ∀ (xs ys : List α) (k : Nat), nth? (xs ++ ys) (xs.length + k) = nth? ys k
  | [], ys, k => by simp
  | x :: xs, ys, k => by
    show nth? (x :: (xs ++ ys)) (xs.length + 1 + k) = nth? ys k
    rw [Nat.add_right_comm]
    exact nth?_append_len xs ys k

/-- **A result variable's value**: the merged table's entry at `r` past the call's table is its fresh
variable, bound to the stage's entry at `r`, at the call's valuation (the site's own map: `θ` the identity). -/
theorem crs_eval {ν : Nat → F64} {tab S2 : List SymE} {ws : List Nat} {n0 r : Nat}
    (hn0 : tab.length = n0) (hnd : ws.Nodup) (hr : n0 ≤ r) (hrl : r - n0 < ws.length) :
    ((nth? (tab ++ resTab ws) r).getD (.var 0)).eval (resVal ν ws (resF SymE.var S2 n0 ν)) =
      ((nth? S2 r).getD (.lit (F64.zero false))).eval ν := by
  obtain ⟨w, hw⟩ := nth?_some_of_lt hrl
  have e1 : nth? (tab ++ resTab ws) r = some (.var w) := by
    have : r = tab.length + (r - n0) := by omega
    rw [this, nth?_append_len, resTab, nth?_map, hw]; rfl
  rw [e1, Option.getD_some]
  show resVal ν ws (resF SymE.var S2 n0 ν) w = _
  rw [resVal_at hnd hw]
  show ((nth? S2 (n0 + (r - n0))).getD (.lit (F64.zero false))).eval (Shift.valuation SymE.var ν) = _
  rw [show n0 + (r - n0) = r by omega]
  rfl

/-- `v + 1` at a valuation giving `v` a small natural. -/
theorem eval_succ_var {ν : Nat → F64} {v o : Nat} (hv : ν v = F64.ofNat o) (ho : o + 1 < 2 ^ 53) :
    (SymE.bin .add (.var v) (.lit (F64.ofNat 1))).eval ν = F64.ofNat (o + 1) := by
  show F64.bin .add (ν v) (F64.ofNat 1) = _
  rw [hv]; exact bin_add_ofNat o 1 ho

theorem eval_var_succ {ν : Nat → F64} {v o : Nat} (hv : ν v = F64.ofNat o) (ho : o + 1 < 2 ^ 53) :
    (SymE.bin .add (.lit (F64.ofNat 1)) (.var v)).eval ν = F64.ofNat (o + 1) := by
  show F64.bin .add (F64.ofNat 1) (ν v) = _
  rw [hv, bin_add_ofNat 1 o (by omega), Nat.add_comm]

/-- `v + 1` with the parser's literal (`litOne`), the form of the generator's `cderived` entries. -/
theorem eval_succ_lit {ν : Nat → F64} {v o : Nat} (hv : ν v = F64.ofNat o) (ho : o + 1 < 2 ^ 53) :
    (SymE.bin .add (.var v) litOne).eval ν = F64.ofNat (o + 1) :=
  eval_succ_var hv ho

/-- `post_call_val`'s `hEs` for results all of one entry `E`. -/
theorem hEs_of_all {Es : List (Option SymE)} {E : SymE} {ν : Nat → F64} {x : F64}
    (hall : Es.all (fun o => decide (o = some E)) = true) (hE : E.eval ν = x) :
    ∀ j o, nth? Es j = some o → ∃ E', o = some E' ∧ E'.eval ν = x := fun _ o ho =>
  ⟨E, of_decide_eq_true (List.all_eq_true.mp hall o (nth?_mem_some ho)), hE⟩

/-! ## The post-call valuation from the generator's facts -/

/-- **The post-call run predicate's valuation facts** at the canonical state of a compacted call, from the
generator's facts: the call's bounded valuation `ν` and quantities `m`; the stage's fresh variables `ws`
(`mergeTab`: the merged table `tab ++ resTab ws`, `n0` the call's table length, `ws` as long as the stage's
new entries); the result variables `cws` and their merged references `nr` (past the call's table:
`cnrLo`), the results' entries `Es` (`cderived`), each at the quantity `q` (`hEs`, from its form). The
canonical valuation is `compactθZ cws crs ws`'s (`crs` the merged entries at `nr`) after the stage's
binding: it is in the bound and has the call's quantities and the results'. -/
theorem post_call_val {VB : Nat → Nat} {ν : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst} {m : List (Nat × Q)} {q : Q}
    {tab S2 S5 : List SymE} {ws cws nr : List Nat} {n0 : Nat} {Es : List (Option SymE)}
    (hVB : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (hm : MapOk ν i m)
    (hm0 : ∀ p ∈ m, idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hS5 : S5 = tab ++ resTab ws) (hn0 : tab.length = n0) (hws : ws.length = S2.length - n0) (hnd : ws.Nodup)
    (hndc : cws.Nodup) (hlen : cws.length = nr.length)
    (hnrLo : nr.all (Nat.ble n0) = true) (hder : nr.map (fun r => nth? S2 r) = Es)
    (hEs : ∀ j o, nth? Es j = some o → ∃ E, o = some E ∧ E.eval ν = F64.ofNat (i.get q))
    (hq : ∀ c ∈ cws, i.get q ≤ VB c) :
    let crs := nr.map fun r => (nth? S5 r).getD (.var 0)
    let ν' := resVal ν ws (resF SymE.var S2 n0 ν)
    (∀ v, ∃ k ≤ VB v, Shift.valuation (compactθZ cws crs ws) ν' v = F64.ofNat k) ∧
      MapOk (Shift.valuation (compactθZ cws crs ws) ν') i (m ++ cws.map fun c => (c, q)) := by
  intro crs ν'
  -- a result's value
  have hres : ∀ j r, nth? crs j = some r → r.eval ν' = F64.ofNat (i.get q) := by
    intro j r hr
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
        obtain ⟨E, hE1, -⟩ := hEs j none hE
        cases hE1
      | some E =>
        rw [hS2] at hE
        have hlt := nth?_lt _ _ _ hS2
        rw [hS5, crs_eval hn0 hnd hlo (by omega), hS2, Option.getD_some]
        obtain ⟨E', hE1, hE2⟩ := hEs j (some E) hE
        cases hE1
        exact hE2
  refine ⟨vbOk_post (fun v hv => ?_) (fun j c r hc hr => ?_) (by simp [crs, hlen]),
    mapOk_post (mapOk_iff'.2 fun p hp => ?_) hm0 (fun j c r _ hr => hres j r hr) (by simp [crs, hlen]) hndc⟩
  · have hv' : v ∉ ws := fun h => by rw [List.contains_iff_mem.mpr h] at hv; cases hv
    show ∃ k ≤ VB v, resVal ν ws _ v = _
    rw [resVal_off hv']; exact hVB v
  · exact ⟨i.get q, hq c (nth?_mem_some hc), hres j r hr⟩
  · have hv' : p.1 ∉ ws := fun h => by
      have := (hm0 p hp).2; rw [List.contains_iff_mem.mpr h] at this; cases this
    show resVal ν ws _ p.1 = _
    rw [resVal_off hv']; exact (mapOk_iff'.1 hm) p hp


/-! ## Results at several quantities

A compaction's results need not share one quantity: the decode chains' forward call exports
`u + 1` and `int32(u + 1)` (the end quantity) and `int32(u)` (the offset), `u` the offset variable
(`decQ`). `post_call_valQ` is `post_call_val` with each result at its own quantity (`qs`, the map's
entries `cws.zip qs`). -/

/-- The decode chains' result forms at the offset variable `u` and their quantities. -/
def decQ (u : Nat) (E : SymE) : Option Q :=
  bif decide (E = .bin .add (.var u) litOne) then some .e
  else bif decide (E = .un .int32 (.var u)) then some .o
  else bif decide (E = .un .int32 (.bin .add (.var u) litOne)) then some .e else none

/-- A decode result form's value: the offset `o` or `o + 1`, the instance's end quantity `o + 1`. -/
theorem decQ_eval {ν : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst} {u : Nat} {E : SymE} {q : Q}
    (h : decQ u E = some q) (hu : ν u = F64.ofNat (i.get .o)) (hn : i.get .e = i.get .o + 1)
    (hb : i.get .o + 1 < 2 ^ 31) : E.eval ν = F64.ofNat (i.get q) := by
  unfold decQ at h
  by_cases h1 : E = .bin .add (.var u) litOne
  · subst h1
    rw [decide_eq_true rfl, Bool.cond_true] at h
    cases h
    rw [hn]; exact eval_succ_lit hu (by omega)
  · rw [decide_eq_false h1, Bool.cond_false] at h
    by_cases h2 : E = .un .int32 (.var u)
    · subst h2
      rw [decide_eq_true rfl, Bool.cond_true] at h
      cases h
      exact eval_int32 (a := .var u) hu (by omega)
    · rw [decide_eq_false h2, Bool.cond_false] at h
      by_cases h3 : E = .un .int32 (.bin .add (.var u) litOne)
      · subst h3
        rw [decide_eq_true rfl, Bool.cond_true] at h
        cases h
        rw [hn]; exact eval_int32 (eval_succ_lit hu (by omega)) hb
      · rw [decide_eq_false h3, Bool.cond_false] at h
        cases h

theorem nth?_zip_some {α β : Type} (l1 : List α) : ∀ {l2 : List β} {j : Nat} {a : α} {b : β},
    nth? (l1.zip l2) j = some (a, b) → nth? l1 j = some a ∧ nth? l2 j = some b := by
  induction l1 with
  | nil => intro l2 j a b h; simp [nth?] at h
  | cons x l1 ih =>
    intro l2 j a b h
    cases l2 with
    | nil => simp [nth?] at h
    | cons y l2 =>
      cases j with
      | zero => simp only [List.zip_cons_cons, nth?] at h; cases h; exact ⟨rfl, rfl⟩
      | succ j => simp only [List.zip_cons_cons, nth?] at h; exact ih h

/-- **The generator's results' quantities from their forms**: each result's entry is a decode form
(`decQ`), its quantity the form's. -/
theorem hEs_of_decQ {Es : List (Option SymE)} {u : Nat} {ν : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst}
    (hall : Es.all (fun o => (o.bind (decQ u)).isSome) = true) (hu : ν u = F64.ofNat (i.get .o))
    (hn : i.get .e = i.get .o + 1) (hb : i.get .o + 1 < 2 ^ 31) :
    ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧
      nth? (Es.map fun o => (o.bind (decQ u)).getD .o) j = some q ∧ E.eval ν = F64.ofNat (i.get q) := by
  intro j o ho
  have hs := List.all_eq_true.mp hall o (nth?_mem_some ho)
  cases o with
  | none => cases hs
  | some E =>
    cases hq : decQ u E with
    | none => simp [Option.bind, hq] at hs
    | some q =>
      refine ⟨E, q, rfl, ?_, decQ_eval hq hu hn hb⟩
      rw [nth?_map, ho]; simp [Option.bind, hq]

/-- `mapOk_post` with each result at its own quantity. -/
theorem mapOk_postQ {ws zs : List Nat} {rs : List SymE} {ν' : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst}
    {m : List (Nat × Q)} {qs : List Q} (hm : MapOk ν' i m)
    (hm0 : ∀ p ∈ m, idx? p.1 ws = none ∧ zs.contains p.1 = false)
    (hc : ∀ j c r q, nth? ws j = some c → nth? rs j = some r → nth? qs j = some q → r.eval ν' = F64.ofNat (i.get q))
    (hlen : ws.length ≤ rs.length) (hnd : ws.Nodup) :
    MapOk (Shift.valuation (compactθZ ws rs zs) ν') i (m ++ ws.zip qs) := by
  refine mapOk_iff'.2 fun p hp => ?_
  rcases List.mem_append.1 hp with hp | hp
  · rw [valuation_compactθZ_out (hm0 p hp).1 (hm0 p hp).2]
    exact (mapOk_iff'.1 hm) p hp
  · obtain ⟨c, q⟩ := p
    obtain ⟨j, hj⟩ := nth?_of_mem hp
    obtain ⟨hjc, hjq⟩ := nth?_zip_some _ hj
    have hjl := nth?_lt _ _ _ hjc
    obtain ⟨r, hr⟩ := nth?_some_of_lt (show j < rs.length by omega)
    rw [valuation_compactθZ_res (idx?_nth hnd hjc) hr]
    exact hc j c r q hjc hr hjq

/-- **`post_call_val` with each result at its own quantity** (`qs`, as long as the results): the
canonical valuation in the bound, the call's quantities and the results' (`cws.zip qs`). -/
theorem post_call_valQ {VB : Nat → Nat} {ν : Nat → F64} {i : Host.Ts.Sim.Lin.Cls.Inst} {m : List (Nat × Q)}
    {qs : List Q} {tab S2 S5 : List SymE} {ws cws nr : List Nat} {n0 : Nat} {Es : List (Option SymE)}
    (hVB : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (hm : MapOk ν i m)
    (hm0 : ∀ p ∈ m, idx? p.1 cws = none ∧ ws.contains p.1 = false)
    (hS5 : S5 = tab ++ resTab ws) (hn0 : tab.length = n0) (hws : ws.length = S2.length - n0) (hnd : ws.Nodup)
    (hndc : cws.Nodup) (hlen : cws.length = nr.length) (hlq : qs.length = cws.length)
    (hnrLo : nr.all (Nat.ble n0) = true) (hder : nr.map (fun r => nth? S2 r) = Es)
    (hEs : ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧ nth? qs j = some q ∧ E.eval ν = F64.ofNat (i.get q))
    (hq : ∀ j c q, nth? cws j = some c → nth? qs j = some q → i.get q ≤ VB c) :
    let crs := nr.map fun r => (nth? S5 r).getD (.var 0)
    let ν' := resVal ν ws (resF SymE.var S2 n0 ν)
    (∀ v, ∃ k ≤ VB v, Shift.valuation (compactθZ cws crs ws) ν' v = F64.ofNat k) ∧
      MapOk (Shift.valuation (compactθZ cws crs ws) ν') i (m ++ cws.zip qs) := by
  intro crs ν'
  have hres : ∀ j r q, nth? crs j = some r → nth? qs j = some q → r.eval ν' = F64.ofNat (i.get q) := by
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
        rw [hS5, crs_eval hn0 hnd hlo (by omega), hS2, Option.getD_some]
        obtain ⟨E', q', hE1, hq', hE2⟩ := hEs j (some E) hE
        cases hE1
        rw [hqj] at hq'
        cases hq'
        exact hE2
  refine ⟨vbOk_post (fun v hv => ?_) (fun j c r hc hr => ?_) (by simp [crs, hlen]),
    mapOk_postQ (mapOk_iff'.2 fun p hp => ?_) hm0 (fun j c r q _ hr hqj => hres j r q hr hqj)
      (by simp [crs, hlen]) hndc⟩
  · have hv' : v ∉ ws := fun h => by rw [List.contains_iff_mem.mpr h] at hv; cases hv
    show ∃ k ≤ VB v, resVal ν ws _ v = _
    rw [resVal_off hv']; exact hVB v
  · obtain ⟨q, hqj⟩ := nth?_some_of_lt (show j < qs.length by rw [hlq]; exact nth?_lt _ _ _ hc)
    exact ⟨i.get q, hq j c q hc hqj, hres j r q hr hqj⟩
  · have hv' : p.1 ∉ ws := fun h => by
      have := (hm0 p hp).2; rw [List.contains_iff_mem.mpr h] at this; cases this
    show resVal ν ws _ p.1 = _
    rw [resVal_off hv']; exact (mapOk_iff'.1 hm) p hp

end Host.Ts.Sim.Conv
