import host.sim.compose.a4b.D1Forward
import host.sim.compose.a4b.SetupD1Body
import host.sim.compose.a4b.SetupD1Reserved
import host.sim.lin.checks.Kv
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable def returnedSavedCut (NB T : Nat) (tk : Nat → Nat) : ICut FF where
  s0 := D1Body.s155
  tab0 := D1Body.S155.tab
  R := fun x s S => ∃ π K0,
    RelB FF (Disp.FRJ (FullRXD { Host.Route.setupP with rest := Host.Route.machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K s S x.t x.C ∧
    SetupD1.BodyBook π K0 x ∧ SetupD1Input.InputAt π (x.M.node 15235) x.t x.C ∧
    SetupD1Values.Reserved T tk x.ν ∧ x.M.a 2590 = 2590
  B := fun x => Host.Route.AneFresh x.t ∧ fixedCells x

theorem saved_forward_returned (NB T : Nat) (tk : Nat → Nat) :
    CutStep (SetupD1SavedCells.forwardSavedInputCut NB T tk) (returnedSavedCut NB T tk) 1541184 := by
  rintro t C ⟨x, rfl, rfl, ⟨π, K0, hr, hb, hi, hv, hem⟩, hf, hc⟩
  obtain ⟨x', h⟩ := SetupD1.run_full hr hb hf hc
  have ip : SetupD1Input.InputAt π (x'.M.node 15235) x'.t x'.C := by
    rw [h.inputNode]
    exact hi.grow h.nativeGrow h.server
  have reserved : SetupD1Values.Reserved T tk x'.ν :=
    SetupD1Reserved.body_reserved hr.srv.num h.relation.srv.num h.ext h.server hv
  have emitted : x'.M.a 2590 = 2590 := (congrFun h.ext.a 2590).trans hem
  exact ⟨x'.t, x'.C, h.run, x', rfl, rfl,
    ⟨π, K0, h.relation, h.book, ip, reserved, emitted⟩, h.fresh, h.anchors⟩

noncomputable def fwd_D1_cold_DFirst__g2_fin_first__g3f_first (NB T : Nat) (tk : Nat → Nat) :
    FwdPiece FF [final_cold.r0] [⟨[(0, .o), (1, .cap), (2, .n)], Stage.Cache.KvDFirst.O⟩]
      (fun _ => forwardCut NB T tk) (fun _ => returnedSavedCut NB T tk) where
  m := [(9, .L)]
  np := 0
  nb := 1541184
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ := FwdCall.warm (toForwardSaved NB T tk) (saved_forward_returned NB T tk) (CutConv.refl _)

end Host.Ts.Sim.Compose.D1First
