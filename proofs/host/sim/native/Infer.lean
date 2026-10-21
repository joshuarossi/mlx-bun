import host.sim.native.Args
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Shape inference on literal shapes is pure

On literal dimensions every dimension operation of the mlx model takes its
integer fast path, so shape inference issues no number request: it is a pure
computation (`PureP`) whose results are literal again. Literal primitives
are their own images, so the source and target infer the same result. -/

/-- A pure computation whose value satisfies `Q`. -/
def PureP {α : Type} (m : Host.Ts.M α) (Q : α → Prop) : Prop :=
  ∃ a, Q a ∧ ∀ (γ : Type) (k : α → Free γ), m γ k = k a

namespace PureP
variable {α β : Type} {Q : α → Prop} {R : β → Prop}

theorem pure {a : α} (h : Q a) : PureP (Host.Ts.M.pure a) Q := ⟨a, h, fun _ _ => rfl⟩

theorem bind {m : Host.Ts.M α} {f : α → Host.Ts.M β} (hm : PureP m Q) (hf : ∀ a, Q a → PureP (f a) R) :
    PureP (Host.Ts.M.bind m f) R := by
  obtain ⟨a, ha, e⟩ := hm
  obtain ⟨b, hb, e'⟩ := hf a ha
  exact ⟨b, hb, fun γ k => by show m γ (fun x => f x γ k) = k b; rw [e]; exact e' γ k⟩

theorem mono {m : Host.Ts.M α} (h : PureP m Q) {Q' : α → Prop} (hq : ∀ a, Q a → Q' a) : PureP m Q' := by
  obtain ⟨a, ha, e⟩ := h; exact ⟨a, hq a ha, e⟩

theorem cond (c : Bool) {m1 m2 : Host.Ts.M α} (h1 : PureP m1 Q) (h2 : PureP m2 Q) :
    PureP (bif c then m1 else m2) Q := by cases c <;> assumption
end PureP

/-- Literal dimension lists. -/
abbrev Lits (ds : List Dim) : Prop := ds.all dimLit = true

theorem Lits.nil : Lits [] := rfl
theorem Lits.cons {d : Dim} {ds : List Dim} : Lits (d :: ds) ↔ dimLit d = true ∧ Lits ds := by
  simp [Lits, List.all_cons]
theorem Lits.mem {ds : List Dim} (h : Lits ds) {d : Dim} (hd : d ∈ ds) : dimLit d = true :=
  List.all_eq_true.mp h d hd
theorem Lits.of_mem {ds : List Dim} (h : ∀ d ∈ ds, dimLit d = true) : Lits ds := List.all_eq_true.mpr h
theorem Lits.append {a b : List Dim} (ha : Lits a) (hb : Lits b) : Lits (a ++ b) :=
  Lits.of_mem fun d hd => (List.mem_append.mp hd).elim (ha.mem ·) (hb.mem ·)
theorem Lits.reverse {a : List Dim} (ha : Lits a) : Lits a.reverse :=
  Lits.of_mem fun d hd => ha.mem (List.mem_reverse.mp hd)
theorem Lits.take {a : List Dim} (ha : Lits a) (k : Nat) : Lits (a.take k) :=
  Lits.of_mem fun d hd => ha.mem (List.mem_of_mem_take hd)
theorem Lits.drop {a : List Dim} (ha : Lits a) (k : Nat) : Lits (a.drop k) :=
  Lits.of_mem fun d hd => ha.mem (List.mem_of_mem_drop hd)

theorem nthD_lit {a : List Dim} (ha : Lits a) : ∀ i, dimLit (nthD (.lit 0) a i) = true := by
  induction a with
  | nil => intro i; rfl
  | cons d ds ih =>
    intro i
    have h := Lits.cons.mp ha
    cases i with
    | zero => exact h.1
    | succ i => exact ih h.2 i

theorem setAt_lit {a : List Dim} (ha : Lits a) {v : Dim} (hv : dimLit v = true) :
    ∀ i, Lits (Host.Mlx.Ffi.setAt a i v) := by
  induction a with
  | nil => intro i; rfl
  | cons d ds ih =>
    intro i
    have h := Lits.cons.mp ha
    cases i with
    | zero => exact Lits.cons.mpr ⟨hv, h.2⟩
    | succ i => exact Lits.cons.mpr ⟨h.1, ih h.2 i⟩

