import host.load.growth.Graph
import host.mlx.GraphStability
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 1000000

namespace Host.Load.Growth
open Host.Mlx Host.Mlx.FfiEval
open Inference.Contracts.Mlx

/-- The same two cache updates, ordered to reuse the existing checked
one-tensor graph builder. The carrier certificate below accounts for the
source method allocating both zero buffers before either concatenate. -/
def valueBuilder (capacity : Nat) : Build Int (Fin 4) (Nat × Nat × Nat × Nat) := do
  let key ← inp 2
  let value ← inp 3
  let keys ← kvStepG id capacity (capacity : Int) ((capacity : Int) + 1) (some capacity) 0 key
  let values ← kvStepG id capacity (capacity : Int) ((capacity : Int) + 1) (some capacity) 1 value
  pure (keys.1, values.1, keys.2, values.2)

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : Env (Fin 4))

theorem valueBuilder_spec (capacity : Nat) (oldK oldV key value bK bV vK vV : Value)
    (hK : oldK.shape = [1,4,capacity,256]) (hV : oldV.shape = [1,4,capacity,256])
    (inputs : env.inputs 0 = some oldK ∧ env.inputs 1 = some oldV ∧
      env.inputs 2 = some key ∧ env.inputs 3 = some value)
    (stepK : GlueKv.step (some oldK) capacity key = some (bK,vK))
    (stepV : GlueKv.step (some oldV) capacity value = some (bV,vV)) :
    Spec (valueBuilder capacity) [] (fun out graph => ∃ viewK viewV,
      AllEv M K env graph [(out.1,bK),(out.2.1,bV),(out.2.2.1,viewK),(out.2.2.2,viewV)] ∧
      SameIn viewK vK ∧ SameIn viewV vV) := by
  have shapeK : BufShape (some oldK) := by
    intro v hv
    cases Option.some.inj hv
    rw [hK]
    rfl
  have shapeV : BufShape (some oldV) := by
    intro v hv
    cases Option.some.inj hv
    rw [hV]
    rfl
  have capK : capOf (some oldK) = some capacity := by simp [capOf,hK]
  have capV : capOf (some oldV) = some capacity := by simp [capOf,hV]
  have empty : AllEv M K env [] [] := by intro p hp; cases hp
  unfold valueBuilder
  refine spec_inp M K env empty inputs.2.2.1 fun g1 keyId h1 => ?_
  refine spec_inp M K env h1 inputs.2.2.2 fun g2 valueId h2 => ?_
  have ks := kvStepG_spec M K env capacity (some oldK) shapeK 0
    (fun v hv => by cases Option.some.inj hv; exact inputs.1)
    g2 _ h2 keyId key (by simp) bK vK stepK
  rw [capK] at ks
  refine spec_seq ks fun keyOut g3 ⟨viewK,h3,sameK⟩ => ?_
  have vs := kvStepG_spec M K env capacity (some oldV) shapeV 1
    (fun v hv => by cases Option.some.inj hv; exact inputs.2.1)
    g3 _ h3 valueId value (by simp) bV vV stepV
  rw [capV] at vs
  refine spec_seq vs fun valueOut g4 ⟨viewV,h4,sameV⟩ => ?_
  exact spec_pure ⟨viewK,viewV,h4.mono M K env (by
    intro p hp
    simp only [List.mem_cons] at hp ⊢
    tauto),sameK,sameV⟩

end

theorem tensor4_of_sameIn {a b : Value} (h : SameIn a b)
    (typed : Tensor4 b heads rows cols f) : Tensor4 a heads rows cols f := by
  refine ⟨h.1.trans typed.1,h.2.1.trans typed.2.1,?_⟩
  intro head row col
  rw [h.2.2 _ (by rw [h.2.1,typed.2.1]; exact within4 Nat.zero_lt_one head.isLt row.isLt col.isLt)]
  exact typed.2.2 head row col

