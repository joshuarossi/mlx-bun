import host.sim.lin.CoverT1
import host.sim.lin.checks.Nps
import host.sim.stage.NextStepHolds
namespace Host.Ts.Sim.Lin.Cls
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Prefill

/-! # Using a class's checks

How a composition reads the table: a class's cover gives the step's row, the row's check gives
the oracle at the template's valuation. Here, at every length of tail class `⟨2048, 22, true⟩`
(a tail of 224…256 rows after whole chunks of 2048), the `nextPrefillStep` call's oracle (class
`DTtail` of `host.sim.stage.NextStepRun`) is correct at the stage's valuation of the step, and the
stage's server is the template's table instantiated there. -/

theorem tail_2048_x22_g.nps_good {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) (ha : TailClass.Applies ⟨2048, 22, true⟩ L) :
    Good (Stage.NextStep.ρd L (tailI L).o (tailI L).C) Stage.NextStep.DTtail.O := by
  obtain ⟨r, hr, hin⟩ := tail_2048_x22_g.cover L h1 h2 ha
  have hm : MapOk (Stage.NextStep.ρd L (tailI L).o (tailI L).C) (tailI L) [(0, .L), (1, .o), (2, .C)] :=
    ⟨rfl, rfl, rfl, trivial⟩
  simp only [tail_2048_x22_g.rows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl
  · exact good_of_row tail_2048_x22_g.r0.nps hin hm
  · exact good_of_row tail_2048_x22_g.r1.nps hin hm

theorem tail_2048_x22_g.nps_inst {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) (ha : TailClass.Applies ⟨2048, 22, true⟩ L) :
    Host.Ts.Inst (Stage.NextStep.ρd L (tailI L).o (tailI L).C) ⟨Stage.NextStep.tab, Stage.NextStep.DTtail.O⟩
      (Stage.NextStep.callSrv L (tailI L).o (tailI L).C) :=
  Stage.NextStep.srv_inst _ _ _ (tail_2048_x22_g.nps_good h1 h2 ha)

end Host.Ts.Sim.Lin.Cls
