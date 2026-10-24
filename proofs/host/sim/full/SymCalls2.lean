import host.sim.full.SymCalls
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)

/-! # The forward's operations over symbolic shapes: calls with values

Calls whose inference or arguments read dimensions by value: broadcasting binary operations,
normalization, quantized matmul, reshapes, dynamic slices, zero arrays and kernel output shapes.
Dimension values come from the numeric premise (`RefSmall` of the dimensions' references, as
`host.sim.native.CallS` uses it); products are bounded statically (`prodBnd`). -/

/-- A static bound on a dimension's value (a reference denotes a natural below `2 ^ 31`). -/
def dimBnd : Dim → Nat
  | .lit i => max 1 i.toNat
  | .sym _ => 2 ^ 31

/-- A static bound on the product of every suffix of dimensions with values. -/
def prodBnd (ds : List Dim) : Nat := natProd (ds.map dimBnd)

theorem natProd_drop_le : ∀ (ks : List Nat) (n : Nat), (∀ k ∈ ks, 1 ≤ k) → natProd (ks.drop n) ≤ natProd ks
  | [], _, _ => by simp [natProd]
  | k :: ks, 0, _ => Nat.le_refl _
  | k :: ks, n + 1, h => by
    have hk : 1 ≤ k := h k List.mem_cons_self
    have := natProd_drop_le ks n fun k' hk' => h k' (List.mem_cons_of_mem _ hk')
    show natProd (ks.drop n) ≤ k * natProd ks
    exact Nat.le_trans this (Nat.le_mul_of_pos_left _ hk)

theorem natProd_le_of : ∀ {ks bs : List Nat}, ks.length = bs.length → (∀ i, ks.getD i 0 ≤ bs.getD i 0) →
    natProd ks ≤ natProd bs
  | [], [], _, _ => Nat.le_refl _
  | k :: ks, b :: bs, hl, h => by
    have h0 := h 0
    have ih := natProd_le_of (ks := ks) (bs := bs) (by simpa using hl) fun i => h (i + 1)
    exact Nat.mul_le_mul h0 ih

theorem _root_.Host.Ts.Sim.DVSs.prodB {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {ds : List Dim} {ks : List Nat}, DVSs M C S ds ks → Bd ks → prodBnd ds < 2 ^ 53 → ProdB ks := by
  intro ds ks h hb hp n
  have hle : ∀ {ds : List Dim} {ks : List Nat}, DVSs M C S ds ks → Bd ks →
      ks.length = (ds.map dimBnd).length ∧ ∀ i, ks.getD i 0 ≤ (ds.map dimBnd).getD i 0 := by
    intro ds ks h hb
    induction ds generalizing ks with
    | nil => cases ks with
      | nil => exact ⟨rfl, fun _ => by simp⟩
      | cons _ _ => exact h.elim
    | cons d ds ih => cases ks with
      | nil => exact h.elim
      | cons k ks =>
        obtain ⟨hd, hds⟩ := h
        obtain ⟨l1, l2⟩ := ih hds fun k' hk' => hb k' (List.mem_cons_of_mem _ hk')
        refine ⟨by simp [l1], fun i => ?_⟩
        cases i with
        | zero =>
          show k ≤ dimBnd d
          rcases hd.1 with rfl | ⟨j, rfl, -⟩
          · show k ≤ max 1 (Int.ofNat k).toNat
            exact Nat.le_max_right 1 k
          · show k ≤ 2 ^ 31
            exact Nat.le_of_lt (hb k List.mem_cons_self)
        | succ i => exact l2 i
  obtain ⟨l1, l2⟩ := hle h hb
  have hpos : ∀ b ∈ ds.map dimBnd, 1 ≤ b := by
    intro b hb'
    obtain ⟨d, -, rfl⟩ := List.mem_map.mp hb'
    cases d with
    | lit i => exact Nat.le_max_left _ _
    | sym _ => exact Nat.one_le_two_pow
  have e1 : natProd (ks.drop n) ≤ natProd ((ds.map dimBnd).drop n) :=
    natProd_le_of (by simp [l1]) fun i => by
      rw [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD, List.getElem?_drop, List.getElem?_drop]
      have := l2 (n + i)
      rwa [List.getD_eq_getElem?_getD, List.getD_eq_getElem?_getD] at this
  have e2 := natProd_drop_le (ds.map dimBnd) n hpos
  exact Nat.lt_of_le_of_lt (Nat.le_trans e1 e2) hp

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

