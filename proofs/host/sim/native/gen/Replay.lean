import host.sim.native.Replay
import host.sim.native.gen.Ops
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Compiled-closure replays for any prefill history

A compiled closure's traces name pre-loop nodes (below `P.NL`): they correspond fully, but
their ids are renamed (`M.node`, injective on present nodes), and a shapeless trace's nodes
keep the shapes of the closure's first call, which differ between histories (the template
holds them as number references). The target replays the imaged trace (`M.trace`) over the
imaged inputs, with the renamed substitution map `substN M m`.

The replay only reads recorded shapes where it infers on them: `rchk` follows the template's
replay and accepts it when every inference reads literal input shapes and every node it
looks up is present (a replay that gets stuck passes). Recorded shapes of nodes the replay
re-infers, of tracers and of replayed kernel nodes (copied) may be symbolic. -/

/-- The substitution map on the target: keys and values renamed. -/
def substN (M : Map) (m : List (Nat × Nat)) : List (Nat × Nat) := m.map fun p => (M.node p.1, M.node p.2)

theorem substOf_substN (M : Map) {Q : Nat → Prop} (hinj : ∀ a b, Q a → Q b → M.node a = M.node b → a = b) :
    ∀ (m : List (Nat × Nat)), (∀ p ∈ m, Q p.1) → ∀ a, Q a →
      Host.Mlx.Ffi.substOf (substN M m) (M.node a) = M.node (Host.Mlx.Ffi.substOf m a)
  | [], _, a, _ => by simp [Host.Mlx.Ffi.substOf, substN]
  | (b, k) :: m, hk, a, ha => by
    have ih := substOf_substN M hinj m (fun p hp => hk p (List.mem_cons_of_mem _ hp)) a ha
    have hb : Q b := hk (b, k) (List.mem_cons_self ..)
    have e : Nat.beq (M.node b) (M.node a) = Nat.beq b a := by
      cases h : Nat.beq b a
      · cases h' : Nat.beq (M.node b) (M.node a)
        · rfl
        · exact absurd (hinj b a hb ha (Nat.eq_of_beq_eq_true h')) (Nat.ne_of_beq_eq_false h)
      · rw [Nat.eq_of_beq_eq_true h]; exact Nat.beq_refl _
    unfold Host.Mlx.Ffi.substOf at ih ⊢
    simp only [substN, List.map_cons, List.find?_cons] at ih ⊢
    rw [e]
    cases Nat.beq b a
    · exact ih
    · rfl

theorem substN_cons (M : Map) (a k : Nat) (m : List (Nat × Nat)) :
    substN M ((a, k) :: m) = (M.node a, M.node k) :: substN M m := rfl

/-- The template's replay of trace nodes `ns` (closure `cls`), checked: every node the replay
reads is present, rebuilt nodes are pre-loop (fully corresponding), and every inference has
literal parameters and reads literal input shapes. A replay that gets stuck passes. -/
def rchk (NL : Nat) (cls : Nat) : NSt → List (Nat × Nat) → List Nat → Bool
  | _, _, [] => true
  | x, m, a :: ns => decide (a < NL) && match x.nodes.get a with
    | none => false
    | some nd => nd.ins.all (fun b => (x.nodes.get b).isSome) &&
      bif leafP nd.prim then rchk NL cls x m ns
      else bif Host.Mlx.Ffi.isKernel nd.prim then
        rchk NL cls (addN x ⟨.replayed cls nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), nd.shape, nd.dtype⟩)
          ((a, x.nnext) :: m) ns
      else bif decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins) then rchk NL cls x m ns
      else primLit nd.prim && match Host.Mlx.Ffi.shapesOf x (nd.ins.map (Host.Mlx.Ffi.substOf m)) with
        | some sh => sh.all (fun q => q.1.all dimLit) &&
          match Host.Mlx.Ffi.infer nd.prim sh (Option Host.Mlx.Ffi.Out) Free.pure with
          | .pure (some (.node shape dt)) =>
            rchk NL cls (addN x ⟨.replayed cls nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), shape, dt⟩)
              ((a, x.nnext) :: m) ns
          | .pure (some (.same i)) => match nth? (nd.ins.map (Host.Mlx.Ffi.substOf m)) i with
            | some k => rchk NL cls x ((a, k) :: m) ns
            | none => true
          | .pure none => true
          | _ => false
        | none => false

