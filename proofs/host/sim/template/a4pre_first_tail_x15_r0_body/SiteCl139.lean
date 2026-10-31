import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK139
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd139 : (PRE_first_tail_x15_r0_body.clo139 ++ PRE_first_tail_x15_r0_body.cln139 ++ PRE_first_tail_x15_r0_body.cli139).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle139 : Conv.Cnt.leB (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck139 : Conv.ncleanListB (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx PRE_first_tail_x15_r0_body.clo139 PRE_first_tail_x15_r0_body.cln139 PRE_first_tail_x15_r0_body.cli139 = true
theorem PRE_first_tail_x15_r0_body.cncl139 (h : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle139 PRE_first_tail_x15_r0_body.ckA139 PRE_first_tail_x15_r0_body.cobjsK139 PRE_first_tail_x15_r0_body.cnodesK139 PRE_first_tail_x15_r0_body.citemsK139 PRE_first_tail_x15_r0_body.cbd139 PRE_first_tail_x15_r0_body.cck139

end Host.Load.Run.Tpl
