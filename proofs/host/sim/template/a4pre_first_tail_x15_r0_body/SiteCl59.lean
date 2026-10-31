import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK59
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd59 : (PRE_first_tail_x15_r0_body.clo59 ++ PRE_first_tail_x15_r0_body.cln59 ++ PRE_first_tail_x15_r0_body.cli59).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle59 : Conv.Cnt.leB (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck59 : Conv.ncleanListB (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx PRE_first_tail_x15_r0_body.clo59 PRE_first_tail_x15_r0_body.cln59 PRE_first_tail_x15_r0_body.cli59 = true
theorem PRE_first_tail_x15_r0_body.cncl59 (h : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx) : Conv.NClean (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle59 PRE_first_tail_x15_r0_body.ckA59 PRE_first_tail_x15_r0_body.cobjsK59 PRE_first_tail_x15_r0_body.cnodesK59 PRE_first_tail_x15_r0_body.citemsK59 PRE_first_tail_x15_r0_body.cbd59 PRE_first_tail_x15_r0_body.cck59

end Host.Load.Run.Tpl
