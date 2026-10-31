import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK159
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA159 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd159 : (PRE_first_tail_x15_r0_body.clo159 ++ PRE_first_tail_x15_r0_body.cln159 ++ PRE_first_tail_x15_r0_body.cli159).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle159 : Conv.Cnt.leB (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck159 : Conv.ncleanListB (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx PRE_first_tail_x15_r0_body.clo159 PRE_first_tail_x15_r0_body.cln159 PRE_first_tail_x15_r0_body.cli159 = true
theorem PRE_first_tail_x15_r0_body.cncl159 (h : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx) : Conv.NClean (⟨21344, 18449, 2800141, 6899⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle159 PRE_first_tail_x15_r0_body.ckA159 PRE_first_tail_x15_r0_body.cobjsK159 PRE_first_tail_x15_r0_body.cnodesK159 PRE_first_tail_x15_r0_body.citemsK159 PRE_first_tail_x15_r0_body.cbd159 PRE_first_tail_x15_r0_body.cck159

end Host.Load.Run.Tpl
