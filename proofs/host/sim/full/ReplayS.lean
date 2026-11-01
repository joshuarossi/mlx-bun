import host.sim.full.BridgeStepD

/-! # Compiled-closure applies whose trace lookup asks the server

A closure that is not shapeless finds its trace by comparing input shapes. Over dimensions that are number references
the comparison is a test of the server (a row count written two ways, `(0 + n) - 0` and a longer form), so
`findTrace` is not pure and `traceOkG`, `clApplyV` do not apply. With every compared dimension valued, the target's
tests have the template's answers: `allEq_simV`, `traceFits_simV`, `findTrace_simV`. `sim_closureApplyS`: the apply,
every trace replaying under `rwalk` (`traceOkS`), the numeric premise (`cloSmallS`) saying the comparison's and
replays' references are small and the lookup finds a trace. `okCallFXS` adds these applies to `okCallFXD`,
`smallFXS` the premise; `fullCallSimXS` is their simulation. -/

namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out Trace)
open Host.Ts.Sim.BufSim (Lawful)

/-! ## Valued comparisons -/

section
variable {ν : Nat → F64}

theorem allEq_simV : ∀ {M : Map} {S : SSrv} {C : CSrv} {xs ys : List Dim} {kxs kys : List Nat},
    Srv M ν S C → DVSs M C S xs kxs → DVSs M C S ys kys → Bd kxs → Bd kys →
    MSim (BPost M ν S C (decide (kxs = kys))) S C (Host.Mlx.Ffi.allEq xs ys) (Host.Mlx.Ffi.allEq (M.dims xs) (M.dims ys))
  | _, _, _, [], [], [], [], hs, _, _, _, _ => MSim.pure ⟨rfl, rfl, GrowL.refl hs⟩
  | _, _, _, [], _ :: _, [], _ :: _, hs, _, _, _, _ => MSim.pure ⟨rfl, by simp, GrowL.refl hs⟩
  | _, _, _, _ :: _, [], _ :: _, [], hs, _, _, _, _ => MSim.pure ⟨rfl, by simp, GrowL.refl hs⟩
  | M, S, C, x :: xs, y :: ys, kx :: kxs, ky :: kys, hs, hx, hy, bx, by_ => by
    obtain ⟨hx, hxs⟩ := hx
    obtain ⟨hy, hys⟩ := hy
    rw [Bd.cons] at bx by_
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.dEq x y) fun e =>
        bif e then Host.Mlx.Ffi.allEq xs ys else Host.Ts.M.pure false)
      (Host.Ts.M.bind (Host.Mlx.Ffi.dEq (M.dim x) (M.dim y)) fun e =>
        bif e then Host.Mlx.Ffi.allEq (M.dims xs) (M.dims ys) else Host.Ts.M.pure false)
    refine MSim.bind (dEq_simV hs hx.1 hy.1 (by omega) (by omega)) fun M1 S1 C1 e e' h => ?_
    obtain ⟨h1, h2, hg⟩ := h
    subst h1 h2
    by_cases hk : kx = ky
    · simp only [decide_eq_true hk, Bool.cond_true]
      obtain ⟨hxs', exs⟩ := DVSs.lift hg hxs
      obtain ⟨hys', eys⟩ := DVSs.lift hg hys
      rw [← exs, ← eys]
      refine MSim.mono (allEq_simV hg.grow.srv hxs' hys' bx.2 by_.2) fun M2 S2 C2 r r' h => ?_
      obtain ⟨h1, h2, hg2⟩ := h
      refine ⟨h1, ?_, hg.trans hg2⟩
      rw [h2]; subst hk; simp
    · simp only [decide_eq_false hk, Bool.cond_false]
      exact MSim.pure ⟨rfl, by simp [hk], hg⟩
  | _, _, _, [], [], _ :: _, _, _, hx, _, _, _ => hx.elim
  | _, _, _, [], [], [], _ :: _, _, _, hy, _, _ => hy.elim
  | _, _, _, _ :: _, _, [], _, _, hx, _, _, _ => hx.elim
  | _, _, _, [], _ :: _, _, [], _, _, hy, _, _ => hy.elim
  | _, _, _, [], _ :: _, _ :: _, _, _, hx, _, _, _ => hx.elim

