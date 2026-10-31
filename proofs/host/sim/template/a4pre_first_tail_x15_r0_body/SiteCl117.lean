import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK117
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA117 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1137.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd117 : (PRE_first_tail_x15_r0_body.clo117 ++ PRE_first_tail_x15_r0_body.cln117 ++ PRE_first_tail_x15_r0_body.cli117).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle117 : Conv.Cnt.leB (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck117 : Conv.ncleanListB (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx PRE_first_tail_x15_r0_body.clo117 PRE_first_tail_x15_r0_body.cln117 PRE_first_tail_x15_r0_body.cli117 = true
theorem PRE_first_tail_x15_r0_body.cncl117 (h : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1137.ffi).mlx) : Conv.NClean (⟨20521, 17615, 2767259, 5100⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle117 PRE_first_tail_x15_r0_body.ckA117 PRE_first_tail_x15_r0_body.cobjsK117 PRE_first_tail_x15_r0_body.cnodesK117 PRE_first_tail_x15_r0_body.citemsK117 PRE_first_tail_x15_r0_body.cbd117 PRE_first_tail_x15_r0_body.cck117

end Host.Load.Run.Tpl
