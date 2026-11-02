import host.sim.template.a4dec4_ord.m.B0
import host.sim.compose.Seg
import host.sim.template.Chain
import host.sim.template.FullWorld
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim.Compose

noncomputable def EosCut4InputSrv : SSrv := ⟨DEC4_ord.S0.tab, []⟩

set_option interpreter.prefer_native true in
tpl_chain EOSCut4 from DEC4_ord.s0, EosCut4InputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/eos4_plan.json" (world := full)

end Host.Load.Run.Tpl
