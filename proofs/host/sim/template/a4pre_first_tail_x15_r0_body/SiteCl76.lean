import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK76
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd76 : (PRE_first_tail_x15_r0_body.clo76 ++ PRE_first_tail_x15_r0_body.cln76 ++ PRE_first_tail_x15_r0_body.cli76).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle76 : Conv.Cnt.leB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck76 : Conv.ncleanListB (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx PRE_first_tail_x15_r0_body.clo76 PRE_first_tail_x15_r0_body.cln76 PRE_first_tail_x15_r0_body.cli76 = true
theorem PRE_first_tail_x15_r0_body.cncl76 (h : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx) : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle76 PRE_first_tail_x15_r0_body.ckA76 PRE_first_tail_x15_r0_body.cobjsK76 PRE_first_tail_x15_r0_body.cnodesK76 PRE_first_tail_x15_r0_body.citemsK76 PRE_first_tail_x15_r0_body.cbd76 PRE_first_tail_x15_r0_body.cck76

end Host.Load.Run.Tpl
