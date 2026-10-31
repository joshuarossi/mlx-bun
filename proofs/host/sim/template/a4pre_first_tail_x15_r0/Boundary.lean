import host.sim.template.a4pre_first_tail_x15_r0.H1
import host.sim.conv.Compact
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

def PRE_first_tail_x15_r0.dws : List Nat := [1087]
def PRE_first_tail_x15_r0.drs : List SymE := [(SymE.bin .add (SymE.lit (F64.zero false)) (SymE.bin .sub (SymE.bin .sub (SymE.var 9) (SymE.lit (F64.zero false))) (SymE.lit (F64.fin false 1 (0)))))]
noncomputable def PRE_first_tail_x15_r0.dtheta : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0.dws PRE_first_tail_x15_r0.drs
noncomputable def PRE_first_tail_x15_r0.endSrv : SSrv :=
  ⟨[(SymE.var 0), (SymE.var 1), (SymE.var 2), (SymE.var 3), (SymE.var 4), (SymE.var 5), (SymE.var 6), (SymE.var 7), (SymE.var 8), (SymE.var 9), (SymE.var 9), (SymE.var 9), (SymE.bin .add (SymE.var 9) (SymE.var 0)), (SymE.var 9), (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.bin .sub (SymE.bin .sub (SymE.var 9) (SymE.lit (F64.zero false))) (SymE.lit (F64.fin false 1 (0))))), (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.bin .sub (SymE.bin .sub (SymE.var 9) (SymE.lit (F64.zero false))) (SymE.lit (F64.fin false 1 (0))))), (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.bin .sub (SymE.bin .sub (SymE.var 9) (SymE.lit (F64.zero false))) (SymE.lit (F64.fin false 1 (0)))))), (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.bin .sub (SymE.bin .sub (SymE.var 9) (SymE.lit (F64.zero false))) (SymE.lit (F64.fin false 1 (0)))))], []⟩
kernel_rfl PRE_first_tail_x15_r0.endTab : PRE_first_tail_x15_r0.S41.tab.map (·.subst PRE_first_tail_x15_r0.dtheta) = PRE_first_tail_x15_r0.endSrv.tab
theorem PRE_first_tail_x15_r0.endSrv_length : PRE_first_tail_x15_r0.endSrv.tab.length = PRE_first_tail_x15_r0.S41.tab.length := by
  rw [← PRE_first_tail_x15_r0.endTab, List.length_map]

end Host.Load.Run.Tpl
