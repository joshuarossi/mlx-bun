import host.sim.compose.a4b.GraphColdCert
import host.sim.compose.a4b.GraphColdEmbedding
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

/-- Exactness is checked by the source domain, including exclusion of the moving host-data input. -/
theorem source_exact {i : Nat} {nd : Ffi.Node}
    (hi : exactTplDom NL N0 fixedBigs endLoad.ffi.mlx i = true)
    (hn : endLoad.ffi.mlx.nodes.get i = some nd) : G.shapeOnly nd = false :=
  exactTplDom_exact hi hn

theorem coldCls_sound (S : SSrv) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1) (ν : Nat → Int) :
    ClsSoundD (coldCls S) (νsOf S ρ) (PDim.eval ν) :=
  coldClass_sound S ρ hρ ν

/-- The incoming band-free policy, retained by raising both cutoffs, covers every node. -/
theorem full_of_band_free (P : LoadP) (hband : P.NL = P.N0) (i : Nat) : Full P i := by
  unfold Full
  omega

/-- The complete frozen native graph embeds under the actual general native relation.
The numerical valuation is prompt length one; logical model time is not substituted for it. -/
theorem graph_embedding (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : LSt)
    (hR : G.LoadR P NB Mp n endLoad.ffi y) (hband : P.NL = P.N0)
    (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? endSrv.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888) (ν : Nat → Int) :
    Embeds Mp.node Mp.handle (mapG (PDim.eval ν) Gs)
      (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx) := by
  exact embeds_cold_image endSrv ρ hρ ν
    SourceKernels.sources endLoad.ffi.mlx y.mlx (exactTplDom NL N0 fixedBigs endLoad.ffi.mlx)
    (CSrv.val ⟨table⟩) Mp.nv Mp.big Mp.arg Mp.handle Mp.node
    (nv_lit Mp) (fun _ => rfl)
    (numbers_agree endSrv ρ Mp.nv (CSrv.val ⟨table⟩) (nv_lit Mp) (fun _ => rfl) hnum)
    (fun a => okArg fixedBigs a = true)
    (arg_fixed Mp fixedBigs (by simp [fixedBigs, hrope]))
    (fun _ _ hi hn => exactTplDom_args hi hn) (kernels_of_GMR hR.mlx SourceKernels.sources)
    (nativeImage_of_GMR hR.mlx _ (fun i _ => full_of_band_free P hband i)
      (fun _ _ hi hn => source_exact hi hn))
end Host.Ts.Sim.Compose.ColdGraph
