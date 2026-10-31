import host.sim.compose.a4b.VWTypedBook
import host.sim.template.a4pre_first_tail_x15_r0.SiteR2
import host.sim.template.a4pre_first_tail_x15_r0.SiteZ2
import host.sim.compose.a4b.VWDispatchGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable abbrev mergedDispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) : ICut FF :=
  { typedCut NB T tk π PRE_first_tail_x15_r0.s39 PRE_first_tail_x15_r0.S39 i with
    B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 PRE_first_tail_x15_r0.s39 x.t ∧
      Conv.CallFacts PRE_first_tail_x15_r0.s38 PRE_first_tail_x15_r0.S38.tab.length ∧
      NB ≤ PRE_first_tail_x15_r0.P2.NL ∧ Conv.FullShiftQ PRE_first_tail_x15_r0.P2 18
        PRE_first_tail_x15_r0.kappa2 PRE_first_tail_x15_r0.s40.ffi PRE_first_tail_x15_r0.s39.ffi }

kernel_rfl cnt39 : countersOkB PRE_first_tail_x15_r0.s38 PRE_first_tail_x15_r0.s39 = true

theorem dispatch_merged (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst)
    (horacle : ∀ ν, MapOk ν i npsMap → Good ν PRE_first_tail_x15_r0.st2.S0.oracle) :
    CutStep (dispatchCut NB T tk π i) (mergedDispatchCut NB T tk π i) 425 := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap⟩, hfresh, hids, hnat⟩
  let d := dispatchSite NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length
  have h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K PRE_first_tail_x15_r0.s38 d.tpl.S0 x.t x.C := by
    have h := hr.withOracle (horacle x.ν hmap)
    change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K PRE_first_tail_x15_r0.s38
      ⟨PRE_first_tail_x15_r0.S38.tab, PRE_first_tail_x15_r0.st2.S0.oracle⟩ x.t x.C at h
    rw [← d.tab] at h
    exact h
  obtain ⟨M', t', C', hrun, hext, h2⟩ := Conv.site_merge d.tpl d.start rfl d.sim d.localOk
    hb.context hb.valuation d.foot d.nodup d.bound d.trace PRE_first_tail_x15_r0.S38.tab.length h0
  rw [d.tab] at hext
  replace h2 := d.merged h2
  have hm := h2.resMerge hr.srv.num hext (runC_le _ _ _ _ _ hrun) (d.tab ▸ d.tpl.len2)
    d.len d.freshNodup d.fresh
  have hm' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] M' x.ν x.K PRE_first_tail_x15_r0.s39
      ⟨PRE_first_tail_x15_r0.S39.tab, []⟩ t' C' := by
    rw [PRE_first_tail_x15_r0.mergeTab2]
    exact hm
  have ng := d.ngrow (dispatchGrowSim NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length) hb.valuation hb.context h0 hrun
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun)
  have book : ForwardBook i π K0 (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) := by
    refine ⟨hb.length, hb.vocab, hb.valuation, hb.rows, hb.context, hb.incoming,
      hb.incomingPrompt, hb.incomingMemo, hb.frames, hb.offset, hb.lo, hb.hi, ?_⟩
    change ∃ asR ret pre tr, x.K.base' = _
    rw [hext.a]
    exact hb.inputEvent
  have inputs : setupInputs T tk (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) :=
    ⟨hins.1, by change M'.a 2590 = 2590; rw [hext.a]; exact hins.2⟩
  have ids : fixedCells (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) := by
    change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
    rw [hext.a]
    exact hids
  have hsrc : bridgeOf PRE_first_tail_x15_r0.s39.ffi = bridgeOf PRE_first_tail_x15_r0.s38.ffi :=
    PRE_first_tail_x15_r0.cbridge2.trans (typedRun40.src_bridge.trans typedRun37.dst_bridge.symm)
  have hi21 : (bridgeOf PRE_first_tail_x15_r0.s39.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) PRE_first_tail_x15_r0.cbridge2).trans PRE_first_tail_x15_r0.zbin2
  have hi20 : (bridgeOf PRE_first_tail_x15_r0.s38.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) hsrc.symm).trans hi21
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi21).bridge.1.trans (hsrc.trans (r0.toR hi20).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise
      (mlxOf PRE_first_tail_x15_r0.s38.ffi).nnext).NL ≤ PRE_first_tail_x15_r0.P2.NL := by
    change (mlxOf PRE_first_tail_x15_r0.s38.ffi).nnext ≤ 15236
    rw [← PRE_first_tail_x15_r0.fcnn2]
  exact ⟨t', C', hrun, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', book, ip, inputs, hmap⟩, fresh, ids,
    hnat.step rfl hr hm' hext.big hext.node cnt39, ⟨hr.presentBound, hr.heapSupp⟩,
    top.1.load.mlx.nbl.trans hNL, PRE_first_tail_x15_r0.cshiftR2 top.1 hNL⟩

end Host.Ts.Sim.Compose.VWFirst
