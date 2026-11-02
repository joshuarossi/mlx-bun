import host.simgraph.ChooseConv
import host.simgraph.tpl.ordinary.Join
import host.sim.template.a4dec4_clear.ERestart
import host.sim.template.DimVals
import host.load.run.prompt.Addr
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Route.Cert.Dec.Clear
open Host.Ts Host.Load Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Ts.Sim.Template

/-! The clear decode chain's end graph over the template `DT4`, read at the symbolic time variable with its abstracted dims pinned.
The carrier search chooses data; the kernel checks the whole certificate. -/

noncomputable def endLoad : St LSt :=
  ⟨Host.Load.Run.Tpl.DEC4_clear.s11.heap, Host.Load.Run.Tpl.DEC4_clear.s11.next, Host.Load.Run.Tpl.DEC4_clear.s11.ctl, Host.Load.Run.Tpl.DEC4_clear.s11.stack,
    ⟨Host.Load.Run.Tpl.DEC4_clear.s11.aux.jobs, Host.Load.Layers.toLoad Host.Load.Run.Tpl.DEC4_clear.s11.aux.ffi, Host.Load.Run.Tpl.DEC4_clear.s11.aux.trace, Host.Load.Run.Tpl.DEC4_clear.s11.aux.stores⟩⟩
noncomputable def startLoad : St LSt :=
  ⟨Host.Load.Run.Tpl.DEC4_clear.s0.heap, Host.Load.Run.Tpl.DEC4_clear.s0.next, Host.Load.Run.Tpl.DEC4_clear.s0.ctl, Host.Load.Run.Tpl.DEC4_clear.s0.stack,
    ⟨Host.Load.Run.Tpl.DEC4_clear.s0.aux.jobs, Host.Load.Layers.toLoad Host.Load.Run.Tpl.DEC4_clear.s0.aux.ffi, Host.Load.Run.Tpl.DEC4_clear.s0.aux.trace, Host.Load.Run.Tpl.DEC4_clear.s0.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`endSrv, ``Host.Load.Run.Tpl.DEC4_clear.S1R),
      (`startSrv, ``Host.Load.Run.Tpl.DEC4_clear.S0), (`envSrv, ``Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

def NL : Nat := 20000
def N0 : Nat := 22539
def fixedBigs : List Int := [5554869888]
def tokenNode : Nat := 22539

noncomputable def Gs : Nat → Option (RNode SDim InKey) :=
  restrictTo (tplDom NL N0 fixedBigs endLoad.ffi.mlx)
    (pinGraph Host.Load.Run.Tpl.DEC4_clear.S1R 9 Host.Load.Run.Tpl.decVal SourceKernels.sources endLoad.ffi.mlx)

set_option interpreter.prefer_native false in
simgraph_choose_conv choice : (endLoad, endSrv), (startLoad, startSrv),
  (Host.Load.Run.Prompt.P.s0, envSrv),
  9, Host.Load.Run.Tpl.decVal, NL, N0, fixedBigs, tokenNode, Tpl.Ordinary.graph

def insT : InKey → Option Nat := inputsOf choice.inputs

simgraph_check_template check : Gs, Tpl.Ordinary.graph, choice.cert, insT choosing Tpl.Ordinary.graph

theorem cert_length : Tpl.Ordinary.graph.length ≤ choice.cert.length := by decide

end Host.Route.Cert.Dec.Clear
