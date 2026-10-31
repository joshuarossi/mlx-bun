import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK140
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd140 : (PRE_first_tail_x15_r0_body.clo140 ++ PRE_first_tail_x15_r0_body.cln140 ++ PRE_first_tail_x15_r0_body.cli140).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle140 : Conv.Cnt.leB (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck140 : Conv.ncleanListB (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx PRE_first_tail_x15_r0_body.clo140 PRE_first_tail_x15_r0_body.cln140 PRE_first_tail_x15_r0_body.cli140 = true
theorem PRE_first_tail_x15_r0_body.cncl140 (h : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx) : Conv.NClean (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle140 PRE_first_tail_x15_r0_body.ckA140 PRE_first_tail_x15_r0_body.cobjsK140 PRE_first_tail_x15_r0_body.cnodesK140 PRE_first_tail_x15_r0_body.citemsK140 PRE_first_tail_x15_r0_body.cbd140 PRE_first_tail_x15_r0_body.cck140

end Host.Load.Run.Tpl
