import host.sim.full.BridgeSchedule

/-! # The bridge after an MLX call, under the map

`FfiAne.after` updates the bridge after an MLX call: an evaluating call schedules the readers and
writers its roots reach (`BRel.schedule`), `mlx_synchronize` completes the running ones, and any
other call classifies its new nodes (`BRel.classify`). On related states before and after the
call it gives related bridges (`BRel.after`), under the template's checks (`afterOk`): an
evaluating call names a present vector or array, and its walk only follows nodes below the node
counter (`schedOk`). The relation before the call is the one after it at the old counters; the
fresh nodes in between are recorded on neither side (`BRel.widen`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim
open Host.Mlx.FfiAne (pushIns reach reachOf minL Effect EvalCall)

theorem minL_mem : ∀ (m : Nat) (l : List Nat), minL m l ∈ m :: l
  | _, [] => List.mem_cons_self
  | m, i :: l => by
    simp only [minL]
    have := minL_mem (bif Nat.blt i m then i else m) l
    cases hb : Nat.blt i m <;> simp only [hb, Bool.cond_false, Bool.cond_true] at this ⊢
    · rcases List.mem_cons.mp this with e | e
      · rw [e]; exact List.mem_cons_self
      · exact List.mem_cons_of_mem _ (List.mem_cons_of_mem _ e)
    · rcases List.mem_cons.mp this with e | e
      · rw [e]; exact List.mem_cons_of_mem _ List.mem_cons_self
      · exact List.mem_cons_of_mem _ (List.mem_cons_of_mem _ e)

/-- The bridge after an evaluation that reached `has` (`FfiAne.schedule`'s result). -/
def schedRes (b : BSt) (has : Nat → Bool) (bl : Bool) : BSt :=
  { b with unscheduled := b.unscheduled.filter (fun n => !has n),
           running := bif bl then (b.running ++ b.unscheduled.filter has).filter (fun n => !has n)
             else b.running ++ b.unscheduled.filter has,
           log := bif (b.unscheduled.filter has).isEmpty then b.log else .gpu (b.unscheduled.filter has) :: b.log }

section
variable {M : Map} {nx ny : Nat} {b b' : BSt}

/-- The bridge after an evaluation, under the map: the reached set `has` renamed by `hasT`. -/
theorem BRel.schedDone (h : BRel M nx ny b b') {has hasT : Nat → Bool}
    (hhas : ∀ n, n < nx → hasT (M.node n) = has n) (bl : Bool) :
    BRel M nx ny (schedRes b has bl) (schedRes b' hasT bl) := by
  unfold schedRes
  have hq : ∀ n ∈ b.unscheduled, n < nx := fun n hn => h.queued n (List.mem_append_left _ hn)
  have hqr : ∀ n ∈ b.running, n < nx := fun n hn => h.queued n (List.mem_append_right _ hn)
  have fU : b'.unscheduled.filter hasT = (b.unscheduled.filter has).map M.node := by
    rw [h.unscheduled, List.filter_map]
    congr 1
    exact List.filter_congr fun u hu => hhas u (hq u hu)
  have fU' : b'.unscheduled.filter (fun n => !hasT n) = (b.unscheduled.filter fun n => !has n).map M.node := by
    rw [h.unscheduled, List.filter_map]
    congr 1
    exact List.filter_congr fun u hu => by simp only [Function.comp, hhas u (hq u hu)]
  have hall : ∀ n ∈ b.running ++ b.unscheduled.filter has, n < nx := fun n hn => by
    rcases List.mem_append.mp hn with e | e
    · exact hqr n e
    · exact hq n (List.mem_filter.mp e).1
  have fR : b'.running ++ b'.unscheduled.filter hasT = (b.running ++ b.unscheduled.filter has).map M.node := by
    rw [h.running, fU, List.map_append]
  have fR' : (b'.running ++ b'.unscheduled.filter hasT).filter (fun n => !hasT n) =
      ((b.running ++ b.unscheduled.filter has).filter fun n => !has n).map M.node := by
    rw [fR, List.filter_map]
    congr 1
    exact List.filter_congr fun u hu => by simp only [Function.comp, hhas u (hall u hu)]
  refine { h with unscheduled := fU', running := ?_, queued := ?_, log := ?_ }
  · cases bl
    · exact fR
    · exact fR'
  · intro n hn
    rcases List.mem_append.mp hn with e | e
    · exact hq n (List.mem_filter.mp e).1
    · cases bl
      · exact hall n e
      · exact hall n (List.mem_filter.mp e).1
  · have hE : (b'.unscheduled.filter hasT).isEmpty = (b.unscheduled.filter has).isEmpty := by
      rw [fU]; cases b.unscheduled.filter has <;> rfl
    show (bif (b'.unscheduled.filter hasT).isEmpty then b'.log else .gpu (b'.unscheduled.filter hasT) :: b'.log) =
      (bif (b.unscheduled.filter has).isEmpty then b.log else .gpu (b.unscheduled.filter has) :: b.log).map M.effect
    rw [hE]
    cases (b.unscheduled.filter has).isEmpty
    · simp only [Bool.cond_false, List.map_cons, h.log, fU, Map.effect]
    · simp only [Bool.cond_true, h.log]

/-- The relation at larger counters, the fresh nodes in between recorded on neither side. -/
theorem BRel.widen (h : BRel M nx ny b b') {nx' ny' : Nat} (hx : nx ≤ nx') (hy : ny ≤ ny')
    (hfr : ∀ i, M.node (nx + i) = ny + i) : BRel M nx' ny' b b' :=
  { h with
    aliases := fun n hn => by
      by_cases e : n < nx
      · exact h.aliases n e
      · have e1 : b.aliases.get n = none := by
          cases g : b.aliases.get n with
          | none => rfl
          | some _ => exact absurd (h.aliasX n (by rw [g]; rfl)) e
        have hm : ny ≤ M.node n := by
          have := hfr (n - nx); rw [show nx + (n - nx) = n by omega] at this; omega
        have e2 : b'.aliases.get (M.node n) = none := by
          cases g : b'.aliases.get (M.node n) with
          | none => rfl
          | some _ => have := h.aliasY _ (by rw [g]; rfl); omega
        rw [e1, e2]
    aliasX := fun n hn => Nat.lt_of_lt_of_le (h.aliasX n hn) hx
    aliasY := fun m hm => Nat.lt_of_lt_of_le (h.aliasY m hm) hy
    touch := fun n hn => by
      by_cases e : n < nx
      · exact h.touch n e
      · have e1 : b.touch.get n = none := by
          cases g : b.touch.get n with
          | none => rfl
          | some _ => exact absurd (h.touchX n (by rw [g]; rfl)) e
        have hm : ny ≤ M.node n := by
          have := hfr (n - nx); rw [show nx + (n - nx) = n by omega] at this; omega
        have e2 : b'.touch.get (M.node n) = none := by
          cases g : b'.touch.get (M.node n) with
          | none => rfl
          | some _ => have := h.touchY _ (by rw [g]; rfl); omega
        rw [e1, e2]
    touchX := fun n hn => Nat.lt_of_lt_of_le (h.touchX n hn) hx
    touchY := fun m hm => Nat.lt_of_lt_of_le (h.touchY m hm) hy
    queued := fun n hn => Nat.lt_of_lt_of_le (h.queued n hn) hx }

end

section
variable {P : LoadP} {NB : Nat} {M : Map} {k : Nat} {x y : NSt} (hr : G.MR P NB M k x y)
  (hF : ∀ i, Full P i) (hd : ∀ i, i < x.nnext → PN x i)
include hr hF hd

/-- **An evaluation under the map.** -/
theorem BRel.schedule {b b' : BSt} (h : BRel M x.nnext y.nnext b b') {roots : List Nat}
    (hok : schedOk b x roots = true) {bl : Bool} {b1 : BSt}
    (e : Host.Mlx.FfiAne.schedule b x roots bl = some b1) :
    ∃ b1', Host.Mlx.FfiAne.schedule b' y (roots.map M.node) bl = some b1' ∧ BRel M x.nnext y.nnext b1 b1' := by
  unfold schedOk at hok
  rw [Bool.and_eq_true] at hok
  obtain ⟨hroots, hok⟩ := hok
  have hroots' : ∀ i ∈ roots, i < x.nnext := fun i hi => by
    have := List.all_eq_true.mp hroots i hi; rw [Nat.blt_eq] at this; exact this
  unfold Host.Mlx.FfiAne.schedule at e ⊢
  have hu : b'.unscheduled.isEmpty = b.unscheduled.isEmpty := by rw [h.unscheduled]; cases b.unscheduled <;> rfl
  have hrn : b'.running.isEmpty = b.running.isEmpty := by rw [h.running]; cases b.running <;> rfl
  rw [hu, hrn]
  cases hc : (b.unscheduled.isEmpty && (!bl || b.running.isEmpty))
  · rw [hc, Bool.cond_false] at e
    rw [Bool.cond_false]
    have hq : b'.unscheduled ++ b'.running = (b.unscheduled ++ b.running).map M.node := by
      rw [h.unscheduled, h.running, List.map_append]
    rw [hq]
    have hqx : ∀ i ∈ b.unscheduled ++ b.running, i < x.nnext := h.queued
    generalize hl : b.unscheduled ++ b.running = l at e hok hqx
    cases l with
    | nil => cases e; exact ⟨b', rfl, h⟩
    | cons t ts =>
      have ht : t < x.nnext := hqx t List.mem_cons_self
      have hts : ∀ i ∈ ts, i < x.nnext := fun i hi => hqx i (List.mem_cons_of_mem _ hi)
      have hlo : minL t ts < x.nnext := hqx _ (minL_mem t ts)
      simp only [List.map_cons]
      dsimp only at e hok ⊢
      rw [minL_map hr hF hd t ts ht hts]
      unfold reachOf at e ⊢
      obtain ⟨p1, p2, p3⟩ := pushIns_rel hr hF hd hlo roots [] hroots' (seen := .nil) (seen' := .nil)
        (fun _ _ => rfl)
      simp only [List.map_nil] at p1 p2
      generalize hp : pushIns (minL t ts) roots [] .nil = pp at e hok p1 p2 p3
      obtain ⟨st0, seen0⟩ := pp
      dsimp only at e hok p1 p2 p3
      have hst0 : ∀ i ∈ st0, i < x.nnext := fun i hi => by
        rcases p3 i hi with e' | e'
        · cases e'
        · exact hroots' i e'
      cases hre : reach x (minL t ts) (x.nnext + Host.Ts.len roots + 1) st0 seen0 with
      | none => rw [hre] at e; cases e
      | some seen =>
        rw [hre] at e
        dsimp only at e
        have hfuel : x.nnext + Host.Ts.len roots + 1 ≤ y.nnext + Host.Ts.len (roots.map M.node) + 1 := by
          rw [Native.len_map]; have := hr.nroom.1; omega
        obtain ⟨seen', hre', hss⟩ := reach_rel hr hF hd hlo _ st0 hst0 p2 hok hre _ hfuel
        generalize hp' : pushIns (M.node (minL t ts)) (roots.map M.node) [] .nil = pp' at p1 p2 hre' ⊢
        obtain ⟨st0', seen0'⟩ := pp'
        dsimp only at p1 p2 hre' ⊢
        rw [p1, hre']
        dsimp only
        have hq0 : ∀ n ∈ b.unscheduled, n < x.nnext := fun n hn => h.queued n (List.mem_append_left _ hn)
        have hhas : ∀ n, n < x.nnext → (seen'.get (M.node n)).isSome = (seen.get n).isSome := fun n hn => by
          rw [hss n hn]
        have fU : b'.unscheduled.filter (fun n => (seen'.get n).isSome) =
            (b.unscheduled.filter fun n => (seen.get n).isSome).map M.node := by
          rw [h.unscheduled, List.filter_map]
          congr 1
          exact List.filter_congr fun u hu => hhas u (hq0 u hu)
        rw [fU, h.eventOk _ fun n hn => hq0 n (List.mem_filter.mp hn).1, ← fU]
        cases hev : Host.Mlx.FfiAne.eventOk b (b.unscheduled.filter fun n => (seen.get n).isSome)
        · rw [hev, Bool.cond_false] at e; cases e
        · rw [hev, Bool.cond_true] at e
          rw [Bool.cond_true]
          cases e
          exact ⟨_, rfl, h.schedDone hhas bl⟩
  · rw [hc, Bool.cond_true] at e
    rw [Bool.cond_true]
    cases e
    exact ⟨b', rfl, h⟩

end

/-! ## Evaluating calls -/

/-- An evaluation call with its roots renamed. -/
def evalMap (M : Map) : EvalCall → EvalCall
  | .roots ns bl => .roots (ns.map M.node) bl
  | .all => .all
  | .other => .other

/-- An evaluating call's argument names a present vector or array. -/
def evalArgsOk (x : NSt) (name : Name) (args : List Arg) : Bool :=
  bif nameEq name chars!"mlx_eval" || nameEq name chars!"mlx_async_eval" then
    (match args with | [v] => vecOk x v | _ => true)
  else bif nameEq name chars!"mlx_array_eval" then (match args with | [h] => nodeOk x h | _ => true)
  else bif nameEq name chars!"mlx_array_item_uint32" then (match args with | [_, h] => nodeOk x h | _ => true)
  else true

/-- **The bridge's checks after an MLX call**, on the template before it. -/
def afterOk (b : BSt) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  evalArgsOk x name args && match Host.Mlx.FfiAne.evalCall x name args with
  | .roots ns _ => schedOk b x ns
  | _ => true

section
variable {P : LoadP} {NB : Nat} {M : Map} {k : Nat} {x y : NSt} (hr : G.MR P NB M k x y)
include hr

theorem _root_.Host.Ts.Sim.G.MR.bvecRoots {v : Arg} (hv : vecOk x v = true) :
    Host.Mlx.FfiAne.vecRoots y (M.arg v) = (Host.Mlx.FfiAne.vecRoots x v).map M.node := by
  obtain ⟨kv, ns, rfl, hm, -, h3, h4⟩ := G.MR.vecArg hr hv
  unfold Host.Mlx.FfiAne.vecRoots
  rw [hm, argNat_nat, argNat_nat, Option.bind_some, Option.bind_some, h3, h4]

theorem _root_.Host.Ts.Sim.G.MR.barrRoot {a : Arg} (ha : nodeOk x a = true) :
    Host.Mlx.FfiAne.arrRoot y (M.arg a) = (Host.Mlx.FfiAne.arrRoot x a).map M.node := by
  obtain ⟨kk, i, nd, nd', rfl, hm, hp, -, -, -⟩ := G.MR.nodeArg hr ha
  unfold Host.Mlx.FfiAne.arrRoot
  rw [hm, argNat_nat, argNat_nat, Option.bind_some, Option.bind_some, G.MR.nodeId? hr hp]
  cases x.nodeId? kk <;> rfl

theorem _root_.Host.Ts.Sim.G.MR.bevalCall {name : Name} {args : List Arg} (hok : evalArgsOk x name args = true) :
    Host.Mlx.FfiAne.evalCall y name (args.map M.arg) = evalMap M (Host.Mlx.FfiAne.evalCall x name args) := by
  unfold evalArgsOk at hok
  unfold Host.Mlx.FfiAne.evalCall
  cases h1 : nameEq name chars!"mlx_eval" <;> cases h2 : nameEq name chars!"mlx_async_eval" <;>
    simp only [h1, h2, Bool.or_false, Bool.or_true, Bool.false_or, Bool.cond_true, Bool.cond_false] at hok ⊢
  · cases h3 : nameEq name chars!"mlx_array_eval" <;> simp only [h3, Bool.cond_true, Bool.cond_false] at hok ⊢
    · cases h4 : nameEq name chars!"mlx_array_item_uint32" <;> simp only [h4, Bool.cond_true, Bool.cond_false] at hok ⊢
      · cases nameEq name chars!"mlx_synchronize" <;> rfl
      · match args, hok with
        | [_, a], hok => simp only [List.map_cons, List.map_nil, evalMap, hr.barrRoot hok]
        | [], _ => rfl
        | [_], _ => rfl
        | _ :: _ :: _ :: _, _ => rfl
    · match args, hok with
      | [a], hok => simp only [List.map_cons, List.map_nil, evalMap, hr.barrRoot hok]
      | [], _ => rfl
      | _ :: _ :: _, _ => rfl
  all_goals
    match args, hok with
    | [a], hok => simp only [List.map_cons, List.map_nil, evalMap, hr.bvecRoots hok]
    | [], _ => rfl
    | _ :: _ :: _, _ => rfl

end

section
variable {P : LoadP} {NB : Nat} {M M' : Map} {k k' : Nat} {x y x' y' : NSt} (hr : G.MR P NB M k x y)
  (hr' : G.MR P NB M' k' x' y') (hn : M'.node = M.node) (hF : ∀ i, Full P i)
  (hd : ∀ i, i < x.nnext → PN x i) (hd' : ∀ i, i < x'.nnext → PN x' i) (hxx : x.nnext ≤ x'.nnext)
include hr hr' hn hF hd hd' hxx

theorem lockstep_nnext : y'.nnext = y.nnext + (x'.nnext - x.nnext) := by
  have e1 := hr'.nfresh 0
  have e0 := hr.nfresh (x'.nnext - x.nnext)
  rw [hn] at e1
  simp only [Nat.add_zero] at e1
  rw [show x.nnext + (x'.nnext - x.nnext) = x'.nnext by omega, e1] at e0
  exact e0

/-- **The replayed nodes classified under the map**: from related bridges before, the template's
classification of the nodes `x'` adds over `x` has an image classifying those `y'` adds over `y`. -/
theorem BRel.classifyPost {b b' : BSt} (h : BRel M x.nnext y.nnext b b') {b1 : BSt}
    (e : Host.Mlx.FfiAne.classify b x' (x'.nnext - x.nnext) x.nnext = some b1) :
    ∃ b1', Host.Mlx.FfiAne.classify b' y' (y'.nnext - y.nnext) y.nnext = some b1' ∧
      BRel M' x'.nnext y'.nnext b1 b1' := by
  have hY := lockstep_nnext hr hr' hn hF hd hd' hxx
  have hfr : ∀ i, M.node (x.nnext + i) = y.nnext + i := hr.nfresh
  have h0 : BRel M' x'.nnext y'.nnext b b' := (h.widen hxx (by omega) hfr).names hn
  have hfr' : ∀ i, M'.node (x.nnext + i) = y.nnext + i := fun i => by rw [hn]; exact hfr i
  have := BRel.classify hr' hF hd' hxx (by omega) hfr' (x'.nnext - x.nnext) 0 h0 (b1 := b1) (by simpa using e)
  simp only [Nat.add_zero] at this
  rw [show y'.nnext - y.nnext = x'.nnext - x.nnext by omega]
  exact this

/-- **The bridge after an MLX call under the map**: from related bridges before the call, the
template's checks before it, and the states before and after related. -/
theorem BRel.after {b b' : BSt} (h : BRel M x.nnext y.nnext b b') {name : Name} {args : List Arg}
    (hok : afterOk b x name args = true) {b1 : BSt} (e : Host.Mlx.FfiAne.after b x x' name args = some b1) :
    ∃ b1', Host.Mlx.FfiAne.after b' y y' name (args.map M.arg) = some b1' ∧ BRel M' x'.nnext y'.nnext b1 b1' := by
  have hY := lockstep_nnext hr hr' hn hF hd hd' hxx
  have hfr : ∀ i, M.node (x.nnext + i) = y.nnext + i := hr.nfresh
  have hw : ∀ {c c' : BSt}, BRel M x.nnext y.nnext c c' → BRel M' x'.nnext y'.nnext c c' := fun hc =>
    (hc.widen hxx (by omega) hfr).names hn
  unfold afterOk at hok
  rw [Bool.and_eq_true] at hok
  obtain ⟨hev, hok⟩ := hok
  unfold Host.Mlx.FfiAne.after at e ⊢
  rw [hr.bevalCall hev]
  cases hc : Host.Mlx.FfiAne.evalCall x name args with
  | roots ns bl =>
    rw [hc] at e hok
    dsimp only [evalMap] at e hok ⊢
    obtain ⟨b1', e', h1⟩ := h.schedule hr hF hd hok e
    exact ⟨b1', e', hw h1⟩
  | all =>
    rw [hc] at e
    dsimp only [evalMap] at e ⊢
    cases e
    have hq : ∀ n ∈ b.unscheduled ++ ([] : List Nat), n < x.nnext := fun n hn =>
      h.queued n (List.mem_append_left _ (by simpa using hn))
    exact ⟨_, rfl, hw { h with running := rfl, queued := hq }⟩
  | other =>
    rw [hc] at e
    dsimp only [evalMap] at e ⊢
    exact h.classifyPost hr hr' hn hF hd hd' hxx e

end

end Host.Ts.Sim.Full