theorem dvss_sh {ins : List Nat} {sh : List (List Dim × Nat)} (hsh : Host.Mlx.Ffi.shapesOf x ins = some sh)
    {s : List Dim} {d : Nat} (hm : (s, d) ∈ sh) (hv : s.all dimOkV = true)
    (hsm : ∀ j ∈ shRefs x ins, RefSmall ν S j) : ∃ ks, DVSs M C S s ks ∧ Bd ks :=
  dvss_of hs hv fun j hj => hsm j (shRefs_mem hsh hm hj)

theorem dvss_args {p c : Arg} {ds : List Dim} (h : Host.Mlx.Ffi.dimsArg p c = some ds) (hv : ds.all dimOkV = true)
    (hsm : ∀ j ∈ dimsArgRefs p c, RefSmall ν S j) : ∃ ks, DVSs M C S ds ks ∧ Bd ks :=
  dvss_of hs hv fun j hj => hsm j (dimsArgRefs_mem h hj)

theorem sim_binaryX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.binary)
    {o a b e : Arg} {ins : List Nat} {sa sb : List Dim} {da db : Nat} (ha : hdOk x a = true) (hb : hdOk x b = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a, b] = some ins) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(sa, da), (sb, db)])
    (va : sa.all dimOkV = true) (vb : sb.all dimOkV = true) (hsm : ∀ j ∈ shRefs x ins, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, b, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg b, M.arg e]) := by
  obtain ⟨ka, hka, bka⟩ := dvss_sh hs hr hsh List.mem_cons_self va hsm
  obtain ⟨kb, hkb, bkb⟩ := dvss_sh hs hr hsh (List.mem_cons_of_mem _ List.mem_cons_self) vb hsm
  have t1 := hr.arrIns_some (as := [a, b]) (by simp [ha, hb]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1]
  exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_binary_simV hs hka hkb bka bkb)

theorem sim_rms1X (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.rmsNorm)
    {o a w e : Arg} {eps : NumV} {ins : List Nat} {s : List Dim} {d : Nat} (ha : hdOk x a = true)
    (hw : natOk P w = true) (hw0 : Host.Mlx.Ffi.argNat w = some 0) (heps : SN (· < S.tab.length) eps)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d)]) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, w, .num eps, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg w, .num (M.nv eps), M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [hr.natOk_argNat hw, hw0, h1, t1]
  exact sim_opOutS hs hr ho hE hNE heps hsh (infer_rms1_simS hs (shOk_of hs hr hsh))

theorem sim_rms2X (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.rmsNorm)
    {o a w e : Arg} {eps : NumV} {ins : List Nat} {s : List Dim} {d dw : Nat} {n l : Int} (ha : hdOk x a = true)
    (hw : hdOk x w = true) (heps : SN (· < S.tab.length) eps)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a, w] = some ins) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d), ([.lit n], dw)])
    (hl : nthD (.lit 0) s (len s - 1) = .lit l) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, w, .num eps, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg w, .num (M.nv eps), M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a, w]) (by simp [ha, hw]) h1
  obtain ⟨kw, rfl, hpw, hmw⟩ := hr.hdOk_spec hw
  simp only [List.map_cons, List.map_nil] at t1
  rw [hmw] at t1 ⊢
  obtain ⟨k1, hk1⟩ := Nat.exists_eq_succ_of_ne_zero (hr.PH_ne_zero hpw)
  obtain ⟨k2, hk2⟩ := Nat.exists_eq_succ_of_ne_zero (hr.handle_pos hpw)
  rw [hk2] at t1 ⊢
  rw [hk1] at h1 ⊢
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, h1, t1]
  have hc := shOk_of hs hr hsh
  exact sim_opOutS hs hr ho hE hNE heps hsh (infer_rms2_simS hs hl fun p hp => hc p (by
    rcases List.mem_singleton.mp hp with rfl; exact List.mem_cons_self))

