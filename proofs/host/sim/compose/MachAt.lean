import host.sim.compose.Mach
import host.simgraph.world.MachAt
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph _root_.Host.Ts
open _root_.Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt)
open _root_.Host.Mlx.SimGraph.Mach (MRef MRefDecodes WeightShapes template_cached_forwardM compat_of_caps shapesOk_of_caps)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey)
section
variable {Wd : World} (pr : GraphProj Wd)

/-- The original template obligation at one explicitly selected fixed prefix. -/
def CaseTplAtM (A : Sim.Addr) (I : TplInputs) (L : Nat) (s1 : Wd.F.S) (S1tab : List SymE) (outT : Nat)
    (outs : List (Option Nat × Option Nat)) (i NB : Nat) : Prop :=
  ∀ (tab : List F64) (P' : Sim.LoadP) (Mp : Sim.Map) (n : Nat) (y : Wd.F.S) (ν : Nat → F64),
    Sim.G.LoadR P' NB Mp n (pr.toLoad s1) (pr.toLoad y) → P'.NL = A.NL → P'.N0 = A.N0 →
    ν A.tvar = F64.ofNat (L + i + 1) →
    (∀ j e, nth? S1tab j = some e → CSrv.val ⟨tab⟩ (Mp.nv (.ref j)) = some (e.eval ν)) →
    Mp.big (A.rope : Int) = (A.rope : Int) →
    ∃ (l : Loaded) (token : Tensor) (T : Template (weights (firstValues M K env tab))) (σ cl : Nat → Nat),
      l.model = parameterChoice.model ∧ l.cache = cachesAt Mp.node I.caches ∧
      Gr tab (Wd.toMlx y) token.node = some ⟨.reshape [1,1], [Mp.node I.fed]⟩ ∧ Mp.node I.fed < token.node ∧
      kvSig (some T.c₀) T.n₀ = kvSig (some (Sim.capL (L + i + 1))) (L + i + 1) ∧
      Embeds σ cl (mapG (SDim.eval (L + i + 1)) T.Gs) (Gr tab (Wd.toMlx y)) ∧
      (∀ hs, CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs →
        inputCarriersMatch (stepGraphOf (weights (firstValues M K env tab)) hs (L + i + 1)).1 (T.cert.map σ)
          (inputNode l token) = true) ∧
      (cachesAt Mp.node outs).map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
        (templateOf (weights (firstValues M K env tab)) T.hs₀ T.n₀).2.2.map
          (fun (a, b) => (some (σ (certAt T.cert a)), some (σ (certAt T.cert b)))) ∧
      σ (certAt T.cert (templateOf (weights (firstValues M K env tab)) T.hs₀ T.n₀).2.1) = Mp.node outT

theorem caseTplM_iff_at (A : Sim.Addr) (I : TplInputs) (L : Nat)
    (s1 : Wd.F.S) (S1tab : List SymE) (outT : Nat)
    (outs : List (Option Nat × Option Nat)) (i : Nat) :
    CaseTplM M K env pr A I L s1 S1tab outT outs i ↔
      ∀ NB, CaseTplAtM M K env pr A I L s1 S1tab outT outs i NB := by
  constructor
  · intro h NB tab P' Mp n y ν
    exact h tab P' NB Mp n y ν
  · intro h tab P' NB Mp n y ν
    exact h NB tab P' Mp n y ν

theorem caseFwdAtM_of_tpl (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {R : MRef}
    {L0 : Nat} (hdec : MRefDecodes M K (fun tab => weights (firstValues M K env tab)) R L0)
    (hW : ∀ tab, WeightShapes (stageWeights (weights (firstValues M K env tab)))) {A : Sim.Addr} {I : TplInputs}
    {L NB : Nat} {s1 : Wd.F.S} {S1tab : List SymE} {outT : Nat} {outs : List (Option Nat × Option Nat)} {i : Nat}
    (hL : L0 ≤ L + i + 1) (h : CaseTplAtM M K env pr A I L s1 S1tab outT outs i NB) :
    CaseFwdAtM M K env pr A I R L s1 S1tab outT outs i NB := by
  intro tab P' Mp n y ν hld hNL hN0 htv hnum hrope tok hs tok' hs' hR1 hR2 hb hcaps hcv hfed hpar
  obtain ⟨l, token, T, σ, cl, hm, hlc, hfb, hea, hbr, hemb, hin, hout, htout⟩ := h tab P' Mp n y ν hld hNL hN0 htv
    hnum hrope
  have hstep : stepTrace M K (weights (firstValues M K env tab)) (L + i + 1) tok hs = some (tok', hs') := by
    have h1 := hdec tab (L + i + 1) hL
    rw [show L + i + 1 + 1 = L + i + 2 by omega, hR2, hR1] at h1
    exact h1.symm
  obtain ⟨h1, h2, h3⟩ := template_cached_forwardM M K env leaves typed tab (L + i + 1) (Wd.toMlx y) l token
    (Mp.node I.fed) (Mp.node outT) tok tok' hs hs' (cachesAt Mp.node outs) (Sim.capL (L + i + 1)) hstep hb
    (compat_of_caps hcaps) (shapesOk_of_caps _ _ (hW tab) hcaps) T σ cl hm hpar hcaps hbr (by rw [hlc]; exact hcv) hfb hea hfed
    hemb (hin hs hcaps) hout htout
  refine ⟨h1, h2, ?_⟩
  rw [kvCap_capL_succ] at h3
  exact h3

variable {A : Sim.Addr} {P : Wd.Par} {W : Nat → Option Sim.WFrame} {Fr : Sim.LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA : List Nat} {I : TplInputs} {R : MRef} {L : Nat} {ρ : Nat → F64} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV}

/-- Lift at the actual prefix of the world without quantifying over unrelated prefixes. -/
theorem loopG_ofAtM (st : StartGM pr A P s0 tab0 I) {e : Prefill.IterEndW Wd A P s0 tab0 fixA} (g : Prefill.GhostP)
    (en : EndGM I e) (hAt : A.tvar = 9) (hAk : A.kvar = 14) {i : Nat}
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (fwd : CaseFwdAtM M K env pr A I R L e.s1.ffi e.S1.tab en.outT en.outs i (pr.NB P)) :
    Prefill.LoopGStepGW (liftG Wd (GxM M K env I R L)) W Fr e g (Sim.valL ρ T tk L) toks i :=
  gstep_ofGAtM M K env pr st.hPNL st.hPN0 st.hPE st.hrope e g R L (Sim.valL ρ T tk L) tk toks i I en.outT en.outs htk
    htkb (fun _ => by rw [hAt]; rfl) (fun _ => by rw [hAk]; rfl) st.htv st.carR st.carF st.carC fwd en.read en.fed
    en.caches st.sread st.pread en.h1read en.h1pread st.s0tok en.s1tok st.tokv en.pout en.pouts

end
end Host.Ts.Sim.Compose
