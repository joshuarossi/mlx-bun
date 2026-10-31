import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK104
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd104 : (PRE_first_tail_x15_r0_body.clo104 ++ PRE_first_tail_x15_r0_body.cln104 ++ PRE_first_tail_x15_r0_body.cli104).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle104 : Conv.Cnt.leB (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck104 : Conv.ncleanListB (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx PRE_first_tail_x15_r0_body.clo104 PRE_first_tail_x15_r0_body.cln104 PRE_first_tail_x15_r0_body.cli104 = true
theorem PRE_first_tail_x15_r0_body.cncl104 (h : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx) : Conv.NClean (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle104 PRE_first_tail_x15_r0_body.ckA104 PRE_first_tail_x15_r0_body.cobjsK104 PRE_first_tail_x15_r0_body.cnodesK104 PRE_first_tail_x15_r0_body.citemsK104 PRE_first_tail_x15_r0_body.cbd104 PRE_first_tail_x15_r0_body.cck104

end Host.Load.Run.Tpl
