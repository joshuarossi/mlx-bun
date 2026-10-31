import host.sim.template.a4dec_ord.st1.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 1 of chain `DEC_ord`: `Conv.site_merge`'s footprint facts. -/

theorem DEC_ord.wrNodup1 : DEC_ord.st1.wr.Nodup := DEC_ord.st1.wrNodup
theorem DEC_ord.wrBound1 : ∀ b ∈ DEC_ord.st1.wr, b / 4096 < 4 ^ 31 := DEC_ord.st1.wrBound
noncomputable def DEC_ord.trFr1 := DEC_ord.st1.s150.trace.take 18059
kernel_rfl DEC_ord.traceEq1 : DEC_ord.st1.s150.trace = DEC_ord.trFr1 ++ DEC_ord.st1.s0.trace
theorem DEC_ord.trace1 : ∃ fr, DEC_ord.st1.s150.trace = fr ++ DEC_ord.st1.s0.trace := ⟨_, DEC_ord.traceEq1⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def DEC_ord.wide1 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl DEC_ord.wfixB1 : (DEC_ord.wide1.all fun p => wfixB Map.id (presentB DEC_ord.st1.s0) p.2) = true
theorem DEC_ord.wfix1 : ∀ p ∈ DEC_ord.wide1, WFix Map.id (Present DEC_ord.st1.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp DEC_ord.wfixB1 p hp)

end Host.Load.Run.Tpl
