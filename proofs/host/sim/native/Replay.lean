import host.sim.native.Ops
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Compiled-closure applies (`mlx_closure_apply`) on literal shapes

A compiled closure's traces name pre-loop nodes (below `P.NL`), which map
identically with full correspondence. An apply finds the trace matching its
inputs and replays the traced nodes in order over the substituted inputs: the
target replays the same traces over the imaged inputs, each step adding the
imaged node. Every node the replay reads has a literal shape, and every
traced primitive literal parameters, so shape inference is pure and agrees. -/

/-- The substitution map on the target. -/
def Map.subst (M : Map) (m : List (Nat × Nat)) : List (Nat × Nat) := m.map fun p => (p.1, M.node p.2)

/-- Leaf primitives the replay shares. -/
def leafP : Prim → Bool
  | .data _ | .load _ _ | .zeros | .arange _ _ _ | .tracer _ => true
  | _ => false

theorem leafP_mprim (M : Map) (p : Prim) : leafP (M.prim p) = leafP p := by cases p <;> rfl

theorem isKernel_mprim (M : Map) (p : Prim) : Host.Mlx.Ffi.isKernel (M.prim p) = Host.Mlx.Ffi.isKernel p := by
  induction p with
  | replayed c q ih => exact ih
  | _ => rfl

/-- The replay of a non-leaf traced node (the body of `replayOrder`). -/
def replayStep (s : NSt) (cls : Nat) (m : List (Nat × Nat)) (n : Nat) (ns : List Nat) (nd : Node) :
    Host.Ts.M (Option (NSt × List (Nat × Nat))) :=
  bif Host.Mlx.Ffi.isKernel nd.prim then
    let (k, s) := s.addNode ⟨.replayed cls nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), nd.shape, nd.dtype⟩
    Host.Mlx.Ffi.replayOrder s cls ((n, k) :: m) ns
  else
  let ins := nd.ins.map (Host.Mlx.Ffi.substOf m)
  bif decide (ins = nd.ins) then Host.Mlx.Ffi.replayOrder s cls m ns else
  match Host.Mlx.Ffi.shapesOf s ins with
  | some sh => .bind (Host.Mlx.Ffi.infer nd.prim sh) fun
    | some (.node shape dt) => let (k, s) := s.addNode ⟨.replayed cls nd.prim, ins, shape, dt⟩
      Host.Mlx.Ffi.replayOrder s cls ((n, k) :: m) ns
    | some (.same i) => match nth? ins i with
      | some k => Host.Mlx.Ffi.replayOrder s cls ((n, k) :: m) ns
      | none => .pure none
    | none => .pure none
  | none => .pure none

theorem replayOrder_cons (s : NSt) (cls : Nat) (m : List (Nat × Nat)) (n : Nat) (ns : List Nat) :
    Host.Mlx.Ffi.replayOrder s cls m (n :: ns) = match s.nodes.get n with
      | some nd => bif leafP nd.prim then Host.Mlx.Ffi.replayOrder s cls m ns else replayStep s cls m n ns nd
      | none => .pure none := by
  conv => lhs; unfold Host.Mlx.Ffi.replayOrder
  cases s.nodes.get n with
  | none => rfl
  | some nd =>
    obtain ⟨p, ins, shape, dt⟩ := nd
    cases p <;> rfl

/-- A present node with a literal shape. -/
def litNode (x : NSt) (k : Nat) : Bool :=
  match x.nodes.get k with
  | some nd => nd.shape.all dimLit
  | none => false

/-- A traced node the replay may rebuild: pre-loop, literal, with pre-loop literal inputs. -/
def rnodeOk (P : LoadP) (x : NSt) (n : Nat) : Bool :=
  decide (n < P.NL) && match x.nodes.get n with
    | some nd => primLit nd.prim && nd.shape.all dimLit && nd.ins.all fun a => decide (a < P.NL) && litNode x a
    | none => false

/-- A trace the replay may follow. -/
def traceOk (P : LoadP) (x : NSt) (t : Trace) : Bool :=
  t.ins.all (fun a => decide (a < P.NL) && litNode x a) && t.outs.all (fun a => decide (a < P.NL)) &&
    t.order.all (rnodeOk P x) && decide (x.nnext + t.order.length ≤ P.NE)

