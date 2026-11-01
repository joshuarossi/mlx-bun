import host.sim.template.a4pre_d1_body.TraceAdvance
import host.sim.template.a4pre_d1_body.m.B10
import host.sim.template.a4pre_d1_body.SizeAdvance
import host.sim.template.a4pre_d1_body.m.B04
import host.sim.template.a4pre_d1_body.m.B05
import host.sim.template.a4pre_d1_body.m.B06
import host.sim.template.a4pre_d1_body.m.B07
import host.sim.template.a4pre_d1_body.m.B08
import host.sim.template.a4pre_d1_body.m.B09

section -- SP83
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece83 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s286 D1BodySized.S286) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s289 D1BodySized.S289) 7938 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted83 D1BodySized.segment83 D1BodySized.acceptedP84
    D1BodySized.haltP84 D1BodySized.stepA84 D1BodySized.topA84
    D1BodySized.oracle83 D1BodySized.fromInactive83 D1BodySized.bridgeInto83 D1BodySized.fromTable20_83
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA84 D1BodySized.sizeArgsA84 D1BodySized.sizeSymA84
    D1BodySized.sizeMlxA84 D1BodySized.sizePayA84 (by decide)
    D1BodySized.sizeDecA84 D1BodySized.sizePreA84 D1BodySized.patchB84
    D1BodySized.sizeOracle83 D1BodySized.inactive84 D1BodySized.bridgeOut83 D1BodySized.sizeTable20_83
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ84
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive84 : (bridgeOf D1BodySized.s289.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check84 : decide (20 ≤ D1BodySized.S289.tab.length) = true
theorem D1BodySized.fromTable20_84 : 20 ≤ D1BodySized.S289.tab.length := of_decide_eq_true D1BodySized.fromTable20Check84
kernel_rfl D1BodySized.bridgeInto84 : bridgeOf D1BodySized.s291.ffi = bridgeOf D1BodySized.s289.ffi
kernel_rfl D1BodySized.bridgeOut84 : bridgeOf D1BodySized.s292.ffi = bridgeOf D1BodySized.s291.ffi
kernel_rfl D1BodySized.sizeTable20Check84 : decide (20 ≤ D1BodySized.S291.tab.length) = true
theorem D1BodySized.sizeTable20_84 : 20 ≤ D1BodySized.S291.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check84
kernel_rfl D1BodySized.sizeOracle84 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S291.oracle = true

end Host.Load.Run.Tpl
end

section -- SP84
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece84 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s289 D1BodySized.S289) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s292 D1BodySized.S292) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted84 D1BodySized.segment84 D1BodySized.acceptedP85
    D1BodySized.haltP85 D1BodySized.stepA85 D1BodySized.topA85
    D1BodySized.oracle84 D1BodySized.fromInactive84 D1BodySized.bridgeInto84 D1BodySized.fromTable20_84
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA85 D1BodySized.sizeArgsA85 D1BodySized.sizeSymA85
    D1BodySized.sizeMlxA85 D1BodySized.sizePayA85 (by decide)
    D1BodySized.sizeDecA85 D1BodySized.sizePreA85 D1BodySized.patchB85
    D1BodySized.sizeOracle84 D1BodySized.inactive85 D1BodySized.bridgeOut84 D1BodySized.sizeTable20_84
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ85
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive85 : (bridgeOf D1BodySized.s292.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check85 : decide (20 ≤ D1BodySized.S292.tab.length) = true
theorem D1BodySized.fromTable20_85 : 20 ≤ D1BodySized.S292.tab.length := of_decide_eq_true D1BodySized.fromTable20Check85
kernel_rfl D1BodySized.bridgeInto85 : bridgeOf D1BodySized.s295.ffi = bridgeOf D1BodySized.s292.ffi
kernel_rfl D1BodySized.bridgeOut85 : bridgeOf D1BodySized.s296.ffi = bridgeOf D1BodySized.s295.ffi
kernel_rfl D1BodySized.sizeTable20Check85 : decide (20 ≤ D1BodySized.S295.tab.length) = true
theorem D1BodySized.sizeTable20_85 : 20 ≤ D1BodySized.S295.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check85
kernel_rfl D1BodySized.sizeOracle85 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S295.oracle = true

end Host.Load.Run.Tpl
end

section -- SP85
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece85 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s292 D1BodySized.S292) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s296 D1BodySized.S296) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted85 D1BodySized.segment85 D1BodySized.acceptedP86
    D1BodySized.haltP86 D1BodySized.stepA86 D1BodySized.topA86
    D1BodySized.oracle85 D1BodySized.fromInactive85 D1BodySized.bridgeInto85 D1BodySized.fromTable20_85
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA86 D1BodySized.sizeArgsA86 D1BodySized.sizeSymA86
    D1BodySized.sizeMlxA86 D1BodySized.sizePayA86 (by decide)
    D1BodySized.sizeDecA86 D1BodySized.sizePreA86 D1BodySized.patchB86
    D1BodySized.sizeOracle85 D1BodySized.inactive86 D1BodySized.bridgeOut85 D1BodySized.sizeTable20_85
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ86
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive86 : (bridgeOf D1BodySized.s296.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check86 : decide (20 ≤ D1BodySized.S296.tab.length) = true
theorem D1BodySized.fromTable20_86 : 20 ≤ D1BodySized.S296.tab.length := of_decide_eq_true D1BodySized.fromTable20Check86
kernel_rfl D1BodySized.bridgeInto86 : bridgeOf D1BodySized.s298.ffi = bridgeOf D1BodySized.s296.ffi
kernel_rfl D1BodySized.bridgeOut86 : bridgeOf D1BodySized.s299.ffi = bridgeOf D1BodySized.s298.ffi
kernel_rfl D1BodySized.sizeTable20Check86 : decide (20 ≤ D1BodySized.S298.tab.length) = true
theorem D1BodySized.sizeTable20_86 : 20 ≤ D1BodySized.S298.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check86
kernel_rfl D1BodySized.sizeOracle86 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S298.oracle = true

end Host.Load.Run.Tpl
end

section -- SP86
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece86 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s296 D1BodySized.S296) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s299 D1BodySized.S299) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted86 D1BodySized.segment86 D1BodySized.acceptedP87
    D1BodySized.haltP87 D1BodySized.stepA87 D1BodySized.topA87
    D1BodySized.oracle86 D1BodySized.fromInactive86 D1BodySized.bridgeInto86 D1BodySized.fromTable20_86
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA87 D1BodySized.sizeArgsA87 D1BodySized.sizeSymA87
    D1BodySized.sizeMlxA87 D1BodySized.sizePayA87 (by decide)
    D1BodySized.sizeDecA87 D1BodySized.sizePreA87 D1BodySized.patchB87
    D1BodySized.sizeOracle86 D1BodySized.inactive87 D1BodySized.bridgeOut86 D1BodySized.sizeTable20_86
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ87
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive87 : (bridgeOf D1BodySized.s299.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check87 : decide (20 ≤ D1BodySized.S299.tab.length) = true
theorem D1BodySized.fromTable20_87 : 20 ≤ D1BodySized.S299.tab.length := of_decide_eq_true D1BodySized.fromTable20Check87
kernel_rfl D1BodySized.bridgeInto87 : bridgeOf D1BodySized.s301.ffi = bridgeOf D1BodySized.s299.ffi
kernel_rfl D1BodySized.bridgeOut87 : bridgeOf D1BodySized.s302.ffi = bridgeOf D1BodySized.s301.ffi
kernel_rfl D1BodySized.sizeTable20Check87 : decide (20 ≤ D1BodySized.S301.tab.length) = true
theorem D1BodySized.sizeTable20_87 : 20 ≤ D1BodySized.S301.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check87
kernel_rfl D1BodySized.sizeOracle87 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S301.oracle = true

end Host.Load.Run.Tpl
end

section -- SP87
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece87 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s299 D1BodySized.S299) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s302 D1BodySized.S302) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted87 D1BodySized.segment87 D1BodySized.acceptedP88
    D1BodySized.haltP88 D1BodySized.stepA88 D1BodySized.topA88
    D1BodySized.oracle87 D1BodySized.fromInactive87 D1BodySized.bridgeInto87 D1BodySized.fromTable20_87
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA88 D1BodySized.sizeArgsA88 D1BodySized.sizeSymA88
    D1BodySized.sizeMlxA88 D1BodySized.sizePayA88 (by decide)
    D1BodySized.sizeDecA88 D1BodySized.sizePreA88 D1BodySized.patchB88
    D1BodySized.sizeOracle87 D1BodySized.inactive88 D1BodySized.bridgeOut87 D1BodySized.sizeTable20_87
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ88
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive88 : (bridgeOf D1BodySized.s302.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check88 : decide (20 ≤ D1BodySized.S302.tab.length) = true
theorem D1BodySized.fromTable20_88 : 20 ≤ D1BodySized.S302.tab.length := of_decide_eq_true D1BodySized.fromTable20Check88
kernel_rfl D1BodySized.bridgeInto88 : bridgeOf D1BodySized.s304.ffi = bridgeOf D1BodySized.s302.ffi
kernel_rfl D1BodySized.bridgeOut88 : bridgeOf D1BodySized.s305.ffi = bridgeOf D1BodySized.s304.ffi
kernel_rfl D1BodySized.sizeTable20Check88 : decide (20 ≤ D1BodySized.S304.tab.length) = true
theorem D1BodySized.sizeTable20_88 : 20 ≤ D1BodySized.S304.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check88
kernel_rfl D1BodySized.sizeOracle88 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S304.oracle = true

end Host.Load.Run.Tpl
end

section -- SP88
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece88 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s302 D1BodySized.S302) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s305 D1BodySized.S305) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted88 D1BodySized.segment88 D1BodySized.acceptedP89
    D1BodySized.haltP89 D1BodySized.stepA89 D1BodySized.topA89
    D1BodySized.oracle88 D1BodySized.fromInactive88 D1BodySized.bridgeInto88 D1BodySized.fromTable20_88
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA89 D1BodySized.sizeArgsA89 D1BodySized.sizeSymA89
    D1BodySized.sizeMlxA89 D1BodySized.sizePayA89 (by decide)
    D1BodySized.sizeDecA89 D1BodySized.sizePreA89 D1BodySized.patchB89
    D1BodySized.sizeOracle88 D1BodySized.inactive89 D1BodySized.bridgeOut88 D1BodySized.sizeTable20_88
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ89
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive89 : (bridgeOf D1BodySized.s305.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check89 : decide (20 ≤ D1BodySized.S305.tab.length) = true
theorem D1BodySized.fromTable20_89 : 20 ≤ D1BodySized.S305.tab.length := of_decide_eq_true D1BodySized.fromTable20Check89
kernel_rfl D1BodySized.bridgeInto89 : bridgeOf D1BodySized.s308.ffi = bridgeOf D1BodySized.s305.ffi
kernel_rfl D1BodySized.bridgeOut89 : bridgeOf D1BodySized.s309.ffi = bridgeOf D1BodySized.s308.ffi
kernel_rfl D1BodySized.sizeTable20Check89 : decide (20 ≤ D1BodySized.S308.tab.length) = true
theorem D1BodySized.sizeTable20_89 : 20 ≤ D1BodySized.S308.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check89
kernel_rfl D1BodySized.sizeOracle89 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S308.oracle = true

end Host.Load.Run.Tpl
end

section -- SP89
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece89 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s305 D1BodySized.S305) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s309 D1BodySized.S309) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted89 D1BodySized.segment89 D1BodySized.acceptedP90
    D1BodySized.haltP90 D1BodySized.stepA90 D1BodySized.topA90
    D1BodySized.oracle89 D1BodySized.fromInactive89 D1BodySized.bridgeInto89 D1BodySized.fromTable20_89
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA90 D1BodySized.sizeArgsA90 D1BodySized.sizeSymA90
    D1BodySized.sizeMlxA90 D1BodySized.sizePayA90 (by decide)
    D1BodySized.sizeDecA90 D1BodySized.sizePreA90 D1BodySized.patchB90
    D1BodySized.sizeOracle89 D1BodySized.inactive90 D1BodySized.bridgeOut89 D1BodySized.sizeTable20_89
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ90
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive90 : (bridgeOf D1BodySized.s309.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check90 : decide (20 ≤ D1BodySized.S309.tab.length) = true
theorem D1BodySized.fromTable20_90 : 20 ≤ D1BodySized.S309.tab.length := of_decide_eq_true D1BodySized.fromTable20Check90
kernel_rfl D1BodySized.bridgeInto90 : bridgeOf D1BodySized.s311.ffi = bridgeOf D1BodySized.s309.ffi
kernel_rfl D1BodySized.bridgeOut90 : bridgeOf D1BodySized.s312.ffi = bridgeOf D1BodySized.s311.ffi
kernel_rfl D1BodySized.sizeTable20Check90 : decide (20 ≤ D1BodySized.S311.tab.length) = true
theorem D1BodySized.sizeTable20_90 : 20 ≤ D1BodySized.S311.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check90
kernel_rfl D1BodySized.sizeOracle90 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S311.oracle = true

end Host.Load.Run.Tpl
end

section -- SP90
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece90 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s309 D1BodySized.S309) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s312 D1BodySized.S312) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted90 D1BodySized.segment90 D1BodySized.acceptedP91
    D1BodySized.haltP91 D1BodySized.stepA91 D1BodySized.topA91
    D1BodySized.oracle90 D1BodySized.fromInactive90 D1BodySized.bridgeInto90 D1BodySized.fromTable20_90
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA91 D1BodySized.sizeArgsA91 D1BodySized.sizeSymA91
    D1BodySized.sizeMlxA91 D1BodySized.sizePayA91 (by decide)
    D1BodySized.sizeDecA91 D1BodySized.sizePreA91 D1BodySized.patchB91
    D1BodySized.sizeOracle90 D1BodySized.inactive91 D1BodySized.bridgeOut90 D1BodySized.sizeTable20_90
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ91
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive91 : (bridgeOf D1BodySized.s312.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check91 : decide (20 ≤ D1BodySized.S312.tab.length) = true
theorem D1BodySized.fromTable20_91 : 20 ≤ D1BodySized.S312.tab.length := of_decide_eq_true D1BodySized.fromTable20Check91
kernel_rfl D1BodySized.bridgeInto91 : bridgeOf D1BodySized.s314.ffi = bridgeOf D1BodySized.s312.ffi
kernel_rfl D1BodySized.bridgeOut91 : bridgeOf D1BodySized.s315.ffi = bridgeOf D1BodySized.s314.ffi
kernel_rfl D1BodySized.sizeTable20Check91 : decide (20 ≤ D1BodySized.S314.tab.length) = true
theorem D1BodySized.sizeTable20_91 : 20 ≤ D1BodySized.S314.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check91
kernel_rfl D1BodySized.sizeOracle91 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S314.oracle = true

end Host.Load.Run.Tpl
end

section -- SP91
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece91 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s312 D1BodySized.S312) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s315 D1BodySized.S315) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted91 D1BodySized.segment91 D1BodySized.acceptedP92
    D1BodySized.haltP92 D1BodySized.stepA92 D1BodySized.topA92
    D1BodySized.oracle91 D1BodySized.fromInactive91 D1BodySized.bridgeInto91 D1BodySized.fromTable20_91
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA92 D1BodySized.sizeArgsA92 D1BodySized.sizeSymA92
    D1BodySized.sizeMlxA92 D1BodySized.sizePayA92 (by decide)
    D1BodySized.sizeDecA92 D1BodySized.sizePreA92 D1BodySized.patchB92
    D1BodySized.sizeOracle91 D1BodySized.inactive92 D1BodySized.bridgeOut91 D1BodySized.sizeTable20_91
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ92
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive92 : (bridgeOf D1BodySized.s315.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check92 : decide (20 ≤ D1BodySized.S315.tab.length) = true
theorem D1BodySized.fromTable20_92 : 20 ≤ D1BodySized.S315.tab.length := of_decide_eq_true D1BodySized.fromTable20Check92
kernel_rfl D1BodySized.bridgeInto92 : bridgeOf D1BodySized.s317.ffi = bridgeOf D1BodySized.s315.ffi
kernel_rfl D1BodySized.bridgeOut92 : bridgeOf D1BodySized.s318.ffi = bridgeOf D1BodySized.s317.ffi
kernel_rfl D1BodySized.sizeTable20Check92 : decide (20 ≤ D1BodySized.S317.tab.length) = true
theorem D1BodySized.sizeTable20_92 : 20 ≤ D1BodySized.S317.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check92
kernel_rfl D1BodySized.sizeOracle92 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S317.oracle = true

end Host.Load.Run.Tpl
end

section -- SP92
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece92 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s315 D1BodySized.S315) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s318 D1BodySized.S318) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted92 D1BodySized.segment92 D1BodySized.acceptedP93
    D1BodySized.haltP93 D1BodySized.stepA93 D1BodySized.topA93
    D1BodySized.oracle92 D1BodySized.fromInactive92 D1BodySized.bridgeInto92 D1BodySized.fromTable20_92
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA93 D1BodySized.sizeArgsA93 D1BodySized.sizeSymA93
    D1BodySized.sizeMlxA93 D1BodySized.sizePayA93 (by decide)
    D1BodySized.sizeDecA93 D1BodySized.sizePreA93 D1BodySized.patchB93
    D1BodySized.sizeOracle92 D1BodySized.inactive93 D1BodySized.bridgeOut92 D1BodySized.sizeTable20_92
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ93
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive93 : (bridgeOf D1BodySized.s318.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check93 : decide (20 ≤ D1BodySized.S318.tab.length) = true
theorem D1BodySized.fromTable20_93 : 20 ≤ D1BodySized.S318.tab.length := of_decide_eq_true D1BodySized.fromTable20Check93
kernel_rfl D1BodySized.bridgeInto93 : bridgeOf D1BodySized.s321.ffi = bridgeOf D1BodySized.s318.ffi
kernel_rfl D1BodySized.bridgeOut93 : bridgeOf D1BodySized.s322.ffi = bridgeOf D1BodySized.s321.ffi
kernel_rfl D1BodySized.sizeTable20Check93 : decide (20 ≤ D1BodySized.S321.tab.length) = true
theorem D1BodySized.sizeTable20_93 : 20 ≤ D1BodySized.S321.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check93
kernel_rfl D1BodySized.sizeOracle93 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S321.oracle = true

end Host.Load.Run.Tpl
end

section -- SP93
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece93 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s318 D1BodySized.S318) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s322 D1BodySized.S322) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted93 D1BodySized.segment93 D1BodySized.acceptedP94
    D1BodySized.haltP94 D1BodySized.stepA94 D1BodySized.topA94
    D1BodySized.oracle93 D1BodySized.fromInactive93 D1BodySized.bridgeInto93 D1BodySized.fromTable20_93
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA94 D1BodySized.sizeArgsA94 D1BodySized.sizeSymA94
    D1BodySized.sizeMlxA94 D1BodySized.sizePayA94 (by decide)
    D1BodySized.sizeDecA94 D1BodySized.sizePreA94 D1BodySized.patchB94
    D1BodySized.sizeOracle93 D1BodySized.inactive94 D1BodySized.bridgeOut93 D1BodySized.sizeTable20_93
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ94
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive94 : (bridgeOf D1BodySized.s322.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check94 : decide (20 ≤ D1BodySized.S322.tab.length) = true
theorem D1BodySized.fromTable20_94 : 20 ≤ D1BodySized.S322.tab.length := of_decide_eq_true D1BodySized.fromTable20Check94
kernel_rfl D1BodySized.bridgeInto94 : bridgeOf D1BodySized.s324.ffi = bridgeOf D1BodySized.s322.ffi
kernel_rfl D1BodySized.bridgeOut94 : bridgeOf D1BodySized.s325.ffi = bridgeOf D1BodySized.s324.ffi
kernel_rfl D1BodySized.sizeTable20Check94 : decide (20 ≤ D1BodySized.S324.tab.length) = true
theorem D1BodySized.sizeTable20_94 : 20 ≤ D1BodySized.S324.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check94
kernel_rfl D1BodySized.sizeOracle94 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S324.oracle = true

end Host.Load.Run.Tpl
end

section -- SP94
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece94 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s322 D1BodySized.S322) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s325 D1BodySized.S325) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted94 D1BodySized.segment94 D1BodySized.acceptedP95
    D1BodySized.haltP95 D1BodySized.stepA95 D1BodySized.topA95
    D1BodySized.oracle94 D1BodySized.fromInactive94 D1BodySized.bridgeInto94 D1BodySized.fromTable20_94
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA95 D1BodySized.sizeArgsA95 D1BodySized.sizeSymA95
    D1BodySized.sizeMlxA95 D1BodySized.sizePayA95 (by decide)
    D1BodySized.sizeDecA95 D1BodySized.sizePreA95 D1BodySized.patchB95
    D1BodySized.sizeOracle94 D1BodySized.inactive95 D1BodySized.bridgeOut94 D1BodySized.sizeTable20_94
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ95
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive95 : (bridgeOf D1BodySized.s325.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check95 : decide (20 ≤ D1BodySized.S325.tab.length) = true
theorem D1BodySized.fromTable20_95 : 20 ≤ D1BodySized.S325.tab.length := of_decide_eq_true D1BodySized.fromTable20Check95
kernel_rfl D1BodySized.bridgeInto95 : bridgeOf D1BodySized.s329.ffi = bridgeOf D1BodySized.s325.ffi
kernel_rfl D1BodySized.bridgeOut95 : bridgeOf D1BodySized.s330.ffi = bridgeOf D1BodySized.s329.ffi
kernel_rfl D1BodySized.sizeTable20Check95 : decide (20 ≤ D1BodySized.S329.tab.length) = true
theorem D1BodySized.sizeTable20_95 : 20 ≤ D1BodySized.S329.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check95
kernel_rfl D1BodySized.sizeOracle95 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S329.oracle = true

end Host.Load.Run.Tpl
end

section -- SP95
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece95 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s325 D1BodySized.S325) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s330 D1BodySized.S330) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted95 D1BodySized.segment95 D1BodySized.acceptedP96
    D1BodySized.haltP96 D1BodySized.stepA96 D1BodySized.topA96
    D1BodySized.oracle95 D1BodySized.fromInactive95 D1BodySized.bridgeInto95 D1BodySized.fromTable20_95
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA96 D1BodySized.sizeArgsA96 D1BodySized.sizeSymA96
    D1BodySized.sizeMlxA96 D1BodySized.sizePayA96 (by decide)
    D1BodySized.sizeDecA96 D1BodySized.sizePreA96 D1BodySized.patchB96
    D1BodySized.sizeOracle95 D1BodySized.inactive96 D1BodySized.bridgeOut95 D1BodySized.sizeTable20_95
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ96
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive96 : (bridgeOf D1BodySized.s330.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check96 : decide (20 ≤ D1BodySized.S330.tab.length) = true
theorem D1BodySized.fromTable20_96 : 20 ≤ D1BodySized.S330.tab.length := of_decide_eq_true D1BodySized.fromTable20Check96
kernel_rfl D1BodySized.bridgeInto96 : bridgeOf D1BodySized.s332.ffi = bridgeOf D1BodySized.s330.ffi
kernel_rfl D1BodySized.bridgeOut96 : bridgeOf D1BodySized.s333.ffi = bridgeOf D1BodySized.s332.ffi
kernel_rfl D1BodySized.sizeTable20Check96 : decide (20 ≤ D1BodySized.S332.tab.length) = true
theorem D1BodySized.sizeTable20_96 : 20 ≤ D1BodySized.S332.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check96
kernel_rfl D1BodySized.sizeOracle96 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S332.oracle = true

end Host.Load.Run.Tpl
end

section -- SP96
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece96 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s330 D1BodySized.S330) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s333 D1BodySized.S333) 7984 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted96 D1BodySized.segment96 D1BodySized.acceptedP97
    D1BodySized.haltP97 D1BodySized.stepA97 D1BodySized.topA97
    D1BodySized.oracle96 D1BodySized.fromInactive96 D1BodySized.bridgeInto96 D1BodySized.fromTable20_96
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA97 D1BodySized.sizeArgsA97 D1BodySized.sizeSymA97
    D1BodySized.sizeMlxA97 D1BodySized.sizePayA97 (by decide)
    D1BodySized.sizeDecA97 D1BodySized.sizePreA97 D1BodySized.patchB97
    D1BodySized.sizeOracle96 D1BodySized.inactive97 D1BodySized.bridgeOut96 D1BodySized.sizeTable20_96
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ97
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive97 : (bridgeOf D1BodySized.s333.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check97 : decide (20 ≤ D1BodySized.S333.tab.length) = true
theorem D1BodySized.fromTable20_97 : 20 ≤ D1BodySized.S333.tab.length := of_decide_eq_true D1BodySized.fromTable20Check97
kernel_rfl D1BodySized.bridgeInto97 : bridgeOf D1BodySized.s335.ffi = bridgeOf D1BodySized.s333.ffi
kernel_rfl D1BodySized.bridgeOut97 : bridgeOf D1BodySized.s336.ffi = bridgeOf D1BodySized.s335.ffi
kernel_rfl D1BodySized.sizeTable20Check97 : decide (20 ≤ D1BodySized.S335.tab.length) = true
theorem D1BodySized.sizeTable20_97 : 20 ≤ D1BodySized.S335.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check97
kernel_rfl D1BodySized.sizeOracle97 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S335.oracle = true

end Host.Load.Run.Tpl
end

section -- SP97
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece97 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s333 D1BodySized.S333) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s336 D1BodySized.S336) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted97 D1BodySized.segment97 D1BodySized.acceptedP98
    D1BodySized.haltP98 D1BodySized.stepA98 D1BodySized.topA98
    D1BodySized.oracle97 D1BodySized.fromInactive97 D1BodySized.bridgeInto97 D1BodySized.fromTable20_97
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA98 D1BodySized.sizeArgsA98 D1BodySized.sizeSymA98
    D1BodySized.sizeMlxA98 D1BodySized.sizePayA98 (by decide)
    D1BodySized.sizeDecA98 D1BodySized.sizePreA98 D1BodySized.patchB98
    D1BodySized.sizeOracle97 D1BodySized.inactive98 D1BodySized.bridgeOut97 D1BodySized.sizeTable20_97
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ98
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive98 : (bridgeOf D1BodySized.s336.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check98 : decide (20 ≤ D1BodySized.S336.tab.length) = true
theorem D1BodySized.fromTable20_98 : 20 ≤ D1BodySized.S336.tab.length := of_decide_eq_true D1BodySized.fromTable20Check98
kernel_rfl D1BodySized.bridgeInto98 : bridgeOf D1BodySized.s339.ffi = bridgeOf D1BodySized.s336.ffi
kernel_rfl D1BodySized.bridgeOut98 : bridgeOf D1BodySized.s340.ffi = bridgeOf D1BodySized.s339.ffi
kernel_rfl D1BodySized.sizeTable20Check98 : decide (20 ≤ D1BodySized.S339.tab.length) = true
theorem D1BodySized.sizeTable20_98 : 20 ≤ D1BodySized.S339.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check98
kernel_rfl D1BodySized.sizeOracle98 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S339.oracle = true

end Host.Load.Run.Tpl
end

section -- SP98
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece98 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s336 D1BodySized.S336) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s340 D1BodySized.S340) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted98 D1BodySized.segment98 D1BodySized.acceptedP99
    D1BodySized.haltP99 D1BodySized.stepA99 D1BodySized.topA99
    D1BodySized.oracle98 D1BodySized.fromInactive98 D1BodySized.bridgeInto98 D1BodySized.fromTable20_98
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA99 D1BodySized.sizeArgsA99 D1BodySized.sizeSymA99
    D1BodySized.sizeMlxA99 D1BodySized.sizePayA99 (by decide)
    D1BodySized.sizeDecA99 D1BodySized.sizePreA99 D1BodySized.patchB99
    D1BodySized.sizeOracle98 D1BodySized.inactive99 D1BodySized.bridgeOut98 D1BodySized.sizeTable20_98
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ99
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive99 : (bridgeOf D1BodySized.s340.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check99 : decide (20 ≤ D1BodySized.S340.tab.length) = true
theorem D1BodySized.fromTable20_99 : 20 ≤ D1BodySized.S340.tab.length := of_decide_eq_true D1BodySized.fromTable20Check99
kernel_rfl D1BodySized.bridgeInto99 : bridgeOf D1BodySized.s342.ffi = bridgeOf D1BodySized.s340.ffi
kernel_rfl D1BodySized.bridgeOut99 : bridgeOf D1BodySized.s343.ffi = bridgeOf D1BodySized.s342.ffi
kernel_rfl D1BodySized.sizeTable20Check99 : decide (20 ≤ D1BodySized.S342.tab.length) = true
theorem D1BodySized.sizeTable20_99 : 20 ≤ D1BodySized.S342.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check99
kernel_rfl D1BodySized.sizeOracle99 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S342.oracle = true

end Host.Load.Run.Tpl
end

section -- SP99
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece99 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s340 D1BodySized.S340) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s343 D1BodySized.S343) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted99 D1BodySized.segment99 D1BodySized.acceptedP100
    D1BodySized.haltP100 D1BodySized.stepA100 D1BodySized.topA100
    D1BodySized.oracle99 D1BodySized.fromInactive99 D1BodySized.bridgeInto99 D1BodySized.fromTable20_99
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA100 D1BodySized.sizeArgsA100 D1BodySized.sizeSymA100
    D1BodySized.sizeMlxA100 D1BodySized.sizePayA100 (by decide)
    D1BodySized.sizeDecA100 D1BodySized.sizePreA100 D1BodySized.patchB100
    D1BodySized.sizeOracle99 D1BodySized.inactive100 D1BodySized.bridgeOut99 D1BodySized.sizeTable20_99
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ100
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive100 : (bridgeOf D1BodySized.s343.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check100 : decide (20 ≤ D1BodySized.S343.tab.length) = true
theorem D1BodySized.fromTable20_100 : 20 ≤ D1BodySized.S343.tab.length := of_decide_eq_true D1BodySized.fromTable20Check100
kernel_rfl D1BodySized.bridgeInto100 : bridgeOf D1BodySized.s345.ffi = bridgeOf D1BodySized.s343.ffi
kernel_rfl D1BodySized.bridgeOut100 : bridgeOf D1BodySized.s346.ffi = bridgeOf D1BodySized.s345.ffi
kernel_rfl D1BodySized.sizeTable20Check100 : decide (20 ≤ D1BodySized.S345.tab.length) = true
theorem D1BodySized.sizeTable20_100 : 20 ≤ D1BodySized.S345.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check100
kernel_rfl D1BodySized.sizeOracle100 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S345.oracle = true

end Host.Load.Run.Tpl
end

section -- SP100
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece100 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s343 D1BodySized.S343) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s346 D1BodySized.S346) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted100 D1BodySized.segment100 D1BodySized.acceptedP101
    D1BodySized.haltP101 D1BodySized.stepA101 D1BodySized.topA101
    D1BodySized.oracle100 D1BodySized.fromInactive100 D1BodySized.bridgeInto100 D1BodySized.fromTable20_100
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA101 D1BodySized.sizeArgsA101 D1BodySized.sizeSymA101
    D1BodySized.sizeMlxA101 D1BodySized.sizePayA101 (by decide)
    D1BodySized.sizeDecA101 D1BodySized.sizePreA101 D1BodySized.patchB101
    D1BodySized.sizeOracle100 D1BodySized.inactive101 D1BodySized.bridgeOut100 D1BodySized.sizeTable20_100
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ101
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive101 : (bridgeOf D1BodySized.s346.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check101 : decide (20 ≤ D1BodySized.S346.tab.length) = true
theorem D1BodySized.fromTable20_101 : 20 ≤ D1BodySized.S346.tab.length := of_decide_eq_true D1BodySized.fromTable20Check101
kernel_rfl D1BodySized.bridgeInto101 : bridgeOf D1BodySized.s348.ffi = bridgeOf D1BodySized.s346.ffi
kernel_rfl D1BodySized.bridgeOut101 : bridgeOf D1BodySized.s349.ffi = bridgeOf D1BodySized.s348.ffi
kernel_rfl D1BodySized.sizeTable20Check101 : decide (20 ≤ D1BodySized.S348.tab.length) = true
theorem D1BodySized.sizeTable20_101 : 20 ≤ D1BodySized.S348.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check101
kernel_rfl D1BodySized.sizeOracle101 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S348.oracle = true

end Host.Load.Run.Tpl
end

section -- SP101
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece101 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s346 D1BodySized.S346) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s349 D1BodySized.S349) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted101 D1BodySized.segment101 D1BodySized.acceptedP102
    D1BodySized.haltP102 D1BodySized.stepA102 D1BodySized.topA102
    D1BodySized.oracle101 D1BodySized.fromInactive101 D1BodySized.bridgeInto101 D1BodySized.fromTable20_101
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA102 D1BodySized.sizeArgsA102 D1BodySized.sizeSymA102
    D1BodySized.sizeMlxA102 D1BodySized.sizePayA102 (by decide)
    D1BodySized.sizeDecA102 D1BodySized.sizePreA102 D1BodySized.patchB102
    D1BodySized.sizeOracle101 D1BodySized.inactive102 D1BodySized.bridgeOut101 D1BodySized.sizeTable20_101
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ102
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive102 : (bridgeOf D1BodySized.s349.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check102 : decide (20 ≤ D1BodySized.S349.tab.length) = true
theorem D1BodySized.fromTable20_102 : 20 ≤ D1BodySized.S349.tab.length := of_decide_eq_true D1BodySized.fromTable20Check102
kernel_rfl D1BodySized.bridgeInto102 : bridgeOf D1BodySized.s352.ffi = bridgeOf D1BodySized.s349.ffi
kernel_rfl D1BodySized.bridgeOut102 : bridgeOf D1BodySized.s353.ffi = bridgeOf D1BodySized.s352.ffi
kernel_rfl D1BodySized.sizeTable20Check102 : decide (20 ≤ D1BodySized.S352.tab.length) = true
theorem D1BodySized.sizeTable20_102 : 20 ≤ D1BodySized.S352.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check102
kernel_rfl D1BodySized.sizeOracle102 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S352.oracle = true

end Host.Load.Run.Tpl
end

section -- SP102
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece102 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s349 D1BodySized.S349) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s353 D1BodySized.S353) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted102 D1BodySized.segment102 D1BodySized.acceptedP103
    D1BodySized.haltP103 D1BodySized.stepA103 D1BodySized.topA103
    D1BodySized.oracle102 D1BodySized.fromInactive102 D1BodySized.bridgeInto102 D1BodySized.fromTable20_102
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA103 D1BodySized.sizeArgsA103 D1BodySized.sizeSymA103
    D1BodySized.sizeMlxA103 D1BodySized.sizePayA103 (by decide)
    D1BodySized.sizeDecA103 D1BodySized.sizePreA103 D1BodySized.patchB103
    D1BodySized.sizeOracle102 D1BodySized.inactive103 D1BodySized.bridgeOut102 D1BodySized.sizeTable20_102
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ103
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive103 : (bridgeOf D1BodySized.s353.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check103 : decide (20 ≤ D1BodySized.S353.tab.length) = true
theorem D1BodySized.fromTable20_103 : 20 ≤ D1BodySized.S353.tab.length := of_decide_eq_true D1BodySized.fromTable20Check103
kernel_rfl D1BodySized.bridgeInto103 : bridgeOf D1BodySized.s355.ffi = bridgeOf D1BodySized.s353.ffi
kernel_rfl D1BodySized.bridgeOut103 : bridgeOf D1BodySized.s356.ffi = bridgeOf D1BodySized.s355.ffi
kernel_rfl D1BodySized.sizeTable20Check103 : decide (20 ≤ D1BodySized.S355.tab.length) = true
theorem D1BodySized.sizeTable20_103 : 20 ≤ D1BodySized.S355.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check103
kernel_rfl D1BodySized.sizeOracle103 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S355.oracle = true

end Host.Load.Run.Tpl
end

section -- SP103
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece103 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s353 D1BodySized.S353) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s356 D1BodySized.S356) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted103 D1BodySized.segment103 D1BodySized.acceptedP104
    D1BodySized.haltP104 D1BodySized.stepA104 D1BodySized.topA104
    D1BodySized.oracle103 D1BodySized.fromInactive103 D1BodySized.bridgeInto103 D1BodySized.fromTable20_103
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA104 D1BodySized.sizeArgsA104 D1BodySized.sizeSymA104
    D1BodySized.sizeMlxA104 D1BodySized.sizePayA104 (by decide)
    D1BodySized.sizeDecA104 D1BodySized.sizePreA104 D1BodySized.patchB104
    D1BodySized.sizeOracle103 D1BodySized.inactive104 D1BodySized.bridgeOut103 D1BodySized.sizeTable20_103
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ104
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive104 : (bridgeOf D1BodySized.s356.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check104 : decide (20 ≤ D1BodySized.S356.tab.length) = true
theorem D1BodySized.fromTable20_104 : 20 ≤ D1BodySized.S356.tab.length := of_decide_eq_true D1BodySized.fromTable20Check104
kernel_rfl D1BodySized.bridgeInto104 : bridgeOf D1BodySized.s358.ffi = bridgeOf D1BodySized.s356.ffi
kernel_rfl D1BodySized.bridgeOut104 : bridgeOf D1BodySized.s359.ffi = bridgeOf D1BodySized.s358.ffi
kernel_rfl D1BodySized.sizeTable20Check104 : decide (20 ≤ D1BodySized.S358.tab.length) = true
theorem D1BodySized.sizeTable20_104 : 20 ≤ D1BodySized.S358.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check104
kernel_rfl D1BodySized.sizeOracle104 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S358.oracle = true

end Host.Load.Run.Tpl
end

section -- SP104
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece104 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s356 D1BodySized.S356) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s359 D1BodySized.S359) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted104 D1BodySized.segment104 D1BodySized.acceptedP105
    D1BodySized.haltP105 D1BodySized.stepA105 D1BodySized.topA105
    D1BodySized.oracle104 D1BodySized.fromInactive104 D1BodySized.bridgeInto104 D1BodySized.fromTable20_104
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA105 D1BodySized.sizeArgsA105 D1BodySized.sizeSymA105
    D1BodySized.sizeMlxA105 D1BodySized.sizePayA105 (by decide)
    D1BodySized.sizeDecA105 D1BodySized.sizePreA105 D1BodySized.patchB105
    D1BodySized.sizeOracle104 D1BodySized.inactive105 D1BodySized.bridgeOut104 D1BodySized.sizeTable20_104
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ105
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive105 : (bridgeOf D1BodySized.s359.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check105 : decide (20 ≤ D1BodySized.S359.tab.length) = true
theorem D1BodySized.fromTable20_105 : 20 ≤ D1BodySized.S359.tab.length := of_decide_eq_true D1BodySized.fromTable20Check105
kernel_rfl D1BodySized.bridgeInto105 : bridgeOf D1BodySized.s361.ffi = bridgeOf D1BodySized.s359.ffi
kernel_rfl D1BodySized.bridgeOut105 : bridgeOf D1BodySized.s362.ffi = bridgeOf D1BodySized.s361.ffi
kernel_rfl D1BodySized.sizeTable20Check105 : decide (20 ≤ D1BodySized.S361.tab.length) = true
theorem D1BodySized.sizeTable20_105 : 20 ≤ D1BodySized.S361.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check105
kernel_rfl D1BodySized.sizeOracle105 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S361.oracle = true

end Host.Load.Run.Tpl
end

section -- SP105
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece105 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s359 D1BodySized.S359) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s362 D1BodySized.S362) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted105 D1BodySized.segment105 D1BodySized.acceptedP106
    D1BodySized.haltP106 D1BodySized.stepA106 D1BodySized.topA106
    D1BodySized.oracle105 D1BodySized.fromInactive105 D1BodySized.bridgeInto105 D1BodySized.fromTable20_105
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA106 D1BodySized.sizeArgsA106 D1BodySized.sizeSymA106
    D1BodySized.sizeMlxA106 D1BodySized.sizePayA106 (by decide)
    D1BodySized.sizeDecA106 D1BodySized.sizePreA106 D1BodySized.patchB106
    D1BodySized.sizeOracle105 D1BodySized.inactive106 D1BodySized.bridgeOut105 D1BodySized.sizeTable20_105
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ106
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive106 : (bridgeOf D1BodySized.s362.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check106 : decide (20 ≤ D1BodySized.S362.tab.length) = true
theorem D1BodySized.fromTable20_106 : 20 ≤ D1BodySized.S362.tab.length := of_decide_eq_true D1BodySized.fromTable20Check106
kernel_rfl D1BodySized.bridgeInto106 : bridgeOf D1BodySized.s365.ffi = bridgeOf D1BodySized.s362.ffi
kernel_rfl D1BodySized.bridgeOut106 : bridgeOf D1BodySized.s366.ffi = bridgeOf D1BodySized.s365.ffi
kernel_rfl D1BodySized.sizeTable20Check106 : decide (20 ≤ D1BodySized.S365.tab.length) = true
theorem D1BodySized.sizeTable20_106 : 20 ≤ D1BodySized.S365.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check106
kernel_rfl D1BodySized.sizeOracle106 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S365.oracle = true

end Host.Load.Run.Tpl
end

section -- SP106
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece106 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s362 D1BodySized.S362) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s366 D1BodySized.S366) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted106 D1BodySized.segment106 D1BodySized.acceptedP107
    D1BodySized.haltP107 D1BodySized.stepA107 D1BodySized.topA107
    D1BodySized.oracle106 D1BodySized.fromInactive106 D1BodySized.bridgeInto106 D1BodySized.fromTable20_106
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA107 D1BodySized.sizeArgsA107 D1BodySized.sizeSymA107
    D1BodySized.sizeMlxA107 D1BodySized.sizePayA107 (by decide)
    D1BodySized.sizeDecA107 D1BodySized.sizePreA107 D1BodySized.patchB107
    D1BodySized.sizeOracle106 D1BodySized.inactive107 D1BodySized.bridgeOut106 D1BodySized.sizeTable20_106
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ107
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive107 : (bridgeOf D1BodySized.s366.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check107 : decide (20 ≤ D1BodySized.S366.tab.length) = true
theorem D1BodySized.fromTable20_107 : 20 ≤ D1BodySized.S366.tab.length := of_decide_eq_true D1BodySized.fromTable20Check107
kernel_rfl D1BodySized.bridgeInto107 : bridgeOf D1BodySized.s368.ffi = bridgeOf D1BodySized.s366.ffi
kernel_rfl D1BodySized.bridgeOut107 : bridgeOf D1BodySized.s369.ffi = bridgeOf D1BodySized.s368.ffi
kernel_rfl D1BodySized.sizeTable20Check107 : decide (20 ≤ D1BodySized.S368.tab.length) = true
theorem D1BodySized.sizeTable20_107 : 20 ≤ D1BodySized.S368.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check107
kernel_rfl D1BodySized.sizeOracle107 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S368.oracle = true

end Host.Load.Run.Tpl
end

section -- SP107
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece107 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s366 D1BodySized.S366) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s369 D1BodySized.S369) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted107 D1BodySized.segment107 D1BodySized.acceptedP108
    D1BodySized.haltP108 D1BodySized.stepA108 D1BodySized.topA108
    D1BodySized.oracle107 D1BodySized.fromInactive107 D1BodySized.bridgeInto107 D1BodySized.fromTable20_107
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA108 D1BodySized.sizeArgsA108 D1BodySized.sizeSymA108
    D1BodySized.sizeMlxA108 D1BodySized.sizePayA108 (by decide)
    D1BodySized.sizeDecA108 D1BodySized.sizePreA108 D1BodySized.patchB108
    D1BodySized.sizeOracle107 D1BodySized.inactive108 D1BodySized.bridgeOut107 D1BodySized.sizeTable20_107
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ108
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive108 : (bridgeOf D1BodySized.s369.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check108 : decide (20 ≤ D1BodySized.S369.tab.length) = true
theorem D1BodySized.fromTable20_108 : 20 ≤ D1BodySized.S369.tab.length := of_decide_eq_true D1BodySized.fromTable20Check108
kernel_rfl D1BodySized.bridgeInto108 : bridgeOf D1BodySized.s373.ffi = bridgeOf D1BodySized.s369.ffi
kernel_rfl D1BodySized.bridgeOut108 : bridgeOf D1BodySized.s374.ffi = bridgeOf D1BodySized.s373.ffi
kernel_rfl D1BodySized.sizeTable20Check108 : decide (20 ≤ D1BodySized.S373.tab.length) = true
theorem D1BodySized.sizeTable20_108 : 20 ≤ D1BodySized.S373.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check108
kernel_rfl D1BodySized.sizeOracle108 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S373.oracle = true

end Host.Load.Run.Tpl
end

section -- SP108
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece108 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s369 D1BodySized.S369) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s374 D1BodySized.S374) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted108 D1BodySized.segment108 D1BodySized.acceptedP109
    D1BodySized.haltP109 D1BodySized.stepA109 D1BodySized.topA109
    D1BodySized.oracle108 D1BodySized.fromInactive108 D1BodySized.bridgeInto108 D1BodySized.fromTable20_108
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA109 D1BodySized.sizeArgsA109 D1BodySized.sizeSymA109
    D1BodySized.sizeMlxA109 D1BodySized.sizePayA109 (by decide)
    D1BodySized.sizeDecA109 D1BodySized.sizePreA109 D1BodySized.patchB109
    D1BodySized.sizeOracle108 D1BodySized.inactive109 D1BodySized.bridgeOut108 D1BodySized.sizeTable20_108
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ109
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive109 : (bridgeOf D1BodySized.s374.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check109 : decide (20 ≤ D1BodySized.S374.tab.length) = true
theorem D1BodySized.fromTable20_109 : 20 ≤ D1BodySized.S374.tab.length := of_decide_eq_true D1BodySized.fromTable20Check109
kernel_rfl D1BodySized.bridgeInto109 : bridgeOf D1BodySized.s376.ffi = bridgeOf D1BodySized.s374.ffi
kernel_rfl D1BodySized.bridgeOut109 : bridgeOf D1BodySized.s377.ffi = bridgeOf D1BodySized.s376.ffi
kernel_rfl D1BodySized.sizeTable20Check109 : decide (20 ≤ D1BodySized.S376.tab.length) = true
theorem D1BodySized.sizeTable20_109 : 20 ≤ D1BodySized.S376.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check109
kernel_rfl D1BodySized.sizeOracle109 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S376.oracle = true

end Host.Load.Run.Tpl
end

section -- SP109
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece109 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s374 D1BodySized.S374) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s377 D1BodySized.S377) 7943 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted109 D1BodySized.segment109 D1BodySized.acceptedP110
    D1BodySized.haltP110 D1BodySized.stepA110 D1BodySized.topA110
    D1BodySized.oracle109 D1BodySized.fromInactive109 D1BodySized.bridgeInto109 D1BodySized.fromTable20_109
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA110 D1BodySized.sizeArgsA110 D1BodySized.sizeSymA110
    D1BodySized.sizeMlxA110 D1BodySized.sizePayA110 (by decide)
    D1BodySized.sizeDecA110 D1BodySized.sizePreA110 D1BodySized.patchB110
    D1BodySized.sizeOracle109 D1BodySized.inactive110 D1BodySized.bridgeOut109 D1BodySized.sizeTable20_109
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ110
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive110 : (bridgeOf D1BodySized.s377.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check110 : decide (20 ≤ D1BodySized.S377.tab.length) = true
theorem D1BodySized.fromTable20_110 : 20 ≤ D1BodySized.S377.tab.length := of_decide_eq_true D1BodySized.fromTable20Check110
kernel_rfl D1BodySized.bridgeInto110 : bridgeOf D1BodySized.s379.ffi = bridgeOf D1BodySized.s377.ffi
kernel_rfl D1BodySized.bridgeOut110 : bridgeOf D1BodySized.s380.ffi = bridgeOf D1BodySized.s379.ffi
kernel_rfl D1BodySized.sizeTable20Check110 : decide (20 ≤ D1BodySized.S379.tab.length) = true
theorem D1BodySized.sizeTable20_110 : 20 ≤ D1BodySized.S379.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check110
kernel_rfl D1BodySized.sizeOracle110 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S379.oracle = true

end Host.Load.Run.Tpl
end

section -- SP110
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece110 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s377 D1BodySized.S377) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s380 D1BodySized.S380) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted110 D1BodySized.segment110 D1BodySized.acceptedP111
    D1BodySized.haltP111 D1BodySized.stepA111 D1BodySized.topA111
    D1BodySized.oracle110 D1BodySized.fromInactive110 D1BodySized.bridgeInto110 D1BodySized.fromTable20_110
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA111 D1BodySized.sizeArgsA111 D1BodySized.sizeSymA111
    D1BodySized.sizeMlxA111 D1BodySized.sizePayA111 (by decide)
    D1BodySized.sizeDecA111 D1BodySized.sizePreA111 D1BodySized.patchB111
    D1BodySized.sizeOracle110 D1BodySized.inactive111 D1BodySized.bridgeOut110 D1BodySized.sizeTable20_110
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ111
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive111 : (bridgeOf D1BodySized.s380.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check111 : decide (20 ≤ D1BodySized.S380.tab.length) = true
theorem D1BodySized.fromTable20_111 : 20 ≤ D1BodySized.S380.tab.length := of_decide_eq_true D1BodySized.fromTable20Check111
kernel_rfl D1BodySized.bridgeInto111 : bridgeOf D1BodySized.s383.ffi = bridgeOf D1BodySized.s380.ffi
kernel_rfl D1BodySized.bridgeOut111 : bridgeOf D1BodySized.s384.ffi = bridgeOf D1BodySized.s383.ffi
kernel_rfl D1BodySized.sizeTable20Check111 : decide (20 ≤ D1BodySized.S383.tab.length) = true
theorem D1BodySized.sizeTable20_111 : 20 ≤ D1BodySized.S383.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check111
kernel_rfl D1BodySized.sizeOracle111 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S383.oracle = true

end Host.Load.Run.Tpl
end

section -- SP111
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece111 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s380 D1BodySized.S380) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s384 D1BodySized.S384) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted111 D1BodySized.segment111 D1BodySized.acceptedP112
    D1BodySized.haltP112 D1BodySized.stepA112 D1BodySized.topA112
    D1BodySized.oracle111 D1BodySized.fromInactive111 D1BodySized.bridgeInto111 D1BodySized.fromTable20_111
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA112 D1BodySized.sizeArgsA112 D1BodySized.sizeSymA112
    D1BodySized.sizeMlxA112 D1BodySized.sizePayA112 (by decide)
    D1BodySized.sizeDecA112 D1BodySized.sizePreA112 D1BodySized.patchB112
    D1BodySized.sizeOracle111 D1BodySized.inactive112 D1BodySized.bridgeOut111 D1BodySized.sizeTable20_111
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ112
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive112 : (bridgeOf D1BodySized.s384.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check112 : decide (20 ≤ D1BodySized.S384.tab.length) = true
theorem D1BodySized.fromTable20_112 : 20 ≤ D1BodySized.S384.tab.length := of_decide_eq_true D1BodySized.fromTable20Check112
kernel_rfl D1BodySized.bridgeInto112 : bridgeOf D1BodySized.s386.ffi = bridgeOf D1BodySized.s384.ffi
kernel_rfl D1BodySized.bridgeOut112 : bridgeOf D1BodySized.s387.ffi = bridgeOf D1BodySized.s386.ffi
kernel_rfl D1BodySized.sizeTable20Check112 : decide (20 ≤ D1BodySized.S386.tab.length) = true
theorem D1BodySized.sizeTable20_112 : 20 ≤ D1BodySized.S386.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check112
kernel_rfl D1BodySized.sizeOracle112 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S386.oracle = true

end Host.Load.Run.Tpl
end

section -- SP112
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece112 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s384 D1BodySized.S384) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s387 D1BodySized.S387) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted112 D1BodySized.segment112 D1BodySized.acceptedP113
    D1BodySized.haltP113 D1BodySized.stepA113 D1BodySized.topA113
    D1BodySized.oracle112 D1BodySized.fromInactive112 D1BodySized.bridgeInto112 D1BodySized.fromTable20_112
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA113 D1BodySized.sizeArgsA113 D1BodySized.sizeSymA113
    D1BodySized.sizeMlxA113 D1BodySized.sizePayA113 (by decide)
    D1BodySized.sizeDecA113 D1BodySized.sizePreA113 D1BodySized.patchB113
    D1BodySized.sizeOracle112 D1BodySized.inactive113 D1BodySized.bridgeOut112 D1BodySized.sizeTable20_112
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ113
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive113 : (bridgeOf D1BodySized.s387.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check113 : decide (20 ≤ D1BodySized.S387.tab.length) = true
theorem D1BodySized.fromTable20_113 : 20 ≤ D1BodySized.S387.tab.length := of_decide_eq_true D1BodySized.fromTable20Check113
kernel_rfl D1BodySized.bridgeInto113 : bridgeOf D1BodySized.s389.ffi = bridgeOf D1BodySized.s387.ffi
kernel_rfl D1BodySized.bridgeOut113 : bridgeOf D1BodySized.s390.ffi = bridgeOf D1BodySized.s389.ffi
kernel_rfl D1BodySized.sizeTable20Check113 : decide (20 ≤ D1BodySized.S389.tab.length) = true
theorem D1BodySized.sizeTable20_113 : 20 ≤ D1BodySized.S389.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check113
kernel_rfl D1BodySized.sizeOracle113 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S389.oracle = true

end Host.Load.Run.Tpl
end

section -- SP113
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece113 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s387 D1BodySized.S387) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s390 D1BodySized.S390) 7725 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted113 D1BodySized.segment113 D1BodySized.acceptedP114
    D1BodySized.haltP114 D1BodySized.stepA114 D1BodySized.topA114
    D1BodySized.oracle113 D1BodySized.fromInactive113 D1BodySized.bridgeInto113 D1BodySized.fromTable20_113
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA114 D1BodySized.sizeArgsA114 D1BodySized.sizeSymA114
    D1BodySized.sizeMlxA114 D1BodySized.sizePayA114 (by decide)
    D1BodySized.sizeDecA114 D1BodySized.sizePreA114 D1BodySized.patchB114
    D1BodySized.sizeOracle113 D1BodySized.inactive114 D1BodySized.bridgeOut113 D1BodySized.sizeTable20_113
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ114
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive114 : (bridgeOf D1BodySized.s390.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check114 : decide (20 ≤ D1BodySized.S390.tab.length) = true
theorem D1BodySized.fromTable20_114 : 20 ≤ D1BodySized.S390.tab.length := of_decide_eq_true D1BodySized.fromTable20Check114
kernel_rfl D1BodySized.bridgeInto114 : bridgeOf D1BodySized.s392.ffi = bridgeOf D1BodySized.s390.ffi
kernel_rfl D1BodySized.bridgeOut114 : bridgeOf D1BodySized.s393.ffi = bridgeOf D1BodySized.s392.ffi
kernel_rfl D1BodySized.sizeTable20Check114 : decide (20 ≤ D1BodySized.S392.tab.length) = true
theorem D1BodySized.sizeTable20_114 : 20 ≤ D1BodySized.S392.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check114
kernel_rfl D1BodySized.sizeOracle114 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S392.oracle = true

end Host.Load.Run.Tpl
end

section -- SP114
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece114 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s390 D1BodySized.S390) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s393 D1BodySized.S393) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted114 D1BodySized.segment114 D1BodySized.acceptedP115
    D1BodySized.haltP115 D1BodySized.stepA115 D1BodySized.topA115
    D1BodySized.oracle114 D1BodySized.fromInactive114 D1BodySized.bridgeInto114 D1BodySized.fromTable20_114
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA115 D1BodySized.sizeArgsA115 D1BodySized.sizeSymA115
    D1BodySized.sizeMlxA115 D1BodySized.sizePayA115 (by decide)
    D1BodySized.sizeDecA115 D1BodySized.sizePreA115 D1BodySized.patchB115
    D1BodySized.sizeOracle114 D1BodySized.inactive115 D1BodySized.bridgeOut114 D1BodySized.sizeTable20_114
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ115
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive115 : (bridgeOf D1BodySized.s393.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check115 : decide (20 ≤ D1BodySized.S393.tab.length) = true
theorem D1BodySized.fromTable20_115 : 20 ≤ D1BodySized.S393.tab.length := of_decide_eq_true D1BodySized.fromTable20Check115
kernel_rfl D1BodySized.bridgeInto115 : bridgeOf D1BodySized.s396.ffi = bridgeOf D1BodySized.s393.ffi
kernel_rfl D1BodySized.bridgeOut115 : bridgeOf D1BodySized.s397.ffi = bridgeOf D1BodySized.s396.ffi
kernel_rfl D1BodySized.sizeTable20Check115 : decide (20 ≤ D1BodySized.S396.tab.length) = true
theorem D1BodySized.sizeTable20_115 : 20 ≤ D1BodySized.S396.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check115
kernel_rfl D1BodySized.sizeOracle115 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S396.oracle = true

end Host.Load.Run.Tpl
end

section -- SP115
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece115 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s393 D1BodySized.S393) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s397 D1BodySized.S397) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted115 D1BodySized.segment115 D1BodySized.acceptedP116
    D1BodySized.haltP116 D1BodySized.stepA116 D1BodySized.topA116
    D1BodySized.oracle115 D1BodySized.fromInactive115 D1BodySized.bridgeInto115 D1BodySized.fromTable20_115
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA116 D1BodySized.sizeArgsA116 D1BodySized.sizeSymA116
    D1BodySized.sizeMlxA116 D1BodySized.sizePayA116 (by decide)
    D1BodySized.sizeDecA116 D1BodySized.sizePreA116 D1BodySized.patchB116
    D1BodySized.sizeOracle115 D1BodySized.inactive116 D1BodySized.bridgeOut115 D1BodySized.sizeTable20_115
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ116
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive116 : (bridgeOf D1BodySized.s397.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check116 : decide (20 ≤ D1BodySized.S397.tab.length) = true
theorem D1BodySized.fromTable20_116 : 20 ≤ D1BodySized.S397.tab.length := of_decide_eq_true D1BodySized.fromTable20Check116
kernel_rfl D1BodySized.bridgeInto116 : bridgeOf D1BodySized.s399.ffi = bridgeOf D1BodySized.s397.ffi
kernel_rfl D1BodySized.bridgeOut116 : bridgeOf D1BodySized.s400.ffi = bridgeOf D1BodySized.s399.ffi
kernel_rfl D1BodySized.sizeTable20Check116 : decide (20 ≤ D1BodySized.S399.tab.length) = true
theorem D1BodySized.sizeTable20_116 : 20 ≤ D1BodySized.S399.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check116
kernel_rfl D1BodySized.sizeOracle116 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S399.oracle = true

end Host.Load.Run.Tpl
end

section -- SP116
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece116 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s397 D1BodySized.S397) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s400 D1BodySized.S400) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted116 D1BodySized.segment116 D1BodySized.acceptedP117
    D1BodySized.haltP117 D1BodySized.stepA117 D1BodySized.topA117
    D1BodySized.oracle116 D1BodySized.fromInactive116 D1BodySized.bridgeInto116 D1BodySized.fromTable20_116
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA117 D1BodySized.sizeArgsA117 D1BodySized.sizeSymA117
    D1BodySized.sizeMlxA117 D1BodySized.sizePayA117 (by decide)
    D1BodySized.sizeDecA117 D1BodySized.sizePreA117 D1BodySized.patchB117
    D1BodySized.sizeOracle116 D1BodySized.inactive117 D1BodySized.bridgeOut116 D1BodySized.sizeTable20_116
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ117
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive117 : (bridgeOf D1BodySized.s400.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check117 : decide (20 ≤ D1BodySized.S400.tab.length) = true
theorem D1BodySized.fromTable20_117 : 20 ≤ D1BodySized.S400.tab.length := of_decide_eq_true D1BodySized.fromTable20Check117
kernel_rfl D1BodySized.bridgeInto117 : bridgeOf D1BodySized.s402.ffi = bridgeOf D1BodySized.s400.ffi
kernel_rfl D1BodySized.bridgeOut117 : bridgeOf D1BodySized.s403.ffi = bridgeOf D1BodySized.s402.ffi
kernel_rfl D1BodySized.sizeTable20Check117 : decide (20 ≤ D1BodySized.S402.tab.length) = true
theorem D1BodySized.sizeTable20_117 : 20 ≤ D1BodySized.S402.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check117
kernel_rfl D1BodySized.sizeOracle117 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S402.oracle = true

end Host.Load.Run.Tpl
end

section -- SP117
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece117 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s400 D1BodySized.S400) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s403 D1BodySized.S403) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted117 D1BodySized.segment117 D1BodySized.acceptedP118
    D1BodySized.haltP118 D1BodySized.stepA118 D1BodySized.topA118
    D1BodySized.oracle117 D1BodySized.fromInactive117 D1BodySized.bridgeInto117 D1BodySized.fromTable20_117
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA118 D1BodySized.sizeArgsA118 D1BodySized.sizeSymA118
    D1BodySized.sizeMlxA118 D1BodySized.sizePayA118 (by decide)
    D1BodySized.sizeDecA118 D1BodySized.sizePreA118 D1BodySized.patchB118
    D1BodySized.sizeOracle117 D1BodySized.inactive118 D1BodySized.bridgeOut117 D1BodySized.sizeTable20_117
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ118
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive118 : (bridgeOf D1BodySized.s403.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check118 : decide (20 ≤ D1BodySized.S403.tab.length) = true
theorem D1BodySized.fromTable20_118 : 20 ≤ D1BodySized.S403.tab.length := of_decide_eq_true D1BodySized.fromTable20Check118
kernel_rfl D1BodySized.bridgeInto118 : bridgeOf D1BodySized.s405.ffi = bridgeOf D1BodySized.s403.ffi
kernel_rfl D1BodySized.bridgeOut118 : bridgeOf D1BodySized.s406.ffi = bridgeOf D1BodySized.s405.ffi
kernel_rfl D1BodySized.sizeTable20Check118 : decide (20 ≤ D1BodySized.S405.tab.length) = true
theorem D1BodySized.sizeTable20_118 : 20 ≤ D1BodySized.S405.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check118
kernel_rfl D1BodySized.sizeOracle118 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S405.oracle = true

end Host.Load.Run.Tpl
end

section -- SP118
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece118 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s403 D1BodySized.S403) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s406 D1BodySized.S406) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted118 D1BodySized.segment118 D1BodySized.acceptedP119
    D1BodySized.haltP119 D1BodySized.stepA119 D1BodySized.topA119
    D1BodySized.oracle118 D1BodySized.fromInactive118 D1BodySized.bridgeInto118 D1BodySized.fromTable20_118
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA119 D1BodySized.sizeArgsA119 D1BodySized.sizeSymA119
    D1BodySized.sizeMlxA119 D1BodySized.sizePayA119 (by decide)
    D1BodySized.sizeDecA119 D1BodySized.sizePreA119 D1BodySized.patchB119
    D1BodySized.sizeOracle118 D1BodySized.inactive119 D1BodySized.bridgeOut118 D1BodySized.sizeTable20_118
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ119
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive119 : (bridgeOf D1BodySized.s406.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check119 : decide (20 ≤ D1BodySized.S406.tab.length) = true
theorem D1BodySized.fromTable20_119 : 20 ≤ D1BodySized.S406.tab.length := of_decide_eq_true D1BodySized.fromTable20Check119
kernel_rfl D1BodySized.bridgeInto119 : bridgeOf D1BodySized.s409.ffi = bridgeOf D1BodySized.s406.ffi
kernel_rfl D1BodySized.bridgeOut119 : bridgeOf D1BodySized.s410.ffi = bridgeOf D1BodySized.s409.ffi
kernel_rfl D1BodySized.sizeTable20Check119 : decide (20 ≤ D1BodySized.S409.tab.length) = true
theorem D1BodySized.sizeTable20_119 : 20 ≤ D1BodySized.S409.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check119
kernel_rfl D1BodySized.sizeOracle119 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S409.oracle = true

end Host.Load.Run.Tpl
end

section -- SP119
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece119 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s406 D1BodySized.S406) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s410 D1BodySized.S410) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted119 D1BodySized.segment119 D1BodySized.acceptedP120
    D1BodySized.haltP120 D1BodySized.stepA120 D1BodySized.topA120
    D1BodySized.oracle119 D1BodySized.fromInactive119 D1BodySized.bridgeInto119 D1BodySized.fromTable20_119
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA120 D1BodySized.sizeArgsA120 D1BodySized.sizeSymA120
    D1BodySized.sizeMlxA120 D1BodySized.sizePayA120 (by decide)
    D1BodySized.sizeDecA120 D1BodySized.sizePreA120 D1BodySized.patchB120
    D1BodySized.sizeOracle119 D1BodySized.inactive120 D1BodySized.bridgeOut119 D1BodySized.sizeTable20_119
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ120
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive120 : (bridgeOf D1BodySized.s410.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check120 : decide (20 ≤ D1BodySized.S410.tab.length) = true
theorem D1BodySized.fromTable20_120 : 20 ≤ D1BodySized.S410.tab.length := of_decide_eq_true D1BodySized.fromTable20Check120
kernel_rfl D1BodySized.bridgeInto120 : bridgeOf D1BodySized.s412.ffi = bridgeOf D1BodySized.s410.ffi
kernel_rfl D1BodySized.bridgeOut120 : bridgeOf D1BodySized.s413.ffi = bridgeOf D1BodySized.s412.ffi
kernel_rfl D1BodySized.sizeTable20Check120 : decide (20 ≤ D1BodySized.S412.tab.length) = true
theorem D1BodySized.sizeTable20_120 : 20 ≤ D1BodySized.S412.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check120
kernel_rfl D1BodySized.sizeOracle120 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S412.oracle = true

end Host.Load.Run.Tpl
end

section -- SP120
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece120 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s410 D1BodySized.S410) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s413 D1BodySized.S413) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted120 D1BodySized.segment120 D1BodySized.acceptedP121
    D1BodySized.haltP121 D1BodySized.stepA121 D1BodySized.topA121
    D1BodySized.oracle120 D1BodySized.fromInactive120 D1BodySized.bridgeInto120 D1BodySized.fromTable20_120
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA121 D1BodySized.sizeArgsA121 D1BodySized.sizeSymA121
    D1BodySized.sizeMlxA121 D1BodySized.sizePayA121 (by decide)
    D1BodySized.sizeDecA121 D1BodySized.sizePreA121 D1BodySized.patchB121
    D1BodySized.sizeOracle120 D1BodySized.inactive121 D1BodySized.bridgeOut120 D1BodySized.sizeTable20_120
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ121
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive121 : (bridgeOf D1BodySized.s413.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check121 : decide (20 ≤ D1BodySized.S413.tab.length) = true
theorem D1BodySized.fromTable20_121 : 20 ≤ D1BodySized.S413.tab.length := of_decide_eq_true D1BodySized.fromTable20Check121
kernel_rfl D1BodySized.bridgeInto121 : bridgeOf D1BodySized.s417.ffi = bridgeOf D1BodySized.s413.ffi
kernel_rfl D1BodySized.bridgeOut121 : bridgeOf D1BodySized.s418.ffi = bridgeOf D1BodySized.s417.ffi
kernel_rfl D1BodySized.sizeTable20Check121 : decide (20 ≤ D1BodySized.S417.tab.length) = true
theorem D1BodySized.sizeTable20_121 : 20 ≤ D1BodySized.S417.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check121
kernel_rfl D1BodySized.sizeOracle121 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S417.oracle = true

end Host.Load.Run.Tpl
end

section -- SP121
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece121 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s413 D1BodySized.S413) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s418 D1BodySized.S418) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted121 D1BodySized.segment121 D1BodySized.acceptedP122
    D1BodySized.haltP122 D1BodySized.stepA122 D1BodySized.topA122
    D1BodySized.oracle121 D1BodySized.fromInactive121 D1BodySized.bridgeInto121 D1BodySized.fromTable20_121
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA122 D1BodySized.sizeArgsA122 D1BodySized.sizeSymA122
    D1BodySized.sizeMlxA122 D1BodySized.sizePayA122 (by decide)
    D1BodySized.sizeDecA122 D1BodySized.sizePreA122 D1BodySized.patchB122
    D1BodySized.sizeOracle121 D1BodySized.inactive122 D1BodySized.bridgeOut121 D1BodySized.sizeTable20_121
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ122
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive122 : (bridgeOf D1BodySized.s418.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check122 : decide (20 ≤ D1BodySized.S418.tab.length) = true
theorem D1BodySized.fromTable20_122 : 20 ≤ D1BodySized.S418.tab.length := of_decide_eq_true D1BodySized.fromTable20Check122
kernel_rfl D1BodySized.bridgeInto122 : bridgeOf D1BodySized.s420.ffi = bridgeOf D1BodySized.s418.ffi
kernel_rfl D1BodySized.bridgeOut122 : bridgeOf D1BodySized.s421.ffi = bridgeOf D1BodySized.s420.ffi
kernel_rfl D1BodySized.sizeTable20Check122 : decide (20 ≤ D1BodySized.S420.tab.length) = true
theorem D1BodySized.sizeTable20_122 : 20 ≤ D1BodySized.S420.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check122
kernel_rfl D1BodySized.sizeOracle122 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S420.oracle = true

end Host.Load.Run.Tpl
end

section -- SP122
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece122 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s418 D1BodySized.S418) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s421 D1BodySized.S421) 7938 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted122 D1BodySized.segment122 D1BodySized.acceptedP123
    D1BodySized.haltP123 D1BodySized.stepA123 D1BodySized.topA123
    D1BodySized.oracle122 D1BodySized.fromInactive122 D1BodySized.bridgeInto122 D1BodySized.fromTable20_122
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA123 D1BodySized.sizeArgsA123 D1BodySized.sizeSymA123
    D1BodySized.sizeMlxA123 D1BodySized.sizePayA123 (by decide)
    D1BodySized.sizeDecA123 D1BodySized.sizePreA123 D1BodySized.patchB123
    D1BodySized.sizeOracle122 D1BodySized.inactive123 D1BodySized.bridgeOut122 D1BodySized.sizeTable20_122
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ123
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive123 : (bridgeOf D1BodySized.s421.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check123 : decide (20 ≤ D1BodySized.S421.tab.length) = true
theorem D1BodySized.fromTable20_123 : 20 ≤ D1BodySized.S421.tab.length := of_decide_eq_true D1BodySized.fromTable20Check123
kernel_rfl D1BodySized.bridgeInto123 : bridgeOf D1BodySized.s423.ffi = bridgeOf D1BodySized.s421.ffi
kernel_rfl D1BodySized.bridgeOut123 : bridgeOf D1BodySized.s424.ffi = bridgeOf D1BodySized.s423.ffi
kernel_rfl D1BodySized.sizeTable20Check123 : decide (20 ≤ D1BodySized.S423.tab.length) = true
theorem D1BodySized.sizeTable20_123 : 20 ≤ D1BodySized.S423.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check123
kernel_rfl D1BodySized.sizeOracle123 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S423.oracle = true

end Host.Load.Run.Tpl
end

section -- SP123
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece123 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s421 D1BodySized.S421) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s424 D1BodySized.S424) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted123 D1BodySized.segment123 D1BodySized.acceptedP124
    D1BodySized.haltP124 D1BodySized.stepA124 D1BodySized.topA124
    D1BodySized.oracle123 D1BodySized.fromInactive123 D1BodySized.bridgeInto123 D1BodySized.fromTable20_123
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA124 D1BodySized.sizeArgsA124 D1BodySized.sizeSymA124
    D1BodySized.sizeMlxA124 D1BodySized.sizePayA124 (by decide)
    D1BodySized.sizeDecA124 D1BodySized.sizePreA124 D1BodySized.patchB124
    D1BodySized.sizeOracle123 D1BodySized.inactive124 D1BodySized.bridgeOut123 D1BodySized.sizeTable20_123
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ124
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive124 : (bridgeOf D1BodySized.s424.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check124 : decide (20 ≤ D1BodySized.S424.tab.length) = true
theorem D1BodySized.fromTable20_124 : 20 ≤ D1BodySized.S424.tab.length := of_decide_eq_true D1BodySized.fromTable20Check124
kernel_rfl D1BodySized.bridgeInto124 : bridgeOf D1BodySized.s427.ffi = bridgeOf D1BodySized.s424.ffi
kernel_rfl D1BodySized.bridgeOut124 : bridgeOf D1BodySized.s428.ffi = bridgeOf D1BodySized.s427.ffi
kernel_rfl D1BodySized.sizeTable20Check124 : decide (20 ≤ D1BodySized.S427.tab.length) = true
theorem D1BodySized.sizeTable20_124 : 20 ≤ D1BodySized.S427.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check124
kernel_rfl D1BodySized.sizeOracle124 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S427.oracle = true

end Host.Load.Run.Tpl
end

section -- SP124
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece124 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s424 D1BodySized.S424) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s428 D1BodySized.S428) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted124 D1BodySized.segment124 D1BodySized.acceptedP125
    D1BodySized.haltP125 D1BodySized.stepA125 D1BodySized.topA125
    D1BodySized.oracle124 D1BodySized.fromInactive124 D1BodySized.bridgeInto124 D1BodySized.fromTable20_124
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA125 D1BodySized.sizeArgsA125 D1BodySized.sizeSymA125
    D1BodySized.sizeMlxA125 D1BodySized.sizePayA125 (by decide)
    D1BodySized.sizeDecA125 D1BodySized.sizePreA125 D1BodySized.patchB125
    D1BodySized.sizeOracle124 D1BodySized.inactive125 D1BodySized.bridgeOut124 D1BodySized.sizeTable20_124
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ125
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive125 : (bridgeOf D1BodySized.s428.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check125 : decide (20 ≤ D1BodySized.S428.tab.length) = true
theorem D1BodySized.fromTable20_125 : 20 ≤ D1BodySized.S428.tab.length := of_decide_eq_true D1BodySized.fromTable20Check125
kernel_rfl D1BodySized.bridgeInto125 : bridgeOf D1BodySized.s430.ffi = bridgeOf D1BodySized.s428.ffi
kernel_rfl D1BodySized.bridgeOut125 : bridgeOf D1BodySized.s431.ffi = bridgeOf D1BodySized.s430.ffi
kernel_rfl D1BodySized.sizeTable20Check125 : decide (20 ≤ D1BodySized.S430.tab.length) = true
theorem D1BodySized.sizeTable20_125 : 20 ≤ D1BodySized.S430.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check125
kernel_rfl D1BodySized.sizeOracle125 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S430.oracle = true

end Host.Load.Run.Tpl
end

section -- SP125
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece125 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s428 D1BodySized.S428) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s431 D1BodySized.S431) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted125 D1BodySized.segment125 D1BodySized.acceptedP126
    D1BodySized.haltP126 D1BodySized.stepA126 D1BodySized.topA126
    D1BodySized.oracle125 D1BodySized.fromInactive125 D1BodySized.bridgeInto125 D1BodySized.fromTable20_125
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA126 D1BodySized.sizeArgsA126 D1BodySized.sizeSymA126
    D1BodySized.sizeMlxA126 D1BodySized.sizePayA126 (by decide)
    D1BodySized.sizeDecA126 D1BodySized.sizePreA126 D1BodySized.patchB126
    D1BodySized.sizeOracle125 D1BodySized.inactive126 D1BodySized.bridgeOut125 D1BodySized.sizeTable20_125
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ126
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive126 : (bridgeOf D1BodySized.s431.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check126 : decide (20 ≤ D1BodySized.S431.tab.length) = true
theorem D1BodySized.fromTable20_126 : 20 ≤ D1BodySized.S431.tab.length := of_decide_eq_true D1BodySized.fromTable20Check126
kernel_rfl D1BodySized.bridgeInto126 : bridgeOf D1BodySized.s433.ffi = bridgeOf D1BodySized.s431.ffi
kernel_rfl D1BodySized.bridgeOut126 : bridgeOf D1BodySized.s434.ffi = bridgeOf D1BodySized.s433.ffi
kernel_rfl D1BodySized.sizeTable20Check126 : decide (20 ≤ D1BodySized.S433.tab.length) = true
theorem D1BodySized.sizeTable20_126 : 20 ≤ D1BodySized.S433.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check126
kernel_rfl D1BodySized.sizeOracle126 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S433.oracle = true

end Host.Load.Run.Tpl
end

section -- SP126
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece126 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s431 D1BodySized.S431) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s434 D1BodySized.S434) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted126 D1BodySized.segment126 D1BodySized.acceptedP127
    D1BodySized.haltP127 D1BodySized.stepA127 D1BodySized.topA127
    D1BodySized.oracle126 D1BodySized.fromInactive126 D1BodySized.bridgeInto126 D1BodySized.fromTable20_126
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA127 D1BodySized.sizeArgsA127 D1BodySized.sizeSymA127
    D1BodySized.sizeMlxA127 D1BodySized.sizePayA127 (by decide)
    D1BodySized.sizeDecA127 D1BodySized.sizePreA127 D1BodySized.patchB127
    D1BodySized.sizeOracle126 D1BodySized.inactive127 D1BodySized.bridgeOut126 D1BodySized.sizeTable20_126
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ127
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive127 : (bridgeOf D1BodySized.s434.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check127 : decide (20 ≤ D1BodySized.S434.tab.length) = true
theorem D1BodySized.fromTable20_127 : 20 ≤ D1BodySized.S434.tab.length := of_decide_eq_true D1BodySized.fromTable20Check127
kernel_rfl D1BodySized.bridgeInto127 : bridgeOf D1BodySized.s436.ffi = bridgeOf D1BodySized.s434.ffi
kernel_rfl D1BodySized.bridgeOut127 : bridgeOf D1BodySized.s437.ffi = bridgeOf D1BodySized.s436.ffi
kernel_rfl D1BodySized.sizeTable20Check127 : decide (20 ≤ D1BodySized.S436.tab.length) = true
theorem D1BodySized.sizeTable20_127 : 20 ≤ D1BodySized.S436.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check127
kernel_rfl D1BodySized.sizeOracle127 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S436.oracle = true

end Host.Load.Run.Tpl
end

section -- SP127
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece127 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s434 D1BodySized.S434) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s437 D1BodySized.S437) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted127 D1BodySized.segment127 D1BodySized.acceptedP128
    D1BodySized.haltP128 D1BodySized.stepA128 D1BodySized.topA128
    D1BodySized.oracle127 D1BodySized.fromInactive127 D1BodySized.bridgeInto127 D1BodySized.fromTable20_127
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA128 D1BodySized.sizeArgsA128 D1BodySized.sizeSymA128
    D1BodySized.sizeMlxA128 D1BodySized.sizePayA128 (by decide)
    D1BodySized.sizeDecA128 D1BodySized.sizePreA128 D1BodySized.patchB128
    D1BodySized.sizeOracle127 D1BodySized.inactive128 D1BodySized.bridgeOut127 D1BodySized.sizeTable20_127
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ128
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive128 : (bridgeOf D1BodySized.s437.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check128 : decide (20 ≤ D1BodySized.S437.tab.length) = true
theorem D1BodySized.fromTable20_128 : 20 ≤ D1BodySized.S437.tab.length := of_decide_eq_true D1BodySized.fromTable20Check128
kernel_rfl D1BodySized.bridgeInto128 : bridgeOf D1BodySized.s440.ffi = bridgeOf D1BodySized.s437.ffi
kernel_rfl D1BodySized.bridgeOut128 : bridgeOf D1BodySized.s441.ffi = bridgeOf D1BodySized.s440.ffi
kernel_rfl D1BodySized.sizeTable20Check128 : decide (20 ≤ D1BodySized.S440.tab.length) = true
theorem D1BodySized.sizeTable20_128 : 20 ≤ D1BodySized.S440.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check128
kernel_rfl D1BodySized.sizeOracle128 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S440.oracle = true

end Host.Load.Run.Tpl
end

section -- SP128
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece128 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s437 D1BodySized.S437) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s441 D1BodySized.S441) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted128 D1BodySized.segment128 D1BodySized.acceptedP129
    D1BodySized.haltP129 D1BodySized.stepA129 D1BodySized.topA129
    D1BodySized.oracle128 D1BodySized.fromInactive128 D1BodySized.bridgeInto128 D1BodySized.fromTable20_128
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA129 D1BodySized.sizeArgsA129 D1BodySized.sizeSymA129
    D1BodySized.sizeMlxA129 D1BodySized.sizePayA129 (by decide)
    D1BodySized.sizeDecA129 D1BodySized.sizePreA129 D1BodySized.patchB129
    D1BodySized.sizeOracle128 D1BodySized.inactive129 D1BodySized.bridgeOut128 D1BodySized.sizeTable20_128
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ129
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive129 : (bridgeOf D1BodySized.s441.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check129 : decide (20 ≤ D1BodySized.S441.tab.length) = true
theorem D1BodySized.fromTable20_129 : 20 ≤ D1BodySized.S441.tab.length := of_decide_eq_true D1BodySized.fromTable20Check129
kernel_rfl D1BodySized.bridgeInto129 : bridgeOf D1BodySized.s443.ffi = bridgeOf D1BodySized.s441.ffi
kernel_rfl D1BodySized.bridgeOut129 : bridgeOf D1BodySized.s444.ffi = bridgeOf D1BodySized.s443.ffi
kernel_rfl D1BodySized.sizeTable20Check129 : decide (20 ≤ D1BodySized.S443.tab.length) = true
theorem D1BodySized.sizeTable20_129 : 20 ≤ D1BodySized.S443.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check129
kernel_rfl D1BodySized.sizeOracle129 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S443.oracle = true

end Host.Load.Run.Tpl
end

section -- SP129
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece129 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s441 D1BodySized.S441) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s444 D1BodySized.S444) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted129 D1BodySized.segment129 D1BodySized.acceptedP130
    D1BodySized.haltP130 D1BodySized.stepA130 D1BodySized.topA130
    D1BodySized.oracle129 D1BodySized.fromInactive129 D1BodySized.bridgeInto129 D1BodySized.fromTable20_129
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA130 D1BodySized.sizeArgsA130 D1BodySized.sizeSymA130
    D1BodySized.sizeMlxA130 D1BodySized.sizePayA130 (by decide)
    D1BodySized.sizeDecA130 D1BodySized.sizePreA130 D1BodySized.patchB130
    D1BodySized.sizeOracle129 D1BodySized.inactive130 D1BodySized.bridgeOut129 D1BodySized.sizeTable20_129
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ130
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive130 : (bridgeOf D1BodySized.s444.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check130 : decide (20 ≤ D1BodySized.S444.tab.length) = true
theorem D1BodySized.fromTable20_130 : 20 ≤ D1BodySized.S444.tab.length := of_decide_eq_true D1BodySized.fromTable20Check130
kernel_rfl D1BodySized.bridgeInto130 : bridgeOf D1BodySized.s446.ffi = bridgeOf D1BodySized.s444.ffi
kernel_rfl D1BodySized.bridgeOut130 : bridgeOf D1BodySized.s447.ffi = bridgeOf D1BodySized.s446.ffi
kernel_rfl D1BodySized.sizeTable20Check130 : decide (20 ≤ D1BodySized.S446.tab.length) = true
theorem D1BodySized.sizeTable20_130 : 20 ≤ D1BodySized.S446.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check130
kernel_rfl D1BodySized.sizeOracle130 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S446.oracle = true

end Host.Load.Run.Tpl
end

section -- SP130
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece130 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s444 D1BodySized.S444) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s447 D1BodySized.S447) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted130 D1BodySized.segment130 D1BodySized.acceptedP131
    D1BodySized.haltP131 D1BodySized.stepA131 D1BodySized.topA131
    D1BodySized.oracle130 D1BodySized.fromInactive130 D1BodySized.bridgeInto130 D1BodySized.fromTable20_130
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA131 D1BodySized.sizeArgsA131 D1BodySized.sizeSymA131
    D1BodySized.sizeMlxA131 D1BodySized.sizePayA131 (by decide)
    D1BodySized.sizeDecA131 D1BodySized.sizePreA131 D1BodySized.patchB131
    D1BodySized.sizeOracle130 D1BodySized.inactive131 D1BodySized.bridgeOut130 D1BodySized.sizeTable20_130
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ131
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive131 : (bridgeOf D1BodySized.s447.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check131 : decide (20 ≤ D1BodySized.S447.tab.length) = true
theorem D1BodySized.fromTable20_131 : 20 ≤ D1BodySized.S447.tab.length := of_decide_eq_true D1BodySized.fromTable20Check131
kernel_rfl D1BodySized.bridgeInto131 : bridgeOf D1BodySized.s449.ffi = bridgeOf D1BodySized.s447.ffi
kernel_rfl D1BodySized.bridgeOut131 : bridgeOf D1BodySized.s450.ffi = bridgeOf D1BodySized.s449.ffi
kernel_rfl D1BodySized.sizeTable20Check131 : decide (20 ≤ D1BodySized.S449.tab.length) = true
theorem D1BodySized.sizeTable20_131 : 20 ≤ D1BodySized.S449.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check131
kernel_rfl D1BodySized.sizeOracle131 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S449.oracle = true

end Host.Load.Run.Tpl
end

section -- SP131
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece131 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s447 D1BodySized.S447) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s450 D1BodySized.S450) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted131 D1BodySized.segment131 D1BodySized.acceptedP132
    D1BodySized.haltP132 D1BodySized.stepA132 D1BodySized.topA132
    D1BodySized.oracle131 D1BodySized.fromInactive131 D1BodySized.bridgeInto131 D1BodySized.fromTable20_131
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA132 D1BodySized.sizeArgsA132 D1BodySized.sizeSymA132
    D1BodySized.sizeMlxA132 D1BodySized.sizePayA132 (by decide)
    D1BodySized.sizeDecA132 D1BodySized.sizePreA132 D1BodySized.patchB132
    D1BodySized.sizeOracle131 D1BodySized.inactive132 D1BodySized.bridgeOut131 D1BodySized.sizeTable20_131
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ132
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive132 : (bridgeOf D1BodySized.s450.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check132 : decide (20 ≤ D1BodySized.S450.tab.length) = true
theorem D1BodySized.fromTable20_132 : 20 ≤ D1BodySized.S450.tab.length := of_decide_eq_true D1BodySized.fromTable20Check132
kernel_rfl D1BodySized.bridgeInto132 : bridgeOf D1BodySized.s453.ffi = bridgeOf D1BodySized.s450.ffi
kernel_rfl D1BodySized.bridgeOut132 : bridgeOf D1BodySized.s454.ffi = bridgeOf D1BodySized.s453.ffi
kernel_rfl D1BodySized.sizeTable20Check132 : decide (20 ≤ D1BodySized.S453.tab.length) = true
theorem D1BodySized.sizeTable20_132 : 20 ≤ D1BodySized.S453.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check132
kernel_rfl D1BodySized.sizeOracle132 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S453.oracle = true

end Host.Load.Run.Tpl
end

section -- SP132
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece132 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s450 D1BodySized.S450) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s454 D1BodySized.S454) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted132 D1BodySized.segment132 D1BodySized.acceptedP133
    D1BodySized.haltP133 D1BodySized.stepA133 D1BodySized.topA133
    D1BodySized.oracle132 D1BodySized.fromInactive132 D1BodySized.bridgeInto132 D1BodySized.fromTable20_132
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA133 D1BodySized.sizeArgsA133 D1BodySized.sizeSymA133
    D1BodySized.sizeMlxA133 D1BodySized.sizePayA133 (by decide)
    D1BodySized.sizeDecA133 D1BodySized.sizePreA133 D1BodySized.patchB133
    D1BodySized.sizeOracle132 D1BodySized.inactive133 D1BodySized.bridgeOut132 D1BodySized.sizeTable20_132
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ133
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive133 : (bridgeOf D1BodySized.s454.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check133 : decide (20 ≤ D1BodySized.S454.tab.length) = true
theorem D1BodySized.fromTable20_133 : 20 ≤ D1BodySized.S454.tab.length := of_decide_eq_true D1BodySized.fromTable20Check133
kernel_rfl D1BodySized.bridgeInto133 : bridgeOf D1BodySized.s456.ffi = bridgeOf D1BodySized.s454.ffi
kernel_rfl D1BodySized.bridgeOut133 : bridgeOf D1BodySized.s457.ffi = bridgeOf D1BodySized.s456.ffi
kernel_rfl D1BodySized.sizeTable20Check133 : decide (20 ≤ D1BodySized.S456.tab.length) = true
theorem D1BodySized.sizeTable20_133 : 20 ≤ D1BodySized.S456.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check133
kernel_rfl D1BodySized.sizeOracle133 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S456.oracle = true

end Host.Load.Run.Tpl
end

section -- SP133
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece133 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s454 D1BodySized.S454) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s457 D1BodySized.S457) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted133 D1BodySized.segment133 D1BodySized.acceptedP134
    D1BodySized.haltP134 D1BodySized.stepA134 D1BodySized.topA134
    D1BodySized.oracle133 D1BodySized.fromInactive133 D1BodySized.bridgeInto133 D1BodySized.fromTable20_133
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA134 D1BodySized.sizeArgsA134 D1BodySized.sizeSymA134
    D1BodySized.sizeMlxA134 D1BodySized.sizePayA134 (by decide)
    D1BodySized.sizeDecA134 D1BodySized.sizePreA134 D1BodySized.patchB134
    D1BodySized.sizeOracle133 D1BodySized.inactive134 D1BodySized.bridgeOut133 D1BodySized.sizeTable20_133
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ134
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive134 : (bridgeOf D1BodySized.s457.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check134 : decide (20 ≤ D1BodySized.S457.tab.length) = true
theorem D1BodySized.fromTable20_134 : 20 ≤ D1BodySized.S457.tab.length := of_decide_eq_true D1BodySized.fromTable20Check134
kernel_rfl D1BodySized.bridgeInto134 : bridgeOf D1BodySized.s461.ffi = bridgeOf D1BodySized.s457.ffi
kernel_rfl D1BodySized.bridgeOut134 : bridgeOf D1BodySized.s462.ffi = bridgeOf D1BodySized.s461.ffi
kernel_rfl D1BodySized.sizeTable20Check134 : decide (20 ≤ D1BodySized.S461.tab.length) = true
theorem D1BodySized.sizeTable20_134 : 20 ≤ D1BodySized.S461.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check134
kernel_rfl D1BodySized.sizeOracle134 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S461.oracle = true

end Host.Load.Run.Tpl
end

section -- SP134
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece134 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s457 D1BodySized.S457) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s462 D1BodySized.S462) 22291 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted134 D1BodySized.segment134 D1BodySized.acceptedP135
    D1BodySized.haltP135 D1BodySized.stepA135 D1BodySized.topA135
    D1BodySized.oracle134 D1BodySized.fromInactive134 D1BodySized.bridgeInto134 D1BodySized.fromTable20_134
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA135 D1BodySized.sizeArgsA135 D1BodySized.sizeSymA135
    D1BodySized.sizeMlxA135 D1BodySized.sizePayA135 (by decide)
    D1BodySized.sizeDecA135 D1BodySized.sizePreA135 D1BodySized.patchB135
    D1BodySized.sizeOracle134 D1BodySized.inactive135 D1BodySized.bridgeOut134 D1BodySized.sizeTable20_134
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ135
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive135 : (bridgeOf D1BodySized.s462.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check135 : decide (20 ≤ D1BodySized.S462.tab.length) = true
theorem D1BodySized.fromTable20_135 : 20 ≤ D1BodySized.S462.tab.length := of_decide_eq_true D1BodySized.fromTable20Check135
kernel_rfl D1BodySized.bridgeInto135 : bridgeOf D1BodySized.s464.ffi = bridgeOf D1BodySized.s462.ffi
kernel_rfl D1BodySized.bridgeOut135 : bridgeOf D1BodySized.s465.ffi = bridgeOf D1BodySized.s464.ffi
kernel_rfl D1BodySized.sizeTable20Check135 : decide (20 ≤ D1BodySized.S464.tab.length) = true
theorem D1BodySized.sizeTable20_135 : 20 ≤ D1BodySized.S464.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check135
kernel_rfl D1BodySized.sizeOracle135 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S464.oracle = true

end Host.Load.Run.Tpl
end

section -- SP135
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece135 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s462 D1BodySized.S462) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s465 D1BodySized.S465) 7943 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted135 D1BodySized.segment135 D1BodySized.acceptedP136
    D1BodySized.haltP136 D1BodySized.stepA136 D1BodySized.topA136
    D1BodySized.oracle135 D1BodySized.fromInactive135 D1BodySized.bridgeInto135 D1BodySized.fromTable20_135
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA136 D1BodySized.sizeArgsA136 D1BodySized.sizeSymA136
    D1BodySized.sizeMlxA136 D1BodySized.sizePayA136 (by decide)
    D1BodySized.sizeDecA136 D1BodySized.sizePreA136 D1BodySized.patchB136
    D1BodySized.sizeOracle135 D1BodySized.inactive136 D1BodySized.bridgeOut135 D1BodySized.sizeTable20_135
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ136
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive136 : (bridgeOf D1BodySized.s465.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check136 : decide (20 ≤ D1BodySized.S465.tab.length) = true
theorem D1BodySized.fromTable20_136 : 20 ≤ D1BodySized.S465.tab.length := of_decide_eq_true D1BodySized.fromTable20Check136
kernel_rfl D1BodySized.bridgeInto136 : bridgeOf D1BodySized.s467.ffi = bridgeOf D1BodySized.s465.ffi
kernel_rfl D1BodySized.bridgeOut136 : bridgeOf D1BodySized.s468.ffi = bridgeOf D1BodySized.s467.ffi
kernel_rfl D1BodySized.sizeTable20Check136 : decide (20 ≤ D1BodySized.S467.tab.length) = true
theorem D1BodySized.sizeTable20_136 : 20 ≤ D1BodySized.S467.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check136
kernel_rfl D1BodySized.sizeOracle136 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S467.oracle = true

end Host.Load.Run.Tpl
end

section -- SP136
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece136 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s465 D1BodySized.S465) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s468 D1BodySized.S468) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted136 D1BodySized.segment136 D1BodySized.acceptedP137
    D1BodySized.haltP137 D1BodySized.stepA137 D1BodySized.topA137
    D1BodySized.oracle136 D1BodySized.fromInactive136 D1BodySized.bridgeInto136 D1BodySized.fromTable20_136
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA137 D1BodySized.sizeArgsA137 D1BodySized.sizeSymA137
    D1BodySized.sizeMlxA137 D1BodySized.sizePayA137 (by decide)
    D1BodySized.sizeDecA137 D1BodySized.sizePreA137 D1BodySized.patchB137
    D1BodySized.sizeOracle136 D1BodySized.inactive137 D1BodySized.bridgeOut136 D1BodySized.sizeTable20_136
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ137
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive137 : (bridgeOf D1BodySized.s468.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check137 : decide (20 ≤ D1BodySized.S468.tab.length) = true
theorem D1BodySized.fromTable20_137 : 20 ≤ D1BodySized.S468.tab.length := of_decide_eq_true D1BodySized.fromTable20Check137
kernel_rfl D1BodySized.bridgeInto137 : bridgeOf D1BodySized.s471.ffi = bridgeOf D1BodySized.s468.ffi
kernel_rfl D1BodySized.bridgeOut137 : bridgeOf D1BodySized.s472.ffi = bridgeOf D1BodySized.s471.ffi
kernel_rfl D1BodySized.sizeTable20Check137 : decide (20 ≤ D1BodySized.S471.tab.length) = true
theorem D1BodySized.sizeTable20_137 : 20 ≤ D1BodySized.S471.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check137
kernel_rfl D1BodySized.sizeOracle137 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S471.oracle = true

end Host.Load.Run.Tpl
end

section -- SP137
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece137 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s468 D1BodySized.S468) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s472 D1BodySized.S472) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted137 D1BodySized.segment137 D1BodySized.acceptedP138
    D1BodySized.haltP138 D1BodySized.stepA138 D1BodySized.topA138
    D1BodySized.oracle137 D1BodySized.fromInactive137 D1BodySized.bridgeInto137 D1BodySized.fromTable20_137
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA138 D1BodySized.sizeArgsA138 D1BodySized.sizeSymA138
    D1BodySized.sizeMlxA138 D1BodySized.sizePayA138 (by decide)
    D1BodySized.sizeDecA138 D1BodySized.sizePreA138 D1BodySized.patchB138
    D1BodySized.sizeOracle137 D1BodySized.inactive138 D1BodySized.bridgeOut137 D1BodySized.sizeTable20_137
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ138
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive138 : (bridgeOf D1BodySized.s472.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check138 : decide (20 ≤ D1BodySized.S472.tab.length) = true
theorem D1BodySized.fromTable20_138 : 20 ≤ D1BodySized.S472.tab.length := of_decide_eq_true D1BodySized.fromTable20Check138
kernel_rfl D1BodySized.bridgeInto138 : bridgeOf D1BodySized.s474.ffi = bridgeOf D1BodySized.s472.ffi
kernel_rfl D1BodySized.bridgeOut138 : bridgeOf D1BodySized.s475.ffi = bridgeOf D1BodySized.s474.ffi
kernel_rfl D1BodySized.sizeTable20Check138 : decide (20 ≤ D1BodySized.S474.tab.length) = true
theorem D1BodySized.sizeTable20_138 : 20 ≤ D1BodySized.S474.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check138
kernel_rfl D1BodySized.sizeOracle138 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S474.oracle = true

end Host.Load.Run.Tpl
end

section -- SP138
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece138 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s472 D1BodySized.S472) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s475 D1BodySized.S475) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted138 D1BodySized.segment138 D1BodySized.acceptedP139
    D1BodySized.haltP139 D1BodySized.stepA139 D1BodySized.topA139
    D1BodySized.oracle138 D1BodySized.fromInactive138 D1BodySized.bridgeInto138 D1BodySized.fromTable20_138
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA139 D1BodySized.sizeArgsA139 D1BodySized.sizeSymA139
    D1BodySized.sizeMlxA139 D1BodySized.sizePayA139 (by decide)
    D1BodySized.sizeDecA139 D1BodySized.sizePreA139 D1BodySized.patchB139
    D1BodySized.sizeOracle138 D1BodySized.inactive139 D1BodySized.bridgeOut138 D1BodySized.sizeTable20_138
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ139
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive139 : (bridgeOf D1BodySized.s475.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check139 : decide (20 ≤ D1BodySized.S475.tab.length) = true
theorem D1BodySized.fromTable20_139 : 20 ≤ D1BodySized.S475.tab.length := of_decide_eq_true D1BodySized.fromTable20Check139
kernel_rfl D1BodySized.bridgeInto139 : bridgeOf D1BodySized.s477.ffi = bridgeOf D1BodySized.s475.ffi
kernel_rfl D1BodySized.bridgeOut139 : bridgeOf D1BodySized.s478.ffi = bridgeOf D1BodySized.s477.ffi
kernel_rfl D1BodySized.sizeTable20Check139 : decide (20 ≤ D1BodySized.S477.tab.length) = true
theorem D1BodySized.sizeTable20_139 : 20 ≤ D1BodySized.S477.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check139
kernel_rfl D1BodySized.sizeOracle139 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S477.oracle = true

end Host.Load.Run.Tpl
end

section -- SP139
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece139 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s475 D1BodySized.S475) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s478 D1BodySized.S478) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted139 D1BodySized.segment139 D1BodySized.acceptedP140
    D1BodySized.haltP140 D1BodySized.stepA140 D1BodySized.topA140
    D1BodySized.oracle139 D1BodySized.fromInactive139 D1BodySized.bridgeInto139 D1BodySized.fromTable20_139
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA140 D1BodySized.sizeArgsA140 D1BodySized.sizeSymA140
    D1BodySized.sizeMlxA140 D1BodySized.sizePayA140 (by decide)
    D1BodySized.sizeDecA140 D1BodySized.sizePreA140 D1BodySized.patchB140
    D1BodySized.sizeOracle139 D1BodySized.inactive140 D1BodySized.bridgeOut139 D1BodySized.sizeTable20_139
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ140
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive140 : (bridgeOf D1BodySized.s478.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check140 : decide (20 ≤ D1BodySized.S478.tab.length) = true
theorem D1BodySized.fromTable20_140 : 20 ≤ D1BodySized.S478.tab.length := of_decide_eq_true D1BodySized.fromTable20Check140
kernel_rfl D1BodySized.bridgeInto140 : bridgeOf D1BodySized.s480.ffi = bridgeOf D1BodySized.s478.ffi
kernel_rfl D1BodySized.bridgeOut140 : bridgeOf D1BodySized.s481.ffi = bridgeOf D1BodySized.s480.ffi
kernel_rfl D1BodySized.sizeTable20Check140 : decide (20 ≤ D1BodySized.S480.tab.length) = true
theorem D1BodySized.sizeTable20_140 : 20 ≤ D1BodySized.S480.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check140
kernel_rfl D1BodySized.sizeOracle140 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S480.oracle = true

end Host.Load.Run.Tpl
end

section -- SP140
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece140 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s478 D1BodySized.S478) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s481 D1BodySized.S481) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted140 D1BodySized.segment140 D1BodySized.acceptedP141
    D1BodySized.haltP141 D1BodySized.stepA141 D1BodySized.topA141
    D1BodySized.oracle140 D1BodySized.fromInactive140 D1BodySized.bridgeInto140 D1BodySized.fromTable20_140
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA141 D1BodySized.sizeArgsA141 D1BodySized.sizeSymA141
    D1BodySized.sizeMlxA141 D1BodySized.sizePayA141 (by decide)
    D1BodySized.sizeDecA141 D1BodySized.sizePreA141 D1BodySized.patchB141
    D1BodySized.sizeOracle140 D1BodySized.inactive141 D1BodySized.bridgeOut140 D1BodySized.sizeTable20_140
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ141
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive141 : (bridgeOf D1BodySized.s481.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check141 : decide (20 ≤ D1BodySized.S481.tab.length) = true
theorem D1BodySized.fromTable20_141 : 20 ≤ D1BodySized.S481.tab.length := of_decide_eq_true D1BodySized.fromTable20Check141
kernel_rfl D1BodySized.bridgeInto141 : bridgeOf D1BodySized.s484.ffi = bridgeOf D1BodySized.s481.ffi
kernel_rfl D1BodySized.bridgeOut141 : bridgeOf D1BodySized.s485.ffi = bridgeOf D1BodySized.s484.ffi
kernel_rfl D1BodySized.sizeTable20Check141 : decide (20 ≤ D1BodySized.S484.tab.length) = true
theorem D1BodySized.sizeTable20_141 : 20 ≤ D1BodySized.S484.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check141
kernel_rfl D1BodySized.sizeOracle141 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S484.oracle = true

end Host.Load.Run.Tpl
end

section -- SP141
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece141 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s481 D1BodySized.S481) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s485 D1BodySized.S485) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted141 D1BodySized.segment141 D1BodySized.acceptedP142
    D1BodySized.haltP142 D1BodySized.stepA142 D1BodySized.topA142
    D1BodySized.oracle141 D1BodySized.fromInactive141 D1BodySized.bridgeInto141 D1BodySized.fromTable20_141
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA142 D1BodySized.sizeArgsA142 D1BodySized.sizeSymA142
    D1BodySized.sizeMlxA142 D1BodySized.sizePayA142 (by decide)
    D1BodySized.sizeDecA142 D1BodySized.sizePreA142 D1BodySized.patchB142
    D1BodySized.sizeOracle141 D1BodySized.inactive142 D1BodySized.bridgeOut141 D1BodySized.sizeTable20_141
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ142
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive142 : (bridgeOf D1BodySized.s485.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check142 : decide (20 ≤ D1BodySized.S485.tab.length) = true
theorem D1BodySized.fromTable20_142 : 20 ≤ D1BodySized.S485.tab.length := of_decide_eq_true D1BodySized.fromTable20Check142
kernel_rfl D1BodySized.bridgeInto142 : bridgeOf D1BodySized.s487.ffi = bridgeOf D1BodySized.s485.ffi
kernel_rfl D1BodySized.bridgeOut142 : bridgeOf D1BodySized.s488.ffi = bridgeOf D1BodySized.s487.ffi
kernel_rfl D1BodySized.sizeTable20Check142 : decide (20 ≤ D1BodySized.S487.tab.length) = true
theorem D1BodySized.sizeTable20_142 : 20 ≤ D1BodySized.S487.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check142
kernel_rfl D1BodySized.sizeOracle142 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S487.oracle = true

end Host.Load.Run.Tpl
end

section -- SP142
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece142 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s485 D1BodySized.S485) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s488 D1BodySized.S488) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted142 D1BodySized.segment142 D1BodySized.acceptedP143
    D1BodySized.haltP143 D1BodySized.stepA143 D1BodySized.topA143
    D1BodySized.oracle142 D1BodySized.fromInactive142 D1BodySized.bridgeInto142 D1BodySized.fromTable20_142
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA143 D1BodySized.sizeArgsA143 D1BodySized.sizeSymA143
    D1BodySized.sizeMlxA143 D1BodySized.sizePayA143 (by decide)
    D1BodySized.sizeDecA143 D1BodySized.sizePreA143 D1BodySized.patchB143
    D1BodySized.sizeOracle142 D1BodySized.inactive143 D1BodySized.bridgeOut142 D1BodySized.sizeTable20_142
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ143
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive143 : (bridgeOf D1BodySized.s488.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check143 : decide (20 ≤ D1BodySized.S488.tab.length) = true
theorem D1BodySized.fromTable20_143 : 20 ≤ D1BodySized.S488.tab.length := of_decide_eq_true D1BodySized.fromTable20Check143
kernel_rfl D1BodySized.bridgeInto143 : bridgeOf D1BodySized.s490.ffi = bridgeOf D1BodySized.s488.ffi
kernel_rfl D1BodySized.bridgeOut143 : bridgeOf D1BodySized.s491.ffi = bridgeOf D1BodySized.s490.ffi
kernel_rfl D1BodySized.sizeTable20Check143 : decide (20 ≤ D1BodySized.S490.tab.length) = true
theorem D1BodySized.sizeTable20_143 : 20 ≤ D1BodySized.S490.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check143
kernel_rfl D1BodySized.sizeOracle143 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S490.oracle = true

end Host.Load.Run.Tpl
end

section -- SP143
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece143 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s488 D1BodySized.S488) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s491 D1BodySized.S491) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted143 D1BodySized.segment143 D1BodySized.acceptedP144
    D1BodySized.haltP144 D1BodySized.stepA144 D1BodySized.topA144
    D1BodySized.oracle143 D1BodySized.fromInactive143 D1BodySized.bridgeInto143 D1BodySized.fromTable20_143
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA144 D1BodySized.sizeArgsA144 D1BodySized.sizeSymA144
    D1BodySized.sizeMlxA144 D1BodySized.sizePayA144 (by decide)
    D1BodySized.sizeDecA144 D1BodySized.sizePreA144 D1BodySized.patchB144
    D1BodySized.sizeOracle143 D1BodySized.inactive144 D1BodySized.bridgeOut143 D1BodySized.sizeTable20_143
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ144
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive144 : (bridgeOf D1BodySized.s491.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check144 : decide (20 ≤ D1BodySized.S491.tab.length) = true
theorem D1BodySized.fromTable20_144 : 20 ≤ D1BodySized.S491.tab.length := of_decide_eq_true D1BodySized.fromTable20Check144
kernel_rfl D1BodySized.bridgeInto144 : bridgeOf D1BodySized.s493.ffi = bridgeOf D1BodySized.s491.ffi
kernel_rfl D1BodySized.bridgeOut144 : bridgeOf D1BodySized.s494.ffi = bridgeOf D1BodySized.s493.ffi
kernel_rfl D1BodySized.sizeTable20Check144 : decide (20 ≤ D1BodySized.S493.tab.length) = true
theorem D1BodySized.sizeTable20_144 : 20 ≤ D1BodySized.S493.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check144
kernel_rfl D1BodySized.sizeOracle144 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S493.oracle = true

end Host.Load.Run.Tpl
end

section -- SP144
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece144 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s491 D1BodySized.S491) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s494 D1BodySized.S494) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted144 D1BodySized.segment144 D1BodySized.acceptedP145
    D1BodySized.haltP145 D1BodySized.stepA145 D1BodySized.topA145
    D1BodySized.oracle144 D1BodySized.fromInactive144 D1BodySized.bridgeInto144 D1BodySized.fromTable20_144
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA145 D1BodySized.sizeArgsA145 D1BodySized.sizeSymA145
    D1BodySized.sizeMlxA145 D1BodySized.sizePayA145 (by decide)
    D1BodySized.sizeDecA145 D1BodySized.sizePreA145 D1BodySized.patchB145
    D1BodySized.sizeOracle144 D1BodySized.inactive145 D1BodySized.bridgeOut144 D1BodySized.sizeTable20_144
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ145
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive145 : (bridgeOf D1BodySized.s494.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check145 : decide (20 ≤ D1BodySized.S494.tab.length) = true
theorem D1BodySized.fromTable20_145 : 20 ≤ D1BodySized.S494.tab.length := of_decide_eq_true D1BodySized.fromTable20Check145
kernel_rfl D1BodySized.bridgeInto145 : bridgeOf D1BodySized.s497.ffi = bridgeOf D1BodySized.s494.ffi
kernel_rfl D1BodySized.bridgeOut145 : bridgeOf D1BodySized.s498.ffi = bridgeOf D1BodySized.s497.ffi
kernel_rfl D1BodySized.sizeTable20Check145 : decide (20 ≤ D1BodySized.S497.tab.length) = true
theorem D1BodySized.sizeTable20_145 : 20 ≤ D1BodySized.S497.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check145
kernel_rfl D1BodySized.sizeOracle145 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S497.oracle = true

end Host.Load.Run.Tpl
end

section -- SP145
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece145 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s494 D1BodySized.S494) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s498 D1BodySized.S498) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted145 D1BodySized.segment145 D1BodySized.acceptedP146
    D1BodySized.haltP146 D1BodySized.stepA146 D1BodySized.topA146
    D1BodySized.oracle145 D1BodySized.fromInactive145 D1BodySized.bridgeInto145 D1BodySized.fromTable20_145
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA146 D1BodySized.sizeArgsA146 D1BodySized.sizeSymA146
    D1BodySized.sizeMlxA146 D1BodySized.sizePayA146 (by decide)
    D1BodySized.sizeDecA146 D1BodySized.sizePreA146 D1BodySized.patchB146
    D1BodySized.sizeOracle145 D1BodySized.inactive146 D1BodySized.bridgeOut145 D1BodySized.sizeTable20_145
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ146
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive146 : (bridgeOf D1BodySized.s498.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check146 : decide (20 ≤ D1BodySized.S498.tab.length) = true
theorem D1BodySized.fromTable20_146 : 20 ≤ D1BodySized.S498.tab.length := of_decide_eq_true D1BodySized.fromTable20Check146
kernel_rfl D1BodySized.bridgeInto146 : bridgeOf D1BodySized.s500.ffi = bridgeOf D1BodySized.s498.ffi
kernel_rfl D1BodySized.bridgeOut146 : bridgeOf D1BodySized.s501.ffi = bridgeOf D1BodySized.s500.ffi
kernel_rfl D1BodySized.sizeTable20Check146 : decide (20 ≤ D1BodySized.S500.tab.length) = true
theorem D1BodySized.sizeTable20_146 : 20 ≤ D1BodySized.S500.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check146
kernel_rfl D1BodySized.sizeOracle146 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S500.oracle = true

end Host.Load.Run.Tpl
end

section -- SP146
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece146 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s498 D1BodySized.S498) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s501 D1BodySized.S501) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted146 D1BodySized.segment146 D1BodySized.acceptedP147
    D1BodySized.haltP147 D1BodySized.stepA147 D1BodySized.topA147
    D1BodySized.oracle146 D1BodySized.fromInactive146 D1BodySized.bridgeInto146 D1BodySized.fromTable20_146
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA147 D1BodySized.sizeArgsA147 D1BodySized.sizeSymA147
    D1BodySized.sizeMlxA147 D1BodySized.sizePayA147 (by decide)
    D1BodySized.sizeDecA147 D1BodySized.sizePreA147 D1BodySized.patchB147
    D1BodySized.sizeOracle146 D1BodySized.inactive147 D1BodySized.bridgeOut146 D1BodySized.sizeTable20_146
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ147
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive147 : (bridgeOf D1BodySized.s501.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check147 : decide (20 ≤ D1BodySized.S501.tab.length) = true
theorem D1BodySized.fromTable20_147 : 20 ≤ D1BodySized.S501.tab.length := of_decide_eq_true D1BodySized.fromTable20Check147
kernel_rfl D1BodySized.bridgeInto147 : bridgeOf D1BodySized.s505.ffi = bridgeOf D1BodySized.s501.ffi
kernel_rfl D1BodySized.bridgeOut147 : bridgeOf D1BodySized.s506.ffi = bridgeOf D1BodySized.s505.ffi
kernel_rfl D1BodySized.sizeTable20Check147 : decide (20 ≤ D1BodySized.S505.tab.length) = true
theorem D1BodySized.sizeTable20_147 : 20 ≤ D1BodySized.S505.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check147
kernel_rfl D1BodySized.sizeOracle147 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S505.oracle = true

end Host.Load.Run.Tpl
end

section -- SP147
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece147 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s501 D1BodySized.S501) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s506 D1BodySized.S506) 22337 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted147 D1BodySized.segment147 D1BodySized.acceptedP148
    D1BodySized.haltP148 D1BodySized.stepA148 D1BodySized.topA148
    D1BodySized.oracle147 D1BodySized.fromInactive147 D1BodySized.bridgeInto147 D1BodySized.fromTable20_147
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA148 D1BodySized.sizeArgsA148 D1BodySized.sizeSymA148
    D1BodySized.sizeMlxA148 D1BodySized.sizePayA148 (by decide)
    D1BodySized.sizeDecA148 D1BodySized.sizePreA148 D1BodySized.patchB148
    D1BodySized.sizeOracle147 D1BodySized.inactive148 D1BodySized.bridgeOut147 D1BodySized.sizeTable20_147
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ148
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive148 : (bridgeOf D1BodySized.s506.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check148 : decide (20 ≤ D1BodySized.S506.tab.length) = true
theorem D1BodySized.fromTable20_148 : 20 ≤ D1BodySized.S506.tab.length := of_decide_eq_true D1BodySized.fromTable20Check148
kernel_rfl D1BodySized.bridgeInto148 : bridgeOf D1BodySized.s508.ffi = bridgeOf D1BodySized.s506.ffi
kernel_rfl D1BodySized.bridgeOut148 : bridgeOf D1BodySized.s509.ffi = bridgeOf D1BodySized.s508.ffi
kernel_rfl D1BodySized.sizeTable20Check148 : decide (20 ≤ D1BodySized.S508.tab.length) = true
theorem D1BodySized.sizeTable20_148 : 20 ≤ D1BodySized.S508.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check148
kernel_rfl D1BodySized.sizeOracle148 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S508.oracle = true

end Host.Load.Run.Tpl
end

section -- SP148
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece148 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s506 D1BodySized.S506) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s509 D1BodySized.S509) 7984 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted148 D1BodySized.segment148 D1BodySized.acceptedP149
    D1BodySized.haltP149 D1BodySized.stepA149 D1BodySized.topA149
    D1BodySized.oracle148 D1BodySized.fromInactive148 D1BodySized.bridgeInto148 D1BodySized.fromTable20_148
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA149 D1BodySized.sizeArgsA149 D1BodySized.sizeSymA149
    D1BodySized.sizeMlxA149 D1BodySized.sizePayA149 (by decide)
    D1BodySized.sizeDecA149 D1BodySized.sizePreA149 D1BodySized.patchB149
    D1BodySized.sizeOracle148 D1BodySized.inactive149 D1BodySized.bridgeOut148 D1BodySized.sizeTable20_148
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ149
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive149 : (bridgeOf D1BodySized.s509.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check149 : decide (20 ≤ D1BodySized.S509.tab.length) = true
theorem D1BodySized.fromTable20_149 : 20 ≤ D1BodySized.S509.tab.length := of_decide_eq_true D1BodySized.fromTable20Check149
kernel_rfl D1BodySized.bridgeInto149 : bridgeOf D1BodySized.s511.ffi = bridgeOf D1BodySized.s509.ffi
kernel_rfl D1BodySized.bridgeOut149 : bridgeOf D1BodySized.s512.ffi = bridgeOf D1BodySized.s511.ffi
kernel_rfl D1BodySized.sizeTable20Check149 : decide (20 ≤ D1BodySized.S511.tab.length) = true
theorem D1BodySized.sizeTable20_149 : 20 ≤ D1BodySized.S511.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check149
kernel_rfl D1BodySized.sizeOracle149 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S511.oracle = true

end Host.Load.Run.Tpl
end

section -- SP149
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece149 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s509 D1BodySized.S509) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s512 D1BodySized.S512) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted149 D1BodySized.segment149 D1BodySized.acceptedP150
    D1BodySized.haltP150 D1BodySized.stepA150 D1BodySized.topA150
    D1BodySized.oracle149 D1BodySized.fromInactive149 D1BodySized.bridgeInto149 D1BodySized.fromTable20_149
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA150 D1BodySized.sizeArgsA150 D1BodySized.sizeSymA150
    D1BodySized.sizeMlxA150 D1BodySized.sizePayA150 (by decide)
    D1BodySized.sizeDecA150 D1BodySized.sizePreA150 D1BodySized.patchB150
    D1BodySized.sizeOracle149 D1BodySized.inactive150 D1BodySized.bridgeOut149 D1BodySized.sizeTable20_149
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ150
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive150 : (bridgeOf D1BodySized.s512.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check150 : decide (20 ≤ D1BodySized.S512.tab.length) = true
theorem D1BodySized.fromTable20_150 : 20 ≤ D1BodySized.S512.tab.length := of_decide_eq_true D1BodySized.fromTable20Check150
kernel_rfl D1BodySized.bridgeInto150 : bridgeOf D1BodySized.s515.ffi = bridgeOf D1BodySized.s512.ffi
kernel_rfl D1BodySized.bridgeOut150 : bridgeOf D1BodySized.s516.ffi = bridgeOf D1BodySized.s515.ffi
kernel_rfl D1BodySized.sizeTable20Check150 : decide (20 ≤ D1BodySized.S515.tab.length) = true
theorem D1BodySized.sizeTable20_150 : 20 ≤ D1BodySized.S515.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check150
kernel_rfl D1BodySized.sizeOracle150 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S515.oracle = true

end Host.Load.Run.Tpl
end

section -- SP150
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece150 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s512 D1BodySized.S512) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s516 D1BodySized.S516) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted150 D1BodySized.segment150 D1BodySized.acceptedP151
    D1BodySized.haltP151 D1BodySized.stepA151 D1BodySized.topA151
    D1BodySized.oracle150 D1BodySized.fromInactive150 D1BodySized.bridgeInto150 D1BodySized.fromTable20_150
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA151 D1BodySized.sizeArgsA151 D1BodySized.sizeSymA151
    D1BodySized.sizeMlxA151 D1BodySized.sizePayA151 (by decide)
    D1BodySized.sizeDecA151 D1BodySized.sizePreA151 D1BodySized.patchB151
    D1BodySized.sizeOracle150 D1BodySized.inactive151 D1BodySized.bridgeOut150 D1BodySized.sizeTable20_150
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ151
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive151 : (bridgeOf D1BodySized.s516.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check151 : decide (20 ≤ D1BodySized.S516.tab.length) = true
theorem D1BodySized.fromTable20_151 : 20 ≤ D1BodySized.S516.tab.length := of_decide_eq_true D1BodySized.fromTable20Check151
kernel_rfl D1BodySized.bridgeInto151 : bridgeOf D1BodySized.s518.ffi = bridgeOf D1BodySized.s516.ffi
kernel_rfl D1BodySized.bridgeOut151 : bridgeOf D1BodySized.s519.ffi = bridgeOf D1BodySized.s518.ffi
kernel_rfl D1BodySized.sizeTable20Check151 : decide (20 ≤ D1BodySized.S518.tab.length) = true
theorem D1BodySized.sizeTable20_151 : 20 ≤ D1BodySized.S518.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check151
kernel_rfl D1BodySized.sizeOracle151 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S518.oracle = true

end Host.Load.Run.Tpl
end

section -- SP151
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece151 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s516 D1BodySized.S516) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s519 D1BodySized.S519) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted151 D1BodySized.segment151 D1BodySized.acceptedP152
    D1BodySized.haltP152 D1BodySized.stepA152 D1BodySized.topA152
    D1BodySized.oracle151 D1BodySized.fromInactive151 D1BodySized.bridgeInto151 D1BodySized.fromTable20_151
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA152 D1BodySized.sizeArgsA152 D1BodySized.sizeSymA152
    D1BodySized.sizeMlxA152 D1BodySized.sizePayA152 (by decide)
    D1BodySized.sizeDecA152 D1BodySized.sizePreA152 D1BodySized.patchB152
    D1BodySized.sizeOracle151 D1BodySized.inactive152 D1BodySized.bridgeOut151 D1BodySized.sizeTable20_151
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ152
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive152 : (bridgeOf D1BodySized.s519.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check152 : decide (20 ≤ D1BodySized.S519.tab.length) = true
theorem D1BodySized.fromTable20_152 : 20 ≤ D1BodySized.S519.tab.length := of_decide_eq_true D1BodySized.fromTable20Check152
kernel_rfl D1BodySized.bridgeInto152 : bridgeOf D1BodySized.s521.ffi = bridgeOf D1BodySized.s519.ffi
kernel_rfl D1BodySized.bridgeOut152 : bridgeOf D1BodySized.s522.ffi = bridgeOf D1BodySized.s521.ffi
kernel_rfl D1BodySized.sizeTable20Check152 : decide (20 ≤ D1BodySized.S521.tab.length) = true
theorem D1BodySized.sizeTable20_152 : 20 ≤ D1BodySized.S521.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check152
kernel_rfl D1BodySized.sizeOracle152 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S521.oracle = true

end Host.Load.Run.Tpl
end

section -- SP152
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece152 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s519 D1BodySized.S519) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s522 D1BodySized.S522) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted152 D1BodySized.segment152 D1BodySized.acceptedP153
    D1BodySized.haltP153 D1BodySized.stepA153 D1BodySized.topA153
    D1BodySized.oracle152 D1BodySized.fromInactive152 D1BodySized.bridgeInto152 D1BodySized.fromTable20_152
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA153 D1BodySized.sizeArgsA153 D1BodySized.sizeSymA153
    D1BodySized.sizeMlxA153 D1BodySized.sizePayA153 (by decide)
    D1BodySized.sizeDecA153 D1BodySized.sizePreA153 D1BodySized.patchB153
    D1BodySized.sizeOracle152 D1BodySized.inactive153 D1BodySized.bridgeOut152 D1BodySized.sizeTable20_152
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ153
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive153 : (bridgeOf D1BodySized.s522.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check153 : decide (20 ≤ D1BodySized.S522.tab.length) = true
theorem D1BodySized.fromTable20_153 : 20 ≤ D1BodySized.S522.tab.length := of_decide_eq_true D1BodySized.fromTable20Check153
kernel_rfl D1BodySized.bridgeInto153 : bridgeOf D1BodySized.s524.ffi = bridgeOf D1BodySized.s522.ffi
kernel_rfl D1BodySized.bridgeOut153 : bridgeOf D1BodySized.s525.ffi = bridgeOf D1BodySized.s524.ffi
kernel_rfl D1BodySized.sizeTable20Check153 : decide (20 ≤ D1BodySized.S524.tab.length) = true
theorem D1BodySized.sizeTable20_153 : 20 ≤ D1BodySized.S524.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check153
kernel_rfl D1BodySized.sizeOracle153 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S524.oracle = true

end Host.Load.Run.Tpl
end

section -- SP153
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece153 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s522 D1BodySized.S522) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s525 D1BodySized.S525) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted153 D1BodySized.segment153 D1BodySized.acceptedP154
    D1BodySized.haltP154 D1BodySized.stepA154 D1BodySized.topA154
    D1BodySized.oracle153 D1BodySized.fromInactive153 D1BodySized.bridgeInto153 D1BodySized.fromTable20_153
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA154 D1BodySized.sizeArgsA154 D1BodySized.sizeSymA154
    D1BodySized.sizeMlxA154 D1BodySized.sizePayA154 (by decide)
    D1BodySized.sizeDecA154 D1BodySized.sizePreA154 D1BodySized.patchB154
    D1BodySized.sizeOracle153 D1BodySized.inactive154 D1BodySized.bridgeOut153 D1BodySized.sizeTable20_153
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ154
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive154 : (bridgeOf D1BodySized.s525.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check154 : decide (20 ≤ D1BodySized.S525.tab.length) = true
theorem D1BodySized.fromTable20_154 : 20 ≤ D1BodySized.S525.tab.length := of_decide_eq_true D1BodySized.fromTable20Check154
kernel_rfl D1BodySized.bridgeInto154 : bridgeOf D1BodySized.s528.ffi = bridgeOf D1BodySized.s525.ffi
kernel_rfl D1BodySized.bridgeOut154 : bridgeOf D1BodySized.s529.ffi = bridgeOf D1BodySized.s528.ffi
kernel_rfl D1BodySized.sizeTable20Check154 : decide (20 ≤ D1BodySized.S528.tab.length) = true
theorem D1BodySized.sizeTable20_154 : 20 ≤ D1BodySized.S528.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check154
kernel_rfl D1BodySized.sizeOracle154 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S528.oracle = true

end Host.Load.Run.Tpl
end

section -- SP154
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece154 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s525 D1BodySized.S525) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s529 D1BodySized.S529) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted154 D1BodySized.segment154 D1BodySized.acceptedP155
    D1BodySized.haltP155 D1BodySized.stepA155 D1BodySized.topA155
    D1BodySized.oracle154 D1BodySized.fromInactive154 D1BodySized.bridgeInto154 D1BodySized.fromTable20_154
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA155 D1BodySized.sizeArgsA155 D1BodySized.sizeSymA155
    D1BodySized.sizeMlxA155 D1BodySized.sizePayA155 (by decide)
    D1BodySized.sizeDecA155 D1BodySized.sizePreA155 D1BodySized.patchB155
    D1BodySized.sizeOracle154 D1BodySized.inactive155 D1BodySized.bridgeOut154 D1BodySized.sizeTable20_154
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ155
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive155 : (bridgeOf D1BodySized.s529.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check155 : decide (20 ≤ D1BodySized.S529.tab.length) = true
theorem D1BodySized.fromTable20_155 : 20 ≤ D1BodySized.S529.tab.length := of_decide_eq_true D1BodySized.fromTable20Check155
kernel_rfl D1BodySized.bridgeInto155 : bridgeOf D1BodySized.s531.ffi = bridgeOf D1BodySized.s529.ffi
kernel_rfl D1BodySized.bridgeOut155 : bridgeOf D1BodySized.s532.ffi = bridgeOf D1BodySized.s531.ffi
kernel_rfl D1BodySized.sizeTable20Check155 : decide (20 ≤ D1BodySized.S531.tab.length) = true
theorem D1BodySized.sizeTable20_155 : 20 ≤ D1BodySized.S531.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check155
kernel_rfl D1BodySized.sizeOracle155 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S531.oracle = true

end Host.Load.Run.Tpl
end

section -- SP155
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece155 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s529 D1BodySized.S529) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s532 D1BodySized.S532) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted155 D1BodySized.segment155 D1BodySized.acceptedP156
    D1BodySized.haltP156 D1BodySized.stepA156 D1BodySized.topA156
    D1BodySized.oracle155 D1BodySized.fromInactive155 D1BodySized.bridgeInto155 D1BodySized.fromTable20_155
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA156 D1BodySized.sizeArgsA156 D1BodySized.sizeSymA156
    D1BodySized.sizeMlxA156 D1BodySized.sizePayA156 (by decide)
    D1BodySized.sizeDecA156 D1BodySized.sizePreA156 D1BodySized.patchB156
    D1BodySized.sizeOracle155 D1BodySized.inactive156 D1BodySized.bridgeOut155 D1BodySized.sizeTable20_155
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ156
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive156 : (bridgeOf D1BodySized.s532.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check156 : decide (20 ≤ D1BodySized.S532.tab.length) = true
theorem D1BodySized.fromTable20_156 : 20 ≤ D1BodySized.S532.tab.length := of_decide_eq_true D1BodySized.fromTable20Check156
kernel_rfl D1BodySized.bridgeInto156 : bridgeOf D1BodySized.s534.ffi = bridgeOf D1BodySized.s532.ffi
kernel_rfl D1BodySized.bridgeOut156 : bridgeOf D1BodySized.s535.ffi = bridgeOf D1BodySized.s534.ffi
kernel_rfl D1BodySized.sizeTable20Check156 : decide (20 ≤ D1BodySized.S534.tab.length) = true
theorem D1BodySized.sizeTable20_156 : 20 ≤ D1BodySized.S534.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check156
kernel_rfl D1BodySized.sizeOracle156 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S534.oracle = true

end Host.Load.Run.Tpl
end

section -- SP156
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece156 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s532 D1BodySized.S532) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s535 D1BodySized.S535) 7766 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted156 D1BodySized.segment156 D1BodySized.acceptedP157
    D1BodySized.haltP157 D1BodySized.stepA157 D1BodySized.topA157
    D1BodySized.oracle156 D1BodySized.fromInactive156 D1BodySized.bridgeInto156 D1BodySized.fromTable20_156
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA157 D1BodySized.sizeArgsA157 D1BodySized.sizeSymA157
    D1BodySized.sizeMlxA157 D1BodySized.sizePayA157 (by decide)
    D1BodySized.sizeDecA157 D1BodySized.sizePreA157 D1BodySized.patchB157
    D1BodySized.sizeOracle156 D1BodySized.inactive157 D1BodySized.bridgeOut156 D1BodySized.sizeTable20_156
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ157
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive157 : (bridgeOf D1BodySized.s535.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check157 : decide (20 ≤ D1BodySized.S535.tab.length) = true
theorem D1BodySized.fromTable20_157 : 20 ≤ D1BodySized.S535.tab.length := of_decide_eq_true D1BodySized.fromTable20Check157
kernel_rfl D1BodySized.bridgeInto157 : bridgeOf D1BodySized.s537.ffi = bridgeOf D1BodySized.s535.ffi
kernel_rfl D1BodySized.bridgeOut157 : bridgeOf D1BodySized.s538.ffi = bridgeOf D1BodySized.s537.ffi
kernel_rfl D1BodySized.sizeTable20Check157 : decide (20 ≤ D1BodySized.S537.tab.length) = true
theorem D1BodySized.sizeTable20_157 : 20 ≤ D1BodySized.S537.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check157
kernel_rfl D1BodySized.sizeOracle157 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S537.oracle = true

end Host.Load.Run.Tpl
end

section -- SP157
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece157 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s535 D1BodySized.S535) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s538 D1BodySized.S538) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted157 D1BodySized.segment157 D1BodySized.acceptedP158
    D1BodySized.haltP158 D1BodySized.stepA158 D1BodySized.topA158
    D1BodySized.oracle157 D1BodySized.fromInactive157 D1BodySized.bridgeInto157 D1BodySized.fromTable20_157
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA158 D1BodySized.sizeArgsA158 D1BodySized.sizeSymA158
    D1BodySized.sizeMlxA158 D1BodySized.sizePayA158 (by decide)
    D1BodySized.sizeDecA158 D1BodySized.sizePreA158 D1BodySized.patchB158
    D1BodySized.sizeOracle157 D1BodySized.inactive158 D1BodySized.bridgeOut157 D1BodySized.sizeTable20_157
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ158
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive158 : (bridgeOf D1BodySized.s538.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check158 : decide (20 ≤ D1BodySized.S538.tab.length) = true
theorem D1BodySized.fromTable20_158 : 20 ≤ D1BodySized.S538.tab.length := of_decide_eq_true D1BodySized.fromTable20Check158
kernel_rfl D1BodySized.bridgeInto158 : bridgeOf D1BodySized.s541.ffi = bridgeOf D1BodySized.s538.ffi
kernel_rfl D1BodySized.bridgeOut158 : bridgeOf D1BodySized.s542.ffi = bridgeOf D1BodySized.s541.ffi
kernel_rfl D1BodySized.sizeTable20Check158 : decide (20 ≤ D1BodySized.S541.tab.length) = true
theorem D1BodySized.sizeTable20_158 : 20 ≤ D1BodySized.S541.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check158
kernel_rfl D1BodySized.sizeOracle158 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S541.oracle = true

end Host.Load.Run.Tpl
end

section -- SP158
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece158 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s538 D1BodySized.S538) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s542 D1BodySized.S542) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted158 D1BodySized.segment158 D1BodySized.acceptedP159
    D1BodySized.haltP159 D1BodySized.stepA159 D1BodySized.topA159
    D1BodySized.oracle158 D1BodySized.fromInactive158 D1BodySized.bridgeInto158 D1BodySized.fromTable20_158
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA159 D1BodySized.sizeArgsA159 D1BodySized.sizeSymA159
    D1BodySized.sizeMlxA159 D1BodySized.sizePayA159 (by decide)
    D1BodySized.sizeDecA159 D1BodySized.sizePreA159 D1BodySized.patchB159
    D1BodySized.sizeOracle158 D1BodySized.inactive159 D1BodySized.bridgeOut158 D1BodySized.sizeTable20_158
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ159
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive159 : (bridgeOf D1BodySized.s542.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check159 : decide (20 ≤ D1BodySized.S542.tab.length) = true
theorem D1BodySized.fromTable20_159 : 20 ≤ D1BodySized.S542.tab.length := of_decide_eq_true D1BodySized.fromTable20Check159
kernel_rfl D1BodySized.bridgeInto159 : bridgeOf D1BodySized.s544.ffi = bridgeOf D1BodySized.s542.ffi
kernel_rfl D1BodySized.bridgeOut159 : bridgeOf D1BodySized.s545.ffi = bridgeOf D1BodySized.s544.ffi
kernel_rfl D1BodySized.sizeTable20Check159 : decide (20 ≤ D1BodySized.S544.tab.length) = true
theorem D1BodySized.sizeTable20_159 : 20 ≤ D1BodySized.S544.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check159
kernel_rfl D1BodySized.sizeOracle159 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S544.oracle = true

end Host.Load.Run.Tpl
end

section -- SP159
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece159 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s542 D1BodySized.S542) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s545 D1BodySized.S545) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted159 D1BodySized.segment159 D1BodySized.acceptedP160
    D1BodySized.haltP160 D1BodySized.stepA160 D1BodySized.topA160
    D1BodySized.oracle159 D1BodySized.fromInactive159 D1BodySized.bridgeInto159 D1BodySized.fromTable20_159
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA160 D1BodySized.sizeArgsA160 D1BodySized.sizeSymA160
    D1BodySized.sizeMlxA160 D1BodySized.sizePayA160 (by decide)
    D1BodySized.sizeDecA160 D1BodySized.sizePreA160 D1BodySized.patchB160
    D1BodySized.sizeOracle159 D1BodySized.inactive160 D1BodySized.bridgeOut159 D1BodySized.sizeTable20_159
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ160
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive160 : (bridgeOf D1BodySized.s545.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check160 : decide (20 ≤ D1BodySized.S545.tab.length) = true
theorem D1BodySized.fromTable20_160 : 20 ≤ D1BodySized.S545.tab.length := of_decide_eq_true D1BodySized.fromTable20Check160
kernel_rfl D1BodySized.bridgeInto160 : bridgeOf D1BodySized.s549.ffi = bridgeOf D1BodySized.s545.ffi
kernel_rfl D1BodySized.bridgeOut160 : bridgeOf D1BodySized.s550.ffi = bridgeOf D1BodySized.s549.ffi
kernel_rfl D1BodySized.sizeTable20Check160 : decide (20 ≤ D1BodySized.S549.tab.length) = true
theorem D1BodySized.sizeTable20_160 : 20 ≤ D1BodySized.S549.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check160
kernel_rfl D1BodySized.sizeOracle160 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S549.oracle = true

end Host.Load.Run.Tpl
end

section -- SP160
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece160 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s545 D1BodySized.S545) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s550 D1BodySized.S550) 22296 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted160 D1BodySized.segment160 D1BodySized.acceptedP161
    D1BodySized.haltP161 D1BodySized.stepA161 D1BodySized.topA161
    D1BodySized.oracle160 D1BodySized.fromInactive160 D1BodySized.bridgeInto160 D1BodySized.fromTable20_160
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA161 D1BodySized.sizeArgsA161 D1BodySized.sizeSymA161
    D1BodySized.sizeMlxA161 D1BodySized.sizePayA161 (by decide)
    D1BodySized.sizeDecA161 D1BodySized.sizePreA161 D1BodySized.patchB161
    D1BodySized.sizeOracle160 D1BodySized.inactive161 D1BodySized.bridgeOut160 D1BodySized.sizeTable20_160
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ161
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive161 : (bridgeOf D1BodySized.s550.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check161 : decide (20 ≤ D1BodySized.S550.tab.length) = true
theorem D1BodySized.fromTable20_161 : 20 ≤ D1BodySized.S550.tab.length := of_decide_eq_true D1BodySized.fromTable20Check161
kernel_rfl D1BodySized.bridgeInto161 : bridgeOf D1BodySized.s552.ffi = bridgeOf D1BodySized.s550.ffi
kernel_rfl D1BodySized.bridgeOut161 : bridgeOf D1BodySized.s553.ffi = bridgeOf D1BodySized.s552.ffi
kernel_rfl D1BodySized.sizeTable20Check161 : decide (20 ≤ D1BodySized.S552.tab.length) = true
theorem D1BodySized.sizeTable20_161 : 20 ≤ D1BodySized.S552.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check161
kernel_rfl D1BodySized.sizeOracle161 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S552.oracle = true

end Host.Load.Run.Tpl
end

section -- SP161
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece161 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s550 D1BodySized.S550) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s553 D1BodySized.S553) 7943 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted161 D1BodySized.segment161 D1BodySized.acceptedP162
    D1BodySized.haltP162 D1BodySized.stepA162 D1BodySized.topA162
    D1BodySized.oracle161 D1BodySized.fromInactive161 D1BodySized.bridgeInto161 D1BodySized.fromTable20_161
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA162 D1BodySized.sizeArgsA162 D1BodySized.sizeSymA162
    D1BodySized.sizeMlxA162 D1BodySized.sizePayA162 (by decide)
    D1BodySized.sizeDecA162 D1BodySized.sizePreA162 D1BodySized.patchB162
    D1BodySized.sizeOracle161 D1BodySized.inactive162 D1BodySized.bridgeOut161 D1BodySized.sizeTable20_161
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ162
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive162 : (bridgeOf D1BodySized.s553.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check162 : decide (20 ≤ D1BodySized.S553.tab.length) = true
theorem D1BodySized.fromTable20_162 : 20 ≤ D1BodySized.S553.tab.length := of_decide_eq_true D1BodySized.fromTable20Check162
kernel_rfl D1BodySized.bridgeInto162 : bridgeOf D1BodySized.s555.ffi = bridgeOf D1BodySized.s553.ffi
kernel_rfl D1BodySized.bridgeOut162 : bridgeOf D1BodySized.s556.ffi = bridgeOf D1BodySized.s555.ffi
kernel_rfl D1BodySized.sizeTable20Check162 : decide (20 ≤ D1BodySized.S555.tab.length) = true
theorem D1BodySized.sizeTable20_162 : 20 ≤ D1BodySized.S555.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check162
kernel_rfl D1BodySized.sizeOracle162 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S555.oracle = true

end Host.Load.Run.Tpl
end

section -- SP162
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece162 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s553 D1BodySized.S553) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s556 D1BodySized.S556) 1940 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted162 D1BodySized.segment162 D1BodySized.acceptedP163
    D1BodySized.haltP163 D1BodySized.stepA163 D1BodySized.topA163
    D1BodySized.oracle162 D1BodySized.fromInactive162 D1BodySized.bridgeInto162 D1BodySized.fromTable20_162
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA163 D1BodySized.sizeArgsA163 D1BodySized.sizeSymA163
    D1BodySized.sizeMlxA163 D1BodySized.sizePayA163 (by decide)
    D1BodySized.sizeDecA163 D1BodySized.sizePreA163 D1BodySized.patchB163
    D1BodySized.sizeOracle162 D1BodySized.inactive163 D1BodySized.bridgeOut162 D1BodySized.sizeTable20_162
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ163
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive163 : (bridgeOf D1BodySized.s556.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check163 : decide (20 ≤ D1BodySized.S556.tab.length) = true
theorem D1BodySized.fromTable20_163 : 20 ≤ D1BodySized.S556.tab.length := of_decide_eq_true D1BodySized.fromTable20Check163
kernel_rfl D1BodySized.bridgeInto163 : bridgeOf D1BodySized.s559.ffi = bridgeOf D1BodySized.s556.ffi
kernel_rfl D1BodySized.bridgeOut163 : bridgeOf D1BodySized.s560.ffi = bridgeOf D1BodySized.s559.ffi
kernel_rfl D1BodySized.sizeTable20Check163 : decide (20 ≤ D1BodySized.S559.tab.length) = true
theorem D1BodySized.sizeTable20_163 : 20 ≤ D1BodySized.S559.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check163
kernel_rfl D1BodySized.sizeOracle163 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S559.oracle = true

end Host.Load.Run.Tpl
end

section -- SP163
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece163 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s556 D1BodySized.S556) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s560 D1BodySized.S560) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted163 D1BodySized.segment163 D1BodySized.acceptedP164
    D1BodySized.haltP164 D1BodySized.stepA164 D1BodySized.topA164
    D1BodySized.oracle163 D1BodySized.fromInactive163 D1BodySized.bridgeInto163 D1BodySized.fromTable20_163
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA164 D1BodySized.sizeArgsA164 D1BodySized.sizeSymA164
    D1BodySized.sizeMlxA164 D1BodySized.sizePayA164 (by decide)
    D1BodySized.sizeDecA164 D1BodySized.sizePreA164 D1BodySized.patchB164
    D1BodySized.sizeOracle163 D1BodySized.inactive164 D1BodySized.bridgeOut163 D1BodySized.sizeTable20_163
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ164
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive164 : (bridgeOf D1BodySized.s560.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check164 : decide (20 ≤ D1BodySized.S560.tab.length) = true
theorem D1BodySized.fromTable20_164 : 20 ≤ D1BodySized.S560.tab.length := of_decide_eq_true D1BodySized.fromTable20Check164
kernel_rfl D1BodySized.bridgeInto164 : bridgeOf D1BodySized.s562.ffi = bridgeOf D1BodySized.s560.ffi
kernel_rfl D1BodySized.bridgeOut164 : bridgeOf D1BodySized.s563.ffi = bridgeOf D1BodySized.s562.ffi
kernel_rfl D1BodySized.sizeTable20Check164 : decide (20 ≤ D1BodySized.S562.tab.length) = true
theorem D1BodySized.sizeTable20_164 : 20 ≤ D1BodySized.S562.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check164
kernel_rfl D1BodySized.sizeOracle164 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S562.oracle = true

end Host.Load.Run.Tpl
end

section -- SP164
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece164 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s560 D1BodySized.S560) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s563 D1BodySized.S563) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted164 D1BodySized.segment164 D1BodySized.acceptedP165
    D1BodySized.haltP165 D1BodySized.stepA165 D1BodySized.topA165
    D1BodySized.oracle164 D1BodySized.fromInactive164 D1BodySized.bridgeInto164 D1BodySized.fromTable20_164
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA165 D1BodySized.sizeArgsA165 D1BodySized.sizeSymA165
    D1BodySized.sizeMlxA165 D1BodySized.sizePayA165 (by decide)
    D1BodySized.sizeDecA165 D1BodySized.sizePreA165 D1BodySized.patchB165
    D1BodySized.sizeOracle164 D1BodySized.inactive165 D1BodySized.bridgeOut164 D1BodySized.sizeTable20_164
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ165
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive165 : (bridgeOf D1BodySized.s563.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check165 : decide (20 ≤ D1BodySized.S563.tab.length) = true
theorem D1BodySized.fromTable20_165 : 20 ≤ D1BodySized.S563.tab.length := of_decide_eq_true D1BodySized.fromTable20Check165
kernel_rfl D1BodySized.bridgeInto165 : bridgeOf D1BodySized.s565.ffi = bridgeOf D1BodySized.s563.ffi
kernel_rfl D1BodySized.bridgeOut165 : bridgeOf D1BodySized.s566.ffi = bridgeOf D1BodySized.s565.ffi
kernel_rfl D1BodySized.sizeTable20Check165 : decide (20 ≤ D1BodySized.S565.tab.length) = true
theorem D1BodySized.sizeTable20_165 : 20 ≤ D1BodySized.S565.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check165
kernel_rfl D1BodySized.sizeOracle165 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S565.oracle = true

end Host.Load.Run.Tpl
end

section -- SP165
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece165 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s563 D1BodySized.S563) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s566 D1BodySized.S566) 7720 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted165 D1BodySized.segment165 D1BodySized.acceptedP166
    D1BodySized.haltP166 D1BodySized.stepA166 D1BodySized.topA166
    D1BodySized.oracle165 D1BodySized.fromInactive165 D1BodySized.bridgeInto165 D1BodySized.fromTable20_165
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA166 D1BodySized.sizeArgsA166 D1BodySized.sizeSymA166
    D1BodySized.sizeMlxA166 D1BodySized.sizePayA166 (by decide)
    D1BodySized.sizeDecA166 D1BodySized.sizePreA166 D1BodySized.patchB166
    D1BodySized.sizeOracle165 D1BodySized.inactive166 D1BodySized.bridgeOut165 D1BodySized.sizeTable20_165
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ166
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive166 : (bridgeOf D1BodySized.s566.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check166 : decide (20 ≤ D1BodySized.S566.tab.length) = true
theorem D1BodySized.fromTable20_166 : 20 ≤ D1BodySized.S566.tab.length := of_decide_eq_true D1BodySized.fromTable20Check166
kernel_rfl D1BodySized.bridgeInto166 : bridgeOf D1BodySized.s569.ffi = bridgeOf D1BodySized.s566.ffi
kernel_rfl D1BodySized.bridgeOut166 : bridgeOf D1BodySized.s570.ffi = bridgeOf D1BodySized.s569.ffi
kernel_rfl D1BodySized.sizeTable20Check166 : decide (20 ≤ D1BodySized.S569.tab.length) = true
theorem D1BodySized.sizeTable20_166 : 20 ≤ D1BodySized.S569.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check166
kernel_rfl D1BodySized.sizeOracle166 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S569.oracle = true

end Host.Load.Run.Tpl
end

section -- SP166
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece166 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s566 D1BodySized.S566) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s570 D1BodySized.S570) 13411 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted166 D1BodySized.segment166 D1BodySized.acceptedP167
    D1BodySized.haltP167 D1BodySized.stepA167 D1BodySized.topA167
    D1BodySized.oracle166 D1BodySized.fromInactive166 D1BodySized.bridgeInto166 D1BodySized.fromTable20_166
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA167 D1BodySized.sizeArgsA167 D1BodySized.sizeSymA167
    D1BodySized.sizeMlxA167 D1BodySized.sizePayA167 (by decide)
    D1BodySized.sizeDecA167 D1BodySized.sizePreA167 D1BodySized.patchB167
    D1BodySized.sizeOracle166 D1BodySized.inactive167 D1BodySized.bridgeOut166 D1BodySized.sizeTable20_166
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ167
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive167 : (bridgeOf D1BodySized.s570.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check167 : decide (20 ≤ D1BodySized.S570.tab.length) = true
theorem D1BodySized.fromTable20_167 : 20 ≤ D1BodySized.S570.tab.length := of_decide_eq_true D1BodySized.fromTable20Check167
kernel_rfl D1BodySized.bridgeInto167 : bridgeOf D1BodySized.s572.ffi = bridgeOf D1BodySized.s570.ffi
kernel_rfl D1BodySized.bridgeOut167 : bridgeOf D1BodySized.s573.ffi = bridgeOf D1BodySized.s572.ffi
kernel_rfl D1BodySized.sizeTable20Check167 : decide (20 ≤ D1BodySized.S572.tab.length) = true
theorem D1BodySized.sizeTable20_167 : 20 ≤ D1BodySized.S572.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check167
kernel_rfl D1BodySized.sizeOracle167 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S572.oracle = true

end Host.Load.Run.Tpl
end

section -- SP167
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece167 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s570 D1BodySized.S570) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s573 D1BodySized.S573) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted167 D1BodySized.segment167 D1BodySized.acceptedP168
    D1BodySized.haltP168 D1BodySized.stepA168 D1BodySized.topA168
    D1BodySized.oracle167 D1BodySized.fromInactive167 D1BodySized.bridgeInto167 D1BodySized.fromTable20_167
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA168 D1BodySized.sizeArgsA168 D1BodySized.sizeSymA168
    D1BodySized.sizeMlxA168 D1BodySized.sizePayA168 (by decide)
    D1BodySized.sizeDecA168 D1BodySized.sizePreA168 D1BodySized.patchB168
    D1BodySized.sizeOracle167 D1BodySized.inactive168 D1BodySized.bridgeOut167 D1BodySized.sizeTable20_167
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ168
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive168 : (bridgeOf D1BodySized.s573.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check168 : decide (20 ≤ D1BodySized.S573.tab.length) = true
theorem D1BodySized.fromTable20_168 : 20 ≤ D1BodySized.S573.tab.length := of_decide_eq_true D1BodySized.fromTable20Check168
kernel_rfl D1BodySized.bridgeInto168 : bridgeOf D1BodySized.s577.ffi = bridgeOf D1BodySized.s573.ffi
kernel_rfl D1BodySized.bridgeOut168 : bridgeOf D1BodySized.s578.ffi = bridgeOf D1BodySized.s577.ffi
kernel_rfl D1BodySized.sizeTable20Check168 : decide (20 ≤ D1BodySized.S577.tab.length) = true
theorem D1BodySized.sizeTable20_168 : 20 ≤ D1BodySized.S577.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check168
kernel_rfl D1BodySized.sizeOracle168 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S577.oracle = true

end Host.Load.Run.Tpl
end

section -- SP168
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece168 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s573 D1BodySized.S573) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s578 D1BodySized.S578) 21476 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted168 D1BodySized.segment168 D1BodySized.acceptedP169
    D1BodySized.haltP169 D1BodySized.stepA169 D1BodySized.topA169
    D1BodySized.oracle168 D1BodySized.fromInactive168 D1BodySized.bridgeInto168 D1BodySized.fromTable20_168
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA169 D1BodySized.sizeArgsA169 D1BodySized.sizeSymA169
    D1BodySized.sizeMlxA169 D1BodySized.sizePayA169 (by decide)
    D1BodySized.sizeDecA169 D1BodySized.sizePreA169 D1BodySized.patchB169
    D1BodySized.sizeOracle168 D1BodySized.inactive169 D1BodySized.bridgeOut168 D1BodySized.sizeTable20_168
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ169
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive169 : (bridgeOf D1BodySized.s578.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check169 : decide (20 ≤ D1BodySized.S578.tab.length) = true
theorem D1BodySized.fromTable20_169 : 20 ≤ D1BodySized.S578.tab.length := of_decide_eq_true D1BodySized.fromTable20Check169
kernel_rfl D1BodySized.bridgeInto169 : bridgeOf D1BodySized.s582.ffi = bridgeOf D1BodySized.s578.ffi
kernel_rfl D1BodySized.bridgeOut169 : bridgeOf D1BodySized.s583.ffi = bridgeOf D1BodySized.s582.ffi
kernel_rfl D1BodySized.sizeTable20Check169 : decide (20 ≤ D1BodySized.S582.tab.length) = true
theorem D1BodySized.sizeTable20_169 : 20 ≤ D1BodySized.S582.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check169
kernel_rfl D1BodySized.sizeOracle169 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S582.oracle = true

end Host.Load.Run.Tpl
end

section -- SP169
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece169 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s578 D1BodySized.S578) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s583 D1BodySized.S583) 22344 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted169 D1BodySized.segment169 D1BodySized.acceptedP170
    D1BodySized.haltP170 D1BodySized.stepA170 D1BodySized.topA170
    D1BodySized.oracle169 D1BodySized.fromInactive169 D1BodySized.bridgeInto169 D1BodySized.fromTable20_169
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA170 D1BodySized.sizeArgsA170 D1BodySized.sizeSymA170
    D1BodySized.sizeMlxA170 D1BodySized.sizePayA170 (by decide)
    D1BodySized.sizeDecA170 D1BodySized.sizePreA170 D1BodySized.patchB170
    D1BodySized.sizeOracle169 D1BodySized.inactive170 D1BodySized.bridgeOut169 D1BodySized.sizeTable20_169
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ170
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive170 : (bridgeOf D1BodySized.s583.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check170 : decide (20 ≤ D1BodySized.S583.tab.length) = true
theorem D1BodySized.fromTable20_170 : 20 ≤ D1BodySized.S583.tab.length := of_decide_eq_true D1BodySized.fromTable20Check170
kernel_rfl D1BodySized.bridgeInto170 : bridgeOf D1BodySized.s587.ffi = bridgeOf D1BodySized.s583.ffi
kernel_rfl D1BodySized.bridgeOut170 : bridgeOf D1BodySized.s588.ffi = bridgeOf D1BodySized.s587.ffi
kernel_rfl D1BodySized.sizeTable20Check170 : decide (20 ≤ D1BodySized.S587.tab.length) = true
theorem D1BodySized.sizeTable20_170 : 20 ≤ D1BodySized.S587.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check170
kernel_rfl D1BodySized.sizeOracle170 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S587.oracle = true

end Host.Load.Run.Tpl
end

section -- SP170
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece170 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s583 D1BodySized.S583) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s588 D1BodySized.S588) 21742 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted170 D1BodySized.segment170 D1BodySized.acceptedP171
    D1BodySized.haltP171 D1BodySized.stepA171 D1BodySized.topA171
    D1BodySized.oracle170 D1BodySized.fromInactive170 D1BodySized.bridgeInto170 D1BodySized.fromTable20_170
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA171 D1BodySized.sizeArgsA171 D1BodySized.sizeSymA171
    D1BodySized.sizeMlxA171 D1BodySized.sizePayA171 (by decide)
    D1BodySized.sizeDecA171 D1BodySized.sizePreA171 D1BodySized.patchB171
    D1BodySized.sizeOracle170 D1BodySized.inactive171 D1BodySized.bridgeOut170 D1BodySized.sizeTable20_170
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ171
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive171 : (bridgeOf D1BodySized.s588.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check171 : decide (20 ≤ D1BodySized.S588.tab.length) = true
theorem D1BodySized.fromTable20_171 : 20 ≤ D1BodySized.S588.tab.length := of_decide_eq_true D1BodySized.fromTable20Check171
kernel_rfl D1BodySized.bridgeInto171 : bridgeOf D1BodySized.s592.ffi = bridgeOf D1BodySized.s588.ffi
kernel_rfl D1BodySized.bridgeOut171 : bridgeOf D1BodySized.s593.ffi = bridgeOf D1BodySized.s592.ffi
kernel_rfl D1BodySized.sizeTable20Check171 : decide (20 ≤ D1BodySized.S592.tab.length) = true
theorem D1BodySized.sizeTable20_171 : 20 ≤ D1BodySized.S592.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check171
kernel_rfl D1BodySized.sizeOracle171 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S592.oracle = true

end Host.Load.Run.Tpl
end

section -- SP171
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece171 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s588 D1BodySized.S588) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s593 D1BodySized.S593) 21529 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted171 D1BodySized.segment171 D1BodySized.acceptedP172
    D1BodySized.haltP172 D1BodySized.stepA172 D1BodySized.topA172
    D1BodySized.oracle171 D1BodySized.fromInactive171 D1BodySized.bridgeInto171 D1BodySized.fromTable20_171
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA172 D1BodySized.sizeArgsA172 D1BodySized.sizeSymA172
    D1BodySized.sizeMlxA172 D1BodySized.sizePayA172 (by decide)
    D1BodySized.sizeDecA172 D1BodySized.sizePreA172 D1BodySized.patchB172
    D1BodySized.sizeOracle171 D1BodySized.inactive172 D1BodySized.bridgeOut171 D1BodySized.sizeTable20_171
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ172
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive172 : (bridgeOf D1BodySized.s593.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check172 : decide (20 ≤ D1BodySized.S593.tab.length) = true
theorem D1BodySized.fromTable20_172 : 20 ≤ D1BodySized.S593.tab.length := of_decide_eq_true D1BodySized.fromTable20Check172
kernel_rfl D1BodySized.bridgeInto172 : bridgeOf D1BodySized.s595.ffi = bridgeOf D1BodySized.s593.ffi
kernel_rfl D1BodySized.bridgeOut172 : bridgeOf D1BodySized.s596.ffi = bridgeOf D1BodySized.s595.ffi
kernel_rfl D1BodySized.sizeTable20Check172 : decide (20 ≤ D1BodySized.S595.tab.length) = true
theorem D1BodySized.sizeTable20_172 : 20 ≤ D1BodySized.S595.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check172
kernel_rfl D1BodySized.sizeOracle172 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S595.oracle = true

end Host.Load.Run.Tpl
end

section -- SP172
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece172 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s593 D1BodySized.S593) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s596 D1BodySized.S596) 8610 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted172 D1BodySized.segment172 D1BodySized.acceptedP173
    D1BodySized.haltP173 D1BodySized.stepA173 D1BodySized.topA173
    D1BodySized.oracle172 D1BodySized.fromInactive172 D1BodySized.bridgeInto172 D1BodySized.fromTable20_172
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA173 D1BodySized.sizeArgsA173 D1BodySized.sizeSymA173
    D1BodySized.sizeMlxA173 D1BodySized.sizePayA173 (by decide)
    D1BodySized.sizeDecA173 D1BodySized.sizePreA173 D1BodySized.patchB173
    D1BodySized.sizeOracle172 D1BodySized.inactive173 D1BodySized.bridgeOut172 D1BodySized.sizeTable20_172
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ173
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive173 : (bridgeOf D1BodySized.s596.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check173 : decide (20 ≤ D1BodySized.S596.tab.length) = true
theorem D1BodySized.fromTable20_173 : 20 ≤ D1BodySized.S596.tab.length := of_decide_eq_true D1BodySized.fromTable20Check173
kernel_rfl D1BodySized.bridgeInto173 : bridgeOf D1BodySized.s599.ffi = bridgeOf D1BodySized.s596.ffi
kernel_rfl D1BodySized.bridgeOut173 : bridgeOf D1BodySized.s600.ffi = bridgeOf D1BodySized.s599.ffi
kernel_rfl D1BodySized.sizeTable20Check173 : decide (20 ≤ D1BodySized.S599.tab.length) = true
theorem D1BodySized.sizeTable20_173 : 20 ≤ D1BodySized.S599.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check173
kernel_rfl D1BodySized.sizeOracle173 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S599.oracle = true

end Host.Load.Run.Tpl
end

section -- SP173
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece173 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s596 D1BodySized.S596) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s600 D1BodySized.S600) 12574 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted173 D1BodySized.segment173 D1BodySized.acceptedP174
    D1BodySized.haltP174 D1BodySized.stepA174 D1BodySized.topA174
    D1BodySized.oracle173 D1BodySized.fromInactive173 D1BodySized.bridgeInto173 D1BodySized.fromTable20_173
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA174 D1BodySized.sizeArgsA174 D1BodySized.sizeSymA174
    D1BodySized.sizeMlxA174 D1BodySized.sizePayA174 (by decide)
    D1BodySized.sizeDecA174 D1BodySized.sizePreA174 D1BodySized.patchB174
    D1BodySized.sizeOracle173 D1BodySized.inactive174 D1BodySized.bridgeOut173 D1BodySized.sizeTable20_173
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ174
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive174 : (bridgeOf D1BodySized.s600.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check174 : decide (20 ≤ D1BodySized.S600.tab.length) = true
theorem D1BodySized.fromTable20_174 : 20 ≤ D1BodySized.S600.tab.length := of_decide_eq_true D1BodySized.fromTable20Check174
kernel_rfl D1BodySized.bridgeInto174 : bridgeOf D1BodySized.s602.ffi = bridgeOf D1BodySized.s600.ffi
kernel_rfl D1BodySized.bridgeOut174 : bridgeOf D1BodySized.s603.ffi = bridgeOf D1BodySized.s602.ffi
kernel_rfl D1BodySized.sizeTable20Check174 : decide (20 ≤ D1BodySized.S602.tab.length) = true
theorem D1BodySized.sizeTable20_174 : 20 ≤ D1BodySized.S602.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check174
kernel_rfl D1BodySized.sizeOracle174 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S602.oracle = true

end Host.Load.Run.Tpl
end

section -- SP174
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece174 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s600 D1BodySized.S600) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s603 D1BodySized.S603) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted174 D1BodySized.segment174 D1BodySized.acceptedP175
    D1BodySized.haltP175 D1BodySized.stepA175 D1BodySized.topA175
    D1BodySized.oracle174 D1BodySized.fromInactive174 D1BodySized.bridgeInto174 D1BodySized.fromTable20_174
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA175 D1BodySized.sizeArgsA175 D1BodySized.sizeSymA175
    D1BodySized.sizeMlxA175 D1BodySized.sizePayA175 (by decide)
    D1BodySized.sizeDecA175 D1BodySized.sizePreA175 D1BodySized.patchB175
    D1BodySized.sizeOracle174 D1BodySized.inactive175 D1BodySized.bridgeOut174 D1BodySized.sizeTable20_174
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ175
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive175 : (bridgeOf D1BodySized.s603.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check175 : decide (20 ≤ D1BodySized.S603.tab.length) = true
theorem D1BodySized.fromTable20_175 : 20 ≤ D1BodySized.S603.tab.length := of_decide_eq_true D1BodySized.fromTable20Check175
kernel_rfl D1BodySized.bridgeInto175 : bridgeOf D1BodySized.s607.ffi = bridgeOf D1BodySized.s603.ffi
kernel_rfl D1BodySized.bridgeOut175 : bridgeOf D1BodySized.s608.ffi = bridgeOf D1BodySized.s607.ffi
kernel_rfl D1BodySized.sizeTable20Check175 : decide (20 ≤ D1BodySized.S607.tab.length) = true
theorem D1BodySized.sizeTable20_175 : 20 ≤ D1BodySized.S607.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check175
kernel_rfl D1BodySized.sizeOracle175 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S607.oracle = true

end Host.Load.Run.Tpl
end

section -- SP175
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece175 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s603 D1BodySized.S603) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s608 D1BodySized.S608) 22344 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted175 D1BodySized.segment175 D1BodySized.acceptedP176
    D1BodySized.haltP176 D1BodySized.stepA176 D1BodySized.topA176
    D1BodySized.oracle175 D1BodySized.fromInactive175 D1BodySized.bridgeInto175 D1BodySized.fromTable20_175
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA176 D1BodySized.sizeArgsA176 D1BodySized.sizeSymA176
    D1BodySized.sizeMlxA176 D1BodySized.sizePayA176 (by decide)
    D1BodySized.sizeDecA176 D1BodySized.sizePreA176 D1BodySized.patchB176
    D1BodySized.sizeOracle175 D1BodySized.inactive176 D1BodySized.bridgeOut175 D1BodySized.sizeTable20_175
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ176
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive176 : (bridgeOf D1BodySized.s608.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check176 : decide (20 ≤ D1BodySized.S608.tab.length) = true
theorem D1BodySized.fromTable20_176 : 20 ≤ D1BodySized.S608.tab.length := of_decide_eq_true D1BodySized.fromTable20Check176
kernel_rfl D1BodySized.bridgeInto176 : bridgeOf D1BodySized.s612.ffi = bridgeOf D1BodySized.s608.ffi
kernel_rfl D1BodySized.bridgeOut176 : bridgeOf D1BodySized.s613.ffi = bridgeOf D1BodySized.s612.ffi
kernel_rfl D1BodySized.sizeTable20Check176 : decide (20 ≤ D1BodySized.S612.tab.length) = true
theorem D1BodySized.sizeTable20_176 : 20 ≤ D1BodySized.S612.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check176
kernel_rfl D1BodySized.sizeOracle176 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S612.oracle = true

end Host.Load.Run.Tpl
end

section -- SP176
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece176 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s608 D1BodySized.S608) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s613 D1BodySized.S613) 20299 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted176 D1BodySized.segment176 D1BodySized.acceptedP177
    D1BodySized.haltP177 D1BodySized.stepA177 D1BodySized.topA177
    D1BodySized.oracle176 D1BodySized.fromInactive176 D1BodySized.bridgeInto176 D1BodySized.fromTable20_176
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA177 D1BodySized.sizeArgsA177 D1BodySized.sizeSymA177
    D1BodySized.sizeMlxA177 D1BodySized.sizePayA177 (by decide)
    D1BodySized.sizeDecA177 D1BodySized.sizePreA177 D1BodySized.patchB177
    D1BodySized.sizeOracle176 D1BodySized.inactive177 D1BodySized.bridgeOut176 D1BodySized.sizeTable20_176
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ177
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive177 : (bridgeOf D1BodySized.s613.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check177 : decide (20 ≤ D1BodySized.S613.tab.length) = true
theorem D1BodySized.fromTable20_177 : 20 ≤ D1BodySized.S613.tab.length := of_decide_eq_true D1BodySized.fromTable20Check177
kernel_rfl D1BodySized.bridgeInto177 : bridgeOf D1BodySized.s615.ffi = bridgeOf D1BodySized.s613.ffi
kernel_rfl D1BodySized.bridgeOut177 : bridgeOf D1BodySized.s616.ffi = bridgeOf D1BodySized.s615.ffi
kernel_rfl D1BodySized.sizeTable20Check177 : decide (20 ≤ D1BodySized.S615.tab.length) = true
theorem D1BodySized.sizeTable20_177 : 20 ≤ D1BodySized.S615.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check177
kernel_rfl D1BodySized.sizeOracle177 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S615.oracle = true

end Host.Load.Run.Tpl
end

section -- SP177
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece177 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s613 D1BodySized.S613) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s616 D1BodySized.S616) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted177 D1BodySized.segment177 D1BodySized.acceptedP178
    D1BodySized.haltP178 D1BodySized.stepA178 D1BodySized.topA178
    D1BodySized.oracle177 D1BodySized.fromInactive177 D1BodySized.bridgeInto177 D1BodySized.fromTable20_177
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA178 D1BodySized.sizeArgsA178 D1BodySized.sizeSymA178
    D1BodySized.sizeMlxA178 D1BodySized.sizePayA178 (by decide)
    D1BodySized.sizeDecA178 D1BodySized.sizePreA178 D1BodySized.patchB178
    D1BodySized.sizeOracle177 D1BodySized.inactive178 D1BodySized.bridgeOut177 D1BodySized.sizeTable20_177
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ178
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive178 : (bridgeOf D1BodySized.s616.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check178 : decide (20 ≤ D1BodySized.S616.tab.length) = true
theorem D1BodySized.fromTable20_178 : 20 ≤ D1BodySized.S616.tab.length := of_decide_eq_true D1BodySized.fromTable20Check178
kernel_rfl D1BodySized.bridgeInto178 : bridgeOf D1BodySized.s620.ffi = bridgeOf D1BodySized.s616.ffi
kernel_rfl D1BodySized.bridgeOut178 : bridgeOf D1BodySized.s621.ffi = bridgeOf D1BodySized.s620.ffi
kernel_rfl D1BodySized.sizeTable20Check178 : decide (20 ≤ D1BodySized.S620.tab.length) = true
theorem D1BodySized.sizeTable20_178 : 20 ≤ D1BodySized.S620.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check178
kernel_rfl D1BodySized.sizeOracle178 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S620.oracle = true

end Host.Load.Run.Tpl
end

section -- SP178
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece178 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s616 D1BodySized.S616) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s621 D1BodySized.S621) 21524 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted178 D1BodySized.segment178 D1BodySized.acceptedP179
    D1BodySized.haltP179 D1BodySized.stepA179 D1BodySized.topA179
    D1BodySized.oracle178 D1BodySized.fromInactive178 D1BodySized.bridgeInto178 D1BodySized.fromTable20_178
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA179 D1BodySized.sizeArgsA179 D1BodySized.sizeSymA179
    D1BodySized.sizeMlxA179 D1BodySized.sizePayA179 (by decide)
    D1BodySized.sizeDecA179 D1BodySized.sizePreA179 D1BodySized.patchB179
    D1BodySized.sizeOracle178 D1BodySized.inactive179 D1BodySized.bridgeOut178 D1BodySized.sizeTable20_178
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ179
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive179 : (bridgeOf D1BodySized.s621.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check179 : decide (20 ≤ D1BodySized.S621.tab.length) = true
theorem D1BodySized.fromTable20_179 : 20 ≤ D1BodySized.S621.tab.length := of_decide_eq_true D1BodySized.fromTable20Check179
kernel_rfl D1BodySized.bridgeInto179 : bridgeOf D1BodySized.s625.ffi = bridgeOf D1BodySized.s621.ffi
kernel_rfl D1BodySized.bridgeOut179 : bridgeOf D1BodySized.s626.ffi = bridgeOf D1BodySized.s625.ffi
kernel_rfl D1BodySized.sizeTable20Check179 : decide (20 ≤ D1BodySized.S625.tab.length) = true
theorem D1BodySized.sizeTable20_179 : 20 ≤ D1BodySized.S625.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check179
kernel_rfl D1BodySized.sizeOracle179 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S625.oracle = true

end Host.Load.Run.Tpl
end

section -- SP179
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece179 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s621 D1BodySized.S621) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s626 D1BodySized.S626) 20081 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted179 D1BodySized.segment179 D1BodySized.acceptedP180
    D1BodySized.haltP180 D1BodySized.stepA180 D1BodySized.topA180
    D1BodySized.oracle179 D1BodySized.fromInactive179 D1BodySized.bridgeInto179 D1BodySized.fromTable20_179
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA180 D1BodySized.sizeArgsA180 D1BodySized.sizeSymA180
    D1BodySized.sizeMlxA180 D1BodySized.sizePayA180 (by decide)
    D1BodySized.sizeDecA180 D1BodySized.sizePreA180 D1BodySized.patchB180
    D1BodySized.sizeOracle179 D1BodySized.inactive180 D1BodySized.bridgeOut179 D1BodySized.sizeTable20_179
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ180
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive180 : (bridgeOf D1BodySized.s626.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check180 : decide (20 ≤ D1BodySized.S626.tab.length) = true
theorem D1BodySized.fromTable20_180 : 20 ≤ D1BodySized.S626.tab.length := of_decide_eq_true D1BodySized.fromTable20Check180
kernel_rfl D1BodySized.bridgeInto180 : bridgeOf D1BodySized.s628.ffi = bridgeOf D1BodySized.s626.ffi
kernel_rfl D1BodySized.bridgeOut180 : bridgeOf D1BodySized.s629.ffi = bridgeOf D1BodySized.s628.ffi
kernel_rfl D1BodySized.sizeTable20Check180 : decide (20 ≤ D1BodySized.S628.tab.length) = true
theorem D1BodySized.sizeTable20_180 : 20 ≤ D1BodySized.S628.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check180
kernel_rfl D1BodySized.sizeOracle180 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S628.oracle = true

end Host.Load.Run.Tpl
end

section -- SP180
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece180 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s626 D1BodySized.S626) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s629 D1BodySized.S629) 2546 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted180 D1BodySized.segment180 D1BodySized.acceptedP181
    D1BodySized.haltP181 D1BodySized.stepA181 D1BodySized.topA181
    D1BodySized.oracle180 D1BodySized.fromInactive180 D1BodySized.bridgeInto180 D1BodySized.fromTable20_180
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA181 D1BodySized.sizeArgsA181 D1BodySized.sizeSymA181
    D1BodySized.sizeMlxA181 D1BodySized.sizePayA181 (by decide)
    D1BodySized.sizeDecA181 D1BodySized.sizePreA181 D1BodySized.patchB181
    D1BodySized.sizeOracle180 D1BodySized.inactive181 D1BodySized.bridgeOut180 D1BodySized.sizeTable20_180
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ181
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive181 : (bridgeOf D1BodySized.s629.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check181 : decide (20 ≤ D1BodySized.S629.tab.length) = true
theorem D1BodySized.fromTable20_181 : 20 ≤ D1BodySized.S629.tab.length := of_decide_eq_true D1BodySized.fromTable20Check181
kernel_rfl D1BodySized.bridgeInto181 : bridgeOf D1BodySized.s633.ffi = bridgeOf D1BodySized.s629.ffi
kernel_rfl D1BodySized.bridgeOut181 : bridgeOf D1BodySized.s634.ffi = bridgeOf D1BodySized.s633.ffi
kernel_rfl D1BodySized.sizeTable20Check181 : decide (20 ≤ D1BodySized.S633.tab.length) = true
theorem D1BodySized.sizeTable20_181 : 20 ≤ D1BodySized.S633.tab.length := of_decide_eq_true D1BodySized.sizeTable20Check181
kernel_rfl D1BodySized.sizeOracle181 : goodEnum final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S633.oracle = true

end Host.Load.Run.Tpl
end

section -- SP181
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece181 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s629 D1BodySized.S629) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s634 D1BodySized.S634) 22296 := by
  have h1 := D1BodyTrace.toCall (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.accepted181 D1BodySized.segment181 D1BodySized.acceptedP182
    D1BodySized.haltP182 D1BodySized.stepA182 D1BodySized.topA182
    D1BodySized.oracle181 D1BodySized.fromInactive181 D1BodySized.bridgeInto181 D1BodySized.fromTable20_181
  have h2 := D1BodyAdvance.size (NB := NB) (T := T) (tk := tk) (π := π) (K0 := K0) (M0 := M0) (y0 := y0)
    D1BodySized.sizeA182 D1BodySized.sizeArgsA182 D1BodySized.sizeSymA182
    D1BodySized.sizeMlxA182 D1BodySized.sizePayA182 (by decide)
    D1BodySized.sizeDecA182 D1BodySized.sizePreA182 D1BodySized.patchB182
    D1BodySized.sizeOracle181 D1BodySized.inactive182 D1BodySized.bridgeOut181 D1BodySized.sizeTable20_181
  exact h1.trans h2

end Host.Load.Run.Tpl
end

section -- SQ182
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls
kernel_rfl D1BodySized.fromInactive182 : (bridgeOf D1BodySized.s634.ffi).active = false
kernel_rfl D1BodySized.fromTable20Check182 : decide (20 ≤ D1BodySized.S634.tab.length) = true
theorem D1BodySized.fromTable20_182 : 20 ≤ D1BodySized.S634.tab.length := of_decide_eq_true D1BodySized.fromTable20Check182
kernel_rfl D1BodySized.finalBridge : bridgeOf D1BodySized.s635.ffi = bridgeOf D1BodySized.s634.ffi
kernel_rfl D1BodySized.finalTop : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s635 = true

end Host.Load.Run.Tpl
end

section -- SP182
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.piece182 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s634 D1BodySized.S634) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s635 D1BodySized.S635) 7368 :=
  D1BodyTrace.finish D1BodySized.accepted182 D1BodySized.segment182
    D1BodySized.finalTop D1BodySized.oracle182 D1BodySized.fromInactive182
    D1BodySized.finalBridge D1BodySized.fromTable20_182

