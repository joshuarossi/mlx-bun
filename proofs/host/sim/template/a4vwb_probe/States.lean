import host.sim.template.a4vw.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! The actual VW forward prefix through its first appendWindow return. This probe checks
the cold callback sites and their compactions; it makes no whole-forward claim. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain VWBProbe from VW0.s1, VW0.S1 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4vwb_probe/plan.json" (world := full)

end Host.Load.Run.Tpl
