import host.sim.compose.RouteSteps
import host.sim.compose.Loop
import host.sim.compose.Mach
import host.route.Final
set_option maxRecDepth 1000000
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Iter (TplInputs)
open Host.Mlx.SimGraph.Mach (refPrompt refPrompt_decodes)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim.Prefill
open Host.Ts.Sim.Full (FF FLR fullWorld fullWorld_end mlxOf)
open Host.Route (RouteArtifacts LoopArtifacts machGx goalM goalC machVal machReads)
open Host.Ts.Sim.Lin.Cls (routeI RouteKind DecKind)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW HaltSegW valL)
namespace Host.Ts.Sim.Compose

/-! # The route's artifacts from the pieces (gen-plan T8, Phase E)

`route_of_pieces`: **the route's generated artifacts** (`RouteArtifacts`, `host.route.Final`: what
`route_final` takes of generation), field for field from the pieces at the full world
`fullWorld NB`, the machine reference `refPrompt π` and the route's readback world (`routeWorld`,
`routeServer`: the table's valuation `machVal T tk`, token 1 read through table symbol 1, token 2
through symbol 2, tokens `3 … T` literals `machReads T tk`):

* the prefill's checked steps (`Pieces`, `classSteps`);
* POST and the short paths' prefixes (`RoutePieces`, `postStep`, `path*Pre`), the short paths'
  halts with their stops (`DecodePiecesW`'s `pA` …);
* the decode iterations (`hit`: the six cases' cut-step chains, `itersW`, each iteration's graph
  certificate by `loopG_ofM` with its forward by `caseFwdM_of_tpl`), the final, exit and EOS chains
  with their oracles over their boxes, and the halts' graph certificates (`lastGC_ofM`, `lastG_ofM`,
  `cutG_ofM`) from the decode route's graph facts (`DecodeGraphM`).

The paths' goals (`PathHaltW.Goal`) are the pieces' graph certificates, taken as hypotheses; the final
chains' program caches are kernel checks of their end states (`FinalCacheTpl`); the weights' shapes are
the load's (`weightShapes_first`). -/

/-- **The full world's graph projection**: the load-world part of a full-world state, the relation's
general part (`FullRB.load`). -/
def fullProj (NB : Nat) : GraphProj (fullWorld NB) where
  toLoad x := Layers.toLoad x
  mlx _ := rfl
  lp P r := { P with rest := r }
  NB _ := NB
  load h := h.load
  rest _ _ := rfl

variable {C : M1Max.Contract}

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **A final chain's graph certificate with the program's caches** (A2's `lgstepC_ofM` with the chain's
`FinalCacheW`): the goal `goalC` at `T`. -/
theorem lastGC_ofM {NB : Nat} {A : Addr} {W : Nat → Option WFrame} {Pw : LoadP} {Fr : LoopFramesA A}
    {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {Itpl : TplInputs} {ρ : Nat → F64} {T : Nat}
    {tk : Nat → Nat} {toks : List NumV} {xs : List Val} {je : Host.Ts.Env}
    (st : StartGM (fullProj NB) A Pw s0 tab0 Itpl)
    {hs : HaltSegW (fullWorld NB) A W Pw (toks.drop (T - 1)) s0 ((fullWorld NB).finalStartW s0 tab0.length)
      (tab0 ++ [.var A.nxt]) xs}
    (lg : LastGM Itpl hs) (hc : FinalCacheW (fullProj NB) fixA Itpl je hs) (hAk : A.kvar = 14) (hAn : A.nxt = 17)
    (hT : 2 ≤ T)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31) :
    LastGStepW A (machGx P KR NE net env π NB Itpl) Pw W Fr fixA hs (valL ρ T tk π.length) tk
      (goalC P KR NE net env π NB T je) :=
  (lgstepC_ofM P.toMlxContract KR.toKernelContract env (fullProj NB) hs (refPrompt P KR NE KR.inPlace net env π)
    π.length (valL ρ T tk π.length) tk Itpl je htk htkb (by rw [hAk]; rfl) (by rw [hAn]; rfl) hT st.ne st.sread
    st.sfed st.pread st.pfed lg.fA lg.fB lg.pfA lg.pfB st.s0tok lg.sFtok lg.v79 lg.v17 hc).toW (fullProj NB)

