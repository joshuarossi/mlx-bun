import host.route.cert.Fin.ChooseHead
import host.simgraph.prompt.ChooseRoute
import host.route.cert.Fin.VW.Choose
import host.simgraph.tpl.ordinary.Join
import host.sim.template.a4pre_plvw_common.H0
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.VW
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The VW class's sampled cut: its choice of carriers

The ordinary step's head and sampler on the template at POST's sampled cut; the forward's part where the final forward left it. -/

noncomputable def loadH : St Host.Load.LSt :=
  ⟨PRE_plvw_common.s1.heap, PRE_plvw_common.s1.next, PRE_plvw_common.s1.ctl, PRE_plvw_common.s1.stack,
    ⟨PRE_plvw_common.s1.aux.jobs, Host.Load.Layers.toLoad PRE_plvw_common.s1.aux.ffi, PRE_plvw_common.s1.aux.trace,
      PRE_plvw_common.s1.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`srvH, ``PRE_plvw_common.S1)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

/-- POST's valuation: the prompt's length at 9 and 11, one row at 10, the cache's capacity at 16. -/
def boxH : Box := [(9, 2, 224), (10, 1, 1), (11, 2, 224), (16, 256, 256)]
def varsH : VarV := [(9, 0, 1), (10, 1, 0), (11, 0, 1), (16, 256, 0)]

set_option interpreter.prefer_native false in
simgraph_choose_head choiceH : (loadH, srvH), boxH, varsH, -1, 19057, 4010, Fin.VW.choice.cert,
  (fun key => (inputsOf Fin.VW.choice.inputs key).orElse fun _ => insOf 0 [] (.base key)),
  Tpl.Ordinary.graph

end Host.Route.Cert.Head.VW
