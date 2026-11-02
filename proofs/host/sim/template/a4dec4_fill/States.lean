import host.sim.template.a4dec4.S
set_option Elab.async false
namespace Host.Load.Run.Tpl
-- stream revision 1793584732686
/-! Decode case `fill` (row `dec_fill.r0`) as a chain from the decode template `DT4`: the readback, the D1 forward, the sampler and the async evaluation as stage calls, to the next readback. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain DEC4_fill from DT4.s0, DT4.S0 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4dec4_fill/plan.json" (world := full)

end Host.Load.Run.Tpl
