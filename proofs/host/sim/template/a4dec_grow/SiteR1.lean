import host.sim.template.a4dec_grow.Site1
import host.sim.template.a4dec_grow.SiteS1
import host.sim.template.a4dec_grow.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 1 of chain `DEC_grow` from the call state's full relation: the call's bookkeeping (`DEC_grow.ncl4`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_grow.cshiftR1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_grow.S4.tab.length DEC_grow.s4.ffi y)
    (hNL : P.NL = DEC_grow.P1.NL) : Conv.FullShiftQ DEC_grow.P1 385 DEC_grow.kappa1 DEC_grow.s6.ffi DEC_grow.s5.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_grow.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_grow.okrC_1
  have hcl : SSt (· < 385) (Host.Load.Layers.toLoad DEC_grow.s6.ffi).mlx :=
    sst_of_callK (n0 := DEC_grow.S4.tab.length) hr.cl (by rw [DEC_grow.n0_1] <;> decide) DEC_grow.cnodesK1 DEC_grow.cobjsK1
      DEC_grow.citemsK1 DEC_grow.cbd1 DEC_grow.csst1
  exact DEC_grow.cshift1 DEC_grow.ncl4 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_grow.n0_1] at this; exact this)

end Host.Load.Run.Tpl
