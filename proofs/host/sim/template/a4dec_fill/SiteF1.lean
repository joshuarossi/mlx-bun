import host.sim.template.a4dec_fill.st1.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `DEC_fill`: `Conv.site_merge`'s footprint facts. -/

theorem DEC_fill.wrNodup1 : DEC_fill.st1.wr.Nodup := DEC_fill.st1.wrNodup
theorem DEC_fill.wrBound1 : ∀ b ∈ DEC_fill.st1.wr, b / 4096 < 4 ^ 31 := DEC_fill.st1.wrBound
noncomputable def DEC_fill.trFr1 := DEC_fill.st1.s150.trace.take 18059
kernel_rfl DEC_fill.traceEq1 : DEC_fill.st1.s150.trace = DEC_fill.trFr1 ++ DEC_fill.st1.s0.trace
theorem DEC_fill.trace1 : ∃ fr, DEC_fill.st1.s150.trace = fr ++ DEC_fill.st1.s0.trace := ⟨_, DEC_fill.traceEq1⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def DEC_fill.wide1 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl DEC_fill.wfixB1 : (DEC_fill.wide1.all fun p => wfixB Map.id (presentB DEC_fill.st1.s0) p.2) = true
theorem DEC_fill.wfix1 : ∀ p ∈ DEC_fill.wide1, WFix Map.id (Present DEC_fill.st1.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp DEC_fill.wfixB1 p hp)

end Host.Load.Run.Tpl
