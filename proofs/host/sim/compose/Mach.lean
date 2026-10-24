import host.simgraph.world.Mach
import host.simgraph.mach.TotalStep
import host.sim.compose.Iter
set_option maxRecDepth 1000000
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt)
open Host.Mlx.SimGraph.Mach (MRef MRefDecodes WeightShapes template_cached_forwardM compat_of_caps shapesOk_of_caps
  StageTy DeltaTy AttnTy pipeTy_of_loaded)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
namespace Host.Ts.Sim.Compose

/-! # The decode route's graph obligations at the machine reference, from the pieces' graph facts

A2's machine-reference obligations (`host.simgraph.world.Mach`) asked of the decode route's pieces:

* `caseFwdM_of_tpl`: **a loop case's forward** (`CaseFwdM`) from its decode template at the
  iteration (`CaseTplM`: the loaded tensors, the fed-back token, the graph template embedded in the
  target's graph with its carriers and its KV branch), by `template_cached_forwardM`, the step from
  the reference's decode (`MRefDecodes`, `refPrompt_decodes`), the caches' kinds and shapes from
  their capacity (`compat_of_caps`, `shapesOk_of_caps`) and the capacity after the step
  (`kvCap_capL_succ`), the weights' shapes from the load (`weightShapes_first`);
* `StartGM`: the decode template start's graph facts (the projection's constants, the carriers);
  `EndGM`: a case end's (its restart map's carriers, the output node and caches); `LastGM`,
  `CutGM`: a final chain's and an exit chain's halted template facts;
* `loopG_ofM` (`gstep_ofGM`: a case's chain through compactions), `lastG_ofM` (`lgstep_ofM`),
  `cutG_ofM` (`cgstep_ofM`, the goal lowered to `k` tokens by `GFM.mono`): the world's obligations
  (`LoopGStepGW`, `LastGStepW`, `CutGStepW`) at `liftG Wd (GxM … R L)` with the goals `GFM`. -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey)

/-- The capacity after a one-row step at offset `t` is the capacity of `t + 1`. -/
theorem kvCap_capL_succ (t : Nat) : kvCap (some (Sim.capL t)) t = Sim.capL (t + 1) := by
  simp only [kvCap]
  have e1 : Sim.capL t = 256 * ((t + 255) / 256) := rfl
  have e2 : Sim.capL (t + 1) = 256 * ((t + 1 + 255) / 256) := rfl
  split <;> (try split) <;> omega

/-- The stages' route types give their shapes. -/
theorem weightShapes_of_ty : ∀ (ws : List StageWeights), (∀ s ∈ ws, StageTy s) → WeightShapes ws
  | [], _ => trivial
  | .delta w :: ws, h =>
    ⟨(h (.delta w) List.mem_cons_self : DeltaTy w).inputNorm.2,
      weightShapes_of_ty ws fun s hs => h s (List.mem_cons_of_mem _ hs)⟩
  | .attention w :: ws, h =>
    ⟨⟨(h (.attention w) List.mem_cons_self : AttnTy w).inputNorm.2,
        (h (.attention w) List.mem_cons_self : AttnTy w).qNorm.2, (h (.attention w) List.mem_cons_self : AttnTy w).kNorm.2⟩,
      weightShapes_of_ty ws fun s hs => h s (List.mem_cons_of_mem _ hs)⟩

