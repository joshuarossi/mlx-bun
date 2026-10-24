import host.sim.full.SymAccept
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf GraphOp)

/-! # The load world's native-call simulation with symbolic shapes

`mlx_simX`: a call the symbolic decider accepts simulates, by symbol, through the lemmas of
`host.sim.full.SymCalls`, `SymCalls2` and `SymGraph`. `loadFfiCallSimX`: the load world's
`FfiCallSim` for `okCallSX`, the general relation's (`loadFfiCallSim`) where `okCallSG` accepts. -/

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

omit hs hr in
theorem out_spec {o : Arg} (h : NativeOkX.out P x o = true) :
    slotOk P x o = true ∧ x.next + 1 ≤ P.E ∧ x.nnext + 1 ≤ P.NE := by
  simp only [NativeOkX.out, Bool.and_eq_true, decide_eq_true_eq] at h
  exact ⟨h.1.1, h.1.2, h.2⟩

omit hs hr in
theorem one_spec {ins : List Nat} (h : NativeOkX.one x ins = true) :
    ∃ s d, Host.Mlx.Ffi.shapesOf x ins = some [(s, d)] := by
  unfold NativeOkX.one at h
  split at h
  · rename_i p hp; exact ⟨p.1, p.2, hp⟩
  · cases h

omit hs hr in
theorem two_spec {ins : List Nat} (h : NativeOkX.two x ins = true) :
    ∃ s d s' d', Host.Mlx.Ffi.shapesOf x ins = some [(s, d), (s', d')] := by
  unfold NativeOkX.two at h
  split at h
  · rename_i p q hp; exact ⟨p.1, p.2, q.1, q.2, hp⟩
  · cases h

omit hs hr in
theorem lastLit_spec {s : List Dim} (h : NativeOkX.lastLit s = true) : ∃ l, nthD (.lit 0) s (len s - 1) = .lit l := by
  unfold NativeOkX.lastLit at h
  split at h
  · rename_i l hl; exact ⟨l, hl⟩
  · cases h

