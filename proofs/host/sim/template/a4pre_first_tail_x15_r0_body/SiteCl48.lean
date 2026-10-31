import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK48
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd48 : (PRE_first_tail_x15_r0_body.clo48 ++ PRE_first_tail_x15_r0_body.cln48 ++ PRE_first_tail_x15_r0_body.cli48).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle48 : Conv.Cnt.leB (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck48 : Conv.ncleanListB (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx PRE_first_tail_x15_r0_body.clo48 PRE_first_tail_x15_r0_body.cln48 PRE_first_tail_x15_r0_body.cli48 = true
theorem PRE_first_tail_x15_r0_body.cncl48 (h : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx) : Conv.NClean (⟨19163, 16253, 2713129, 2153⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle48 PRE_first_tail_x15_r0_body.ckA48 PRE_first_tail_x15_r0_body.cobjsK48 PRE_first_tail_x15_r0_body.cnodesK48 PRE_first_tail_x15_r0_body.citemsK48 PRE_first_tail_x15_r0_body.cbd48 PRE_first_tail_x15_r0_body.cck48

end Host.Load.Run.Tpl
