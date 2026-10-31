import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK14
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA14 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd14 : (PRE_first_tail_x15_r0_body.clo14 ++ PRE_first_tail_x15_r0_body.cln14 ++ PRE_first_tail_x15_r0_body.cli14).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle14 : Conv.Cnt.leB (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck14 : Conv.ncleanListB (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx PRE_first_tail_x15_r0_body.clo14 PRE_first_tail_x15_r0_body.cln14 PRE_first_tail_x15_r0_body.cli14 = true
theorem PRE_first_tail_x15_r0_body.cncl14 (h : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx) : Conv.NClean (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle14 PRE_first_tail_x15_r0_body.ckA14 PRE_first_tail_x15_r0_body.cobjsK14 PRE_first_tail_x15_r0_body.cnodesK14 PRE_first_tail_x15_r0_body.citemsK14 PRE_first_tail_x15_r0_body.cbd14 PRE_first_tail_x15_r0_body.cck14

end Host.Load.Run.Tpl
