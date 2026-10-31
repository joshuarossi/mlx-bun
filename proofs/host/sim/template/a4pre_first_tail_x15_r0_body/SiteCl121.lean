import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK121
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA121 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo121.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd121 : (PRE_first_tail_x15_r0_body.clo121 ++ PRE_first_tail_x15_r0_body.cln121 ++ PRE_first_tail_x15_r0_body.cli121).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle121 : Conv.Cnt.leB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck121 : Conv.ncleanListB (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx PRE_first_tail_x15_r0_body.clo121 PRE_first_tail_x15_r0_body.cln121 PRE_first_tail_x15_r0_body.cli121 = true
theorem PRE_first_tail_x15_r0_body.cncl121 (h : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx) : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle121 PRE_first_tail_x15_r0_body.ckA121 PRE_first_tail_x15_r0_body.cobjsK121 PRE_first_tail_x15_r0_body.cnodesK121 PRE_first_tail_x15_r0_body.citemsK121 PRE_first_tail_x15_r0_body.cbd121 PRE_first_tail_x15_r0_body.cck121

end Host.Load.Run.Tpl
