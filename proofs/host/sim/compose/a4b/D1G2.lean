import host.sim.compose.a4b.D1Dispatch
import host.sim.template.a4pre_d1_input.Growth
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable abbrev forwardCut (NB T : Nat) (tk : Nat → Nat) :=
  typedCut NB T tk D1StageSplit.s22 D1StageSplit.S22

kernel_rfl cnt22 : countersOkB D1StageSplit.s21 D1StageSplit.s22 = true

private theorem bridge22 : bridgeOf D1StageSplit.s22.ffi = bridgeOf D1StageSplit.s21.ffi :=
  typedRun21.dst_bridge.trans typedRun21.src_bridge.symm

theorem g2 (NB T : Nat) (tk : Nat → Nat)
    (horacle : ∀ ν, MapOk ν (setupI 1) D1StageSplit.map_g1_FIN_first → Good ν D1StageSplit.S21.oracle) :
    CutStep (g2Cut NB T tk) (forwardCut NB T tk) 7 := by
  rintro t C ⟨x, rfl, rfl, ⟨π, K0, hr, hb, hip, hins, hmap⟩, hfresh, hids, hnat⟩
  have hgood := horacle x.ν hmap
  obtain ⟨M', t', C', hrun, hext, hm'⟩ := D1Advance.run
    (D1Sim.typed NB T tk (D1Typed.bytes π)) hb.context hb.valuation hgood
    (congrFun typedAccepted21 _) (congrFun typedRun21 _) top22 hr
  have ng := glue_ngrow (D1InputGrow.typed NB T tk (D1Typed.bytes π))
    (congrFun typedAccepted21 _) (congrFun typedRun21 _) hb.valuation hb.context (hr.withOracle hgood) hrun
  have ip : SetupD1Input.InputAt π (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun)
  have book : SetupD1.ForwardBook π K0 (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) := by
    refine ⟨hb.length, hb.vocab, hb.valuation, hb.singleton, hb.context, hb.incoming,
      hb.incomingPrompt, hb.incomingMemo, hb.frames, hb.offset, hb.lo, hb.hi, ?_⟩
    change ∃ asR ret tr, x.K.base' = _
    rw [hext.a]
    exact hb.inputEvent
  have inputs : setupInputs T tk (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) :=
    ⟨hins.1, by change M'.a 2590 = 2590; rw [hext.a]; exact hins.2⟩
  have ids : fixedCells (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) := by
    change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
    rw [hext.a]
    exact hids
  have hi21 : (bridgeOf D1StageSplit.s21.ffi).active = false := by
    have hbr := typedRun21.src_bridge.trans D1StageSplit.k1.src_bridge.symm
    rw [hbr, bridge1]
    exact inactive0
  have hi22 : (bridgeOf D1StageSplit.s22.ffi).active = false := by rw [bridge22]; exact hi21
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi22).bridge.1.trans (bridge22.trans (r0.toR hi21).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  exact ⟨t', C', hrun, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨π, K0, hm', book, ip, inputs, hmap⟩, fresh, ids,
    hnat.step rfl hr hm' hext.big hext.node cnt22⟩

noncomputable def g2_fin_first (NB T : Nat) (tk : Nat → Nat) :
    GluePiece FF [final_cold.r0] (fun _ => g2Cut NB T tk) (fun _ => forwardCut NB T tk) where
  m := D1StageSplit.map_g1_FIN_first
  n := 7
  O := D1StageSplit.S21.oracle
  chk r hr := by obtain rfl := List.mem_singleton.mp hr; exact typedOracle21
  ok r hr i hi ho := by
    obtain rfl := List.mem_singleton.mp hr
    have hL := finalRowL hi
    apply g2
    intro ν hm
    apply ho.1 ν
    simpa only [D1StageSplit.map_g1_FIN_first, MapOk, setupI, Cls.Inst.get, hL] using hm

end Host.Ts.Sim.Compose.D1Split
