import host.sim.compose.a4b.fd.DispatchCompact
set_option Elab.async false
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

def vwRows : List Row := [first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0,
  first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0,
  first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0,
  first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0]

noncomputable def disp_VW__g1_DTtail_first__g2_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF vwRows [] (fun i => withMem (Mem i.L) (dispatchCut NB T tk π i))
      (fun i => withMem (Mem i.L) (g2Cut NB T tk π i)) where
  m := npsMap
  n := 425
  O := PRE_fd_vw_r0.st1.S0.oracle
  chk r hr := List.all_eq_true.mp PRE_fd_vw_r0.chk_site1 r hr
  ok _ _ i _ ho := StageCall.intro (CutConv.refl _)
    (dispatch_merged NB T tk π i (hMem i.L) ho.1) (dispatch_compact (hMem i.L))

end Host.Ts.Sim.Compose.FDVW