theorem sim_qmmX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.qmm)
    {o a w sc bi g b mode e : Arg} {tr : Bool} {ins : List Nat} {gv bv : Option Nat} {m : List Char}
    {xs ws scs bis : List Dim} {dx dw dsc dbi : Nat} {xl : Int}
    (ha : hdOk x a = true) (hw : hdOk x w = true) (hsc : hdOk x sc = true) (hbi : hdOk x bi = true)
    (hg : natOk P g = true) (hb : natOk P b = true)
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a, w, sc, bi] = some ins) (eg : Host.Mlx.Ffi.optIntArg g = some gv)
    (eb : Host.Mlx.Ffi.optIntArg b = some bv) (hm : Host.Mlx.Ffi.cstrArg mode = some m)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(xs, dx), (ws, dw), (scs, dsc), (bis, dbi)])
    (hx : nthD (.lit 0) xs (len xs - 1) = .lit xl) (lw : Lits ws) (lsc : Lits scs) (lbi : Lits bis) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, w, sc, bi, .bool tr, g, b, mode, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg w, M.arg sc, M.arg bi, .bool tr, M.arg g, M.arg b,
        M.arg mode, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a, w, sc, bi]) (by simp [ha, hw, hsc, hbi]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, hr.optInt_eq hg, hr.optInt_eq hb, eg, eb, cstrArg_map, hm]
  have hc := shOk_of hs hr hsh
  exact sim_opOutS hs hr ho hE hNE trivial hsh (infer_qmm_simS hs hx lw lsc lbi fun p hp => hc p (by
    rcases List.mem_singleton.mp hp with rfl; exact List.mem_cons_self))

theorem sim_reshapeX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.reshape)
    {o a sh n e : Arg} {ins : List Nat} {new old : List Dim} {d : Nat} (ha : hdOk x a = true)
    (hd : dimsOk P sh n = true) (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (h2 : Host.Mlx.Ffi.dimsArg sh n = some new)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(old, d)]) (vn : new.all dimOkV = true) (vo : old.all dimOkV = true)
    (pn : prodBnd new < 2 ^ 53) (po : prodBnd old < 2 ^ 53)
    (hsm : ∀ j ∈ shRefs x ins ++ dimsArgRefs sh n, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, sh, n, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg sh, M.arg n, M.arg e]) := by
  obtain ⟨kn, hkn, bkn⟩ := dvss_args hs hr h2 vn fun j hj => hsm j (List.mem_append_right _ hj)
  obtain ⟨ko, hko, bko⟩ := dvss_sh hs hr hsh List.mem_cons_self vo fun j hj => hsm j (List.mem_append_left _ hj)
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, h2, hr.dimsArg_map hd h2]
  exact sim_opOutS hs hr ho hE hNE hkn.sds hsh
    (infer_reshape_simV hs hkn hko bkn.lt53 bko.lt53 (hkn.prodB bkn pn) (hko.prodB bko po))

