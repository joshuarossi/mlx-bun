import host.route.cert.Dec.Ends
import host.route.cert.Dec.Final.Caches
import host.route.cert.Dec.Final.Eos0
import host.route.cert.Dec.Final.Eos1
import host.route.cert.Dec.Final.EosCut
import host.sim.compose.a4b.Dec4Counters
import host.sim.compose.Gpu
import host.sim.compose.MainGpu
import host.sim.compose.LoopFramed
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Prefill _root_.Host.Ts.Sim.Full
open _root_.Host.Ts.Sim.Template _root_.Host.Load.Layers _root_.Host.Load.Run.Prompt
open _root_.Host.Ts.Sim.Lin.Cls
open _root_.Host.Mlx _root_.Host.Mlx.SimGraph _root_.Host.Mlx.FfiEval
open _root_.Host.Load.Program
open _root_.Host.Load.Run.Tpl (wideG decVal)
open _root_.Host.Load.Run.Tpl.DecOk (VP)
open _root_.Host.Route (machVal machReads)
open _root_.Host.Route.Cert
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The decode route at `L ≤ 224` over the template `DT4`

`DEC4.piecesFramedGpu`: the four chains `L ≤ 224` runs and the halting chains. `DEC4.tailsGpu`: their chains from the decode cut at `shortFixP`.
`DEC4.graphPieces`: their graph facts, the end tables read at the pins `decVal`. -/

section
variable {b0 : BSt} {NB T L : Nat} {tk : Nat → Nat} {toks : List NumV} {ρ : Nat → F64}
  {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The decode pieces of a prompt of at most 224 tokens, for budgets at least three. -/
noncomputable def DEC4.piecesFramedGpu (q : List Val) (hql : q.length = L)
    (hVP : ∀ i nx, i + 2 ≤ T → nx ≤ 2 ^ 20 → VP (valL ρ T tk L i nx))
    (h1 : 1 ≤ L) (hL : L ≤ 224) (hT : 3 ≤ T) (hctx : L + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hJ : DEC4G.ΔJ ≤ ΔJ) (hH : DEC4G.ΔH ≤ ΔH) (hN : DEC4G.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Dec.s0.ffi).next + T * ΔH + B.H + (Dec.Pw.E - (mlxOf Dec.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Dec.s0.ffi).nnext + T * ΔN + B.N + (Dec.Pw.NE - (mlxOf Dec.s0.ffi).nnext) < 2 ^ 62) :
    DecodePiecesFramedW (fullWorldFb b0 NB) addrPrompt Dec.Pw wideG Dec.s0 Dec.tab0 Dec4.fix4
      (framesG Dec.s0 q) ρ T tk L toks [.num (.ref 1)] B ΔJ ΔH ΔN where
  toDecodeCasesW :=
    have hV : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VP (valL ρ T tk L i nx) := fun i nx hi hnx => hVP i nx (by omega) hnx
    Gpu.casesOfFour hL
      (DEC4_ord.caseFixed q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb)
      (DEC4_clear.caseFixed q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb)
      (DEC4_grow.caseFixed q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb)
      (DEC4_fill.caseFixed q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb)
      rfl rfl rfl rfl
  f0 := DEC4.finalPlain b0 NB q
  f1 := DEC4.finalClear0 b0 NB q
  f2 := DEC4.finalClear1 b0 NB q
  c0 := DEC4.finalPlain_finalOk b0 NB q
  c1 := DEC4.finalClear0_finalOk b0 NB q
  c2 := DEC4.finalClear1_finalOk b0 NB q
  qF := by
    intro p1 K hfr hlo hhi
    have hv := hVP (T - 2) (tk T) (by omega) (by have := htv T le_rfl; omega)
    have hfr' : K.fr = frA (S := FF.S) addrPrompt Dec.s0 (framesG Dec.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num) := by
      change K.fr = frA (S := FF.S) addrPrompt Dec.s0 (framesG Dec.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 2 - 1)).map Val.num) at hfr
      simpa only [Nat.sub_sub, show 2 + 1 = (3 : Nat) by rfl] using hfr
    exact ⟨DEC4.finalPlain_entry b0 NB (q := q) (p1 := p1) (toks := toks) hv hT hctx htv hfr' hql hlo hhi,
      DEC4.finalClear0_entry b0 NB (q := q) (p1 := p1) (toks := toks) hv hT hctx htv hfr' hql hlo hhi,
      DEC4.finalClear1_entry b0 NB (q := q) (p1 := p1) (toks := toks) hv hT hctx htv hfr' hql hlo hhi⟩
  x := DEC4.eosCut b0 NB
  cX := DEC4.eosCut_exitOk b0 NB
  qX := by
    intro k hk hkT nx p1 K hnx hfr hlo hhi
    change K.fr = frA (S := FF.S) addrPrompt Dec.s0 (framesG Dec.s0 q).X p1
      ([.num (.ref 1)] ++ (toks.take (k - 1 - 1)).map Val.num) at hfr
    exact DEC4.eosCut_entry b0 NB (q := q) (p1 := p1) hVP hctx htv hfr hql hlo hhi k hk hkT nx hnx
  sX := DEC4.eosCut_stop b0 NB
  e0 := DEC4.finalEos0 b0 NB q
  e1 := DEC4.finalEos1 b0 NB q
  c0E := DEC4.finalEos0_finalOk b0 NB q
  c1E := DEC4.finalEos1_finalOk b0 NB q
  qE := by
    intro p1 K hfr hlo hhi
    have hv := hVP (T - 2) (tk T) (by omega) (by have := htv T le_rfl; omega)
    have hfr' : K.fr = frA (S := FF.S) addrPrompt Dec.s0 (framesG Dec.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num) := by
      change K.fr = frA (S := FF.S) addrPrompt Dec.s0 (framesG Dec.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 2 - 1)).map Val.num) at hfr
      simpa only [Nat.sub_sub, show 2 + 1 = (3 : Nat) by rfl] using hfr
    exact ⟨DEC4.finalEos0_entry b0 NB (q := q) (p1 := p1) (toks := toks) hv hT hctx htv hfr' hql hlo hhi,
      DEC4.finalEos1_entry b0 NB (q := q) (p1 := p1) (toks := toks) hv hT hctx htv hfr' hql hlo hhi⟩
  s0E := DEC4.finalEos0_stop b0 NB q
  s1E := DEC4.finalEos1_stop b0 NB q

