import host.sim.native.ShapeV
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf Out)

/-! # Shape inference over symbolic shapes

The inference of the decode route's symbolic operations: unit-stride slices and
slice updates and two-input concatenation over dimensions with values, and the
attention output, whose shape is assembled from its inputs' dimensions. Results
correspond (`OutR`): the source gives up, or both infer the same output under
the map, with closed and canonical symbolic dimensions. -/

def OutR (M : Map) (n : Nat) : Option Host.Mlx.Ffi.Out → Option Host.Mlx.Ffi.Out → Prop
  | none, _ => True
  | some (.node s d), some o' => o' = .node (M.dims s) d ∧ SDs (· < n) s ∧ ∀ e ∈ s, DimCanon M e
  | some (.same i), some o' => o' = .same i
  | some _, none => False

def IPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option Host.Mlx.Ffi.Out → Option Host.Mlx.Ffi.Out → Prop :=
  fun M' S' C' r r' => GrowL M ν S C M' S' C' ∧ OutR M' S'.tab.length r r'

/-! ## Lists -/

theorem dims_setAt (M : Map) : ∀ (s : List Dim) (i : Nat) (v : Dim),
    M.dims (Host.Mlx.Ffi.setAt s i v) = Host.Mlx.Ffi.setAt (M.dims s) i (M.dim v)
  | [], _, _ => rfl
  | _ :: _, 0, _ => rfl
  | x :: xs, n + 1, v => by
    show M.dim x :: M.dims (Host.Mlx.Ffi.setAt xs n v) = M.dim x :: Host.Mlx.Ffi.setAt (M.dims xs) n (M.dim v)
    rw [dims_setAt M xs n v]

theorem setAt_dims_lit (M : Map) (s : List Dim) (i : Nat) (c : Int) :
    Host.Mlx.Ffi.setAt (M.dims s) i (.lit c) = M.dims (Host.Mlx.Ffi.setAt s i (.lit c)) :=
  (dims_setAt M s i (.lit c)).symm

theorem nthD_dims (M : Map) : ∀ (s : List Dim) (i : Nat), nthD (.lit 0) (M.dims s) i = M.dim (nthD (.lit 0) s i)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: xs, n + 1 => nthD_dims M xs n

theorem len_dims (M : Map) (s : List Dim) : len (M.dims s) = len s := Native.len_map _ _

theorem mem_setAt {α : Type} : ∀ {s : List α} {i : Nat} {v e : α}, e ∈ Host.Mlx.Ffi.setAt s i v → e ∈ s ∨ e = v
  | [], _, _, _, h => by cases h
  | _ :: _, 0, _, _, h => by
    rcases List.mem_cons.mp h with h | h
    · exact .inr h
    · exact .inl (List.mem_cons_of_mem _ h)
  | _ :: xs, n + 1, _, _, h => by
    rcases List.mem_cons.mp h with h | h
    · exact .inl (h ▸ List.mem_cons_self ..)
    · rcases mem_setAt (s := xs) (i := n) h with h | h
      · exact .inl (List.mem_cons_of_mem _ h)
      · exact .inr h

theorem mem_nthD {α : Type} {d : α} : ∀ {s : List α} {i : Nat}, nthD d s i ∈ s ∨ nthD d s i = d
  | [], _ => .inr rfl
  | _ :: _, 0 => .inl (List.mem_cons_self ..)
  | _ :: xs, n + 1 => by
    rcases mem_nthD (d := d) (s := xs) (i := n) with h | h
    · exact .inl (List.mem_cons_of_mem _ h)
    · exact .inr h

section
variable {ν : Nat → F64}

