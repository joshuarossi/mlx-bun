import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK169
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA169 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1634.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd169 : (PRE_first_tail_x15_r0_body.clo169 ++ PRE_first_tail_x15_r0_body.cln169 ++ PRE_first_tail_x15_r0_body.cli169).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle169 : Conv.Cnt.leB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck169 : Conv.ncleanListB (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx PRE_first_tail_x15_r0_body.clo169 PRE_first_tail_x15_r0_body.cln169 PRE_first_tail_x15_r0_body.cli169 = true
theorem PRE_first_tail_x15_r0_body.cncl169 (h : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1634.ffi).mlx) : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle169 PRE_first_tail_x15_r0_body.ckA169 PRE_first_tail_x15_r0_body.cobjsK169 PRE_first_tail_x15_r0_body.cnodesK169 PRE_first_tail_x15_r0_body.citemsK169 PRE_first_tail_x15_r0_body.cbd169 PRE_first_tail_x15_r0_body.cck169

end Host.Load.Run.Tpl
