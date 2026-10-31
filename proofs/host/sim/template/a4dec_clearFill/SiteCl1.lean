import host.sim.template.a4dec_clearFill.SiteK1
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearFill.ckA1 : (Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx.arrs (DEC_clearFill.clo1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearFill.cbd1 : (DEC_clearFill.clo1 ++ DEC_clearFill.cln1 ++ DEC_clearFill.cli1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.cle1 : Conv.Cnt.leB (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) = true
kernel_rfl DEC_clearFill.cck1 : Conv.ncleanListB (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx DEC_clearFill.clo1 DEC_clearFill.cln1 DEC_clearFill.cli1 = true
theorem DEC_clearFill.cncl1 (h : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s4.ffi).mlx) : Conv.NClean (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clearFill.cle1 DEC_clearFill.ckA1 DEC_clearFill.cobjsK1 DEC_clearFill.cnodesK1 DEC_clearFill.citemsK1 DEC_clearFill.cbd1 DEC_clearFill.cck1

end Host.Load.Run.Tpl
