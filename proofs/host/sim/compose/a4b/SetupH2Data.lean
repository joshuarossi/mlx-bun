import host.sim.compose.a4b.PrefillSetupH2
import host.sim.compose.a4b.SetupLiteralCommon
import host.sim.template.a4pre_setup_h2_chunk.Canonical
import host.sim.template.a4pre_setup_h2_chunk.SiteR0
import host.sim.template.a4pre_setup_h2_chunk.SiteZ0
import host.sim.conv.CompactJs

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupH2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem startEq : (PRE_setup_h2_chunk.s0 : St FF.S) = PRE_setup_early_r0.s4 :=
  PRE_setup_h2_chunk.start_state.trans PRE_first_tail_x15_r0.call0_eq
theorem startTab : PRE_setup_h2_chunk.S0.tab = PRE_setup_early_r0.S4.tab :=
  PRE_setup_h2_chunk.start_tab.trans PRE_first_tail_x15_r0.call0_tab_eq
theorem canonicalEq : (PRE_setup_h2_chunk.s2 : St FF.S) =
    (PRE_setup_early_r0.s6 : St FF.S).ret (.num (.lit (F64.ofNat 512))) :=
  (show (PRE_setup_h2_chunk.s2 : St FF.S) = PRE_first_tail_x15_r0.s6.ret (.num (.lit (F64.ofNat 512)))
    from PRE_setup_h2_chunk.canonical_state).trans
      (congrArg (fun s : St FF.S => s.ret (.num (.lit (F64.ofNat 512)))) PRE_first_tail_x15_r0.chunk0_eq)
theorem canonicalTab : PRE_setup_h2_chunk.S2.tab = PRE_setup_early_r0.S6.tab :=
  PRE_setup_h2_chunk.canonical_tab.trans PRE_first_tail_x15_r0.chunk0_tab_eq

theorem callClean : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h2_chunk.s0 := by
  rw [startEq]
  exact SetupChunk.callClean

theorem jsPredicate : jsShiftBadB PRE_setup_h2_chunk.kappa0 = jsShiftBadB PRE_setup_early_r0.kappa0 := by
  rw [PRE_setup_h2_chunk.zkap0, PRE_setup_early_r0.zkap0]
  have hn : PRE_setup_h2_chunk.s0.next = PRE_setup_early_r0.s4.next := congrArg St.next startEq
  rw [hn]
  exact Conv.jsShiftBadB_compact_nil_rdata_eq PRE_setup_h2_chunk.kd0 PRE_setup_early_r0.kd0 (by decide) (by decide)

theorem canonicalJsHeap (a : Nat) (ha : Present PRE_setup_h2_chunk.s2 a) :
    noBigAtP (jsShiftBadB PRE_setup_h2_chunk.kappa0) PRE_setup_h2_chunk.s2 a = true := by
  rw [jsPredicate, canonicalEq]
  rw [canonicalEq] at ha
  exact SetupChunk.canonicalJsHeap a ha

theorem canonicalJsRoots : noBigRootsP (jsShiftBadB PRE_setup_h2_chunk.kappa0)
    PRE_setup_h2_chunk.s2.trace PRE_setup_h2_chunk.s2 = true := by
  rw [jsPredicate, canonicalEq]
  exact SetupChunk.canonicalJsRoots

theorem canonicalJsNative : bigsOutB jsLoN jsHiN (mlxOf PRE_setup_h2_chunk.s2.ffi) = true := by
  rw [canonicalEq]
  exact SetupChunk.canonicalJsNative

kernel_rfl sameNativeNext : (mlxOf PRE_setup_h2_chunk.s1.ffi).next = (mlxOf PRE_setup_h2_chunk.s2.ffi).next
kernel_rfl sameNativeNnext : (mlxOf PRE_setup_h2_chunk.s1.ffi).nnext = (mlxOf PRE_setup_h2_chunk.s2.ffi).nnext
kernel_rfl wsLow : PRE_setup_h2_chunk.ws0.all (Nat.ble 9) = true

end Host.Ts.Sim.Compose.SetupH2
