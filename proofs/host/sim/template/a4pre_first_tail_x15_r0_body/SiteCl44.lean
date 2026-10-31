import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK44
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s396.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s394.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s396.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd44 : (PRE_first_tail_x15_r0_body.clo44 ++ PRE_first_tail_x15_r0_body.cln44 ++ PRE_first_tail_x15_r0_body.cli44).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle44 : Conv.Cnt.leB (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck44 : Conv.ncleanListB (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s396.ffi).mlx PRE_first_tail_x15_r0_body.clo44 PRE_first_tail_x15_r0_body.cln44 PRE_first_tail_x15_r0_body.cli44 = true
theorem PRE_first_tail_x15_r0_body.cncl44 (h : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s394.ffi).mlx) : Conv.NClean (⟨19061, 16159, 2709004, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s396.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle44 PRE_first_tail_x15_r0_body.ckA44 PRE_first_tail_x15_r0_body.cobjsK44 PRE_first_tail_x15_r0_body.cnodesK44 PRE_first_tail_x15_r0_body.citemsK44 PRE_first_tail_x15_r0_body.cbd44 PRE_first_tail_x15_r0_body.cck44

end Host.Load.Run.Tpl
