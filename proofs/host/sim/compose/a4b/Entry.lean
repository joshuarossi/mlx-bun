import host.sim.compose.Loop
import host.sim.full.BridgeFrame
import host.sim.conv.CompactShift
import host.sim.template.a4dec_ord.EFacts
import host.load.run.prompt.Addr
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Load.Layers

abbrev DEC.Pw : LoadP := Host.Load.Run.Tpl.DEC_ord.PE
noncomputable abbrev DEC.s0 : St FF.S := Host.Load.Run.Tpl.DEC_ord.s0
noncomputable abbrev DEC.tab0 : List SymE := Host.Load.Run.Tpl.DEC_ord.S0.tab

/-- The common entry is the existing decode template with only its live readback token. -/
theorem DEC.source : DEC.s0 = Host.Load.Run.Tpl.DT.s0.setFfi
    (fullSetTokens Host.Load.Run.Tpl.DT.s0.ffi [.ref 79]) :=
  Host.Load.Run.Tpl.DEC_ord.s0_tok

kernel_rfl DEC.startTok : (mlxOf DEC.s0.ffi).tokens = [.ref Host.Load.Run.Prompt.addrPrompt.tok]
kernel_rfl DEC.startBig : bigsOutB (mlxOf DEC.s0.ffi).next DEC.Pw.E (mlxOf DEC.s0.ffi) = true
kernel_rfl DEC.startRoots : noBigRootsP
    (fun i => !Conv.oldBigB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) i) DEC.s0.trace DEC.s0 = true

/-- The loop start facts are checked at the source entry for every pinned bridge. -/
theorem DEC.start (b0 : BSt) (NB : Nat) :
    LoopStartW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.Pw DEC.s0 DEC.tab0 where
  htok := by decide +kernel
  start := ⟨DEC.startTok, DEC.startBig,
    Conv.jclean_noBigSt Host.Load.Run.Tpl.DEC_ord.jclean0 (by decide +kernel) (by decide) DEC.startRoots⟩
  lo := by
    change DEC.Pw.lo ≤ (mlxOf DEC.s0.ffi).next
    decide +kernel
  hi := by
    change DEC.Pw.E ≤ 2 ^ 56
    decide

end Host.Ts.Sim.Compose
