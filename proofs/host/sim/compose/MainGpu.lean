import host.sim.compose.MainFramed
import host.route.FinalGpu
import host.sim.compose.Gpu
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Gpu
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph _root_.Host.Ts
open _root_.Host.Mlx.SimGraph.Iter (TplInputs)
open _root_.Host.Mlx.SimGraph.Mach (refPrompt refPrompt_decodes)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open _root_.Host.Ts.Sim.Prefill
open _root_.Host.Ts.Sim.Full (FF fullWorldXD fullWorldFb fullWorldFb_end mlxOf)
open _root_.Host.Route (RouteArtifactsX decCutFb machGxV goalMV goalCV machVal machReads routeVs)
open _root_.Host.Ts.Sim.Lin.Cls (routeI RouteKind DecKind)
open _root_.Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW HaltSegW valL)
open _root_.Host.Ts.Sim.Compose (DecodePiecesFramedW DecodeGraphMFramedAt PathPiecesW itersW loopG_ofAtV caseFwdAtV_of_tpl
  lastGC_ofV lastG_ofV cutG_ofV machReads_length fullProjFb)

/-! # The route's artifacts at `L ≤ 224`

`route_of_stepsFramedAt`: `route_of_piecesFramedAt` with the restricted bundles: the prefill's steps at the clipped
invariants (`ClassStepsR.toPrefSteps`), POST and the short paths' prefixes in the post class `other`. The rest of the
assembly reads no bundle and is the same. -/

variable {C : M1Max.Contract}

