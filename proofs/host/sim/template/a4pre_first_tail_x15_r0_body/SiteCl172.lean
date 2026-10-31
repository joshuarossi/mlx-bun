import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK172
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA172 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1663.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd172 : (PRE_first_tail_x15_r0_body.clo172 ++ PRE_first_tail_x15_r0_body.cln172 ++ PRE_first_tail_x15_r0_body.cli172).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle172 : Conv.Cnt.leB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck172 : Conv.ncleanListB (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx PRE_first_tail_x15_r0_body.clo172 PRE_first_tail_x15_r0_body.cln172 PRE_first_tail_x15_r0_body.cli172 = true
theorem PRE_first_tail_x15_r0_body.cncl172 (h : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1663.ffi).mlx) : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle172 PRE_first_tail_x15_r0_body.ckA172 PRE_first_tail_x15_r0_body.cobjsK172 PRE_first_tail_x15_r0_body.cnodesK172 PRE_first_tail_x15_r0_body.citemsK172 PRE_first_tail_x15_r0_body.cbd172 PRE_first_tail_x15_r0_body.cck172

end Host.Load.Run.Tpl
