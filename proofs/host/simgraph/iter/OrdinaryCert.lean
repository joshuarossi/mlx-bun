import host.sim.template.ordinary.H4
import host.simgraph.Choose
import host.simgraph.tpl.ordinary.Join
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter.Ordinary
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl

/-! The ORDINARY template's certificate: the end state `ORDINARY.s150` of the
template iteration from `Base.s0`, read symbolically (`clsOf ORDINARY.S150 9`)
on the template domain (pre-loop nodes below 15270, the iteration's from 22539,
rope base `5554869888`), carries the interior-branch template graph. The
carriers are searched natively; `check` is the kernel check. -/

/-- The template domain's bounds: pre-loop nodes, the template's start, kept rope bases. -/
def NL : Nat := 15270
def N0 : Nat := 22539
def fixedBigs : List Int := [5554869888]
/-- The fed-back token: the template iteration's first node. -/
def tokenNode : Nat := 22539

noncomputable def Gs : Nat → Option (RNode SDim InKey) :=
  restrictTo (tplDom NL N0 fixedBigs ORDINARY.s150.ffi.mlx)
    (symGraph (clsOf ORDINARY.S150 9) SourceKernels.sources ORDINARY.s150.ffi.mlx)

simgraph_choose choice : (ORDINARY.s150, ORDINARY.S150), (Base.s0, Base.S0),
  (Host.Load.Run.Full.P.s0, Host.Load.Run.Full.P.S0), 9, NL, N0, fixedBigs, tokenNode, Tpl.Ordinary.graph

def insT : InKey → Option Nat := inputsOf choice.inputs

simgraph_check_template check : Gs, Tpl.Ordinary.graph, choice.cert, insT choosing Tpl.Ordinary.graph

theorem cert_length : Tpl.Ordinary.graph.length ≤ choice.cert.length := by decide

end Host.Mlx.SimGraph.Iter.Ordinary
