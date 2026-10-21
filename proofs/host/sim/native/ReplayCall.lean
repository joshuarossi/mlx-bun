import host.sim.native.Replay
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # `mlx_closure_apply`: finding the trace and replaying it -/

theorem traceFits_go_pure (sl : Bool) : ∀ (a b : List (List Dim × Nat)), ShLits a → ShLits b →
    PureP (Host.Mlx.Ffi.traceFits.go sl a b) (fun _ => True)
  | [], [], _, _ => ⟨_, trivial, fun _ _ => rfl⟩
  | [], _ :: _, _, _ => ⟨_, trivial, fun _ _ => rfl⟩
  | _ :: _, [], _, _ => ⟨_, trivial, fun _ _ => rfl⟩
  | (sa, da) :: ra, (sb, db) :: rb, ha, hb => by
    have ih := traceFits_go_pure sl ra rb (fun q hq => ha q (List.mem_cons_of_mem _ hq))
      (fun q hq => hb q (List.mem_cons_of_mem _ hq))
    unfold Host.Mlx.Ffi.traceFits.go
    exact PureP.cond _ (PureP.pure trivial) (PureP.cond _ ih
      (PureP.bind (allEq_pure sa sb (ha _ (List.mem_cons_self ..)) (hb _ (List.mem_cons_self ..))) fun e _ =>
        PureP.cond e ih (PureP.pure trivial)))

theorem traceFits_pure (s : NSt) (sl : Bool) (t : Trace) (xs : List Nat)
    (h1 : ∀ k ∈ t.ins, litNode s k = true) (h2 : ∀ k ∈ xs, litNode s k = true) :
    PureP (Host.Mlx.Ffi.traceFits s sl t xs) (fun _ => True) := by
  obtain ⟨a, ea, ha⟩ := shapesOf_lit h1
  obtain ⟨b, eb, hb⟩ := shapesOf_lit h2
  unfold Host.Mlx.Ffi.traceFits
  rw [ea, eb]
  exact traceFits_go_pure sl a b ha hb

theorem findTrace_pure (s : NSt) (sl : Bool) (xs : List Nat) :
    ∀ (ts : List Trace), (∀ t ∈ ts, PureP (Host.Mlx.Ffi.traceFits s sl t xs) (fun _ => True)) →
      PureP (Host.Mlx.Ffi.findTrace s sl xs ts) (fun r => ∀ t, r = some t → t ∈ ts)
  | [], _ => ⟨none, (fun _ h => by cases h), fun _ _ => rfl⟩
  | t :: ts, h => PureP.bind (h t (List.mem_cons_self ..)) fun b _ =>
      PureP.cond b (PureP.pure fun t' e => by cases e; exact List.mem_cons_self ..)
        (PureP.mono (findTrace_pure s sl xs ts fun t' ht' => h t' (List.mem_cons_of_mem _ ht'))
          fun r hr t' e => List.mem_cons_of_mem _ (hr t' e))

theorem findTrace_congr {s s' : NSt} {sl : Bool} {xs xs' : List Nat} :
    ∀ (ts : List Trace), (∀ t ∈ ts, Host.Mlx.Ffi.traceFits s' sl t xs' = Host.Mlx.Ffi.traceFits s sl t xs) →
      Host.Mlx.Ffi.findTrace s' sl xs' ts = Host.Mlx.Ffi.findTrace s sl xs ts
  | [], _ => rfl
  | t :: ts, h => by
    simp only [Host.Mlx.Ffi.findTrace, h t (List.mem_cons_self ..),
      findTrace_congr ts fun t' ht' => h t' (List.mem_cons_of_mem _ ht')]

/-- An apply the replay covers. -/
def NativeOk.clApply (P : LoadP) (x : NSt) : List Arg → Bool
  | [o, c, v] => slotOk P x o && hdOk x c && vecOk x v && decide (x.next + 1 ≤ P.E) &&
    match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.clo (.compiled _ _ sl ts)), some (.vec xs) =>
      xs.all (litNode x) && ts.all (traceOk P x) &&
        match Host.Mlx.Ffi.findTrace x sl xs ts (Option Trace) Free.pure with
        | .pure (some _) => true
        | _ => false
    | _, _ => false
  | _ => false

