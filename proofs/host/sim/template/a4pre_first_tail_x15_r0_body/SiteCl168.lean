import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK168
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA168 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd168 : (PRE_first_tail_x15_r0_body.clo168 ++ PRE_first_tail_x15_r0_body.cln168 ++ PRE_first_tail_x15_r0_body.cli168).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle168 : Conv.Cnt.leB (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck168 : Conv.ncleanListB (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx PRE_first_tail_x15_r0_body.clo168 PRE_first_tail_x15_r0_body.cln168 PRE_first_tail_x15_r0_body.cli168 = true
theorem PRE_first_tail_x15_r0_body.cncl168 (h : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx) : Conv.NClean (⟨21523, 18623, 2807305, 7283⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle168 PRE_first_tail_x15_r0_body.ckA168 PRE_first_tail_x15_r0_body.cobjsK168 PRE_first_tail_x15_r0_body.cnodesK168 PRE_first_tail_x15_r0_body.citemsK168 PRE_first_tail_x15_r0_body.cbd168 PRE_first_tail_x15_r0_body.cck168

end Host.Load.Run.Tpl
