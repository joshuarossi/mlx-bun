import host.sim.full.SymCalls2
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf GraphOp)

/-! # The multi-row forwards' graph operations over symbolic shapes

`mlx_matmul`, `mlx_less_equal`, `mlx_where`, `mlx_softmax_axis` and `mlx_sum_axis`
(`Host.Mlx.Ffi.graphShape`) decide their output shape without number requests: dimensions agree
syntactically or are a literal `1`. Where the template's decision succeeds, the target's over the
images gives the image (`graphShape_map`), and its dimensions are the inputs' or literal
(`graphShape_mem`). -/

section
variable (M : Map)

theorem dim_lit1 : M.dim (.lit 1) = .lit 1 := rfl

theorem bcast_head (x y d : Dim)
    (hd : (bif decide (x = y) then some x else bif decide (x = .lit 1) then some y
      else bif decide (y = .lit 1) then some x else none) = some d) :
    (bif decide (M.dim x = M.dim y) then some (M.dim x) else bif decide (M.dim x = .lit 1) then some (M.dim y)
      else bif decide (M.dim y = .lit 1) then some (M.dim x) else none) = some (M.dim d) := by
  by_cases e1 : x = y
  · subst e1
    simp only [decide_true, Bool.cond_true, Option.some.injEq] at hd ⊢
    rw [hd]
  · by_cases e2 : x = .lit 1
    · subst e2
      simp only [e1, decide_false, Bool.cond_false, decide_true, Bool.cond_true, Option.some.injEq] at hd
      subst hd
      by_cases t1 : M.dim (.lit 1) = M.dim y
      · simp only [t1, decide_true, Bool.cond_true]
      · have t2 : decide (Dim.lit 1 = M.dim y) = false := by rw [dim_lit1] at t1; simp [t1]
        simp only [dim_lit1, decide_true, Bool.cond_true, Bool.cond_false]
        by_cases hc : Dim.lit 1 = M.dim y
        · simp [hc]
        · simp [hc]
    · by_cases e4 : y = .lit 1
      · subst e4
        simp only [e1, e2, decide_false, Bool.cond_false, decide_true, Bool.cond_true, Option.some.injEq] at hd
        subst hd
        by_cases t1 : M.dim x = M.dim (.lit 1)
        · simp only [t1, decide_true, Bool.cond_true]
        · have t2 : decide (M.dim x = Dim.lit 1) = false := by rw [dim_lit1] at t1; simp [t1]
          simp only [dim_lit1, decide_true, Bool.cond_true, Bool.cond_false]
          by_cases hc : M.dim x = Dim.lit 1
          · simp [hc]
          · simp [hc]
      · simp [e1, e2, e4] at hd

theorem bcastRev_map : ∀ {xs ys zs : List Dim}, Host.Mlx.Ffi.bcastRev xs ys = some zs →
    Host.Mlx.Ffi.bcastRev (M.dims xs) (M.dims ys) = some (M.dims zs)
  | [], ys, zs, h => by
    simp only [Host.Mlx.Ffi.bcastRev, Option.some.injEq] at h; subst h; rfl
  | x :: xs, [], zs, h => by
    simp only [Host.Mlx.Ffi.bcastRev, Option.some.injEq] at h; subst h; rfl
  | x :: xs, y :: ys, zs, h => by
    simp only [Host.Mlx.Ffi.bcastRev] at h
    show (bif decide (M.dim x = M.dim y) then some (M.dim x) else bif decide (M.dim x = .lit 1) then some (M.dim y)
      else bif decide (M.dim y = .lit 1) then some (M.dim x) else none).bind
        (fun d => (Host.Mlx.Ffi.bcastRev (M.dims xs) (M.dims ys)).map (d :: ·)) = some (M.dims zs)
    cases hh : (bif decide (x = y) then some x else bif decide (x = .lit 1) then some y
        else bif decide (y = .lit 1) then some x else none) with
    | none => rw [hh] at h; cases h
    | some d =>
      rw [hh] at h
      simp only [Option.bind_some] at h
      cases ht : Host.Mlx.Ffi.bcastRev xs ys with
      | none => rw [ht] at h; cases h
      | some t =>
        rw [ht] at h
        simp only [Option.map_some, Option.some.injEq] at h
        subst h
        rw [bcast_head M x y d hh, Option.bind_some, bcastRev_map ht]
        rfl

