import host.sim.template.a4dec_clearFill.Site2
import host.sim.template.a4dec_clearFill.SiteS2
import host.sim.template.a4dec_clearFill.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 2 of chain `DEC_clearFill` from the call state's full relation: the call's bookkeeping (`DEC_clearFill.ncl8`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_clearFill.cshiftR2 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_clearFill.S8.tab.length DEC_clearFill.s8.ffi y)
    (hNL : P.NL = DEC_clearFill.P2.NL) : Conv.FullShiftQ DEC_clearFill.P2 290 DEC_clearFill.kappa2 DEC_clearFill.s10.ffi DEC_clearFill.s9.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_clearFill.ofxC_2
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_clearFill.okrC_2
  have hcl : SSt (· < 290) (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx :=
    sst_of_callK (n0 := DEC_clearFill.S8.tab.length) hr.cl (by rw [DEC_clearFill.n0_2] <;> decide) DEC_clearFill.cnodesK2 DEC_clearFill.cobjsK2
      DEC_clearFill.citemsK2 DEC_clearFill.cbd2 DEC_clearFill.csst2
  exact DEC_clearFill.cshift2 DEC_clearFill.ncl8 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_clearFill.n0_2] at this; exact this)

end Host.Load.Run.Tpl
