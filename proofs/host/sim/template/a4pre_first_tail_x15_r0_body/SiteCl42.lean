import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK42
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA42 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s421.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s419.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s421.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd42 : (PRE_first_tail_x15_r0_body.clo42 ++ PRE_first_tail_x15_r0_body.cln42 ++ PRE_first_tail_x15_r0_body.cli42).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle42 : Conv.Cnt.leB (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck42 : Conv.ncleanListB (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s421.ffi).mlx PRE_first_tail_x15_r0_body.clo42 PRE_first_tail_x15_r0_body.cln42 PRE_first_tail_x15_r0_body.cli42 = true
theorem PRE_first_tail_x15_r0_body.cncl42 (h : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s419.ffi).mlx) : Conv.NClean (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s421.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle42 PRE_first_tail_x15_r0_body.ckA42 PRE_first_tail_x15_r0_body.cobjsK42 PRE_first_tail_x15_r0_body.cnodesK42 PRE_first_tail_x15_r0_body.citemsK42 PRE_first_tail_x15_r0_body.cbd42 PRE_first_tail_x15_r0_body.cck42

end Host.Load.Run.Tpl
