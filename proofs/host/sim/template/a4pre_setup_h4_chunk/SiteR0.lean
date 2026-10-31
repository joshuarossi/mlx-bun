import host.sim.template.a4pre_setup_h4_chunk.Site0
import host.sim.template.a4pre_setup_h4_chunk.SiteS0
import host.sim.template.a4pre_setup_h4_chunk.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 of chain `PRE_setup_h4_chunk` from the call state's full relation: the call's bookkeeping (`PRE_setup_h4_chunk.ncl0`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_setup_h4_chunk.cshiftR0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_setup_h4_chunk.S0.tab.length PRE_setup_h4_chunk.s0.ffi y)
    (hNL : P.NL ≤ PRE_setup_h4_chunk.P0.NL) : Conv.FullShiftQ PRE_setup_h4_chunk.P0 10 PRE_setup_h4_chunk.kappa0 PRE_setup_h4_chunk.s2.ffi PRE_setup_h4_chunk.s1.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_setup_h4_chunk.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_setup_h4_chunk.okrC_0
  have hcl : SSt (· < 10) (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s2.ffi).mlx :=
    sst_of_callK (n0 := PRE_setup_h4_chunk.S0.tab.length) hr.cl (by rw [PRE_setup_h4_chunk.n0_0] <;> decide) PRE_setup_h4_chunk.cnodesK0 PRE_setup_h4_chunk.cobjsK0
      PRE_setup_h4_chunk.citemsK0 PRE_setup_h4_chunk.cbd0 PRE_setup_h4_chunk.csst0
  exact PRE_setup_h4_chunk.cshift0 PRE_setup_h4_chunk.ncl0 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_setup_h4_chunk.n0_0] at this; exact this)

end Host.Load.Run.Tpl