/-- The result relation of a replay. -/
def RRel (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x : NSt) :
    Option (NSt × List (Nat × Nat)) → Option (NSt × List (Nat × Nat)) → Prop
  | none, none => True
  | some (x', m), some (y', m') => MR P NB M n x' y' ∧ m' = substN M m ∧
      (∀ p ∈ m, PN x' p.1 ∧ PN x' p.2) ∧ NGrow x x' ∧ x'.next = x.next ∧ x'.arrs = x.arrs ∧ x'.objs = x.objs
  | _, _ => False

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)
include hr

theorem MR.ngrow_addN (nd : Node) : NGrow x (addN x nd) :=
  ⟨Nat.le_succ _, fun i hi => by
    show (x.nodes.set x.nnext nd).get i = _
    rw [PTrie.gs _ _ _ hr.xnnext_lt]; simp [Nat.ne_of_lt hi]⟩

theorem MR.pn_grow {x' : NSt} (hg : NGrow x x') {k : Nat} (h : PN x k) : PN x' k := by
  unfold PN at h ⊢
  rw [hg.2 k (hr.nlt k h)]; exact h

theorem MR.pn_addN (nd : Node) : PN (addN x nd) x.nnext := by
  show ((x.nodes.set x.nnext nd).get x.nnext).isSome = true
  rw [PTrie.gs _ _ _ hr.xnnext_lt]; simp

end

theorem pn_of_get {x : NSt} {k : Nat} {nd : Node} (h : x.nodes.get k = some nd) : PN x k := by
  unfold PN; rw [h]; rfl

theorem shapesOf_present {x : NSt} : ∀ {l : List Nat} {sh : List (List Dim × Nat)},
    Host.Mlx.Ffi.shapesOf x l = some sh → ∀ b ∈ l, PN x b
  | [], _, _, _, hb => by cases hb
  | b :: l, sh, h, c, hc => by
    simp only [Host.Mlx.Ffi.shapesOf] at h
    cases hn : x.nodes.get b with
    | none => rw [hn] at h; cases h
    | some nd =>
      rw [hn] at h
      cases hs : Host.Mlx.Ffi.shapesOf x l with
      | none => rw [hs] at h; cases h
      | some sh' =>
        rcases List.mem_cons.mp hc with rfl | hc
        · exact pn_of_get hn
        · exact shapesOf_present hs c hc

theorem leafP_primR {M : Map} {nd : Node} {p' : Prim} (h : PrimR M nd p') : leafP p' = leafP nd.prim := by
  rcases h with rfl | ⟨hs, bs, rfl⟩
  · exact leafP_mprim M nd.prim
  · obtain ⟨p, ins, s, d⟩ := nd
    cases p <;> simp_all [shapeOnly, leafP]

theorem primR_exact {M : Map} {nd : Node} {p' : Prim} (h : PrimR M nd p') (hl : leafP nd.prim = false) :
    p' = M.prim nd.prim := by
  rcases h with h | ⟨hs, -⟩
  · exact h
  · exfalso
    obtain ⟨p, ins, s, d⟩ := nd
    cases p <;> simp_all [shapeOnly, leafP]

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat}

