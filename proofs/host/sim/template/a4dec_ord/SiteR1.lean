import host.sim.template.a4dec_ord.Site1
import host.sim.template.a4dec_ord.SiteS1
import host.sim.template.a4dec_ord.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 1 of chain `DEC_ord` from the call state's full relation: the call's bookkeeping (`DEC_ord.ncl4`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_ord.cshiftR1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_ord.S4.tab.length DEC_ord.s4.ffi y)
    (hNL : P.NL = DEC_ord.P1.NL) : Conv.FullShiftQ DEC_ord.P1 353 DEC_ord.kappa1 DEC_ord.s6.ffi DEC_ord.s5.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_ord.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_ord.okrC_1
  have hcl : SSt (· < 353) (Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx :=
    sst_of_callK (n0 := DEC_ord.S4.tab.length) hr.cl (by rw [DEC_ord.n0_1] <;> decide) DEC_ord.cnodesK1 DEC_ord.cobjsK1
      DEC_ord.citemsK1 DEC_ord.cbd1 DEC_ord.csst1
  exact DEC_ord.cshift1 DEC_ord.ncl4 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_ord.n0_1] at this; exact this)

end Host.Load.Run.Tpl
