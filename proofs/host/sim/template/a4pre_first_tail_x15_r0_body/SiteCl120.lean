import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK120
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA120 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1066.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1064.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1066.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd120 : (PRE_first_tail_x15_r0_body.clo120 ++ PRE_first_tail_x15_r0_body.cln120 ++ PRE_first_tail_x15_r0_body.cli120).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle120 : Conv.Cnt.leB (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck120 : Conv.ncleanListB (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1066.ffi).mlx PRE_first_tail_x15_r0_body.clo120 PRE_first_tail_x15_r0_body.cln120 PRE_first_tail_x15_r0_body.cli120 = true
theorem PRE_first_tail_x15_r0_body.cncl120 (h : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1064.ffi).mlx) : Conv.NClean (⟨20579, 17675, 2769629, 5231⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1066.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle120 PRE_first_tail_x15_r0_body.ckA120 PRE_first_tail_x15_r0_body.cobjsK120 PRE_first_tail_x15_r0_body.cnodesK120 PRE_first_tail_x15_r0_body.citemsK120 PRE_first_tail_x15_r0_body.cbd120 PRE_first_tail_x15_r0_body.cck120

end Host.Load.Run.Tpl
