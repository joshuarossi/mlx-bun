import host.sim.template.a4dec_grow.st2.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_grow`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl DEC_grow.wrNodupB2 : nodupT DEC_grow.st2.wr PTrie.nil = true
theorem DEC_grow.wrNodup2 : DEC_grow.st2.wr.Nodup := (nodupT_sound DEC_grow.wrNodupB2).2
kernel_rfl DEC_grow.wrBoundB2 : DEC_grow.st2.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem DEC_grow.wrBound2 : ∀ b ∈ DEC_grow.st2.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp DEC_grow.wrBoundB2 b hb)
noncomputable def DEC_grow.trFr2 := DEC_grow.st2.s2.trace.take 3
kernel_rfl DEC_grow.traceEq2 : DEC_grow.st2.s2.trace = DEC_grow.trFr2 ++ DEC_grow.st2.s0.trace
theorem DEC_grow.trace2 : ∃ fr, DEC_grow.st2.s2.trace = fr ++ DEC_grow.st2.s0.trace := ⟨_, DEC_grow.traceEq2⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def DEC_grow.wide2 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl DEC_grow.wfixB2 : (DEC_grow.wide2.all fun p => wfixB Map.id (presentB DEC_grow.st2.s0) p.2) = true
theorem DEC_grow.wfix2 : ∀ p ∈ DEC_grow.wide2, WFix Map.id (Present DEC_grow.st2.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp DEC_grow.wfixB2 p hp)

end Host.Load.Run.Tpl
