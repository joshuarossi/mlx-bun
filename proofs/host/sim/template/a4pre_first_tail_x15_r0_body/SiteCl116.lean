import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK116
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA116 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd116 : (PRE_first_tail_x15_r0_body.clo116 ++ PRE_first_tail_x15_r0_body.cln116 ++ PRE_first_tail_x15_r0_body.cli116).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle116 : Conv.Cnt.leB (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck116 : Conv.ncleanListB (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx PRE_first_tail_x15_r0_body.clo116 PRE_first_tail_x15_r0_body.cln116 PRE_first_tail_x15_r0_body.cli116 = true
theorem PRE_first_tail_x15_r0_body.cncl116 (h : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx) : Conv.NClean (⟨20477, 17581, 2765508, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle116 PRE_first_tail_x15_r0_body.ckA116 PRE_first_tail_x15_r0_body.cobjsK116 PRE_first_tail_x15_r0_body.cnodesK116 PRE_first_tail_x15_r0_body.citemsK116 PRE_first_tail_x15_r0_body.cbd116 PRE_first_tail_x15_r0_body.cck116

end Host.Load.Run.Tpl
