import host.sim.native.Ops
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # The decode route's graph operations

Each lemma takes the source's decoded arguments (the check computes them)
and the operation check, and simulates the call by `sim_opOut`. -/

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

theorem MR.arrIns_some {as : List Arg} {ins : List Nat} (ha : ∀ a ∈ as, hdOk x a = true)
    (h : Host.Mlx.Ffi.arrIns x as = some ins) :
    Host.Mlx.Ffi.arrIns y (as.map M.arg) = some (ins.map M.node) := by
  rw [hr.arrIns_map ha, h]; rfl

theorem MR.argInt_eq {a : Arg} (h : natOk P a = true) : Host.Mlx.Ffi.argInt (M.arg a) = Host.Mlx.Ffi.argInt a :=
  hr.natOk_argInt h

theorem MR.optInt_eq {a : Arg} (h : natOk P a = true) :
    Host.Mlx.Ffi.optIntArg (M.arg a) = Host.Mlx.Ffi.optIntArg a := by
  unfold Host.Mlx.Ffi.optIntArg; rw [hr.natOk_argNat h]
end

section
variable {P : LoadP} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P M S.tab.length x y)
include hs hr

theorem sim_reshape (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.reshape)
    {o a sh m e : Arg} {ins : List Nat} {shape : List Dim} (ha : hdOk x a = true) (hd : dimsOk P sh m = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (h2 : Host.Mlx.Ffi.dimsArg sh m = some shape)
    (hop : opCheck P x o (.reshape shape) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, sh, m, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg sh, M.arg m, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, h2, hr.dimsArg_map hd h2]
  have hl := hop
  simp only [opCheck, primLit, Bool.and_eq_true] at hl
  exact sim_opOut hs hr hop (SDs.of_lit hl.1.2)

theorem sim_transpose (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.transpose)
    {o a ax m e : Arg} {ins : List Nat} {ds : List Dim} {axes : List Nat} (ha : hdOk x a = true)
    (hd : dimsOk P ax m = true) (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins)
    (h2 : Host.Mlx.Ffi.dimsArg ax m = some ds) (h3 : Host.Mlx.Ffi.natsOfDims ds = some axes)
    (hop : opCheck P x o (.transpose axes) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, ax, m, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg ax, M.arg m, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, h2, hr.dimsArg_map hd h2, Option.bind_some, h3, natsOfDims_map M h3]
  exact sim_opOut hs hr hop trivial

theorem sim_slice (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.slice)
    {o a st n1 sp n2 sr n3 e : Arg} {ins : List Nat} {d1 d2 d3 : List Dim} (ha : hdOk x a = true)
    (k1 : dimsOk P st n1 = true) (k2 : dimsOk P sp n2 = true) (k3 : dimsOk P sr n3 = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (e1 : Host.Mlx.Ffi.dimsArg st n1 = some d1)
    (e2 : Host.Mlx.Ffi.dimsArg sp n2 = some d2) (e3 : Host.Mlx.Ffi.dimsArg sr n3 = some d3)
    (hop : opCheck P x o (.slice d1 d2 d3) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, st, n1, sp, n2, sr, n3, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg st, M.arg n1, M.arg sp, M.arg n2, M.arg sr, M.arg n3,
        M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, e1, e2, e3, hr.dimsArg_map k1 e1, hr.dimsArg_map k2 e2, hr.dimsArg_map k3 e3]
  have hl := hop
  simp only [opCheck, primLit, Bool.and_eq_true] at hl
  exact sim_opOut hs hr hop ⟨SDs.of_lit hl.1.2.1.1, SDs.of_lit hl.1.2.1.2, SDs.of_lit hl.1.2.2⟩

theorem sim_sliceUpdate (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.sliceUpdate)
    {o a u st n1 sp n2 sr n3 e : Arg} {ins : List Nat} {d1 d2 d3 : List Dim} (ha : hdOk x a = true)
    (hu : hdOk x u = true)
    (k1 : dimsOk P st n1 = true) (k2 : dimsOk P sp n2 = true) (k3 : dimsOk P sr n3 = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a, u] = some ins) (e1 : Host.Mlx.Ffi.dimsArg st n1 = some d1)
    (e2 : Host.Mlx.Ffi.dimsArg sp n2 = some d2) (e3 : Host.Mlx.Ffi.dimsArg sr n3 = some d3)
    (hop : opCheck P x o (.sliceUpdate d1 d2 d3) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, u, st, n1, sp, n2, sr, n3, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg u, M.arg st, M.arg n1, M.arg sp, M.arg n2, M.arg sr,
        M.arg n3, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a, u]) (by simp [ha, hu]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, e1, e2, e3, hr.dimsArg_map k1 e1, hr.dimsArg_map k2 e2, hr.dimsArg_map k3 e3]
  have hl := hop
  simp only [opCheck, primLit, Bool.and_eq_true] at hl
  exact sim_opOut hs hr hop ⟨SDs.of_lit hl.1.2.1.1, SDs.of_lit hl.1.2.1.2, SDs.of_lit hl.1.2.2⟩

