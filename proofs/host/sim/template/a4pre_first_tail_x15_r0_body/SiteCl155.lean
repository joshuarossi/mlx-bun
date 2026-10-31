import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK155
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA155 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1363.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo155.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd155 : (PRE_first_tail_x15_r0_body.clo155 ++ PRE_first_tail_x15_r0_body.cln155 ++ PRE_first_tail_x15_r0_body.cli155).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle155 : Conv.Cnt.leB (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck155 : Conv.ncleanListB (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx PRE_first_tail_x15_r0_body.clo155 PRE_first_tail_x15_r0_body.cln155 PRE_first_tail_x15_r0_body.cli155 = true
theorem PRE_first_tail_x15_r0_body.cncl155 (h : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1363.ffi).mlx) : Conv.NClean (⟨21249, 18340, 2796386, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle155 PRE_first_tail_x15_r0_body.ckA155 PRE_first_tail_x15_r0_body.cobjsK155 PRE_first_tail_x15_r0_body.cnodesK155 PRE_first_tail_x15_r0_body.citemsK155 PRE_first_tail_x15_r0_body.cbd155 PRE_first_tail_x15_r0_body.cck155

end Host.Load.Run.Tpl
