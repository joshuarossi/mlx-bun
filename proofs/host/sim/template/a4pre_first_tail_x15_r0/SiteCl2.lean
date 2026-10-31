import host.sim.template.a4pre_first_tail_x15_r0.SiteK2
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0.ckA2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.arrs (PRE_first_tail_x15_r0.clo2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.cbd2 : (PRE_first_tail_x15_r0.clo2 ++ PRE_first_tail_x15_r0.cln2 ++ PRE_first_tail_x15_r0.cli2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.cle2 : Conv.Cnt.leB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0.cck2 : Conv.ncleanListB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx PRE_first_tail_x15_r0.clo2 PRE_first_tail_x15_r0.cln2 PRE_first_tail_x15_r0.cli2 = true
theorem PRE_first_tail_x15_r0.cncl2 (h : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx) : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0.cle2 PRE_first_tail_x15_r0.ckA2 PRE_first_tail_x15_r0.cobjsK2 PRE_first_tail_x15_r0.cnodesK2 PRE_first_tail_x15_r0.citemsK2 PRE_first_tail_x15_r0.cbd2 PRE_first_tail_x15_r0.cck2

end Host.Load.Run.Tpl
