import host.simgraph.prompt.ChooseRoute
import host.simgraph.tpl.fam.VW83.Join
import host.sim.template.a4pre_first_tail_x8_r0_suffix.States
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.VW8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam

/-! # The x8 forward's choice of carriers -/

/-- The template at the forward's return, for restoring its stream. -/
noncomputable def endLoad : St Host.Load.LSt :=
  ⟨PRE_first_tail_x8_r0_suffix.input.heap, PRE_first_tail_x8_r0_suffix.input.next, PRE_first_tail_x8_r0_suffix.input.ctl, PRE_first_tail_x8_r0_suffix.input.stack,
    ⟨PRE_first_tail_x8_r0_suffix.input.aux.jobs, Host.Load.Layers.toLoad PRE_first_tail_x8_r0_suffix.input.aux.ffi, PRE_first_tail_x8_r0_suffix.input.aux.trace, PRE_first_tail_x8_r0_suffix.input.aux.stores⟩⟩

def box : Box := [(9, 10, 224), (10, 9, 223)]

/-- The expected graph, built natively. -/
def Ecn : List (RNode PDim SimGraph.PKey) :=
  (familyGraph VW83.F id 0 124 Host.Load.Run.Full.Expected.stages).1.map (Host.Mlx.SimGraph.mapN (rowsAt 10))

set_option interpreter.prefer_native true in
simgraph_choose_route choice : (endLoad, PRE_first_tail_x8_r0_suffix.inputSrv), box, 15235, 15235, [5554869888], Ecn, 15235

end Host.Route.Cert.VW8
