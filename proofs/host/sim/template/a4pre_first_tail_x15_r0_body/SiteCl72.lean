import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK72
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd72 : (PRE_first_tail_x15_r0_body.clo72 ++ PRE_first_tail_x15_r0_body.cln72 ++ PRE_first_tail_x15_r0_body.cli72).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle72 : Conv.Cnt.leB (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck72 : Conv.ncleanListB (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx PRE_first_tail_x15_r0_body.clo72 PRE_first_tail_x15_r0_body.cln72 PRE_first_tail_x15_r0_body.cli72 = true
theorem PRE_first_tail_x15_r0_body.cncl72 (h : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx) : Conv.NClean (⟨19635, 16727, 2731965, 3179⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle72 PRE_first_tail_x15_r0_body.ckA72 PRE_first_tail_x15_r0_body.cobjsK72 PRE_first_tail_x15_r0_body.cnodesK72 PRE_first_tail_x15_r0_body.citemsK72 PRE_first_tail_x15_r0_body.cbd72 PRE_first_tail_x15_r0_body.cck72

end Host.Load.Run.Tpl
