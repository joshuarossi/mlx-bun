import host.sim.template.a4dec_grow.Site0
import host.sim.template.a4dec_grow.SiteS0
import host.sim.template.a4dec_grow.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 of chain `DEC_grow` from the call state's full relation: the call's bookkeeping (`DEC_grow.ncl0`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_grow.cshiftR0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_grow.S0.tab.length DEC_grow.s0.ffi y)
    (hNL : P.NL = DEC_grow.P0.NL) : Conv.FullShiftQ DEC_grow.P0 123 DEC_grow.kappa0 DEC_grow.s2.ffi DEC_grow.s1.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_grow.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_grow.okrC_0
  have hcl : SSt (· < 123) (Host.Load.Layers.toLoad DEC_grow.s2.ffi).mlx :=
    sst_of_callK (n0 := DEC_grow.S0.tab.length) hr.cl (by rw [DEC_grow.n0_0] <;> decide) DEC_grow.cnodesK0 DEC_grow.cobjsK0
      DEC_grow.citemsK0 DEC_grow.cbd0 DEC_grow.csst0
  exact DEC_grow.cshift0 DEC_grow.ncl0 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_grow.n0_0] at this; exact this)

end Host.Load.Run.Tpl
