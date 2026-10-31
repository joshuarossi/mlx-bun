import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK161
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA161 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1552.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd161 : (PRE_first_tail_x15_r0_body.clo161 ++ PRE_first_tail_x15_r0_body.cln161 ++ PRE_first_tail_x15_r0_body.cli161).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle161 : Conv.Cnt.leB (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck161 : Conv.ncleanListB (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx PRE_first_tail_x15_r0_body.clo161 PRE_first_tail_x15_r0_body.cln161 PRE_first_tail_x15_r0_body.cli161 = true
theorem PRE_first_tail_x15_r0_body.cncl161 (h : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1552.ffi).mlx) : Conv.NClean (⟨21364, 18466, 2800920, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle161 PRE_first_tail_x15_r0_body.ckA161 PRE_first_tail_x15_r0_body.cobjsK161 PRE_first_tail_x15_r0_body.cnodesK161 PRE_first_tail_x15_r0_body.citemsK161 PRE_first_tail_x15_r0_body.cbd161 PRE_first_tail_x15_r0_body.cck161

end Host.Load.Run.Tpl
