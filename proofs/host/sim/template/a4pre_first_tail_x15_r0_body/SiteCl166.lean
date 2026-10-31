import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK166
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA166 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1605.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd166 : (PRE_first_tail_x15_r0_body.clo166 ++ PRE_first_tail_x15_r0_body.cln166 ++ PRE_first_tail_x15_r0_body.cli166).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle166 : Conv.Cnt.leB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck166 : Conv.ncleanListB (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx PRE_first_tail_x15_r0_body.clo166 PRE_first_tail_x15_r0_body.cln166 PRE_first_tail_x15_r0_body.cli166 = true
theorem PRE_first_tail_x15_r0_body.cncl166 (h : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1605.ffi).mlx) : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle166 PRE_first_tail_x15_r0_body.ckA166 PRE_first_tail_x15_r0_body.cobjsK166 PRE_first_tail_x15_r0_body.cnodesK166 PRE_first_tail_x15_r0_body.citemsK166 PRE_first_tail_x15_r0_body.cbd166 PRE_first_tail_x15_r0_body.cck166

end Host.Load.Run.Tpl
