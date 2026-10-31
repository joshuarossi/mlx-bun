import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK163
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA163 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd163 : (PRE_first_tail_x15_r0_body.clo163 ++ PRE_first_tail_x15_r0_body.cln163 ++ PRE_first_tail_x15_r0_body.cli163).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle163 : Conv.Cnt.leB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck163 : Conv.ncleanListB (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx PRE_first_tail_x15_r0_body.clo163 PRE_first_tail_x15_r0_body.cln163 PRE_first_tail_x15_r0_body.cli163 = true
theorem PRE_first_tail_x15_r0_body.cncl163 (h : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx) : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle163 PRE_first_tail_x15_r0_body.ckA163 PRE_first_tail_x15_r0_body.cobjsK163 PRE_first_tail_x15_r0_body.cnodesK163 PRE_first_tail_x15_r0_body.citemsK163 PRE_first_tail_x15_r0_body.cbd163 PRE_first_tail_x15_r0_body.cck163

end Host.Load.Run.Tpl
