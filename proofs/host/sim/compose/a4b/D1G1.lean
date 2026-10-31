import host.sim.compose.a4b.D1G1Input
import host.sim.compose.a4b.D1Nps
import host.sim.compose.a4b.SetupD1Dispatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def typedCut (NB T : Nat) (tk : Nat → Nat) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ π K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K s S x.t x.C ∧
    SetupD1.ForwardBook π K0 x ∧ SetupD1Input.InputAt π (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν (setupI 1) D1StageSplit.map_g1_FIN_first
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 s x.t

noncomputable abbrev dispatchCut (NB T : Nat) (tk : Nat → Nat) :=
  typedCut NB T tk D1StageSplit.s20 D1StageSplit.S20

kernel_rfl cnt20 : countersOkB D1StageSplit.s1 D1StageSplit.s20 = true

private theorem bridge15 : bridgeOf D1StageSplit.s15.ffi = bridgeOf D1StageSplit.s1.ffi :=
  D1StageSplit.stepA6.dst_bridge.trans D1StageSplit.k1.src_bridge.symm
private theorem bridge20 : bridgeOf D1StageSplit.s20.ffi = bridgeOf D1StageSplit.s1.ffi :=
  typedRun19.dst_bridge.trans D1StageSplit.k1.src_bridge.symm

theorem g1 (NB T : Nat) (tk : Nat → Nat)
    (horacle : ∀ ν, MapOk ν (setupI 1) D1StageSplit.map_g1_FIN_first → Good ν g1Oracle) :
    CutStep (g1Cut NB T tk) (dispatchCut NB T tk) 261 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hq⟩, hb, hnat⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb.1.1
  have hi1 : (bridgeOf D1StageSplit.s1.ffi).active = false := by rw [bridge1]; exact inactive0
  have hi15 : (bridgeOf D1StageSplit.s15.ffi).active = false := by rw [bridge15]; exact hi1
  have hi20 : (bridgeOf D1StageSplit.s20.ffi).active = false := by rw [bridge20]; exact hi1
  have hv : x.ν 9 = F64.ofNat 1 := hq.2.2.1
  obtain ⟨M', t', C', K', hrun, hext, hrel, hkp, hfr, hD, hlo, hhi, hev, hinput⟩ :=
    g1Run_input hr hk hq.1 (G1Good.ofGood (horacle x.ν hq.2.2)) hframe hlen hv hi15 hvocab
  have hbook : SetupD1.ForwardBook π x.K ⟨M', x.ν, K', t', C'⟩ :=
    ⟨hlen, hvocab, hq.1, hv, hkp, hk, hframe, hmemo, hfr, hD.trans hd, hlo, hhi, hev⟩
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hrel.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi20).bridge.1.trans (bridge20.trans (r0.toR hi1).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have hids : fixedCells (⟨M', x.ν, K', t', C'⟩ : SegInst FF) := by
    change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
    rw [hext.a]
    exact hb.1.2
  have hinputs : setupInputs T tk (⟨M', x.ν, K', t', C'⟩ : SegInst FF) := by
    exact ⟨hb.2.1, by change M'.a 2590 = 2590; rw [hext.a]; exact hb.2.2⟩
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨π, x.K, hrel, hbook, hinput, hinputs, hq.2.2⟩, fresh, hids,
    hnat.step rfl hr hrel hext.big hext.node cnt20⟩

noncomputable def g1_FIN_first (NB T : Nat) (tk : Nat → Nat) :
    GluePiece FF [final_cold.r0] (fun _ => g1Cut NB T tk) (fun _ => dispatchCut NB T tk) where
  m := D1StageSplit.map_g1_FIN_first
  n := 261
  O := g1Oracle
  chk r hr := by obtain rfl := List.mem_singleton.mp hr; exact g1Check
  ok r hr i hi ho := by
    obtain rfl := List.mem_singleton.mp hr
    have hL := finalRowL hi
    apply g1
    intro ν hm
    apply ho.1 ν
    simpa only [D1StageSplit.map_g1_FIN_first, MapOk, setupI, Cls.Inst.get, hL] using hm

end Host.Ts.Sim.Compose.D1Split
