import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK137
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd137 : (PRE_first_tail_x15_r0_body.clo137 ++ PRE_first_tail_x15_r0_body.cln137 ++ PRE_first_tail_x15_r0_body.cli137).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle137 : Conv.Cnt.leB (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck137 : Conv.ncleanListB (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx PRE_first_tail_x15_r0_body.clo137 PRE_first_tail_x15_r0_body.cln137 PRE_first_tail_x15_r0_body.cli137 = true
theorem PRE_first_tail_x15_r0_body.cncl137 (h : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx) : Conv.NClean (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle137 PRE_first_tail_x15_r0_body.ckA137 PRE_first_tail_x15_r0_body.cobjsK137 PRE_first_tail_x15_r0_body.cnodesK137 PRE_first_tail_x15_r0_body.citemsK137 PRE_first_tail_x15_r0_body.cbd137 PRE_first_tail_x15_r0_body.cck137

end Host.Load.Run.Tpl