theorem Lits.map_axes {s : List Dim} (hs : Lits s) (axes : List Nat) : Lits (axes.map (nthD (.lit 0) s)) :=
  Lits.of_mem fun d hd => by
    obtain ⟨i, _, rfl⟩ := List.mem_map.mp hd
    exact nthD_lit hs i

/-! ## Dimension operations -/

section
variable {a b : Dim} (ha : dimLit a = true) (hb : dimLit b = true)
include ha hb

theorem dEq_pure : PureP (Host.Mlx.Ffi.dEq a b) (fun _ => True) := by
  cases a with
  | sym _ => cases ha
  | lit _ => cases b with
    | sym _ => cases hb
    | lit _ => exact ⟨_, trivial, fun _ _ => rfl⟩

theorem dLt_pure : PureP (Host.Mlx.Ffi.dLt a b) (fun _ => True) := by
  cases a with
  | sym _ => cases ha
  | lit _ => cases b with
    | sym _ => cases hb
    | lit _ => exact ⟨_, trivial, fun _ _ => rfl⟩

theorem dAdd_pure : PureP (Host.Mlx.Ffi.dAdd a b) (dimLit · = true) := by
  cases a with
  | sym _ => cases ha
  | lit _ => cases b with
    | sym _ => cases hb
    | lit _ => exact ⟨_, rfl, fun _ _ => rfl⟩

theorem dSub_pure : PureP (Host.Mlx.Ffi.dSub a b) (dimLit · = true) := by
  cases a with
  | sym _ => cases ha
  | lit _ => cases b with
    | sym _ => cases hb
    | lit _ => exact ⟨_, rfl, fun _ _ => rfl⟩

theorem dMul_pure : PureP (Host.Mlx.Ffi.dMul a b) (dimLit · = true) := by
  cases a with
  | sym _ => cases ha
  | lit _ => cases b with
    | sym _ => cases hb
    | lit _ => exact ⟨_, rfl, fun _ _ => rfl⟩

theorem dMin_pure : PureP (Host.Mlx.Ffi.dMin a b) (dimLit · = true) :=
  PureP.bind (dLt_pure ha hb) fun l _ => PureP.pure (by cases l <;> assumption)

theorem dMax_pure : PureP (Host.Mlx.Ffi.dMax a b) (dimLit · = true) :=
  PureP.bind (dLt_pure ha hb) fun l _ => PureP.pure (by cases l <;> assumption)
end

theorem allEq_pure : ∀ (xs ys : List Dim), Lits xs → Lits ys → PureP (Host.Mlx.Ffi.allEq xs ys) (fun _ => True)
  | [], [], _, _ => ⟨_, trivial, fun _ _ => rfl⟩
  | [], _ :: _, _, _ => ⟨_, trivial, fun _ _ => rfl⟩
  | _ :: _, [], _, _ => ⟨_, trivial, fun _ _ => rfl⟩
  | x :: xs, y :: ys, hx, hy => by
    have hx' := Lits.cons.mp hx
    have hy' := Lits.cons.mp hy
    exact PureP.bind (dEq_pure hx'.1 hy'.1) fun e _ =>
      PureP.cond e (allEq_pure xs ys hx'.2 hy'.2) (PureP.pure trivial)

theorem dProd_pure : ∀ (ds : List Dim), Lits ds → PureP (Host.Mlx.Ffi.dProd ds) (dimLit · = true)
  | [], _ => ⟨_, rfl, fun _ _ => rfl⟩
  | d :: ds, h => by
    have h' := Lits.cons.mp h
    exact PureP.bind (dProd_pure ds h'.2) fun p hp => dMul_pure h'.1 hp

/-- Optional literal lists. -/
def OptLits (r : Option (List Dim)) : Prop := ∀ l, r = some l → Lits l

theorem broadcast_go_pure : ∀ (xs ys : List Dim), Lits xs → Lits ys →
    PureP (Host.Mlx.Ffi.broadcast.go xs ys) OptLits
  | [], ys, _, hy => ⟨_, (fun l h => by cases h; exact hy.reverse), fun _ _ => rfl⟩
  | x :: xs, [], hx, _ => ⟨_, (fun l h => by cases h; exact hx.reverse), fun _ _ => rfl⟩
  | x :: xs, y :: ys, hx, hy => by
    have hx' := Lits.cons.mp hx
    have hy' := Lits.cons.mp hy
    have ih := broadcast_go_pure xs ys hx'.2 hy'.2
    have k : ∀ z, dimLit z = true →
        PureP (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast.go xs ys) fun r => Host.Ts.M.pure (r.map (· ++ [z]))) OptLits :=
      fun z hz => PureP.bind ih fun r hr => PureP.pure fun l hl => by
        cases r with
        | none => cases hl
        | some r => cases hl; exact (hr r rfl).append (Lits.cons.mpr ⟨hz, rfl⟩)
    exact PureP.bind (dEq_pure hx'.1 hy'.1) fun e _ =>
      PureP.cond e (k x hx'.1) (PureP.cond _ (k y hy'.1) (PureP.cond _ (k x hx'.1)
        (PureP.pure fun l h => by cases h)))

