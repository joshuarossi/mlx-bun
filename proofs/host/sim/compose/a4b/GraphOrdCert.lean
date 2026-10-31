import host.sim.compose.a4b.Entry
import host.simgraph.Choose
import host.simgraph.tpl.ordinary.Join
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Ts.Sim.Compose.DECGraph.Ord
open _root_.Host.Ts _root_.Host.Load _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Ts.Sim.Template

/-! The ordinary decode chain's actual end graph, read at the symbolic time variable.
The carrier search chooses data; `simgraph_check_template` checks the whole certificate. -/

noncomputable def endLoad : St LSt :=
  ⟨Host.Load.Run.Tpl.DEC_ord.s11.heap, Host.Load.Run.Tpl.DEC_ord.s11.next,
    Host.Load.Run.Tpl.DEC_ord.s11.ctl, Host.Load.Run.Tpl.DEC_ord.s11.stack,
    ⟨Host.Load.Run.Tpl.DEC_ord.s11.aux.jobs, Host.Load.Layers.toLoad Host.Load.Run.Tpl.DEC_ord.s11.aux.ffi,
      Host.Load.Run.Tpl.DEC_ord.s11.aux.trace, Host.Load.Run.Tpl.DEC_ord.s11.aux.stores⟩⟩
noncomputable def startLoad : St LSt :=
  ⟨DEC.s0.heap, DEC.s0.next, DEC.s0.ctl, DEC.s0.stack,
    ⟨DEC.s0.aux.jobs, Host.Load.Layers.toLoad DEC.s0.aux.ffi, DEC.s0.aux.trace, DEC.s0.aux.stores⟩⟩

theorem endLoad_proj : endLoad = fullWorld.proj Host.Load.Run.Tpl.DEC_ord.s11 := rfl
theorem startLoad_proj : startLoad = fullWorld.proj DEC.s0 := rfl

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`endSrv, ``Host.Load.Run.Tpl.DEC_ord.S1D),
      (`startSrv, ``Host.Load.Run.Tpl.DEC_ord.S0), (`envSrv, ``Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

theorem endSrv_eq : endSrv = Host.Load.Run.Tpl.DEC_ord.S1D := rfl
theorem startSrv_eq : startSrv = Host.Load.Run.Tpl.DEC_ord.S0 := rfl
theorem envSrv_eq : envSrv = Host.Load.Run.Prompt.P.S0 := rfl

def NL : Nat := 20000
def N0 : Nat := 22539
def fixedBigs : List Int := [5554869888]
def tokenNode : Nat := 22539

noncomputable def Gs : Nat → Option (RNode SDim InKey) :=
  restrictTo (tplDom NL N0 fixedBigs endLoad.ffi.mlx)
    (symGraph (clsOf Host.Load.Run.Tpl.DEC_ord.S1D 9) SourceKernels.sources endLoad.ffi.mlx)

set_option interpreter.prefer_native false in
simgraph_choose choice : (endLoad, endSrv), (startLoad, startSrv),
  (Host.Load.Run.Prompt.P.s0, envSrv),
  9, NL, N0, fixedBigs, tokenNode, Tpl.Ordinary.graph

def insT : InKey → Option Nat := inputsOf choice.inputs

simgraph_check_template check : Gs, Tpl.Ordinary.graph, choice.cert, insT choosing Tpl.Ordinary.graph

theorem cert_length : Tpl.Ordinary.graph.length ≤ choice.cert.length := by decide

end Host.Ts.Sim.Compose.DECGraph.Ord
