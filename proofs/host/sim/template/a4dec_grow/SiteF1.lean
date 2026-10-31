import host.sim.template.a4dec_grow.st1.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `DEC_grow`: `Conv.site_merge`'s footprint facts. -/

theorem DEC_grow.wrNodup1 : DEC_grow.st1.wr.Nodup := DEC_grow.st1.wrNodup
theorem DEC_grow.wrBound1 : ∀ b ∈ DEC_grow.st1.wr, b / 4096 < 4 ^ 31 := DEC_grow.st1.wrBound
noncomputable def DEC_grow.trFr1 := DEC_grow.st1.s153.trace.take 18411
kernel_rfl DEC_grow.traceEq1 : DEC_grow.st1.s153.trace = DEC_grow.trFr1 ++ DEC_grow.st1.s0.trace
theorem DEC_grow.trace1 : ∃ fr, DEC_grow.st1.s153.trace = fr ++ DEC_grow.st1.s0.trace := ⟨_, DEC_grow.traceEq1⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def DEC_grow.wide1 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl DEC_grow.wfixB1 : (DEC_grow.wide1.all fun p => wfixB Map.id (presentB DEC_grow.st1.s0) p.2) = true
theorem DEC_grow.wfix1 : ∀ p ∈ DEC_grow.wide1, WFix Map.id (Present DEC_grow.st1.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp DEC_grow.wfixB1 p hp)

end Host.Load.Run.Tpl