theorem broadcast_pure {a b : List Dim} (ha : Lits a) (hb : Lits b) :
    PureP (Host.Mlx.Ffi.broadcast a b) OptLits :=
  PureP.bind (broadcast_go_pure _ _ ha.reverse hb.reverse) fun r hr => PureP.pure hr

theorem sliceAxis_pure {n s e k : Dim} (hn : dimLit n = true) (hs : dimLit s = true) (he : dimLit e = true)
    (hk : dimLit k = true) :
    PureP (Host.Mlx.Ffi.sliceAxis n s e k) (fun r => ∀ d, r = some d → dimLit d = true) := by
  have l0 : dimLit (.lit 0) = true := rfl
  unfold Host.Mlx.Ffi.sliceAxis
  refine PureP.bind (dLt_pure hs l0) fun sn _ => ?_
  refine PureP.bind (Q := (dimLit · = true)) (PureP.cond sn (dAdd_pure hs hn) (PureP.pure hs)) fun s1 hs1 => ?_
  refine PureP.bind (dLt_pure he l0) fun en _ => ?_
  refine PureP.bind (Q := (dimLit · = true)) (PureP.cond en (dAdd_pure he hn) (PureP.pure he)) fun e1 he1 => ?_
  refine PureP.bind (dMin_pure hs1 hn) fun st hst => ?_
  refine PureP.bind (dMax_pure l0 hst) fun st hst => ?_
  refine PureP.bind (dMin_pure he1 hn) fun ed hed => ?_
  refine PureP.bind (dMax_pure l0 hed) fun ed hed => ?_
  refine PureP.bind (dLt_pure hed hst) fun lt _ => ?_
  have hed' : dimLit (bif lt then st else ed) = true := by cases lt <;> assumption
  cases k with
  | sym _ => cases hk
  | lit kk =>
    cases st with
    | sym _ => cases hst
    | lit b =>
      generalize hE : (bif lt then Dim.lit b else ed) = E at hed'
      cases E with
      | sym _ => cases hed'
      | lit a =>
        simp only
        split
        · exact PureP.bind (dSub_pure rfl rfl) fun r hr => PureP.pure fun d hd => by cases hd; exact hr
        · exact PureP.cond _ (PureP.pure fun d hd => by cases hd; rfl) (PureP.pure fun d hd => by cases hd)
        · exact PureP.pure fun d hd => by cases hd

theorem sliceShape_pure : ∀ (ns ss es ks : List Dim), Lits ns → Lits ss → Lits es → Lits ks →
    PureP (Host.Mlx.Ffi.sliceShape ns ss es ks) OptLits
  | [], [], [], [], _, _, _, _ => ⟨_, (fun l h => by cases h; rfl), fun _ _ => rfl⟩
  | n :: ns, s :: ss, e :: es, k :: ks, hn, hs, he, hk => by
    have hn' := Lits.cons.mp hn
    have hs' := Lits.cons.mp hs
    have he' := Lits.cons.mp he
    have hk' := Lits.cons.mp hk
    refine PureP.bind (sliceAxis_pure hn'.1 hs'.1 he'.1 hk'.1) fun r hr => ?_
    cases r with
    | none => exact PureP.pure fun l h => by cases h
    | some d =>
      exact PureP.bind (sliceShape_pure ns ss es ks hn'.2 hs'.2 he'.2 hk'.2) fun r' hr' => PureP.pure fun l h => by
        cases r' with
        | none => cases h
        | some l' => cases h; exact Lits.cons.mpr ⟨hr d rfl, hr' l' rfl⟩
  | [], [], [], _ :: _, _, _, _, _ => ⟨_, (fun l h => by cases h), fun _ _ => rfl⟩
  | [], [], _ :: _, _, _, _, _, _ => ⟨_, (fun l h => by cases h), fun _ _ => rfl⟩
  | [], _ :: _, _, _, _, _, _, _ => ⟨_, (fun l h => by cases h), fun _ _ => rfl⟩
  | _ :: _, [], _, _, _, _, _, _ => ⟨_, (fun l h => by cases h), fun _ _ => rfl⟩
  | _ :: _, _ :: _, [], _, _, _, _, _ => ⟨_, (fun l h => by cases h), fun _ _ => rfl⟩
  | _ :: _, _ :: _, _ :: _, [], _, _, _, _ => ⟨_, (fun l h => by cases h), fun _ _ => rfl⟩

