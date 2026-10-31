import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK181
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA181 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1598.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1596.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1598.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd181 : (PRE_first_tail_x15_r0_body.clo181 ++ PRE_first_tail_x15_r0_body.cln181 ++ PRE_first_tail_x15_r0_body.cli181).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle181 : Conv.Cnt.leB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck181 : Conv.ncleanListB (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1598.ffi).mlx PRE_first_tail_x15_r0_body.clo181 PRE_first_tail_x15_r0_body.cln181 PRE_first_tail_x15_r0_body.cli181 = true
theorem PRE_first_tail_x15_r0_body.cncl181 (h : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1596.ffi).mlx) : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1598.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle181 PRE_first_tail_x15_r0_body.ckA181 PRE_first_tail_x15_r0_body.cobjsK181 PRE_first_tail_x15_r0_body.cnodesK181 PRE_first_tail_x15_r0_body.citemsK181 PRE_first_tail_x15_r0_body.cbd181 PRE_first_tail_x15_r0_body.cck181

end Host.Load.Run.Tpl
