import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK165
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA165 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1597.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd165 : (PRE_first_tail_x15_r0_body.clo165 ++ PRE_first_tail_x15_r0_body.cln165 ++ PRE_first_tail_x15_r0_body.cli165).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle165 : Conv.Cnt.leB (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck165 : Conv.ncleanListB (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx PRE_first_tail_x15_r0_body.clo165 PRE_first_tail_x15_r0_body.cln165 PRE_first_tail_x15_r0_body.cli165 = true
theorem PRE_first_tail_x15_r0_body.cncl165 (h : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1597.ffi).mlx) : Conv.NClean (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle165 PRE_first_tail_x15_r0_body.ckA165 PRE_first_tail_x15_r0_body.cobjsK165 PRE_first_tail_x15_r0_body.cnodesK165 PRE_first_tail_x15_r0_body.citemsK165 PRE_first_tail_x15_r0_body.cbd165 PRE_first_tail_x15_r0_body.cck165

end Host.Load.Run.Tpl
