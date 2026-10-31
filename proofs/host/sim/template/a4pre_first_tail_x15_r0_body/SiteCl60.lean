import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK60
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s539.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd60 : (PRE_first_tail_x15_r0_body.clo60 ++ PRE_first_tail_x15_r0_body.cln60 ++ PRE_first_tail_x15_r0_body.cli60).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle60 : Conv.Cnt.leB (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck60 : Conv.ncleanListB (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx PRE_first_tail_x15_r0_body.clo60 PRE_first_tail_x15_r0_body.cln60 PRE_first_tail_x15_r0_body.cli60 = true
theorem PRE_first_tail_x15_r0_body.cncl60 (h : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s539.ffi).mlx) : Conv.NClean (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle60 PRE_first_tail_x15_r0_body.ckA60 PRE_first_tail_x15_r0_body.cobjsK60 PRE_first_tail_x15_r0_body.cnodesK60 PRE_first_tail_x15_r0_body.citemsK60 PRE_first_tail_x15_r0_body.cbd60 PRE_first_tail_x15_r0_body.cck60

end Host.Load.Run.Tpl
