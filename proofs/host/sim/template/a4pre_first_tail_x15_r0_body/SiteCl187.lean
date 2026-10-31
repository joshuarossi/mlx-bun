import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK187
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1652.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1650.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1652.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd187 : (PRE_first_tail_x15_r0_body.clo187 ++ PRE_first_tail_x15_r0_body.cln187 ++ PRE_first_tail_x15_r0_body.cli187).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle187 : Conv.Cnt.leB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck187 : Conv.ncleanListB (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1652.ffi).mlx PRE_first_tail_x15_r0_body.clo187 PRE_first_tail_x15_r0_body.cln187 PRE_first_tail_x15_r0_body.cli187 = true
theorem PRE_first_tail_x15_r0_body.cncl187 (h : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1650.ffi).mlx) : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1652.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle187 PRE_first_tail_x15_r0_body.ckA187 PRE_first_tail_x15_r0_body.cobjsK187 PRE_first_tail_x15_r0_body.cnodesK187 PRE_first_tail_x15_r0_body.citemsK187 PRE_first_tail_x15_r0_body.cbd187 PRE_first_tail_x15_r0_body.cck187

end Host.Load.Run.Tpl
