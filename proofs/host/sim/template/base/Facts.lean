import host.sim.template.base.S
import host.sim.Upd
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The template's counters and its token reference, as numerals; its table does not mention
the look-ahead variable `var 17`. -/

kernel_rfl Base.next_val : Base.s0.next = 3123579
kernel_rfl Base.mnext_val : Base.s0.ffi.mlx.next = 29302
kernel_rfl Base.mnnext_val : Base.s0.ffi.mlx.nnext = 22539
kernel_rfl Base.tokens_val : Base.s0.ffi.mlx.tokens = [.ref 79]
kernel_rfl Base.noVar17_check : Base.S0.tab.all (SymE.noVar 17) = true

theorem Base.noVar17 : ∀ e ∈ Base.S0.tab, e.noVar 17 = true := List.all_eq_true.mp Base.noVar17_check

end Host.Load.Run.Tpl