section
variable {P : LoadP} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P M S.tab.length x y)
include hs hr

theorem sim_closureApply (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.closureApply) {args : List Arg}
    (hok : NativeOk.clApply P x args = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  unfold NativeOk.clApply at hok
  split at hok
  case h_2 => cases hok
  rename_i o c v
  rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hok
  obtain ⟨⟨⟨⟨ho, hc⟩, hv⟩, hE⟩, hm⟩ := hok
  have hE' : x.next + 1 ≤ P.E := of_decide_eq_true hE
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  obtain ⟨ck, rfl, hpc, hmc⟩ := hr.hdOk_spec hc
  obtain ⟨kv, xs, rfl, hmv, hpv, h3, h4⟩ := hr.vecArg hv
  rw [argNat_nat, Option.bind_some, argNat_nat, Option.bind_some, h3] at hm
  cases hco : x.obj? ck with
  | none => rw [hco] at hm; cases hm
  | some oc =>
    rw [hco] at hm
    cases oc with
    | clo cl =>
      cases cl with
      | compiled cb pl shl ts =>
        simp only at hm
        rw [Bool.and_eq_true, Bool.and_eq_true] at hm
        obtain ⟨⟨hxs, hts⟩, hft⟩ := hm
        have hxs' : ∀ k ∈ xs, litNode x k = true := fun k hk => List.all_eq_true.mp hxs k hk
        have hts' : ∀ t ∈ ts, traceOk P x t = true := fun t ht => List.all_eq_true.mp hts t ht
        -- trace facts
        have tOk : ∀ t ∈ ts, (∀ a ∈ t.ins, a < P.NL ∧ litNode x a = true) ∧ (∀ a ∈ t.outs, a < P.NL) ∧
            (∀ a ∈ t.order, rnodeOk P x a = true) ∧ x.nnext + t.order.length ≤ P.NE := by
          intro t ht
          have h := hts' t ht
          unfold traceOk at h
          rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at h
          obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := h
          refine ⟨fun a ha => ?_, fun a ha => of_decide_eq_true (List.all_eq_true.mp h2 a ha),
            fun a ha => List.all_eq_true.mp h3 a ha, of_decide_eq_true h4⟩
          have := List.all_eq_true.mp h1 a ha
          rw [Bool.and_eq_true] at this
          exact ⟨of_decide_eq_true this.1, this.2⟩
        have hidl : ∀ l : List Nat, (∀ a ∈ l, a < P.NL) → l.map M.node = l := fun l hl => by
          conv => rhs; rw [← List.map_id l]
          exact List.map_congr_left fun a ha => hr.nid a (hl a ha)
        have htr : ts.map M.trace = ts := by
          conv => rhs; rw [← List.map_id ts]
          refine List.map_congr_left fun t ht => ?_
          obtain ⟨ti, to, tr⟩ := t
          have h := tOk _ ht
          simp only [Map.trace, id]
          rw [hidl ti (fun a ha => (h.1 a ha).1), hidl to h.2.1,
            hidl tr (fun a ha => by
              have := h.2.2.1 a ha; unfold rnodeOk at this; rw [Bool.and_eq_true] at this
              exact of_decide_eq_true this.1)]
        have hyc : y.obj? (M.handle ck) = some (.clo (.compiled (M.region cb) (M.arg pl) shl ts)) := by
          rw [hr.obj? hpc, hco]; simp only [Option.map_some, Map.nobj, Map.clo, htr]
        -- traces fit identically
        have hfit : ∀ t ∈ ts, Host.Mlx.Ffi.traceFits y shl t (xs.map M.node) = Host.Mlx.Ffi.traceFits x shl t xs := by
          intro t ht
          obtain ⟨a, ea, ha⟩ := shapesOf_lit (fun k hk => (tOk t ht).1 k hk |>.2)
          obtain ⟨bb, eb, hb⟩ := shapesOf_lit hxs'
          have ea' : Host.Mlx.Ffi.shapesOf y t.ins = some a := by
            have := hr.shapesOf_map ea
            rwa [hidl t.ins (fun k hk => ((tOk t ht).1 k hk).1), shp_lits M ha] at this
          have eb' : Host.Mlx.Ffi.shapesOf y (xs.map M.node) = some bb := by
            rw [hr.shapesOf_map eb, shp_lits M hb]
          unfold Host.Mlx.Ffi.traceFits
          rw [ea, eb, ea', eb']
        obtain ⟨r, hrm, e⟩ := findTrace_pure x shl xs ts fun t ht =>
          traceFits_pure x shl t xs (fun k hk => ((tOk t ht).1 k hk).2) hxs'
        have e' : ∀ γ (k : Option Trace → Free γ),
            Host.Mlx.Ffi.findTrace y shl (xs.map M.node) ts γ k = k r := by
          rw [findTrace_congr ts hfit]; exact e
        have hrt : ∃ t, r = some t := by
          rw [e] at hft
          cases r with
          | none => cases hft
          | some t => exact ⟨t, rfl⟩
        obtain ⟨t, rfl⟩ := hrt
        have hts1 := hrm t rfl
        obtain ⟨tIns, tOuts, tOrd, tRoom⟩ := tOk t hts1
        simp only [List.map_cons, List.map_nil]
        rw [hmc, hmv]
        unfold Host.Mlx.Ffi.call; rw [hsym]
        unfold Host.Mlx.Ffi.closureApply
        simp only [h1, h2, argNat_nat, Option.bind_some, hco, hyc, h3, h4]
        rw [bind_pureP e, bind_pureP e']
        simp only
        unfold Host.Mlx.Ffi.applyDone Host.Mlx.Ffi.replay
        have hzip : t.ins.zip (xs.map M.node) = M.subst (t.ins.zip xs) := by
          simp only [Map.subst, List.zip_map_right]; rfl
        have hzm : ∀ p ∈ t.ins.zip xs, p.1 < P.NL ∧ litNode x p.2 = true := by
          intro p hp
          obtain ⟨a, k⟩ := p
          exact ⟨(tIns a (List.of_mem_zip hp).1).1, hxs' k (List.of_mem_zip hp).2⟩
        obtain ⟨rr, rr', er, er', hrel⟩ := MR.replayOrder ck t.order (t.ins.zip xs) hr tOrd hzm tRoom
        rw [hzip, bind_pureP er, bind_pureP er']
        cases rr with
        | none =>
          cases rr' with
          | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
          | some _ => exact hrel.elim
        | some q =>
          cases rr' with
          | none => exact hrel.elim
          | some q' =>
            obtain ⟨x', m1⟩ := q
            obtain ⟨y', m1'⟩ := q'
            obtain ⟨hr', rfl, hm1, hnx, hax, hox⟩ := hrel
            simp only
            have houts : t.outs.map (Host.Mlx.Ffi.substOf (M.subst m1)) =
                (t.outs.map (Host.Mlx.Ffi.substOf m1)).map M.node := by
              rw [List.map_map]
              exact List.map_congr_left fun a ha =>
                substOf_map M hr.nid m1 (fun p hp => (hm1 p hp).1) a (tOuts a ha)
            rw [houts]
            have hsl' : sl = 0 ∨ PH x' sl := by
              rcases hsl with h | h
              · exact .inl h
              · right; unfold PH; rw [hax, hox]; exact h
            obtain ⟨hh, x'', hh', y'', e3, e4, hr2, hb⟩ :=
              hr'.setVec_map hsl' (by rw [hnx]; exact hE') (t.outs.map (Host.Mlx.Ffi.substOf m1))
            rw [bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl),
              bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl)]
            simp only
            rw [e3, e4]
            exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr2
      | _ => cases hm
    | _ => cases hm
end

end Host.Ts.Sim
