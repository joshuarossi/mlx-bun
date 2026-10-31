import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK114
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA114 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1013.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd114 : (PRE_first_tail_x15_r0_body.clo114 ++ PRE_first_tail_x15_r0_body.cln114 ++ PRE_first_tail_x15_r0_body.cli114).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle114 : Conv.Cnt.leB (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck114 : Conv.ncleanListB (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx PRE_first_tail_x15_r0_body.clo114 PRE_first_tail_x15_r0_body.cln114 PRE_first_tail_x15_r0_body.cli114 = true
theorem PRE_first_tail_x15_r0_body.cncl114 (h : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1013.ffi).mlx) : Conv.NClean (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle114 PRE_first_tail_x15_r0_body.ckA114 PRE_first_tail_x15_r0_body.cobjsK114 PRE_first_tail_x15_r0_body.cnodesK114 PRE_first_tail_x15_r0_body.citemsK114 PRE_first_tail_x15_r0_body.cbd114 PRE_first_tail_x15_r0_body.cck114

end Host.Load.Run.Tpl
