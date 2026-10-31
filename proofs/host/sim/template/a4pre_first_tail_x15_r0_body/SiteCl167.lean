import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK167
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA167 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd167 : (PRE_first_tail_x15_r0_body.clo167 ++ PRE_first_tail_x15_r0_body.cln167 ++ PRE_first_tail_x15_r0_body.cli167).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle167 : Conv.Cnt.leB (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck167 : Conv.ncleanListB (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx PRE_first_tail_x15_r0_body.clo167 PRE_first_tail_x15_r0_body.cln167 PRE_first_tail_x15_r0_body.cli167 = true
theorem PRE_first_tail_x15_r0_body.cncl167 (h : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx) : Conv.NClean (⟨21485, 18577, 2805802, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle167 PRE_first_tail_x15_r0_body.ckA167 PRE_first_tail_x15_r0_body.cobjsK167 PRE_first_tail_x15_r0_body.cnodesK167 PRE_first_tail_x15_r0_body.citemsK167 PRE_first_tail_x15_r0_body.cbd167 PRE_first_tail_x15_r0_body.cck167

end Host.Load.Run.Tpl
