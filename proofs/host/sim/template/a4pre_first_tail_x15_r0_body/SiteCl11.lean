import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK11
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA11 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd11 : (PRE_first_tail_x15_r0_body.clo11 ++ PRE_first_tail_x15_r0_body.cln11 ++ PRE_first_tail_x15_r0_body.cli11).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle11 : Conv.Cnt.leB (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck11 : Conv.ncleanListB (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx PRE_first_tail_x15_r0_body.clo11 PRE_first_tail_x15_r0_body.cln11 PRE_first_tail_x15_r0_body.cli11 = true
theorem PRE_first_tail_x15_r0_body.cncl11 (h : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx) : Conv.NClean (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle11 PRE_first_tail_x15_r0_body.ckA11 PRE_first_tail_x15_r0_body.cobjsK11 PRE_first_tail_x15_r0_body.cnodesK11 PRE_first_tail_x15_r0_body.citemsK11 PRE_first_tail_x15_r0_body.cbd11 PRE_first_tail_x15_r0_body.cck11

end Host.Load.Run.Tpl