theorem sim_sliceDynamic (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.sliceDynamic)
    {o a st ax n1 sz n2 e : Arg} {ins : List Nat} {d1 sizes : List Dim} {axes : List Nat} (ha : hdOk x a = true)
    (hst : hdOk x st = true) (k1 : dimsOk P ax n1 = true) (k2 : dimsOk P sz n2 = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a, st] = some ins) (e1 : Host.Mlx.Ffi.dimsArg ax n1 = some d1)
    (e1' : Host.Mlx.Ffi.natsOfDims d1 = some axes) (e2 : Host.Mlx.Ffi.dimsArg sz n2 = some sizes)
    (hop : opCheck P x o (.sliceDynamic axes sizes) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, st, ax, n1, sz, n2, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg st, M.arg ax, M.arg n1, M.arg sz, M.arg n2, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a, st]) (by simp [ha, hst]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, e1, hr.dimsArg_map k1 e1, Option.bind_some, e1', natsOfDims_map M e1', e2,
    hr.dimsArg_map k2 e2]
  have hl := hop
  simp only [opCheck, primLit, Bool.and_eq_true] at hl
  exact sim_opOut hs hr hop (SDs.of_lit hl.1.2)

theorem sim_concat (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.concat)
    {o v ax e : Arg} {i : Nat} {rest : List Nat} {nd : Node} {a : Int} {b : Nat}
    (hv : hdOk x v = true) (hax : natOk P ax = true)
    (h3 : (Host.Mlx.Ffi.argNat v).bind x.obj? = some (.vec (i :: rest))) (hn : x.nodes.get i = some nd)
    (hai : Host.Mlx.Ffi.argInt ax = some a) (hb : Host.Mlx.Ffi.axisOf a (len nd.shape) = some b)
    (hop : opCheck P x o (.concat b) (i :: rest) = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, v, ax, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg v, M.arg ax, M.arg e]) := by
  obtain ⟨k, rfl, hp, hm⟩ := hr.hdOk_spec hv
  rw [argNat_nat, Option.bind_some] at h3
  have h4 : y.obj? (M.handle k) = some (.vec ((i :: rest).map M.node)) := by rw [hr.obj? hp, h3]; rfl
  obtain ⟨nd', h1, h2, -, -⟩ := hr.nodes i nd hn
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h3, h4, hr.argInt_eq hax, hai, List.map_cons, hn, h1, h2, Map.dims,
    Native.len_map, hb]
  exact sim_opOut (p := .concat b) (ins := i :: rest) hs hr hop trivial

theorem sim_unary (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.unary)
    {o a e : Arg} {ins : List Nat} (ha : hdOk x a = true) (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins)
    (hop : opCheck P x o (.unary (Host.Mlx.Ffi.strip name)) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1]
  exact sim_opOut hs hr hop trivial

theorem sim_binary (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.binary)
    {o a b e : Arg} {ins : List Nat} (ha : hdOk x a = true) (hb : hdOk x b = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a, b] = some ins)
    (hop : opCheck P x o (.binary (Host.Mlx.Ffi.strip name)) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, b, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg b, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a, b]) (by simp [ha, hb]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1]
  exact sim_opOut hs hr hop trivial

