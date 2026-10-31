import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK88
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA88 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo88.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd88 : (PRE_first_tail_x15_r0_body.clo88 ++ PRE_first_tail_x15_r0_body.cln88 ++ PRE_first_tail_x15_r0_body.cli88).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle88 : Conv.Cnt.leB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck88 : Conv.ncleanListB (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx PRE_first_tail_x15_r0_body.clo88 PRE_first_tail_x15_r0_body.cln88 PRE_first_tail_x15_r0_body.cli88 = true
theorem PRE_first_tail_x15_r0_body.cncl88 (h : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx) : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle88 PRE_first_tail_x15_r0_body.ckA88 PRE_first_tail_x15_r0_body.cobjsK88 PRE_first_tail_x15_r0_body.cnodesK88 PRE_first_tail_x15_r0_body.citemsK88 PRE_first_tail_x15_r0_body.cbd88 PRE_first_tail_x15_r0_body.cck88

end Host.Load.Run.Tpl
