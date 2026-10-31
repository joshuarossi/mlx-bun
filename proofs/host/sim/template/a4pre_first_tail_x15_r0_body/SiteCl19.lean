import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK19
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA19 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s182.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo19.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s182.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd19 : (PRE_first_tail_x15_r0_body.clo19 ++ PRE_first_tail_x15_r0_body.cln19 ++ PRE_first_tail_x15_r0_body.cli19).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle19 : Conv.Cnt.leB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck19 : Conv.ncleanListB (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s182.ffi).mlx PRE_first_tail_x15_r0_body.clo19 PRE_first_tail_x15_r0_body.cln19 PRE_first_tail_x15_r0_body.cli19 = true
theorem PRE_first_tail_x15_r0_body.cncl19 (h : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s180.ffi).mlx) : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s182.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle19 PRE_first_tail_x15_r0_body.ckA19 PRE_first_tail_x15_r0_body.cobjsK19 PRE_first_tail_x15_r0_body.cnodesK19 PRE_first_tail_x15_r0_body.citemsK19 PRE_first_tail_x15_r0_body.cbd19 PRE_first_tail_x15_r0_body.cck19

end Host.Load.Run.Tpl
