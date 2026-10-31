import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK57
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd57 : (PRE_first_tail_x15_r0_body.clo57 ++ PRE_first_tail_x15_r0_body.cln57 ++ PRE_first_tail_x15_r0_body.cli57).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle57 : Conv.Cnt.leB (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck57 : Conv.ncleanListB (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx PRE_first_tail_x15_r0_body.clo57 PRE_first_tail_x15_r0_body.cln57 PRE_first_tail_x15_r0_body.cli57 = true
theorem PRE_first_tail_x15_r0_body.cncl57 (h : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx) : Conv.NClean (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle57 PRE_first_tail_x15_r0_body.ckA57 PRE_first_tail_x15_r0_body.cobjsK57 PRE_first_tail_x15_r0_body.cnodesK57 PRE_first_tail_x15_r0_body.citemsK57 PRE_first_tail_x15_r0_body.cbd57 PRE_first_tail_x15_r0_body.cck57

end Host.Load.Run.Tpl
