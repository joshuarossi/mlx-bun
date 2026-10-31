import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK16
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA16 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd16 : (PRE_first_tail_x15_r0_body.clo16 ++ PRE_first_tail_x15_r0_body.cln16 ++ PRE_first_tail_x15_r0_body.cli16).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle16 : Conv.Cnt.leB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck16 : Conv.ncleanListB (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx PRE_first_tail_x15_r0_body.clo16 PRE_first_tail_x15_r0_body.cln16 PRE_first_tail_x15_r0_body.cli16 = true
theorem PRE_first_tail_x15_r0_body.cncl16 (h : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx) : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle16 PRE_first_tail_x15_r0_body.ckA16 PRE_first_tail_x15_r0_body.cobjsK16 PRE_first_tail_x15_r0_body.cnodesK16 PRE_first_tail_x15_r0_body.citemsK16 PRE_first_tail_x15_r0_body.cbd16 PRE_first_tail_x15_r0_body.cck16

end Host.Load.Run.Tpl
