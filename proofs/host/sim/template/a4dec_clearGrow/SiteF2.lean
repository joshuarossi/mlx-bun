import host.sim.template.a4dec_clearGrow.st2.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_clearGrow`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl DEC_clearGrow.wrNodupB2 : nodupT DEC_clearGrow.st2.wr PTrie.nil = true
theorem DEC_clearGrow.wrNodup2 : DEC_clearGrow.st2.wr.Nodup := (nodupT_sound DEC_clearGrow.wrNodupB2).2
kernel_rfl DEC_clearGrow.wrBoundB2 : DEC_clearGrow.st2.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem DEC_clearGrow.wrBound2 : ∀ b ∈ DEC_clearGrow.st2.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearGrow.wrBoundB2 b hb)
noncomputable def DEC_clearGrow.trFr2 := DEC_clearGrow.st2.s2.trace.take 3
kernel_rfl DEC_clearGrow.traceEq2 : DEC_clearGrow.st2.s2.trace = DEC_clearGrow.trFr2 ++ DEC_clearGrow.st2.s0.trace
theorem DEC_clearGrow.trace2 : ∃ fr, DEC_clearGrow.st2.s2.trace = fr ++ DEC_clearGrow.st2.s0.trace := ⟨_, DEC_clearGrow.traceEq2⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def DEC_clearGrow.wide2 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl DEC_clearGrow.wfixB2 : (DEC_clearGrow.wide2.all fun p => wfixB Map.id (presentB DEC_clearGrow.st2.s0) p.2) = true
theorem DEC_clearGrow.wfix2 : ∀ p ∈ DEC_clearGrow.wide2, WFix Map.id (Present DEC_clearGrow.st2.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp DEC_clearGrow.wfixB2 p hp)

end Host.Load.Run.Tpl
