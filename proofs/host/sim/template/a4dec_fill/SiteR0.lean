import host.sim.template.a4dec_fill.Site0
import host.sim.template.a4dec_fill.SiteS0
import host.sim.template.a4dec_fill.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 of chain `DEC_fill` from the call state's full relation: the call's bookkeeping (`DEC_fill.ncl0`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem DEC_fill.cshiftR0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M DEC_fill.S0.tab.length DEC_fill.s0.ffi y)
    (hNL : P.NL = DEC_fill.P0.NL) : Conv.FullShiftQ DEC_fill.P0 123 DEC_fill.kappa0 DEC_fill.s2.ffi DEC_fill.s1.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ DEC_fill.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ DEC_fill.okrC_0
  have hcl : SSt (· < 123) (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx :=
    sst_of_callK (n0 := DEC_fill.S0.tab.length) hr.cl (by rw [DEC_fill.n0_0] <;> decide) DEC_fill.cnodesK0 DEC_fill.cobjsK0
      DEC_fill.citemsK0 DEC_fill.cbd0 DEC_fill.csst0
  exact DEC_fill.cshift0 DEC_fill.ncl0 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => hNL ▸ hr.traced h o hg i hi) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [DEC_fill.n0_0] at this; exact this)

end Host.Load.Run.Tpl
