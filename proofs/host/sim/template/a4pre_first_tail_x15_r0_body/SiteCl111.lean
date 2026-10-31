import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK111
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA111 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s986.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd111 : (PRE_first_tail_x15_r0_body.clo111 ++ PRE_first_tail_x15_r0_body.cln111 ++ PRE_first_tail_x15_r0_body.cli111).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle111 : Conv.Cnt.leB (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck111 : Conv.ncleanListB (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx PRE_first_tail_x15_r0_body.clo111 PRE_first_tail_x15_r0_body.cln111 PRE_first_tail_x15_r0_body.cli111 = true
theorem PRE_first_tail_x15_r0_body.cncl111 (h : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s986.ffi).mlx) : Conv.NClean (⟨20400, 17501, 2762473, 4847⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle111 PRE_first_tail_x15_r0_body.ckA111 PRE_first_tail_x15_r0_body.cobjsK111 PRE_first_tail_x15_r0_body.cnodesK111 PRE_first_tail_x15_r0_body.citemsK111 PRE_first_tail_x15_r0_body.cbd111 PRE_first_tail_x15_r0_body.cck111

end Host.Load.Run.Tpl
