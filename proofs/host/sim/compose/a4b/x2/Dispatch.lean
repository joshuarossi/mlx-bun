import host.sim.compose.a4b.x2.G2
set_option Elab.async false
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl chkDispatch : (fwdClassRows.all fun r => goodLin r.ps (varsOf r.V npsMap) PRE_first_tail_x2_r0.st2.S0.oracle) = true

/-- **The class's dispatch.** -/
noncomputable def disp_V4__g1_DTtail_first__g2_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y)
    (hn : ∀ r ∈ fwdClassRows, ∀ i, InRow r i → i.n ≤ 2 ^ 20) :
    StagePiece FF fwdClassRows [] (fun i => withMem (Mem i.L) (VWFirst.dispatchCut NB T tk π i))
      (fun i => withMem (Mem i.L) (g2Cut NB T tk π i)) where
  m := npsMap
  n := 309
  O := PRE_first_tail_x2_r0.st2.S0.oracle
  chk r hr := List.all_eq_true.mp chkDispatch r hr
  ok r hr i hi ho := StageCall.intro (toDispatch (hMem i.L) (hn r hr i hi))
    (dispatch_merged NB T tk π i (hMem i.L) ho.1) (dispatch_compact (hMem i.L))

end Host.Ts.Sim.Compose.VWFirst.X2