/-- **The route's artifacts of a prompt with no Neural Engine forward.** -/
noncomputable def route_of_stepsFramedAt (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : _root_.Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (π : List Nat) {T : Nat} {tk : Nat → Nat} (je : _root_.Host.Ts.Env)
    (nm : _root_.Host.Ts.Name) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224) (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
    (NB : Nat) (Pw Pd : LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat) (I : PrefInvsW (fullWorldXD NB).F)
    (Fr : LoopFramesA A) (s0 : St FF.S) (tab0 : List SymE) (Itpl : TplInputs) (B : LoopBase) (ΔJ ΔH ΔN : Nat)
    (Pp : PiecesR (fullWorldXD NB).F I) (H : RoutePiecesR (fullWorldXD NB).F I T tk)
    (Hp : PathPiecesW (fullWorldXD NB) A Pw W fixA tk (H.cuts.b_pA_cut (routeI π.length T (tk 1) (tk 2)))
      (H.cuts.b_pB_cut (routeI π.length T (tk 1) (tk 2))) (H.cuts.b_pC_cut (routeI π.length T (tk 1) (tk 2))))
    (D : ∀ (_ : 3 ≤ T) (b0 : _root_.Host.Mlx.FfiAne.St), DecodePiecesFramedW (fullWorldFb b0 NB) A Pd W s0 tab0 fixA Fr (machVal T tk) T tk π.length
      (.ref 2 :: machReads T tk) [.num (.ref 1)] B ΔJ ΔH ΔN)
    (Dg : ∀ h3 b0, DecodeGraphMFramedAt P KR env π b0 je Itpl (D h3 b0))
    (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA) (hgen : A.gen ∈ fixA) (hwc : W A.cE = none) (hwe : W A.emit = none)
    (henv : lookupEnv nm je = some A.cE) (hgenv : lookupEnv chars!"generation" je = some A.gen)
    (hA : A.nxt = 17) (hAt : A.tvar = 9) (hAk : A.kvar = 14) (hst0 : LoopStartW (fullWorldXD NB) A Pd s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true)
    (hdec : ∀ t Cs, (I.dec π.length).Inv t Cs → ∃ kind, (decCutFb NB A (machGxV P KR NE net env π kind NB Itpl) W Pd Fr s0 tab0 fixA
      (valL (machVal T tk) T tk π.length) tk (.ref 2 :: machReads T tk) [.num (.ref 1)] B).Inv t Cs)
    (he1 : ∀ t C, (I.dec π.length).Inv t C → C.val (.ref 1) = some (F64.ofNat (tk 1)))
    (htkR : ∀ tab j, j < T → ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk : ∀ j, j ≤ T → tk j ≤ 248319)
    (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pd.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hN : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pd.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62)
    (gA : Hp.pA.Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF))
    (gB2 : Hp.pB2.Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 2 tF CF))
    (gB0 : Hp.pB0.Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF))
    (gC1 : Hp.pC1.Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF))
    (gC0 : Hp.pC0.Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF)) :
    RouteArtifactsX P KR NE net env π T tk je nm :=
  have h2 : π.length ≤ 262143 := by omega
  have ha : PostClass.other.Applies π.length := other_short hπ hL
  have htk' : ∀ j, j ≤ T → tk j ≤ 2 ^ 20 := fun j hj => Nat.le_trans (htk j hj) (by decide)
  have htkb : ∀ j, j + 1 ≤ T → tk (j + 1) < 2 ^ 31 := fun j hj => by have := htk (j + 1) hj; omega
  have hst : ∀ b0, LoopStartW (fullWorldFb b0 NB) A Pd s0 tab0 := fun _ => ⟨hst0.htok, hst0.start, hst0.lo, hst0.hi⟩
  let pA : RouteKind.pathA.Holds π.length T (tk 1) (tk 2) → PathW (fullWorldXD NB) A W Pw fixA (I.clip.ps π.length) [] :=
    fun hq => Hp.pA.path (pathAPre H hπ h2 hq ha)
  let pB2 : RouteKind.pathB.Holds π.length T (tk 1) (tk 2) →
      PathW (fullWorldXD NB) A W Pw fixA (I.clip.ps π.length) (tokVals tk 1) :=
    fun hq => Hp.pB2.path (pathBPre H hπ h2 hq ha)
  let pB0 : RouteKind.pathB.Holds π.length T (tk 1) (tk 2) →
      PathW (fullWorldXD NB) A W Pw fixA (I.clip.ps π.length) (tokVals tk 2) :=
    fun hq => Hp.pB0.path (pathBPre H hπ h2 hq ha)
  let pC1 : RouteKind.pathC.Holds π.length T (tk 1) (tk 2) → PathW (fullWorldXD NB) A W Pw fixA (I.clip.ps π.length) [] :=
    fun hq => Hp.pC1.path (pathCPre H hπ h2 hq ha)
  let pC0 : RouteKind.pathC.Holds π.length T (tk 1) (tk 2) →
      PathW (fullWorldXD NB) A W Pw fixA (I.clip.ps π.length) (tokVals tk 1) :=
    fun hq => Hp.pC0.path (pathCPre H hπ h2 hq ha)
  { NB := NB
    Pw := Pw
    Pd := Pd
    A := A
    W := W
    fixA := fixA
    I := I.clip
    SP := (classStepsR Pp).toPrefSteps
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
    s21 := fun _ _ => Hp.pA.h.stop Hp.sA _
    s22 := fun _ _ _ => Hp.pB2.h.stop Hp.sB2 _
    s11 := fun _ _ => Hp.pC1.h.stop Hp.sC1 _
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
        nP := route_post_other.total H
        hpost := fun h1 => postStepR H hπ h2 ⟨h3, hctx, htk 1 (by omega), h1, htk 2 (by omega)⟩ ha
        hdec := hdec
        e1 := .ref 1
        hE0 := rfl
        he1 := he1
        hA := hA
        hfrN := hfrN
        hwe := hwe
        P1 := fun h => pA ⟨by omega, hctx, h, htk 2 (by omega)⟩
        s1H := fun _ => Hp.pA.h.stop Hp.sA _
        hG1 := fun _ => gA }
    dec := fun h3 b0 kind =>
      { st := hst b0
        hit := itersW (fullWorldFb_end b0 NB) hA (hst b0) (D h3 b0).cs (D h3 b0).gr (by omega)
          (by simp only [List.length_cons, machReads_length]; omega) htk' htk hJ hH hN
          fun k i hs _ => loopG_ofAtV P.toMlxContract KR.toKernelContract env (routeVs P KR env kind) (fullProjFb b0 NB) (Dg h3 b0).st
            ((D h3 b0).cs k).g ((Dg h3 b0).en k) hAt hAk (fun tab j hj => htkR tab j (by have := hs.1.2.1; omega))
            (fun j hj => htkb j (by have := hs.1.2.1; omega))
            (caseFwdAtV_of_tpl P KR env kind (fun _ _ => none) (fullProjFb b0 NB) leaves typed
              (refPrompt_decodes P KR NE KR.inPlace net env π)
              (weightShapes_first P.toMlxContract KR.toKernelContract env leaves typed) (by omega) ((Dg h3 b0).tpl k i hs))
        F0 := (D h3 b0).f0.seg _
        F1 := (D h3 b0).f1.seg _
        F2 := (D h3 b0).f2.seg _
        c0 := (D h3 b0).c0
        c1 := (D h3 b0).c1
        c2 := (D h3 b0).c2
        hQA := (D h3 b0).qF
        X := fun k => (D h3 b0).x.seg ((.ref 2 :: machReads T tk).drop (k - 1))
        cX := fun _ => (D h3 b0).cX
        hQX := (D h3 b0).qX
        sX := fun _ _ _ => (D h3 b0).x.stop (D h3 b0).sX _
        FE0 := (D h3 b0).e0.seg _
        FE1 := (D h3 b0).e1.seg _
        c0E := (D h3 b0).c0E
        c1E := (D h3 b0).c1E
        hQE := (D h3 b0).qE
        s0E := (D h3 b0).e0.stop (D h3 b0).s0E _
        s1E := (D h3 b0).e1.stop (D h3 b0).s1E _
        hlen := by simp only [List.length_cons, machReads_length]; omega
        hF := fun _ _ _ => lastGC_ofV P KR NE net env π kind (Dg h3 b0).st (Dg h3 b0).f0 (Dg h3 b0).c0.cache hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hF0 := fun _ _ => lastGC_ofV P KR NE net env π kind (Dg h3 b0).st (Dg h3 b0).f1 (Dg h3 b0).c1.cache hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hF1 := fun _ _ => lastGC_ofV P KR NE net env π kind (Dg h3 b0).st (Dg h3 b0).f2 (Dg h3 b0).c2.cache hAk hA (by omega)
          (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hX := fun k hk hkT _ => cutG_ofV P.toMlxContract KR.toKernelContract env (routeVs P KR env kind) (fullProjFb b0 NB) (Dg h3 b0).st
          (by omega) ((Dg h3 b0).x k) hAk (fun tab j hj => htkR tab j (by omega)) (by have := htk k (by omega); omega)
        hFE := fun _ _ => lastG_ofV P.toMlxContract KR.toKernelContract env (routeVs P KR env kind) (fullProjFb b0 NB) (Dg h3 b0).st (Dg h3 b0).e0
          hAk hA (by omega) (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega))
        hFE0 := fun _ _ => lastG_ofV P.toMlxContract KR.toKernelContract env (routeVs P KR env kind) (fullProjFb b0 NB) (Dg h3 b0).st (Dg h3 b0).e1
          hAk hA (by omega) (fun tab j hj => htkR tab j (by omega)) (fun j hj => htkb j (by omega)) } }

end Host.Ts.Sim.Compose.Gpu
