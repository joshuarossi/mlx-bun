import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK171
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA171 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd171 : (PRE_first_tail_x15_r0_body.clo171 ++ PRE_first_tail_x15_r0_body.cln171 ++ PRE_first_tail_x15_r0_body.cli171).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle171 : Conv.Cnt.leB (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck171 : Conv.ncleanListB (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx PRE_first_tail_x15_r0_body.clo171 PRE_first_tail_x15_r0_body.cln171 PRE_first_tail_x15_r0_body.cli171 = true
theorem PRE_first_tail_x15_r0_body.cncl171 (h : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx) : Conv.NClean (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle171 PRE_first_tail_x15_r0_body.ckA171 PRE_first_tail_x15_r0_body.cobjsK171 PRE_first_tail_x15_r0_body.cnodesK171 PRE_first_tail_x15_r0_body.citemsK171 PRE_first_tail_x15_r0_body.cbd171 PRE_first_tail_x15_r0_body.cck171

end Host.Load.Run.Tpl
