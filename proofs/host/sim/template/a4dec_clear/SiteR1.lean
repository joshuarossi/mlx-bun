import host.sim.template.a4dec_clear.Site1
import host.sim.template.a4dec_clear.SiteS1
import host.sim.template.a4dec_clear.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 1 of chain `DEC_clear` from the call state's full relation: the call's bookkeeping (`DEC_clear.ncl4`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_clear.cshiftR1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_clear.S4.tab.length DEC_clear.s4.ffi y)
    (hNL : P.NL = DEC_clear.P1.NL) : Conv.FullShiftQ DEC_clear.P1 353 DEC_clear.kappa1 DEC_clear.s6.ffi DEC_clear.s5.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_clear.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_clear.okrC_1
  have hcl : SSt (· < 353) (Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx :=
    sst_of_callK (n0 := DEC_clear.S4.tab.length) hr.cl (by rw [DEC_clear.n0_1] <;> decide) DEC_clear.cnodesK1 DEC_clear.cobjsK1
      DEC_clear.citemsK1 DEC_clear.cbd1 DEC_clear.csst1
  exact DEC_clear.cshift1 DEC_clear.ncl4 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_clear.n0_1] at this; exact this)

end Host.Load.Run.Tpl