end

section
variable {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
  {NB : Nat} {A : Addr} {W : Nat → Option WFrame} {Pw : LoadP} {Fr : LoopFramesA A} {s0 : St FF.S}
  {tab0 : List SymE} {fixA : List Nat} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {cA cB cC : ICut FF}

variable (P KR env π) in
/-- **The decode route's graph facts** at the machine reference (`host.sim.compose.Mach`): the
template start's, each case end's and its decode template at every iteration it is selected for,
the final and EOS final chains' halted template facts with the final chains' program caches, the
exit chain's. -/
structure DecodeGraphM (je : Host.Ts.Env) (Itpl : TplInputs)
    (D : DecodePiecesW (fullWorld NB) A Pw W s0 tab0 fixA Fr (machVal T tk) T tk π.length
      (.ref 2 :: machReads T tk) [.num (.ref 1)] B ΔJ ΔH ΔN cA cB cC) where
  st : StartGM (fullProj NB) A Pw s0 tab0 Itpl
  en : (k : DecKind) → EndGM Itpl (D.cs k).e
  tpl : ∀ k i, DecSel T π.length tk k i →
    CaseTplM P.toMlxContract KR.toKernelContract env (fullProj NB) A Itpl π.length (D.cs k).e.s1.ffi
      (D.cs k).e.S1.tab (en k).outT (en k).outs i
  f0 : LastGM Itpl (D.f0.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  f1 : LastGM Itpl (D.f1.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  f2 : LastGM Itpl (D.f2.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  c0 : FinalCacheTpl (fullProj NB) fixA Itpl je (D.f0.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  c1 : FinalCacheTpl (fullProj NB) fixA Itpl je (D.f1.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  c2 : FinalCacheTpl (fullProj NB) fixA Itpl je (D.f2.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  e0 : LastGM Itpl (D.e0.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  e1 : LastGM Itpl (D.e1.seg ((.ref 2 :: machReads T tk).drop (T - 1)))
  x : ∀ k, CutGM Itpl (D.x.seg ((.ref 2 :: machReads T tk).drop (k - 1)))

end

theorem machReads_length (T : Nat) (tk : Nat → Nat) : (machReads T tk).length = T - 2 := by
  simp [machReads]

/-- **The route's generated artifacts from the pieces** (see the module doc). -/
noncomputable def route_of_pieces (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (π : List Nat) {T : Nat} {tk : Nat → Nat} (je : Host.Ts.Env)
    (nm : Host.Ts.Name) (hπ : 1 ≤ π.length) (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
    -- the full world, the driver's cells, the prefill invariants
    (NB : Nat) (Pw : LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat) (I : PrefInvsW (fullWorld NB).F)
    -- the decode template's constants
    (Fr : LoopFramesA A) (s0 : St FF.S) (tab0 : List SymE) (Itpl : TplInputs) (B : LoopBase) (ΔJ ΔH ΔN : Nat)
    -- the pieces
    (Pp : Pieces (fullWorld NB).F I) (H : RoutePieces (fullWorld NB).F I T tk)
    (D : DecodePiecesW (fullWorld NB) A Pw W s0 tab0 fixA Fr (machVal T tk) T tk π.length
      (.ref 2 :: machReads T tk) [.num (.ref 1)] B ΔJ ΔH ΔN (H.cuts.b_pA_cut (routeI π.length T (tk 1) (tk 2)))
      (H.cuts.b_pB_cut (routeI π.length T (tk 1) (tk 2))) (H.cuts.b_pC_cut (routeI π.length T (tk 1) (tk 2))))
    (Dg : DecodeGraphM P KR env π je Itpl D)
    -- the driver's cells and the decode template's start facts
    (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA) (hgen : A.gen ∈ fixA) (hwc : W A.cE = none) (hwe : W A.emit = none)
    (henv : lookupEnv nm je = some A.cE) (hgenv : lookupEnv chars!"generation" je = some A.gen)
    (hA : A.nxt = 17) (hAt : A.tvar = 9) (hAk : A.kvar = 14) (hst0 : LoopStartW (fullWorld NB) A Pw s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true)
    -- the decode cut, its prefix token 1 read through table symbol 1
    (hdec : I.dec π.length = loopCutW (fullWorld NB) A (machGx P KR NE net env π NB Itpl) W Pw Fr s0 tab0 fixA
      (valL (machVal T tk) T tk π.length) tk (.ref 2 :: machReads T tk) [.num (.ref 1)] B)
    (he1 : ∀ t C, (I.dec π.length).Inv t C → C.val (.ref 1) = some (F64.ofNat (tk 1)))
    -- the tokens: the reference's, in the vocabulary
    (htkR : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk : ∀ j, j ≤ T → tk j ≤ 248319)
    -- the counters' bounds
    (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hN : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62)
    -- the short paths' graph certificates
    (gA : D.pA.Goal (goalM P KR NE net env π NB 1)) (gB2 : D.pB2.Goal (goalM P KR NE net env π NB 2))
    (gB0 : D.pB0.Goal (goalC P KR NE net env π NB T je)) (gC1 : D.pC1.Goal (goalM P KR NE net env π NB 1))
    (gC0 : D.pC0.Goal (goalC P KR NE net env π NB T je)) :
    RouteArtifacts P KR NE net env π T tk je nm :=
  have h2 : π.length ≤ 262143 := by omega
  have htk' : ∀ j, j ≤ T → tk j ≤ 2 ^ 20 := fun j hj => Nat.le_trans (htk j hj) (by decide)
  have htkb : ∀ j, j + 1 ≤ T → tk (j + 1) < 2 ^ 31 := fun j hj => by have := htk (j + 1) hj; omega
  -- the short paths from the exit cut
  let pA : RouteKind.pathA.Holds π.length T (tk 1) (tk 2) → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) [] :=
    fun hq => D.pA.path (pathAPre H hπ h2 hq)
  let pB2 : RouteKind.pathB.Holds π.length T (tk 1) (tk 2) →
      PathW (fullWorld NB) A W Pw fixA (I.ps π.length) (tokVals tk 1) :=
    fun hq => D.pB2.path (pathBPre H hπ h2 hq)
  let pB0 : RouteKind.pathB.Holds π.length T (tk 1) (tk 2) →
      PathW (fullWorld NB) A W Pw fixA (I.ps π.length) (tokVals tk 2) :=
    fun hq => D.pB0.path (pathBPre H hπ h2 hq)
  let pC1 : RouteKind.pathC.Holds π.length T (tk 1) (tk 2) → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) [] :=
    fun hq => D.pC1.path (pathCPre H hπ h2 hq)
  let pC0 : RouteKind.pathC.Holds π.length T (tk 1) (tk 2) →
      PathW (fullWorld NB) A W Pw fixA (I.ps π.length) (tokVals tk 1) :=
    fun hq => D.pC0.path (pathCPre H hπ h2 hq)
  { NB := NB
    Pw := Pw
    A := A
    W := W
    fixA := fixA
    I := I
    SP := (classSteps Pp).toPrefSteps
    hcE := hcE
    hb := hb
    hgen := hgen
    hwc := hwc
    henv := henv
    hgenv := hgenv
    P21 := fun h h' => pA ⟨by omega, hctx, h', htk 2 (by omega)⟩
    P22 := fun h h' _ => pB2 ⟨h, hctx, htk 1 (by omega), h', htk 2 (by omega)⟩
    P20 := fun h h' _ => pB0 ⟨h, hctx, htk 1 (by omega), h', htk 2 (by omega)⟩
    P11 := fun h _ => pC1 ⟨h, hctx, htk 1 (by omega)⟩
    P10 := fun h _ => pC0 ⟨h, hctx, htk 1 (by omega)⟩
    s21 := fun _ _ => D.pA.h.stop D.sA _
    s22 := fun _ _ _ => D.pB2.h.stop D.sB2 _
    s11 := fun _ _ => D.pC1.h.stop D.sC1 _
    g21 := fun _ _ => gA
    g22 := fun _ _ _ => gB2
    g20 := fun _ _ _ => gB0
    g11 := fun _ _ => gC1
    g10 := fun _ _ => gC0
    loop := fun h3 =>
      { Fr := Fr
        s0 := s0
        tab0 := tab0
        Itpl := Itpl
        ρ := machVal T tk
        toks := .ref 2 :: machReads T tk
        E0 := [.num (.ref 1)]
        B := B
        ΔJ := ΔJ
        ΔH := ΔH
        ΔN := ΔN
        nP := postN H (postOf π.length)
        hpost := fun h1 => postStep H hπ h2 ⟨h3, hctx, htk 1 (by omega), h1, htk 2 (by omega)⟩
        hdec := hdec
        e1 := .ref 1
        hE0 := rfl
        he1 := he1
        hA := hA
        st := hst0
        hfrN := hfrN
        hwe := hwe
        hit := itersW (fullWorld_end NB) hA hst0 D.cs D.gr (by omega) (by simp only [List.length_cons, machReads_length]; omega) htk' htk hJ hH hN
          fun k i hs _ => loopG_ofM P.toMlxContract KR.toKernelContract env (fullProj NB) Dg.st (D.cs k).g (Dg.en k)
            hAt hAk (fun tab j hj => htkR tab j (by have := hs.1.2.1; omega))
            (fun j hj => htkb j (by have := hs.1.2.1; omega))
            (caseFwdM_of_tpl P.toMlxContract KR.toKernelContract env (fullProj NB) leaves typed
              (refPrompt_decodes P KR NE KR.inPlace net env π)
              (weightShapes_first P.toMlxContract KR.toKernelContract env leaves typed) (by omega) (Dg.tpl k i hs))
        F0 := D.f0.seg _
        F1 := D.f1.seg _
        F2 := D.f2.seg _
        c0 := D.c0
        c1 := D.c1
        c2 := D.c2
        hQA := D.qF
        X := fun k => D.x.seg ((.ref 2 :: machReads T tk).drop (k - 1))
        cX := fun _ => D.cX
        hQX := D.qX
        sX := fun _ _ _ => D.x.stop D.sX _
        FE0 := D.e0.seg _
        FE1 := D.e1.seg _
        c0E := D.c0E
        c1E := D.c1E
        hQE := D.qE
        s0E := D.e0.stop D.s0E _
        s1E := D.e1.stop D.s1E _
        P1 := fun h => pA ⟨by omega, hctx, h, htk 2 (by omega)⟩
        s1H := fun _ => D.pA.h.stop D.sA _
        hlen := by simp only [List.length_cons, machReads_length]; omega
        hF := fun _ _ _ => lastGC_ofM P KR NE net env π Dg.st Dg.f0 Dg.c0.cache hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hF0 := fun _ _ => lastGC_ofM P KR NE net env π Dg.st Dg.f1 Dg.c1.cache hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hF1 := fun _ _ => lastGC_ofM P KR NE net env π Dg.st Dg.f2 Dg.c2.cache hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hX := fun k hk hkT _ => cutG_ofM P.toMlxContract KR.toKernelContract env (fullProj NB) Dg.st (by omega)
          (Dg.x k) hAk (fun tab j hj => htkR tab j (by omega)) (by have := htk k (by omega); omega)
        hFE := fun _ _ => lastG_ofM P.toMlxContract KR.toKernelContract env (fullProj NB) Dg.st Dg.e0 hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hFE0 := fun _ _ => lastG_ofM P.toMlxContract KR.toKernelContract env (fullProj NB) Dg.st Dg.e1 hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hG1 := fun _ => gA } }

end Host.Ts.Sim.Compose
