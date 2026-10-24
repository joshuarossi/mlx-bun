import host.sim.native.ReplayCall
import host.sim.native.gen.Replay
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # `mlx_closure_apply` for any prefill history

The target's closure holds the imaged traces (`M.trace`): the target finds the image of
the trace the template finds, since a shapeless match compares ranks and dtypes only, and a
shaped one literal shapes; then it replays the imaged trace (`MR.replayOrder`). Recorded
shapes of a shapeless trace may be symbolic (`traceOkG`, `rchk`). -/

theorem traceFits_go_map (M : Map) : ∀ (a b : List (List Dim × Nat)),
    Host.Mlx.Ffi.traceFits.go true (a.map M.shp) (b.map M.shp) = Host.Mlx.Ffi.traceFits.go true a b
  | [], [] => rfl
  | [], _ :: _ => rfl
  | _ :: _, [] => rfl
  | (sa, da) :: ra, (sb, db) :: rb => by
    have ih := traceFits_go_map M ra rb
    simp only [List.map_cons, Map.shp]
    unfold Host.Mlx.Ffi.traceFits.go
    simp only [Map.dims, Native.len_map, Bool.cond_true]
    rw [ih]

theorem traceFits_go_pureT : ∀ (a b : List (List Dim × Nat)),
    PureP (Host.Mlx.Ffi.traceFits.go true a b) (fun _ => True)
  | [], [] => ⟨_, trivial, fun _ _ => rfl⟩
  | [], _ :: _ => ⟨_, trivial, fun _ _ => rfl⟩
  | _ :: _, [] => ⟨_, trivial, fun _ _ => rfl⟩
  | (sa, da) :: ra, (sb, db) :: rb => by
    unfold Host.Mlx.Ffi.traceFits.go
    simp only [Bool.cond_true]
    exact PureP.cond _ (PureP.pure trivial) (traceFits_go_pureT ra rb)

