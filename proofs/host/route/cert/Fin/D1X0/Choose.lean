import host.route.cert.Fin.Choose
import host.load.run.full.expected.Join
import host.sim.template.a4pre_first_tail_x0_r0_suffix.States
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B00
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.D1X0
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The D1X0 class's first forward: its choice of carriers -/

noncomputable def endLoad : St Host.Load.LSt :=
  ⟨PRE_first_tail_x0_r0_suffix.input.heap, PRE_first_tail_x0_r0_suffix.input.next, PRE_first_tail_x0_r0_suffix.input.ctl, PRE_first_tail_x0_r0_suffix.input.stack,
    ⟨PRE_first_tail_x0_r0_suffix.input.aux.jobs, Host.Load.Layers.toLoad PRE_first_tail_x0_r0_suffix.input.aux.ffi, PRE_first_tail_x0_r0_suffix.input.aux.trace, PRE_first_tail_x0_r0_suffix.input.aux.stores⟩⟩
noncomputable def startLoad : St Host.Load.LSt :=
  ⟨PRE_first_tail_x0_r0_body.s0.heap, PRE_first_tail_x0_r0_body.s0.next, PRE_first_tail_x0_r0_body.s0.ctl, PRE_first_tail_x0_r0_body.s0.stack,
    ⟨PRE_first_tail_x0_r0_body.s0.aux.jobs, Host.Load.Layers.toLoad PRE_first_tail_x0_r0_body.s0.aux.ffi, PRE_first_tail_x0_r0_body.s0.aux.trace, PRE_first_tail_x0_r0_body.s0.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`startSrv, ``PRE_first_tail_x0_r0_body.S0), (`envSrv, ``Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

def box : Box := [(9, 2, 2)]
def vars : VarV := [(9, 0, 1)]

/-- The cold step's forward part, as the certificate reads it. -/
def Ed : List (RNode SDim InKey) := (Host.Load.Run.Full.Expected.graph.map (SimGraph.mapN SDim.lit)).take 4010

set_option interpreter.prefer_native false in
simgraph_choose_fin choice : (endLoad, PRE_first_tail_x0_r0_suffix.inputSrv), (startLoad, startSrv), (Host.Load.Run.Prompt.P.s0, envSrv),
  box, vars, -2, 15235, 15235, Ed

end Host.Route.Cert.Fin.D1X0
