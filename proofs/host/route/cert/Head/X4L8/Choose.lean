import host.route.cert.Fin.ChooseHead
import host.simgraph.prompt.ChooseRoute
import host.route.cert.Fin.X4L8.Choose
import host.simgraph.tpl.ordinary.Join
import host.sim.template.a4pre_plx4_L8_common.H0
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.X4L8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The X4L8 class's sampled cut: its choice of carriers -/

noncomputable def loadH : St Host.Load.LSt :=
  ⟨PRE_plx4_L8_common.s1.heap, PRE_plx4_L8_common.s1.next, PRE_plx4_L8_common.s1.ctl, PRE_plx4_L8_common.s1.stack,
    ⟨PRE_plx4_L8_common.s1.aux.jobs, Host.Load.Layers.toLoad PRE_plx4_L8_common.s1.aux.ffi, PRE_plx4_L8_common.s1.aux.trace, PRE_plx4_L8_common.s1.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`srvH, ``PRE_plx4_L8_common.S1)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

def boxH : Box := [(9, 8, 8), (10, 1, 1), (11, 8, 8), (16, 256, 256)]
def varsH : VarV := [(9, 0, 1), (10, 1, 0), (11, 0, 1), (16, 256, 0)]

set_option interpreter.prefer_native false in
simgraph_choose_head choiceH : (loadH, srvH), boxH, varsH, -1, 19265, 4010, Fin.X4L8.choice.cert,
  (fun key => (inputsOf Fin.X4L8.choice.inputs key).orElse fun _ => insOf 0 [] (.base key)), Tpl.Ordinary.graph

end Host.Route.Cert.Head.X4L8
