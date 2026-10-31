import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK86
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA86 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s835.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s833.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s835.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd86 : (PRE_first_tail_x15_r0_body.clo86 ++ PRE_first_tail_x15_r0_body.cln86 ++ PRE_first_tail_x15_r0_body.cli86).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle86 : Conv.Cnt.leB (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck86 : Conv.ncleanListB (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s835.ffi).mlx PRE_first_tail_x15_r0_body.clo86 PRE_first_tail_x15_r0_body.cln86 PRE_first_tail_x15_r0_body.cli86 = true
theorem PRE_first_tail_x15_r0_body.cncl86 (h : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s833.ffi).mlx) : Conv.NClean (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s835.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle86 PRE_first_tail_x15_r0_body.ckA86 PRE_first_tail_x15_r0_body.cobjsK86 PRE_first_tail_x15_r0_body.cnodesK86 PRE_first_tail_x15_r0_body.citemsK86 PRE_first_tail_x15_r0_body.cbd86 PRE_first_tail_x15_r0_body.cck86

end Host.Load.Run.Tpl