theorem sim_rmsNorm (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.rmsNorm)
    {o a w e : Arg} {eps : NumV} {ins : List Nat} (ha : hdOk x a = true) (hw : hdOk x w = true)
    (heps : SN (· < S.tab.length) eps) (h1 : Host.Mlx.Ffi.arrIns x [a, w] = some ins)
    (hop : opCheck P x o (.rmsNorm eps) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, w, .num eps, e])
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
  exact sim_opOut hs hr hop heps

theorem sim_rope (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.rope)
    {o a base freqs e : Arg} {dims : F64} {tr : Bool} {scale off : NumV} {ins : List Nat} {d : Int}
    (ha : hdOk x a = true) (hf : natOk P freqs = true) (hb : SA (· < S.tab.length) base)
    (hsc : SN (· < S.tab.length) scale) (hof : SN (· < S.tab.length) off)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (hd : F64.toInt? dims = some d) (hd0 : 0 < d)
    (hop : opCheck P x o (.rope d.toNat tr base scale off) ins = true) :
    MSim (MPost P M ν S C) S C
      (Host.Mlx.Ffi.call x name [o, a, .num (.lit dims), .bool tr, base, .num scale, .num off, freqs, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, .num (.lit dims), .bool tr, M.arg base, .num (M.nv scale),
        .num (M.nv off), M.arg freqs, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, hd, hr.natOk_argNat hf]
  cases hfr : Host.Mlx.Ffi.argNat freqs with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some fq =>
    cases fq with
    | succ _ => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | zero =>
      simp only [show decide (0 < d) = true from decide_eq_true hd0, Bool.cond_true]
      exact sim_opOut hs hr hop ⟨hb, hsc, hof⟩

theorem sim_sdpa (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.sdpa)
    {o q k v mask mk sk e1 e2 : Arg} {scale : NumV} {ins : List Nat} {m : List Char}
    (hq : hdOk x q = true) (hk : hdOk x k = true) (hv : hdOk x v = true) (hmk : natOk P mk = true)
    (hsk : natOk P sk = true) (hsc : SN (· < S.tab.length) scale)
    (h1 : Host.Mlx.Ffi.arrIns x [q, k, v] = some ins) (hm : Host.Mlx.Ffi.cstrArg mask = some m)
    (h0 : Host.Mlx.Ffi.argNat mk = some 0) (h0' : Host.Mlx.Ffi.argNat sk = some 0)
    (hop : opCheck P x o (.sdpa scale m) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, q, k, v, .num scale, mask, mk, sk, e1, e2])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg q, M.arg k, M.arg v, .num (M.nv scale), M.arg mask, M.arg mk,
        M.arg sk, M.arg e1, M.arg e2]) := by
  have t1 := hr.arrIns_some (as := [q, k, v]) (by simp [hq, hk, hv]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, cstrArg_map, hm, hr.natOk_argNat hmk, hr.natOk_argNat hsk, h0, h0']
  exact sim_opOut hs hr hop hsc

theorem sim_qmm (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.qmm)
    {o a w sc bi g b mode e : Arg} {tr : Bool} {ins : List Nat} {gv bv : Option Nat} {m : List Char}
    (ha : hdOk x a = true) (hw : hdOk x w = true) (hsc : hdOk x sc = true) (hbi : hdOk x bi = true)
    (hg : natOk P g = true) (hb : natOk P b = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a, w, sc, bi] = some ins) (eg : Host.Mlx.Ffi.optIntArg g = some gv)
    (eb : Host.Mlx.Ffi.optIntArg b = some bv) (hm : Host.Mlx.Ffi.cstrArg mode = some m)
    (hop : opCheck P x o (.qmm tr (gv.getD 64) (bv.getD 4) m) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, w, sc, bi, .bool tr, g, b, mode, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg w, M.arg sc, M.arg bi, .bool tr, M.arg g, M.arg b,
        M.arg mode, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a, w, sc, bi]) (by simp [ha, hw, hsc, hbi]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, hr.optInt_eq hg, hr.optInt_eq hb, eg, eb, cstrArg_map, hm]
  exact sim_opOut hs hr hop trivial

