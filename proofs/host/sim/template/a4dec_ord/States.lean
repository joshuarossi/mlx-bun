import host.sim.template.a4dec.S
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Scratch (track A4, Phase B): decode case `ord` (row `dec_ord.r0`) as a chain from the decode template `DT`:
the readback, the D1 forward, the sampler and the async evaluation as stage calls, to the next readback. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain DEC_ord from DT.s0, DT.S0 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4dec_ord/plan.json" (world := full)

end Host.Load.Run.Tpl
