import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK30
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA30 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s280.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s278.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s280.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd30 : (PRE_first_tail_x15_r0_body.clo30 ++ PRE_first_tail_x15_r0_body.cln30 ++ PRE_first_tail_x15_r0_body.cli30).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle30 : Conv.Cnt.leB (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck30 : Conv.ncleanListB (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s280.ffi).mlx PRE_first_tail_x15_r0_body.clo30 PRE_first_tail_x15_r0_body.cln30 PRE_first_tail_x15_r0_body.cli30 = true
theorem PRE_first_tail_x15_r0_body.cncl30 (h : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s278.ffi).mlx) : Conv.NClean (⟨18805, 15905, 2698805, 1385⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s280.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle30 PRE_first_tail_x15_r0_body.ckA30 PRE_first_tail_x15_r0_body.cobjsK30 PRE_first_tail_x15_r0_body.cnodesK30 PRE_first_tail_x15_r0_body.citemsK30 PRE_first_tail_x15_r0_body.cbd30 PRE_first_tail_x15_r0_body.cck30

end Host.Load.Run.Tpl
