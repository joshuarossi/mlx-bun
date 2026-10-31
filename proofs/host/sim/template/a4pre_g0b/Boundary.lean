import host.sim.template.a4pre_g0b.H0
import host.sim.conv.Compact
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

def PRE_g0b.dws : List Nat := []
def PRE_g0b.drs : List SymE := []
noncomputable def PRE_g0b.dtheta : Nat → SymE := Conv.compactθ PRE_g0b.dws PRE_g0b.drs
noncomputable def PRE_g0b.endSrv : SSrv :=
  ⟨[(SymE.var 0), (SymE.var 1), (SymE.var 2), (SymE.var 3), (SymE.var 4), (SymE.var 5), (SymE.var 6), (SymE.var 7), (SymE.var 8), (SymE.var 9), (SymE.var 10), (SymE.var 9), (SymE.var 9), (SymE.bin .add (SymE.var 9) (SymE.var 0)), (SymE.var 9)], []⟩
kernel_rfl PRE_g0b.endTab : PRE_g0b.S10.tab.map (·.subst PRE_g0b.dtheta) = PRE_g0b.endSrv.tab
theorem PRE_g0b.endSrv_length : PRE_g0b.endSrv.tab.length = PRE_g0b.S10.tab.length := by
  rw [← PRE_g0b.endTab, List.length_map]

end Host.Load.Run.Tpl