end Host.Load.Run.Tpl
end

section -- SR0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group0 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s0 D1BodySized.S0) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s57 D1BodySized.S57) 160312 :=
  (((((((((((((((D1BodySized.piece0).trans D1BodySized.piece1).trans D1BodySized.piece2).trans D1BodySized.piece3).trans D1BodySized.piece4).trans D1BodySized.piece5).trans D1BodySized.piece6).trans D1BodySized.piece7).trans D1BodySized.piece8).trans D1BodySized.piece9).trans D1BodySized.piece10).trans D1BodySized.piece11).trans D1BodySized.piece12).trans D1BodySized.piece13).trans D1BodySized.piece14).trans D1BodySized.piece15

end Host.Load.Run.Tpl
end

section -- SR1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group1 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s57 D1BodySized.S57) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s113 D1BodySized.S113) 134260 :=
  (((((((((((((((D1BodySized.piece16).trans D1BodySized.piece17).trans D1BodySized.piece18).trans D1BodySized.piece19).trans D1BodySized.piece20).trans D1BodySized.piece21).trans D1BodySized.piece22).trans D1BodySized.piece23).trans D1BodySized.piece24).trans D1BodySized.piece25).trans D1BodySized.piece26).trans D1BodySized.piece27).trans D1BodySized.piece28).trans D1BodySized.piece29).trans D1BodySized.piece30).trans D1BodySized.piece31

