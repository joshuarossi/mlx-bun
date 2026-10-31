import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK85
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA85 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s756.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd85 : (PRE_first_tail_x15_r0_body.clo85 ++ PRE_first_tail_x15_r0_body.cln85 ++ PRE_first_tail_x15_r0_body.cli85).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle85 : Conv.Cnt.leB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck85 : Conv.ncleanListB (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx PRE_first_tail_x15_r0_body.clo85 PRE_first_tail_x15_r0_body.cln85 PRE_first_tail_x15_r0_body.cli85 = true
theorem PRE_first_tail_x15_r0_body.cncl85 (h : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s756.ffi).mlx) : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s758.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle85 PRE_first_tail_x15_r0_body.ckA85 PRE_first_tail_x15_r0_body.cobjsK85 PRE_first_tail_x15_r0_body.cnodesK85 PRE_first_tail_x15_r0_body.citemsK85 PRE_first_tail_x15_r0_body.cbd85 PRE_first_tail_x15_r0_body.cck85

end Host.Load.Run.Tpl
