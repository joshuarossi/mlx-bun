import host.sim.compose.a4b.PrefillFirstTailX15
import host.sim.compose.a4b.SetupLiteralCommon
import host.sim.template.a4pre_first_tail_x15_r0.SharedStart
import host.sim.template.a4pre_first_tail_x15_r0.SiteR0
import host.sim.template.a4pre_first_tail_x15_r0.SiteZ0
import host.sim.conv.CompactJs

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupH0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly

theorem startEq : (PRE_first_tail_x15_r0.s4 : St FF.S) = PRE_setup_early_r0.s4 :=
  PRE_first_tail_x15_r0.call0_eq
theorem startTab : PRE_first_tail_x15_r0.S4.tab = PRE_setup_early_r0.S4.tab := PRE_first_tail_x15_r0.call0_tab_eq
private theorem ret_same {S : Type} {s : St S} {v : Val} (hc : s.ctl = .ret v) : s.ret v = s := by
  cases s
  cases hc
  rfl
theorem canonicalEq : (PRE_first_tail_x15_r0.s6 : St FF.S) =
    (PRE_setup_early_r0.s6 : St FF.S).ret (.num (.lit (F64.ofNat 2048))) :=
  (show (PRE_first_tail_x15_r0.s6 : St FF.S) = PRE_setup_early_r0.s6 from PRE_first_tail_x15_r0.chunk0_eq).trans
    (ret_same SetupChunk.chunkLiteral6).symm
theorem canonicalTab : PRE_first_tail_x15_r0.S6.tab = PRE_setup_early_r0.S6.tab := PRE_first_tail_x15_r0.chunk0_tab_eq

theorem callClean : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s4 := by
  rw [startEq]
  exact SetupChunk.callClean

theorem jsPredicate : jsShiftBadB PRE_first_tail_x15_r0.kappa0 = jsShiftBadB PRE_setup_early_r0.kappa0 := by
  rw [PRE_first_tail_x15_r0.zkap0, PRE_setup_early_r0.zkap0]
  have hn : PRE_first_tail_x15_r0.s4.next = PRE_setup_early_r0.s4.next := congrArg St.next startEq
  rw [hn]
  exact Conv.jsShiftBadB_compact_nil_rdata_eq PRE_first_tail_x15_r0.kd0 PRE_setup_early_r0.kd0 (by decide) (by decide)

theorem canonicalJsHeap (a : Nat) (ha : Present PRE_first_tail_x15_r0.s6 a) :
    noBigAtP (jsShiftBadB PRE_first_tail_x15_r0.kappa0) PRE_first_tail_x15_r0.s6 a = true := by
  rw [jsPredicate, canonicalEq]
  rw [canonicalEq] at ha
  exact SetupChunk.canonicalJsHeap a ha

theorem canonicalJsRoots : noBigRootsP (jsShiftBadB PRE_first_tail_x15_r0.kappa0)
    PRE_first_tail_x15_r0.s6.trace PRE_first_tail_x15_r0.s6 = true := by
  rw [jsPredicate, canonicalEq]
  exact SetupChunk.canonicalJsRoots

theorem canonicalJsNative : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0.s6.ffi) = true := by
  rw [canonicalEq]
  exact SetupChunk.canonicalJsNative

kernel_rfl sameNativeNext : (mlxOf PRE_first_tail_x15_r0.s5.ffi).next = (mlxOf PRE_first_tail_x15_r0.s6.ffi).next
kernel_rfl sameNativeNnext : (mlxOf PRE_first_tail_x15_r0.s5.ffi).nnext = (mlxOf PRE_first_tail_x15_r0.s6.ffi).nnext
kernel_rfl wsLow : PRE_first_tail_x15_r0.ws0.all (Nat.ble 9) = true

end Host.Ts.Sim.Compose.SetupH0
