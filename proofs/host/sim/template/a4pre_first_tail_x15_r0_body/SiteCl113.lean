import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK113
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA113 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s999.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo113.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s999.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd113 : (PRE_first_tail_x15_r0_body.clo113 ++ PRE_first_tail_x15_r0_body.cln113 ++ PRE_first_tail_x15_r0_body.cli113).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle113 : Conv.Cnt.leB (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck113 : Conv.ncleanListB (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s999.ffi).mlx PRE_first_tail_x15_r0_body.clo113 PRE_first_tail_x15_r0_body.cln113 PRE_first_tail_x15_r0_body.cli113 = true
theorem PRE_first_tail_x15_r0_body.cncl113 (h : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s997.ffi).mlx) : Conv.NClean (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s999.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle113 PRE_first_tail_x15_r0_body.ckA113 PRE_first_tail_x15_r0_body.cobjsK113 PRE_first_tail_x15_r0_body.cnodesK113 PRE_first_tail_x15_r0_body.citemsK113 PRE_first_tail_x15_r0_body.cbd113 PRE_first_tail_x15_r0_body.cck113

end Host.Load.Run.Tpl
