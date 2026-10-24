import host.sim.full.VecSet
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf Pending Trace)

/-! # A compiled closure's trace recording

`mlx_closure_apply` on a compiled closure none of whose traces fits the inputs records a trace
(`Ffi.closureApply`): a tracer node per input, a vector of them, a pending trace with a fresh id,
and the `JSCallback` with the pending trace's result vector `.extPtr (4·id + 2) 0`, the tracers'
vector and the payload. `sim_clRecord`: the template's and the target's recordings simulate, the
fresh id's result region sent to the target's (`PendReg.fresh`). The decider
`NativeOkX.clRecord` checks what `NativeOk.clApplyG` checks of the closure and its traces, the
template's search found none, and the room. -/

/-- A recording application: no trace fits. -/
def NativeOkX.clRecord (P : LoadP) (x : NSt) : List Arg → Bool
  | [o, c, v] => slotOk P x o && hdOk x c && vecOk x v && decide (x.next + 2 ≤ P.E) &&
    match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.clo (.compiled _ _ sl ts)), some (.vec xs) =>
      xs.all (fun k => (x.nodes.get k).isSome) && ts.all (traceOkG x sl xs) &&
        decide (x.nnext + xs.length ≤ P.NE) &&
        match Host.Mlx.Ffi.findTrace x sl xs ts (Option Trace) Free.pure with
        | .pure none => true
        | _ => false
    | _, _ => false
  | _ => false

theorem shapesOf_length {x : NSt} : ∀ {l : List Nat} {sh : List (List Dim × Nat)},
    Host.Mlx.Ffi.shapesOf x l = some sh → sh.length = l.length
  | [], sh, h => by simp only [Host.Mlx.Ffi.shapesOf, Option.some.injEq] at h; subst h; rfl
  | i :: l, sh, h => by
    unfold Host.Mlx.Ffi.shapesOf at h
    cases hn : x.nodes.get i with
    | none => rw [hn] at h; cases h
    | some nd =>
      rw [hn, Option.bind_some] at h
      cases hs : Host.Mlx.Ffi.shapesOf x l with
      | none => rw [hs] at h; cases h
      | some t =>
        rw [hs, Option.map_some, Option.some.injEq] at h
        subst h
        simp only [List.length_cons, shapesOf_length hs]

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt}