/-- Nodes are only appended. -/
def NGrow (x x' : NSt) : Prop := x.nnext ≤ x'.nnext ∧ ∀ i, i < x.nnext → x'.nodes.get i = x.nodes.get i

theorem NGrow.refl (x : NSt) : NGrow x x := ⟨Nat.le_refl _, fun _ _ => rfl⟩

theorem NGrow.trans {x x' x'' : NSt} (h : NGrow x x') (h' : NGrow x' x'') : NGrow x x'' :=
  ⟨Nat.le_trans h.1 h'.1, fun i hi => (h'.2 i (Nat.lt_of_lt_of_le hi h.1)).trans (h.2 i hi)⟩

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

theorem MR.litNode_grow {x' : NSt} (hg : NGrow x x') {k : Nat} (h : litNode x k = true) : litNode x' k = true := by
  unfold litNode at h ⊢
  cases hk : x.nodes.get k with
  | none => rw [hk] at h; cases h
  | some nd =>
    rw [hk] at h
    rw [hg.2 k (hr.nlt k (by show (x.nodes.get k).isSome = true; rw [hk]; rfl)), hk]
    exact h

theorem MR.rnodeOk_grow {x' : NSt} (hg : NGrow x x') {a : Nat} (h : rnodeOk P x a = true) : rnodeOk P x' a = true := by
  unfold rnodeOk at h ⊢
  rw [Bool.and_eq_true] at h ⊢
  refine ⟨h.1, ?_⟩
  have h2 := h.2
  cases hk : x.nodes.get a with
  | none => rw [hk] at h2; cases h2
  | some nd =>
    rw [hk] at h2
    rw [hg.2 a (hr.nlt a (by show (x.nodes.get a).isSome = true; rw [hk]; rfl)), hk]
    rw [Bool.and_eq_true] at h2 ⊢
    refine ⟨h2.1, List.all_eq_true.mpr fun b hb => ?_⟩
    have := List.all_eq_true.mp h2.2 b hb
    rw [Bool.and_eq_true] at this ⊢
    exact ⟨this.1, hr.litNode_grow hg this.2⟩

omit hr in
theorem MR.litNode_present {k : Nat} (h : litNode x k = true) : PN x k := by
  unfold litNode at h
  cases hk : x.nodes.get k with
  | none => rw [hk] at h; cases h
  | some _ => show (x.nodes.get k).isSome = true; rw [hk]; rfl

/-- Adding a node. -/
def addN (x : NSt) (nd : Node) : NSt := { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext nd }

theorem MR.ngrow_addN (nd : Node) : NGrow x (addN x nd) :=
  ⟨Nat.le_succ _, fun i hi => by
    show (x.nodes.set x.nnext nd).get i = _
    rw [PTrie.gs _ _ _ hr.xnnext_lt]; simp [Nat.ne_of_lt hi]⟩

theorem MR.litNode_addN (nd : Node) (h : nd.shape.all dimLit = true) : litNode (addN x nd) x.nnext = true := by
  show (match (x.nodes.set x.nnext nd).get x.nnext with | some nd => nd.shape.all dimLit | none => false) = true
  rw [PTrie.gs _ _ _ hr.xnnext_lt]; simpa using h

end

theorem shapesOf_lit {x : NSt} : ∀ {l : List Nat}, (∀ b ∈ l, litNode x b = true) →
    ∃ sh, Host.Mlx.Ffi.shapesOf x l = some sh ∧ ShLits sh
  | [], _ => ⟨[], rfl, fun _ h => by cases h⟩
  | b :: l, h => by
    have hb := h b (List.mem_cons_self ..)
    unfold litNode at hb
    cases hk : x.nodes.get b with
    | none => rw [hk] at hb; cases hb
    | some nd =>
      rw [hk] at hb
      obtain ⟨sh, e, hl⟩ := shapesOf_lit (fun c hc => h c (List.mem_cons_of_mem _ hc))
      refine ⟨(nd.shape, nd.dtype) :: sh, by simp only [Host.Mlx.Ffi.shapesOf, hk, e]; rfl, fun q hq => ?_⟩
      rcases List.mem_cons.mp hq with rfl | hq
      · exact hb
      · exact hl q hq

theorem substOf_map (M : Map) {NL : Nat} (hid : ∀ j, j < NL → M.node j = j) :
    ∀ (m : List (Nat × Nat)), (∀ p ∈ m, p.1 < NL) → ∀ a, a < NL →
      Host.Mlx.Ffi.substOf (M.subst m) a = M.node (Host.Mlx.Ffi.substOf m a)
  | [], _, a, ha => by simp [Host.Mlx.Ffi.substOf, Map.subst, hid a ha]
  | (b, k) :: m, hk, a, ha => by
    have ih := substOf_map M hid m (fun p hp => hk p (List.mem_cons_of_mem _ hp)) a ha
    unfold Host.Mlx.Ffi.substOf at ih ⊢
    simp only [Map.subst, List.map_cons, List.find?_cons] at ih ⊢
    cases Nat.beq b a
    · exact ih
    · rfl

