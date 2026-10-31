import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK3
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd3 : (PRE_first_tail_x15_r0_body.clo3 ++ PRE_first_tail_x15_r0_body.cln3 ++ PRE_first_tail_x15_r0_body.cli3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle3 : Conv.Cnt.leB (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck3 : Conv.ncleanListB (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx PRE_first_tail_x15_r0_body.clo3 PRE_first_tail_x15_r0_body.cln3 PRE_first_tail_x15_r0_body.cli3 = true
theorem PRE_first_tail_x15_r0_body.cncl3 (h : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s41.ffi).mlx) : Conv.NClean (⟨18273, 15368, 2677629, 230⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle3 PRE_first_tail_x15_r0_body.ckA3 PRE_first_tail_x15_r0_body.cobjsK3 PRE_first_tail_x15_r0_body.cnodesK3 PRE_first_tail_x15_r0_body.citemsK3 PRE_first_tail_x15_r0_body.cbd3 PRE_first_tail_x15_r0_body.cck3

end Host.Load.Run.Tpl
