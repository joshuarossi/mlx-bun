import host.ts.renameOrdinary.ConcatReturnPrefix
import host.ts.RenameParametricTests
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.StatusComparison362
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s62
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s63
noncomputable def sourceTail : List Frame := input.stack.tail
theorem source_control : input.ctl = .ret (.num zeroN) := by host_kernel_rfl
theorem source_frame : input.stack = .e (.binR .sne (.num zeroN))::sourceTail := by host_kernel_rfl
theorem source_post : {input with stack := sourceTail}.ret (.bool false) = output := by host_kernel_rfl

/-- The actual error test uses the literal zero returned by the native call
and the zero in the original source syntax. The false result is proved in
both numeric semantics; it is not a supplied branch outcome. -/
theorem transport (ν₀ ν : Nat → F64) (C₀ C : CSrv) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (fs : List Frame) (hc : s.ctl = .ret (.num zeroN))
    (hf : s.stack = .e (.binR .sne (.num zeroN))::fs) :
    interpC (step P.F s).run C = some ({s with stack := fs}.ret (.bool false),C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' output
        ({s with stack := fs}.ret (.bool false)) := by
  have zeroRole : NumRole ν₀ ν C₀ C (.lit (F64.zero false)) zeroN zeroN := ⟨rfl,rfl⟩
  obtain ⟨_,hr,hs⟩ := step_comparison_roles P.F FR R ν₀ ν C₀ C live framed before after old old' input s h
    .sne zeroN zeroN zeroN zeroN (.lit (F64.zero false)) (.lit (F64.zero false)) sourceTail fs
    zeroRole zeroRole source_control hc source_frame hf true (by change F64.test .eq (F64.zero false) (F64.zero false) = true; decide +kernel) (by change F64.test .eq (F64.zero false) (F64.zero false) = true; decide +kernel)
  exact ⟨hr,source_post ▸ hs⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.StatusComparison362
