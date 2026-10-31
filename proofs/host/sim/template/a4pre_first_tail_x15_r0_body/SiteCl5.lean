import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK5
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA5 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd5 : (PRE_first_tail_x15_r0_body.clo5 ++ PRE_first_tail_x15_r0_body.cln5 ++ PRE_first_tail_x15_r0_body.cli5).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle5 : Conv.Cnt.leB (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck5 : Conv.ncleanListB (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx PRE_first_tail_x15_r0_body.clo5 PRE_first_tail_x15_r0_body.cln5 PRE_first_tail_x15_r0_body.cli5 = true
theorem PRE_first_tail_x15_r0_body.cncl5 (h : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx) : Conv.NClean (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle5 PRE_first_tail_x15_r0_body.ckA5 PRE_first_tail_x15_r0_body.cobjsK5 PRE_first_tail_x15_r0_body.cnodesK5 PRE_first_tail_x15_r0_body.citemsK5 PRE_first_tail_x15_r0_body.cbd5 PRE_first_tail_x15_r0_body.cck5

end Host.Load.Run.Tpl
