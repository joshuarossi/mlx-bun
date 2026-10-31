import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK110
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA110 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1063.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd110 : (PRE_first_tail_x15_r0_body.clo110 ++ PRE_first_tail_x15_r0_body.cln110 ++ PRE_first_tail_x15_r0_body.cli110).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle110 : Conv.Cnt.leB (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck110 : Conv.ncleanListB (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx PRE_first_tail_x15_r0_body.clo110 PRE_first_tail_x15_r0_body.cln110 PRE_first_tail_x15_r0_body.cli110 = true
theorem PRE_first_tail_x15_r0_body.cncl110 (h : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1063.ffi).mlx) : Conv.NClean (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle110 PRE_first_tail_x15_r0_body.ckA110 PRE_first_tail_x15_r0_body.cobjsK110 PRE_first_tail_x15_r0_body.cnodesK110 PRE_first_tail_x15_r0_body.citemsK110 PRE_first_tail_x15_r0_body.cbd110 PRE_first_tail_x15_r0_body.cck110

end Host.Load.Run.Tpl
