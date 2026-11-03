import host.sim.compose.a4b.fd_x4_L7.TypedBook
import host.sim.template.a4pre_fd_x4_L7_r0.SiteR1
import host.sim.template.a4pre_fd_x4_L7_r0.SiteZ1
import host.sim.compose.a4b.fd_x4_L7.DispatchGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable abbrev mergedDispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (i : Cls.Inst) : ICut FF :=
  { typedCut NB T tk π cap H N PRE_fd_x4_L7_r0.s22 PRE_fd_x4_L7_r0.S22 i with
    B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt H N PRE_fd_x4_L7_r0.s22 x.t ∧
      Conv.CallFacts PRE_fd_x4_L7_r0.s21 PRE_fd_x4_L7_r0.S21.tab.length ∧
      NB ≤ PRE_fd_x4_L7_r0.P1.NL ∧ Conv.FullShiftQ PRE_fd_x4_L7_r0.P1 112
        PRE_fd_x4_L7_r0.kappa1 PRE_fd_x4_L7_r0.s23.ffi PRE_fd_x4_L7_r0.s22.ffi }

kernel_rfl bridge3938 : bridgeOf PRE_fd_x4_L7_r0.s22.ffi = bridgeOf PRE_fd_x4_L7_r0.s21.ffi
kernel_rfl nnext21 : (mlxOf PRE_fd_x4_L7_r0.s21.ffi).nnext = 19266
kernel_rfl cnt22 : countersOkB PRE_fd_x4_L7_r0.s21 PRE_fd_x4_L7_r0.s22 = true

theorem dispatch_merged (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (i : Cls.Inst) {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y)
    (horacle : ∀ ν, MapOk ν i fdMap → Good ν PRE_fd_x4_L7_r0.st1.S0.oracle) :
    CutStep (withMem Mem (dispatchCut NB T tk π cap H N i)) (withMem Mem (mergedDispatchCut NB T tk π cap H N i)) 155 := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap, -⟩, ⟨hfresh, hids, hnat⟩, hmem⟩
  let d := dispatchSite NB T tk (tokenBytes (lastRows π)) (lastRows π).length
  have h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDX4L7Frames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] x.M x.ν x.K PRE_fd_x4_L7_r0.s21 d.tpl.S0 x.t x.C := by
    have h := hr.withOracle (horacle x.ν hmap)
    change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDX4L7Frames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] x.M x.ν x.K PRE_fd_x4_L7_r0.s21
      ⟨PRE_fd_x4_L7_r0.S21.tab, PRE_fd_x4_L7_r0.st1.S0.oracle⟩ x.t x.C at h
    rw [← d.tab] at h
    exact h
  obtain ⟨M', t', C', hrun, hext, h2⟩ := Conv.site_merge d.tpl d.start rfl d.sim d.localOk
    hb.context hb.valuation d.foot d.nodup d.bound d.trace PRE_fd_x4_L7_r0.S21.tab.length h0
  rw [d.tab] at hext
  replace h2 := d.merged h2
  have hm := h2.resMerge hr.srv.num hext (runC_le _ _ _ _ _ hrun) (d.tab ▸ d.tpl.len2)
    d.len d.freshNodup d.fresh
  have hm' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (FDX4L7Frames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] M' x.ν x.K PRE_fd_x4_L7_r0.s22
      ⟨PRE_fd_x4_L7_r0.S22.tab, []⟩ t' C' := by
    rw [PRE_fd_x4_L7_r0.mergeTab1]
    exact hm
  have ng := d.ngrow (dispatchGrowSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length) hb.valuation hb.context h0 hrun
  have ip : InputAt (lastRows π) (M'.node 19265) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun)
  have book : ForwardBook i π K0 (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) cap := by
    refine ⟨hb.length, hb.vocab, hb.valuation, hb.promptValue, hb.rowValue, hb.offsetValue, hb.capValue, hb.context, hb.incoming,
      hb.incomingPrompt, hb.frames, hb.offset, hb.lo, hb.hi, ?_⟩
    change ∃ asR ret pre tr, x.K.base' = _
    rw [hext.a]
    exact hb.inputEvent
  have inputs : setupInputs T tk (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) :=
    ⟨hins.1, by change M'.a 2590 = 2590; rw [hext.a]; exact hins.2⟩
  have ids : fixedCells (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) := by
    change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
    rw [hext.a]
    exact hids
  have hsrc : bridgeOf PRE_fd_x4_L7_r0.s22.ffi = bridgeOf PRE_fd_x4_L7_r0.s21.ffi := bridge3938
  have hi4 : (bridgeOf PRE_fd_x4_L7_r0.s22.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) PRE_fd_x4_L7_r0.cbridge1).trans PRE_fd_x4_L7_r0.zbin1
  have hi3 : (bridgeOf PRE_fd_x4_L7_r0.s21.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) hsrc.symm).trans hi4
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi4).bridge.1.trans (hsrc.trans (r0.toR hi3).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise
      (mlxOf PRE_fd_x4_L7_r0.s21.ffi).nnext).NL ≤ PRE_fd_x4_L7_r0.P1.NL := by
    change (mlxOf PRE_fd_x4_L7_r0.s21.ffi).nnext ≤ 19266
    rw [nnext21]
  exact ⟨t', C', hrun, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', book, ip, inputs, hmap, Nat.zero_le _⟩, ⟨fresh, ids,
    hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hm' hext.big hext.node cnt22, ⟨hr.presentBound, hr.heapSupp⟩,
    Nat.le_trans top.1.load.mlx.nbl hNL, PRE_fd_x4_L7_r0.cshiftR1 top.1 hNL⟩,
    hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens cnt22), congrFun hext.a 12504⟩ hmem⟩

end Host.Ts.Sim.Compose.FDX4L7
