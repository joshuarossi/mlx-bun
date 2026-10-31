import host.sim.template.a4dec.S
import host.sim.Upd
import host.sim.template.NShiftOf
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The template's counters and its token reference; its table does not mention the look-ahead variable `var 17`. -/

kernel_rfl DT.next_val : DT.s0.next = 3123568
kernel_rfl DT.mnext_val : (Host.Load.Layers.toLoad DT.s0.ffi).mlx.next = 29302
kernel_rfl DT.mnnext_val : (Host.Load.Layers.toLoad DT.s0.ffi).mlx.nnext = 22539
kernel_rfl DT.tokens_val : (Host.Load.Layers.toLoad DT.s0.ffi).mlx.tokens = [.ref 79, .ref 3, .ref 4, .ref 5, .ref 6, .ref 7, .ref 8]
-- the hand-off to the banded decode relation: every recorded trace node below its NL (20000)
kernel_rfl DT.handoff_check : (PTrie.keysA (Host.Load.Layers.toLoad DT.s0.ffi).mlx.objs).all (fun h => match (Host.Load.Layers.toLoad DT.s0.ffi).mlx.objs.get h with
  | some o => (objTraces o).all (fun i => Nat.blt i 20000) | none => true) = true
theorem DT.handoff : ∀ h o, (Host.Load.Layers.toLoad DT.s0.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < 20000 := by
  intro h o ho i hi
  have := List.all_eq_true.mp DT.handoff_check h (PTrie.mem_keysA _ _ _ ho)
  rw [ho] at this
  exact Nat.blt_eq.mp (List.all_eq_true.mp this i hi)
kernel_rfl DT.noVar17_check : DT.S0.tab.all (SymE.noVar 17) = true
theorem DT.noVar17 : ∀ e ∈ DT.S0.tab, e.noVar 17 = true := List.all_eq_true.mp DT.noVar17_check

end Host.Load.Run.Tpl
