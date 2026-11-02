import host.sim.compose.a4b.GraphColdAgreement
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

theorem embeds_cold_image (S : SSrv) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1) (ν : Nat → Int)
    (Ks : KernelSources) (s t : Ffi.St) (D : Nat → Bool)
    (νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νsOf S ρ x = some f → νt (μ x) = some f)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds (κ := InKey) σ η (mapG (PDim.eval ν) (restrictTo D (ffiGraph (coldNums S) Ks s)))
      (ffiGraph (concrete νt) Ks t) where
  node := by
    intro i r hr
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : D i = true := by
      cases hd : D i
      · simp [restrictTo, hd] at h0
      · rfl
    simp only [restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    have h2 := resolveNode_img (cold_agree S ρ hρ ν νt μ β α η hlitμ hlitt hν A hα _ _ hk)
      σ nd r0 (hargs i nd hb hnd) hres
    show (t.nodes.get (σ i)).bind _ = _
    rw [himg.nodes i nd hb hnd, Option.bind_some]
    exact h2
  order i r hr j hj := by
    obtain ⟨hb, nd, hnd, hins⟩ := ins_of_restrict (PDim.eval ν) (coldNums S) Ks s D hr
    exact himg.order i nd hb hnd j (hins ▸ hj)
end Host.Ts.Sim.Compose.ColdGraph
