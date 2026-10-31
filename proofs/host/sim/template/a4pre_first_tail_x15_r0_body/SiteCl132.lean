import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK132
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd132 : (PRE_first_tail_x15_r0_body.clo132 ++ PRE_first_tail_x15_r0_body.cln132 ++ PRE_first_tail_x15_r0_body.cli132).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle132 : Conv.Cnt.leB (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck132 : Conv.ncleanListB (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx PRE_first_tail_x15_r0_body.clo132 PRE_first_tail_x15_r0_body.cln132 PRE_first_tail_x15_r0_body.cli132 = true
theorem PRE_first_tail_x15_r0_body.cncl132 (h : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) : Conv.NClean (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle132 PRE_first_tail_x15_r0_body.ckA132 PRE_first_tail_x15_r0_body.cobjsK132 PRE_first_tail_x15_r0_body.cnodesK132 PRE_first_tail_x15_r0_body.citemsK132 PRE_first_tail_x15_r0_body.cbd132 PRE_first_tail_x15_r0_body.cck132

end Host.Load.Run.Tpl