theorem DVSs.setAt {M : Map} {S : SSrv} {C : CSrv} {v : Dim} {kv : Nat} (hv : DVS M C S v kv) :
    ∀ {s : List Dim} {ks : List Nat} (i : Nat), DVSs M C S s ks →
      DVSs M C S (Host.Mlx.Ffi.setAt s i v) (Host.Mlx.Ffi.setAt ks i kv)
  | [], [], _, _ => trivial
  | _ :: _, _ :: _, 0, h => ⟨hv, h.2⟩
  | _ :: _, _ :: _, n + 1, h => ⟨h.1, DVSs.setAt hv n h.2⟩
  | [], _ :: _, _, h => h.elim
  | _ :: _, [], _, h => h.elim

theorem DVSs.nthD {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {s : List Dim} {ks : List Nat} (i : Nat), DVSs M C S s ks → DVS M C S (nthD (.lit 0) s i) (nthD 0 ks i)
  | [], [], _, _ => DVS.lit M C S 0
  | _ :: _, _ :: _, 0, h => h.1
  | _ :: _, _ :: _, n + 1, h => DVSs.nthD n h.2
  | [], _ :: _, _, h => h.elim
  | _ :: _, [], _, h => h.elim

theorem Bd.nthD {ks : List Nat} (h : Bd ks) (i : Nat) : nthD 0 ks i < 2 ^ 31 := by
  rcases mem_nthD (d := 0) (s := ks) (i := i) with hm | hm
  · exact h _ hm
  · rw [hm]; omega

/-! ## Unit-stride slices -/

theorem infer_slice_simV {M : Map} {S : SSrv} {C : CSrv} {s st sp sr : List Dim} {d : Nat}
    {ks kst ksp : List Nat} (hs : Srv M ν S C) (h1 : DVSs M C S s ks) (h2 : DVSs M C S st kst)
    (h3 : DVSs M C S sp ksp) (b1 : Bd ks) (b2 : Bd kst) (b3 : Bd ksp) (hr : ∀ k ∈ sr, k = .lit 1) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.slice st sp sr) [(s, d)])
      (Host.Mlx.Ffi.infer (M.prim (.slice st sp sr)) ([(s, d)].map M.shp)) := by
  have esr : M.dims sr = sr := dims_lit M (List.all_eq_true.mpr fun k hk => by rw [hr k hk]; rfl)
  show MSim _ S C
    (bif Nat.beq (len st) (len s) then
      Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape s st sp sr) fun
        | some r => Host.Ts.M.bind (Host.Mlx.Ffi.allEq r s) fun e =>
          Host.Ts.M.pure (some (bif e then Out.same 0 else Out.node r d))
        | none => Host.Ts.M.pure none
    else Host.Ts.M.pure none)
    (bif Nat.beq (len (M.dims st)) (len (M.dims s)) then
      Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape (M.dims s) (M.dims st) (M.dims sp) (M.dims sr)) fun
        | some r => Host.Ts.M.bind (Host.Mlx.Ffi.allEq r (M.dims s)) fun e =>
          Host.Ts.M.pure (some (bif e then Out.same 0 else Out.node r d))
        | none => Host.Ts.M.pure none
    else Host.Ts.M.pure none)
  rw [len_dims, len_dims, esr]
  cases Nat.beq (len st) (len s)
  · exact MSim.pure ⟨GrowL.refl hs, trivial⟩
  · simp only [Bool.cond_true]
    refine MSim.bind (sliceShape_simV hr hs h1 h2 h3 b1 b2 b3) fun M1 S1 C1 r r' h => ?_
    obtain ⟨g1, h⟩ := h
    rcases h with ⟨rfl, rfl⟩ | ⟨ds, kds, rfl, rfl, hds, bds⟩
    · exact MSim.pure ⟨g1, trivial⟩
    · obtain ⟨h1', es⟩ := DVSs.lift g1 h1
      show MSim _ S1 C1 (Host.Ts.M.bind (Host.Mlx.Ffi.allEq ds s) fun e =>
          Host.Ts.M.pure (some (bif e then Out.same 0 else Out.node ds d)))
        (Host.Ts.M.bind (Host.Mlx.Ffi.allEq (M1.dims ds) (M.dims s)) fun e =>
          Host.Ts.M.pure (some (bif e then Out.same 0 else Out.node (M1.dims ds) d)))
      rw [← es]
      refine MSim.bind (allEq_simV g1.grow.srv hds h1' bds b1) fun M2 S2 C2 e e' h => MSim.pure (M := M2) ?_
      obtain ⟨h1, h2, g2⟩ := h
      subst h1 h2
      obtain ⟨hds2, eds⟩ := DVSs.lift g2 hds
      refine ⟨g1.trans g2, ?_⟩
      cases decide (kds = ks)
      · exact ⟨by rw [eds]; rfl, DVSs.sds hds2, DVSs.canon hds2 bds.lt53⟩
      · rfl

/-! ## Unit-stride slice updates -/

theorem infer_sliceUpdate_simV {M : Map} {S : SSrv} {C : CSrv} {s u st sp sr : List Dim} {d du : Nat}
    {ks ku kst ksp : List Nat} (hs : Srv M ν S C) (h1 : DVSs M C S s ks) (hu : DVSs M C S u ku)
    (h2 : DVSs M C S st kst) (h3 : DVSs M C S sp ksp) (b1 : Bd ks) (bu : Bd ku) (b2 : Bd kst) (b3 : Bd ksp)
    (hr : ∀ k ∈ sr, k = .lit 1) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.sliceUpdate st sp sr) [(s, d), (u, du)])
      (Host.Mlx.Ffi.infer (M.prim (.sliceUpdate st sp sr)) ([(s, d), (u, du)].map M.shp)) := by
  have esr : M.dims sr = sr := dims_lit M (List.all_eq_true.mpr fun k hk => by rw [hr k hk]; rfl)
  show MSim _ S C
    (Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape s st sp sr) fun
      | some r => Host.Ts.M.bind (Host.Mlx.Ffi.broadcast u r) fun
        | some b => Host.Ts.M.bind (Host.Mlx.Ffi.allEq b r) fun ok =>
          bif ok then Host.Ts.M.pure (some (Out.node s d)) else Host.Ts.M.pure none
        | none => Host.Ts.M.pure none
      | none => Host.Ts.M.pure none)
    (Host.Ts.M.bind (Host.Mlx.Ffi.sliceShape (M.dims s) (M.dims st) (M.dims sp) (M.dims sr)) fun
      | some r => Host.Ts.M.bind (Host.Mlx.Ffi.broadcast (M.dims u) r) fun
        | some b => Host.Ts.M.bind (Host.Mlx.Ffi.allEq b r) fun ok =>
          bif ok then Host.Ts.M.pure (some (Out.node (M.dims s) d)) else Host.Ts.M.pure none
        | none => Host.Ts.M.pure none
      | none => Host.Ts.M.pure none)
  rw [esr]
  refine MSim.bind (sliceShape_simV hr hs h1 h2 h3 b1 b2 b3) fun M1 S1 C1 r r' h => ?_
  obtain ⟨g1, h⟩ := h
  rcases h with ⟨rfl, rfl⟩ | ⟨ds, kds, rfl, rfl, hds, bds⟩
  · exact MSim.pure ⟨g1, trivial⟩
  · obtain ⟨hu1, eu⟩ := DVSs.lift g1 hu
    show MSim _ S1 C1
      (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast u ds) fun
        | some b => Host.Ts.M.bind (Host.Mlx.Ffi.allEq b ds) fun ok =>
          bif ok then Host.Ts.M.pure (some (Out.node s d)) else Host.Ts.M.pure none
        | none => Host.Ts.M.pure none)
      (Host.Ts.M.bind (Host.Mlx.Ffi.broadcast (M.dims u) (M1.dims ds)) fun
        | some b => Host.Ts.M.bind (Host.Mlx.Ffi.allEq b (M1.dims ds)) fun ok =>
          bif ok then Host.Ts.M.pure (some (Out.node (M.dims s) d)) else Host.Ts.M.pure none
        | none => Host.Ts.M.pure none)
    rw [← eu]
    refine MSim.bind (broadcast_simV g1.grow.srv hu1 hds bu bds) fun M2 S2 C2 r r' h => ?_
    obtain ⟨g2, h⟩ := h
    obtain ⟨hds2, eds⟩ := DVSs.lift g2 hds
    have hs2 := g2.grow.srv
    rcases h with ⟨rfl, ht⟩ | ⟨bs, kbs, rfl, rfl, hbs, bbs⟩
    · cases r' with
      | none => exact MSim.pure ⟨g1.trans g2, trivial⟩
      | some b' =>
        have hrun : TRuns (Host.Ts.M.bind (Host.Mlx.Ffi.allEq b' (M1.dims ds)) fun ok =>
            bif ok then Host.Ts.M.pure (some (Host.Mlx.Ffi.Out.node (M.dims s) d)) else Host.Ts.M.pure none) C2 := by
          refine TRuns.bind (tv_allEq b' (M1.dims ds) C2 (ht b' rfl) (by rw [← eds]; exact DVSs.tvs hds2 bds))
            fun ok C' _ => TRuns.cond _ (TRuns.pure _ _) (TRuns.pure _ _)
        exact MSim.mono (msim_none hs2 hrun) fun M3 S3 C3 r r' h => ⟨g1.trans (g2.trans h.2), by rw [h.1]; trivial⟩
    · show MSim _ S2 C2
        (Host.Ts.M.bind (Host.Mlx.Ffi.allEq bs ds) fun ok =>
          bif ok then Host.Ts.M.pure (some (Out.node s d)) else Host.Ts.M.pure none)
        (Host.Ts.M.bind (Host.Mlx.Ffi.allEq (M2.dims bs) (M1.dims ds)) fun ok =>
          bif ok then Host.Ts.M.pure (some (Out.node (M.dims s) d)) else Host.Ts.M.pure none)
      rw [← eds]
      refine MSim.bind (allEq_simV hs2 hbs hds2 bbs bds) fun M3 S3 C3 e e' h => ?_
      obtain ⟨h1, h2, g3⟩ := h
      subst h1 h2
      have G := g1.trans (g2.trans g3)
      obtain ⟨hs3, es⟩ := DVSs.lift G h1
      cases decide (kbs = kds)
      · exact MSim.pure ⟨G, trivial⟩
      · exact MSim.pure ⟨G, by rw [es], DVSs.sds hs3, DVSs.canon hs3 b1.lt53⟩

