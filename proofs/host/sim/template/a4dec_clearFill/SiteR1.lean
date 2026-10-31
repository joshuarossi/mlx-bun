import host.sim.template.a4dec_clearFill.Site1
import host.sim.template.a4dec_clearFill.SiteS1
import host.sim.template.a4dec_clearFill.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 1 of chain `DEC_clearFill` from the call state's full relation: the call's bookkeeping (`DEC_clearFill.ncl4`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_clearFill.cshiftR1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_clearFill.S4.tab.length DEC_clearFill.s4.ffi y)
    (hNL : P.NL = DEC_clearFill.P1.NL) : Conv.FullShiftQ DEC_clearFill.P1 289 DEC_clearFill.kappa1 DEC_clearFill.s6.ffi DEC_clearFill.s5.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_clearFill.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_clearFill.okrC_1
  have hcl : SSt (· < 289) (Host.Load.Layers.toLoad DEC_clearFill.s6.ffi).mlx :=
    sst_of_callK (n0 := DEC_clearFill.S4.tab.length) hr.cl (by rw [DEC_clearFill.n0_1] <;> decide) DEC_clearFill.cnodesK1 DEC_clearFill.cobjsK1
      DEC_clearFill.citemsK1 DEC_clearFill.cbd1 DEC_clearFill.csst1
  exact DEC_clearFill.cshift1 DEC_clearFill.ncl4 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_clearFill.n0_1] at this; exact this)

end Host.Load.Run.Tpl