end Host.Load.Run.Tpl
end

section -- SR2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group2 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s113 D1BodySized.S113) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s167 D1BodySized.S167) 119444 :=
  (((((((((((((((D1BodySized.piece32).trans D1BodySized.piece33).trans D1BodySized.piece34).trans D1BodySized.piece35).trans D1BodySized.piece36).trans D1BodySized.piece37).trans D1BodySized.piece38).trans D1BodySized.piece39).trans D1BodySized.piece40).trans D1BodySized.piece41).trans D1BodySized.piece42).trans D1BodySized.piece43).trans D1BodySized.piece44).trans D1BodySized.piece45).trans D1BodySized.piece46).trans D1BodySized.piece47

end Host.Load.Run.Tpl
end

section -- SR3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group3 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s167 D1BodySized.S167) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s220 D1BodySized.S220) 109193 :=
  (((((((((((((((D1BodySized.piece48).trans D1BodySized.piece49).trans D1BodySized.piece50).trans D1BodySized.piece51).trans D1BodySized.piece52).trans D1BodySized.piece53).trans D1BodySized.piece54).trans D1BodySized.piece55).trans D1BodySized.piece56).trans D1BodySized.piece57).trans D1BodySized.piece58).trans D1BodySized.piece59).trans D1BodySized.piece60).trans D1BodySized.piece61).trans D1BodySized.piece62).trans D1BodySized.piece63

