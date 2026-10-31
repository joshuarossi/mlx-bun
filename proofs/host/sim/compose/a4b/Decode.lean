import host.sim.compose.DecIter
import host.sim.compose.a4b.Entry
import host.sim.compose.a4b.Fill_DEC_ord
import host.sim.compose.a4b.Fill_DEC_clear
import host.sim.compose.a4b.Fill_DEC_grow
import host.sim.compose.a4b.Fill_DEC_fill
import host.sim.compose.a4b.Fill_DEC_clearFill
import host.sim.compose.a4b.Fill_DEC_clearGrow
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Load.Layers
open Host.Ts.Sim.Lin.Cls

/-! The six generated decode chains at their common source entry, for every pinned bridge.
`DEC.cases` supplies `DecodePiecesW.toDecodeCasesW`; the final and EOS halts remain separate. -/

/-- The maximum counter deltas of the six chains, including compactions. -/
def DEC.ΔJ : Nat := 151312
def DEC.ΔH : Nat := 3867
def DEC.ΔN : Nat := 4882

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat}
  {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}
  {Gx : Nat → Map → St FF.S → CSrv → Prop}

/-- All six loop cases, with the same prompt, budget, EOS selection and pinned bridge as the route. -/
noncomputable def DEC.cases (q : List Val)
    (hVB : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx))
    (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : DEC.ΔJ ≤ ΔJ) (hH : DEC.ΔH ≤ ΔH) (hN : DEC.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62) :
    DecodeCasesW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.Pw Template.wideP
      DEC.s0 DEC.tab0 Template.fixP (Template.framesP DEC.s0 q) ρ T tk L toks E0 B ΔJ ΔH ΔN where
  cs
    | .ord => DEC_ord.case q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
    | .clear => DEC_clear.case q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
    | .grow => DEC_grow.case q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
    | .fill => DEC_fill.case q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
    | .clearFill => DEC_clearFill.case q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
    | .clearGrow => DEC_clearGrow.case q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ)
        (by exact Nat.le_trans (by decide) hH) (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
  gr k := by cases k <;> rfl

/-- The decode iterations from the actual six chains, without any final or EOS halt pieces. -/
theorem DEC.iters (q : List Val)
    (hVB : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx))
    (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : DEC.ΔJ ≤ ΔJ) (hH : DEC.ΔH ≤ ΔH) (hN : DEC.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62)
    (hlen : T - 2 ≤ toks.length) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hG :
      let D := DEC.cases (b0 := b0) (NB := NB) (toks := toks) (E0 := E0)
        q hVB h1 hctx hJ hH hN hJb hHb hNb
      ∀ k i, DecSel T L tk k i → (∀ j, 1 ≤ j → j ≤ i + 1 → tk j ≠ 248044) →
        LoopGStepGW Gx Template.wideP (Template.framesP DEC.s0 q)
          (D.cs k).e (D.cs k).g (valL ρ T tk L) toks i) :
    DecodeItersW (DecodeInvW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Gx Template.wideP DEC.Pw
      (Template.framesP DEC.s0 q) DEC.s0 DEC.tab0 Template.fixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) T tk :=
  (DEC.cases q hVB h1 hctx hJ hH hN hJb hHb hNb).itersW (fullWorldFb_end b0 NB) rfl (DEC.start b0 NB)
    (by omega) hlen (fun j hj => Nat.le_trans (htv j hj) (by decide)) htv hJb hHb hNb hG

end
end Host.Ts.Sim.Compose
