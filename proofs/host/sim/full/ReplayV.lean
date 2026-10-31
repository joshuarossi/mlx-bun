import host.sim.full.Call
import host.sim.full.Record
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out Trace)
open Host.Ts.Sim.BufSim (Lawful)

/-! # Compiled-closure replays over symbolic shapes

`rchk` accepts a replay whose inferences read literal shapes, so that both sides infer alike without
requests. A shapeless closure traced over the prompt's rows (`compile.ts`'s SwiGLU) replays casts,
unary operations and broadcasting binary operations over dimensions that are number references.
`rwalk` follows the template's replay as `rchk` does (the band checked apart), without the shapes of
the replay's own nodes:
every inference is a cast, a unary, contiguous or broadcasting binary operation (`symOp`), and every
input the replay reads that is not one of its own nodes has dimensions with values (`valuedN`). It
lists those inputs; the numeric premise takes their references small. The replay's own nodes have
shapes with values by induction (`inferV_sim`: these inferences keep or broadcast their inputs'
dimensions). `MR.replayOrderV` simulates the replay given that the template's replay has a result
(`RunSome`): a source inference that gives up would stop the template there. -/

/-- The inferences the symbolic replay covers, by arity. -/
def symOp : Prim → Nat → Bool
  | .unary _, 1 | .astype _, 1 | .contiguous, 1 | .binary _, 2 => true
  | _, _ => false

/-- A present node whose shape's dimensions may have values. -/
def valuedN (x : NSt) (b : Nat) : Bool :=
  match x.nodes.get b with
  | some nd => nd.shape.all dimOkV
  | none => false

/-- **The template's replay of trace nodes `ns` over symbolic shapes** (next node `nn`): every node it
reads is present, a kernel's recorded shape and every input that is not the replay's own node (below
`x.nnext`) may have values, and every inference is `symOp`'s. The result lists those nodes. -/
def rwalk (x : NSt) : Nat → List (Nat × Nat) → List Nat → Option (List Nat)
  | _, _, [] => some []
  | nn, m, a :: ns => match x.nodes.get a with
    | none => none
    | some nd => bif nd.ins.all (fun b => (x.nodes.get b).isSome) then
        bif leafP nd.prim then rwalk x nn m ns
        else bif Host.Mlx.Ffi.isKernel nd.prim then
          bif nd.shape.all dimOkV then (rwalk x (nn + 1) ((a, nn) :: m) ns).map (a :: ·) else none
        else bif decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins) then rwalk x nn m ns
        else bif symOp nd.prim (nd.ins.map (Host.Mlx.Ffi.substOf m)).length &&
            (nd.ins.map (Host.Mlx.Ffi.substOf m)).all (fun b => decide (x.nnext ≤ b) || valuedN x b) then
          (rwalk x (nn + 1) ((a, nn) :: m) ns).map
            ((nd.ins.map (Host.Mlx.Ffi.substOf m)).filter (fun b => decide (b < x.nnext)) ++ ·)
        else none
      else none

/-! ## The inferences -/

section
variable {ν : Nat → F64}

/-- An inference's result: a source shape with values and its image. -/
def VPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) : Map → SSrv → CSrv → Option Out → Option Out → Prop :=
  fun M' S' C' r r' => GrowL M ν S C M' S' C' ∧
    (r = none ∨ ∃ s d ks, r = some (.node s d) ∧ r' = some (.node (M'.dims s) d) ∧ DVSs M' C' S' s ks ∧ Bd ks)

/-- **`symOp`'s inferences over inputs with values.** -/
theorem inferV_sim {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) {p : Prim} :
    ∀ {sh : List (List Dim × Nat)}, symOp p sh.length = true → (∀ q ∈ sh, ∃ ks, DVSs M C S q.1 ks ∧ Bd ks) →
      MSim (VPost M ν S C) S C (Host.Mlx.Ffi.infer p sh) (Host.Mlx.Ffi.infer (M.prim p) (sh.map M.shp))
  | [], hp, _ => by cases p <;> simp [symOp] at hp
  | [(s, d)], hp, hv => by
    obtain ⟨ks, hks, bks⟩ := hv (s, d) List.mem_cons_self
    cases p <;> simp only [symOp, List.length_cons, List.length_nil, Nat.zero_add] at hp <;> try cases hp
    all_goals exact MSim.pure ⟨GrowL.refl hs, .inr ⟨s, _, ks, rfl, rfl, hks, bks⟩⟩
  | [(a, da), (b, db)], hp, hv => by
    obtain ⟨ka, hka, bka⟩ := hv (a, da) List.mem_cons_self
    obtain ⟨kb, hkb, bkb⟩ := hv (b, db) (List.mem_cons_of_mem _ List.mem_cons_self)
    cases p <;> simp only [symOp, List.length_cons, List.length_nil, Nat.zero_add] at hp <;> try cases hp
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast a b) _) (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast (M.dims a) (M.dims b)) _)
    refine MSim.bind (broadcast_simV hs hka hkb bka bkb) fun M' S' C' r r' h => MSim.pure ⟨h.1, ?_⟩
    rcases h.2 with ⟨rfl, -⟩ | ⟨ds, kds, rfl, rfl, hds, bds⟩
    · exact .inl rfl
    · exact .inr ⟨ds, _, kds, rfl, rfl, hds, bds⟩
  | _ :: _ :: _ :: _, hp, _ => by cases p <;> simp [symOp] at hp

end

/-! ## Runs with a result -/