end Host.Load.Growth

namespace Host.Load.Run.Full.Growth256
open Host.Mlx Host.Mlx.FfiEval

def valueExpected : List (RNode Int (Fin 4)) := (FfiEval.run (Growth.valueBuilder 256) []).2

noncomputable def valueCarriers : List Nat :=
  [roots.newKey.node,roots.newValue.node,roots.oldKey.node,
   22672,22674,22676,22678,roots.oldValue.node,22673,22675,22677,22679]

theorem value_graph_matches (sources : KernelSources) (table : List Host.Ts.F64) :
    Matches (actual sources table) valueExpected valueCarriers = true := by rfl

theorem value_output_carriers :
    certAt valueCarriers 5 = outcome.bufferKey.node ∧ certAt valueCarriers 10 = outcome.bufferValue.node ∧
    certAt valueCarriers 6 = outcome.fetchedKey.node ∧ certAt valueCarriers 11 = outcome.fetchedValue.node := by
  exact ⟨rfl,rfl,rfl,rfl⟩

private theorem valueExpected_literal : valueExpected =
  [⟨.input 2,[]⟩,⟨.input 3,[]⟩,⟨.input 0,[]⟩,
   ⟨.zeros [1,4,256,256] 12,[]⟩,⟨.concat 2,[2,3]⟩,
   ⟨.sliceUpdate [0,0,256,0] [1,4,257,256] [1,1,1,1],[4,0]⟩,
   ⟨.slice [0,0,0,0] [1,4,257,256] [1,1,1,1],[5]⟩,
   ⟨.input 1,[]⟩,⟨.zeros [1,4,256,256] 12,[]⟩,⟨.concat 2,[7,8]⟩,
   ⟨.sliceUpdate [0,0,256,0] [1,4,257,256] [1,1,1,1],[9,1]⟩,
   ⟨.slice [0,0,0,0] [1,4,257,256] [1,1,1,1],[10]⟩] := by rfl

noncomputable def inputCarrier (key : Fin 4) : Nat :=
  match key.val with
  | 0 => roots.oldKey.node
  | 1 => roots.oldValue.node
  | 2 => roots.newKey.node
  | _ => roots.newValue.node

section
open Inference.Contracts.Mlx
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env (Fin 4)) (sources : KernelSources) (table : List Host.Ts.F64)

/-- Expected inputs are defined by evaluation of the four incoming real
carriers. Actual FFI graphs do not read expected-graph input placeholders. -/
noncomputable def incomingEnv : Env (Fin 4) :=
  { weights := env.weights, inputs := fun key => evalR M K env (actual sources table) (inputCarrier key) }

theorem incoming_inputs_held :
    InputsHeld M K (incomingEnv M K env sources table) (actual sources table) valueExpected valueCarriers := by
  intro i e key he hp
  obtain ⟨hi,_⟩ := List.getElem?_eq_some_iff.mp he
  have bound : i < 12 := by simpa only [valueExpected_literal,List.length_cons,List.length_nil] using hi
  rw [valueExpected_literal] at he
  have cases : i=0 ∨ i=1 ∨ i=2 ∨ i=3 ∨ i=4 ∨ i=5 ∨ i=6 ∨ i=7 ∨ i=8 ∨ i=9 ∨ i=10 ∨ i=11 := by omega
  rcases cases with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;>
    simp only [List.getElem?_cons_zero,List.getElem?_cons_succ] at he <;>
    cases Option.some.inj he <;> cases hp
  all_goals
    change evalR M K (incomingEnv M K env sources table) (actual sources table) _ =
      evalR M K env (actual sources table) _
    exact evalFfi_inputs M K (incomingEnv M K env sources table) env rfl
      (concrete (Host.Ts.CSrv.val ⟨table⟩)) sources s5.ffi.mlx _

