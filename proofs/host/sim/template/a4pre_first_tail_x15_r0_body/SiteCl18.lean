import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK18
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA18 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s189.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd18 : (PRE_first_tail_x15_r0_body.clo18 ++ PRE_first_tail_x15_r0_body.cln18 ++ PRE_first_tail_x15_r0_body.cli18).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle18 : Conv.Cnt.leB (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck18 : Conv.ncleanListB (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx PRE_first_tail_x15_r0_body.clo18 PRE_first_tail_x15_r0_body.cln18 PRE_first_tail_x15_r0_body.cli18 = true
theorem PRE_first_tail_x15_r0_body.cncl18 (h : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s189.ffi).mlx) : Conv.NClean (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle18 PRE_first_tail_x15_r0_body.ckA18 PRE_first_tail_x15_r0_body.cobjsK18 PRE_first_tail_x15_r0_body.cnodesK18 PRE_first_tail_x15_r0_body.citemsK18 PRE_first_tail_x15_r0_body.cbd18 PRE_first_tail_x15_r0_body.cck18

end Host.Load.Run.Tpl