end Host.Load.Run.Tpl
end

section -- SR4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group4 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s220 D1BodySized.S220) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s274 D1BodySized.S274) 120531 :=
  (((((((((((((((D1BodySized.piece64).trans D1BodySized.piece65).trans D1BodySized.piece66).trans D1BodySized.piece67).trans D1BodySized.piece68).trans D1BodySized.piece69).trans D1BodySized.piece70).trans D1BodySized.piece71).trans D1BodySized.piece72).trans D1BodySized.piece73).trans D1BodySized.piece74).trans D1BodySized.piece75).trans D1BodySized.piece76).trans D1BodySized.piece77).trans D1BodySized.piece78).trans D1BodySized.piece79

end Host.Load.Run.Tpl
end

section -- SR5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group5 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s274 D1BodySized.S274) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s330 D1BodySized.S330) 134306 :=
  (((((((((((((((D1BodySized.piece80).trans D1BodySized.piece81).trans D1BodySized.piece82).trans D1BodySized.piece83).trans D1BodySized.piece84).trans D1BodySized.piece85).trans D1BodySized.piece86).trans D1BodySized.piece87).trans D1BodySized.piece88).trans D1BodySized.piece89).trans D1BodySized.piece90).trans D1BodySized.piece91).trans D1BodySized.piece92).trans D1BodySized.piece93).trans D1BodySized.piece94).trans D1BodySized.piece95

