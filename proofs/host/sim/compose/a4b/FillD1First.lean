import host.sim.compose.a4b.D1G3f
namespace Host.Ts.Sim.Compose.FillD1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def pc0 := SetupCommon.nextCut
noncomputable def b_g1_FIN_first_i := D1First.g1Cut
noncomputable def b_g1_FIN_first_o := D1First.dispatchCut
noncomputable def b_g2_fin_first_i := D1First.g2Cut
noncomputable def b_g2_fin_first_o := D1First.forwardCut
noncomputable def b_g3f_first_i (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop) : ICut FF :=
  withMem (Mem 1) (D1First.returnedPromptCut NB T tk π)

noncomputable def nps_FIN_first__start__g1_FIN_first := D1First.nps_FIN_first__start__g1_FIN_first
noncomputable def g1_FIN_first := D1First.g1_FIN_first
noncomputable def disp_D1__g1_FIN_first__g2_fin_first := D1First.disp_D1__g1_FIN_first__g2_fin_first
noncomputable def g2_fin_first := D1First.g2_fin_first
noncomputable def fwd_D1_cold_DFirst__g2_fin_first__g3f_first := D1First.fwd_D1_cold_DFirst__g2_fin_first__g3f_first
noncomputable def g3f_first := D1First.g3f_first
end Host.Ts.Sim.Compose.FillD1First