/-- **The loaded weights' shapes at every table**: the first load's pipeline is the checkpoint's
(`firstPipeline_loaded`, from the first graph's load matching the checkpoint, `first_load_matches`), so
its stages have the route's types (`pipeTy_of_loaded`). -/
theorem weightShapes_first (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (tab : List F64) :
    WeightShapes (stageWeights (weights (firstValues M K env tab))) :=
  weightShapes_of_ty _ (pipeTy_of_loaded M K (firstPipeline_loaded M K env tab leaves typed)).stages

section
variable {Wd : World} (pr : GraphProj Wd)

/-- **A loop case's decode template at iteration `i`** (what `template_cached_forwardM` asks besides
the reference's step and the caches' kinds and shapes): at every end pair of the case (`CaseFwdM`'s
premises), the loaded tensors `l` (the model's, its caches at the template start's carriers), the
token tensor fed back from the fed carrier, the decode graph template `T` with its embedding `σ`,
`cl` in the target's graph at the step's time, its inputs at the carriers, its outputs at `outs`
and `outT`, its KV branch the step's. -/
def CaseTplM (A : Sim.Addr) (I : TplInputs) (L : Nat) (s1 : Wd.F.S) (S1tab : List SymE) (outT : Nat)
    (outs : List (Option Nat × Option Nat)) (i : Nat) : Prop :=
  ∀ (tab : List F64) (P' : Sim.LoadP) (NB : Nat) (Mp : Sim.Map) (n : Nat) (y : Wd.F.S) (ν : Nat → F64),
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

/-- **A loop case's forward at the machine reference** from its decode template (see the module
doc). -/
theorem caseFwdM_of_tpl (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {R : MRef}
    {L0 : Nat} (hdec : MRefDecodes M K (fun tab => weights (firstValues M K env tab)) R L0)
    (hW : ∀ tab, WeightShapes (stageWeights (weights (firstValues M K env tab)))) {A : Sim.Addr} {I : TplInputs}
    {L : Nat} {s1 : Wd.F.S} {S1tab : List SymE} {outT : Nat} {outs : List (Option Nat × Option Nat)} {i : Nat}
    (hL : L0 ≤ L + i + 1) (h : CaseTplM M K env pr A I L s1 S1tab outT outs i) :
    CaseFwdM M K env pr A I R L s1 S1tab outT outs i := by
  intro tab P' NB Mp n y ν hld hNL hN0 htv hnum hrope tok hs tok' hs' hR1 hR2 hb hcaps hcv hfed hpar
  obtain ⟨l, token, T, σ, cl, hm, hlc, hfb, hea, hbr, hemb, hin, hout, htout⟩ := h tab P' NB Mp n y ν hld hNL hN0 htv
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

/-- **The decode template start's graph facts**: the projection's constants, the carriers of the
template start (unread, present, below the native counter), the look-ahead token. -/
structure StartGM (A : Sim.Addr) (P : Wd.Par) (s0 : St Wd.F.S) (tab0 : List SymE) (I : TplInputs) : Prop where
  hPNL : ∀ r, (pr.lp P r).NL = A.NL
  hPN0 : ∀ r, (pr.lp P r).N0 = A.N0
  hPE : Wd.E P ≤ A.rope
  hrope : A.rope < 2 ^ 56
  htv : ∃ j, nth? tab0 j = some (.var A.tvar)
  carR : I.read < (Wd.toMlx s0.ffi).nnext
  carF : I.fed < (Wd.toMlx s0.ffi).nnext
  carC : ∀ p ∈ I.caches, ∀ j, (p.1 = some j ∨ p.2 = some j) → j < (Wd.toMlx s0.ffi).nnext
  sread : (Wd.toMlx s0.ffi).items.get I.read = none
  pread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true
  sfed : (Wd.toMlx s0.ffi).items.get I.fed = none
  pfed : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true
  ne : I.read ≠ I.fed
  s0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]
  tokv : nth? tab0 A.tok = some (.var A.kvar)

/-- **A decode case end's graph facts**: its restart map's carriers (the read carrier to the fed
one, the fed one to the output node `outT`, the caches to `outs`), the readback at the end, the
output node and caches present. -/
structure EndGM {A : Sim.Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} (I : TplInputs)
    (e : Prefill.IterEndW Wd A P s0 tab0 fixA) where
  outT : Nat
  outs : List (Option Nat × Option Nat)
  read : e.σ.node I.read = I.fed
  fed : e.σ.node I.fed = outT
  caches : I.caches.map (fun p => (p.1.map e.σ.node, p.2.map e.σ.node)) = outs
  h1read : (Wd.toMlx e.s1.ffi).items.get I.read = some (.ref A.tok)
  h1pread : ((Wd.toMlx e.s1.ffi).nodes.get I.read).isSome = true
  s1tok : (Wd.toMlx e.s1.ffi).tokens = []
  pout : ((Wd.toMlx e.s1.ffi).nodes.get outT).isSome = true
  pouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx e.s1.ffi).nodes.get j).isSome = true

/-- **A final chain's halted template facts**: the readback and the look-ahead token at its halt,
present, no token left, their variables. -/
structure LastGM {A : Sim.Addr} {W : Nat → Option Sim.WFrame} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE}
    {r : List NumV} {xs : List Val} (I : TplInputs)
    (hs : Sim.HaltSegW Wd A W P r s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs) : Prop where
  fA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok)
  fB : (Wd.toMlx hs.case.sF.ffi).items.get I.fed = some (.ref tab0.length)
  pfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true
  pfB : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.fed).isSome = true
  sFtok : (Wd.toMlx hs.case.sF.ffi).tokens = []
  v79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar)
  v17 : nth? hs.case.SF.tab tab0.length = some (.var A.nxt)

