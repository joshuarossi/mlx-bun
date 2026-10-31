import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK51
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA51 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo51.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd51 : (PRE_first_tail_x15_r0_body.clo51 ++ PRE_first_tail_x15_r0_body.cln51 ++ PRE_first_tail_x15_r0_body.cli51).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle51 : Conv.Cnt.leB (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck51 : Conv.ncleanListB (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx PRE_first_tail_x15_r0_body.clo51 PRE_first_tail_x15_r0_body.cln51 PRE_first_tail_x15_r0_body.cli51 = true
theorem PRE_first_tail_x15_r0_body.cncl51 (h : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx) : Conv.NClean (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle51 PRE_first_tail_x15_r0_body.ckA51 PRE_first_tail_x15_r0_body.cobjsK51 PRE_first_tail_x15_r0_body.cnodesK51 PRE_first_tail_x15_r0_body.citemsK51 PRE_first_tail_x15_r0_body.cbd51 PRE_first_tail_x15_r0_body.cck51

end Host.Load.Run.Tpl
