import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK7
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA7 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s82.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo7.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd7 : (PRE_first_tail_x15_r0_body.clo7 ++ PRE_first_tail_x15_r0_body.cln7 ++ PRE_first_tail_x15_r0_body.cli7).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle7 : Conv.Cnt.leB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck7 : Conv.ncleanListB (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx PRE_first_tail_x15_r0_body.clo7 PRE_first_tail_x15_r0_body.cln7 PRE_first_tail_x15_r0_body.cli7 = true
theorem PRE_first_tail_x15_r0_body.cncl7 (h : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s82.ffi).mlx) : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle7 PRE_first_tail_x15_r0_body.ckA7 PRE_first_tail_x15_r0_body.cobjsK7 PRE_first_tail_x15_r0_body.cnodesK7 PRE_first_tail_x15_r0_body.citemsK7 PRE_first_tail_x15_r0_body.cbd7 PRE_first_tail_x15_r0_body.cck7

end Host.Load.Run.Tpl
