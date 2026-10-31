import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK13
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA13 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s139.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd13 : (PRE_first_tail_x15_r0_body.clo13 ++ PRE_first_tail_x15_r0_body.cln13 ++ PRE_first_tail_x15_r0_body.cli13).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle13 : Conv.Cnt.leB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck13 : Conv.ncleanListB (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx PRE_first_tail_x15_r0_body.clo13 PRE_first_tail_x15_r0_body.cln13 PRE_first_tail_x15_r0_body.cli13 = true
theorem PRE_first_tail_x15_r0_body.cncl13 (h : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s139.ffi).mlx) : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle13 PRE_first_tail_x15_r0_body.ckA13 PRE_first_tail_x15_r0_body.cobjsK13 PRE_first_tail_x15_r0_body.cnodesK13 PRE_first_tail_x15_r0_body.citemsK13 PRE_first_tail_x15_r0_body.cbd13 PRE_first_tail_x15_r0_body.cck13

end Host.Load.Run.Tpl
