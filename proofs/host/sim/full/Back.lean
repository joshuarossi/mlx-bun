import host.sim.full.Topo
import host.sim.full.ReplayV
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # A trace continuation (`back`) for any prefill history

`traceBack` pops the pending trace, orders its graph from the outputs down to the tracers (`topo`),
appends the trace to the closure and replays it on the apply's inputs (`applyDone`). On related
states the target pops the image, orders the images (`MR.topo_map`), appends the imaged trace and
replays it (`sim_applyDone`, `MR.replayOrder`). The recorded nodes are pre-loop for the relation
(`P.NL`, `backOkG`): the full world raises a band-free relation's band to the node counter first
(`host.sim.full.Raise`). A trace over symbolic shapes replays under `rwalk` (`backOkV`, `sim_traceBackV`,
`host.sim.full.ReplayV`) given its numeric premise `backSmall`. -/

/-- Node `n` of `x` is a custom kernel's (`traceBack`'s shapeless check). -/
def kernAt (x : NSt) (n : Nat) : Bool :=
  match x.nodes.get n with
  | some nd => Host.Mlx.Ffi.isKernel nd.prim
  | none => false

theorem isKernel_prim (M : Map) (p : Prim) : Host.Mlx.Ffi.isKernel (M.prim p) = Host.Mlx.Ffi.isKernel p := by
  induction p <;> first | rfl | exact ‹_›

theorem PrimR.isKernel {M : Map} {nd : Node} {p' : Prim} (h : PrimR M nd p') :
    Host.Mlx.Ffi.isKernel p' = Host.Mlx.Ffi.isKernel nd.prim := by
  rcases h with rfl | ⟨hs, bs, rfl⟩
  · exact isKernel_prim M nd.prim
  · obtain ⟨p, ins, sh, d⟩ := nd
    cases p <;> first | rfl | (simp [shapeOnly] at hs)

/-- The template's traceBack, decided with a replay check `rc` (state, closure, inputs, order): the
pending trace's result decoded and its closure compiled, its graph ordered over pre-loop nodes (`P.NL`)
with no custom kernel in a shapeless graph, its tracers, outputs and inputs present, the result slot
null or present, room for the result vector and the replay, and the replay checked on the state after
the closure's update. -/
def backOkR (P : LoadP) (rc : NSt → Nat → List (Nat × Nat) → List Nat → Bool) (x : NSt) (a : Arg) : Bool :=
  natOk P a && match x.pending, Host.Mlx.Ffi.argNat a with
  | p :: rest, some 0 => match p.res, x.obj? p.cls with
    | some outs, some (.clo (.compiled cb pl sl ts)) =>
      match Host.Mlx.Ffi.topo x p.tracers 4096 (outs.map (·, false)) [] [] with
      | some order =>
        p.tracers.all (fun i => (x.nodes.get i).isSome) && outs.all (fun i => (x.nodes.get i).isSome) &&
          p.ins.all (fun i => (x.nodes.get i).isSome) &&
          order.all (fun i => decide (i < P.NL) && (x.nodes.get i).isSome) && !(sl && order.any (kernAt x)) &&
          (Nat.beq p.outSlot 0 || isPH x p.outSlot) && decide (x.next + 1 ≤ P.E) &&
          decide (x.nnext + order.length ≤ P.NE) &&
          rc { x.setObj p.cls (.clo (.compiled cb pl sl (ts ++ [⟨p.tracers, outs, order⟩]))) with pending := rest }
            p.cls (p.tracers.zip p.ins) order
      | none => false
    | _, _ => false
  | _, _ => false

/-- **The template's traceBack, decided** with the literal replay's check (`rchk`). -/
def backOkG (P : LoadP) (x : NSt) (a : Arg) : Bool := backOkR P (fun x1 c m o => rchk P.NL c x1 m o) x a

/-- **The template's traceBack over symbolic shapes**: the replay `rwalk` accepts and the literal one
does not (`host.sim.full.ReplayV`). -/
def backOkV (P : LoadP) (x : NSt) (a : Arg) : Bool :=
  backOkR P (fun x1 c m o => (rwalk x1 x1.nnext m o).isSome && !(rchk x1.nnext c x1 m o)) x a

