import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK191
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1678.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd191 : (PRE_first_tail_x15_r0_body.clo191 ++ PRE_first_tail_x15_r0_body.cln191 ++ PRE_first_tail_x15_r0_body.cli191).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle191 : Conv.Cnt.leB (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck191 : Conv.ncleanListB (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx PRE_first_tail_x15_r0_body.clo191 PRE_first_tail_x15_r0_body.cln191 PRE_first_tail_x15_r0_body.cli191 = true
theorem PRE_first_tail_x15_r0_body.cncl191 (h : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1678.ffi).mlx) : Conv.NClean (⟨21957, 19051, 2824654, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle191 PRE_first_tail_x15_r0_body.ckA191 PRE_first_tail_x15_r0_body.cobjsK191 PRE_first_tail_x15_r0_body.cnodesK191 PRE_first_tail_x15_r0_body.citemsK191 PRE_first_tail_x15_r0_body.cbd191 PRE_first_tail_x15_r0_body.cck191

end Host.Load.Run.Tpl