/-- **The replay of a checked trace** on related states. -/
theorem MR.replayOrder (c : Nat) (ns : List Nat) : ∀ {x y : NSt} (m : List (Nat × Nat)), MR P NB M n x y →
    rchk P.NL c x m ns = true → (∀ p ∈ m, PN x p.1 ∧ PN x p.2) → x.nnext + ns.length ≤ P.NE →
    ∃ r r', (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ), Host.Mlx.Ffi.replayOrder x c m ns γ k = k r) ∧
      (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
        Host.Mlx.Ffi.replayOrder y (M.handle c) (substN M m) (ns.map M.node) γ k = k r') ∧ RRel P NB M n x r r' := by
  induction ns with
  | nil =>
    intro x y m hr _ hm _
    exact ⟨some (x, m), some (y, substN M m), fun _ _ => rfl, fun _ _ => rfl, hr, rfl, hm, NGrow.refl x, rfl, rfl, rfl⟩
  | cons a ns ih =>
    intro x y m hr hck hm hroom
    have hroom' : x.nnext + ns.length ≤ P.NE := by simp at hroom; omega
    have lift : ∀ {x' : NSt} {r r' : Option (NSt × List (Nat × Nat))}, x'.next = x.next → x'.arrs = x.arrs →
        x'.objs = x.objs → NGrow x x' → RRel P NB M n x' r r' → RRel P NB M n x r r' := by
      intro x' r r' e1 e2 e3 hg h
      cases r with
      | none => cases r' with
        | none => trivial
        | some _ => exact h.elim
      | some q => cases r' with
        | none => exact h.elim
        | some q' =>
          obtain ⟨x'', mm⟩ := q
          obtain ⟨y'', mm'⟩ := q'
          obtain ⟨h1, h2, h3, h4, h5, h6, h7⟩ := h
          exact ⟨h1, h2, h3, hg.trans h4, h5.trans e1, h6.trans e2, h7.trans e3⟩
    have hmQ : ∀ p ∈ m, PN x p.1 := fun p hp => (hm p hp).1
    -- the keys of `m` and present nodes are named injectively
    have hsub : ∀ b, PN x b → Host.Mlx.Ffi.substOf (substN M m) (M.node b) = M.node (Host.Mlx.Ffi.substOf m b) :=
      fun b hb => substOf_substN M (Q := PN x) (fun u v hu hv => hr.ninj u v hu hv) m hmQ b hb
    have hsubP : ∀ b, PN x b → PN x (Host.Mlx.Ffi.substOf m b) := fun b hb => by
      rcases substOf_mem m b with e | ⟨p, hp, e⟩
      · rw [e]; exact hb
      · rw [e]; exact (hm p hp).2
    -- continue after binding `a` to a new node
    have cont : ∀ (nd0 : Node), SNode (· < n) nd0 → (∀ d ∈ nd0.shape, DimCanon M d) →
        rchk P.NL c (addN x nd0) ((a, x.nnext) :: m) ns = true → PN x a →
        ∃ r r', (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
          Host.Mlx.Ffi.replayOrder (addN x nd0) c ((a, x.nnext) :: m) ns γ k = k r) ∧
          (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
            Host.Mlx.Ffi.replayOrder (addN y (M.nnode nd0)) (M.handle c) ((M.node a, y.nnext) :: substN M m)
              (ns.map M.node) γ k = k r') ∧ RRel P NB M n x r r' := by
      intro nd0 hcl hcn hck' ha
      have hr1 : MR P NB M n (addN x nd0) (addN y (M.nnode nd0)) := hr.addNode nd0 (by simp at hroom; omega) hcl hcn
      have hg := hr.ngrow_addN nd0
      have hm' : ∀ p ∈ (a, x.nnext) :: m, PN (addN x nd0) p.1 ∧ PN (addN x nd0) p.2 := by
        intro p hp
        rcases List.mem_cons.mp hp with rfl | hp
        · exact ⟨hr.pn_grow hg ha, hr.pn_addN nd0⟩
        · exact ⟨hr.pn_grow hg (hm p hp).1, hr.pn_grow hg (hm p hp).2⟩
      obtain ⟨r, r', e1, e2, hrel⟩ := ih ((a, x.nnext) :: m) hr1 hck' hm'
        (by show x.nnext + 1 + ns.length ≤ P.NE; simp at hroom; omega)
      refine ⟨r, r', e1, fun γ k => ?_, lift (x' := addN x nd0) rfl rfl rfl hg hrel⟩
      have := e2 γ k
      rw [substN_cons, hr.node_next] at this
      exact this
    -- continue after binding `a` to an existing node
    have keep : ∀ kk, PN x kk → PN x a → rchk P.NL c x ((a, kk) :: m) ns = true →
        ∃ r r', (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
          Host.Mlx.Ffi.replayOrder x c ((a, kk) :: m) ns γ k = k r) ∧
          (∀ γ (k : Option (NSt × List (Nat × Nat)) → Free γ),
            Host.Mlx.Ffi.replayOrder y (M.handle c) ((M.node a, M.node kk) :: substN M m) (ns.map M.node) γ k = k r') ∧
          RRel P NB M n x r r' := by
      intro kk hkk ha hck'
      exact ih ((a, kk) :: m) hr hck' (fun p hp => by
        rcases List.mem_cons.mp hp with rfl | hp
        · exact ⟨ha, hkk⟩
        · exact hm p hp) hroom'
    unfold rchk at hck
    rw [Bool.and_eq_true] at hck
    obtain ⟨haNL, hck⟩ := hck
    have haNL : a < P.NL := of_decide_eq_true haNL
    cases hxa : x.nodes.get a with
    | none => rw [hxa] at hck; cases hck
    | some nd =>
      rw [hxa] at hck
      simp only [Bool.and_eq_true] at hck
      obtain ⟨hinsP, hck⟩ := hck
      have hinsP : ∀ b ∈ nd.ins, PN x b := fun b hb => List.all_eq_true.mp hinsP b hb
      have hpa : PN x a := pn_of_get hxa
      obtain ⟨nd', hya, hs1, hd1, hc1, hf1⟩ := hr.nodes a nd hxa
      obtain ⟨hp1, hi1⟩ := hf1 (.inl haNL)
      have hclp : SP (· < n) nd.prim := (hr.cl.1 a nd hxa).1
      have hcls : SDs (· < n) nd.shape := (hr.cl.1 a nd hxa).2
      have hsubst : nd'.ins.map (Host.Mlx.Ffi.substOf (substN M m)) =
          (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node := by
        rw [hi1, List.map_map, List.map_map]
        exact List.map_congr_left fun b hb => hsub b (hinsP b hb)
      have hpres : ∀ b ∈ nd.ins.map (Host.Mlx.Ffi.substOf m), PN x b := by
        intro b hb
        obtain ⟨b0, hb0, rfl⟩ := List.mem_map.mp hb
        exact hsubP b0 (hinsP b0 hb0)
      rw [List.map_cons, replayOrder_cons, replayOrder_cons, hxa, hya]
      simp only [leafP_primR hp1]
      cases hleaf : leafP nd.prim
      · rw [hleaf] at hck
        simp only [Bool.cond_false] at hck ⊢
        have hp1 := primR_exact hp1 hleaf
        unfold replayStep
        simp only [hp1, isKernel_mprim, hsubst, hs1, hd1]
        cases hk : Host.Mlx.Ffi.isKernel nd.prim
        · rw [hk] at hck
          simp only [Bool.cond_false] at hck ⊢
          have hdec : decide ((nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node = nd.ins.map M.node) =
              decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins) :=
            decide_eq_decide.mpr ⟨fun h => map_inj_on (fun u v hu hv h => hr.ninj u v hu hv h) hpres hinsP h,
              fun h => by rw [h]⟩
          rw [← hi1] at hdec
          rw [hdec]
          cases hdq : decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins)
          · rw [hdq] at hck
            simp only [Bool.cond_false, Bool.and_eq_true] at hck ⊢
            obtain ⟨hpl, hck⟩ := hck
            cases hsx : Host.Mlx.Ffi.shapesOf x (nd.ins.map (Host.Mlx.Ffi.substOf m)) with
            | none => rw [hsx] at hck; cases hck
            | some sh =>
              rw [hsx] at hck
              simp only [Bool.and_eq_true] at hck
              obtain ⟨hshl, hck⟩ := hck
              have hshl : ShLits sh := fun q hq => List.all_eq_true.mp hshl q hq
              have hsy : Host.Mlx.Ffi.shapesOf y ((nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node) = some sh := by
                rw [hr.shapesOf_map hsx, shp_lits M hshl]
              rw [hsy]
              simp only
              obtain ⟨r, hrl, e⟩ := infer_pure nd.prim hpl sh hshl
              have e' : ∀ γ (k : Option Host.Mlx.Ffi.Out → Free γ), Host.Mlx.Ffi.infer (M.prim nd.prim) sh γ k = k r := by
                rw [infer_mprim M nd.prim hpl sh]; exact e
              rw [bind_pureP e, bind_pureP e']
              rw [e] at hck
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
                  exact cont _ ⟨hclp, SDs.of_lit hrl⟩ (fun d hd => dimCanon_lit M (List.all_eq_true.mp hrl d hd))
                    hck hpa
                | same i =>
                  simp only at hck
                  simp only [nth?_map] at hck ⊢
                  cases hi : nth? nd.ins i with
                  | none => exact ⟨none, none, fun _ _ => rfl, fun _ _ => rfl, trivial⟩
                  | some b0 =>
                    rw [hi] at hck
                    simp only [Option.map_some] at hck ⊢
                    exact keep _ (hsubP b0 (hinsP b0 (nth?_mem' hi))) hpa hck
          · rw [hdq] at hck
            simp only [Bool.cond_true] at hck ⊢
            exact ih m hr hck hm hroom'
        · rw [hk] at hck
          simp only [Bool.cond_true] at hck ⊢
          have hnn : (⟨.replayed (M.handle c) (M.prim nd.prim),
              (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node, M.dims nd.shape, nd.dtype⟩ : Node) =
              M.nnode ⟨.replayed c nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), nd.shape, nd.dtype⟩ := by
            simp only [Map.nnode, Map.prim]
          simp only [Host.Mlx.Ffi.St.addNode]
          rw [hnn]
          exact cont _ ⟨hclp, hcls⟩ hc1 hck hpa
      · rw [hleaf] at hck
        simp only [Bool.cond_true] at hck ⊢
        exact ih m hr hck hm hroom'
end


/-! ## Literal traces pass the check -/

theorem litNode_addN' {x : NSt} {nd0 : Node} (hk : x.nnext < 2 ^ 62) (hl : nd0.shape.all dimLit = true) {k : Nat}
    (h : litNode x k = true) : litNode (addN x nd0) k = true := by
  unfold litNode at h ⊢
  show (match (x.nodes.set x.nnext nd0).get k with | some nd => nd.shape.all dimLit | none => false) = true
  rw [PTrie.gs _ _ _ hk]
  by_cases e : k = x.nnext
  · simp only [e, ↓reduceIte]; exact hl
  · simp only [e, ↓reduceIte]; exact h

theorem rnodeOk_addN' {P : LoadP} {x : NSt} {nd0 : Node} (hk : x.nnext < 2 ^ 62) (hl : nd0.shape.all dimLit = true)
    (hlt : ∀ k, PN x k → k < x.nnext) {a : Nat} (h : rnodeOk P x a = true) : rnodeOk P (addN x nd0) a = true := by
  unfold rnodeOk at h ⊢
  rw [Bool.and_eq_true] at h ⊢
  refine ⟨h.1, ?_⟩
  have h2 := h.2
  cases ha : x.nodes.get a with
  | none => rw [ha] at h2; cases h2
  | some nd =>
    rw [ha] at h2
    have hne : a ≠ x.nnext := Nat.ne_of_lt (hlt a (pn_of_get ha))
    show (match (x.nodes.set x.nnext nd0).get a with
      | some nd => primLit nd.prim && nd.shape.all dimLit && nd.ins.all fun b => decide (b < P.NL) && litNode (addN x nd0) b
      | none => false) = true
    rw [PTrie.gs _ _ _ hk]
    simp only [hne, ↓reduceIte, ha]
    rw [Bool.and_eq_true] at h2 ⊢
    refine ⟨h2.1, List.all_eq_true.mpr fun b hb => ?_⟩
    have := List.all_eq_true.mp h2.2 b hb
    rw [Bool.and_eq_true] at this ⊢
    exact ⟨this.1, litNode_addN' hk hl this.2⟩

theorem pnlt_addN {x : NSt} {nd0 : Node} (hk : x.nnext < 2 ^ 62) (hlt : ∀ k, PN x k → k < x.nnext) :
    ∀ k, PN (addN x nd0) k → k < (addN x nd0).nnext := by
  intro k hk'
  show k < x.nnext + 1
  change ((x.nodes.set x.nnext nd0).get k).isSome = true at hk'
  rw [PTrie.gs _ _ _ hk] at hk'
  by_cases e : k = x.nnext
  · omega
  · simp only [e, ↓reduceIte] at hk'; exact Nat.lt_succ_of_lt (hlt k hk')

/-- Today's checks (`rnodeOk`: pre-loop literal nodes with pre-loop literal inputs, literal
substitution values) pass `rchk`. -/
theorem rchk_of_lit {P : LoadP} (c : Nat) (ns : List Nat) : ∀ {x : NSt} (m : List (Nat × Nat)),
    (∀ k, PN x k → k < x.nnext) → x.nnext + ns.length < 2 ^ 62 →
    (∀ a ∈ ns, rnodeOk P x a = true) → (∀ p ∈ m, litNode x p.2 = true) → rchk P.NL c x m ns = true := by
  induction ns with
  | nil => intro _ _ _ _ _ _; rfl
  | cons a ns ih =>
    intro x m hlt hroom hns hm
    have hk : x.nnext < 2 ^ 62 := by simp at hroom; omega
    have hns' : ∀ b ∈ ns, rnodeOk P x b = true := fun b hb => hns b (List.mem_cons_of_mem _ hb)
    have ha := hns a (List.mem_cons_self ..)
    -- continue on a grown state with a literal node
    have cont : ∀ (nd0 : Node), nd0.shape.all dimLit = true →
        rchk P.NL c (addN x nd0) ((a, x.nnext) :: m) ns = true := by
      intro nd0 hl
      refine ih ((a, x.nnext) :: m) (pnlt_addN hk hlt) (by show x.nnext + 1 + ns.length < 2 ^ 62; simp at hroom; omega)
        (fun b hb => rnodeOk_addN' hk hl hlt (hns' b hb)) (fun p hp => ?_)
      rcases List.mem_cons.mp hp with rfl | hp
      · show (match (x.nodes.set x.nnext nd0).get x.nnext with | some nd => nd.shape.all dimLit | none => false) = true
        rw [PTrie.gs _ _ _ hk]; simpa using hl
      · exact litNode_addN' hk hl (hm p hp)
    unfold rnodeOk at ha
    rw [Bool.and_eq_true] at ha
    obtain ⟨haNL, hnd⟩ := ha
    unfold rchk
    rw [haNL, Bool.true_and]
    cases hxa : x.nodes.get a with
    | none => rw [hxa] at hnd; cases hnd
    | some nd =>
      rw [hxa] at hnd
      simp only [Bool.and_eq_true] at hnd
      obtain ⟨⟨hpl, hsl⟩, hins⟩ := hnd
      have hins' : ∀ b ∈ nd.ins, b < P.NL ∧ litNode x b = true := fun b hb => by
        have := List.all_eq_true.mp hins b hb
        rw [Bool.and_eq_true] at this
        exact ⟨of_decide_eq_true this.1, this.2⟩
      have hsubLit : ∀ b ∈ nd.ins, litNode x (Host.Mlx.Ffi.substOf m b) = true := by
        intro b hb
        rcases substOf_mem m b with e | ⟨p, hp, e⟩
        · rw [e]; exact (hins' b hb).2
        · rw [e]; exact hm p hp
      have hinsP : nd.ins.all (fun b => (x.nodes.get b).isSome) = true :=
        List.all_eq_true.mpr fun b hb => MR.litNode_present (hins' b hb).2
      simp only [hinsP, Bool.true_and]
      cases hleaf : leafP nd.prim
      · simp only [Bool.cond_false]
        cases hkr : Host.Mlx.Ffi.isKernel nd.prim
        · simp only [Bool.cond_false]
          cases hdq : decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins)
          · simp only [Bool.cond_false, hpl, Bool.true_and]
            obtain ⟨sh, hsx, hshl⟩ := shapesOf_lit (x := x) (l := nd.ins.map (Host.Mlx.Ffi.substOf m)) (fun b hb => by
              obtain ⟨b0, hb0, rfl⟩ := List.mem_map.mp hb
              exact hsubLit b0 hb0)
            rw [hsx]
            simp only
            rw [show sh.all (fun q => q.1.all dimLit) = true from List.all_eq_true.mpr fun q hq => hshl q hq,
              Bool.true_and]
            obtain ⟨r, hrl, e⟩ := infer_pure nd.prim hpl sh hshl
            rw [e]
            cases r with
            | none => rfl
            | some out =>
              cases out with
              | node shape dt => exact cont _ hrl
              | same i =>
                simp only
                cases hi : nth? (nd.ins.map (Host.Mlx.Ffi.substOf m)) i with
                | none => rfl
                | some b0 =>
                  simp only
                  refine ih ((a, b0) :: m) hlt (by simp at hroom; omega) hns' (fun p hp => ?_)
                  rcases List.mem_cons.mp hp with rfl | hp
                  · obtain ⟨b1, hb1, e1⟩ := List.mem_map.mp (nth?_mem' hi)
                    rw [← e1]; exact hsubLit b1 hb1
                  · exact hm p hp
          · simp only [Bool.cond_true]
            exact ih m hlt (by simp at hroom; omega) hns' hm
        · simp only [Bool.cond_true]
          exact cont _ hsl
      · simp only [Bool.cond_true]
        exact ih m hlt (by simp at hroom; omega) hns' hm

end Host.Ts.Sim.G