theorem sim_dequantize (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.dequantize)
    {o w sc bi g b mode gs dt e : Arg} {ins : List Nat} {gv bv : Option Nat} {dv : Option Nat} {m : List Char}
    (hw : hdOk x w = true) (hsc : hdOk x sc = true) (hbi : hdOk x bi = true)
    (hg : natOk P g = true) (hb : natOk P b = true) (hgs : natOk P gs = true) (hdt : natOk P dt = true)
    (h1 : Host.Mlx.Ffi.arrIns x [w, sc, bi] = some ins) (eg : Host.Mlx.Ffi.optIntArg g = some gv)
    (eb : Host.Mlx.Ffi.optIntArg b = some bv) (hm : Host.Mlx.Ffi.cstrArg mode = some m)
    (egs : Host.Mlx.Ffi.argNat gs = some 0) (edt : Host.Mlx.Ffi.optIntArg dt = some dv)
    (hop : opCheck P x o (.dequantize (gv.getD 64) (bv.getD 4) m dv) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, w, sc, bi, g, b, mode, gs, dt, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg w, M.arg sc, M.arg bi, M.arg g, M.arg b, M.arg mode, M.arg gs,
        M.arg dt, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [w, sc, bi]) (by simp [hw, hsc, hbi]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, hr.optInt_eq hg, hr.optInt_eq hb, eg, eb, cstrArg_map, hm, hr.natOk_argNat hgs, egs,
    hr.optInt_eq hdt, edt]
  exact sim_opOut hs hr hop trivial

theorem sim_take (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.take)
    {o a i ax e : Arg} {ins : List Nat} {av : Int} {nd : Node} {b : Nat}
    (ha : nodeOk x a = true) (hi : hdOk x i = true) (hax : natOk P ax = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a, i] = some ins) (eax : Host.Mlx.Ffi.argInt ax = some av)
    (hn : (Host.Mlx.Ffi.argNat a).bind x.node? = some nd) (hb : Host.Mlx.Ffi.axisOf av (len nd.shape) = some b)
    (hop : opCheck P x o (.take b) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, i, ax, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg i, M.arg ax, M.arg e]) := by
  have ha' : hdOk x a = true := by simp only [nodeOk, Bool.and_eq_true] at ha; exact ha.1
  have t1 := hr.arrIns_some (as := [a, i]) (by simp [ha', hi]) h1
  obtain ⟨k, j, nd0, nd', rfl, hm, hp, e1, e2, e3⟩ := hr.nodeArg ha
  rw [argNat_nat, Option.bind_some, e1] at hn
  cases hn
  simp only [List.map_cons, List.map_nil] at t1
  rw [hm] at t1 ⊢
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [h1, t1, hr.argInt_eq hax, eax, argNat_nat, Option.bind_some, e1, e2, e3.1, Map.dims,
    Native.len_map, hb]
  exact sim_opOut hs hr hop trivial

theorem sim_conv1d (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.conv1d)
    {o a w st pd dl gr e : Arg} {ins : List Nat} (ha : hdOk x a = true) (hw : hdOk x w = true)
    (k1 : natOk P st = true) (k2 : natOk P pd = true) (k3 : natOk P dl = true) (k4 : natOk P gr = true)
    {v1 v2 v3 v4 : Nat} (e1 : Host.Mlx.Ffi.argNat st = some v1) (e2 : Host.Mlx.Ffi.argNat pd = some v2)
    (e3 : Host.Mlx.Ffi.argNat dl = some v3) (e4 : Host.Mlx.Ffi.argNat gr = some v4)
    (h1 : Host.Mlx.Ffi.arrIns x [a, w] = some ins) (hop : opCheck P x o (.conv1d v1 v2 v3 v4) ins = true) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, w, st, pd, dl, gr, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg w, M.arg st, M.arg pd, M.arg dl, M.arg gr, M.arg e]) := by
  have t1 := hr.arrIns_some (as := [a, w]) (by simp [ha, hw]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, hr.natOk_argNat k1, hr.natOk_argNat k2, hr.natOk_argNat k3, hr.natOk_argNat k4, e1, e2, e3, e4]
  exact sim_opOut hs hr hop trivial
end

end Host.Ts.Sim
