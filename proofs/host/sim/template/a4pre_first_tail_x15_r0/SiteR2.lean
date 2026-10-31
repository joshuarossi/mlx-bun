import host.sim.template.a4pre_first_tail_x15_r0.Site2
import host.sim.template.a4pre_first_tail_x15_r0.SiteS2
import host.sim.template.a4pre_first_tail_x15_r0.NClCall2
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 2 of chain `PRE_first_tail_x15_r0` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0.ncl38`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0.cshiftR2 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0.S38.tab.length PRE_first_tail_x15_r0.s38.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0.P2.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0.P2 18 PRE_first_tail_x15_r0.kappa2 PRE_first_tail_x15_r0.s40.ffi PRE_first_tail_x15_r0.s39.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0.ofxC_2
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0.okrC_2
  have hcl : SSt (· < 18) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0.S38.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0.n0_2] <;> decide) PRE_first_tail_x15_r0.cnodesK2 PRE_first_tail_x15_r0.cobjsK2
      PRE_first_tail_x15_r0.citemsK2 PRE_first_tail_x15_r0.cbd2 PRE_first_tail_x15_r0.csst2
  exact PRE_first_tail_x15_r0.cshift2 PRE_first_tail_x15_r0.ncl38 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0.n0_2] at this; exact this)

end Host.Load.Run.Tpl
