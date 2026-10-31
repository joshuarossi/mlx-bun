import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK64
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s573.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd64 : (PRE_first_tail_x15_r0_body.clo64 ++ PRE_first_tail_x15_r0_body.cln64 ++ PRE_first_tail_x15_r0_body.cli64).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle64 : Conv.Cnt.leB (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck64 : Conv.ncleanListB (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx PRE_first_tail_x15_r0_body.clo64 PRE_first_tail_x15_r0_body.cln64 PRE_first_tail_x15_r0_body.cli64 = true
theorem PRE_first_tail_x15_r0_body.cncl64 (h : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s573.ffi).mlx) : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle64 PRE_first_tail_x15_r0_body.ckA64 PRE_first_tail_x15_r0_body.cobjsK64 PRE_first_tail_x15_r0_body.cnodesK64 PRE_first_tail_x15_r0_body.citemsK64 PRE_first_tail_x15_r0_body.cbd64 PRE_first_tail_x15_r0_body.cck64

end Host.Load.Run.Tpl
