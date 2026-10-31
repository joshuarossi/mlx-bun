import host.sim.template.a4pre_first_tail_x15_r0_body.Site179
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS179
import host.sim.template.a4pre_first_tail_x15_r0_body.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 179 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1573`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR179 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1573.tab.length PRE_first_tail_x15_r0_body.s1573.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P179.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P179 7705 PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.s1575.ffi PRE_first_tail_x15_r0_body.s1574.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_179
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_179
  have hcl : SSt (· < 7705) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1573.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_179] <;> decide) PRE_first_tail_x15_r0_body.cnodesK179 PRE_first_tail_x15_r0_body.cobjsK179
      PRE_first_tail_x15_r0_body.citemsK179 PRE_first_tail_x15_r0_body.cbd179 PRE_first_tail_x15_r0_body.csst179
  exact PRE_first_tail_x15_r0_body.cshift179 PRE_first_tail_x15_r0_body.ncl1573 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_179] at this; exact this)

end Host.Load.Run.Tpl
