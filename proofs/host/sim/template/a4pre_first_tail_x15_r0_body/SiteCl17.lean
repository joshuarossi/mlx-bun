import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK17
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA17 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s159.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s159.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd17 : (PRE_first_tail_x15_r0_body.clo17 ++ PRE_first_tail_x15_r0_body.cln17 ++ PRE_first_tail_x15_r0_body.cli17).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle17 : Conv.Cnt.leB (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck17 : Conv.ncleanListB (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s159.ffi).mlx PRE_first_tail_x15_r0_body.clo17 PRE_first_tail_x15_r0_body.cln17 PRE_first_tail_x15_r0_body.cli17 = true
theorem PRE_first_tail_x15_r0_body.cncl17 (h : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s157.ffi).mlx) : Conv.NClean (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s159.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle17 PRE_first_tail_x15_r0_body.ckA17 PRE_first_tail_x15_r0_body.cobjsK17 PRE_first_tail_x15_r0_body.cnodesK17 PRE_first_tail_x15_r0_body.citemsK17 PRE_first_tail_x15_r0_body.cbd17 PRE_first_tail_x15_r0_body.cck17

end Host.Load.Run.Tpl
