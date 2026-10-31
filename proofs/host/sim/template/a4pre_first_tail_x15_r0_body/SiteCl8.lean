import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK8
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA8 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s88.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s86.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo8.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s88.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd8 : (PRE_first_tail_x15_r0_body.clo8 ++ PRE_first_tail_x15_r0_body.cln8 ++ PRE_first_tail_x15_r0_body.cli8).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle8 : Conv.Cnt.leB (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck8 : Conv.ncleanListB (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s88.ffi).mlx PRE_first_tail_x15_r0_body.clo8 PRE_first_tail_x15_r0_body.cln8 PRE_first_tail_x15_r0_body.cli8 = true
theorem PRE_first_tail_x15_r0_body.cncl8 (h : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s86.ffi).mlx) : Conv.NClean (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s88.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle8 PRE_first_tail_x15_r0_body.ckA8 PRE_first_tail_x15_r0_body.cobjsK8 PRE_first_tail_x15_r0_body.cnodesK8 PRE_first_tail_x15_r0_body.citemsK8 PRE_first_tail_x15_r0_body.cbd8 PRE_first_tail_x15_r0_body.cck8

end Host.Load.Run.Tpl
