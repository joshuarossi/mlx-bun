import host.route.cert.Fin.Choose
import host.simgraph.tpl.ordinary.Join
import host.sim.template.a4pre_fd_vw_r0_body.H0
import host.sim.template.a4pre_fd_vw_r0_body.H28
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.VW
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl

/-! # The VW class's final forward: its choice of carriers -/

noncomputable def endLoad : St Host.Load.LSt :=
  ⟨PRE_fd_vw_r0_body.s900.heap, PRE_fd_vw_r0_body.s900.next, PRE_fd_vw_r0_body.s900.ctl, PRE_fd_vw_r0_body.s900.stack,
    ⟨PRE_fd_vw_r0_body.s900.aux.jobs, Host.Load.Layers.toLoad PRE_fd_vw_r0_body.s900.aux.ffi, PRE_fd_vw_r0_body.s900.aux.trace,
      PRE_fd_vw_r0_body.s900.aux.stores⟩⟩
noncomputable def startLoad : St Host.Load.LSt :=
  ⟨PRE_fd_vw_r0_body.s0.heap, PRE_fd_vw_r0_body.s0.next, PRE_fd_vw_r0_body.s0.ctl, PRE_fd_vw_r0_body.s0.stack,
    ⟨PRE_fd_vw_r0_body.s0.aux.jobs, Host.Load.Layers.toLoad PRE_fd_vw_r0_body.s0.aux.ffi, PRE_fd_vw_r0_body.s0.aux.trace,
      PRE_fd_vw_r0_body.s0.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`endSrv, ``PRE_fd_vw_r0_body.S900), (`startSrv, ``PRE_fd_vw_r0_body.S0), (`envSrv, ``Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

def box : Box := [(9, 2, 224), (10, 1, 223), (11, 1, 223), (12, 1, 1), (16, 256, 256)]
def vars : VarV := [(9, 0, 1), (10, -1, 1), (11, -1, 1), (12, 1, 0), (16, 256, 0)]

/-- The forward's part of the ordinary step. -/
def Eh : List (RNode SDim InKey) := Tpl.Ordinary.graph.take 4010

set_option interpreter.prefer_native false in
simgraph_choose_fin choice : (endLoad, endSrv), (startLoad, startSrv), (Host.Load.Run.Prompt.P.s0, envSrv),
  box, vars, -1, 19057, 19057, Eh

end Host.Route.Cert.Fin.VW