/-! ## Two-input concatenation -/

/-- The postcondition of a concatenation. -/
def CPost (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option (List Dim × Nat) → Option (List Dim × Nat) → Prop :=
  fun M' S' C' r r' => GrowL M ν S C M' S' C' ∧ ((r = none ∧ r' = none) ∨
    ∃ ds dt, r = some (ds, dt) ∧ r' = some (M'.dims ds, dt) ∧ SDs (· < S'.tab.length) ds ∧
      ∀ e ∈ ds, DimCanon M' e)

theorem concat2_simV {M : Map} {S : SSrv} {C : CSrv} (axis : Nat) {s1 s2 : List Dim} {d1 d2 : Nat}
    {k1 k2 : List Nat} (hs : Srv M ν S C) (h1 : DVSs M C S s1 k1) (h2 : DVSs M C S s2 k2) (b1 : Bd k1)
    (b2 : Bd k2) :
    MSim (CPost M ν S C) S C (Host.Mlx.Ffi.concatShape axis [(s1, d1), (s2, d2)])
      (Host.Mlx.Ffi.concatShape axis [(M.dims s1, d1), (M.dims s2, d2)]) := by
  show MSim _ S C
    (bif Nat.beq (len s1) (len s2) then
      Host.Ts.M.bind (Host.Mlx.Ffi.allEq (Host.Mlx.Ffi.setAt s1 axis (.lit 0)) (Host.Mlx.Ffi.setAt s2 axis (.lit 0)))
        (fun e => bif e then
          Host.Ts.M.bind (Host.Mlx.Ffi.dAdd (nthD (.lit 0) s1 axis) (nthD (.lit 0) s2 axis)) (fun a =>
            Host.Ts.M.pure (some (Host.Mlx.Ffi.setAt s1 axis a, Host.Mlx.Ffi.promote d1 d2)))
          else Host.Ts.M.pure none)
    else Host.Ts.M.pure none)
    (bif Nat.beq (len (M.dims s1)) (len (M.dims s2)) then
      Host.Ts.M.bind (Host.Mlx.Ffi.allEq (Host.Mlx.Ffi.setAt (M.dims s1) axis (.lit 0))
          (Host.Mlx.Ffi.setAt (M.dims s2) axis (.lit 0)))
        (fun e => bif e then
          Host.Ts.M.bind (Host.Mlx.Ffi.dAdd (nthD (.lit 0) (M.dims s1) axis) (nthD (.lit 0) (M.dims s2) axis))
            (fun a => Host.Ts.M.pure (some (Host.Mlx.Ffi.setAt (M.dims s1) axis a, Host.Mlx.Ffi.promote d1 d2)))
          else Host.Ts.M.pure none)
    else Host.Ts.M.pure none)
  rw [len_dims, len_dims]
  cases Nat.beq (len s1) (len s2)
  · exact MSim.pure ⟨GrowL.refl hs, .inl ⟨rfl, rfl⟩⟩
  · simp only [Bool.cond_true]
    rw [setAt_dims_lit, setAt_dims_lit]
    have z : DVS M C S (.lit 0) 0 := DVS.lit M C S 0
    have bz : ∀ {ks : List Nat}, Bd ks → Bd (Host.Mlx.Ffi.setAt ks axis 0) := fun hb k hk => by
      rcases mem_setAt hk with h | h
      · exact hb k h
      · rw [h]; omega
    refine MSim.bind (allEq_simV hs (DVSs.setAt z axis h1) (DVSs.setAt z axis h2) (bz b1) (bz b2))
      fun M1 S1 C1 e e' h => ?_
    obtain ⟨he1, he2, g1⟩ := h
    subst he1 he2
    cases decide (Host.Mlx.Ffi.setAt k1 axis 0 = Host.Mlx.Ffi.setAt k2 axis 0)
    · exact MSim.pure ⟨g1, .inl ⟨rfl, rfl⟩⟩
    · simp only [Bool.cond_true]
      obtain ⟨h1', e1⟩ := DVSs.lift g1 h1
      obtain ⟨h2', e2⟩ := DVSs.lift g1 h2
      rw [← e1, ← e2, nthD_dims, nthD_dims]
      have hn1 := DVSs.nthD axis h1'
      have hn2 := DVSs.nthD axis h2'
      have bn1 := b1.nthD axis
      have bn2 := b2.nthD axis
      refine MSim.bind (dAdd_simV g1.grow.srv hn1.1 hn2.1 hn1.2 hn2.2 (by omega)) fun M2 S2 C2 a a' h => ?_
      obtain ⟨rfl, ha, g2⟩ := DPost.ex h
      obtain ⟨h1'', e1'⟩ := DVSs.lift g2 h1'
      refine MSim.pure ⟨g1.trans g2, .inr ⟨_, _, rfl, ?_, ?_, ?_⟩⟩
      · rw [dims_setAt, e1']
      · exact DVSs.sds (DVSs.setAt ha axis h1'')
      · refine DVSs.canon (DVSs.setAt ha axis h1'') fun k hk => ?_
        rcases mem_setAt hk with h | h
        · have := b1 k h; omega
        · rw [h]; omega

theorem infer_concat2_simV {M : Map} {S : SSrv} {C : CSrv} (axis : Nat) {s1 s2 : List Dim} {d1 d2 : Nat}
    {k1 k2 : List Nat} (hs : Srv M ν S C) (h1 : DVSs M C S s1 k1) (h2 : DVSs M C S s2 k2) (b1 : Bd k1)
    (b2 : Bd k2) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.concat axis) [(s1, d1), (s2, d2)])
      (Host.Mlx.Ffi.infer (M.prim (.concat axis)) ([(s1, d1), (s2, d2)].map M.shp)) := by
  show MSim _ S C
    (Host.Ts.M.bind (Host.Mlx.Ffi.concatShape axis [(s1, d1), (s2, d2)]) fun r =>
      Host.Ts.M.pure (r.map fun (s, d) => Out.node s d))
    (Host.Ts.M.bind (Host.Mlx.Ffi.concatShape axis [(M.dims s1, d1), (M.dims s2, d2)]) fun r =>
      Host.Ts.M.pure (r.map fun (s, d) => Out.node s d))
  refine MSim.bind (concat2_simV axis hs h1 h2 b1 b2) fun M1 S1 C1 r r' h => MSim.pure (M := M1) ?_
  obtain ⟨g1, h⟩ := h
  rcases h with ⟨rfl, rfl⟩ | ⟨ds, dt, rfl, rfl, hsd, hc⟩
  · exact ⟨g1, trivial⟩
  · exact ⟨g1, rfl, hsd, hc⟩

