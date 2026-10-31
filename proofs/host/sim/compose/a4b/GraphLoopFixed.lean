import host.sim.compose.a4b.DecodeFixed
import host.sim.compose.FixedGhost
import host.sim.compose.ValuationBounded
import host.sim.compose.a4b.GraphOrdLoop
import host.sim.compose.a4b.GraphClearLoop
import host.sim.compose.a4b.GraphGrowLoop
import host.sim.compose.a4b.GraphFillLoop
import host.sim.compose.a4b.GraphClearFillLoop
import host.sim.compose.a4b.GraphClearGrowLoop
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Prefill
open _root_.Host.Ts.Sim.Full _root_.Host.Ts.Sim.Template
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program
open _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter
open _root_.Host.Mlx.SimGraph.Mach (MRef MRefDecodes)
open _root_.Host.Ts.Sim.Lin.Cls
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
  (R : MRef) (L : Nat)
  (hdec : MRefDecodes M K (fun table => weights (firstValues M K env table)) R L)
  {b0 : Host.Mlx.FfiAne.St} {NB T : Nat} {ρ : Nat → F64} {tk : Nat → Nat} {toks : List NumV}
  {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

include leaves typed hdec

/-- The actual graph result for every selected case of the six-chain bundle. -/
theorem DEC.graphStepsFixed (q : List Val)
    (hρ : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k)
    (h1 : 1 ≤ L) (hctx : L + T ≤ 262144) (hNB : 15235 ≤ NB)
    (hJ : DEC.ΔJ ≤ ΔJ) (hH : DEC.ΔH ≤ ΔH) (hN : DEC.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62)
    (htkR : ∀ table j, j < T → ∃ cache, R table (L + j) = some (tk (j + 1), cache))
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) :
    let D := DEC.casesFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0)
      q (fun i nx hi hnx => valL_vb_supported hρ hctx htv i nx hi hnx) h1 hctx hJ hH hN hJb hHb hNb
    ∀ k i, DecSel T L tk k i → (∀ j, 1 ≤ j → j ≤ i + 1 → tk j ≠ 248044) →
      LoopGStepGW (liftG (fullWorldFb b0 NB) (GxM M K env DEC.inputs R L)) wideP
        (framesP DEC.s0 q) (D.cs k).e (D.cs k).g (valL ρ T tk L) toks i := by
  intro D k i hs _
  have ht : ∀ table j, j ≤ i + 2 → ∃ cache, R table (L + j) = some (tk (j + 1), cache) := by
    intro table j hj
    exact htkR table j (by have := hs.1.2.1; omega)
  have hb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31 := by
    intro j hj
    have hv := htv (j + 1) (by have := hs.1.2.1; omega)
    omega
  cases k with
  | ord =>
    have hσ : ∀ a ∈ [2586, 2589],
        (((Host.Load.Run.Tpl.DEC_ord.iterEnd NB).toFb b0).σ.a a) = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact DEC.FixedCells.ord_restart_2586
      · exact DEC.FixedCells.ord_restart_2589
    exact LoopGStepGW.withFixed ((Host.Load.Run.Tpl.DEC_ord.iterEnd NB).toFb b0) hσ
      (DECGraph.Ord.loopG M K env leaves typed R L hdec b0 NB T i ρ tk toks q
        (D.cs .ord).g hNB hctx hs ht hb)
  | clear =>
    have hσ : ∀ a ∈ [2586, 2589],
        (((Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0).σ.a a) = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact DEC.FixedCells.clear_restart_2586
      · exact DEC.FixedCells.clear_restart_2589
    exact LoopGStepGW.withFixed ((Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0) hσ
      (DECGraph.Clear.loopG M K env leaves typed R L hdec b0 NB T i ρ tk toks q
        (D.cs .clear).g hNB hctx hs ht hb)
  | grow =>
    have hσ : ∀ a ∈ [2586, 2589],
        (((Host.Load.Run.Tpl.DEC_grow.iterEnd NB).toFb b0).σ.a a) = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact DEC.FixedCells.grow_restart_2586
      · exact DEC.FixedCells.grow_restart_2589
    exact LoopGStepGW.withFixed ((Host.Load.Run.Tpl.DEC_grow.iterEnd NB).toFb b0) hσ
      (DECGraph.Grow.loopG M K env leaves typed R L hdec b0 NB T i ρ tk toks q
        (D.cs .grow).g hNB hctx hs ht hb)
  | fill =>
    have hσ : ∀ a ∈ [2586, 2589],
        (((Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0).σ.a a) = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact DEC.FixedCells.fill_restart_2586
      · exact DEC.FixedCells.fill_restart_2589
    exact LoopGStepGW.withFixed ((Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0) hσ
      (DECGraph.Fill.loopG M K env leaves typed R L hdec b0 NB T i ρ tk toks q
        (D.cs .fill).g hNB hctx hs ht hb)
  | clearFill =>
    have hσ : ∀ a ∈ [2586, 2589],
        (((Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0).σ.a a) = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact DEC.FixedCells.clearFill_restart_2586
      · exact DEC.FixedCells.clearFill_restart_2589
    exact LoopGStepGW.withFixed ((Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0) hσ
      (DECGraph.ClearFill.loopG M K env leaves typed R L hdec b0 NB T i ρ tk toks q
        (D.cs .clearFill).g hNB hctx hs ht hb)
  | clearGrow =>
    have hσ : ∀ a ∈ [2586, 2589],
        (((Host.Load.Run.Tpl.DEC_clearGrow.iterEnd NB).toFb b0).σ.a a) = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact DEC.FixedCells.clearGrow_restart_2586
      · exact DEC.FixedCells.clearGrow_restart_2589
    exact LoopGStepGW.withFixed ((Host.Load.Run.Tpl.DEC_clearGrow.iterEnd NB).toFb b0) hσ
      (DECGraph.ClearGrow.loopG M K env leaves typed R L hdec b0 NB T i ρ tk toks q
        (D.cs .clearGrow).g hNB hctx hs ht hb)

/-- General decode iteration from the actual source chains and their checked graphs. -/
theorem DEC.itersMFixed (q : List Val)
    (hρ : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k)
    (h1 : 1 ≤ L) (hctx : L + T ≤ 262144) (hNB : 15235 ≤ NB)
    (hJ : DEC.ΔJ ≤ ΔJ) (hH : DEC.ΔH ≤ ΔH) (hN : DEC.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62)
    (hlen : T - 2 ≤ toks.length)
    (htkR : ∀ table j, j < T → ∃ cache, R table (L + j) = some (tk (j + 1), cache))
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) :
    DecodeItersW (DecodeInvW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt
      (liftG (fullWorldFb b0 NB) (GxM M K env DEC.inputs R L)) wideP DEC.Pw
      (framesP DEC.s0 q) DEC.s0 DEC.tab0 terminalFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) T tk :=
  DEC.itersFixed q (fun i nx hi hnx => valL_vb_supported hρ hctx htv i nx hi hnx) h1 hctx hJ hH hN hJb hHb hNb hlen htv
    (DEC.graphStepsFixed M K env leaves typed R L hdec q hρ h1 hctx hNB hJ hH hN hJb hHb hNb htkR htv)

/-- A canonical finite-prefix valuation discharges the base valuation premise as well. -/
theorem DEC.itersMFixedBudget (q : List Val)
    (h1 : 1 ≤ L) (hctx : L + T ≤ 262144) (hNB : 15235 ≤ NB)
    (hJ : DEC.ΔJ ≤ ΔJ) (hH : DEC.ΔH ≤ ΔH) (hN : DEC.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62)
    (hlen : T - 2 ≤ toks.length)
    (htkR : ∀ table j, j < T → ∃ cache, R table (L + j) = some (tk (j + 1), cache))
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) :
    DecodeItersW (DecodeInvW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt
      (liftG (fullWorldFb b0 NB) (GxM M K env DEC.inputs R L)) wideP DEC.Pw
      (framesP DEC.s0 q) DEC.s0 DEC.tab0 terminalFixP (valL (budgetVal T tk) T tk L)
      tk toks E0 B ΔJ ΔH ΔN) T tk :=
  DEC.itersMFixed M K env leaves typed R L hdec q
    (budgetVal_bound (by omega) htv) h1 hctx hNB hJ hH hN hJb hHb hNb hlen htkR htv

end
end Host.Ts.Sim.Compose
