import host.sim.template.a4pre_first_tail_x15_r0_body.Site18
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteS18
import host.sim.template.a4pre_first_tail_x15_r0_body.NClAll
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 18 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl173`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR18 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S173.tab.length PRE_first_tail_x15_r0_body.s173.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P18.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P18 872 PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.s175.ffi PRE_first_tail_x15_r0_body.s174.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_18
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_18
  have hcl : SSt (· < 872) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s175.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S173.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_18] <;> decide) PRE_first_tail_x15_r0_body.cnodesK18 PRE_first_tail_x15_r0_body.cobjsK18
      PRE_first_tail_x15_r0_body.citemsK18 PRE_first_tail_x15_r0_body.cbd18 PRE_first_tail_x15_r0_body.csst18
  exact PRE_first_tail_x15_r0_body.cshift18 PRE_first_tail_x15_r0_body.ncl173 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_18] at this; exact this)

end Host.Load.Run.Tpl
