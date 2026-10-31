import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK179
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA179 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd179 : (PRE_first_tail_x15_r0_body.clo179 ++ PRE_first_tail_x15_r0_body.cln179 ++ PRE_first_tail_x15_r0_body.cli179).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle179 : Conv.Cnt.leB (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck179 : Conv.ncleanListB (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx PRE_first_tail_x15_r0_body.clo179 PRE_first_tail_x15_r0_body.cln179 PRE_first_tail_x15_r0_body.cli179 = true
theorem PRE_first_tail_x15_r0_body.cncl179 (h : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx) : Conv.NClean (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle179 PRE_first_tail_x15_r0_body.ckA179 PRE_first_tail_x15_r0_body.cobjsK179 PRE_first_tail_x15_r0_body.cnodesK179 PRE_first_tail_x15_r0_body.citemsK179 PRE_first_tail_x15_r0_body.cbd179 PRE_first_tail_x15_r0_body.cck179

end Host.Load.Run.Tpl