theorem sim_sliceDynamicX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.sliceDynamic)
    {o a st ax n1 sz n2 e : Arg} {ins : List Nat} {d1 sizes : List Dim} {axes : List Nat} {s sst : List Dim}
    {d sd : Nat} (ha : hdOk x a = true) (hst : hdOk x st = true) (k1 : dimsOk P ax n1 = true)
    (k2 : dimsOk P sz n2 = true) (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h1 : Host.Mlx.Ffi.arrIns x [a, st] = some ins) (e1 : Host.Mlx.Ffi.dimsArg ax n1 = some d1)
    (e1' : Host.Mlx.Ffi.natsOfDims d1 = some axes) (e2 : Host.Mlx.Ffi.dimsArg sz n2 = some sizes)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, d), (sst, sd)]) (vz : sizes.all dimOkV = true)
    (hsm : ∀ j ∈ dimsArgRefs sz n2, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, st, ax, n1, sz, n2, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg st, M.arg ax, M.arg n1, M.arg sz, M.arg n2, M.arg e]) := by
  obtain ⟨kz, hkz, bkz⟩ := dvss_args hs hr e2 vz hsm
  have t1 := hr.arrIns_some (as := [a, st]) (by simp [ha, hst]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, e1, hr.dimsArg_map k1 e1, Option.bind_some, e1', natsOfDims_map M e1', e2,
    hr.dimsArg_map k2 e2]
  exact sim_opOutS hs hr ho hE hNE hkz.sds hsh (infer_sliceDynamic_simS hs hkz.sds (hkz.canon bkz.lt53))

theorem sim_zerosX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.zeros)
    {o sh m dt e : Arg} {ds : List Dim} (ho : slotOk P x o = true) (hd : dimsOk P sh m = true)
    (hdt : natOk P dt = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (h2 : Host.Mlx.Ffi.dimsArg sh m = some ds) (vz : ds.all dimOkV = true)
    (hsm : ∀ j ∈ dimsArgRefs sh m, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, sh, m, dt, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg sh, M.arg m, M.arg dt, M.arg e]) := by
  obtain ⟨kz, hkz, bkz⟩ := dvss_args hs hr h2 vz hsm
  obtain ⟨b, off, sl, e1, e2, hsl⟩ := hr.slot_map ho
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [hr.natOk_argNat hdt, h2, hr.dimsArg_map hd h2]
  cases hn : Host.Mlx.Ffi.argNat dt with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some dv =>
    simp only
    unfold Host.Mlx.Ffi.leafOut
    rw [e1, e2]
    exact sim_nodeS hs hr hsl (fun _ => hE) hNE .zeros [] ds dv trivial hkz.sds (hkz.canon bkz.lt53)

theorem sim_cfgOutputX (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgOutput) {c sh m dt : Arg}
    {ds : List Dim} (hc : cfgOk x c) (hd : dimsOk P sh m = true) (hdt : natOk P dt = true)
    (h2 : Host.Mlx.Ffi.dimsArg sh m = some ds) (vz : ds.all dimOkV = true)
    (hsm : ∀ j ∈ dimsArgRefs sh m, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [c, sh, m, dt])
      (Host.Mlx.Ffi.call y name [M.arg c, M.arg sh, M.arg m, M.arg dt]) := by
  obtain ⟨kz, hkz, bkz⟩ := dvss_args hs hr h2 vz hsm
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [hr.natOk_argNat hdt, h2, hr.dimsArg_map hd h2]
  cases hn : Host.Mlx.Ffi.argNat dt with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some d =>
    simp only
    refine sim_cfgUpdate hs hr hc (fun k => { k with outs := k.outs ++ [(ds, d)] })
      (fun k => { k with outs := k.outs ++ [(M.dims ds, d)] }) (fun k => (Map.cfg_outs M k ds d).symm) ?_ ?_
    · intro k hk
      refine ⟨fun p hp => ?_, hk.2.1, hk.2.2.1, hk.2.2.2.1, hk.2.2.2.2⟩
      rcases List.mem_append.mp hp with hp | hp
      · exact hk.1 p hp
      · simp only [List.mem_singleton] at hp; subst hp; exact hkz.sds
    · intro k hk p hp e he
      rcases List.mem_append.mp hp with hp | hp
      · exact hk p hp e he
      · simp only [List.mem_singleton] at hp; subst hp
        exact hkz.canon bkz.lt53 e he

end

end Host.Ts.Sim.G
