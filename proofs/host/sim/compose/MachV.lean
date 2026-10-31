import host.sim.compose.MachAt
import host.simgraph.world.MachAtV
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph _root_.Host.Ts
open _root_.Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt)
open _root_.Host.Mlx.SimGraph.Mach (MRef MRefDecodes WeightShapes template_cached_forwardV compat_of_caps
  shapesOk_of_caps Vals routeVals)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The decode route's graph lifts at the route's values

`caseFwdAtV_of_tpl`: **a generated decode template gives the forward at the route's values**. `CaseTplAtM` is the
generated certificates' interface, unchanged: it embeds the template in the decode-resolved graph. Only the
evaluation changes (`template_cached_forwardV`). `loopG_ofAtV`, `lastG_ofV`, `cutG_ofV`: `loopG_ofAtM`, `lastG_ofM`,
`cutG_ofM` at values `Vs`, from the same end-state facts (`StartGM`, `EndGM`, `LastGM`, `CutGM`). -/

variable {C : M1Max.Contract}

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled) (Z : List F64 → Nat → Option Value) {Wd : World} (pr : GraphProj Wd)

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract

theorem caseFwdAtV_of_tpl (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {R : MRef}
    {L0 : Nat} (hdec : MRefDecodes Mx Kx (fun tab => weights (firstValues Mx Kx env tab)) R L0)
    (hW : ∀ tab, WeightShapes (stageWeights (weights (firstValues Mx Kx env tab)))) {A : Sim.Addr} {I : TplInputs}
    {L NB : Nat} {s1 : Wd.F.S} {S1tab : List SymE} {outT : Nat} {outs : List (Option Nat × Option Nat)} {i : Nat}
    (hL : L0 ≤ L + i + 1) (h : CaseTplAtM Mx Kx env pr A I L s1 S1tab outT outs i NB) :
    CaseFwdAtV Mx Kx env (routeVals P KR env kind Z) pr A I R L s1 S1tab outT outs i NB := by
  intro tab P' Mp n y ν hld hNL hN0 htv hnum hrope tok hs tok' hs' hR1 hR2 hb hcaps hcv hfed hpar
  obtain ⟨l, token, T, σ, cl, hm, hlc, hfb, hea, hbr, hemb, hin, hout, htout⟩ := h tab P' Mp n y ν hld hNL hN0 htv
    hnum hrope
  have hstep : stepTrace Mx Kx (weights (firstValues Mx Kx env tab)) (L + i + 1) tok hs = some (tok', hs') := by
    have h1 := hdec tab (L + i + 1) hL
    rw [show L + i + 1 + 1 = L + i + 2 by omega, hR2, hR1] at h1
    exact h1.symm
  obtain ⟨h1, h2, h3⟩ := template_cached_forwardV P KR env kind (Z tab) leaves typed tab (L + i + 1) (Wd.toMlx y) l token
    (Mp.node I.fed) (Mp.node outT) tok tok' hs hs' (cachesAt Mp.node outs) (Sim.capL (L + i + 1)) hstep hb
    (compat_of_caps hcaps) (shapesOk_of_caps _ _ (hW tab) hcaps) T σ cl hm hpar hcaps hbr (by rw [hlc]; exact hcv) hfb hea hfed
    hemb (hin hs hcaps) hout htout
  refine ⟨h1, h2, ?_⟩
  rw [kvCap_capL_succ] at h3
  exact h3

end

section
variable (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (Vs : Vals)
  {Wd : World} (pr : GraphProj Wd)
variable {A : Sim.Addr} {P : Wd.Par} {W : Nat → Option Sim.WFrame} {Fr : Sim.LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA : List Nat} {I : TplInputs} {R : MRef} {L : Nat} {ρ : Nat → F64} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV}

/-- `loopG_ofAtM` at values `Vs`. -/
theorem loopG_ofAtV (st : StartGM pr A P s0 tab0 I) {e : Prefill.IterEndW Wd A P s0 tab0 fixA} (g : Prefill.GhostP)
    (en : EndGM I e) (hAt : A.tvar = 9) (hAk : A.kvar = 14) {i : Nat}
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (fwd : CaseFwdAtV M K env Vs pr A I R L e.s1.ffi e.S1.tab en.outT en.outs i (pr.NB P)) :
    Prefill.LoopGStepGW (liftG Wd (GxV M K env Vs I R L)) W Fr e g (Sim.valL ρ T tk L) toks i :=
  gstep_ofGAtV M K env Vs pr st.hPNL st.hPN0 st.hPE st.hrope e g R L (Sim.valL ρ T tk L) tk toks i I en.outT en.outs htk
    htkb (fun _ => by rw [hAt]; rfl) (fun _ => by rw [hAk]; rfl) st.htv st.carR st.carF st.carC fwd en.read en.fed
    en.caches st.sread st.pread en.h1read en.h1pread st.s0tok en.s1tok st.tokv en.pout en.pouts

/-- `lastG_ofM` at values `Vs`. -/
theorem lastG_ofV (st : StartGM pr A P s0 tab0 I) {xs : List Val}
    {hs : Sim.HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs}
    (lg : LastGM I hs) (hAk : A.kvar = 14) (hAn : A.nxt = 17) (hT : 2 ≤ T)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31) :
    Sim.LastGStepW A (liftG Wd (GxV M K env Vs I R L)) P W Fr fixA hs (Sim.valL ρ T tk L) tk
      (fun tF CF => GFV Vs R L T CF.tab (Wd.toMlx tF.ffi)) :=
  LastGStepM.toW pr (lgstep_ofV M K env Vs pr hs R L (Sim.valL ρ T tk L) tk I htk htkb (by rw [hAk]; rfl)
    (by rw [hAn]; rfl) hT st.ne st.sread st.sfed st.pread st.pfed lg.fA lg.fB lg.pfA lg.pfB st.s0tok lg.sFtok lg.v79
    lg.v17)

/-- `cutG_ofM` at values `Vs`. -/
theorem cutG_ofV (st : StartGM pr A P s0 tab0 I) {k : Nat} (hk : 1 ≤ k)
    {hs : Sim.HaltSegW Wd A W P (toks.drop (k - 1)) s0 s0 tab0 []} (cg : CutGM I hs) (hAk : A.kvar = 14)
    (htk : ∀ tab j, j ≤ k → ∃ hs, R tab (L + j) = some (tk (j + 1), hs)) (htkb : tk k < 2 ^ 31) :
    Sim.CutGStepW A (liftG Wd (GxV M K env Vs I R L)) P W Fr fixA hs (Sim.valL ρ T tk L)
      (fun tF CF => GFV Vs R L k CF.tab (Wd.toMlx tF.ffi)) := by
  have h := cgstep_ofV M K env Vs pr (fixA := fixA) hs R L (Sim.valL ρ T tk L) tk I
    (fun tab j hj => htk tab j (by omega)) (by rw [show k - 1 + 1 = k by omega]; exact htkb)
    (fun _ => by rw [hAk]; rfl) st.sread st.pread cg.fA cg.pfA st.s0tok cg.sFtok cg.v79
  refine CutGStepM.toW pr ?_
  intro nx Mp Kc t Cs xF h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11
  exact GFV.mono Vs (h nx Mp Kc t Cs xF h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11) (by omega)

end

end Host.Ts.Sim.Compose
