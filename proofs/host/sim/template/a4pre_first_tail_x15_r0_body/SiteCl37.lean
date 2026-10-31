import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK37
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA37 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd37 : (PRE_first_tail_x15_r0_body.clo37 ++ PRE_first_tail_x15_r0_body.cln37 ++ PRE_first_tail_x15_r0_body.cli37).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle37 : Conv.Cnt.leB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck37 : Conv.ncleanListB (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx PRE_first_tail_x15_r0_body.clo37 PRE_first_tail_x15_r0_body.cln37 PRE_first_tail_x15_r0_body.cli37 = true
theorem PRE_first_tail_x15_r0_body.cncl37 (h : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx) : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle37 PRE_first_tail_x15_r0_body.ckA37 PRE_first_tail_x15_r0_body.cobjsK37 PRE_first_tail_x15_r0_body.cnodesK37 PRE_first_tail_x15_r0_body.citemsK37 PRE_first_tail_x15_r0_body.cbd37 PRE_first_tail_x15_r0_body.cck37

end Host.Load.Run.Tpl