/-- **An exit chain's halted template facts.** -/
structure CutGM {A : Sim.Addr} {W : Nat → Option Sim.WFrame} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE}
    {r : List NumV} (I : TplInputs) (hs : Sim.HaltSegW Wd A W P r s0 s0 tab0 []) : Prop where
  fA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok)
  pfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true
  sFtok : (Wd.toMlx hs.case.sF.ffi).tokens = []
  v79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar)

variable {A : Sim.Addr} {P : Wd.Par} {W : Nat → Option Sim.WFrame} {Fr : Sim.LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA : List Nat} {I : TplInputs} {R : MRef} {L : Nat} {ρ : Nat → F64} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV}

/-- **A case's graph obligation through its chain** at the machine reference (`gstep_ofGM`). -/
theorem loopG_ofM (st : StartGM pr A P s0 tab0 I) {e : Prefill.IterEndW Wd A P s0 tab0 fixA} (g : Prefill.GhostP)
    (en : EndGM I e) (hAt : A.tvar = 9) (hAk : A.kvar = 14) {i : Nat}
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (fwd : CaseFwdM M K env pr A I R L e.s1.ffi e.S1.tab en.outT en.outs i) :
    Prefill.LoopGStepGW (liftG Wd (GxM M K env I R L)) W Fr e g (Sim.valL ρ T tk L) toks i :=
  gstep_ofGM M K env pr st.hPNL st.hPN0 st.hPE st.hrope e g R L (Sim.valL ρ T tk L) tk toks i I en.outT en.outs htk
    htkb (fun _ => by rw [hAt]; rfl) (fun _ => by rw [hAk]; rfl) st.htv st.carR st.carF st.carC fwd en.read en.fed
    en.caches st.sread st.pread en.h1read en.h1pread st.s0tok en.s1tok st.tokv en.pout en.pouts

/-- **A final chain's graph obligation** at the machine reference (`lgstep_ofM`): the goal `GFM`
at `T`. -/
theorem lastG_ofM (st : StartGM pr A P s0 tab0 I) {xs : List Val}
    {hs : Sim.HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs}
    (lg : LastGM I hs) (hAk : A.kvar = 14) (hAn : A.nxt = 17) (hT : 2 ≤ T)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31) :
    Sim.LastGStepW A (liftG Wd (GxM M K env I R L)) P W Fr fixA hs (Sim.valL ρ T tk L) tk
      (fun tF CF => GFM M K env R L T CF.tab (Wd.toMlx tF.ffi)) :=
  LastGStepM.toW pr (lgstep_ofM M K env pr hs R L (Sim.valL ρ T tk L) tk I htk htkb (by rw [hAk]; rfl)
    (by rw [hAn]; rfl) hT st.ne st.sread st.sfed st.pread st.pfed lg.fA lg.fB lg.pfA lg.pfB st.s0tok lg.sFtok lg.v79
    lg.v17)

/-- **An exit chain's graph obligation** at the cut of iteration `k - 1` at the machine reference
(`cgstep_ofM`), its goal `GFM (k + 1)` lowered to `k` tokens. -/
theorem cutG_ofM (st : StartGM pr A P s0 tab0 I) {k : Nat} (hk : 1 ≤ k)
    {hs : Sim.HaltSegW Wd A W P (toks.drop (k - 1)) s0 s0 tab0 []} (cg : CutGM I hs) (hAk : A.kvar = 14)
    (htk : ∀ tab j, j ≤ k → ∃ hs, R tab (L + j) = some (tk (j + 1), hs)) (htkb : tk k < 2 ^ 31) :
    Sim.CutGStepW A (liftG Wd (GxM M K env I R L)) P W Fr fixA hs (Sim.valL ρ T tk L)
      (fun tF CF => GFM M K env R L k CF.tab (Wd.toMlx tF.ffi)) := by
  have h := cgstep_ofM M K env pr (fixA := fixA) hs R L (Sim.valL ρ T tk L) tk I
    (fun tab j hj => htk tab j (by omega)) (by rw [show k - 1 + 1 = k by omega]; exact htkb)
    (fun _ => by rw [hAk]; rfl) st.sread st.pread cg.fA cg.pfA st.s0tok cg.sFtok cg.v79
  refine CutGStepM.toW pr ?_
  intro nx Mp Kc t Cs xF h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11
  exact GFM.mono M K env (h nx Mp Kc t Cs xF h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11) (by omega)

end

end Host.Ts.Sim.Compose