theorem reshapeShape_pure {old new : List Dim} (ho : Lits old) (hn : Lits new) :
    PureP (Host.Mlx.Ffi.reshapeShape old new) OptLits := by
  unfold Host.Mlx.Ffi.reshapeShape
  refine PureP.bind (dProd_pure old ho) fun total ht => ?_
  have hf : Lits (new.filter (· ≠ .lit (-1))) := Lits.of_mem fun d hd => hn.mem (List.mem_filter.mp hd).1
  split
  · exact PureP.bind (dProd_pure new hn) fun p hp => PureP.bind (dEq_pure hp ht) fun e _ =>
      PureP.pure fun l h => by cases e <;> simp at h; subst h; exact hn
  · refine PureP.bind (dProd_pure _ hf) fun p hp => ?_
    cases total with
    | sym _ => cases ht
    | lit t =>
      cases p with
      | sym _ => cases hp
      | lit q =>
        simp only
        refine PureP.cond _ (PureP.pure fun l h => ?_) (PureP.pure fun l h => by cases h)
        cases h
        exact Lits.of_mem fun d hd => by
          obtain ⟨d0, h0, rfl⟩ := List.mem_map.mp hd
          cases decide (d0 = .lit (-1)) <;> first | rfl | exact hn.mem h0
  · exact PureP.pure fun l h => by cases h

