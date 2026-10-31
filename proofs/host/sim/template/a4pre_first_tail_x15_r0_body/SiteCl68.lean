import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK68
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd68 : (PRE_first_tail_x15_r0_body.clo68 ++ PRE_first_tail_x15_r0_body.cln68 ++ PRE_first_tail_x15_r0_body.cli68).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle68 : Conv.Cnt.leB (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck68 : Conv.ncleanListB (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx PRE_first_tail_x15_r0_body.clo68 PRE_first_tail_x15_r0_body.cln68 PRE_first_tail_x15_r0_body.cli68 = true
theorem PRE_first_tail_x15_r0_body.cncl68 (h : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx) : Conv.NClean (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle68 PRE_first_tail_x15_r0_body.ckA68 PRE_first_tail_x15_r0_body.cobjsK68 PRE_first_tail_x15_r0_body.cnodesK68 PRE_first_tail_x15_r0_body.citemsK68 PRE_first_tail_x15_r0_body.cbd68 PRE_first_tail_x15_r0_body.cck68

end Host.Load.Run.Tpl
