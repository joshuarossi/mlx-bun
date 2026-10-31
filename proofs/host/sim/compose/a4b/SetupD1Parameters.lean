import host.sim.template.a4pre_d1_input.ParameterSource
import host.sim.compose.a4b.SetupD1ParameterProofs
import host.sim.compose.a4b.GraphColdInputValue
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.SetupD1Parameters
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.GlueStep _root_.Host.Mlx.SimGraph.ColdParameters _root_.Host.Load.Run.Tpl

/-- A regular definition keeps the concrete source behind a single conversion boundary. -/
private noncomputable def nativeSource : NSt := D1ParameterSource.source

run_cmd Lean.logInfo "PHASE nativeSource_eq-start"
private theorem nativeSource_eq : nativeSource = mlxOf D1Call.s1.ffi := rfl

run_cmd Lean.logInfo "PHASE nativeSource_support-start"
private theorem nativeSource_support (i : Nat) (hi : i < code.length) :
    certAt code.cert i < 15235 ∧ ∃ nd, nativeSource.nodes.get (certAt code.cert i) = some nd ∧
      staticNode 15235 nd = true :=
  @D1ParameterSource.support i hi

run_cmd Lean.logInfo "PHASE nativeSource_matches-start"
private theorem nativeSource_matches (Cs : CSrv) :
    Matches (ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources nativeSource)
      (code.map Program.Node.erase) code.cert = true :=
  D1ParameterSource.load_matches Cs.tab SourceKernels.sources

run_cmd Lean.logInfo "PHASE source-wrappers-checked"

/-- The same accepted singleton-input witness supplies the load-program support.
The fixed band is exactly 15235; no arbitrary NB fixation is assumed. -/
theorem later_matches {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (t : St FF.S) (Cs : CSrv)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t.ffi)) :
    Matches (ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources (mlxOf t.ffi))
      (code.map Program.Node.erase) code.cert = true := by
  exact @SetupD1ParameterProofs.matches_of_cut code code.cert nativeSource T tk x D1Call.s1
    ⟨D1Call.S1.tab, []⟩ h nativeSource_eq nativeSource_support (mlxOf t.ffi) Cs
    (nativeSource_matches Cs) hg

run_cmd Lean.logInfo "PHASE later-matches-checked"

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Ordinary loaded-parameter evaluation on the actual later target. The body supplies
only operational growth from the accepted input witness. All parameter support is derived. -/
theorem later_parameters (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (t : St FF.S) (Cs : CSrv) (ids : Value)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t.ffi)) :
    ∀ u ∈ parameterTensors parameterChoice,
      evalR M K (stepEnvWithIds env.weights (weights (firstValues M K env table)) ids initialHandles)
        (ffiGraph (concrete Cs.val) SourceKernels.sources (mlxOf t.ffi)) u.node = some (firstValues M K env table u) :=
  parameter_values M K env table leaves (mlxOf t.ffi) Cs ids (@later_matches T tk x h t Cs hg)

run_cmd Lean.logInfo "PHASE later-parameters-checked"

/-- The input endpoint itself is the reflexive operational-growth case. -/
theorem input_parameters (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (ids : Value) :
    ∀ u ∈ parameterTensors parameterChoice,
      evalR M K (stepEnvWithIds env.weights (weights (firstValues M K env table)) ids initialHandles)
        (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi)) u.node = some (firstValues M K env table u) :=
  later_parameters M K env table leaves h x.t x.C ids (.refl _)
run_cmd Lean.logInfo "PHASE input-parameters-checked"

/-- Exactly the ordinary parameter premise consumed by ColdGraph.input_values_of_inputAt. -/
theorem cold_parameters (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (t : St FF.S) (Cs : CSrv) (token : Nat)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t.ffi)) :
    ∀ u ∈ parameterTensors parameterChoice,
      evalR M K (stepEnvWithIds env.weights (weights (firstValues M K env table)) (ColdGraph.coldIds token) initialHandles)
        (ffiGraph (concrete Cs.val) SourceKernels.sources (mlxOf t.ffi)) u.node = some (firstValues M K env table u) :=
  later_parameters M K env table leaves h t Cs (ColdGraph.coldIds token) hg
run_cmd Lean.logInfo "PHASE cold-parameters-checked"
end Host.Ts.Sim.Compose.SetupD1Parameters
