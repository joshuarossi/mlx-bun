import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK148
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA148 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1308.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo148.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd148 : (PRE_first_tail_x15_r0_body.clo148 ++ PRE_first_tail_x15_r0_body.cln148 ++ PRE_first_tail_x15_r0_body.cli148).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle148 : Conv.Cnt.leB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck148 : Conv.ncleanListB (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx PRE_first_tail_x15_r0_body.clo148 PRE_first_tail_x15_r0_body.cln148 PRE_first_tail_x15_r0_body.cli148 = true
theorem PRE_first_tail_x15_r0_body.cncl148 (h : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1308.ffi).mlx) : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle148 PRE_first_tail_x15_r0_body.ckA148 PRE_first_tail_x15_r0_body.cobjsK148 PRE_first_tail_x15_r0_body.cnodesK148 PRE_first_tail_x15_r0_body.citemsK148 PRE_first_tail_x15_r0_body.cbd148 PRE_first_tail_x15_r0_body.cck148

end Host.Load.Run.Tpl
