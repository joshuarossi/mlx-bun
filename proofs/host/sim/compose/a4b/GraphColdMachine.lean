import host.sim.compose.a4b.GraphColdFullExpected
import host.sim.compose.a4b.GraphColdExact
import host.sim.compose.a4b.GraphColdInputs
import host.sim.compose.a4b.GraphColdInputValue
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-- The complete cold D1 template, including all64 layers and the real head/sampler suffix. -/
noncomputable def T : PromptTemplate fullFamily where
  o₀ := 0
  n₀ := 1
  ss₀ := stages
  Gs := Gs
  cert := choice.cert
  checked := by rw [← full_expected_family]; exact check.matches
  length := by rw [← full_expected_family]; exact cert_length

theorem cold_empty (σ : Nat → Nat) : EmptyCacheInputs (loadedAt σ cacheInputs) := by
  intro p s hp
  have hlt : p < 64 := (List.getElem?_eq_some_iff.mp hp).choose
  refine ⟨cacheAt σ (none, none), ?_, rfl, rfl⟩
  simp only [loadedAt, cachesAt, cacheInputs, List.getElem?_map, List.getElem?_replicate, hlt, ↓reduceIte, Option.map_some]

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Cold input values follow from the loaded parameters and the actual moving
input carrier. The producer-based theorem below supplies the token evaluation. -/
theorem input_values (value : TensorValues) (ids : Value)
    (weightsEnv : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey))
    (σ : Nat → Nat) (_hfix : ∀ j, j < 15235 → σ j = j)
    (hp : ∀ t, t ∈ parameterTensors parameterChoice →
      evalR M K (stepEnvWithIds weightsEnv (weights value) ids initialHandles) G t.node = some (value t))
    (ht : evalR M K (stepEnvWithIds weightsEnv (weights value) ids initialHandles) G (σ tokenNode) = some ids)
    (E : List (RNode Int InKey))
    (hm : inputCarriersMatch E (choice.cert.map σ)
      (inputNode (loadedAt σ cacheInputs) (tensorAt (σ tokenNode))) = true) :
    InputsHeld M K (stepEnvWithIds weightsEnv (weights value) ids initialHandles) G E (choice.cert.map σ) := by
  apply inputsHeld_initial M K (loadedAt σ cacheInputs) (tensorAt (σ tokenNode)) value _ G E _
    (cold_empty σ) hp
  · intro key hk
    exact initial_input_values value ids key hk
  · exact ht
  · exact hm


/-- The accepted producer's actual target input fact discharges the moving
input evaluation premise for an arbitrary singleton vocabulary token. -/
theorem input_values_of_inputAt (value : TensorValues)
    (weightsEnv : List Char → List Char → Option Value) (σ : Nat → Nat)
    (t : St Full.FF.S) (Cs : CSrv) (token : Nat) (hvocab : token < 248320)
    (hinput : SetupD1Input.InputAt [token] (σ tokenNode) t Cs)
    (hfix : ∀ j, j < 15235 → σ j = j)
    (hp : ∀ u, u ∈ parameterTensors parameterChoice →
      evalR M K (stepEnvWithIds weightsEnv (weights value) (coldIds token) initialHandles)
        (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) u.node = some (value u))
    (E : List (RNode Int InKey))
    (hm : inputCarriersMatch E (choice.cert.map σ)
      (inputNode (loadedAt σ cacheInputs) (tensorAt (σ tokenNode))) = true) :
    InputsHeld M K (stepEnvWithIds weightsEnv (weights value) (coldIds token) initialHandles)
      (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) E (choice.cert.map σ) ∧
      TokenBuffer (coldIds token) token := by
  have htok := inputAt_singleton M K
    (stepEnvWithIds weightsEnv (weights value) (coldIds token) initialHandles) SourceKernels.sources hvocab hinput
  exact ⟨input_values M K value (coldIds token) weightsEnv _ σ hfix hp htok.1 E hm, htok.2⟩

/-- The complete actual cold graph is carried at arbitrary target maps.
No output value, future graph or execution premise is added. -/
theorem «matches» (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : LSt)
    (hR : G.LoadR P NB Mp n endLoad.ffi y) (hband : P.NL = P.N0)
    (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? endSrv.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888) (ν : Nat → Int) :
    Matches (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx)
      (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node) = true := by
  exact matches_embed _ _ (graph_embedding table P NB Mp n y hR hband ρ hρ hnum hrope ν)
    (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) choice.cert (by rw [List.length_map]; exact cert_length)
    (matchesD_map (PDim.eval ν) Gs fullExpected.1 choice.cert check.matches)

/-- All input carriers survive mapping; parameters retain their actual prefix bound. -/
theorem inputs (σ : Nat → Nat) (hfix : ∀ j, j < 15235 → σ j = j) (ν : Nat → Int) :
    inputCarriersMatch (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map σ)
      (inputNode (loadedAt σ cacheInputs) (tensorAt (σ tokenNode))) = true := by
  apply inputCarriers_embed _ choice.cert (by rw [List.length_map]; exact cert_length)
    insT (inputNode (loadedAt σ cacheInputs) (tensorAt (σ tokenNode))) (input_carriers σ hfix)
  rw [inputCarriersMatch_map]
  exact check.inputs

/-- The real general relation supplies the fixed parameter-prefix premise. -/
theorem native_inputs (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : LSt)
    (hR : G.LoadR P NB Mp n endLoad.ffi y) (hNB : 15235 ≤ NB) (ν : Nat → Int) :
    inputCarriersMatch (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node)
      (inputNode (loadedAt Mp.node cacheInputs) (tensorAt (Mp.node tokenNode))) = true :=
  inputs Mp.node (fun j hj => hR.mlx.nid j (Nat.lt_of_lt_of_le hj hNB)) ν

/-- Map all64 graph-carrier pairs. cachesAt supplies carrier metadata; actual
numeric heap offsets are checked separately in GraphColdCacheValues. No target
offset assertion follows from cachesAt alone. -/
theorem output_pairs (σ : Nat → Nat) :
    (cachesAt σ choice.outputs).map cacheNodePair = fullExpected.2.2.map
      (fun (a,b) => (some (σ (certAt choice.cert a)), some (σ (certAt choice.cert b)))) := by
  rw [cachesAt_nodes, outputs_check, List.map_map]
  rfl
end Host.Ts.Sim.Compose.ColdGraph
