import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK54
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd54 : (PRE_first_tail_x15_r0_body.clo54 ++ PRE_first_tail_x15_r0_body.cln54 ++ PRE_first_tail_x15_r0_body.cli54).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle54 : Conv.Cnt.leB (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck54 : Conv.ncleanListB (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx PRE_first_tail_x15_r0_body.clo54 PRE_first_tail_x15_r0_body.cln54 PRE_first_tail_x15_r0_body.cli54 = true
theorem PRE_first_tail_x15_r0_body.cncl54 (h : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx) : Conv.NClean (⟨19277, 16379, 2717649, 2411⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle54 PRE_first_tail_x15_r0_body.ckA54 PRE_first_tail_x15_r0_body.cobjsK54 PRE_first_tail_x15_r0_body.cnodesK54 PRE_first_tail_x15_r0_body.citemsK54 PRE_first_tail_x15_r0_body.cbd54 PRE_first_tail_x15_r0_body.cck54

end Host.Load.Run.Tpl