end Host.Load.Run.Tpl
end

section -- SR6
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group6 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s330 D1BodySized.S330) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s384 D1BodySized.S384) 119444 :=
  (((((((((((((((D1BodySized.piece96).trans D1BodySized.piece97).trans D1BodySized.piece98).trans D1BodySized.piece99).trans D1BodySized.piece100).trans D1BodySized.piece101).trans D1BodySized.piece102).trans D1BodySized.piece103).trans D1BodySized.piece104).trans D1BodySized.piece105).trans D1BodySized.piece106).trans D1BodySized.piece107).trans D1BodySized.piece108).trans D1BodySized.piece109).trans D1BodySized.piece110).trans D1BodySized.piece111

end Host.Load.Run.Tpl
end

section -- SR7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group7 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s384 D1BodySized.S384) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s437 D1BodySized.S437) 109060 :=
  (((((((((((((((D1BodySized.piece112).trans D1BodySized.piece113).trans D1BodySized.piece114).trans D1BodySized.piece115).trans D1BodySized.piece116).trans D1BodySized.piece117).trans D1BodySized.piece118).trans D1BodySized.piece119).trans D1BodySized.piece120).trans D1BodySized.piece121).trans D1BodySized.piece122).trans D1BodySized.piece123).trans D1BodySized.piece124).trans D1BodySized.piece125).trans D1BodySized.piece126).trans D1BodySized.piece127

