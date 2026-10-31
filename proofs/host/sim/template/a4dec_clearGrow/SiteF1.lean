import host.sim.template.a4dec_clearGrow.st1.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `DEC_clearGrow`: `Conv.site_merge`'s footprint facts. -/

theorem DEC_clearGrow.wrNodup1 : DEC_clearGrow.st1.wr.Nodup := DEC_clearGrow.st1.wrNodup
theorem DEC_clearGrow.wrBound1 : ∀ b ∈ DEC_clearGrow.st1.wr, b / 4096 < 4 ^ 31 := DEC_clearGrow.st1.wrBound
noncomputable def DEC_clearGrow.trFr1 := DEC_clearGrow.st1.s153.trace.take 18411
kernel_rfl DEC_clearGrow.traceEq1 : DEC_clearGrow.st1.s153.trace = DEC_clearGrow.trFr1 ++ DEC_clearGrow.st1.s0.trace
theorem DEC_clearGrow.trace1 : ∃ fr, DEC_clearGrow.st1.s153.trace = fr ++ DEC_clearGrow.st1.s0.trace := ⟨_, DEC_clearGrow.traceEq1⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def DEC_clearGrow.wide1 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl DEC_clearGrow.wfixB1 : (DEC_clearGrow.wide1.all fun p => wfixB Map.id (presentB DEC_clearGrow.st1.s0) p.2) = true
theorem DEC_clearGrow.wfix1 : ∀ p ∈ DEC_clearGrow.wide1, WFix Map.id (Present DEC_clearGrow.st1.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp DEC_clearGrow.wfixB1 p hp)

end Host.Load.Run.Tpl
