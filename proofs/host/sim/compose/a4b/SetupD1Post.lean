import host.sim.template.a4pre_d1_post.FreshAccept
import host.sim.template.a4pre_d1_post.Oracles
import host.sim.template.a4pre_d1_post.SizeBridge
import host.sim.template.a4pre_d1_post_small.Simulation
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Route
open Host.Load.Run.Tpl

abbrev Native (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :=
  Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
    (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))

structure Book (bytes : List Byte) (ν : Nat → F64) (K0 : Host.Ts.Sim.Ctx)
    (x : SegInst FF) : Prop where
  valuation : x.ν = ν
  context : Disp.KpJ (D1PostSmall.J bytes) 4096 x.K
  frames : x.K.fr = K0.fr
  offset : x.K.D = K0.D
  lo : x.K.lo = K0.lo
  hi : x.K.hi = K0.hi

def Anchors (x : SegInst FF) : Prop := x.M.a 2586 = 2586 ∧ x.M.a 2589 = 2589

noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte)
    (ν : Nat → F64) (K0 : Host.Ts.Sim.Ctx) (M0 : Map) (y0 : Host.Mlx.Ffi.St)
    (s : St FF.S) (S : SSrv) : ICut FF :=
  (Cut.mk s S.tab (Conv.relB FF (Native NB T tk y0) (D1Frames.typedW bytes) []
    (Book bytes ν K0))).with (fun x => AneFresh x.t ∧ Anchors x ∧ Ext M0 x.M 20)

private theorem Book.rebase {bytes : List Byte} {ν : Nat → F64} {K0 K K' : Host.Ts.Sim.Ctx}
    {M M' : Map} {u : Nat → F64} {t t' : St FF.S} {C C' : CSrv}
    (h : Book bytes ν K0 ⟨M, u, K, t, C⟩)
    (hf : K'.fr = K.fr) (hD : K'.D = K.D) (hl : K'.lo = K.lo) (hh : K'.hi = K.hi) :
    Book bytes ν K0 ⟨M', u, K', t', C'⟩ := by
  refine ⟨h.valuation, ?_, hf.trans h.frames, hD.trans h.offset,
    hl.trans h.lo, hh.trans h.hi⟩
  change Disp.Kp (D1PostSmall.J bytes) K' ∧ K'.D ≤ 4096
  simpa only [Disp.KpJ, Disp.Kp, hf, hD, hl, hh] using h.context

private theorem anchors_ext {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : Anchors ⟨M, ν, K, t, C⟩) (he : Ext M M' n) :
    Anchors ⟨M', ν, K', t', C'⟩ := by
  constructor
  · change M'.a 2586 = 2586
    rw [he.a]; exact h.1
  · change M'.a 2589 = 2589
    rw [he.a]; exact h.2

private theorem fresh {NB T : Nat} {tk : Nat → Nat} {y0 : Host.Mlx.Ffi.St}
    {W : Nat → Option WFrame} {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (Native NB T tk y0) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Native NB T tk y0) W [] M' ν K' sb Sb t' C')
    (hi : (bridgeOf sa.ffi).active = false) (he : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hf : AneFresh t) : AneFresh t' := by
  obtain ⟨_, _, r0⟩ := hr.ffi.1.1
  obtain ⟨_, _, r1⟩ := hr'.ffi.1.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) he).trans hi
  have hb : bridgeOf t'.ffi = bridgeOf t.ffi :=
    (r1.toR hi').bridge.1.trans (he.trans (r0.toR hi).bridge.1.symm)
  intro Cx Pc Kc weights kind NE IP G init
  rw [hb]
  exact hf Cx Pc Kc weights kind NE IP G init

kernel_rfl oracle_sizeSuffix : D1Post.S2.oracle =
  D1Post.O.drop (D1Post.O.length - D1Post.S2.oracle.length)

theorem beforeSize {NB T : Nat} {tk : Nat → Nat} {bytes : List Byte}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hg : Good ν D1Post.O) :
    CutStep (cut NB T tk bytes ν K0 M0 y0 D1Post.s0 D1Post.S0)
      (cut NB T tk bytes ν K0 M0 y0 D1Post.s2 D1Post.S2) 1205 := by
  apply cut_glueCall (D1PostSmall.simulation_ngrow NB T tk bytes y0)
    (congrFun D1Post.acceptedStart bytes) (D1PostSmall.runSeg0 bytes)
    (congrFun D1Post.acceptedBeforeSize bytes) D1Post.liveBeforeSize D1Post.size_step
    D1Post.size_noRetBlock
  · intro x hb _
    exact ⟨hb.context, hb.valuation.symm ▸ hν⟩
  · intro x hb _
    rw [hb.valuation]
    exact D1Post.good_initial hg
  · intro x M' t' C' hb hB hr he hrun hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), hb.rebase rfl rfl rfl rfl⟩,
      fresh hr hrel D1Post.initialInactive D1Post.firstBridge hB.1,
      anchors_ext hB.2.1 he, hB.2.2.trans (he.mono ?_) (Nat.le_refl _)⟩
    rw [D1Post.initialTable]
    decide

theorem size {NB T : Nat} {tk : Nat → Nat} {bytes : List Byte}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hg : Good ν D1Post.O) :
    CutStep (cut NB T tk bytes ν K0 M0 y0 D1Post.s2 D1Post.S2)
      (cut NB T tk bytes ν K0 M0 y0 D1Post.s3 D1Post.S3) 3 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hb⟩, hf, ha, he0⟩
  have hv : D1PostSmall.VP x.ν := hb.valuation.symm ▸ hν
  have hg2 : Good x.ν D1Post.S2.oracle := by
    rw [hb.valuation, oracle_sizeSuffix]
    exact fun q hq => hg q (List.mem_of_mem_drop hq)
  have hfr : x.K.fr 4277 = none := by
    by_contra hn
    have hm := (hb.context.1.2.2 4277).mp hn
    exact (by decide : 4277 ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view]) hm
  obtain ⟨M', t', C', ⟨gg, hrel, hev⟩, hrun⟩ :=
    D1Post.size_run y0 (hr.withOracle hg2) hv.1 hfr
  let K' : Host.Ts.Sim.Ctx :=
    ⟨x.K.fr, D1Post.s3.trace, t'.trace, x.K.D, x.K.lo, x.K.hi⟩
  have h20 : 20 ≤ D1Post.S2.tab.length := by decide
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨hrel.withOracle (fun _ h => nomatch h), hb.rebase rfl rfl rfl rfl⟩,
    fresh hr hrel D1Post.size_inactive D1Post.size_bridge hf,
    anchors_ext ha gg.ext, he0.trans (gg.ext.mono h20) (Nat.le_refl _)⟩

