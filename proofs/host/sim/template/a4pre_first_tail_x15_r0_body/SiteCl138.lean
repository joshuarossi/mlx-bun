import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK138
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd138 : (PRE_first_tail_x15_r0_body.clo138 ++ PRE_first_tail_x15_r0_body.cln138 ++ PRE_first_tail_x15_r0_body.cli138).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle138 : Conv.Cnt.leB (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck138 : Conv.ncleanListB (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx PRE_first_tail_x15_r0_body.clo138 PRE_first_tail_x15_r0_body.cln138 PRE_first_tail_x15_r0_body.cli138 = true
theorem PRE_first_tail_x15_r0_body.cncl138 (h : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) : Conv.NClean (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle138 PRE_first_tail_x15_r0_body.ckA138 PRE_first_tail_x15_r0_body.cobjsK138 PRE_first_tail_x15_r0_body.cnodesK138 PRE_first_tail_x15_r0_body.citemsK138 PRE_first_tail_x15_r0_body.cbd138 PRE_first_tail_x15_r0_body.cck138

end Host.Load.Run.Tpl
