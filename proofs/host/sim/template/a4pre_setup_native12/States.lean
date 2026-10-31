import host.sim.template.a4pre_setup_native12.Base
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

set_option interpreter.prefer_native true in
tpl_chain PREG12Native32 from PREGlue12.chooserLiteral, PREGlue12.chooserSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_setup_native12/plan.json" («world» := full)

end Host.Load.Run.Tpl