theorem mlx_simX (s : Host.Mlx.Ffi.Sym) (hsym : Host.Mlx.Ffi.symOf name = some s) (args : List Arg)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hok : NativeOkX.sym P x s args = true)
    (hsm : ∀ j ∈ symRefsX x s args, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  cases s
  case unary =>
    simp only [NativeOkX.sym, NativeOkX.unary] at hok
    split at hok
    · rename_i o a e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨ha, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins h1
        obtain ⟨s, d, hsh⟩ := one_spec hm
        exact sim_unaryX hs hr hsym ha ho hE hNE h1 hsh
      · cases hm
    · cases hok
  case astype =>
    simp only [NativeOkX.sym, NativeOkX.astype] at hok
    split at hok
    · rename_i o a dt e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hdt⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins h1
        obtain ⟨s, d, hsh⟩ := one_spec hm
        exact sim_astypeX hs hr hsym ha hdt ho hE hNE h1 hsh
      · cases hm
    · cases hok
  case contiguous =>
    simp only [NativeOkX.sym, NativeOkX.contiguous] at hok
    split at hok
    · rename_i o a e1 e2
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨ha, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins h1
        obtain ⟨s, d, hsh⟩ := one_spec hm
        exact sim_contiguousX hs hr hsym ha ho hE hNE h1 hsh
      · cases hm
    · cases hok
  case rope =>
    simp only [NativeOkX.sym, NativeOkX.rope] at hok
    split at hok
    · rename_i o a dims tr base scale off freqs e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨ha, hf⟩, hno⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins d h1 hd
        simp only [Bool.and_eq_true, decide_eq_true_eq] at hm
        obtain ⟨s, dd, hsh⟩ := one_spec hm.2
        exact sim_ropeX hs hr hsym ha hf (SA.of_supp (hsupp base (by simp)) hno)
          (SN.of_supp (A := fun _ => True) (hsupp (.num scale) (by simp)))
          (SN.of_supp (A := fun _ => True) (hsupp (.num off) (by simp))) ho hE hNE h1 hd hm.1 hsh
      · cases hm
    · cases hok
  case logsumexp =>
    simp only [NativeOkX.sym, NativeOkX.logsumexp] at hok
    split at hok
    · rename_i o a ax keep e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hax⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins av nd h1 eax hn
        simp only [Bool.and_eq_true] at hm
        obtain ⟨b, hb⟩ := Option.isSome_iff_exists.mp hm.1
        obtain ⟨s, d, hsh⟩ := one_spec hm.2
        exact sim_logsumexpX hs hr hsym ha hax ho hE hNE h1 eax hn hb hsh
      · cases hm
    · cases hok
  case transpose =>
    simp only [NativeOkX.sym, NativeOkX.transpose] at hok
    split at hok
    · rename_i o a ax m e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hd⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins ds h1 h2
        simp only [Bool.and_eq_true] at hm
        obtain ⟨axes, h3⟩ := Option.isSome_iff_exists.mp hm.1
        obtain ⟨s, d, hsh⟩ := one_spec hm.2
        exact sim_transposeX hs hr hsym ha hd ho hE hNE h1 h2 h3 hsh
      · cases hm
    · cases hok
  case take =>
    simp only [NativeOkX.sym, NativeOkX.take] at hok
    split at hok
    · rename_i o a i ax e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨ha, hi⟩, hax⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins av nd h1 eax hn
        simp only [Bool.and_eq_true] at hm
        obtain ⟨b, hb⟩ := Option.isSome_iff_exists.mp hm.1
        obtain ⟨s, d, s', d', hsh⟩ := two_spec hm.2
        exact sim_takeX hs hr hsym ha hi hax ho hE hNE h1 eax hn hb hsh
      · cases hm
    · cases hok
  case eval =>
    simp only [NativeOkX.sym, NativeOkX.eval] at hok
    split at hok
    · exact sim_evalX hs hr hsym hok
    · cases hok
  case binary =>
    simp only [NativeOkX.sym, NativeOkX.binary] at hok
    split at hok
    · rename_i o a b e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hb⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins h1
        split at hm
        · rename_i sa da sb db hsh
          simp only [Bool.and_eq_true] at hm
          refine sim_binaryX hs hr hsym ha hb ho hE hNE h1 hsh hm.1 hm.2 fun j hj => hsm j ?_
          simp only [symRefsX, h1]; exact hj
        · cases hm
      · cases hm
    · cases hok
  case rmsNorm =>
    simp only [NativeOkX.sym, NativeOkX.rms] at hok
    split at hok
    · rename_i o a w eps e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨ha, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      have heps := SN.of_supp (A := fun _ => True) (hsupp (.num eps) (by simp))
      split at hm
      · rename_i hw0
        simp only [Bool.and_eq_true] at hm
        obtain ⟨hw, hm⟩ := hm
        split at hm
        · rename_i ins h1
          obtain ⟨s, d, hsh⟩ := one_spec hm
          exact sim_rms1X hs hr hsym ha hw hw0 heps ho hE hNE h1 hsh
        · cases hm
      · simp only [Bool.and_eq_true] at hm
        obtain ⟨hw, hm⟩ := hm
        split at hm
        · rename_i ins h1
          split at hm
          · rename_i s d n dw hsh
            obtain ⟨l, hl⟩ := lastLit_spec hm
            exact sim_rms2X hs hr hsym ha hw heps ho hE hNE h1 hsh hl
          · cases hm
        · cases hm
    · cases hok
  case qmm =>
    simp only [NativeOkX.sym, NativeOkX.qmm] at hok
    split at hok
    · rename_i o a w sc bi tr g b mode e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨⟨⟨ha, hw⟩, hsc⟩, hbi⟩, hg⟩, hb⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins gv bv m h1 eg eb emode
        split at hm
        · rename_i xs dx ws dw scs dsc bis dbi hsh
          simp only [Bool.and_eq_true] at hm
          obtain ⟨⟨⟨hl, lw⟩, lsc⟩, lbi⟩ := hm
          obtain ⟨xl, hx⟩ := lastLit_spec hl
          exact sim_qmmX hs hr hsym ha hw hsc hbi hg hb ho hE hNE h1 eg eb emode hsh hx lw lsc lbi
        · cases hm
      · cases hm
    · cases hok
  case reshape =>
    simp only [NativeOkX.sym, NativeOkX.reshape] at hok
    split at hok
    · rename_i o a sh n e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hd⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins new h1 h2
        split at hm
        · rename_i old d hsh
          simp only [Bool.and_eq_true, decide_eq_true_eq] at hm
          obtain ⟨⟨⟨vn, vo⟩, pn⟩, po⟩ := hm
          refine sim_reshapeX hs hr hsym ha hd ho hE hNE h1 h2 hsh vn vo pn po fun j hj => hsm j ?_
          simp only [symRefsX, h1]; exact hj
        · cases hm
      · cases hm
    · cases hok
  case sliceDynamic =>
    simp only [NativeOkX.sym, NativeOkX.sliceDynamic] at hok
    split at hok
    · rename_i o a st ax n1 sz n2 e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨ha, hst⟩, k1⟩, k2⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins d1 sizes h1 e1 e2
        simp only [Bool.and_eq_true] at hm
        obtain ⟨⟨hnat, htwo⟩, vz⟩ := hm
        obtain ⟨axes, e1'⟩ := Option.isSome_iff_exists.mp hnat
        obtain ⟨s, d, s', d', hsh⟩ := two_spec htwo
        exact sim_sliceDynamicX hs hr hsym ha hst k1 k2 ho hE hNE h1 e1 e1' e2 hsh vz fun j hj => hsm j hj
      · cases hm
    · cases hok
  case zeros =>
    simp only [NativeOkX.sym, NativeOkX.zeros] at hok
    split at hok
    · rename_i o sh m dt e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨hout, hd⟩, hdt⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ds h2
        exact sim_zerosX hs hr hsym ho hd hdt hE hNE h2 hm fun j hj => hsm j hj
      · cases hm
    · cases hok
  case cfgOutput =>
    simp only [NativeOkX.sym, NativeOkX.cout] at hok
    split at hok
    · rename_i c sh m dt
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨hc, hd⟩, hdt⟩, hm⟩ := hok
      split at hm
      · rename_i ds h2
        exact sim_cfgOutputX hs hr hsym hc hd hdt h2 hm fun j hj => hsm j hj
      · cases hm
    · cases hok
  case graph op =>
    simp only [NativeOkX.sym, NativeOkX.graph] at hok
    split at hok
    · rename_i o a rest
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨ha, hall⟩, hax⟩, hout⟩, hm⟩ := hok
      obtain ⟨ho, hE, hNE⟩ := out_spec hout
      split at hm
      · rename_i ins av nd h1 eax hn
        obtain ⟨⟨r, dt⟩, hg⟩ := Option.isSome_iff_exists.mp hm
        exact sim_graphX hs hr hsym ha (fun b hb => List.all_eq_true.mp hall b hb) hax ho hE hNE h1 eax hn hg
      · cases hm
    · cases hok
  all_goals (simp only [NativeOkX.sym] at hok; cases hok)

end

theorem smallRefsX_sym {x : NSt} {name : Name} {args : List Arg} {s : Host.Mlx.Ffi.Sym}
    (h : Host.Mlx.Ffi.symOf name = some s) : smallRefsX x name args = symRefsX x s args := by
  unfold smallRefsX; rw [h]

/-- **The load world's native-call simulation with the forward's operations over symbolic shapes.** -/
theorem loadFfiCallSimX (P : LoadP) (NB : Nat) : FfiCallSim Host.Load.ffi (LoadR P NB) (okCallSX P) smallX where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    simp only [okCallSX, Bool.or_eq_true] at hok
    rcases hok with hok | hok
    · exact (loadFfiCallSim P NB).call M ν S C x y name args hsrv hr hok hsupp hsm.1
    · simp only [Bool.and_eq_true] at hok
      obtain ⟨hm, hok⟩ := hok
      cases hsym : Host.Mlx.Ffi.symOf name with
      | none => simp only [hsym] at hok; cases hok
      | some s =>
        simp only [hsym] at hok
        have h2 : ∀ j ∈ smallRefsX x.mlx name args, RefSmall ν S j := hsm.2
        rw [smallRefsX_sym hsym] at h2
        exact mlx_lift hr hm (mlx_simX hsrv hr.mlx s hsym args hsupp hok h2)

theorem okCallSX_rest (P : LoadP) (r : List NumV) : okCallSX { P with rest := r } = okCallSX P := by
  funext x name args
  unfold okCallSX
  simp only [okCallSG_rest]
  cases Host.Mlx.Ffi.symOf name with
  | none => rfl
  | some s => cases s <;> rfl

end Host.Ts.Sim.G
