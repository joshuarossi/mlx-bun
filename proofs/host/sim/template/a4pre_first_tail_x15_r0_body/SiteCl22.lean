import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK22
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA22 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s227.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s225.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s227.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd22 : (PRE_first_tail_x15_r0_body.clo22 ++ PRE_first_tail_x15_r0_body.cln22 ++ PRE_first_tail_x15_r0_body.cli22).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle22 : Conv.Cnt.leB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck22 : Conv.ncleanListB (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s227.ffi).mlx PRE_first_tail_x15_r0_body.clo22 PRE_first_tail_x15_r0_body.cln22 PRE_first_tail_x15_r0_body.cli22 = true
theorem PRE_first_tail_x15_r0_body.cncl22 (h : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s225.ffi).mlx) : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s227.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle22 PRE_first_tail_x15_r0_body.ckA22 PRE_first_tail_x15_r0_body.cobjsK22 PRE_first_tail_x15_r0_body.cnodesK22 PRE_first_tail_x15_r0_body.citemsK22 PRE_first_tail_x15_r0_body.cbd22 PRE_first_tail_x15_r0_body.cck22

end Host.Load.Run.Tpl
