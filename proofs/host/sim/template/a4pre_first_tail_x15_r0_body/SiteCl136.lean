import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK136
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd136 : (PRE_first_tail_x15_r0_body.clo136 ++ PRE_first_tail_x15_r0_body.cln136 ++ PRE_first_tail_x15_r0_body.cli136).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle136 : Conv.Cnt.leB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck136 : Conv.ncleanListB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx PRE_first_tail_x15_r0_body.clo136 PRE_first_tail_x15_r0_body.cln136 PRE_first_tail_x15_r0_body.cli136 = true
theorem PRE_first_tail_x15_r0_body.cncl136 (h : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle136 PRE_first_tail_x15_r0_body.ckA136 PRE_first_tail_x15_r0_body.cobjsK136 PRE_first_tail_x15_r0_body.cnodesK136 PRE_first_tail_x15_r0_body.citemsK136 PRE_first_tail_x15_r0_body.cbd136 PRE_first_tail_x15_r0_body.cck136

end Host.Load.Run.Tpl
