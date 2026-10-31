import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK95
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA95 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo95.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd95 : (PRE_first_tail_x15_r0_body.clo95 ++ PRE_first_tail_x15_r0_body.cln95 ++ PRE_first_tail_x15_r0_body.cli95).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle95 : Conv.Cnt.leB (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck95 : Conv.ncleanListB (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx PRE_first_tail_x15_r0_body.clo95 PRE_first_tail_x15_r0_body.cln95 PRE_first_tail_x15_r0_body.cli95 = true
theorem PRE_first_tail_x15_r0_body.cncl95 (h : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s838.ffi).mlx) : Conv.NClean (⟨20069, 17155, 2749294, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle95 PRE_first_tail_x15_r0_body.ckA95 PRE_first_tail_x15_r0_body.cobjsK95 PRE_first_tail_x15_r0_body.cnodesK95 PRE_first_tail_x15_r0_body.citemsK95 PRE_first_tail_x15_r0_body.cbd95 PRE_first_tail_x15_r0_body.cck95

end Host.Load.Run.Tpl
