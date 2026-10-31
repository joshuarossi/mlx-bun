import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK160
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA160 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd160 : (PRE_first_tail_x15_r0_body.clo160 ++ PRE_first_tail_x15_r0_body.cln160 ++ PRE_first_tail_x15_r0_body.cli160).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle160 : Conv.Cnt.leB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck160 : Conv.ncleanListB (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx PRE_first_tail_x15_r0_body.clo160 PRE_first_tail_x15_r0_body.cln160 PRE_first_tail_x15_r0_body.cli160 = true
theorem PRE_first_tail_x15_r0_body.cncl160 (h : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx) : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle160 PRE_first_tail_x15_r0_body.ckA160 PRE_first_tail_x15_r0_body.cobjsK160 PRE_first_tail_x15_r0_body.cnodesK160 PRE_first_tail_x15_r0_body.citemsK160 PRE_first_tail_x15_r0_body.cbd160 PRE_first_tail_x15_r0_body.cck160

end Host.Load.Run.Tpl
