import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK144
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA144 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1276.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1274.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1276.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd144 : (PRE_first_tail_x15_r0_body.clo144 ++ PRE_first_tail_x15_r0_body.cln144 ++ PRE_first_tail_x15_r0_body.cli144).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle144 : Conv.Cnt.leB (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck144 : Conv.ncleanListB (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1276.ffi).mlx PRE_first_tail_x15_r0_body.clo144 PRE_first_tail_x15_r0_body.cln144 PRE_first_tail_x15_r0_body.cli144 = true
theorem PRE_first_tail_x15_r0_body.cncl144 (h : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1274.ffi).mlx) : Conv.NClean (⟨21051, 18149, 2788465, 6257⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1276.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle144 PRE_first_tail_x15_r0_body.ckA144 PRE_first_tail_x15_r0_body.cobjsK144 PRE_first_tail_x15_r0_body.cnodesK144 PRE_first_tail_x15_r0_body.citemsK144 PRE_first_tail_x15_r0_body.cbd144 PRE_first_tail_x15_r0_body.cck144

end Host.Load.Run.Tpl
