import host.route.cert.Row.ChooseRow
import host.simgraph.tpl.ordinary.Join
import host.sim.template.a4pre_pl_r1.H0
import host.sim.template.a4pre_pl_r1.H14
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row.R1
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl

/-! # POST row `r1`: its choice of carriers -/

noncomputable def endLoad : St Host.Load.LSt :=
  ⟨PRE_pl_r1.s448.heap, PRE_pl_r1.s448.next, PRE_pl_r1.s448.ctl, PRE_pl_r1.s448.stack,
    ⟨PRE_pl_r1.s448.aux.jobs, Host.Load.Layers.toLoad PRE_pl_r1.s448.aux.ffi, PRE_pl_r1.s448.aux.trace,
      PRE_pl_r1.s448.aux.stores⟩⟩
noncomputable def startLoad : St Host.Load.LSt :=
  ⟨PRE_pl_r1.s0.heap, PRE_pl_r1.s0.next, PRE_pl_r1.s0.ctl, PRE_pl_r1.s0.stack,
    ⟨PRE_pl_r1.s0.aux.jobs, Host.Load.Layers.toLoad PRE_pl_r1.s0.aux.ffi, PRE_pl_r1.s0.aux.trace,
      PRE_pl_r1.s0.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`endSrv, ``PRE_pl_r1.S448), (`startSrv, ``PRE_pl_r1.S0), (`envSrv, ``Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

set_option interpreter.prefer_native false in
simgraph_choose_row choice : (endLoad, endSrv), (startLoad, startSrv), (Host.Load.Run.Prompt.P.s0, envSrv),
  0, 17777, Tpl.Ordinary.graph

end Host.Route.Cert.Row.R1