/-- A new pending trace at a fresh id. -/
theorem MR.bumpPend (hr : MR P NB M n x y) (p p' : Pending) (hp : p' = M.pend p) (hE : x.next + 1 ≤ P.E) :
    MR P NB M n { x with next := x.next + 1, pending := p :: x.pending }
      { y with next := y.next + 1, pending := p' :: y.pending } :=
  { hr with
    hlt := fun h hph => Nat.lt_succ_of_lt (hr.hlt h hph)
    himg := fun h hph => ⟨(hr.himg h hph).1, Nat.lt_succ_of_lt (hr.himg h hph).2⟩
    hfreshR := fun k hk => by
      have := hr.hfreshR (k + 1) (by simp only at hk; omega)
      simpa only [Nat.add_assoc, Nat.add_comm 1 k] using this
    hnext := ⟨by have := hr.hnext; simp only; omega, by have := hr.hnext; simp only; omega⟩
    hroom := ⟨hE, by have := hr.hroom; simp only; omega⟩
    yabsent := fun h hh => hr.yabsent h (by simp only at hh; omega)
    pending := by show p' :: y.pending = (p :: x.pending).map M.pend; rw [hr.pending, hp]; rfl
    hfreshB := fun k hk => by
      have := hr.hfreshB (k + 1) (by simp only at hk; omega)
      simpa only [Nat.add_assoc, Nat.add_comm 1 k] using this }

/-- The tracer nodes of a recording. -/
theorem MR.tracers : ∀ {x y : NSt}, MR P NB M n x y →
    ∀ (i : Nat) (sh : List (List Dim × Nat)), (∀ q ∈ sh, SDs (· < n) q.1 ∧ ∀ d ∈ q.1, DimCanon M d) →
      x.nnext + sh.length ≤ P.NE →
      MR P NB M n (Host.Mlx.Ffi.closureApply.tracers x i sh).1
        (Host.Mlx.Ffi.closureApply.tracers y i (sh.map M.shp)).1 ∧
      (Host.Mlx.Ffi.closureApply.tracers y i (sh.map M.shp)).2 =
        (Host.Mlx.Ffi.closureApply.tracers x i sh).2.map M.node ∧
      (Host.Mlx.Ffi.closureApply.tracers x i sh).1.next = x.next ∧
      (Host.Mlx.Ffi.closureApply.tracers y i (sh.map M.shp)).1.next = y.next ∧
      (Host.Mlx.Ffi.closureApply.tracers x i sh).1.pending = x.pending ∧
      (Host.Mlx.Ffi.closureApply.tracers y i (sh.map M.shp)).1.pending = y.pending
  | _, _, hr, _, [], _, _ => ⟨hr, rfl, rfl, rfl, rfl, rfl⟩
  | x, y, hr, i, (shape, dt) :: rest, hsh, hroom => by
    obtain ⟨hs1, hc1⟩ := hsh _ List.mem_cons_self
    have hNE : x.nnext + 1 ≤ P.NE := by simp only [List.length_cons] at hroom; omega
    have h1 := hr.addNode ⟨.tracer i, [], shape, dt⟩ hNE ⟨trivial, hs1⟩ hc1
    have hn0 : M.node x.nnext = y.nnext := by have := hr.nfresh 0; simpa using this
    have ih := MR.tracers h1 (i + 1) rest (fun q hq => hsh q (List.mem_cons_of_mem _ hq))
      (by simp only [List.length_cons] at hroom ⊢; omega)
    obtain ⟨r1, r2, r3, r4, r5, r6⟩ := ih
    refine ⟨r1, ?_, r3, r4, r5, r6⟩
    show y.nnext :: _ = (x.nnext :: _).map M.node
    rw [List.map_cons, hn0]
    exact congrArg (y.nnext :: ·) r2

end

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **A compiled closure's trace recording**: the fresh id's result region sent to the target's. -/
theorem sim_clRecord (hsym : Host.Mlx.Ffi.symOf name = some .closureApply) {args : List Arg}
    (hok : NativeOkX.clRecord P x args = true)
    (hpr : PendReg M x y) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  unfold NativeOkX.clRecord at hok
  split at hok
  case h_2 => cases hok
  rename_i o c v
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨⟨⟨ho, hc⟩, hv⟩, hE⟩, hm⟩ := hok
  have hfr := hpr.fresh 1 (by have := hr.hroom; omega)
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
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hm
        obtain ⟨⟨⟨hxs, hts⟩, hroomN⟩, hft⟩ := hm
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
        obtain ⟨r, -, e⟩ := findTrace_pure x shl xs ts fun t ht => by
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
        | some _ => cases hft
        | none =>
        simp only [List.map_cons, List.map_nil]
        rw [hmc, hmv]
        unfold Host.Mlx.Ffi.call; rw [hsym]
        unfold Host.Mlx.Ffi.closureApply
        simp only [h1, h2, argNat_nat, Option.bind_some, hco, hyc, h3, h4]
        rw [bind_pureP e, bind_pureP e']
        simp only [Option.map_none, eb, eb']
        -- the tracers
        have hsh := hr.shapesOf_props eb
        have hlen : bb.length = xs.length := shapesOf_length eb
        obtain ⟨t1, t2, t3, t4, t5, t6⟩ := hr.tracers 0 bb hsh (by rw [hlen]; exact hroomN)
        generalize Host.Mlx.Ffi.closureApply.tracers x 0 bb = T at t1 t2 t3 t5 ⊢
        generalize Host.Mlx.Ffi.closureApply.tracers y 0 (bb.map M.shp) = T' at t1 t2 t4 t6 ⊢
        obtain ⟨s1, ts⟩ := T
        obtain ⟨s1', ts'⟩ := T'
        simp only at t1 t2 t3 t4 t5 t6
        subst t2
        -- the tracers' vector
        have hE1 : s1.next + 1 ≤ P.E := by rw [t3]; omega
        have m2 := t1.newObj (.vec ts) hE1 trivial (fun c h => nomatch h) (fun i hi => by simp [objTraces] at hi)
        -- the pending trace
        have hb1 : M.handle (x.next + 1) = y.next + 1 := by
          show (M.big (Int.ofNat (x.next + 1))).toNat = _
          rw [hr.hfreshB 1 (by omega)]; rfl
        have hb0 : M.big (Int.ofNat x.next) = Int.ofNat y.next := by
          have := hr.hfreshB 0 (by omega); simpa using this
        have m3 := m2.bumpPend ⟨s1.next + 1, b, off, sl, ck, xs, ts, none⟩
          ⟨s1'.next + 1, M.a b, off, M.handle sl, M.handle ck, xs.map M.node, ts.map M.node, none⟩
          (by
            rw [t3, t4]
            exact congrArg (fun i => (⟨i, M.a b, off, M.handle sl, M.handle ck, xs.map M.node, ts.map M.node, none⟩ :
              Pending)) hb1.symm)
          (by simp only; omega)
        refine msim_ok' hs hr ?_ m3
        show Ret.callback (M.region cb) [.extPtr (4 * (s1'.next + 1) + 2) 0, .big (Int.ofNat s1'.next), M.arg pl] =
          Ret.callback (M.region cb) [.extPtr (M.region (4 * (s1.next + 1) + 2)) 0, .big (M.big (Int.ofNat s1.next)),
            M.arg pl]
        rw [t3, t4, hfr, hb0]
      | _ => cases hm
    | _ => cases hm

end

end Host.Ts.Sim.G
