import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK77
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA77 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s684.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s682.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo77.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s684.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd77 : (PRE_first_tail_x15_r0_body.clo77 ++ PRE_first_tail_x15_r0_body.cln77 ++ PRE_first_tail_x15_r0_body.cli77).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle77 : Conv.Cnt.leB (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck77 : Conv.ncleanListB (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s684.ffi).mlx PRE_first_tail_x15_r0_body.clo77 PRE_first_tail_x15_r0_body.cln77 PRE_first_tail_x15_r0_body.cli77 = true
theorem PRE_first_tail_x15_r0_body.cncl77 (h : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s682.ffi).mlx) : Conv.NClean (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s684.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle77 PRE_first_tail_x15_r0_body.ckA77 PRE_first_tail_x15_r0_body.cobjsK77 PRE_first_tail_x15_r0_body.cnodesK77 PRE_first_tail_x15_r0_body.citemsK77 PRE_first_tail_x15_r0_body.cbd77 PRE_first_tail_x15_r0_body.cck77

end Host.Load.Run.Tpl