/-- The template's computation at `S` has a result whenever it runs. -/
def RunSome {α : Type} (S : SSrv) (m : Host.Ts.M (Option α)) : Prop :=
  ∀ r S', interpS m.run S = some (r, S') → r.isSome = true

theorem RunSome.bind {α β : Type} {S S1 : SSrv} {m : Host.Ts.M α} {K : α → Host.Ts.M (Option β)} {a : α}
    (hl : Lawful m) (hm : interpS m.run S = some (a, S1)) (h : RunSome S (Host.Ts.M.bind m K)) : RunSome S1 (K a) := by
  intro r S' hk
  apply h r S'
  show interpS (m _ fun a => (K a).run) S = _
  rw [hl.1, hm]
  exact hk

theorem RunSome.of_bind {α β : Type} {S : SSrv} {m : Host.Ts.M (Option α)} {K : Option α → Host.Ts.M (Option β)}
    (hl : Lawful m) (hK : K none = Host.Ts.M.pure none) (h : RunSome S (Host.Ts.M.bind m K)) : RunSome S m := by
  intro r S1 hr1
  cases r with
  | some _ => rfl
  | none =>
    have := h none S1 (by
      show interpS (m _ fun a => (K a).run) S = _
      rw [hl.1, hr1]
      show interpS (K none).run S1 = _
      rw [hK]; rfl)
    cases this

/-! ## The replay's steps -/

section
variable {s : NSt} {c : Nat} {m : List (Nat × Nat)} {a : Nat} {ns : List Nat} {nd : Node}

theorem replayOrder_leaf (h : s.nodes.get a = some nd) (hl : leafP nd.prim = true) :
    Host.Mlx.Ffi.replayOrder s c m (a :: ns) = Host.Mlx.Ffi.replayOrder s c m ns := by
  rw [replayOrder_cons, h]; simp only [hl, Bool.cond_true]

theorem replayOrder_kern (h : s.nodes.get a = some nd) (hl : leafP nd.prim = false)
    (hk : Host.Mlx.Ffi.isKernel nd.prim = true) :
    Host.Mlx.Ffi.replayOrder s c m (a :: ns) =
      Host.Mlx.Ffi.replayOrder (addN s ⟨.replayed c nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), nd.shape, nd.dtype⟩)
        c ((a, s.nnext) :: m) ns := by
  rw [replayOrder_cons, h]; simp only [hl, Bool.cond_false]; unfold replayStep; simp only [hk, Bool.cond_true]; rfl

theorem replayOrder_same (h : s.nodes.get a = some nd) (hl : leafP nd.prim = false)
    (hk : Host.Mlx.Ffi.isKernel nd.prim = false) (hq : nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins) :
    Host.Mlx.Ffi.replayOrder s c m (a :: ns) = Host.Mlx.Ffi.replayOrder s c m ns := by
  rw [replayOrder_cons, h]
  simp only [hl, Bool.cond_false, replayStep, hk, hq, decide_true, Bool.cond_true]

/-- The replay after an inference. -/
def replayK (s : NSt) (c : Nat) (m : List (Nat × Nat)) (a : Nat) (ns : List Nat) (ins : List Nat) (p : Prim) :
    Option Out → Host.Ts.M (Option (NSt × List (Nat × Nat)))
  | some (.node shape dt) => Host.Mlx.Ffi.replayOrder (addN s ⟨.replayed c p, ins, shape, dt⟩) c ((a, s.nnext) :: m) ns
  | some (.same i) => match nth? ins i with
    | some k => Host.Mlx.Ffi.replayOrder s c ((a, k) :: m) ns
    | none => Host.Ts.M.pure none
  | none => Host.Ts.M.pure none

theorem replayOrder_inf (h : s.nodes.get a = some nd) (hl : leafP nd.prim = false)
    (hk : Host.Mlx.Ffi.isKernel nd.prim = false) (hq : nd.ins.map (Host.Mlx.Ffi.substOf m) ≠ nd.ins)
    {sh : List (List Dim × Nat)} (hsh : Host.Mlx.Ffi.shapesOf s (nd.ins.map (Host.Mlx.Ffi.substOf m)) = some sh) :
    Host.Mlx.Ffi.replayOrder s c m (a :: ns) =
      Host.Ts.M.bind (Host.Mlx.Ffi.infer nd.prim sh) (replayK s c m a ns (nd.ins.map (Host.Mlx.Ffi.substOf m)) nd.prim) := by
  rw [replayOrder_cons, h]; simp only [hl, Bool.cond_false]; unfold replayStep
  simp only [hk, Bool.cond_false, decide_eq_false hq, hsh]
  congr 1

end

/-! ## The replay -/

theorem shapesOf_get {x : NSt} : ∀ {l : List Nat} {sh : List (List Dim × Nat)}, Host.Mlx.Ffi.shapesOf x l = some sh →
    ∀ q ∈ sh, ∃ b ∈ l, ∃ nd, x.nodes.get b = some nd ∧ q = (nd.shape, nd.dtype)
  | [], sh, h, q, hq => by simp only [Host.Mlx.Ffi.shapesOf, Option.some.injEq] at h; subst h; cases hq
  | b :: l, sh, h, q, hq => by
    simp only [Host.Mlx.Ffi.shapesOf] at h
    cases hn : x.nodes.get b with
    | none => rw [hn] at h; cases h
    | some nd =>
      rw [hn, Option.bind_some] at h
      cases hs : Host.Mlx.Ffi.shapesOf x l with
      | none => rw [hs] at h; cases h
      | some sh' =>
        rw [hs, Option.map_some, Option.some.injEq] at h
        subst h
        rcases List.mem_cons.mp hq with rfl | hq
        · exact ⟨b, List.mem_cons_self, nd, hn, rfl⟩
        · obtain ⟨b', hb', nd', h1, h2⟩ := shapesOf_get hs q hq
          exact ⟨b', List.mem_cons_of_mem _ hb', nd', h1, h2⟩

