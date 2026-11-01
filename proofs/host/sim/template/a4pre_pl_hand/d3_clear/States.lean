import host.sim.template.a4pre_pl_hand.d3.S
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain DEC3_clear from DT3.s0, DT3.S0 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_pl_hand/d3_clear/plan.json" (world := full)
end Host.Load.Run.Tpl