/-- The state `traceBack` replays on, with the closure, the recorded trace and the apply's inputs. -/
def backFound (x : NSt) (a : Arg) : Option (NSt × Nat × Trace × List Nat) :=
  match x.pending, Host.Mlx.Ffi.argNat a with
  | p :: rest, some 0 => match p.res, x.obj? p.cls with
    | some outs, some (.clo (.compiled cb pl sl ts)) =>
      match Host.Mlx.Ffi.topo x p.tracers 4096 (outs.map (·, false)) [] [] with
      | some order =>
        some ({ x.setObj p.cls (.clo (.compiled cb pl sl (ts ++ [⟨p.tracers, outs, order⟩]))) with pending := rest },
          p.cls, ⟨p.tracers, outs, order⟩, p.ins)
      | none => none
    | _, _ => none
  | _, _ => none

/-- A continuation the symbolic replay may cover: the recorded trace is not the literal replay's. -/
def backSym (x : NSt) (a : Arg) : Bool :=
  match backFound x a with
  | some (x1, c, t, xs) => !(rchk x1.nnext c x1 (t.ins.zip xs) t.order)
  | none => false

/-- The references of the nodes the symbolic replay of a continuation lists. -/
def backRefs (x : NSt) (a : Arg) : List Nat :=
  match backFound x a with
  | some (x1, _, t, xs) => ((rwalk x1 x1.nnext (t.ins.zip xs) t.order).getD []).flatMap (nodeRefs x1)
  | none => []

/-- **The symbolic replay's numeric premise for a continuation** (`cloSmall`'s): the listed nodes'
references denote small naturals, and the template's continuation has a result. -/
def backSmall (ν : Nat → F64) (S : SSrv) (x : NSt) (a : Arg) : Prop :=
  backSym x a = true → (∀ j ∈ backRefs x a, RefSmall ν S j) ∧ RunSome S (Host.Mlx.Ffi.back x a)

/-- The template's continuation at `S` has a result (decided by evaluation). -/
def backRunB (S : SSrv) (x : NSt) (a : Arg) : Bool :=
  match interpS (Host.Mlx.Ffi.back x a).run S with
  | some (none, _) => false
  | _ => true

/-- The decider of `backSmall`. -/
def backSmallB (VB : Nat → Nat) (S : SSrv) (x : NSt) (a : Arg) : Bool :=
  !backSym x a || ((backRefs x a).all (refSmallB VB S) && backRunB S x a)

theorem backSmallB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : NSt} {a : Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : backSmallB VB S x a = true) : backSmall ν S x a := by
  intro hc
  unfold backSmallB at h
  rw [hc] at h
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at h
  refine ⟨fun j hj => refSmallB_sound (List.all_eq_true.mp h.1 j hj) hν, fun r S' hr' => ?_⟩
  have h2 := h.2
  unfold backRunB at h2
  rw [hr'] at h2
  cases r
  · cases h2
  · rfl

/-- A continuation `backOkR` accepts has its replay's state found, with the node counter, and checked. -/
theorem backOkR_found {P : LoadP} {rc : NSt → Nat → List (Nat × Nat) → List Nat → Bool} {x : NSt} {a : Arg}
    (h : backOkR P rc x a = true) :
    ∃ x1 c t xs, backFound x a = some (x1, c, t, xs) ∧ x1.nnext = x.nnext ∧ rc x1 c (t.ins.zip xs) t.order = true := by
  unfold backOkR at h
  rw [Bool.and_eq_true] at h
  obtain ⟨-, h⟩ := h
  split at h
  case h_2 => cases h
  rename_i p rest hpx ha0
  split at h
  case h_2 => cases h
  rename_i outs cb pl sl ts hres hcls
  split at h
  case h_2 => cases h
  rename_i order htopo
  simp only [Bool.and_eq_true] at h
  refine ⟨_, _, ⟨p.tracers, outs, order⟩, _, ?_, ?_, h.2⟩
  · unfold backFound
    rw [hpx, ha0]
    simp only [hres, hcls, htopo]
  · rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt}

theorem MR.setPend (hr : MR P NB M n x y) (ps : List Pending) :
    MR P NB M n { x with pending := ps } { y with pending := ps.map M.pend } :=
  { hr with pending := rfl }

