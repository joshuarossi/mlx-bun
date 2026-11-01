import host.sim.compose.a4b.Entry
import host.sim.compose.a4b.Fill_DEC_ord_Fixed
import host.sim.compose.a4b.Fill_DEC_clear_Fixed
import host.sim.compose.a4b.Fill_DEC_grow_Fixed
import host.sim.compose.a4b.Fill_DEC_fill_Fixed
import host.sim.compose.Gpu
import host.sim.compose.LoopFramed
import host.sim.compose.ValuationBounded
import host.sim.compose.a4b.FinalPlain
import host.sim.compose.a4b.FinalClear0
import host.sim.compose.a4b.FinalClear1
import host.sim.compose.a4b.FinalEos0
import host.sim.compose.a4b.FinalEos1
import host.sim.compose.a4b.EosCutFramed
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Prefill _root_.Host.Ts.Sim.Full
open _root_.Host.Ts.Sim.Template _root_.Host.Load.Layers _root_.Host.Load.Run.Prompt
open _root_.Host.Ts.Sim.Lin.Cls

/-! # The decode pieces at `L ≤ 224`

`DEC.piecesFramedFixed` from the four chains those prompts run: `clearFill` and `clearGrow` are never selected there
(`Gpu.casesOfFour`), so their chains are not imported. The halting pieces are the same. -/

/-- The four cases' counters (`DEC.ΔJ`, `DEC.ΔH`, `DEC.ΔN`). -/
def DECG.ΔJ : Nat := 151312
def DECG.ΔH : Nat := 3867
def DECG.ΔN : Nat := 4882

section
variable {b0 : BSt} {NB T L : Nat} {tk : Nat → Nat} {toks : List NumV} {ρ : Nat → F64}
  {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The decode pieces of a prompt of at most 224 tokens, for budgets at least three. -/
noncomputable def DEC.piecesFramedGpu (q : List Val) (hql : q.length = L)
    (hρ : ∀ j, ∃ n ≤ 2 ^ 20, ρ j = F64.ofNat n)
    (h1 : 1 ≤ L) (hL : L ≤ 224) (hT : 3 ≤ T) (hctx : L + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hJ : DECG.ΔJ ≤ ΔJ) (hH : DECG.ΔH ≤ ΔH) (hN : DECG.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62) :
    DecodePiecesFramedW (fullWorldFb b0 NB) addrPrompt DEC.Pw wideP DEC.s0 DEC.tab0 terminalFixP
      (framesP DEC.s0 q) ρ T tk L toks [.num (.ref 1)] B ΔJ ΔH ΔN where
  toDecodeCasesW :=
    have hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx) :=
      fun i nx hi hnx => valL_vb_supported hρ hctx htv i nx hi hnx
    Gpu.casesOfFour hL
      (DEC_ord.caseFixed q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb)
      (DEC_clear.caseFixed q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb)
      (DEC_grow.caseFixed q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb)
      (DEC_fill.caseFixed q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb)
      rfl rfl rfl rfl
  f0 := DEC.finalPlain b0 NB q
  f1 := DEC.finalClear0 b0 NB q
  f2 := DEC.finalClear1 b0 NB q
  c0 := DEC.finalPlain_finalOk b0 NB q
  c1 := DEC.finalClear0_finalOk b0 NB q
  c2 := DEC.finalClear1_finalOk b0 NB q
  qF := by
    intro p1 K hfr hlo hhi
    have hfr' : K.fr = frA (S := FF.S) addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num) := by
      change K.fr = frA (S := FF.S) addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 2 - 1)).map Val.num) at hfr
      simpa only [Nat.sub_sub, show 2 + 1 = (3 : Nat) by rfl] using hfr
    exact ⟨DEC.finalPlain_entry b0 NB (q := q) (p1 := p1) (toks := toks) hρ hT hctx htv hfr' hql hlo hhi,
      DEC.finalClear0_entry b0 NB (q := q) (p1 := p1) (toks := toks) hρ hT hctx htv hfr' hql hlo hhi,
      DEC.finalClear1_entry b0 NB (q := q) (p1 := p1) (toks := toks) hρ hT hctx htv hfr' hql hlo hhi⟩
  x := DEC.eosCutFramed b0 NB
  cX := DEC.eosCutFramed_exitOk b0 NB
  qX := by
    intro k hk hkT nx p1 K hnx hfr hlo hhi
    change K.fr = frA (S := FF.S) addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
      ([.num (.ref 1)] ++ (toks.take (k - 1 - 1)).map Val.num) at hfr
    exact DEC.eosCutFramed_entry b0 NB (q := q) (p1 := p1)
      hρ hctx htv hfr hql hlo hhi k hk hkT nx hnx
  sX := DEC.eosCutFramed_stop b0 NB
  e0 := DEC.finalEos0 b0 NB q
  e1 := DEC.finalEos1 b0 NB q
  c0E := DEC.finalEos0_finalOk b0 NB q
  c1E := DEC.finalEos1_finalOk b0 NB q
  qE := by
    intro p1 K hfr hlo hhi
    have hfr' : K.fr = frA (S := FF.S) addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num) := by
      change K.fr = frA (S := FF.S) addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
        ([.num (.ref 1)] ++ (toks.take (T - 2 - 1)).map Val.num) at hfr
      simpa only [Nat.sub_sub, show 2 + 1 = (3 : Nat) by rfl] using hfr
    exact ⟨DEC.finalEos0_entry b0 NB (q := q) (p1 := p1) (toks := toks) hρ hT hctx htv hfr' hql hlo hhi,
      DEC.finalEos1_entry b0 NB (q := q) (p1 := p1) (toks := toks) hρ hT hctx htv hfr' hql hlo hhi⟩
  s0E := DEC.finalEos0_stop b0 NB q
  s1E := DEC.finalEos1_stop b0 NB q

end
end Host.Ts.Sim.Compose
