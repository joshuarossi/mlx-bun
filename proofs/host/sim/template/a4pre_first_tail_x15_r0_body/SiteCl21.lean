import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK21
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA21 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd21 : (PRE_first_tail_x15_r0_body.clo21 ++ PRE_first_tail_x15_r0_body.cln21 ++ PRE_first_tail_x15_r0_body.cli21).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle21 : Conv.Cnt.leB (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck21 : Conv.ncleanListB (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx PRE_first_tail_x15_r0_body.clo21 PRE_first_tail_x15_r0_body.cln21 PRE_first_tail_x15_r0_body.cli21 = true
theorem PRE_first_tail_x15_r0_body.cncl21 (h : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx) : Conv.NClean (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle21 PRE_first_tail_x15_r0_body.ckA21 PRE_first_tail_x15_r0_body.cobjsK21 PRE_first_tail_x15_r0_body.cnodesK21 PRE_first_tail_x15_r0_body.citemsK21 PRE_first_tail_x15_r0_body.cbd21 PRE_first_tail_x15_r0_body.cck21

end Host.Load.Run.Tpl