/-- The replay's result relation: a source result's target result, related. -/
@[reducible] def RRelV (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x0 : NSt) :
    Option (NSt × List (Nat × Nat)) → Option (NSt × List (Nat × Nat)) → Prop
  | none, _ => True
  | some (x', m), some (y', m') => MR P NB M n x' y' ∧ m' = substN M m ∧ (∀ p ∈ m, PN x' p.1 ∧ PN x' p.2) ∧
      NGrow x0 x' ∧ x'.next = x0.next ∧ x'.arrs = x0.arrs ∧ x'.objs = x0.objs
  | some _, none => False

/-- The replay's postcondition. -/
@[reducible] def RPostV (P : LoadP) (NB : Nat) (x0 : NSt) (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option (NSt × List (Nat × Nat)) → Option (NSt × List (Nat × Nat)) → Prop :=
  fun M' S' C' r r' => GrowL M ν S C M' S' C' ∧ RRelV P NB M' S'.tab.length x0 r r'

section
variable {P : LoadP} {NB : Nat} {ν : Nat → F64}

theorem addN_get_self {x : NSt} (hk : x.nnext < 2 ^ 62) (nd0 : Node) : (addN x nd0).nodes.get x.nnext = some nd0 := by
  show (x.nodes.set x.nnext nd0).get x.nnext = _
  rw [PTrie.gs _ _ _ hk]; simp

theorem addN_get_ne {x : NSt} (hk : x.nnext < 2 ^ 62) (nd0 : Node) {b : Nat} (e : b ≠ x.nnext) :
    (addN x nd0).nodes.get b = x.nodes.get b := by
  show (x.nodes.set x.nnext nd0).get b = _
  rw [PTrie.gs _ _ _ hk]; simp [e]

/-- **The replay over symbolic shapes** on related states, the template's replay having a result. -/
theorem MR.replayOrderV (c : Nat) (x0 : NSt) (hx0 : ∀ b, PN x0 b → b < x0.nnext) :
    ∀ (ns : List Nat) {M : Map} {S : SSrv} {C : CSrv} {x y : NSt} (m : List (Nat × Nat)) {L : List Nat},
    Srv M ν S C → MR P NB M S.tab.length x y → rwalk x0 x.nnext m ns = some L → (∀ a ∈ ns, a < P.NL) →
    NGrow x0 x → x.next = x0.next → x.arrs = x0.arrs → x.objs = x0.objs →
    (∀ p ∈ m, PN x p.1 ∧ PN x p.2) →
    (∀ b nd, x0.nnext ≤ b → x.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks) →
    (∀ b ∈ L, ∀ nd, x0.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks) →
    x.nnext + ns.length ≤ P.NE → RunSome S (Host.Mlx.Ffi.replayOrder x c m ns) →
    MSim (RPostV P NB x0 M ν S C) S C (Host.Mlx.Ffi.replayOrder x c m ns)
      (Host.Mlx.Ffi.replayOrder y (M.handle c) (substN M m) (ns.map M.node))
  | [], M, S, C, x, y, m, L, hs, hr, _, _, hg, e1, e2, e3, hm, _, _, _, _ =>
    MSim.pure (M := M) ⟨GrowL.refl hs, hr, rfl, hm, hg, e1, e2, e3⟩
  | a :: ns, M, S, C, x, y, m, L, hs, hr, hw, hband, hg, e1, e2, e3, hm, hnew, hL, hroom, hrun => by
    have hroom2 : x.nnext + ns.length ≤ P.NE := by simp at hroom; omega
    have hroom1 : x.nnext + 1 + ns.length ≤ P.NE := by simp at hroom; omega
    have haNL : a < P.NL := hband a List.mem_cons_self
    have hband' : ∀ b ∈ ns, b < P.NL := fun b hb => hband b (List.mem_cons_of_mem _ hb)
    have hmQ : ∀ p ∈ m, PN x p.1 := fun p hp => (hm p hp).1
    have hsub : ∀ b, PN x b → Host.Mlx.Ffi.substOf (substN M m) (M.node b) = M.node (Host.Mlx.Ffi.substOf m b) :=
      fun b hb => substOf_substN M (Q := PN x) (fun u v hu hv => hr.ninj u v hu hv) m hmQ b hb
    have hsubP : ∀ b, PN x b → PN x (Host.Mlx.Ffi.substOf m b) := fun b hb => by
      rcases substOf_mem m b with e | ⟨p, hp, e⟩
      · rw [e]; exact hb
      · rw [e]; exact (hm p hp).2
    have hx0x : ∀ b, PN x0 b → x.nodes.get b = x0.nodes.get b := fun b hb => hg.2 b (hx0 b hb)
    have hk62 : x.nnext < 2 ^ 62 := hr.xnnext_lt
    have hm1 : ∀ (nd0 : Node), ∀ p ∈ (a, x.nnext) :: m, PN (addN x nd0) p.1 ∧ PN (addN x nd0) p.2 := by
      intro nd0 p hp
      have hg1 := hr.ngrow_addN nd0
      rcases List.mem_cons.mp hp with rfl | hp
      · refine ⟨hr.pn_grow hg1 ?_, hr.pn_addN nd0⟩
        unfold rwalk at hw
        cases hx0a : x0.nodes.get a with
        | none => rw [hx0a] at hw; cases hw
        | some nd => unfold PN; rw [hx0x a (pn_of_get hx0a), hx0a]; rfl
      · exact ⟨hr.pn_grow hg1 (hm p hp).1, hr.pn_grow hg1 (hm p hp).2⟩
    unfold rwalk at hw
    cases hx0a : x0.nodes.get a with
    | none => rw [hx0a] at hw; cases hw
    | some nd =>
    rw [hx0a] at hw
    dsimp only at hw
    have hpa0 : PN x0 a := pn_of_get hx0a
    have hxa : x.nodes.get a = some nd := by rw [hx0x a hpa0, hx0a]
    cases hinsP : nd.ins.all (fun b => (x0.nodes.get b).isSome)
    · rw [hinsP] at hw; cases hw
    rw [hinsP, Bool.cond_true] at hw
    have hinsP0 : ∀ b ∈ nd.ins, PN x0 b := fun b hb => List.all_eq_true.mp hinsP b hb
    have hinsPx : ∀ b ∈ nd.ins, PN x b := fun b hb => by
      unfold PN; rw [hx0x b (hinsP0 b hb)]; exact hinsP0 b hb
    obtain ⟨nd', hya, hs1, hd1, hc1, hf1⟩ := hr.nodes a nd hxa
    obtain ⟨hp1, hi1⟩ := hf1 (.inl haNL)
    have hclp : SP (· < S.tab.length) nd.prim := (hr.cl.1 a nd hxa).1
    have hcls : SDs (· < S.tab.length) nd.shape := (hr.cl.1 a nd hxa).2
    have hsubst : nd'.ins.map (Host.Mlx.Ffi.substOf (substN M m)) =
        (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node := by
      rw [hi1, List.map_map, List.map_map]
      exact List.map_congr_left fun b hb => hsub b (hinsPx b hb)
    have hpres : ∀ b ∈ nd.ins.map (Host.Mlx.Ffi.substOf m), PN x b := by
      intro b hb
      obtain ⟨b0, hb0, rfl⟩ := List.mem_map.mp hb
      exact hsubP b0 (hinsPx b0 hb0)
    rw [List.map_cons]
    cases hl : leafP nd.prim
    case true =>
      rw [hl, Bool.cond_true] at hw
      have hl' : leafP nd'.prim = true := by rw [leafP_primR hp1]; exact hl
      rw [replayOrder_leaf hxa hl] at hrun ⊢
      rw [replayOrder_leaf hya hl']
      exact MR.replayOrderV c x0 hx0 ns m hs hr hw hband' hg e1 e2 e3 hm hnew hL hroom2 hrun
    rw [hl, Bool.cond_false] at hw
    have hl' : leafP nd'.prim = false := by rw [leafP_primR hp1]; exact hl
    have hp1' : nd'.prim = M.prim nd.prim := primR_exact hp1 hl
    cases hk : Host.Mlx.Ffi.isKernel nd.prim
    case true =>
      rw [hk, Bool.cond_true] at hw
      cases hdo : nd.shape.all dimOkV
      · rw [hdo] at hw; cases hw
      rw [hdo, Bool.cond_true] at hw
      cases hw' : rwalk x0 (x.nnext + 1) ((a, x.nnext) :: m) ns with
      | none => rw [hw'] at hw; cases hw
      | some L' =>
      rw [hw'] at hw
      simp only [Option.map_some, Option.some.injEq] at hw
      subst hw
      have hk' : Host.Mlx.Ffi.isKernel nd'.prim = true := by rw [hp1', isKernel_mprim]; exact hk
      let nd0 : Node := ⟨.replayed c nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), nd.shape, nd.dtype⟩
      rw [replayOrder_kern hxa hl hk] at hrun ⊢
      rw [replayOrder_kern hya hl' hk', hsubst, hs1, hd1, hp1', ← hr.node_next, ← substN_cons]
      have hnn : (⟨.replayed (M.handle c) (M.prim nd.prim), (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node,
          M.dims nd.shape, nd.dtype⟩ : Node) = M.nnode nd0 := rfl
      rw [hnn]
      have hr1 : MR P NB M S.tab.length (addN x nd0) (addN y (M.nnode nd0)) :=
        hr.addNode nd0 (by omega) ⟨hclp, hcls⟩ hc1
      have hg1 := hr.ngrow_addN nd0
      refine MR.replayOrderV c x0 hx0 ns ((a, x.nnext) :: m) hs hr1 hw' hband' (hg.trans hg1) e1 e2 e3 (hm1 nd0)
        ?_ (fun b hb => hL b (List.mem_cons_of_mem _ hb)) hroom1 hrun
      intro b nd1 hb h1
      by_cases e : b = x.nnext
      · subst e
        rw [addN_get_self hk62] at h1
        cases h1
        exact hL a List.mem_cons_self nd hx0a
      · rw [addN_get_ne hk62 nd0 e] at h1
        exact hnew b nd1 hb h1
    rw [hk, Bool.cond_false] at hw
    have hk' : Host.Mlx.Ffi.isKernel nd'.prim = false := by rw [hp1', isKernel_mprim]; exact hk
    have hdec : nd'.ins.map (Host.Mlx.Ffi.substOf (substN M m)) = nd'.ins ↔
        nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins := by
      rw [hsubst, hi1]
      exact ⟨fun h => map_inj_on (fun u v hu hv h => hr.ninj u v hu hv h) hpres hinsPx h, fun h => by rw [h]⟩
    by_cases hq : nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins
    · rw [decide_eq_true hq, Bool.cond_true] at hw
      rw [replayOrder_same hxa hl hk hq] at hrun ⊢
      rw [replayOrder_same hya hl' hk' (hdec.2 hq)]
      exact MR.replayOrderV c x0 hx0 ns m hs hr hw hband' hg e1 e2 e3 hm hnew hL hroom2 hrun
    rw [decide_eq_false hq, Bool.cond_false] at hw
    cases hc : (symOp nd.prim (nd.ins.map (Host.Mlx.Ffi.substOf m)).length &&
        (nd.ins.map (Host.Mlx.Ffi.substOf m)).all (fun b => decide (x0.nnext ≤ b) || valuedN x0 b))
    · rw [hc] at hw; cases hw
    rw [hc, Bool.cond_true] at hw
    rw [Bool.and_eq_true] at hc
    obtain ⟨hso, -⟩ := hc
    cases hw' : rwalk x0 (x.nnext + 1) ((a, x.nnext) :: m) ns with
    | none => rw [hw'] at hw; cases hw
    | some L' =>
    rw [hw'] at hw
    simp only [Option.map_some, Option.some.injEq] at hw
    subst hw
    obtain ⟨sh, hsx⟩ := shapesOf_some hpres
    have hsy := hr.shapesOf_map hsx
    rw [← hsubst] at hsy
    rw [replayOrder_inf hxa hl hk hq hsx] at hrun ⊢
    rw [replayOrder_inf hya hl' hk' (fun h => hq (hdec.1 h)) hsy, hsubst, hp1']
    have hv : ∀ q ∈ sh, ∃ ks, DVSs M C S q.1 ks ∧ Bd ks := by
      intro q hq'
      obtain ⟨b, hb, nd1, h1, rfl⟩ := shapesOf_get hsx q hq'
      by_cases hn : x0.nnext ≤ b
      · exact hnew b nd1 hn h1
      · have h0 : x0.nodes.get b = some nd1 := by rw [← hg.2 b (by omega)]; exact h1
        exact hL b (List.mem_append_left _ (List.mem_filter.mpr ⟨hb, decide_eq_true (by omega)⟩)) nd1 h0
    have hso' : symOp nd.prim sh.length = true := by rw [shapesOf_length hsx]; exact hso
    refine MSim.bind (Full.MSim.both (inferV_sim hs hso' hv) (NativeLawful.infer_l _ _)
      (NativeLawful.infer_l _ _)) fun M1 S1 C1 r r' h => ?_
    obtain ⟨⟨g1, hout⟩, hrS, -⟩ := h
    have hrun1 := RunSome.bind (NativeLawful.infer_l _ _) hrS hrun
    rcases hout with rfl | ⟨s, d, ks, rfl, rfl, hks, bks⟩
    · exact absurd (hrun1 none S1 rfl) (by simp)
    have hs1' := g1.grow.srv
    have hrg : MR P NB M1 S1.tab.length x y := hr.grow g1.grow
    have en : M1.node = M.node := g1.grow.ext.node
    have eh : M1.handle c = M.handle c := by simp only [Map.handle, g1.grow.ext.big]
    have ep : M1.prim nd.prim = M.prim nd.prim := (NAgree.ofExt g1.grow.ext).prim hclp
    have esn : ∀ m' : List (Nat × Nat), substN M1 m' = substN M m' := fun m' => by simp only [substN, en]
    have hclp1 : SP (· < S1.tab.length) nd.prim := SP.mono (fun i hi => Nat.lt_of_lt_of_le hi g1.grow.len) hclp
    let nd0 : Node := ⟨.replayed c nd.prim, nd.ins.map (Host.Mlx.Ffi.substOf m), s, d⟩
    have hr1 : MR P NB M1 S1.tab.length (addN x nd0) (addN y (M1.nnode nd0)) :=
      hrg.addNode nd0 (by omega) ⟨hclp1, hks.sds⟩ (hks.canon bks.lt53)
    have hnn : M1.nnode nd0 = ⟨.replayed (M.handle c) (M.prim nd.prim),
        (nd.ins.map (Host.Mlx.Ffi.substOf m)).map M.node, M1.dims s, d⟩ := by
      simp only [nd0, Map.nnode, Map.prim, eh, ep, en]
    have hg1 := hr.ngrow_addN nd0
    have hnew1 : ∀ b nd1, x0.nnext ≤ b → (addN x nd0).nodes.get b = some nd1 →
        ∃ ks, DVSs M1 C1 S1 nd1.shape ks ∧ Bd ks := by
      intro b nd1 hb h1
      by_cases e : b = x.nnext
      · subst e
        rw [addN_get_self hk62] at h1
        cases h1
        exact ⟨ks, hks, bks⟩
      · rw [addN_get_ne hk62 nd0 e] at h1
        obtain ⟨ks', h2, b2⟩ := hnew b nd1 hb h1
        exact ⟨ks', (DVSs.lift g1 h2).1, b2⟩
    have hL1 : ∀ b ∈ L', ∀ nd1, x0.nodes.get b = some nd1 → ∃ ks, DVSs M1 C1 S1 nd1.shape ks ∧ Bd ks := by
      intro b hb nd1 h1
      obtain ⟨ks', h2, b2⟩ := hL b (List.mem_append_right _ hb) nd1 h1
      exact ⟨ks', (DVSs.lift g1 h2).1, b2⟩
    have ih := MR.replayOrderV c x0 hx0 ns ((a, x.nnext) :: m) hs1' hr1 hw' hband' (hg.trans hg1) e1 e2 e3
      (hm1 nd0) hnew1 hL1 hroom1 hrun1
    rw [hnn, eh, esn, substN_cons, en, hr.node_next] at ih
    exact MSim.mono ih fun M' S' C' r r' h => ⟨g1.trans h.1, h.2⟩

end


/-! ## `mlx_closure_apply` over symbolic shapes -/

theorem rwalk_valued {x : NSt} : ∀ (ns : List Nat) (nn : Nat) (m : List (Nat × Nat)) {L : List Nat},
    rwalk x nn m ns = some L → ∀ b ∈ L, valuedN x b = true
  | [], _, _, L, hw, b, hb => by simp only [rwalk, Option.some.injEq] at hw; subst hw; cases hb
  | a :: ns, nn, m, L, hw, b, hb => by
    unfold rwalk at hw
    cases hxa : x.nodes.get a with
    | none => rw [hxa] at hw; cases hw
    | some nd =>
    rw [hxa] at hw
    dsimp only at hw
    cases hi : nd.ins.all (fun b => (x.nodes.get b).isSome)
    · rw [hi] at hw; cases hw
    rw [hi, Bool.cond_true] at hw
    cases hl : leafP nd.prim
    case true => rw [hl, Bool.cond_true] at hw; exact rwalk_valued ns nn m hw b hb
    rw [hl, Bool.cond_false] at hw
    cases hk : Host.Mlx.Ffi.isKernel nd.prim
    case true =>
      rw [hk, Bool.cond_true] at hw
      cases hdo : nd.shape.all dimOkV
      · rw [hdo] at hw; cases hw
      rw [hdo, Bool.cond_true] at hw
      cases hw' : rwalk x (nn + 1) ((a, nn) :: m) ns with
      | none => rw [hw'] at hw; cases hw
      | some L' =>
        rw [hw'] at hw
        simp only [Option.map_some, Option.some.injEq] at hw
        subst hw
        rcases List.mem_cons.mp hb with rfl | hb
        · unfold valuedN; rw [hxa]; exact hdo
        · exact rwalk_valued ns (nn + 1) _ hw' b hb
    rw [hk, Bool.cond_false] at hw
    cases hq : decide (nd.ins.map (Host.Mlx.Ffi.substOf m) = nd.ins)
    case true => rw [hq, Bool.cond_true] at hw; exact rwalk_valued ns nn m hw b hb
    rw [hq, Bool.cond_false] at hw
    cases hc : (symOp nd.prim (nd.ins.map (Host.Mlx.Ffi.substOf m)).length &&
        (nd.ins.map (Host.Mlx.Ffi.substOf m)).all (fun b => decide (x.nnext ≤ b) || valuedN x b))
    · rw [hc] at hw; cases hw
    rw [hc, Bool.cond_true] at hw
    rw [Bool.and_eq_true] at hc
    cases hw' : rwalk x (nn + 1) ((a, nn) :: m) ns with
    | none => rw [hw'] at hw; cases hw
    | some L' =>
      rw [hw'] at hw
      simp only [Option.map_some, Option.some.injEq] at hw
      subst hw
      rcases List.mem_append.mp hb with hb | hb
      · obtain ⟨hb1, hb2⟩ := List.mem_filter.mp hb
        have := List.all_eq_true.mp hc.2 b hb1
        simp only [Bool.or_eq_true, decide_eq_true_eq] at this hb2
        rcases this with h | h
        · omega
        · exact h
      · exact rwalk_valued ns (nn + 1) _ hw' b hb

/-- **An apply the symbolic replay covers**: the trace found is not the literal replay's (`rchk` at the
node counter fails), it replays under `rwalk` and its nodes are pre-loop. -/
def NativeOkX.clApplyV (P : LoadP) (x : NSt) : List Arg → Bool
  | [o, c, v] => slotOk P x o && hdOk x c && vecOk x v && decide (x.next + 1 ≤ P.E) &&
    match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj?, Host.Mlx.Ffi.argNat c with
    | some (.clo (.compiled _ _ sl ts)), some (.vec xs), some ck =>
      xs.all (fun k => (x.nodes.get k).isSome) && ts.all (traceOkG x sl xs) &&
        match Host.Mlx.Ffi.findTrace x sl xs ts (Option Trace) Free.pure with
        | .pure (some t) => (rwalk x x.nnext (t.ins.zip xs) t.order).isSome &&
            !(rchk x.nnext ck x (t.ins.zip xs) t.order) && t.order.all (fun a => decide (a < P.NL)) &&
            decide (x.nnext + t.order.length ≤ P.NE)
        | _ => false
    | _, _, _ => false
  | _ => false

/-- The trace an apply finds, with its closure and inputs. -/
def cloFound (x : NSt) : List Arg → Option (Trace × Nat × List Nat)
  | [_, c, v] => match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj?, Host.Mlx.Ffi.argNat c with
    | some (.clo (.compiled _ _ sl ts)), some (.vec xs), some ck =>
      match Host.Mlx.Ffi.findTrace x sl xs ts (Option Trace) Free.pure with
      | .pure (some t) => some (t, ck, xs)
      | _ => none
    | _, _, _ => none
  | _ => none

/-- A node's shape's references. -/
def nodeRefs (x : NSt) (b : Nat) : List Nat :=
  match x.nodes.get b with
  | some nd => nd.shape.flatMap dimRefs
  | none => []

/-- The references of the nodes the symbolic replay of an apply lists. -/
def cloRefs (x : NSt) (args : List Arg) : List Nat :=
  match cloFound x args with
  | some (t, _, xs) => ((rwalk x x.nnext (t.ins.zip xs) t.order).getD []).flatMap (nodeRefs x)
  | none => []

/-- An apply the symbolic replay may cover: the trace found is not the literal replay's. -/
def cloSym (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name, cloFound x args with
  | some .closureApply, some (t, ck, xs) => !(rchk x.nnext ck x (t.ins.zip xs) t.order)
  | _, _ => false

/-- **The symbolic replay's numeric premise**: the listed nodes' references denote small naturals, and
the template's call has a result. -/
def cloSmall (ν : Nat → F64) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Prop :=
  cloSym x name args = true → (∀ j ∈ cloRefs x args, RefSmall ν S j) ∧ RunSome S (Host.Mlx.Ffi.call x name args)

/-- The template's call at `S` has a result (decided by evaluation). -/
def cloRunB (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match interpS (Host.Mlx.Ffi.call x name args).run S with
  | some (none, _) => false
  | _ => true

/-- The decider of `cloSmall`. -/
def cloSmallB (VB : Nat → Nat) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !cloSym x name args || ((cloRefs x args).all (refSmallB VB S) && cloRunB S x name args)

theorem cloSmallB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : cloSmallB VB S x name args = true) : cloSmall ν S x name args := by
  intro hc
  unfold cloSmallB at h
  rw [hc] at h
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at h
  refine ⟨fun j hj => refSmallB_sound (List.all_eq_true.mp h.1 j hj) hν, fun r S' hr' => ?_⟩
  have h2 := h.2
  unfold cloRunB at h2
  rw [hr'] at h2
  cases r
  · cases h2
  · rfl

theorem bind_bind {α β γ : Type} (m : Host.Ts.M α) (H : α → Host.Ts.M β) (G : β → Host.Ts.M γ) :
    Host.Ts.M.bind (Host.Ts.M.bind m H) G = Host.Ts.M.bind m (fun a => Host.Ts.M.bind (H a) G) := rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **Finishing an apply over symbolic shapes**: trace `t`'s replay `rwalk` accepts on present inputs,
its result written to a null or present slot, the template's run having a result. -/
theorem sim_applyDoneV {c b off sl : Nat} {t : Trace} {xs : List Nat} {L : List Nat}
    (hw : rwalk x x.nnext (t.ins.zip xs) t.order = some L) (hband : ∀ a ∈ t.order, a < P.NL)
    (hLv : ∀ b ∈ L, ∀ nd, x.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks)
    (hrun : RunSome S (Host.Mlx.Ffi.applyDone x c b off sl t xs))
    (tIns : ∀ a ∈ t.ins, PN x a) (hxs : ∀ k ∈ xs, PN x k) (tOuts : ∀ a ∈ t.outs, PN x a)
    (tRoom : x.nnext + t.order.length ≤ P.NE) (hsl : sl = 0 ∨ PH x sl) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.applyDone x c b off sl t xs)
      (Host.Mlx.Ffi.applyDone y (M.handle c) (M.a b) off (M.handle sl) (M.trace t) (xs.map M.node)) := by
  unfold Host.Mlx.Ffi.applyDone Host.Mlx.Ffi.replay at hrun ⊢
  rw [bind_bind] at hrun
  have hrunR := RunSome.of_bind (NativeLawful.replayOrder_l _ _ _ _) (by rfl) hrun
  have hzip : (M.trace t).ins.zip (xs.map M.node) = substN M (t.ins.zip xs) := by
    show (t.ins.map M.node).zip (xs.map M.node) = _
    rw [List.zip_map]; rfl
  have hzm : ∀ p ∈ t.ins.zip xs, PN x p.1 ∧ PN x p.2 := by
    intro p hp
    obtain ⟨a, k⟩ := p
    exact ⟨tIns a (List.of_mem_zip hp).1, hxs k (List.of_mem_zip hp).2⟩
  rw [hzip, show (M.trace t).order = t.order.map M.node from rfl, bind_bind, bind_bind]
  refine MSim.bind (MR.replayOrderV c x (fun b hb => hr.nlt b hb) t.order (t.ins.zip xs) hs hr hw hband
    (NGrow.refl x) rfl rfl rfl hzm (fun b nd hb hn => absurd (hr.nlt b (pn_of_get hn)) (by omega)) hLv tRoom hrunR)
    fun M1 S1 C1 rr rr' h => ?_
  obtain ⟨g1, hrel⟩ := h
  have hs1 := g1.grow.srv
  refine MSim.mono (P := MPost P NB M1 ν S1 C1) ?_ fun M' S' C' r r' h => ⟨g1.grow.trans h.1, h.2⟩
  cases rr with
  | none =>
    refine msim_stuck' hs1 ?_
    rcases rr' with _ | ⟨y', m1'⟩ <;> exact ⟨_, fun _ _ => rfl⟩
  | some q =>
    cases rr' with
    | none => exact hrel.elim
    | some q' =>
      obtain ⟨x', m1⟩ := q
      obtain ⟨y', m1'⟩ := q'
      obtain ⟨hr', rfl, hm1, hg, hnx, hax, hox⟩ := hrel
      have en : M1.node = M.node := g1.grow.ext.node
      have eh : M1.handle sl = M.handle sl := by simp only [Map.handle, g1.grow.ext.big]
      have ea : M1.a = M.a := g1.grow.ext.a
      show MSim _ S1 C1 (Host.Ts.M.bind (Host.Ts.M.pure _) _) (Host.Ts.M.bind (Host.Ts.M.pure _) _)
      have houts : (M.trace t).outs.map (Host.Mlx.Ffi.substOf (substN M1 m1)) =
          (t.outs.map (Host.Mlx.Ffi.substOf m1)).map M1.node := by
        show (t.outs.map M.node).map _ = _
        rw [List.map_map, List.map_map, ← en]
        exact List.map_congr_left fun a ha =>
          substOf_substN M1 (Q := PN x') (fun u v hu hv => hr'.ninj u v hu hv) m1 (fun p hp => (hm1 p hp).1) a
            (hr.pn_grow hg (tOuts a ha))
      have hsl' : sl = 0 ∨ PH x' sl := by
        rcases hsl with h | h
        · exact .inl h
        · right; unfold PH; rw [hax, hox]; exact h
      obtain ⟨hh, x'', hh', y'', e3, e4, hr2, hb⟩ :=
        hr'.setVec_map hsl' (by rw [hnx]; exact hE) (t.outs.map (Host.Mlx.Ffi.substOf m1))
      rw [bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl),
        bind_pureP (m := Host.Ts.M.pure _) (fun _ _ => rfl)]
      simp only
      rw [houts, ← eh, e3, e4]
      exact msim_okW' hs1 hr' rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M1 hb, ea]) hr2

/-- **An apply over symbolic shapes**: the trace found replays under `rwalk`. -/
theorem sim_closureApplyV (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.closureApply) {args : List Arg}
    (hok : NativeOkX.clApplyV P x args = true) (hsm : cloSmall ν S x name args) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  unfold NativeOkX.clApplyV at hok
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
        have hlits : ∀ t ∈ ts, ∃ a, Host.Mlx.Ffi.shapesOf x t.ins = some a ∧ (shl = true ∨ (ShLits a ∧ ShLits bb)) := by
          intro t ht
          obtain ⟨tI, -, tL⟩ := tOk t ht
          obtain ⟨a, ea⟩ := shapesOf_some tI
          refine ⟨a, ea, ?_⟩
          rcases tL with h | ⟨l1, l2⟩
          · exact .inl h
          · right
            obtain ⟨a', ea', la⟩ := shapesOf_lit l1
            obtain ⟨b', eb'', lb⟩ := shapesOf_lit l2
            rw [ea] at ea'; rw [eb] at eb''
            cases ea'; cases eb''
            exact ⟨la, lb⟩
        have hfit : ∀ t ∈ ts, Host.Mlx.Ffi.traceFits y shl (M.trace t) (xs.map M.node) =
            Host.Mlx.Ffi.traceFits x shl t xs := by
          intro t ht
          obtain ⟨a, ea, hl⟩ := hlits t ht
          exact traceFits_map M ea eb (hr.shapesOf_map ea) eb' hl
        obtain ⟨r, hrm, e⟩ := findTrace_pure x shl xs ts fun t ht => by
          obtain ⟨a, ea, hl⟩ := hlits t ht
          exact traceFits_pureG ea eb hl
        have e' : ∀ γ (k : Option Trace → Free γ),
            Host.Mlx.Ffi.findTrace y shl (xs.map M.node) (ts.map M.trace) γ k = k (r.map M.trace) := by
          intro γ k
          rw [findTrace_map M.trace ts hfit, e]
        rw [e] at hft
        cases r with
        | none => cases hft
        | some t =>
        simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true', List.all_eq_true] at hft
        obtain ⟨⟨⟨hwk, hnr⟩, hband⟩, tRoom⟩ := hft
        obtain ⟨L, hwL⟩ := Option.isSome_iff_exists.mp hwk
        have hts1 := hrm t rfl
        obtain ⟨tIns, tOuts, -⟩ := tOk t hts1
        -- the premise
        have hfound : cloFound x [o, .big (Int.ofNat ck), .big (Int.ofNat kv)] = some (t, ck, xs) := by
          unfold cloFound
          simp only [argNat_nat, Option.bind_some, hco, h3]
          rw [e]
        have hcs : cloSym x name [o, .big (Int.ofNat ck), .big (Int.ofNat kv)] = true := by
          unfold cloSym; rw [hsym, hfound]; simp only [hnr, Bool.not_false]
        obtain ⟨hrefs, hrun⟩ := hsm hcs
        have hrefsL : ∀ j ∈ L.flatMap (nodeRefs x), RefSmall ν S j := by
          intro j hj; apply hrefs j; unfold cloRefs; rw [hfound]; dsimp only; rw [hwL]; exact hj
        have hLv : ∀ b ∈ L, ∀ nd, x.nodes.get b = some nd → ∃ ks, DVSs M C S nd.shape ks ∧ Bd ks := by
          intro b hb nd hn
          have hval := rwalk_valued _ _ _ hwL b hb
          unfold valuedN at hval; rw [hn] at hval
          exact dvss_of hs hval fun j hj => hrefsL j (List.mem_flatMap.mpr ⟨b, hb, by unfold nodeRefs; rw [hn]; exact hj⟩)
        -- the run
        unfold Host.Mlx.Ffi.call at hrun; rw [hsym] at hrun
        unfold Host.Mlx.Ffi.closureApply at hrun
        simp only [h1, argNat_nat, Option.bind_some, hco, h3] at hrun
        rw [bind_pureP e] at hrun
        dsimp only at hrun
        simp only [List.map_cons, List.map_nil]
        rw [hmc, hmv]
        unfold Host.Mlx.Ffi.call; rw [hsym]
        unfold Host.Mlx.Ffi.closureApply
        simp only [h1, h2, argNat_nat, Option.bind_some, hco, hyc, h3, h4]
        rw [bind_pureP e, bind_pureP e']
        simp only [Option.map_some]
        exact sim_applyDoneV hs hr hwL hband hLv hrun tIns hxs' tOuts tRoom hsl hE'
      | _ => cases hm
    | _ => cases hm

end


end Host.Ts.Sim.G
