import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK107
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd107 : (PRE_first_tail_x15_r0_body.clo107 ++ PRE_first_tail_x15_r0_body.cln107 ++ PRE_first_tail_x15_r0_body.cli107).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle107 : Conv.Cnt.leB (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck107 : Conv.ncleanListB (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx PRE_first_tail_x15_r0_body.clo107 PRE_first_tail_x15_r0_body.cln107 PRE_first_tail_x15_r0_body.cli107 = true
theorem PRE_first_tail_x15_r0_body.cncl107 (h : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx) : Conv.NClean (⟨20305, 17392, 2758718, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle107 PRE_first_tail_x15_r0_body.ckA107 PRE_first_tail_x15_r0_body.cobjsK107 PRE_first_tail_x15_r0_body.cnodesK107 PRE_first_tail_x15_r0_body.citemsK107 PRE_first_tail_x15_r0_body.cbd107 PRE_first_tail_x15_r0_body.cck107

end Host.Load.Run.Tpl