theorem afterSize {NB T : Nat} {tk : Nat → Nat} {bytes : List Byte}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hg : Good ν D1Post.O) :
    CutStep (cut NB T tk bytes ν K0 M0 y0 D1Post.s3 D1Post.S3)
      (cut NB T tk bytes ν K0 M0 y0 D1Post.s4 D1Post.S4) 9962 := by
  apply cut_glue (D1PostSmall.simulation_ngrow NB T tk bytes y0)
    (congrFun D1Post.acceptedAfterSize bytes) (D1PostSplit.run bytes)
    D1Post.callAtEnd
  · intro x hb _
    exact ⟨hb.context, hb.valuation.symm ▸ hν⟩
  · intro x hb _
    rw [hb.valuation]
    exact D1Post.good_finalSuffix hg
  · intro x M' t' C' hb hB hr he hrun hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), hb.rebase rfl rfl rfl rfl⟩,
      fresh hr hrel D1Post.finalInactive D1Post.finalBridge hB.1,
      anchors_ext hB.2.1 he, hB.2.2.trans (he.mono ?_) (Nat.le_refl _)⟩
    have := D1Post.afterSizeTableBound
    omega

theorem run {NB T : Nat} {tk : Nat → Nat} {bytes : List Byte}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    (hν : D1PostSmall.VP ν) (hT : 2 ≤ T) (hTb : T ≤ 262144)
    (htok : tk 1 < 248320) (hne : tk 1 ≠ 248044)
    (h0 : ν 0 = F64.ofNat T) (h1 : ν 1 = F64.ofNat (tk 1)) :
    CutStep (cut NB T tk bytes ν K0 M0 y0 D1Post.s0 D1Post.S0)
      (cut NB T tk bytes ν K0 M0 y0 D1Post.s4 D1Post.S4) 11170 := by
  have hg := D1Post.good hT hTb htok hne h0 h1 hν.2
  exact ((beforeSize hν hg).trans ((size hν hg).trans (afterSize hν hg))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.SetupD1Post
