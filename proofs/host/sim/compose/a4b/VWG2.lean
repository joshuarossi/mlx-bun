import host.sim.compose.a4b.VWDispatchCompact
import host.sim.compose.a4b.VWDispatchGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def forwardCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) : ICut FF :=
  typedCut NB T tk π PRE_first_tail_x15_r0.s41 PRE_first_tail_x15_r0.S41 i 3571

kernel_rfl cnt41 : countersOkB PRE_first_tail_x15_r0.s40 PRE_first_tail_x15_r0.s41 = true

private theorem bridge22 : bridgeOf PRE_first_tail_x15_r0.s41.ffi = bridgeOf PRE_first_tail_x15_r0.s40.ffi :=
  typedRun40.dst_bridge.trans typedRun40.src_bridge.symm

theorem g2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y)
    (horacle : ∀ ν, MapOk ν i npsMap → Good ν PRE_first_tail_x15_r0.S40.oracle) :
    CutStep (withMem Mem (g2Cut NB T tk π i)) (withMem Mem (forwardCut NB T tk π i)) 7 := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap⟩, ⟨hfresh, hids, hnat⟩, hm⟩
  have hgood := horacle x.ν hmap
  obtain ⟨M', t', C', hrun, hext, hm'⟩ := D1Advance.run
    (typedSim NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length []) hb.context hb.valuation hgood
    (congrFun (congrFun typedAccepted40 _) _) (congrFun (congrFun typedRun40 _) _) top41 hr
  have ng := glue_ngrow (typedGrowSimAt NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length 4096 [])
    (congrFun (congrFun typedAccepted40 _) _) (congrFun (congrFun typedRun40 _) _) hb.valuation hb.context (hr.withOracle hgood) hrun
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun)
  have book : ForwardBook i π K0 (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) 3571 := by
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
  have hi21 : (bridgeOf PRE_first_tail_x15_r0.s40.ffi).active = false := PRE_first_tail_x15_r0.zbin2
  have hi22 : (bridgeOf PRE_first_tail_x15_r0.s41.ffi).active = false := by rw [bridge22]; exact hi21
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi22).bridge.1.trans (bridge22.trans (r0.toR hi21).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  exact ⟨t', C', hrun, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', book, ip, inputs, hmap⟩, ⟨fresh, ids,
    hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hm' hext.big hext.node cnt41⟩,
    hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens cnt41), congrFun hext.a 12504⟩ hm⟩

kernel_rfl g2Check : (firstTailRows.all fun r => goodLin r.ps
  (varsOf r.V npsMap) PRE_first_tail_x15_r0.S40.oracle) = true

noncomputable def g2_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF firstTailRows (fun i => withMem (Mem i.L) (g2Cut NB T tk π i))
      (fun i => withMem (Mem i.L) (forwardCut NB T tk π i)) where
  m := npsMap
  n := 7
  O := PRE_first_tail_x15_r0.S40.oracle
  chk r hr := List.all_eq_true.mp g2Check r hr
  ok _ _ i _ ho := g2 NB T tk π i (hMem i.L) ho.1

end Host.Ts.Sim.Compose.VWFirst