theorem MR.kernAt (hr : MR P NB M n x y) {i : Nat} (hp : PN x i) (hf : Full P i) :
    G.kernAt y (M.node i) = G.kernAt x i := by
  obtain ⟨nd, hn⟩ := Option.isSome_iff_exists.mp hp
  obtain ⟨nd', hn', hnr⟩ := hr.nodes i nd hn
  unfold G.kernAt
  rw [hn, hn']
  exact (hnr.2.2.2 hf).1.isKernel

theorem MR.anyKernel (hr : MR P NB M n x y) :
    ∀ {l : List Nat}, (∀ i ∈ l, PN x i ∧ Full P i) → (l.map M.node).any (G.kernAt y) = l.any (G.kernAt x)
  | [], _ => rfl
  | i :: l, h => by
    simp only [List.map_cons, List.any_cons]
    rw [hr.kernAt (h i List.mem_cons_self).1 (h i List.mem_cons_self).2,
      hr.anyKernel fun j hj => h j (List.mem_cons_of_mem _ hj)]

end

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **Finishing an apply**: a checked replay of trace `t` on present inputs, its result written to a
null or present slot. -/
theorem sim_applyDone {c b off sl : Nat} {t : Trace} {xs : List Nat}
    (hck : rchk P.NL c x (t.ins.zip xs) t.order = true) (tIns : ∀ a ∈ t.ins, PN x a) (hxs : ∀ k ∈ xs, PN x k)
    (tOuts : ∀ a ∈ t.outs, PN x a) (tRoom : x.nnext + t.order.length ≤ P.NE) (hsl : sl = 0 ∨ PH x sl)
    (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.applyDone x c b off sl t xs)
      (Host.Mlx.Ffi.applyDone y (M.handle c) (M.a b) off (M.handle sl) (M.trace t) (xs.map M.node)) := by
  unfold Host.Mlx.Ffi.applyDone Host.Mlx.Ffi.replay
  have hzip : (M.trace t).ins.zip (xs.map M.node) = substN M (t.ins.zip xs) := by
    show (t.ins.map M.node).zip (xs.map M.node) = _
    rw [List.zip_map]; rfl
  have hzm : ∀ p ∈ t.ins.zip xs, PN x p.1 ∧ PN x p.2 := by
    intro p hp
    obtain ⟨a, k⟩ := p
    exact ⟨tIns a (List.of_mem_zip hp).1, hxs k (List.of_mem_zip hp).2⟩
  obtain ⟨rr, rr', er, er', hrel⟩ := MR.replayOrder c t.order (t.ins.zip xs) hr hck hzm tRoom
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
        hr'.setVec_map hsl' (by rw [hnx]; exact hE) (t.outs.map (Host.Mlx.Ffi.substOf m1))
      rw [bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl),
        bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl)]
      simp only
      rw [e3, e4]
      exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr2

end

/-- `traceBack` once its pending trace, result, closure and order are known. -/
theorem traceBack_eq {s : NSt} {a : Arg} {p : Pending} {rest : List Pending} {outs : List Nat} {cb : Nat}
    {pl : Arg} {sl : Bool} {ts : List Trace} {order : List Nat} (hp : s.pending = p :: rest)
    (ha : Host.Mlx.Ffi.argNat a = some 0) (hres : p.res = some outs)
    (hcls : s.obj? p.cls = some (.clo (.compiled cb pl sl ts)))
    (htopo : Host.Mlx.Ffi.topo s p.tracers 4096 (outs.map (·, false)) [] [] = some order) :
    Host.Mlx.Ffi.traceBack s a = bif sl && order.any (kernAt s) then Host.Mlx.Ffi.stuck else
      Host.Mlx.Ffi.applyDone
        { s.setObj p.cls (.clo (.compiled cb pl sl (ts ++ [⟨p.tracers, outs, order⟩]))) with pending := rest }
        p.cls p.outBuf p.outOff p.outSlot ⟨p.tracers, outs, order⟩ p.ins := by
  unfold Host.Mlx.Ffi.traceBack
  rw [hp, ha]
  simp only [hres, hcls, htopo]
  rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

