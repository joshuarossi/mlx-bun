import host.sim.template.a4pre_setup_native6.Base
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

set_option interpreter.prefer_native true in
tpl_chain PREG6Native32 from PREGlue6.chooserLiteral, PREGlue6.chooserSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_setup_native6/plan.json" («world» := full)

end Host.Load.Run.Tpl
