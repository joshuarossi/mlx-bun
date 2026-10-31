import host.sim.template.a4pre_d1_post.Origin
import host.simgraph.Choose
import host.simgraph.GenLoadRel
import host.simgraph.prompt.PromptStep
import host.sim.compose.a4b.GraphColdFullExpected
import host.sim.compose.a4b.GraphColdEval
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Ts.Sim.Template

/-! Frozen candidate data only; no body execution is asserted here. Native variable 9
is the singleton prompt length. The model's cold logical positions are 0 and 1. -/
noncomputable def startLoad : St LSt :=
  ⟨Host.Load.Run.Tpl.D1Body.s0.heap, Host.Load.Run.Tpl.D1Body.s0.next,
    Host.Load.Run.Tpl.D1Body.s0.ctl, Host.Load.Run.Tpl.D1Body.s0.stack,
    ⟨Host.Load.Run.Tpl.D1Body.s0.aux.jobs, Host.Load.Layers.toLoad Host.Load.Run.Tpl.D1Body.s0.aux.ffi,
      Host.Load.Run.Tpl.D1Body.s0.aux.trace, Host.Load.Run.Tpl.D1Body.s0.aux.stores⟩⟩
noncomputable def endLoad : St LSt :=
  ⟨Host.Load.Run.Tpl.D1Post.s4.heap, Host.Load.Run.Tpl.D1Post.s4.next,
    Host.Load.Run.Tpl.D1Post.s4.ctl, Host.Load.Run.Tpl.D1Post.s4.stack,
    ⟨Host.Load.Run.Tpl.D1Post.s4.aux.jobs, Host.Load.Layers.toLoad Host.Load.Run.Tpl.D1Post.s4.aux.ffi,
      Host.Load.Run.Tpl.D1Post.s4.aux.trace, Host.Load.Run.Tpl.D1Post.s4.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`endSrv, ``Host.Load.Run.Tpl.D1Post.S4),
      (`startSrv, ``Host.Load.Run.Tpl.D1Body.S0), (`envSrv, ``Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

theorem endSrv_eq : endSrv = Host.Load.Run.Tpl.D1Post.S4 := rfl
theorem startSrv_eq : startSrv = Host.Load.Run.Tpl.D1Body.S0 := rfl

def NL : Nat := 15235
def N0 : Nat := 15235
def tokenNode : Nat := 15235
def fixedBigs : List Int := [5554869888]

def coldCls (S : SSrv) (x : NumV) : Option PDim :=
  coldClass S x

noncomputable def Gs : Nat → Option (RNode PDim InKey) :=
  restrictTo (exactTplDom NL N0 fixedBigs endLoad.ffi.mlx)
    (ffiGraph (coldNums endSrv) SourceKernels.sources endLoad.ffi.mlx)

end Host.Ts.Sim.Compose.ColdGraph
