import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK142
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd142 : (PRE_first_tail_x15_r0_body.clo142 ++ PRE_first_tail_x15_r0_body.cln142 ++ PRE_first_tail_x15_r0_body.cli142).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle142 : Conv.Cnt.leB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck142 : Conv.ncleanListB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx PRE_first_tail_x15_r0_body.clo142 PRE_first_tail_x15_r0_body.cln142 PRE_first_tail_x15_r0_body.cli142 = true
theorem PRE_first_tail_x15_r0_body.cncl142 (h : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx) : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle142 PRE_first_tail_x15_r0_body.ckA142 PRE_first_tail_x15_r0_body.cobjsK142 PRE_first_tail_x15_r0_body.cnodesK142 PRE_first_tail_x15_r0_body.citemsK142 PRE_first_tail_x15_r0_body.cbd142 PRE_first_tail_x15_r0_body.cck142

end Host.Load.Run.Tpl
