import host.sim.template.a4dec2.S
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Decode case `ord` (row `dec_ord.r0`) as a chain from the decode template `DT2`: the readback, the D1 forward, the sampler and the async evaluation as stage calls, to the next readback. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain DEC2_ord from DT2.s0, DT2.S0 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4dec2_ord/plan.json" (world := full)

end Host.Load.Run.Tpl
