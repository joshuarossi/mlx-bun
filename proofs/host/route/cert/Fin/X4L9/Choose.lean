import host.route.cert.Fin.Choose
import host.simgraph.tpl.ordinary.Join
import host.sim.template.a4pre_fd_x4_L9_r0_body.m.B00
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.X4L9
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The X4L9 class's final forward: its choice of carriers -/

noncomputable def endLoad : St Host.Load.LSt :=
  ⟨PRE_fd_x4_L9_r0_body.s451.heap, PRE_fd_x4_L9_r0_body.s451.next, PRE_fd_x4_L9_r0_body.s451.ctl, PRE_fd_x4_L9_r0_body.s451.stack,
    ⟨PRE_fd_x4_L9_r0_body.s451.aux.jobs, Host.Load.Layers.toLoad PRE_fd_x4_L9_r0_body.s451.aux.ffi, PRE_fd_x4_L9_r0_body.s451.aux.trace, PRE_fd_x4_L9_r0_body.s451.aux.stores⟩⟩
noncomputable def startLoad : St Host.Load.LSt :=
  ⟨PRE_fd_x4_L9_r0_body.s0.heap, PRE_fd_x4_L9_r0_body.s0.next, PRE_fd_x4_L9_r0_body.s0.ctl, PRE_fd_x4_L9_r0_body.s0.stack,
    ⟨PRE_fd_x4_L9_r0_body.s0.aux.jobs, Host.Load.Layers.toLoad PRE_fd_x4_L9_r0_body.s0.aux.ffi, PRE_fd_x4_L9_r0_body.s0.aux.trace, PRE_fd_x4_L9_r0_body.s0.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`endSrv, ``PRE_fd_x4_L9_r0_body.S451), (`startSrv, ``PRE_fd_x4_L9_r0_body.S0), (`envSrv, ``Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

def box : Box := [(9, 9, 9), (10, 8, 8), (11, 8, 8), (16, 256, 256)]
def vars : VarV := [(9, 0, 1), (10, -1, 1), (11, -1, 1), (16, 256, 0)]

/-- The forward's part of the ordinary step. -/
def Eh : List (RNode SDim InKey) := Tpl.Ordinary.graph.take 4010

set_option interpreter.prefer_native false in
simgraph_choose_fin choice : (endLoad, endSrv), (startLoad, startSrv), (Host.Load.Run.Prompt.P.s0, envSrv),
  box, vars, -1, 19265, 19265, Eh

end Host.Route.Cert.Fin.X4L9
