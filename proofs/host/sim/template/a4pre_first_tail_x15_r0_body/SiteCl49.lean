import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK49
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s441.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd49 : (PRE_first_tail_x15_r0_body.clo49 ++ PRE_first_tail_x15_r0_body.cln49 ++ PRE_first_tail_x15_r0_body.cli49).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle49 : Conv.Cnt.leB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck49 : Conv.ncleanListB (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx PRE_first_tail_x15_r0_body.clo49 PRE_first_tail_x15_r0_body.cln49 PRE_first_tail_x15_r0_body.cli49 = true
theorem PRE_first_tail_x15_r0_body.cncl49 (h : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s441.ffi).mlx) : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle49 PRE_first_tail_x15_r0_body.ckA49 PRE_first_tail_x15_r0_body.cobjsK49 PRE_first_tail_x15_r0_body.cnodesK49 PRE_first_tail_x15_r0_body.citemsK49 PRE_first_tail_x15_r0_body.cbd49 PRE_first_tail_x15_r0_body.cck49

end Host.Load.Run.Tpl
