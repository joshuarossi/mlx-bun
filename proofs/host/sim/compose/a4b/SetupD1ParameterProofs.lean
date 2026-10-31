import host.simgraph.ColdParameters
import host.sim.compose.a4b.SetupD1Values
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.SetupD1ParameterProofs
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.GlueStep _root_.Host.Mlx.SimGraph.ColdParameters _root_.Host.Load.Run.Tpl

/-- Additive locality transport over abstract native states. The concrete producer
below supplies every source-support premise from its checked finite source. -/
theorem matches_of_MR_grow (p : Program.Code) (cert : List Nat) {P : LoadP} {Mp : Map} {n : Nat} {source input target : NSt}
    (mr : G.MR P 15235 Mp n source input)
    (support : ∀ i, i < p.length → certAt cert i < 15235 ∧
      ∃ nd, source.nodes.get (certAt cert i) = some nd ∧ staticNode 15235 nd = true)
    (Cs : CSrv)
    (matched : Matches (ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources source)
      (p.map Program.Node.erase) cert = true)
    (hg : Host.Mlx.Ffi.NGrow input target) :
    Matches (ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources target)
      (p.map Program.Node.erase) cert = true := by
  apply matches_transfer p cert _ _ matched
  intro i hil
  obtain ⟨hj, nd, hnd, hs⟩ := support i hil
  have hy : input.nodes.get (certAt cert i) = some nd := node_of_MR mr hj hnd hs
  have hp : PN source (certAt cert i) := by
    change (source.nodes.get (certAt cert i)).isSome = true
    rw [hnd]
    rfl
  have hlt := mr.nimg _ hp
  rw [mr.nid _ hj] at hlt
  have ht : target.nodes.get (certAt cert i) = some nd := (hg.nodes _ hlt).trans hy
  calc
    ffiGraph (concrete Cs.val) SourceKernels.sources target (certAt cert i) =
        resolveNode (concrete Cs.val) (kernelName? SourceKernels.sources target) nd :=
      congrArg (fun (q : Option Ffi.Node) => q.bind (resolveNode (κ := InKey) (concrete Cs.val) (kernelName? SourceKernels.sources target))) ht
    _ = resolveNode (concrete Cs.val) (kernelName? SourceKernels.sources source) nd :=
      resolve_static Cs Cs _ _ 15235 nd hs
    _ = ffiGraph (concrete Cs.val) SourceKernels.sources source (certAt cert i) :=
      (congrArg (fun (q : Option Ffi.Node) => q.bind (resolveNode (κ := InKey) (concrete Cs.val) (kernelName? SourceKernels.sources source))) hnd).symm


run_cmd Lean.logInfo "PHASE abstract-MR-transport-checked"

/-- Extract and transport under abstract source states before any concrete source is applied. -/
theorem matches_of_cut (p : Program.Code) (cert : List Nat) (source : NSt)
    {T : Nat} {tk : Nat → Nat} {x : SegInst FF} {s : St FF.S} {S : SSrv}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x s S)
    (source_eq : source = mlxOf s.ffi)
    (support : ∀ i, i < p.length → certAt cert i < 15235 ∧
      ∃ nd, source.nodes.get (certAt cert i) = some nd ∧ staticNode 15235 nd = true)
    (target : NSt) (Cs : CSrv)
    (matched : Matches (ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources source)
      (p.map Program.Node.erase) cert = true)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) target) :
    Matches (ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources target)
      (p.map Program.Node.erase) cert = true := by
  cases source_eq
  obtain ⟨π, K0, hr, hb, hi, hv⟩ := h
  obtain ⟨P', hP, hn⟩ := hr.ffi.1
  exact @matches_of_MR_grow p cert P' x.M S.tab.length (mlxOf s.ffi) (mlxOf x.t.ffi) target
    hn.load.mlx support Cs matched hg
run_cmd Lean.logInfo "PHASE abstract-cut-transport-checked"
end Host.Ts.Sim.Compose.SetupD1ParameterProofs
