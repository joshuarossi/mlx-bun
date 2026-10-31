import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK146
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA146 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo146.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd146 : (PRE_first_tail_x15_r0_body.clo146 ++ PRE_first_tail_x15_r0_body.cln146 ++ PRE_first_tail_x15_r0_body.cli146).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle146 : Conv.Cnt.leB (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck146 : Conv.ncleanListB (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx PRE_first_tail_x15_r0_body.clo146 PRE_first_tail_x15_r0_body.cln146 PRE_first_tail_x15_r0_body.cli146 = true
theorem PRE_first_tail_x15_r0_body.cncl146 (h : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx) : Conv.NClean (⟨21071, 18166, 2789244, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle146 PRE_first_tail_x15_r0_body.ckA146 PRE_first_tail_x15_r0_body.cobjsK146 PRE_first_tail_x15_r0_body.cnodesK146 PRE_first_tail_x15_r0_body.citemsK146 PRE_first_tail_x15_r0_body.cbd146 PRE_first_tail_x15_r0_body.cck146

end Host.Load.Run.Tpl