/-- Cache contents at the four incoming carriers suffice for all four real
growth outputs. No whole `InputsHeld`, output value, or zero-buffer premise is
assumed. Transporting the caller's cache invariant to this method entry is a
separate source-invariant obligation. -/
theorem outputs_of_contents
    (keys values : Fin 4 → Fin 256 → Fin 256 → BF)
    (key value : Fin 4 → Fin 256 → BF)
    (contents : Growth.Contents (evalR M K env (actual sources table)) roots keys values key value) :
    ∃ bK bV vK vV,
      evalR M K env (actual sources table) outcome.bufferKey.node = some bK ∧
      evalR M K env (actual sources table) outcome.bufferValue.node = some bV ∧
      evalR M K env (actual sources table) outcome.fetchedKey.node = some vK ∧
      evalR M K env (actual sources table) outcome.fetchedValue.node = some vV ∧
      GlueKv.State (some bK) 257 (fun h t i => Inference.State.Kv.appendRows (fun s => keys h s i) (key h i) t) ∧
      GlueKv.State (some bV) 257 (fun h t i => Inference.State.Kv.appendRows (fun s => values h s i) (value h i) t) ∧
      Tensor4 vK 4 257 256 (fun h t i => Inference.State.Kv.appendRows (fun s => keys h s i) (key h i) t) ∧
      Tensor4 vV 4 257 256 (fun h t i => Inference.State.Kv.appendRows (fun s => values h s i) (value h i) t) := by
  obtain ⟨oldK,oldV,k,v,hOldK,hOldV,hK,hV,holdsK,holdsV,typedK,typedV⟩ := contents
  obtain ⟨bK,vK,stepK,stateK,viewK⟩ := GlueKv.step_correct (some oldK) keys
    ⟨256,rfl,holdsK⟩ k key typedK
  obtain ⟨bV,vV,stepV,stateV,viewV⟩ := GlueKv.step_correct (some oldV) values
    ⟨256,rfl,holdsV⟩ v value typedV
  let inputEnv := incomingEnv M K env sources table
  have inputs : inputEnv.inputs 0 = some oldK ∧ inputEnv.inputs 1 = some oldV ∧
      inputEnv.inputs 2 = some k ∧ inputEnv.inputs 3 = some v := ⟨hOldK,hOldV,hK,hV⟩
  have spec := Growth.valueBuilder_spec M K inputEnv 256 oldK oldV k v bK bV vK vV
    holdsK.2.1 holdsV.2.1 inputs stepK stepV
  change ∃ keyView valueView,
    AllEv M K inputEnv valueExpected [(5,bK),(10,bV),(6,keyView),(11,valueView)] ∧
    SameIn keyView vK ∧ SameIn valueView vV at spec
  obtain ⟨keyView,valueView,hevals,sameK,sameV⟩ := spec
  have transfer (i : Nat) (hi : i < valueExpected.length) (v : Value)
      (hv : evalR M K inputEnv (listGraph valueExpected) i = some v) :
      evalR M K env (actual sources table) (certAt valueCarriers i) = some v := by
    have carried := (matches_eval M K inputEnv (actual sources table) valueExpected valueCarriers
      (value_graph_matches sources table) (incoming_inputs_held M K env sources table) i hi).trans hv
    exact (evalFfi_inputs M K env inputEnv rfl _ sources s5.ffi.mlx _).trans carried
  refine ⟨bK,bV,keyView,valueView,?_,?_,?_,?_,stateK,stateV,
    Growth.tensor4_of_sameIn sameK viewK,Growth.tensor4_of_sameIn sameV viewV⟩
  · exact transfer 5 (by decide) bK (hevals (5,bK) (by simp)).2
  · exact transfer 10 (by decide) bV (hevals (10,bV) (by simp)).2
  · exact transfer 6 (by decide) keyView (hevals (6,keyView) (by simp)).2
  · exact transfer 11 (by decide) valueView (hevals (11,valueView) (by simp)).2

end

end Host.Load.Run.Full.Growth256