omit hs in
/-- **A trace continuation** the template's check accepts with a replay check `rc`, given that an apply
`rc` accepts finishes (`hfin`, on the state `traceBack` replays on, `backFound`). -/
theorem sim_traceBackR {a : Arg} {rc : NSt → Nat → List (Nat × Nat) → List Nat → Bool} (hok : backOkR P rc x a = true)
    (hfin : ∀ {x1 y1 : NSt} {c b off sl : Nat} {t : Trace} {xs : List Nat}, MR P NB M S.tab.length x1 y1 →
      rc x1 c (t.ins.zip xs) t.order = true → (∀ a ∈ t.ins, PN x1 a) → (∀ k ∈ xs, PN x1 k) →
      (∀ a ∈ t.outs, PN x1 a) → x1.nnext + t.order.length ≤ P.NE → (sl = 0 ∨ PH x1 sl) → x1.next + 1 ≤ P.E →
      (∀ i ∈ t.order, i < P.NL) → backFound x a = some (x1, c, t, xs) →
      Host.Mlx.Ffi.back x a = Host.Mlx.Ffi.applyDone x1 c b off sl t xs →
      MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.applyDone x1 c b off sl t xs)
        (Host.Mlx.Ffi.applyDone y1 (M.handle c) (M.a b) off (M.handle sl) (M.trace t) (xs.map M.node))) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.back x a) (Host.Mlx.Ffi.back y (M.arg a)) := by
  unfold backOkR at hok
  rw [Bool.and_eq_true] at hok
  obtain ⟨hna, hm⟩ := hok
  have ha : Host.Mlx.Ffi.argNat (M.arg a) = Host.Mlx.Ffi.argNat a := hr.natOk_argNat hna
  split at hm
  case h_2 => cases hm
  rename_i p rest hpx ha0
  split at hm
  case h_2 => cases hm
  rename_i outs cb pl sl ts hres hcls
  split at hm
  case h_2 => cases hm
  rename_i order htopo
  simp only [Bool.and_eq_true] at hm
  obtain ⟨⟨⟨⟨⟨⟨⟨⟨hT, hO⟩, hI⟩, hOrd⟩, hK⟩, hSl⟩, hE⟩, hRoom⟩, hck⟩ := hm
  have hT' : ∀ i ∈ p.tracers, PN x i := List.all_eq_true.mp hT
  have hO' : ∀ i ∈ outs, PN x i := List.all_eq_true.mp hO
  have hI' : ∀ i ∈ p.ins, PN x i := List.all_eq_true.mp hI
  have hOrd' : ∀ i ∈ order, i < P.NL ∧ PN x i := fun i hi => by
    have := List.all_eq_true.mp hOrd i hi
    simp only [Bool.and_eq_true, decide_eq_true_eq] at this
    exact this
  have hk1 : (sl && order.any (kernAt x)) = false := by rw [Bool.not_eq_true'] at hK; exact hK
  have hsl : p.outSlot = 0 ∨ PH x p.outSlot := by
    simp only [Bool.or_eq_true] at hSl
    rcases hSl with h | h
    · exact .inl (Nat.eq_of_beq_eq_true h)
    · exact .inr (isPH_iff.mp h)
  have hE' : x.next + 1 ≤ P.E := of_decide_eq_true hE
  have hRoom' : x.nnext + order.length ≤ P.NE := of_decide_eq_true hRoom
  -- the target's pending trace, result, closure and order
  have hpc : PH x p.cls := .inr (by show (x.obj? p.cls).isSome = true; rw [hcls]; rfl)
  have hpy : y.pending = M.pend p :: rest.map M.pend := by rw [hr.pending, hpx]; rfl
  have hresy : (M.pend p).res = some (outs.map M.node) := by
    show p.res.map (·.map M.node) = _; rw [hres]; rfl
  have hclsy : y.obj? (M.pend p).cls = some (.clo (.compiled (M.region cb) (M.arg pl) sl (ts.map M.trace))) := by
    show y.obj? (M.handle p.cls) = _; rw [hr.obj? hpc, hcls]; rfl
  have hfull : ∀ i ∈ order, Full P i := fun i hi => .inl (hOrd' i hi).1
  have htopoy : Host.Mlx.Ffi.topo y (M.pend p).tracers 4096 ((outs.map M.node).map (·, false)) [] [] =
      some (order.map M.node) := by
    have := hr.topo_map hT' 4096 (outs.map (·, false)) [] [] order (by simp) (by simp)
      (fun q hq ht => by obtain ⟨i, -, rfl⟩ := List.mem_map.mp hq; cases ht) htopo hfull
    have e : (outs.map (·, false)).map (fun q => (M.node q.1, q.2)) = (outs.map M.node).map (·, false) := by
      rw [List.map_map, List.map_map]; rfl
    rw [e] at this
    exact this
  have hk2 : (sl && (order.map M.node).any (kernAt y)) = false := by
    rw [hr.anyKernel fun i hi => ⟨(hOrd' i hi).2, hfull i hi⟩]; exact hk1
  unfold Host.Mlx.Ffi.back
  rw [traceBack_eq hpx ha0 hres hcls htopo, traceBack_eq hpy (ha.trans ha0) hresy hclsy htopoy, hk1, hk2,
    Bool.cond_false, Bool.cond_false]
  -- the closure with the new trace, the pending trace popped
  let t : Trace := ⟨p.tracers, outs, order⟩
  let o : NObj := .clo (.compiled cb pl sl (ts ++ [t]))
  have htr : ∀ i ∈ objTraces o, i < P.NL := by
    intro i hi
    obtain ⟨t', ht', hit⟩ := List.mem_flatMap.mp hi
    rcases List.mem_append.mp ht' with ht' | ht'
    · exact hr.traced p.cls _ hcls i (List.mem_flatMap.mpr ⟨t', ht', hit⟩)
    · rw [List.mem_singleton.mp ht'] at hit; exact (hOrd' i hit).1
  have hr1 := (hr.setObj hpc o (hr.cl.2.1 p.cls (.clo (.compiled cb pl sl ts)) hcls) (fun c h => by simp [o] at h)
    htr).setPend rest
  have eo : M.nobj o = .clo (.compiled (M.region cb) (M.arg pl) sl (ts.map M.trace ++ [M.trace t])) := by
    simp only [o, Map.nobj, Map.clo, List.map_append, List.map_cons, List.map_nil]
  rw [eo] at hr1
  have gx := PTrie.gs x.objs p.cls o (hr.PH_lt hpc)
  have hsl' : p.outSlot = 0 ∨ PH { x.setObj p.cls o with pending := rest } p.outSlot := by
    rcases hsl with h | h
    · exact .inl h
    · right
      rcases h with h | h
      · exact .inl h
      · right
        show ((x.objs.set p.cls o).get p.outSlot).isSome = true
        rw [gx]
        by_cases e : p.outSlot = p.cls
        · simp [e]
        · simp only [e, ↓reduceIte]; exact h
  have hfound : backFound x a = some ({ x.setObj p.cls o with pending := rest }, p.cls, t, p.ins) := by
    unfold backFound
    rw [hpx, ha0]
    simp only [hres, hcls, htopo]
    rfl
  have eback : Host.Mlx.Ffi.back x a = Host.Mlx.Ffi.applyDone { x.setObj p.cls o with pending := rest } p.cls
      p.outBuf p.outOff p.outSlot t p.ins := by
    unfold Host.Mlx.Ffi.back
    rw [traceBack_eq hpx ha0 hres hcls htopo, hk1, Bool.cond_false]
  exact hfin hr1 hck hT' hI' hO' hRoom' hsl' hE' (fun i hi => (hOrd' i hi).1) hfound eback

/-- **A trace continuation** the template's check accepts (`backOkG`). -/
theorem sim_traceBack {a : Arg} (hok : backOkG P x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.back x a) (Host.Mlx.Ffi.back y (M.arg a)) :=
  sim_traceBackR hr hok fun hr1 hck hT hI hO hR hsl hE _ _ _ => sim_applyDone hs hr1 hck hT hI hO hR hsl hE

/-- **A trace continuation over symbolic shapes** (`backOkV`), under its numeric premise. -/
theorem sim_traceBackV {a : Arg} (hok : backOkV P x a = true) (hsm : backSmall ν S x a) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.back x a) (Host.Mlx.Ffi.back y (M.arg a)) := by
  refine sim_traceBackR hr hok fun {x1 y1 c b off sl t xs} hr1 hck hT hI hO hR hsl hE hband hfound eback => ?_
  rw [Bool.and_eq_true, Bool.not_eq_true'] at hck
  obtain ⟨hwk, hnr⟩ := hck
  obtain ⟨L, hwL⟩ := Option.isSome_iff_exists.mp hwk
  have hbs : backSym x a = true := by unfold backSym; rw [hfound]; simp only [hnr, Bool.not_false]
  obtain ⟨hrefs, hrun⟩ := hsm hbs
  have hLv : ∀ b ∈ L, ∀ nd, x1.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks := by
    intro b hb nd hn
    have hval := rwalk_valued _ _ _ hwL b hb
    unfold valuedN at hval; rw [hn] at hval
    refine dvss_of hs hval fun j hj => hrefs j ?_
    unfold backRefs; rw [hfound]; dsimp only; rw [hwL]
    exact List.mem_flatMap.mpr ⟨b, hb, by unfold nodeRefs; rw [hn]; exact hj⟩
  rw [eback] at hrun
  exact sim_applyDoneV hs hr1 hwL hband hLv hrun hT hI hO hR hsl hE

end

end Host.Ts.Sim.G
