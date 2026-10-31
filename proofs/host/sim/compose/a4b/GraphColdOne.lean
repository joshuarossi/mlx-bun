import host.sim.compose.a4b.GraphColdOnePrefix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph.One
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Run.Tpl
open _root_.Host.Load.Extract _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

noncomputable def prefixDom (i : Nat) : Bool :=
  exactTplDom NL N0 fixedBigs endLoad.ffi.mlx i && decide (i < 17777)

theorem restrict_inter {δ κ : Type} (D E : Nat → Bool) (G : Nat → Option (RNode δ κ)) :
    restrictTo D (restrictTo E G) = restrictTo (fun i => E i && D i) G := by
  funext i
  cases hd : D i <;> cases he : E i <;> simp only [restrictTo, hd, he] <;> rfl

theorem prefix_graph : prefixGs = restrictTo prefixDom
    (ffiGraph (coldNums endSrv) SourceKernels.sources endLoad.ffi.mlx) := by
  exact restrict_inter (fun i => decide (i < 17777))
    (exactTplDom NL N0 fixedBigs endLoad.ffi.mlx)
    (ffiGraph (coldNums endSrv) SourceKernels.sources endLoad.ffi.mlx)

theorem image_common {P : LoadP} {NB : Nat} {Mp : Map} {n : Nat} {s s' y : Ffi.St}
    (hR : G.MR P NB Mp n s' y) (D : Nat → Bool)
    (hD : ∀ i, D i = true → Full P i)
    (hc : ∀ i, D i = true → s'.nodes.get i = s.nodes.get i)
    (he : ∀ i nd, D i = true → s.nodes.get i = some nd → G.shapeOnly nd = false) :
    NativeImage Mp.node (numImg Mp.nv Mp.big Mp.arg Mp.handle) D s y := by
  have image := nativeImage_of_GMR hR D hD
    (fun i nd hi hn => he i nd hi (by rw [← hc i hi]; exact hn))
  exact ⟨fun i nd hi hn => image.nodes i nd hi (by rw [hc i hi]; exact hn),
    fun i j hi hn hj => image.order i j hi (by rw [hc i hi]; exact hn) hj⟩

/-- The image is obtained directly from the actual One native relation. -/
theorem native_image (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hband : P.NL = P.N0) :
    NativeImage Mp.node (numImg Mp.nv Mp.big Mp.arg Mp.handle) prefixDom endLoad.ffi.mlx y := by
  have bound : ∀ i, prefixDom i = true → i < 17777 := by
    intro i hi
    exact of_decide_eq_true (Bool.and_eq_true_iff.mp hi).2
  exact image_common (s := endLoad.ffi.mlx) (s' := native) hR prefixDom
    (fun i _ => full_of_band_free P hband i)
    (fun i hi => common_nodes i (bound i hi))
    (fun _ _ hi hn => source_exact (Bool.and_eq_true_iff.mp hi).1 hn)

/-- Ordinary numerical agreement is over the actual One table; its retained prefix
supplies precisely the old symbolic numbers needed by the frozen cold graph. -/
theorem embedding_prefix (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hband : P.NL = P.N0)
    (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOne.S10.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888) (ν : Nat → Int) :
    Embeds Mp.node Mp.handle (mapG (PDim.eval ν) prefixGs)
      (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y) := by
  rw [prefix_graph]
  exact embeds_cold_image endSrv ρ hρ ν
    SourceKernels.sources endLoad.ffi.mlx y prefixDom
    (CSrv.val ⟨table⟩) Mp.nv Mp.big Mp.arg Mp.handle Mp.node
    (nv_lit Mp) (fun _ => rfl)
    (numbers_agree endSrv ρ Mp.nv (CSrv.val ⟨table⟩) (nv_lit Mp) (fun _ => rfl)
      (fun i e he => hnum i e (table_prefix i e he)))
    (fun a => okArg fixedBigs a = true)
    (arg_fixed Mp fixedBigs (by simp [fixedBigs, hrope]))
    (fun _ _ hi hn => exactTplDom_args (Bool.and_eq_true_iff.mp hi).1 hn)
    (fun k name hk => kernels_of_GMR hR SourceKernels.sources k name
      (by rw [kernel_names]; exact hk))
    (native_image P NB Mp n y hR hband)

theorem «matches» (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hband : P.NL = P.N0)
    (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOne.S10.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888) (ν : Nat → Int) :
    Matches (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y)
      (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node) = true := by
  have hlen : (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))).length ≤ choice.cert.length := by
    rw [List.length_map]
    exact cert_length
  have hchecked : Matches (mapG (PDim.eval ν) prefixGs)
      (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) choice.cert = true :=
    matchesD_map (PDim.eval ν) prefixGs fullExpected.1 choice.cert prefix_checked
  exact matches_embed (σ := Mp.node) (cl := Mp.handle)
    (mapG (PDim.eval ν) prefixGs)
    (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y)
    (embedding_prefix table P NB Mp n y hR hband ρ hρ hnum hrope ν)
    (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) choice.cert
    hlen hchecked

theorem native_inputs (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hNB : 15235 ≤ NB) (ν : Nat → Int) :
    inputCarriersMatch (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node)
      (inputNode (loadedAt Mp.node cacheInputs) (tensorAt (Mp.node tokenNode))) = true := by
  have hfix : ∀ j, j < 15235 → Mp.node j = j :=
    fun j hj => hR.nid j (Nat.lt_of_lt_of_le hj hNB)
  exact ColdGraph.inputs Mp.node hfix ν

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

theorem input_values_of_inputAt (value : TensorValues)
    (weightsEnv : List Char → List Char → Option Value)
    (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (t : St Full.FF.S) (Cs : CSrv)
    (hR : G.MR P NB Mp n native (Full.mlxOf t.ffi)) (hNB : 15235 ≤ NB)
    (token : Nat) (hvocab : token < 248320)
    (hinput : SetupD1Input.InputAt [token] (Mp.node tokenNode) t Cs)
    (hp : ∀ u, u ∈ parameterTensors parameterChoice →
      evalR M K (stepEnvWithIds weightsEnv (weights value) (coldIds token) initialHandles)
        (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) u.node = some (value u))
    (ν : Nat → Int) :
    InputsHeld M K (stepEnvWithIds weightsEnv (weights value) (coldIds token) initialHandles)
      (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi))
      (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node) ∧
      TokenBuffer (coldIds token) token := by
  have hfix : ∀ j, j < 15235 → Mp.node j = j :=
    fun j hj => hR.nid j (Nat.lt_of_lt_of_le hj hNB)
  have hm : inputCarriersMatch (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν)))
      (choice.cert.map Mp.node)
      (inputNode (loadedAt Mp.node cacheInputs) (tensorAt (Mp.node tokenNode))) = true :=
    native_inputs P NB Mp n (Full.mlxOf t.ffi) hR hNB ν
  exact ColdGraph.input_values_of_inputAt M K value weightsEnv Mp.node t Cs token hvocab hinput
    hfix hp (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) hm

end Host.Ts.Sim.Compose.ColdGraph.One
