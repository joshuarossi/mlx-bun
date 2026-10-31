import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK29
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA29 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo29.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd29 : (PRE_first_tail_x15_r0_body.clo29 ++ PRE_first_tail_x15_r0_body.cln29 ++ PRE_first_tail_x15_r0_body.cli29).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle29 : Conv.Cnt.leB (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck29 : Conv.ncleanListB (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx PRE_first_tail_x15_r0_body.clo29 PRE_first_tail_x15_r0_body.cln29 PRE_first_tail_x15_r0_body.cli29 = true
theorem PRE_first_tail_x15_r0_body.cncl29 (h : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx) : Conv.NClean (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle29 PRE_first_tail_x15_r0_body.ckA29 PRE_first_tail_x15_r0_body.cobjsK29 PRE_first_tail_x15_r0_body.cnodesK29 PRE_first_tail_x15_r0_body.citemsK29 PRE_first_tail_x15_r0_body.cbd29 PRE_first_tail_x15_r0_body.cck29

end Host.Load.Run.Tpl
