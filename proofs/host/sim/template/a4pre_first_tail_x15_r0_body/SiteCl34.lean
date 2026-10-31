import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK34
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA34 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd34 : (PRE_first_tail_x15_r0_body.clo34 ++ PRE_first_tail_x15_r0_body.cln34 ++ PRE_first_tail_x15_r0_body.cli34).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle34 : Conv.Cnt.leB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck34 : Conv.ncleanListB (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx PRE_first_tail_x15_r0_body.clo34 PRE_first_tail_x15_r0_body.cln34 PRE_first_tail_x15_r0_body.cli34 = true
theorem PRE_first_tail_x15_r0_body.cncl34 (h : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx) : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle34 PRE_first_tail_x15_r0_body.ckA34 PRE_first_tail_x15_r0_body.cobjsK34 PRE_first_tail_x15_r0_body.cnodesK34 PRE_first_tail_x15_r0_body.citemsK34 PRE_first_tail_x15_r0_body.cbd34 PRE_first_tail_x15_r0_body.cck34

end Host.Load.Run.Tpl
