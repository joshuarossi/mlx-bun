import host.sim.compose.a4b.x4_L9.G2
set_option Elab.async false
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl chkDispatch : (fwdClassRows.all fun r => goodLin r.ps (varsOf r.V npsMap) PRE_first_tail_x4_L9_r0.st2.S0.oracle) = true

/-- **The class's dispatch.** -/
noncomputable def disp (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF fwdClassRows [] (fun i => withMem (Mem i.L) (dispatchCut NB T tk π i))
      (fun i => withMem (Mem i.L) (g2Cut NB T tk π i)) where
  m := npsMap
  n := 367
  O := PRE_first_tail_x4_L9_r0.st2.S0.oracle
  chk r hr := List.all_eq_true.mp chkDispatch r hr
  ok _ _ i _ ho := StageCall.intro (CutConv.refl _)
    (dispatch_merged NB T tk π i (hMem i.L) ho.1) (dispatch_compact (hMem i.L))

end Host.Ts.Sim.Compose.VWFirst.X4_L9
