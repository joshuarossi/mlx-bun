import host.sim.template.a4dec_fill.Site2
import host.sim.template.a4dec_fill.SiteS2
import host.sim.template.a4dec_fill.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 2 of chain `DEC_fill` from the call state's full relation: the call's bookkeeping (`DEC_fill.ncl8`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_fill.cshiftR2 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_fill.S8.tab.length DEC_fill.s8.ffi y)
    (hNL : P.NL = DEC_fill.P2.NL) : Conv.FullShiftQ DEC_fill.P2 290 DEC_fill.kappa2 DEC_fill.s10.ffi DEC_fill.s9.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_fill.ofxC_2
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_fill.okrC_2
  have hcl : SSt (· < 290) (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx :=
    sst_of_callK (n0 := DEC_fill.S8.tab.length) hr.cl (by rw [DEC_fill.n0_2] <;> decide) DEC_fill.cnodesK2 DEC_fill.cobjsK2
      DEC_fill.citemsK2 DEC_fill.cbd2 DEC_fill.csst2
  exact DEC_fill.cshift2 DEC_fill.ncl8 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_fill.n0_2] at this; exact this)

end Host.Load.Run.Tpl