/-- **Every decode case's chain from the decode cut at `shortFixP`.** -/
theorem DEC4.tailsGpu (q : List Val) (hql : q.length = L)
    (hVP : ∀ i nx, i + 2 ≤ T → nx ≤ 2 ^ 20 → VP (valL ρ T tk L i nx))
    (h1 : 1 ≤ L) (hL : L ≤ 224) (hT : 3 ≤ T) (hctx : L + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hJ : DEC4G.ΔJ ≤ ΔJ) (hH : DEC4G.ΔH ≤ ΔH) (hN : DEC4G.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Dec.s0.ffi).next + T * ΔH + B.H + (Dec.Pw.E - (mlxOf Dec.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Dec.s0.ffi).nnext + T * ΔN + B.N + (Dec.Pw.NE - (mlxOf Dec.s0.ffi).nnext) < 2 ^ 62) (k : DecKind) :
    TailFix (fullWorldFb b0 NB) addrPrompt wideG Dec.Pw (framesG Dec.s0 q) Dec.s0 Dec.tab0 Dec4.fix4 shortFixP (valL ρ T tk L) tk toks
      [.num (.ref 1)] B ΔJ ΔH ΔN
      ((DEC4.piecesFramedGpu (b0 := b0) (NB := NB) (ρ := ρ) (toks := toks) (B := B) q hql hVP h1 hL hT hctx htv hJ hH hN hJb hHb hNb).cs k) := by
  have hV : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VP (valL ρ T tk L i nx) := fun i nx hi hnx => hVP i nx (by omega) hnx
  cases k
  · exact DEC4_ord.tailS q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact DEC4_clear.tailS q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact DEC4_grow.tailS q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact DEC4_fill.tailS q hV h1 hctx (Nat.le_trans (by decide) hJ) (Nat.le_trans (by decide) hH) (Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact ⟨0, fun _ _ hs => (Gpu.clearFill_not hL hs.1.2.2).elim⟩
  · exact ⟨0, fun _ _ hs => (Gpu.clearGrow_not hL hs.1.2.2).elim⟩

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (env : FfiEval.Env InKey) (π : List Nat)
  {b0 : BSt} {NB T : Nat} {tk : Nat → Nat} {ρ : Nat → F64} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- **The decode graph facts of a prompt of at most 224 tokens**, at the saved source environment. -/
noncomputable def DEC4.graphPieces (q : List Val) (hql : q.length = π.length)
    (hVP : ∀ i nx, i + 2 ≤ T → nx ≤ 2 ^ 20 → VP (valL ρ T tk π.length i nx))
    (h1 : 1 ≤ π.length) (hL : π.length ≤ 224) (hT : 3 ≤ T) (hctx : π.length + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) (hNB : 15235 ≤ NB)
    (hJ : DEC4G.ΔJ ≤ ΔJ) (hH : DEC4G.ΔH ≤ ΔH) (hN : DEC4G.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Dec.s0.ffi).next + T * ΔH + B.H + (Dec.Pw.E - (mlxOf Dec.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Dec.s0.ffi).nnext + T * ΔN + B.N + (Dec.Pw.NE - (mlxOf Dec.s0.ffi).nnext) < 2 ^ 62) :
    Gpu.DecodeGraphR P KR env π decVal b0
      (entryEnv (_root_.Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk))) Dec.inputs
      (DEC4.piecesFramedGpu (b0 := b0) (NB := NB) (ρ := ρ)
        (toks := .ref 2 :: machReads T tk) q hql hVP h1 hL hT hctx htv hJ hH hN hJb hHb hNb) where
  st := Dec.startGM b0 NB
  en
    | .ord => Dec.ordEnd b0 NB
    | .clear => Dec.clearEnd b0 NB
    | .grow => Dec.growEnd b0 NB
    | .fill => Dec.fillEnd b0 NB
    | .clearFill => Dec.clearEnd b0 NB
    | .clearGrow => Dec.growEnd b0 NB
  tpl k i hs := by
    cases k
    · exact Dec.Ord.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact Dec.Clear.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact Dec.Grow.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact Dec.Fill.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact (Gpu.clearFill_not hL hs.1.2.2).elim
    · exact (Gpu.clearGrow_not hL hs.1.2.2).elim
  f0 := DEC4.finalPlain_graph b0 NB q _
  f1 := DEC4.finalClear0_graph b0 NB q _
  f2 := DEC4.finalClear1_graph b0 NB q _
  c0 := DEC4.finalPlain_savedCacheTpl b0 NB q _ (π.map natV) (machReads T tk)
  c1 := DEC4.finalClear0_savedCacheTpl b0 NB q _ (π.map natV) (machReads T tk)
  c2 := DEC4.finalClear1_savedCacheTpl b0 NB q _ (π.map natV) (machReads T tk)
  e0 := DEC4.finalEos0_graph b0 NB q _
  e1 := DEC4.finalEos1_graph b0 NB q _
  x _ := DEC4.eosCut_graph b0 NB _

end
end Host.Ts.Sim.Compose
