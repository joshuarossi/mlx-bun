import host.route.cert.X4L8.Choose
import host.sim.template.a4pre_first_tail_x4_L8_r0_suffix.m.B0
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.X4L8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam
open Host.Ts.Sim.Full (mlxOf)

/-! # The x4_L8 forward's certificate: what it reads -/

noncomputable def native : Ffi.St := mlxOf PRE_first_tail_x4_L8_r0_suffix.s0.ffi
noncomputable abbrev Gs := famGs native PRE_first_tail_x4_L8_r0_suffix.inputSrv box [5554869888]
noncomputable abbrev ins := insOf 15235 choice.cells

/-- The expected graph, as the chain reads it at its rows' variable. -/
noncomputable def Ec : List (RNode PDim SimGraph.PKey) := V587.graph.map (Host.Mlx.SimGraph.mapN (litAt (Ref.refNu 0 7)))

end Host.Route.Cert.X4L8
