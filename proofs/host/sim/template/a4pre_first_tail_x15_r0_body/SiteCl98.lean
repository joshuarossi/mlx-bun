import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK98
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA98 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s867.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo98.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s867.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd98 : (PRE_first_tail_x15_r0_body.clo98 ++ PRE_first_tail_x15_r0_body.cln98 ++ PRE_first_tail_x15_r0_body.cli98).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle98 : Conv.Cnt.leB (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck98 : Conv.ncleanListB (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s867.ffi).mlx PRE_first_tail_x15_r0_body.clo98 PRE_first_tail_x15_r0_body.cln98 PRE_first_tail_x15_r0_body.cli98 = true
theorem PRE_first_tail_x15_r0_body.cncl98 (h : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s865.ffi).mlx) : Conv.NClean (⟨20127, 17218, 2751576, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s867.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle98 PRE_first_tail_x15_r0_body.ckA98 PRE_first_tail_x15_r0_body.cobjsK98 PRE_first_tail_x15_r0_body.cnodesK98 PRE_first_tail_x15_r0_body.citemsK98 PRE_first_tail_x15_r0_body.cbd98 PRE_first_tail_x15_r0_body.cck98

end Host.Load.Run.Tpl