/-- Shapes whose dimensions have small values. -/
def ShV (M : Map) (C : CSrv) (S : SSrv) (a : List (List Dim × Nat)) : Prop :=
  ∀ q ∈ a, ∃ ks, DVSs M C S q.1 ks ∧ Bd ks

theorem ShV.lift {M M' : Map} {S S' : SSrv} {C C' : CSrv} (hg : GrowL M ν S C M' S' C') :
    ∀ {a : List (List Dim × Nat)}, ShV M C S a → ShV M' C' S' a ∧ a.map M'.shp = a.map M.shp
  | [], _ => ⟨(fun _ h => by cases h), rfl⟩
  | q :: a, h => by
    obtain ⟨ks, hk, bk⟩ := h q List.mem_cons_self
    obtain ⟨h1, e1⟩ := DVSs.lift hg hk
    obtain ⟨h2, e2⟩ := ShV.lift hg (a := a) fun q' hq' => h q' (List.mem_cons_of_mem _ hq')
    refine ⟨fun q' hq' => ?_, ?_⟩
    · rcases List.mem_cons.mp hq' with rfl | hq'
      · exact ⟨ks, h1, bk⟩
      · exact h2 q' hq'
    · simp only [List.map_cons, e2]
      show (M'.dims q.1, q.2) :: _ = (M.dims q.1, q.2) :: _
      rw [e1]

/-- Both sides' comparisons agree. -/
def BSame (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) : Map → SSrv → CSrv → Bool → Bool → Prop :=
  fun M' S' C' r r' => r' = r ∧ GrowL M ν S C M' S' C'

theorem lenL_map {α β : Type} (f : α → β) : ∀ (l : List α) (n : Nat), lenL (l.map f) n = lenL l n
  | [], _ => rfl
  | _ :: l, n => lenL_map f l (Nat.succ n)

theorem go_cons (sa : List Dim) (da : Nat) (ra : List (List Dim × Nat)) (sb : List Dim) (db : Nat)
    (rb : List (List Dim × Nat)) :
    Host.Mlx.Ffi.traceFits.go false ((sa, da) :: ra) ((sb, db) :: rb) =
      bif !(Nat.beq da db) || !(Nat.beq (len sa) (len sb)) then Host.Ts.M.pure false
      else Host.Ts.M.bind (Host.Mlx.Ffi.allEq sa sb) fun e =>
        bif e then Host.Mlx.Ffi.traceFits.go false ra rb else Host.Ts.M.pure false := rfl

theorem go_simV : ∀ {M : Map} {S : SSrv} {C : CSrv} {a b : List (List Dim × Nat)}, Srv M ν S C → ShV M C S a → ShV M C S b →
    MSim (BSame M ν S C) S C (Host.Mlx.Ffi.traceFits.go false a b)
      (Host.Mlx.Ffi.traceFits.go false (a.map M.shp) (b.map M.shp))
  | _, _, _, [], [], hs, _, _ => MSim.pure ⟨rfl, GrowL.refl hs⟩
  | _, _, _, [], _ :: _, hs, _, _ => MSim.pure ⟨rfl, GrowL.refl hs⟩
  | _, _, _, _ :: _, [], hs, _, _ => MSim.pure ⟨rfl, GrowL.refl hs⟩
  | M, S, C, (sa, da) :: ra, (sb, db) :: rb, hs, ha, hb => by
    obtain ⟨ka, hka, bka⟩ := ha (sa, da) List.mem_cons_self
    obtain ⟨kb, hkb, bkb⟩ := hb (sb, db) List.mem_cons_self
    have hra : ShV M C S ra := fun q hq => ha q (List.mem_cons_of_mem _ hq)
    have hrb : ShV M C S rb := fun q hq => hb q (List.mem_cons_of_mem _ hq)
    show MSim _ S C (Host.Mlx.Ffi.traceFits.go false ((sa, da) :: ra) ((sb, db) :: rb))
      (Host.Mlx.Ffi.traceFits.go false ((M.dims sa, da) :: ra.map M.shp) ((M.dims sb, db) :: rb.map M.shp))
    rw [go_cons, go_cons]
    have ela : len (M.dims sa) = len sa := lenL_map _ sa 0
    have elb : len (M.dims sb) = len sb := lenL_map _ sb 0
    rw [ela, elb]
    cases hc : (!(Nat.beq da db) || !(Nat.beq (len sa) (len sb)))
    · simp only [Bool.cond_false]
      refine MSim.bind (allEq_simV hs hka hkb bka bkb) fun M1 S1 C1 e e' h => ?_
      obtain ⟨h1, -, hg⟩ := h
      subst h1
      cases e'
      · exact MSim.pure ⟨rfl, hg⟩
      · simp only [Bool.cond_true]
        obtain ⟨la, ea⟩ := ShV.lift hg hra
        obtain ⟨lb, eb⟩ := ShV.lift hg hrb
        rw [← ea, ← eb]
        exact MSim.mono (go_simV hg.grow.srv la lb) fun _ _ _ _ _ h => ⟨h.1, hg.trans h.2⟩
    · exact MSim.pure ⟨rfl, GrowL.refl hs⟩

theorem traceFits_simV {M : Map} {S : SSrv} {C : CSrv} {x y : NSt} {t t' : Trace} {xs xs' : List Nat}
    {a b : List (List Dim × Nat)} (hs : Srv M ν S C) (ha : Host.Mlx.Ffi.shapesOf x t.ins = some a)
    (hb : Host.Mlx.Ffi.shapesOf x xs = some b) (ha' : Host.Mlx.Ffi.shapesOf y t'.ins = some (a.map M.shp))
    (hb' : Host.Mlx.Ffi.shapesOf y xs' = some (b.map M.shp)) (hav : ShV M C S a) (hbv : ShV M C S b) :
    MSim (BSame M ν S C) S C (Host.Mlx.Ffi.traceFits x false t xs) (Host.Mlx.Ffi.traceFits y false t' xs') := by
  unfold Host.Mlx.Ffi.traceFits
  rw [ha, hb, ha', hb']
  exact go_simV hs hav hbv

theorem findTrace_simV {M0 : Map} {S0 : SSrv} {C0 : CSrv} {x y : NSt} {xs xs' : List Nat}
    {b : List (List Dim × Nat)} (hb : Host.Mlx.Ffi.shapesOf x xs = some b)
    (hb' : Host.Mlx.Ffi.shapesOf y xs' = some (b.map M0.shp)) (hbv : ShV M0 C0 S0 b) :
    ∀ (ts : List Trace) {M : Map} {S : SSrv} {C : CSrv}, GrowL M0 ν S0 C0 M S C →
      (∀ t ∈ ts, ∃ a, Host.Mlx.Ffi.shapesOf x t.ins = some a ∧
        Host.Mlx.Ffi.shapesOf y (t.ins.map M0.node) = some (a.map M0.shp) ∧ ShV M0 C0 S0 a) →
      MSim (fun M' S' C' r r' => r' = r.map M0.trace ∧ GrowL M0 ν S0 C0 M' S' C' ∧ ∀ t, r = some t → t ∈ ts) S C
        (Host.Mlx.Ffi.findTrace x false xs ts) (Host.Mlx.Ffi.findTrace y false xs' (ts.map M0.trace))
  | [], _, _, _, hg, _ => MSim.pure ⟨rfl, hg, fun _ h => by cases h⟩
  | t :: ts, M, S, C, hg, h => by
    obtain ⟨a, ea, ea', hav⟩ := h t List.mem_cons_self
    obtain ⟨la, ela⟩ := ShV.lift hg hav
    obtain ⟨lb, elb⟩ := ShV.lift hg hbv
    have hf : MSim (BSame M ν S C) S C (Host.Mlx.Ffi.traceFits x false t xs)
        (Host.Mlx.Ffi.traceFits y false (M0.trace t) xs') :=
      traceFits_simV hg.grow.srv ea hb (by show Host.Mlx.Ffi.shapesOf y (t.ins.map M0.node) = _; rw [ea', ela])
        (by rw [hb', elb]) la lb
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.traceFits x false t xs) fun m =>
        bif m then Host.Ts.M.pure (some t) else Host.Mlx.Ffi.findTrace x false xs ts)
      (Host.Ts.M.bind (Host.Mlx.Ffi.traceFits y false (M0.trace t) xs') fun m =>
        bif m then Host.Ts.M.pure (some (M0.trace t)) else Host.Mlx.Ffi.findTrace y false xs' (ts.map M0.trace))
    refine MSim.bind hf fun M1 S1 C1 e e' h1 => ?_
    obtain ⟨rfl, hg1⟩ := h1
    cases e'
    · simp only [Bool.cond_false]
      refine MSim.mono (findTrace_simV hb hb' hbv ts (hg.trans hg1) fun t' ht' => h t' (List.mem_cons_of_mem _ ht')) ?_
      exact fun _ _ _ _ _ q => ⟨q.1, q.2.1, fun t' e => List.mem_cons_of_mem _ (q.2.2 t' e)⟩
    · simp only [Bool.cond_true]
      exact MSim.pure ⟨rfl, hg.trans hg1, fun t' e => by cases e; exact List.mem_cons_self⟩

end

/-! ## The acceptance -/

/-- A trace the lookup may find: valued tracer inputs, present outputs, a replay `rwalk` accepts. -/
def traceOkS (P : LoadP) (x : NSt) (xs : List Nat) (t : Trace) : Bool :=
  t.ins.all (valuedN x) && t.outs.all (fun a => (x.nodes.get a).isSome) &&
    (rwalk x x.nnext (t.ins.zip xs) t.order).isSome && t.order.all (fun a => decide (a < P.NL)) &&
    decide (x.nnext + t.order.length ≤ P.NE)

/-- **An apply whose lookup compares valued shapes.** -/
def NativeOkX.clApplyS (P : LoadP) (x : NSt) : List Arg → Bool
  | [o, c, v] => slotOk P x o && hdOk x c && vecOk x v && decide (x.next + 1 ≤ P.E) &&
    match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj?, Host.Mlx.Ffi.argNat c with
    | some (.clo (.compiled _ _ sl ts)), some (.vec xs), some _ =>
      !sl && xs.all (valuedN x) && ts.all (traceOkS P x xs)
    | _, _, _ => false
  | _ => false

/-- A closure's inputs and traces, not shapeless. -/
def cloParts (x : NSt) : List Arg → Option (List Nat × List Trace)
  | [_, c, v] => match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.clo (.compiled _ _ false ts)), some (.vec xs) => some (xs, ts)
    | _, _ => none
  | _ => none

/-- **The apply's lookup asks the server** (the existing checks read a pure lookup). -/
def cloServer (x : NSt) (name : Name) (args : List Arg) : Bool :=
  decide (Host.Mlx.Ffi.symOf name = some .closureApply) && match cloParts x args with
  | some (xs, ts) => match Host.Mlx.Ffi.findTrace x false xs ts (Option Trace) Free.pure with
    | .pure _ => false
    | _ => true
  | none => false

theorem cloServer_sym {x : NSt} {name : Name} {args : List Arg} (h : cloServer x name args = true) :
    Host.Mlx.Ffi.symOf name = some .closureApply := by
  simp only [cloServer, Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.1

/-- The references of the shapes the lookup compares and the replays read. -/
def cloRefsS (x : NSt) (args : List Arg) : List Nat :=
  match cloParts x args with
  | some (xs, ts) => xs.flatMap (nodeRefs x) ++ ts.flatMap fun t =>
      t.ins.flatMap (nodeRefs x) ++ ((rwalk x x.nnext (t.ins.zip xs) t.order).getD []).flatMap (nodeRefs x)
  | none => []

/-- The lookup finds a trace at `S`. -/
def cloFoundS (S : SSrv) (x : NSt) (args : List Arg) : Bool :=
  match cloParts x args with
  | some (xs, ts) => match interpS (Host.Mlx.Ffi.findTrace x false xs ts).run S with
    | some (some _, _) => true
    | _ => false
  | none => false

/-- **The numeric premise of such an apply.** -/
def cloSmallS (ν : Nat → F64) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Prop :=
  cloServer x name args = true → (∀ j ∈ cloRefsS x args, RefSmall ν S j) ∧ cloFoundS S x args = true ∧
    RunSome S (Host.Mlx.Ffi.call x name args)

theorem valuedN_pn {x : NSt} {k : Nat} (h : valuedN x k = true) : PN x k := by
  unfold valuedN at h
  unfold PN
  cases hn : x.nodes.get k with
  | none => rw [hn] at h; cases h
  | some _ => rfl

/-! ## The simulation -/

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs

theorem shv_of : ∀ {l : List Nat} {a : List (List Dim × Nat)}, Host.Mlx.Ffi.shapesOf x l = some a →
    (∀ b ∈ l, ∀ nd, x.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks) → ShV M C S a
  | [], a, e, _ => by
    simp only [Host.Mlx.Ffi.shapesOf, Option.some.injEq] at e
    subst e
    exact fun _ h => by cases h
  | b :: l, a, e, h => by
    simp only [Host.Mlx.Ffi.shapesOf] at e
    cases hn : x.nodes.get b with
    | none => rw [hn] at e; cases e
    | some nd =>
      rw [hn, Option.bind_some] at e
      cases hl : Host.Mlx.Ffi.shapesOf x l with
      | none => rw [hl] at e; cases e
      | some a' =>
        rw [hl] at e
        simp only [Option.map_some, Option.some.injEq] at e
        subst e
        intro q hq
        rcases List.mem_cons.mp hq with rfl | hq
        · exact h b List.mem_cons_self nd hn
        · exact shv_of hl (fun c hc => h c (List.mem_cons_of_mem _ hc)) q hq

include hr

/-- **An apply whose lookup compares valued shapes**: both sides find the same trace, which replays under `rwalk`. -/
theorem sim_closureApplyS (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.closureApply) {args : List Arg}
    (hok : NativeOkX.clApplyS P x args = true) (hgate : cloServer x name args = true) (hsm : cloSmallS ν S x name args) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  obtain ⟨hrefs, hfound, hrun⟩ := hsm hgate
  unfold NativeOkX.clApplyS at hok
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
        obtain ⟨⟨hshl, hxs⟩, hts⟩ := hm
        have e0 : shl = false := by simpa using hshl
        subst e0
        have hxsV : ∀ k ∈ xs, valuedN x k = true := fun k hk => List.all_eq_true.mp hxs k hk
        have hxs' : ∀ k ∈ xs, PN x k := fun k hk => valuedN_pn (hxsV k hk)
        have tOk : ∀ t ∈ ts, (∀ a ∈ t.ins, valuedN x a = true) ∧ (∀ a ∈ t.outs, PN x a) ∧
            (rwalk x x.nnext (t.ins.zip xs) t.order).isSome = true ∧ (∀ a ∈ t.order, a < P.NL) ∧
            x.nnext + t.order.length ≤ P.NE := by
          intro t ht
          have h := List.all_eq_true.mp hts t ht
          unfold traceOkS at h
          simp only [Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at h
          exact ⟨h.1.1.1.1, h.1.1.1.2, h.1.1.2, h.1.2, h.2⟩
        have hyc : y.obj? (M.handle ck) = some (.clo (.compiled (M.region cb) (M.arg pl) false (ts.map M.trace))) := by
          rw [hr.obj? hpc, hco]; rfl
        have hparts : cloParts x [o, .big (Int.ofNat ck), .big (Int.ofNat kv)] = some (xs, ts) := by
          unfold cloParts
          simp only [argNat_nat, Option.bind_some, hco, h3]
        -- the references
        have hrefsAll : ∀ j ∈ cloRefsS x [o, .big (Int.ofNat ck), .big (Int.ofNat kv)], RefSmall ν S j := hrefs
        unfold cloRefsS at hrefsAll
        rw [hparts] at hrefsAll
        dsimp only at hrefsAll
        have hval : ∀ b, valuedN x b = true → (∀ j ∈ nodeRefs x b, RefSmall ν S j) → ∀ nd, x.nodes.get b = some nd →
            ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks := by
          intro b hb hj nd hn
          unfold valuedN at hb
          rw [hn] at hb
          exact dvss_of hs hb fun j h => hj j (by unfold nodeRefs; rw [hn]; exact h)
        have hbX : ∀ b ∈ xs, ∀ nd, x.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks := fun b hb =>
          hval b (hxsV b hb) fun j hj => hrefsAll j (List.mem_append_left _ (List.mem_flatMap.mpr ⟨b, hb, hj⟩))
        have hbT : ∀ t ∈ ts, ∀ b ∈ t.ins, ∀ nd, x.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks :=
          fun t ht b hb => hval b ((tOk t ht).1 b hb) fun j hj => hrefsAll j (List.mem_append_right _
            (List.mem_flatMap.mpr ⟨t, ht, List.mem_append_left _ (List.mem_flatMap.mpr ⟨b, hb, hj⟩)⟩))
        -- the lookup
        obtain ⟨bb, eb⟩ := shapesOf_some hxs'
        have hbv : ShV M C S bb := shv_of hs eb hbX
        have hfts : ∀ t ∈ ts, ∃ a, Host.Mlx.Ffi.shapesOf x t.ins = some a ∧
            Host.Mlx.Ffi.shapesOf y (t.ins.map M.node) = some (a.map M.shp) ∧ ShV M C S a := by
          intro t ht
          obtain ⟨a, ea⟩ := shapesOf_some (x := x) (l := t.ins) fun a' ha' => valuedN_pn ((tOk t ht).1 a' ha')
          exact ⟨a, ea, hr.shapesOf_map ea, shv_of hs ea (hbT t ht)⟩
        have hfind := findTrace_simV (ν := ν) eb (hr.shapesOf_map eb) hbv ts (GrowL.refl hs) hfts
        have hboth := Full.MSim.both hfind (NativeLawful.findTrace_l _ _ _ _) (NativeLawful.findTrace_l _ _ _ _)
        unfold cloFoundS at hfound
        rw [hparts] at hfound
        dsimp only at hfound
        unfold Host.Mlx.Ffi.call at hrun
        rw [hsym] at hrun
        unfold Host.Mlx.Ffi.closureApply at hrun
        simp only [h1, argNat_nat, Option.bind_some, hco, h3] at hrun
        simp only [List.map_cons, List.map_nil]
        rw [hmc, hmv]
        unfold Host.Mlx.Ffi.call
        rw [hsym]
        unfold Host.Mlx.Ffi.closureApply
        simp only [h1, h2, argNat_nat, Option.bind_some, hco, hyc, h3, h4]
        refine MSim.bind hboth fun M1 S1 C1 r r' h => ?_
        obtain ⟨⟨rfl, hg1, hmem⟩, hra, -⟩ := h
        rw [hra] at hfound
        cases r with
        | none => cases hfound
        | some t =>
          obtain ⟨-, tOuts, hwk, hband, tRoom⟩ := tOk t (hmem t rfl)
          obtain ⟨L, hwL⟩ := Option.isSome_iff_exists.mp hwk
          have tIns : ∀ a ∈ t.ins, PN x a := fun a ha => valuedN_pn ((tOk t (hmem t rfl)).1 a ha)
          have hrun1 := RunSome.bind (NativeLawful.findTrace_l _ _ _ _) hra hrun
          have hLv : ∀ b ∈ L, ∀ nd, x.nodes.get b = some nd → ∃ ks, DVSs M1 C1 S1 nd.shape ks ∧ Bd ks := by
            intro b' hb' nd hn
            obtain ⟨ks, hk, bk⟩ := hval b' (rwalk_valued _ _ _ hwL b' hb') (fun j hj => hrefsAll j (List.mem_append_right _
              (List.mem_flatMap.mpr ⟨t, hmem t rfl, List.mem_append_right _ (by
                rw [hwL]
                exact List.mem_flatMap.mpr ⟨b', hb', hj⟩)⟩))) nd hn
            exact ⟨ks, (DVSs.lift hg1 hk).1, bk⟩
          have en : M1.node = M.node := hg1.grow.ext.node
          have ea : M1.a = M.a := hg1.grow.ext.a
          have eh : ∀ c, M1.handle c = M.handle c := fun c => by simp only [Map.handle, hg1.grow.ext.big]
          have et : M1.trace t = M.trace t := by simp only [Map.trace, en]
          have hd := sim_applyDoneV (P := P) (NB := NB) hg1.grow.srv (hr.grow hg1.grow) hwL hband hLv hrun1 tIns hxs' tOuts tRoom
            hsl hE'
          rw [eh, ea, eh, et, en] at hd
          exact MSim.mono hd fun M' S' C' r r' h => ⟨hg1.grow.trans h.1, h.2⟩
      | _ => cases hm
    | _ => cases hm

end

end Host.Ts.Sim.G

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-- **The accepted applies whose lookup asks the server**, the bridge inactive. -/
def okCallSV (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName && !(bridgeOf x).active &&
    G.cloServer (mlxOf x) name args && G.NativeOkX.clApplyS P (mlxOf x) args && obsOk (mlxOf x) name args

/-- **`okCallFXD` with those applies**, at the band raised to the node counter. -/
def okCallFXS (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  okCallFXD P x name args || (decide (P.NL = P.N0) && okCallSV (P.raise (mlxOf x).nnext) x name args)

/-- `smallFX2` with their premise. -/
def smallFXS (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  smallFX2 ν S x name args ∧ G.cloSmallS ν S (mlxOf x) name args

theorem clApplyS_rest (P : LoadP) (r : List NumV) :
    G.NativeOkX.clApplyS { P with rest := r } = G.NativeOkX.clApplyS P := by
  funext x args
  unfold G.NativeOkX.clApplyS
  split <;> rfl

theorem fullCloSimS {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullR P NB M S.tab.length x y)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = false) (hgate : G.cloServer (mlxOf x) name args = true)
    (hok : G.NativeOkX.clApplyS P (mlxOf x) args = true) (hobs : obsOk (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hsm : G.cloSmallS ν S (mlxOf x) name args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullR P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hsym := G.cloServer_sym hgate
  have hg := G.mlx_lift hr.load hm (G.sim_closureApplyS hsrv hr.load.mlx hsym hok hgate hsm)
  have hss : isSymShape name = false := by unfold isSymShape; rw [hsym]
  refine fullCallOf hr hm hp hact hobs hsupp ?_ ?_ (fun h => by rw [hss] at h; cases h) hg
  · intro s hs; rw [hsym] at hs; cases hs
    exact ⟨(fun h => nomatch h), (fun h => by rcases h with h | h | h <;> cases h)⟩
  · intro hs; rw [hsym] at hs; cases hs

/-- **The native-call simulation with those applies.** -/
theorem fullCallSimXS (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRXD P NB) (okCallFXS P) smallFXS where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    unfold okCallFXS at hok
    rw [Bool.or_eq_true] at hok
    rcases hok with hd | hs
    · exact (fullCallSimXD P NB).call M ν S C x y name args hsrv hr hd hsupp hsm.1
    · simp only [Bool.and_eq_true, decide_eq_true_eq] at hs
      obtain ⟨hb, hv⟩ := hs
      obtain ⟨hrr, hP⟩ := hr.top hb
      simp only [okCallSV, Bool.and_eq_true, Bool.not_eq_true'] at hv
      obtain ⟨⟨⟨⟨⟨hm, hp⟩, hact⟩, hgate⟩, hok⟩, hobs⟩ := hv
      refine MSim.mono (fullCloSimS hsrv (hrr.toR hact) hm hp hact hgate hok hobs hsupp hsm.2) ?_
      exact fun _ _ _ _ _ h => ⟨h.1, callR_mono (fun _ _ _ _ h => ⟨_, hP, h.toX⟩) h.2⟩

end Host.Ts.Sim.Full
