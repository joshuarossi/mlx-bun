import host.sim.template.a4dec_clearFill.Site0
import host.sim.template.a4dec_clearFill.SiteS0
import host.sim.template.a4dec_clearFill.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 of chain `DEC_clearFill` from the call state's full relation: the call's bookkeeping (`DEC_clearFill.ncl0`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_clearFill.cshiftR0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_clearFill.S0.tab.length DEC_clearFill.s0.ffi y)
    (hNL : P.NL = DEC_clearFill.P0.NL) : Conv.FullShiftQ DEC_clearFill.P0 123 DEC_clearFill.kappa0 DEC_clearFill.s2.ffi DEC_clearFill.s1.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_clearFill.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_clearFill.okrC_0
  have hcl : SSt (· < 123) (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx :=
    sst_of_callK (n0 := DEC_clearFill.S0.tab.length) hr.cl (by rw [DEC_clearFill.n0_0] <;> decide) DEC_clearFill.cnodesK0 DEC_clearFill.cobjsK0
      DEC_clearFill.citemsK0 DEC_clearFill.cbd0 DEC_clearFill.csst0
  exact DEC_clearFill.cshift0 DEC_clearFill.ncl0 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_clearFill.n0_0] at this; exact this)

end Host.Load.Run.Tpl
