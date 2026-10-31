import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK183
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA183 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd183 : (PRE_first_tail_x15_r0_body.clo183 ++ PRE_first_tail_x15_r0_body.cln183 ++ PRE_first_tail_x15_r0_body.cli183).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle183 : Conv.Cnt.leB (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck183 : Conv.ncleanListB (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx PRE_first_tail_x15_r0_body.clo183 PRE_first_tail_x15_r0_body.cln183 PRE_first_tail_x15_r0_body.cli183 = true
theorem PRE_first_tail_x15_r0_body.cncl183 (h : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx) : Conv.NClean (⟨21816, 18923, 2818993, 7925⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle183 PRE_first_tail_x15_r0_body.ckA183 PRE_first_tail_x15_r0_body.cobjsK183 PRE_first_tail_x15_r0_body.cnodesK183 PRE_first_tail_x15_r0_body.citemsK183 PRE_first_tail_x15_r0_body.cbd183 PRE_first_tail_x15_r0_body.cck183

end Host.Load.Run.Tpl
