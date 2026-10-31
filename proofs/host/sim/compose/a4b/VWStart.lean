import host.sim.compose.a4b.SetupDrop
import host.sim.template.a4pre_first_tail_x15_r0.NpsStart
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

noncomputable def npsCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (L : Nat) : ICut FF :=
  { SetupDrop.cut NB T tk π L with
    s0 := PRE_first_tail_x15_r0.s17, tab0 := PRE_first_tail_x15_r0.S17.tab }

theorem toNps {NB T L : Nat} {tk : Nat → Nat} {π : List Nat} (hC : chunkC L = 2048) :
    CutConv (SetupCommon.nextCut NB T tk π L) (npsCut NB T tk π L) := by
  apply (SetupDrop.toOld hC).trans
  rintro x ⟨hr, hq⟩ hb
  refine ⟨x, rfl, rfl, ⟨?_, hq⟩, hb⟩
  change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
    x.M x.ν x.K PRE_first_tail_x15_r0.s17 ⟨PRE_first_tail_x15_r0.S17.tab, []⟩ x.t x.C
  rw [PRE_first_tail_x15_r0.nps1_eq, PRE_first_tail_x15_r0.nps1_tab_eq]
  exact hr

end Host.Ts.Sim.Compose.VWFirst