end Host.Load.Run.Tpl
end

section -- SR8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group8 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s437 D1BodySized.S437) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s491 D1BodySized.S491) 119740 :=
  (((((((((((((((D1BodySized.piece128).trans D1BodySized.piece129).trans D1BodySized.piece130).trans D1BodySized.piece131).trans D1BodySized.piece132).trans D1BodySized.piece133).trans D1BodySized.piece134).trans D1BodySized.piece135).trans D1BodySized.piece136).trans D1BodySized.piece137).trans D1BodySized.piece138).trans D1BodySized.piece139).trans D1BodySized.piece140).trans D1BodySized.piece141).trans D1BodySized.piece142).trans D1BodySized.piece143

end Host.Load.Run.Tpl
end

section -- SR9
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group9 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s491 D1BodySized.S491) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s545 D1BodySized.S545) 114093 :=
  (((((((((((((((D1BodySized.piece144).trans D1BodySized.piece145).trans D1BodySized.piece146).trans D1BodySized.piece147).trans D1BodySized.piece148).trans D1BodySized.piece149).trans D1BodySized.piece150).trans D1BodySized.piece151).trans D1BodySized.piece152).trans D1BodySized.piece153).trans D1BodySized.piece154).trans D1BodySized.piece155).trans D1BodySized.piece156).trans D1BodySized.piece157).trans D1BodySized.piece158).trans D1BodySized.piece159

end Host.Load.Run.Tpl
end

section -- SR10
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group10 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s545 D1BodySized.S545) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s608 D1BodySized.S608) 204141 :=
  (((((((((((((((D1BodySized.piece160).trans D1BodySized.piece161).trans D1BodySized.piece162).trans D1BodySized.piece163).trans D1BodySized.piece164).trans D1BodySized.piece165).trans D1BodySized.piece166).trans D1BodySized.piece167).trans D1BodySized.piece168).trans D1BodySized.piece169).trans D1BodySized.piece170).trans D1BodySized.piece171).trans D1BodySized.piece172).trans D1BodySized.piece173).trans D1BodySized.piece174).trans D1BodySized.piece175

end Host.Load.Run.Tpl
end

section -- SR11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.group11 {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s608 D1BodySized.S608) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s635 D1BodySized.S635) 96660 :=
  ((((((D1BodySized.piece176).trans D1BodySized.piece177).trans D1BodySized.piece178).trans D1BodySized.piece179).trans D1BodySized.piece180).trans D1BodySized.piece181).trans D1BodySized.piece182

end Host.Load.Run.Tpl
end
