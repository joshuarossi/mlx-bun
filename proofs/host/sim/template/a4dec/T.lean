import host.sim.template.a4dec.States
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Scratch (track A4, Phase B): the decode loop template on the prompt route (full world) from `DK0.s0`, iteration 1's
readback call for a 1-token prompt, by `specs/prompt.json`. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_template DT from DK0.s0, DK0.S0 (world := full, spec := "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/prompt.json")

end Host.Load.Run.Tpl
