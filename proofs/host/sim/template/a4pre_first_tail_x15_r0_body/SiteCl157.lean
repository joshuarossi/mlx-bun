import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK157
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA157 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1386.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo157.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd157 : (PRE_first_tail_x15_r0_body.clo157 ++ PRE_first_tail_x15_r0_body.cln157 ++ PRE_first_tail_x15_r0_body.cli157).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle157 : Conv.Cnt.leB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck157 : Conv.ncleanListB (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx PRE_first_tail_x15_r0_body.clo157 PRE_first_tail_x15_r0_body.cln157 PRE_first_tail_x15_r0_body.cli157 = true
theorem PRE_first_tail_x15_r0_body.cncl157 (h : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1386.ffi).mlx) : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle157 PRE_first_tail_x15_r0_body.ckA157 PRE_first_tail_x15_r0_body.cobjsK157 PRE_first_tail_x15_r0_body.cnodesK157 PRE_first_tail_x15_r0_body.citemsK157 PRE_first_tail_x15_r0_body.cbd157 PRE_first_tail_x15_r0_body.cck157

end Host.Load.Run.Tpl