theorem bcastPure_map {a b c : List Dim} (h : Host.Mlx.Ffi.bcastPure a b = some c) :
    Host.Mlx.Ffi.bcastPure (M.dims a) (M.dims b) = some (M.dims c) := by
  unfold Host.Mlx.Ffi.bcastPure at h ⊢
  cases hr : Host.Mlx.Ffi.bcastRev a.reverse b.reverse with
  | none => rw [hr] at h; cases h
  | some r =>
    rw [hr] at h
    simp only [Option.map_some, Option.some.injEq] at h
    subst h
    have e1 : (M.dims a).reverse = M.dims a.reverse := by simp [Map.dims, List.map_reverse]
    have e2 : (M.dims b).reverse = M.dims b.reverse := by simp [Map.dims, List.map_reverse]
    rw [e1, e2, bcastRev_map M hr]
    simp [Map.dims, List.map_reverse]

theorem mem_bcastRev : ∀ {xs ys zs : List Dim}, Host.Mlx.Ffi.bcastRev xs ys = some zs → ∀ e ∈ zs, e ∈ xs ∨ e ∈ ys
  | [], ys, zs, h => by simp only [Host.Mlx.Ffi.bcastRev, Option.some.injEq] at h; subst h; exact fun e he => .inr he
  | x :: xs, [], zs, h => by simp only [Host.Mlx.Ffi.bcastRev, Option.some.injEq] at h; subst h; exact fun e he => .inl he
  | x :: xs, y :: ys, zs, h => by
    simp only [Host.Mlx.Ffi.bcastRev] at h
    cases hh : (bif decide (x = y) then some x else bif decide (x = .lit 1) then some y
        else bif decide (y = .lit 1) then some x else none) with
    | none => rw [hh] at h; cases h
    | some d =>
      rw [hh] at h
      simp only [Option.bind_some] at h
      cases ht : Host.Mlx.Ffi.bcastRev xs ys with
      | none => rw [ht] at h; cases h
      | some t =>
        rw [ht] at h
        simp only [Option.map_some, Option.some.injEq] at h
        subst h
        intro e he
        rcases List.mem_cons.mp he with rfl | he
        · have : e = x ∨ e = y := by
            cases e1 : decide (x = y) <;> cases e2 : decide (x = .lit 1) <;> cases e3 : decide (y = .lit 1) <;>
              simp_all
          rcases this with rfl | rfl
          · exact .inl List.mem_cons_self
          · exact .inr List.mem_cons_self
        · rcases mem_bcastRev ht e he with h' | h'
          · exact .inl (List.mem_cons_of_mem _ h')
          · exact .inr (List.mem_cons_of_mem _ h')

theorem mem_bcastPure {a b c : List Dim} (h : Host.Mlx.Ffi.bcastPure a b = some c) : ∀ e ∈ c, e ∈ a ∨ e ∈ b := by
  unfold Host.Mlx.Ffi.bcastPure at h
  cases hr : Host.Mlx.Ffi.bcastRev a.reverse b.reverse with
  | none => rw [hr] at h; cases h
  | some r =>
    rw [hr] at h
    simp only [Option.map_some, Option.some.injEq] at h
    subst h
    intro e he
    rcases mem_bcastRev hr e (List.mem_reverse.mp he) with h' | h'
    · exact .inl (List.mem_reverse.mp h')
    · exact .inr (List.mem_reverse.mp h')

theorem matmulShape_map {a b r : List Dim} {da db dt : Nat} (h : Host.Mlx.Ffi.matmulShape a b da db = some (r, dt)) :
    Host.Mlx.Ffi.matmulShape (M.dims a) (M.dims b) da db = some (M.dims r, dt) := by
  unfold Host.Mlx.Ffi.matmulShape at h ⊢
  dsimp only at h ⊢
  simp only [len_dims, nthD_dims]
  revert h
  cases c1 : (Nat.blt (len a) 2 || Nat.blt (len b) 2 || !Host.Mlx.Ffi.isInexact (Host.Mlx.Ffi.promote da db))
  · intro h
    simp only [Bool.cond_false] at h ⊢
    by_cases c2 : nthD (.lit 0) a (len a - 1) = nthD (.lit 0) b (len b - 2)
    · have c2' : M.dim (nthD (.lit 0) a (len a - 1)) = M.dim (nthD (.lit 0) b (len b - 2)) := by rw [c2]
      simp only [c2, c2', decide_true, Bool.not_true, Bool.cond_false] at h ⊢
      revert h
      cases c3 : (Nat.blt 2 (len a) && Nat.ble (len b) 2)
      · intro h
        simp only [Bool.cond_false] at h ⊢
        cases hb : Host.Mlx.Ffi.bcastPure (a.take (len a - 2)) (b.take (len b - 2)) with
        | none => rw [hb] at h; cases h
        | some bt =>
          rw [hb] at h
          simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          rw [← dims_take, ← dims_take, bcastPure_map M hb]
          simp [Map.dims]
      · intro h
        simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h ⊢
        obtain ⟨rfl, rfl⟩ := h
        rw [← dims_take]
        simp [Map.dims]
    · simp only [c2, decide_false, Bool.not_false, Bool.cond_true] at h
      cases h
  · intro h
    simp only [Bool.cond_true] at h
    cases h

end

theorem mem_matmulShape {a b r : List Dim} {da db dt : Nat} (h : Host.Mlx.Ffi.matmulShape a b da db = some (r, dt)) :
    ∀ e ∈ r, e ∈ a ∨ e ∈ b ∨ dimLit e = true := by
  unfold Host.Mlx.Ffi.matmulShape at h
  dsimp only at h
  have hn : nthD (.lit 0) b (len b - 1) ∈ b ∨ dimLit (nthD (.lit 0) b (len b - 1)) = true := by
    rcases mem_nthD (d := Dim.lit 0) (s := b) (i := len b - 1) with h' | h'
    · exact .inl h'
    · rw [h']; exact .inr rfl
  have ha2 : nthD (.lit 0) a (len a - 2) ∈ a ∨ dimLit (nthD (.lit 0) a (len a - 2)) = true := by
    rcases mem_nthD (d := Dim.lit 0) (s := a) (i := len a - 2) with h' | h'
    · exact .inl h'
    · rw [h']; exact .inr rfl
  revert h
  cases c1 : (Nat.blt (len a) 2 || Nat.blt (len b) 2 || !Host.Mlx.Ffi.isInexact (Host.Mlx.Ffi.promote da db))
  · intro h
    simp only [Bool.cond_false] at h
    by_cases c2 : nthD (.lit 0) a (len a - 1) = nthD (.lit 0) b (len b - 2)
    · simp only [c2, decide_true, Bool.not_true, Bool.cond_false] at h
      revert h
      cases c3 : (Nat.blt 2 (len a) && Nat.ble (len b) 2)
      · intro h
        simp only [Bool.cond_false] at h
        cases hb : Host.Mlx.Ffi.bcastPure (a.take (len a - 2)) (b.take (len b - 2)) with
        | none => rw [hb] at h; cases h
        | some bt =>
          rw [hb] at h
          simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          intro e he
          simp only [List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at he
          rcases he with he | rfl | rfl
          · rcases mem_bcastPure hb e he with h' | h'
            · exact .inl (List.mem_of_mem_take h')
            · exact .inr (.inl (List.mem_of_mem_take h'))
          · rcases ha2 with h' | h'
            · exact .inl h'
            · exact .inr (.inr h')
          · rcases hn with h' | h'
            · exact .inr (.inl h')
            · exact .inr (.inr h')
      · intro h
        simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        intro e he
        simp only [List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at he
        rcases he with he | rfl
        · exact .inl (List.mem_of_mem_take he)
        · rcases hn with h' | h'
          · exact .inr (.inl h')
          · exact .inr (.inr h')
    · simp only [c2, decide_false, Bool.not_false, Bool.cond_true] at h
      cases h
  · intro h
    simp only [Bool.cond_true] at h
    cases h

/-- The shape `graphShape` gives: over the images, the image; its dimensions the inputs' or literal. -/
theorem graphShape_map (M : Map) {op : GraphOp} {ax : Int} {f : Bool} :
    ∀ {sh : List (List Dim × Nat)} {r : List Dim} {d : Nat}, Host.Mlx.Ffi.graphShape op ax f sh = some (r, d) →
    Host.Mlx.Ffi.graphShape op ax f (sh.map M.shp) = some (M.dims r, d) ∧
      ∀ e ∈ r, (∃ p ∈ sh, e ∈ p.1) ∨ dimLit e = true
  | [(a, da), (b, db)], r, d, h => by
    cases op with
    | matmul =>
      refine ⟨matmulShape_map M h, fun e he => ?_⟩
      rcases mem_matmulShape h e he with h' | h' | h'
      · exact .inl ⟨_, List.mem_cons_self, h'⟩
      · exact .inl ⟨_, List.mem_cons_of_mem _ List.mem_cons_self, h'⟩
      · exact .inr h'
    | lessEqual =>
      simp only [Host.Mlx.Ffi.graphShape] at h ⊢
      cases hb : Host.Mlx.Ffi.bcastPure a b with
      | none => rw [hb] at h; cases h
      | some c =>
        rw [hb] at h
        simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        refine ⟨by simp only [List.map_cons, List.map_nil, Map.shp, bcastPure_map M hb, Option.map_some], fun e he => ?_⟩
        rcases mem_bcastPure hb e he with h' | h'
        · exact .inl ⟨_, List.mem_cons_self, h'⟩
        · exact .inl ⟨_, List.mem_cons_of_mem _ List.mem_cons_self, h'⟩
    | _ => simp [Host.Mlx.Ffi.graphShape] at h
  | [(c, dc), (x, dx), (y, dy)], r, d, h => by
    cases op with
    | select =>
      simp only [Host.Mlx.Ffi.graphShape] at h ⊢
      cases hb : Host.Mlx.Ffi.bcastPure c x with
      | none => rw [hb] at h; cases h
      | some cx =>
        rw [hb] at h
        simp only [Option.bind_some] at h
        cases hb2 : Host.Mlx.Ffi.bcastPure cx y with
        | none => rw [hb2] at h; cases h
        | some z =>
          rw [hb2] at h
          simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          refine ⟨by simp only [List.map_cons, List.map_nil, Map.shp, bcastPure_map M hb, Option.bind_some,
            bcastPure_map M hb2, Option.map_some], fun e he => ?_⟩
          rcases mem_bcastPure hb2 e he with h' | h'
          · rcases mem_bcastPure hb e h' with h'' | h''
            · exact .inl ⟨_, List.mem_cons_self, h''⟩
            · exact .inl ⟨_, List.mem_cons_of_mem _ List.mem_cons_self, h''⟩
          · exact .inl ⟨_, List.mem_cons_of_mem _ (List.mem_cons_of_mem _ List.mem_cons_self), h'⟩
    | _ => simp [Host.Mlx.Ffi.graphShape] at h
  | [(a, da)], r, d, h => by
    cases op with
    | softmax =>
      simp only [Host.Mlx.Ffi.graphShape] at h ⊢
      simp only [List.map_cons, List.map_nil, Map.shp, len_dims]
      cases hx : Host.Mlx.Ffi.axisOf ax (len a) with
      | none => rw [hx] at h; cases h
      | some k =>
        rw [hx] at h
        simp only [Option.bind_some] at h ⊢
        cases hc : (Nat.beq k (len a - 1) && Host.Mlx.Ffi.isFloat da) <;> rw [hc] at h
        · cases h
        · simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          refine ⟨rfl, fun e he => .inl ⟨_, List.mem_cons_self, he⟩⟩
    | sum =>
      simp only [Host.Mlx.Ffi.graphShape] at h ⊢
      simp only [List.map_cons, List.map_nil, Map.shp, len_dims]
      cases hx : Host.Mlx.Ffi.axisOf ax (len a) with
      | none => rw [hx] at h; cases h
      | some k =>
        rw [hx] at h
        simp only [Option.bind_some, Option.some.injEq, Prod.mk.injEq] at h ⊢
        obtain ⟨rfl, rfl⟩ := h
        cases f
        · refine ⟨by simp only [Bool.cond_false]; rw [← dims_take, ← dims_drop, ← dims_append]; exact ⟨rfl, trivial⟩, fun e he => ?_⟩
          simp only [Bool.cond_false, List.mem_append] at he
          rcases he with he | he
          · exact .inl ⟨_, List.mem_cons_self, List.mem_of_mem_take he⟩
          · exact .inl ⟨_, List.mem_cons_self, List.mem_of_mem_drop he⟩
        · refine ⟨by simp only [Bool.cond_true]; rw [setAt_dims_lit]; exact ⟨rfl, trivial⟩, fun e he => ?_⟩
          simp only [Bool.cond_true] at he
          rcases mem_setAt he with h' | rfl
          · exact .inl ⟨_, List.mem_cons_self, h'⟩
          · exact .inr rfl
    | _ => simp [Host.Mlx.Ffi.graphShape] at h
  | [], r, d, h => by simp [Host.Mlx.Ffi.graphShape] at h
  | _ :: _ :: _ :: _ :: _, r, d, h => by simp [Host.Mlx.Ffi.graphShape] at h

end Host.Ts.Sim.G

namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf GraphOp)

theorem arg_bool (M : Map) (a : Arg) (f : Bool) : M.arg a = .bool f ↔ a = .bool f := by
  cases a <;> simp [Map.arg]

theorem graphArrays_map (M : Map) (op : GraphOp) (a : Arg) (rest : List Arg) :
    Host.Mlx.Ffi.graphArrays op (M.arg a) (rest.map M.arg) = (Host.Mlx.Ffi.graphArrays op a rest).map M.arg := by
  match rest with
  | [] => cases op <;> rfl
  | [_] => cases op <;> rfl
  | [_, f] => cases op <;> cases f <;> rfl
  | [_, f, _] => cases op <;> cases f <;> rfl
  | _ :: f :: _ :: _ :: _ => cases op <;> cases f <;> rfl

theorem graphAxis_map (M : Map) (op : GraphOp) (rest : List Arg) :
    Host.Mlx.Ffi.graphAxis op (rest.map M.arg) = M.arg (Host.Mlx.Ffi.graphAxis op rest) := by
  match rest with
  | [] => cases op <;> rfl
  | [_] => cases op <;> rfl
  | [_, f] => cases op <;> cases f <;> rfl
  | [_, f, _] => cases op <;> cases f <;> rfl
  | _ :: f :: _ :: _ :: _ => cases op <;> cases f <;> rfl

theorem graphFlag_map (M : Map) (rest : List Arg) :
    Host.Mlx.Ffi.graphFlag (rest.map M.arg) = Host.Mlx.Ffi.graphFlag rest := by
  match rest with
  | [] => rfl
  | [_] => rfl
  | [_, f] => cases f <;> rfl
  | [_, f, _] => cases f <;> rfl
  | _ :: f :: _ :: _ :: _ => cases f <;> rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **A graph operation over symbolic shapes.** -/
theorem sim_graphX {op : GraphOp} (hsym : Host.Mlx.Ffi.symOf name = some (.graph op))
    {o a : Arg} {rest : List Arg} {ins : List Nat} {av : Int} {nd : Node} {r : List Dim} {dt : Nat}
    (ha : nodeOk x a = true) (hall : ∀ b ∈ Host.Mlx.Ffi.graphArrays op a rest, hdOk x b = true)
    (hax : natOk P (Host.Mlx.Ffi.graphAxis op rest) = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x (Host.Mlx.Ffi.graphArrays op a rest) = some ins)
    (eax : Host.Mlx.Ffi.argInt (Host.Mlx.Ffi.graphAxis op rest) = some av)
    (hn : (Host.Mlx.Ffi.argNat a).bind x.node? = some nd)
    (hg : Host.Mlx.Ffi.graphOut x op av rest ins = some (r, dt)) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name (o :: a :: rest))
      (Host.Mlx.Ffi.call y name ((o :: a :: rest).map M.arg)) := by
  obtain ⟨b, off, sl, e1, e2, hsl⟩ := hr.slot_map ho
  have t1 := hr.arrIns_some hall h1
  obtain ⟨k, j, nd0, nd', rfl, hm, hp, n1, n2, n3⟩ := hr.nodeArg ha
  rw [argNat_nat, Option.bind_some, n1] at hn
  cases hn
  have hgo := hg
  unfold Host.Mlx.Ffi.graphOut at hg
  cases hsh : Host.Mlx.Ffi.shapesOf x ins with
  | none => rw [hsh] at hg; cases hg
  | some sh =>
    rw [hsh, Option.bind_some] at hg
    obtain ⟨gm, gmem⟩ := graphShape_map M hg
    have hsy := hr.shapesOf_map hsh
    have hy : Host.Mlx.Ffi.graphOut y op av (rest.map M.arg) (ins.map M.node) = some (M.dims r, dt) := by
      unfold Host.Mlx.Ffi.graphOut; rw [hsy, Option.bind_some, graphFlag_map]; exact gm
    have hok := shOk_of hs hr hsh
    have hsd : SDs (· < S.tab.length) r := fun e he => by
      rcases gmem e he with ⟨p, hp, he'⟩ | hl
      · exact (hok p hp).1 e he'
      · cases e with
        | lit _ => trivial
        | sym _ => cases hl
    have hcn : ∀ e ∈ r, DimCanon M e := fun e he => by
      rcases gmem e he with ⟨p, hp, he'⟩ | hl
      · exact (hok p hp).2 e he'
      · exact dimCanon_lit M hl
    unfold Host.Mlx.Ffi.call; rw [hsym]
    simp only [List.map_cons]
    rw [graphArrays_map, graphAxis_map, t1, hr.natOk_argInt hax, eax]
    simp only [hm, argNat_nat, Option.bind_some, n2, h1, n1]
    simp only [e1, e2]
    unfold Host.Mlx.Ffi.graphResult Host.Mlx.Ffi.graphDtype
    rw [hy, hgo]
    simp only [Option.map_some]
    have hprim : Host.Mlx.Ffi.graphNodePrim op av (rest.map M.arg) nd' (ins.map M.node) =
        M.prim (Host.Mlx.Ffi.graphNodePrim op av rest nd ins) := by
      unfold Host.Mlx.Ffi.graphNodePrim Host.Mlx.Ffi.graphPrim
      rw [graphFlag_map, n3.1, len_dims, Native.len_map]
      cases Nat.beq (len ins) 1 <;> rfl
    rw [hprim]
    have hsp : SP (· < S.tab.length) (Host.Mlx.Ffi.graphNodePrim op av rest nd ins) := by
      unfold Host.Mlx.Ffi.graphNodePrim Host.Mlx.Ffi.graphPrim
      cases Nat.beq (len ins) 1 <;> trivial
    exact sim_nodeS hs hr hsl (fun _ => hE) hNE _ ins r dt hsp hsd hcn

end

end Host.Ts.Sim.G