theorem concatShape_pure (axis : Nat) : ∀ (xs : List (List Dim × Nat)), (∀ p ∈ xs, Lits p.1) →
    PureP (Host.Mlx.Ffi.concatShape axis xs) (fun r => ∀ s d, r = some (s, d) → Lits s)
  | [], _ => ⟨_, (fun s d h => by cases h), fun _ _ => rfl⟩
  | [(s, d)], h => ⟨_, (fun s' d' e => by cases e; exact h _ (List.mem_singleton_self _)), fun _ _ => rfl⟩
  | (s, d) :: q :: rest, h => by
    have hs := h _ (List.mem_cons_self ..)
    refine PureP.bind (concatShape_pure axis (q :: rest) fun p hp => h p (List.mem_cons_of_mem _ hp)) fun r hr => ?_
    cases r with
    | none => exact PureP.pure fun s d e => by cases e
    | some rd =>
      obtain ⟨r, dr⟩ := rd
      have hr' := hr r dr rfl
      simp only
      refine PureP.cond _ ?_ (PureP.pure fun s d e => by cases e)
      refine PureP.bind (allEq_pure _ _ (setAt_lit hs rfl axis) (setAt_lit hr' rfl axis)) fun e _ => ?_
      refine PureP.cond e ?_ (PureP.pure fun s d e => by cases e)
      exact PureP.bind (dAdd_pure (nthD_lit hs axis) (nthD_lit hr' axis)) fun a ha =>
        PureP.pure fun s' d' e => by cases e; exact setAt_lit hs ha axis

/-! ## Shape inference -/

/-- Primitives whose dimension parameters are literal. -/
def primLit : Prim → Bool
  | .reshape s => s.all dimLit
  | .slice a b c => a.all dimLit && b.all dimLit && c.all dimLit
  | .sliceUpdate a b c => a.all dimLit && b.all dimLit && c.all dimLit
  | .sliceDynamic _ sz => sz.all dimLit
  | .replayed _ p => primLit p
  | _ => true

/-- An inferred output with a literal shape. -/
def OutLit : Option Host.Mlx.Ffi.Out → Prop
  | some (.node s _) => Lits s
  | _ => True

/-- Literal shapes of inputs. -/
def ShLits (sh : List (List Dim × Nat)) : Prop := ∀ p ∈ sh, Lits p.1

theorem infer_mprim (M : Map) (p : Prim) (hp : primLit p = true) (sh : List (List Dim × Nat)) :
    Host.Mlx.Ffi.infer (M.prim p) sh = Host.Mlx.Ffi.infer p sh := by
  induction p generalizing sh with
  | reshape s => simp only [primLit] at hp; simp only [Map.prim, dims_lit M hp]
  | slice a b c =>
    simp only [primLit, Bool.and_eq_true] at hp
    simp only [Map.prim, dims_lit M hp.1.1, dims_lit M hp.1.2, dims_lit M hp.2]
  | sliceUpdate a b c =>
    simp only [primLit, Bool.and_eq_true] at hp
    simp only [Map.prim, dims_lit M hp.1.1, dims_lit M hp.1.2, dims_lit M hp.2]
  | sliceDynamic ax sz => simp only [primLit] at hp; simp only [Map.prim, dims_lit M hp]
  | replayed c q ih =>
    simp only [primLit] at hp
    show Host.Mlx.Ffi.infer (.replayed _ (M.prim q)) sh = Host.Mlx.Ffi.infer (.replayed c q) sh
    unfold Host.Mlx.Ffi.infer
    exact ih hp sh
  | rmsNorm e => rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨⟨w, dw⟩, _ | ⟨_, _⟩⟩⟩ <;> rfl
  | rope _ _ _ _ _ => rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩ <;> rfl
  | sdpa _ _ => rcases sh with _ | ⟨⟨q, dq⟩, _ | ⟨⟨k, dk⟩, _ | ⟨⟨v, dv⟩, _ | ⟨_, _⟩⟩⟩⟩ <;> rfl
  | _ => rfl

end Host.Ts.Sim

namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

private theorem pnone {m : Host.Ts.M (Option Host.Mlx.Ffi.Out)} (h : ∀ γ k, m γ k = k none) : PureP m OutLit :=
  ⟨none, trivial, h⟩

private theorem none_pure {α : Type} (Q : Option α → Prop) (hq : Q none) :
    PureP (Host.Ts.M.pure (none : Option α)) Q := PureP.pure hq

private theorem node_pure {s : List Dim} {d : Nat} (hs : Lits s) :
    PureP (Host.Ts.M.pure (some (Host.Mlx.Ffi.Out.node s d))) OutLit := PureP.pure hs

private theorem map_node_pure {d : Nat} :
    ∀ (r : Option (List Dim)), OptLits r → OutLit (r.map (Host.Mlx.Ffi.Out.node · d))
  | none, _ => trivial
  | some l, h => h l rfl

theorem infer_pure (p : Prim) (hp : primLit p = true) (sh : List (List Dim × Nat)) (hsh : ShLits sh) :
    PureP (Host.Mlx.Ffi.infer p sh) OutLit := by
  have L : ∀ s d, (s, d) ∈ sh → Lits s := fun s d h => hsh (s, d) h
  induction p generalizing sh with
  | replayed c q ih =>
    simp only [primLit] at hp
    show PureP (Host.Mlx.Ffi.infer q sh) OutLit
    exact ih hp sh hsh L
  | concat axis =>
    show PureP (bif Nat.beq (len sh) 1 then Host.Ts.M.pure (some (Host.Mlx.Ffi.Out.same 0)) else
      Host.Ts.M.bind (Host.Mlx.Ffi.concatShape axis sh) fun r => Host.Ts.M.pure (r.map fun (s, d) => .node s d)) OutLit
    refine PureP.cond _ (PureP.pure trivial) (PureP.bind (concatShape_pure axis sh hsh) fun r hr => PureP.pure ?_)
    cases r with
    | none => trivial
    | some q => obtain ⟨s, d⟩ := q; exact hr s d rfl
  | reshape new =>
    simp only [primLit] at hp
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · exact PureP.bind (reshapeShape_pure (L s d (List.mem_singleton_self _)) hp) fun r hr =>
        PureP.pure (map_node_pure r hr)
    · exact pnone fun _ _ => rfl
  | transpose axes =>
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · exact PureP.cond _ (node_pure (Lits.map_axes (L s d (List.mem_singleton_self _)) axes)) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | slice st sp sr =>
    simp only [primLit, Bool.and_eq_true] at hp
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · have hs := L s d (List.mem_singleton_self _)
      refine PureP.cond _ ?_ (PureP.pure trivial)
      refine PureP.bind (sliceShape_pure s st sp sr hs hp.1.1 hp.1.2 hp.2) fun r hr => ?_
      cases r with
      | none => exact PureP.pure trivial
      | some r =>
        exact PureP.bind (allEq_pure r s (hr r rfl) hs) fun e _ => PureP.pure (by cases e <;> first | trivial | exact hr r rfl)
    · exact pnone fun _ _ => rfl
  | sliceUpdate st sp sr =>
    simp only [primLit, Bool.and_eq_true] at hp
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨⟨u, du⟩, _ | ⟨_, _⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · have hs := L s d (List.mem_cons_self ..)
      have hu := L u du (List.mem_cons_of_mem _ (List.mem_singleton_self _))
      refine PureP.bind (sliceShape_pure s st sp sr hs hp.1.1 hp.1.2 hp.2) fun r hr => ?_
      cases r with
      | none => exact PureP.pure trivial
      | some r =>
        refine PureP.bind (broadcast_pure hu (hr r rfl)) fun b hb => ?_
        cases b with
        | none => exact PureP.pure trivial
        | some b =>
          exact PureP.bind (allEq_pure b r (hb b rfl) (hr r rfl)) fun ok _ =>
            PureP.cond ok (node_pure hs) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | sliceDynamic axes sizes =>
    simp only [primLit] at hp
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨⟨u, du⟩, _ | ⟨_, _⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · exact PureP.cond _ (node_pure hp) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | unary op =>
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · exact node_pure (L s d (List.mem_singleton_self _))
    · exact pnone fun _ _ => rfl
  | binary op =>
    rcases sh with _ | ⟨⟨a, da⟩, _ | ⟨⟨b, db⟩, _ | ⟨_, _⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · exact PureP.bind (broadcast_pure (L a da (List.mem_cons_self ..))
        (L b db (List.mem_cons_of_mem _ (List.mem_singleton_self _)))) fun r hr => PureP.pure (map_node_pure r hr)
    · exact pnone fun _ _ => rfl
  | astype dt =>
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · exact node_pure (L s d (List.mem_singleton_self _))
    · exact pnone fun _ _ => rfl
  | contiguous =>
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · exact node_pure (L s d (List.mem_singleton_self _))
    · exact pnone fun _ _ => rfl
  | rmsNorm eps =>
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨⟨w, dw⟩, _ | ⟨_, _⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact PureP.cond _ (node_pure (L s d (List.mem_singleton_self _))) (PureP.pure trivial)
    · have hs := L s d (List.mem_cons_self ..)
      have hw := L w dw (List.mem_cons_of_mem _ (List.mem_singleton_self _))
      rcases w with _ | ⟨m, _ | ⟨_, _⟩⟩
      · exact pnone fun _ _ => rfl
      · show PureP (Host.Ts.M.bind (Host.Mlx.Ffi.dEq m (nthD (.lit 0) s (len s - 1))) _) OutLit
        exact PureP.bind (dEq_pure (Lits.cons.mp hw).1 (nthD_lit hs _)) fun e _ =>
          PureP.cond _ (node_pure hs) (pnone fun _ _ => rfl)
      · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
  | rope _ _ _ _ _ =>
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · exact PureP.cond _ (node_pure (L s d (List.mem_singleton_self _))) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | sdpa _ _ =>
    rcases sh with _ | ⟨⟨q, dq⟩, _ | ⟨⟨k, dk⟩, _ | ⟨⟨v, dv⟩, _ | ⟨_, _⟩⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · have hq := L q dq (List.mem_cons_self ..)
      have hv := L v dv (by simp)
      exact PureP.cond _ (node_pure (setAt_lit hq (nthD_lit hv 3) 3)) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | qmm tr g b mode =>
    rcases sh with _ | ⟨⟨x, dx⟩, _ | ⟨⟨w, dw⟩, _ | ⟨⟨sc, dsc⟩, _ | ⟨⟨bi, dbi⟩, _ | ⟨_, _⟩⟩⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · have hx := L x dx (List.mem_cons_self ..)
      have hw := L w dw (by simp)
      have hsc := L sc dsc (by simp)
      have hbi := L bi dbi (by simp)
      refine PureP.cond _ (PureP.pure trivial) ?_
      simp only
      generalize hwl : nthD (Dim.lit 0) w (len w - 1) = wl
      generalize hw2 : nthD (Dim.lit 0) w (len w - 2) = w2
      have l1 : dimLit wl = true := hwl ▸ nthD_lit hw _
      have l2 : dimLit w2 = true := hw2 ▸ nthD_lit hw _
      cases wl with
      | sym _ => cases l1
      | lit a =>
        cases w2 with
        | sym _ => cases l2
        | lit c =>
          simp only
          exact PureP.bind (dEq_pure (nthD_lit hx _) rfl) fun e _ =>
            PureP.bind (allEq_pure sc bi hsc hbi) fun sb _ =>
              PureP.cond _ (node_pure (setAt_lit hx rfl _)) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | dequantize g b mode dt =>
    rcases sh with _ | ⟨⟨w, dw⟩, _ | ⟨⟨sc, dsc⟩, _ | ⟨⟨bi, dbi⟩, _ | ⟨_, _⟩⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · have hw := L w dw (List.mem_cons_self ..)
      have hsc := L sc dsc (by simp)
      have hbi := L bi dbi (by simp)
      refine PureP.cond _ (PureP.pure trivial) ?_
      generalize hwl : nthD (Dim.lit 0) w (len w - 1) = wl
      have l1 : dimLit wl = true := hwl ▸ nthD_lit hw _
      cases wl with
      | sym _ => cases l1
      | lit a =>
        simp only
        exact PureP.bind (allEq_pure sc bi hsc hbi) fun sb _ =>
          PureP.cond _ (node_pure (setAt_lit hw rfl _)) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | take axis =>
    rcases sh with _ | ⟨⟨a, d⟩, _ | ⟨⟨i, di⟩, _ | ⟨_, _⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · have ha := L a d (List.mem_cons_self ..)
      have hi := L i di (by simp)
      exact PureP.cond _ (node_pure ((ha.take _).append hi |>.append (ha.drop _))) (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | conv1d st pd dl gr =>
    rcases sh with _ | ⟨⟨x, dx⟩, _ | ⟨⟨w, dw⟩, _ | ⟨_, _⟩⟩⟩
    · exact pnone fun _ _ => rfl
    · exact pnone fun _ _ => rfl
    · have hx := L x dx (List.mem_cons_self ..)
      have hw := L w dw (by simp)
      rcases x with _ | ⟨n0, _ | ⟨l0, _ | ⟨c0, _ | ⟨_, _⟩⟩⟩⟩ <;>
        try exact pnone fun _ _ => rfl
      rcases w with _ | ⟨o0, _ | ⟨k0, _ | ⟨ci0, _ | ⟨_, _⟩⟩⟩⟩ <;>
        try exact pnone fun _ _ => rfl
      simp only [Lits.cons] at hx hw
      obtain ⟨hn0, hl0, hc0, -⟩ := hx
      obtain ⟨ho0, hk0, hci0, -⟩ := hw
      cases l0 with
      | sym _ => cases hl0
      | lit l =>
        cases k0 with
        | sym _ => cases hk0
        | lit k =>
          cases c0 with
          | sym _ => cases hc0
          | lit c =>
            cases ci0 with
            | sym _ => cases hci0
            | lit ci =>
              exact PureP.cond _ (node_pure (Lits.cons.mpr ⟨hn0, Lits.cons.mpr ⟨rfl, Lits.cons.mpr ⟨ho0, rfl⟩⟩⟩))
                (PureP.pure trivial)
    · exact pnone fun _ _ => rfl
  | logsumexp axis keep =>
    rcases sh with _ | ⟨⟨s, d⟩, _ | ⟨_, _⟩⟩
    · exact pnone fun _ _ => rfl
    · have hs := L s d (List.mem_singleton_self _)
      refine PureP.cond _ (node_pure ?_) (PureP.pure trivial)
      cases keep
      · exact (hs.take _).append (hs.drop _)
      · exact setAt_lit hs rfl _
    · exact pnone fun _ _ => rfl
  | _ => exact pnone fun _ _ => rfl

end Host.Ts.Sim