theorem traceFits_map (M : Map) {x y : NSt} {sl : Bool} {t : Trace} {xs : List Nat}
    {a b : List (List Dim × Nat)} (ha : Host.Mlx.Ffi.shapesOf x t.ins = some a) (hb : Host.Mlx.Ffi.shapesOf x xs = some b)
    (ha' : Host.Mlx.Ffi.shapesOf y (t.ins.map M.node) = some (a.map M.shp))
    (hb' : Host.Mlx.Ffi.shapesOf y (xs.map M.node) = some (b.map M.shp)) (hl : sl = true ∨ (ShLits a ∧ ShLits b)) :
    Host.Mlx.Ffi.traceFits y sl (M.trace t) (xs.map M.node) = Host.Mlx.Ffi.traceFits x sl t xs := by
  unfold Host.Mlx.Ffi.traceFits
  rw [show (M.trace t).ins = t.ins.map M.node from rfl, ha, hb, ha', hb']
  simp only
  rcases hl with rfl | ⟨h1, h2⟩
  · exact traceFits_go_map M a b
  · rw [shp_lits M h1, shp_lits M h2]

theorem traceFits_pureG {x : NSt} {sl : Bool} {t : Trace} {xs : List Nat} {a b : List (List Dim × Nat)}
    (ha : Host.Mlx.Ffi.shapesOf x t.ins = some a) (hb : Host.Mlx.Ffi.shapesOf x xs = some b)
    (hl : sl = true ∨ (ShLits a ∧ ShLits b)) : PureP (Host.Mlx.Ffi.traceFits x sl t xs) (fun _ => True) := by
  unfold Host.Mlx.Ffi.traceFits
  rw [ha, hb]
  rcases hl with rfl | ⟨h1, h2⟩
  · exact traceFits_go_pureT a b
  · exact traceFits_go_pure _ a b h1 h2

/-- Mapping the traces maps the trace found. -/
theorem findTrace_map {s s' : NSt} {sl : Bool} {xs xs' : List Nat} (f : Trace → Trace) :
    ∀ (ts : List Trace), (∀ t ∈ ts, Host.Mlx.Ffi.traceFits s' sl (f t) xs' = Host.Mlx.Ffi.traceFits s sl t xs) →
      ∀ γ (k : Option Trace → Free γ),
        Host.Mlx.Ffi.findTrace s' sl xs' (ts.map f) γ k = Host.Mlx.Ffi.findTrace s sl xs ts γ (fun r => k (r.map f))
  | [], _, _, _ => rfl
  | t :: ts, h, γ, k => by
    have ih := findTrace_map f ts fun t' ht' => h t' (List.mem_cons_of_mem _ ht')
    show Host.Mlx.Ffi.traceFits s' sl (f t) xs' γ _ = Host.Mlx.Ffi.traceFits s sl t xs γ _
    rw [h t (List.mem_cons_self ..)]
    congr 1
    funext m
    cases m
    · exact ih γ k
    · rfl

theorem shapesOf_some {x : NSt} : ∀ {l : List Nat}, (∀ b ∈ l, PN x b) → ∃ sh, Host.Mlx.Ffi.shapesOf x l = some sh
  | [], _ => ⟨[], rfl⟩
  | b :: l, h => by
    obtain ⟨nd, hn⟩ := Option.isSome_iff_exists.mp (h b (List.mem_cons_self ..))
    obtain ⟨sh, e⟩ := shapesOf_some (fun c hc => h c (List.mem_cons_of_mem _ hc))
    exact ⟨(nd.shape, nd.dtype) :: sh, by simp only [Host.Mlx.Ffi.shapesOf, hn, e]; rfl⟩

/-- A trace the general replay may look up: present tracers and outputs; literal tracer and
input shapes unless the closure is shapeless. -/
def traceOkG (x : NSt) (sl : Bool) (xs : List Nat) (t : Trace) : Bool :=
  t.ins.all (fun a => (x.nodes.get a).isSome) && t.outs.all (fun a => (x.nodes.get a).isSome) &&
    (sl || (t.ins.all (litNode x) && xs.all (litNode x)))

/-- **An apply the general replay covers**: the trace found replays under `rchk`. -/
def NativeOk.clApplyG (P : LoadP) (x : NSt) : List Arg → Bool
  | [o, c, v] => slotOk P x o && hdOk x c && vecOk x v && decide (x.next + 1 ≤ P.E) &&
    match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj?, Host.Mlx.Ffi.argNat c with
    | some (.clo (.compiled _ _ sl ts)), some (.vec xs), some ck =>
      xs.all (fun k => (x.nodes.get k).isSome) && ts.all (traceOkG x sl xs) &&
        match Host.Mlx.Ffi.findTrace x sl xs ts (Option Trace) Free.pure with
        | .pure (some t) => rchk P.NL ck x (t.ins.zip xs) t.order && decide (x.nnext + t.order.length ≤ P.NE)
        | _ => false
    | _, _, _ => false
  | _ => false

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

theorem sim_closureApplyG (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.closureApply) {args : List Arg}
    (hok : NativeOk.clApplyG P x args = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  unfold NativeOk.clApplyG at hok
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
        have hxs' : ∀ k ∈ xs, PN x k := fun k hk => List.all_eq_true.mp hxs k hk
        have tOk : ∀ t ∈ ts, (∀ a ∈ t.ins, PN x a) ∧ (∀ a ∈ t.outs, PN x a) ∧
            (shl = true ∨ ((∀ a ∈ t.ins, litNode x a = true) ∧ ∀ a ∈ xs, litNode x a = true)) := by
          intro t ht
          have h := List.all_eq_true.mp hts t ht
          unfold traceOkG at h
          simp only [Bool.and_eq_true, Bool.or_eq_true, List.all_eq_true] at h
          exact ⟨h.1.1, h.1.2, h.2⟩
        have hyc : y.obj? (M.handle ck) = some (.clo (.compiled (M.region cb) (M.arg pl) shl (ts.map M.trace))) := by
          rw [hr.obj? hpc, hco]; rfl
        obtain ⟨bb, eb⟩ := shapesOf_some hxs'
        have eb' := hr.shapesOf_map eb
        have hfit : ∀ t ∈ ts, Host.Mlx.Ffi.traceFits y shl (M.trace t) (xs.map M.node) =
            Host.Mlx.Ffi.traceFits x shl t xs := by
          intro t ht
          obtain ⟨tI, -, tL⟩ := tOk t ht
          obtain ⟨a, ea⟩ := shapesOf_some tI
          refine traceFits_map M ea eb (hr.shapesOf_map ea) eb' ?_
          rcases tL with h | ⟨l1, l2⟩
          · exact .inl h
          · right
            obtain ⟨a', ea', la⟩ := shapesOf_lit l1
            obtain ⟨b', eb'', lb⟩ := shapesOf_lit l2
            rw [ea] at ea'; rw [eb] at eb''
            cases ea'; cases eb''
            exact ⟨la, lb⟩
        obtain ⟨r, hrm, e⟩ := findTrace_pure x shl xs ts fun t ht => by
          obtain ⟨tI, -, tL⟩ := tOk t ht
          obtain ⟨a, ea⟩ := shapesOf_some tI
          refine traceFits_pureG ea eb ?_
          rcases tL with h | ⟨l1, l2⟩
          · exact .inl h
          · right
            obtain ⟨a', ea', la⟩ := shapesOf_lit l1
            obtain ⟨b', eb'', lb⟩ := shapesOf_lit l2
            rw [ea] at ea'; rw [eb] at eb''
            cases ea'; cases eb''
            exact ⟨la, lb⟩
        have e' : ∀ γ (k : Option Trace → Free γ),
            Host.Mlx.Ffi.findTrace y shl (xs.map M.node) (ts.map M.trace) γ k = k (r.map M.trace) := by
          intro γ k
          rw [findTrace_map M.trace ts hfit, e]
        rw [e] at hft
        cases r with
        | none => cases hft
        | some t =>
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hft
        obtain ⟨hck, tRoom⟩ := hft
        have hts1 := hrm t rfl
        obtain ⟨tIns, tOuts, -⟩ := tOk t hts1
        simp only [List.map_cons, List.map_nil]
        rw [hmc, hmv]
        unfold Host.Mlx.Ffi.call; rw [hsym]
        unfold Host.Mlx.Ffi.closureApply
        simp only [h1, h2, argNat_nat, Option.bind_some, hco, hyc, h3, h4]
        rw [bind_pureP e, bind_pureP e']
        simp only [Option.map_some]
        unfold Host.Mlx.Ffi.applyDone Host.Mlx.Ffi.replay
        have hzip : (M.trace t).ins.zip (xs.map M.node) = substN M (t.ins.zip xs) := by
          show (t.ins.map M.node).zip (xs.map M.node) = _
          rw [List.zip_map]; rfl
        have hzm : ∀ p ∈ t.ins.zip xs, PN x p.1 ∧ PN x p.2 := by
          intro p hp
          obtain ⟨a, k⟩ := p
          exact ⟨tIns a (List.of_mem_zip hp).1, hxs' k (List.of_mem_zip hp).2⟩
        obtain ⟨rr, rr', er, er', hrel⟩ := MR.replayOrder ck t.order (t.ins.zip xs) hr hck hzm tRoom
        rw [hzip, show (M.trace t).order = t.order.map M.node from rfl, bind_pureP er, bind_pureP er']
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
            obtain ⟨hr', rfl, hm1, hg, hnx, hax, hox⟩ := hrel
            simp only
            have houts : (M.trace t).outs.map (Host.Mlx.Ffi.substOf (substN M m1)) =
                (t.outs.map (Host.Mlx.Ffi.substOf m1)).map M.node := by
              show (t.outs.map M.node).map _ = _
              rw [List.map_map, List.map_map]
              exact List.map_congr_left fun a ha =>
                substOf_substN M (Q := PN x') (fun u v hu hv => hr'.ninj u v hu hv) m1 (fun p hp => (hm1 p hp).1) a
                  (hr.pn_grow hg (tOuts a ha))
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

end Host.Ts.Sim.G
