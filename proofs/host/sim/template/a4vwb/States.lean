import host.sim.template.a4vw.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Scratch (track A4, Phase B): the VW forward body with its row count symbolic (`var 21`, 101 here), isolated
at its call (`VW0.s1`), cut at its cache stages and its plan selectors (per-site instances, merges and
compactions), the symbolic `mlx_array_size` calls bridged, to its return. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain VWB from VW0.s1, VW0.S1 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4vw/body.json" (world := full)

end Host.Load.Run.Tpl