theorem substOf_mem (m : List (Nat × Nat)) (a : Nat) :
    Host.Mlx.Ffi.substOf m a = a ∨ ∃ p ∈ m, Host.Mlx.Ffi.substOf m a = p.2 := by
  unfold Host.Mlx.Ffi.substOf
  cases h : m.find? (fun (q : Nat × Nat) => Nat.beq q.1 a) with
  | none => left; rfl
  | some p => right; exact ⟨p, List.mem_of_find?_eq_some h, rfl⟩

theorem nth?_mem' {α : Type} : ∀ {l : List α} {i : Nat} {b : α}, nth? l i = some b → b ∈ l
  | [], _, _, h => by cases h
  | a :: _, 0, b, h => by cases h; exact List.mem_cons_self ..
  | _ :: l, i + 1, b, h => List.mem_cons_of_mem _ (nth?_mem' (l := l) (i := i) h)

/-- The result relation of a replay. -/
def RRel (P : LoadP) (M : Map) (n : Nat) (x : NSt) :
    Option (NSt × List (Nat × Nat)) → Option (NSt × List (Nat × Nat)) → Prop
  | none, none => True
  | some (x', m), some (y', m') => MR P M n x' y' ∧ m' = M.subst m ∧
      (∀ p ∈ m, p.1 < P.NL ∧ litNode x' p.2 = true) ∧ x'.next = x.next ∧ x'.arrs = x.arrs ∧ x'.objs = x.objs
  | _, _ => False

theorem map_inj_on {f : Nat → Nat} {Q : Nat → Prop} (hf : ∀ a b, Q a → Q b → f a = f b → a = b) :
    ∀ {l l' : List Nat}, (∀ a ∈ l, Q a) → (∀ a ∈ l', Q a) → l.map f = l'.map f → l = l'
  | [], [], _, _, _ => rfl
  | [], _ :: _, _, _, h => by cases h
  | _ :: _, [], _, _, h => by cases h
  | a :: l, b :: l', ha, hb, h => by
    simp only [List.map_cons, List.cons.injEq] at h
    rw [hf a b (ha a (List.mem_cons_self ..)) (hb b (List.mem_cons_self ..)) h.1,
      map_inj_on hf (fun c hc => ha c (List.mem_cons_of_mem _ hc)) (fun c hc => hb c (List.mem_cons_of_mem _ hc)) h.2]

section
variable {P : LoadP} {M : Map} {n : Nat}


theorem MR.replayOrder (c : Nat) (ns : List Nat) : ∀ {x y : NSt} (m : List (Nat × Nat)), MR P M n x y →
    (∀ a ∈ ns, rnodeOk P x a = true) → (∀ p ∈ m, p.1 < P.NL ∧ litNode x p.2 = true) →
    x.nnext + ns.length ≤ P.NE →
    ∃ r r', (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ), Host.Mlx.Ffi.replayOrder x c m ns γ k = k r) ∧
      (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
        Host.Mlx.Ffi.replayOrder y (M.handle c) (M.subst m) ns γ k = k r') ∧ RRel P M n x r r' := by
  induction ns with
  | nil =>
    intro x y m hr _ hm _
    exact ⟨some (x, m), some (y, M.subst m), fun _ _ => rfl, fun _ _ => rfl, hr, rfl, hm, rfl, rfl, rfl⟩
  | cons a ns ih =>
    intro x y m hr hns hm hroom
    have ha := hns a (List.mem_cons_self ..)
    have hns' : ∀ b ∈ ns, rnodeOk P x b = true := fun b hb => hns b (List.mem_cons_of_mem _ hb)
    have hroom' : x.nnext + ns.length ≤ P.NE := by simp at hroom; omega
    have lift : ∀ {x' : NSt} {r r' : Option (NSt × List (Nat × Nat))}, x'.next = x.next → x'.arrs = x.arrs →
        x'.objs = x.objs → RRel P M n x' r r' → RRel P M n x r r' := by
      intro x' r r' e1 e2 e3 h
      cases r with
      | none => cases r' with
        | none => trivial
        | some _ => exact h.elim
      | some q => cases r' with
        | none => exact h.elim
        | some q' =>
          obtain ⟨x'', mm⟩ := q
          obtain ⟨y'', mm'⟩ := q'
          obtain ⟨h1, h2, h3, h4, h5, h6⟩ := h
          exact ⟨h1, h2, h3, h4.trans e1, h5.trans e2, h6.trans e3⟩
    -- continue after binding `a` to a new node
    have cont : ∀ (nd0 : Node), nd0.shape.all dimLit = true → SNode (· < n) nd0 →
        ∃ r r', (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
          Host.Mlx.Ffi.replayOrder (addN x nd0) c ((a, x.nnext) :: m) ns γ k = k r) ∧
          (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
            Host.Mlx.Ffi.replayOrder (addN y (M.nnode nd0)) (M.handle c) ((a, y.nnext) :: M.subst m) ns γ k = k r') ∧
          RRel P M n x r r' := by
      intro nd0 hl hcl
      have hr1 : MR P M n (addN x nd0) (addN y (M.nnode nd0)) :=
        hr.addNode nd0 (by simp at hroom; omega) hcl (fun e he => dimCanon_lit M (List.all_eq_true.mp hl e he))
      have hg := hr.ngrow_addN nd0
      have hm' : ∀ p ∈ (a, x.nnext) :: m, p.1 < P.NL ∧ litNode (addN x nd0) p.2 = true := by
        intro p hp
        rcases List.mem_cons.mp hp with rfl | hp
        · have := (Bool.and_eq_true _ _).mp (by unfold rnodeOk at ha; exact ha)
          exact ⟨of_decide_eq_true this.1, hr.litNode_addN nd0 hl⟩
        · exact ⟨(hm p hp).1, hr.litNode_grow hg (hm p hp).2⟩
      obtain ⟨r, r', e1, e2, hrel⟩ := ih ((a, x.nnext) :: m) hr1 (fun b hb => hr.rnodeOk_grow hg (hns' b hb)) hm'
        (by show x.nnext + 1 + ns.length ≤ P.NE; simp at hroom; omega)
      refine ⟨r, r', e1, fun γ k => ?_, lift rfl rfl rfl hrel⟩
      have := e2 γ k
      simp only [Map.subst, List.map_cons, hr.node_next] at this
      exact this
    -- continue after binding `a` to an existing node
    have keep : ∀ kk, litNode x kk = true → a < P.NL →
        ∃ r r', (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
          Host.Mlx.Ffi.replayOrder x c ((a, kk) :: m) ns γ k = k r) ∧
          (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
            Host.Mlx.Ffi.replayOrder y (M.handle c) ((a, M.node kk) :: M.subst m) ns γ k = k r') ∧
          RRel P M n x r r' := by
      intro kk hkk haNL
      exact ih ((a, kk) :: m) hr hns' (fun p hp => by
        rcases List.mem_cons.mp hp with rfl | hp
        · exact ⟨haNL, hkk⟩
        · exact hm p hp) hroom'
    unfold rnodeOk at ha
    rw [Bool.and_eq_true] at ha
    have haNL : a < P.NL := of_decide_eq_true ha.1
    have hnd := ha.2
    cases hxa : x.nodes.get a with
    | none => rw [hxa] at hnd; cases hnd
    | some nd =>
      rw [hxa] at hnd
      rw [Bool.and_eq_true, Bool.and_eq_true] at hnd
      obtain ⟨⟨hpl, hsl⟩, hins⟩ := hnd
      have hins' : ∀ b ∈ nd.ins, b < P.NL ∧ litNode x b = true := fun b hb => by
        have := List.all_eq_true.mp hins b hb
        rw [Bool.and_eq_true] at this
        exact ⟨of_decide_eq_true this.1, this.2⟩
      obtain ⟨nd', hya, hs1, hd1, -, hf1⟩ := hr.nodes a nd hxa
      obtain ⟨hp1, hi1⟩ := hf1 (.inl haNL)
      rw [hr.nid a haNL] at hya
      have hinsNL : ∀ b ∈ nd.ins, b < P.NL := fun b hb => (hins' b hb).1
      have hinsId : nd.ins.map M.node = nd.ins := by
        conv => rhs; rw [← List.map_id nd.ins]
        exact List.map_congr_left fun b hb => hr.nid b (hinsNL b hb)
      have hmNL : ∀ p ∈ m, p.1 < P.NL := fun p hp => (hm p hp).1
      have hsubst : (nd.ins.map (Host.Mlx.Ffi.substOf (M.subst m))) = (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node := by
        rw [List.map_map]
        exact List.map_congr_left fun b hb => substOf_map M hr.nid m hmNL b (hinsNL b hb)
      have hsubLit : ∀ b ∈ nd.ins, litNode x (Host.Mlx.Ffi.substOf m b) = true := by
        intro b hb
        rcases substOf_mem m b with e | ⟨p, hp, e⟩
        · rw [e]; exact (hins' b hb).2
        · rw [e]; exact (hm p hp).2
      have hclp : SP (· < n) nd.prim := (hr.cl.1 a nd hxa).1
      have hsid : M.dims nd.shape = nd.shape := dims_lit M hsl
      rw [replayOrder_cons, replayOrder_cons, hxa, hya]
      simp only [hp1, leafP_mprim]
      cases hleaf : leafP nd.prim
      · simp only [Bool.cond_false]
        unfold replayStep
        simp only [hp1, isKernel_mprim, hi1, hinsId, hs1, hd1, hsid, hsubst]
        cases hk : Host.Mlx.Ffi.isKernel nd.prim
        · simp only [Bool.cond_false]
          have hpres : ∀ b ∈ nd.ins.map (Host.Mlx.Ffi.substOf m), PN x b := by
            intro b hb
            obtain ⟨b0, hb0, rfl⟩ := List.mem_map.mp hb
            exact MR.litNode_present (hsubLit b0 hb0)
          have hpres' : ∀ b ∈ nd.ins, PN x b := fun b hb => MR.litNode_present (hins' b hb).2
          have hdec : decide ((nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node = nd.ins) =
              decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins) :=
            decide_eq_decide.mpr ⟨fun h => map_inj_on (fun u v hu hv h => hr.ninj u v hu hv h) hpres hpres'
              (h.trans hinsId.symm), fun h => by rw [h, hinsId]⟩
          rw [hdec]
          cases hdq : decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins)
          · simp only [Bool.cond_false]
            obtain ⟨sh, hsx, hshl⟩ := shapesOf_lit (x := x) (l := nd.ins.map (Host.Mlx.Ffi.substOf m)) (fun b hb => by
              obtain ⟨b0, hb0, rfl⟩ := List.mem_map.mp hb
              exact hsubLit b0 hb0)
            have hsy : Host.Mlx.Ffi.shapesOf y ((nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node) = some sh := by
              rw [hr.shapesOf_map hsx, shp_lits M hshl]
            rw [hsx, hsy]
            simp only
            obtain ⟨r, hrl, e⟩ := infer_pure nd.prim hpl sh hshl
            have e' : ∀ γ (k : Option Host.Mlx.Ffi.Out → Free γ), Host.Mlx.Ffi.infer (M.prim nd.prim) sh γ k = k r := by
              rw [infer_mprim M nd.prim hpl sh]; exact e
            rw [bind_pureP e, bind_pureP e']
            cases r with
            | none => exact ⟨none, none, fun _ _ => rfl, fun _ _ => rfl, trivial⟩
            | some out =>
              cases out with
              | node shape dt =>
                have hnn : (⟨.replayed (M.handle c) (M.prim nd.prim),
                    (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node, shape, dt⟩ : Node) =
                    M.nnode ⟨.replayed c nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), shape, dt⟩ := by
                  simp only [Map.nnode, Map.prim, dims_lit M hrl]
                simp only [Host.Mlx.Ffi.St.addNode]
                rw [hnn]
                exact cont _ hrl ⟨hclp, SDs.of_lit hrl⟩
              | same i =>
                simp only [nth?_map]
                cases hi : nth? nd.ins i with
                | none => exact ⟨none, none, fun _ _ => rfl, fun _ _ => rfl, trivial⟩
                | some b0 =>
                  simp only [Option.map_some]
                  have hkk : litNode x (Host.Mlx.Ffi.substOf m b0) = true := hsubLit b0 (nth?_mem' hi)
                  have := keep _ hkk haNL
                  simpa only [Map.subst, List.map_cons] using this
          · simp only [Bool.cond_true]
            exact ih m hr hns' hm hroom'
        · simp only [Bool.cond_true]
          have hnn : (⟨.replayed (M.handle c) (M.prim nd.prim),
              (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node, nd.shape, nd.dtype⟩ : Node) =
              M.nnode ⟨.replayed c nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), nd.shape, nd.dtype⟩ := by
            simp only [Map.nnode, Map.prim, hsid]
          simp only [Host.Mlx.Ffi.St.addNode]
          rw [hnn]
          exact cont _ hsl ⟨hclp, SDs.of_lit hsl⟩
      · simp only [Bool.cond_true]
        exact ih m hr hns' hm hroom'
end

end Host.Ts.Sim