/-! ## Attention -/

theorem infer_sdpa_simV {M : Map} {S : SSrv} {C : CSrv} {scale : NumV} {m : List Char} {q k v : List Dim}
    {dq dk dv : Nat} (hs : Srv M ν S C) (sq : SDs (· < S.tab.length) q) (sv : SDs (· < S.tab.length) v)
    (cq : ∀ e ∈ q, DimCanon M e) (cv : ∀ e ∈ v, DimCanon M e) :
    MSim (IPost M ν S C) S C (Host.Mlx.Ffi.infer (.sdpa scale m) [(q, dq), (k, dk), (v, dv)])
      (Host.Mlx.Ffi.infer (M.prim (.sdpa scale m)) ([(q, dq), (k, dk), (v, dv)].map M.shp)) := by
  show MSim _ S C
    (bif Nat.beq (len q) 4 && Nat.beq (len k) 4 && Nat.beq (len v) 4 then
      Host.Ts.M.pure (some (Out.node (Host.Mlx.Ffi.setAt q 3 (nthD (.lit 0) v 3))
        (Host.Mlx.Ffi.promote dq (Host.Mlx.Ffi.promote dk dv)))) else Host.Ts.M.pure none)
    (bif Nat.beq (len (M.dims q)) 4 && Nat.beq (len (M.dims k)) 4 && Nat.beq (len (M.dims v)) 4 then
      Host.Ts.M.pure (some (Out.node (Host.Mlx.Ffi.setAt (M.dims q) 3 (nthD (.lit 0) (M.dims v) 3))
        (Host.Mlx.Ffi.promote dq (Host.Mlx.Ffi.promote dk dv)))) else Host.Ts.M.pure none)
  rw [len_dims, len_dims, len_dims, nthD_dims, ← dims_setAt]
  cases Nat.beq (len q) 4 && Nat.beq (len k) 4 && Nat.beq (len v) 4
  · exact MSim.pure ⟨GrowL.refl hs, trivial⟩
  · refine MSim.pure ⟨GrowL.refl hs, rfl, fun e he => ?_, fun e he => ?_⟩
    · rcases mem_setAt he with h | h
      · exact sq e h
      · rcases mem_nthD (d := Dim.lit 0) (s := v) (i := 3) with h' | h'
        · exact h ▸ sv _ h'
        · rw [h, h']; trivial
    · rcases mem_setAt he with h | h
      · exact cq e h
      · rcases mem_nthD (d := Dim.lit 0) (s := v) (i := 3) with h' | h'
        · exact h ▸ cv _ h'
        · rw [h, h']; rfl
end

end Host.Ts.Sim
