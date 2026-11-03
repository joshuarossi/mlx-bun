import host.sim.compose.a4b.fd_x4_L9.DispatchCompact
import host.sim.compose.a4b.fd_x4_L9.DispatchGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def forwardCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (i : Cls.Inst) : ICut FF :=
  typedCut NB T tk π cap H N PRE_fd_x4_L9_r0.s24 PRE_fd_x4_L9_r0.S24 i 18

kernel_rfl cnt24 : countersOkB PRE_fd_x4_L9_r0.s23 PRE_fd_x4_L9_r0.s24 = true

private theorem bridge5 : bridgeOf PRE_fd_x4_L9_r0.s24.ffi = bridgeOf PRE_fd_x4_L9_r0.s23.ffi :=
  typedRun23.dst_bridge.trans typedRun23.src_bridge.symm

theorem g2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap H N : Nat) (i : Cls.Inst) {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y)
    (horacle : ∀ ν, MapOk ν i fdMap → Good ν PRE_fd_x4_L9_r0.S23.oracle) :
    CutStep (withMem Mem (g2Cut NB T tk π cap H N i)) (withMem Mem (forwardCut NB T tk π cap H N i)) 7 := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap, hlo⟩, ⟨hfresh, hids, hnat⟩, hm⟩
  have hgood := horacle x.ν hmap
  obtain ⟨M', t', C', hrun, hext, hm'⟩ := D1Advance.run
    (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hb.context hb.valuation hgood
    (congrFun (congrFun typedAccepted23 _) _) (congrFun (congrFun typedRun23 _) _) top24 hr
  have ng := glue_ngrow (typedGrowSimAt NB T tk (tokenBytes (lastRows π)) (lastRows π).length 131072 [])
    (congrFun (congrFun typedAccepted23 _) _) (congrFun (congrFun typedRun23 _) _) hb.valuation hb.context (hr.withOracle hgood) hrun
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
  have hi4 : (bridgeOf PRE_fd_x4_L9_r0.s23.ffi).active = false := PRE_fd_x4_L9_r0.zbin1
  have hi5 : (bridgeOf PRE_fd_x4_L9_r0.s24.ffi).active = false := by rw [bridge5]; exact hi4
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi5).bridge.1.trans (bridge5.trans (r0.toR hi4).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  exact ⟨t', C', hrun, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', book, ip, inputs, hmap, hlo⟩, ⟨fresh, ids,
    hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hm' hext.big hext.node cnt24⟩,
    hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens cnt24), congrFun hext.a 12504⟩ hm⟩

end Host.Ts.Sim.Compose.FDX4L9
