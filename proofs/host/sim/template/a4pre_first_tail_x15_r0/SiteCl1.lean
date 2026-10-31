import host.sim.template.a4pre_first_tail_x15_r0.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0.ckA1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.arrs (PRE_first_tail_x15_r0.clo1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.cbd1 : (PRE_first_tail_x15_r0.clo1 ++ PRE_first_tail_x15_r0.cln1 ++ PRE_first_tail_x15_r0.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.cle1 : Conv.Cnt.leB (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0.cck1 : Conv.ncleanListB (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx PRE_first_tail_x15_r0.clo1 PRE_first_tail_x15_r0.cln1 PRE_first_tail_x15_r0.cli1 = true
theorem PRE_first_tail_x15_r0.cncl1 (h : Conv.NClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx) : Conv.NClean (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0.cle1 PRE_first_tail_x15_r0.ckA1 PRE_first_tail_x15_r0.cobjsK1 PRE_first_tail_x15_r0.cnodesK1 PRE_first_tail_x15_r0.citemsK1 PRE_first_tail_x15_r0.cbd1 PRE_first_tail_x15_r0.cck1

end Host.Load.Run.Tpl
