import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.CallGen
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33

section -- SiteR0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 0 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl15`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR0 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S15.tab.length PRE_first_tail_x15_r0_body.s15.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P0.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P0 101 PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.s17.ffi PRE_first_tail_x15_r0_body.s16.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_0
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_0
  have hcl : SSt (· < 101) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S15.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_0] <;> decide) PRE_first_tail_x15_r0_body.cnodesK0 PRE_first_tail_x15_r0_body.cobjsK0
      PRE_first_tail_x15_r0_body.citemsK0 PRE_first_tail_x15_r0_body.cbd0 PRE_first_tail_x15_r0_body.csst0
  exact PRE_first_tail_x15_r0_body.cshift0 PRE_first_tail_x15_r0_body.ncl15 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_0] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 1 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl24`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S24.tab.length PRE_first_tail_x15_r0_body.s24.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P1.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P1 122 PRE_first_tail_x15_r0_body.kappa1 PRE_first_tail_x15_r0_body.s26.ffi PRE_first_tail_x15_r0_body.s25.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_1
  have hcl : SSt (· < 122) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S24.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_1] <;> decide) PRE_first_tail_x15_r0_body.cnodesK1 PRE_first_tail_x15_r0_body.cobjsK1
      PRE_first_tail_x15_r0_body.citemsK1 PRE_first_tail_x15_r0_body.cbd1 PRE_first_tail_x15_r0_body.csst1
  exact PRE_first_tail_x15_r0_body.cshift1 PRE_first_tail_x15_r0_body.ncl24 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_1] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 2 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl28`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR2 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S28.tab.length PRE_first_tail_x15_r0_body.s28.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P2.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P2 139 PRE_first_tail_x15_r0_body.kappa2 PRE_first_tail_x15_r0_body.s30.ffi PRE_first_tail_x15_r0_body.s29.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_2
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_2
  have hcl : SSt (· < 139) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s30.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S28.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_2] <;> decide) PRE_first_tail_x15_r0_body.cnodesK2 PRE_first_tail_x15_r0_body.cobjsK2
      PRE_first_tail_x15_r0_body.citemsK2 PRE_first_tail_x15_r0_body.cbd2 PRE_first_tail_x15_r0_body.csst2
  exact PRE_first_tail_x15_r0_body.cshift2 PRE_first_tail_x15_r0_body.ncl28 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_2] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 3 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl45`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR3 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S45.tab.length PRE_first_tail_x15_r0_body.s45.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P3.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P3 230 PRE_first_tail_x15_r0_body.kappa3 PRE_first_tail_x15_r0_body.s47.ffi PRE_first_tail_x15_r0_body.s46.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_3
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_3
  have hcl : SSt (· < 230) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S45.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_3] <;> decide) PRE_first_tail_x15_r0_body.cnodesK3 PRE_first_tail_x15_r0_body.cobjsK3
      PRE_first_tail_x15_r0_body.citemsK3 PRE_first_tail_x15_r0_body.cbd3 PRE_first_tail_x15_r0_body.csst3
  exact PRE_first_tail_x15_r0_body.cshift3 PRE_first_tail_x15_r0_body.ncl45 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_3] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR4
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 4 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl53`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR4 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S53.tab.length PRE_first_tail_x15_r0_body.s53.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P4.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P4 251 PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.s55.ffi PRE_first_tail_x15_r0_body.s54.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_4
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_4
  have hcl : SSt (· < 251) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s55.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S53.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_4] <;> decide) PRE_first_tail_x15_r0_body.cnodesK4 PRE_first_tail_x15_r0_body.cobjsK4
      PRE_first_tail_x15_r0_body.citemsK4 PRE_first_tail_x15_r0_body.cbd4 PRE_first_tail_x15_r0_body.csst4
  exact PRE_first_tail_x15_r0_body.cshift4 PRE_first_tail_x15_r0_body.ncl53 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_4] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR5
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 5 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl57`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR5 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S57.tab.length PRE_first_tail_x15_r0_body.s57.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P5.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P5 268 PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.s59.ffi PRE_first_tail_x15_r0_body.s58.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_5
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_5
  have hcl : SSt (· < 268) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S57.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_5] <;> decide) PRE_first_tail_x15_r0_body.cnodesK5 PRE_first_tail_x15_r0_body.cobjsK5
      PRE_first_tail_x15_r0_body.citemsK5 PRE_first_tail_x15_r0_body.cbd5 PRE_first_tail_x15_r0_body.csst5
  exact PRE_first_tail_x15_r0_body.cshift5 PRE_first_tail_x15_r0_body.ncl57 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_5] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR6
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 6 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl74`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR6 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S74.tab.length PRE_first_tail_x15_r0_body.s74.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P6.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P6 359 PRE_first_tail_x15_r0_body.kappa6 PRE_first_tail_x15_r0_body.s76.ffi PRE_first_tail_x15_r0_body.s75.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_6
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_6
  have hcl : SSt (· < 359) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S74.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_6] <;> decide) PRE_first_tail_x15_r0_body.cnodesK6 PRE_first_tail_x15_r0_body.cobjsK6
      PRE_first_tail_x15_r0_body.citemsK6 PRE_first_tail_x15_r0_body.cbd6 PRE_first_tail_x15_r0_body.csst6
  exact PRE_first_tail_x15_r0_body.cshift6 PRE_first_tail_x15_r0_body.ncl74 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_6] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 7 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl82`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR7 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S82.tab.length PRE_first_tail_x15_r0_body.s82.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P7.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P7 380 PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.s84.ffi PRE_first_tail_x15_r0_body.s83.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_7
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_7
  have hcl : SSt (· < 380) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S82.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_7] <;> decide) PRE_first_tail_x15_r0_body.cnodesK7 PRE_first_tail_x15_r0_body.cobjsK7
      PRE_first_tail_x15_r0_body.citemsK7 PRE_first_tail_x15_r0_body.cbd7 PRE_first_tail_x15_r0_body.csst7
  exact PRE_first_tail_x15_r0_body.cshift7 PRE_first_tail_x15_r0_body.ncl82 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_7] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR8
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 8 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl86`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR8 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S86.tab.length PRE_first_tail_x15_r0_body.s86.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P8.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P8 397 PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.s88.ffi PRE_first_tail_x15_r0_body.s87.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_8
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_8
  have hcl : SSt (· < 397) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s88.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S86.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_8] <;> decide) PRE_first_tail_x15_r0_body.cnodesK8 PRE_first_tail_x15_r0_body.cobjsK8
      PRE_first_tail_x15_r0_body.citemsK8 PRE_first_tail_x15_r0_body.cbd8 PRE_first_tail_x15_r0_body.csst8
  exact PRE_first_tail_x15_r0_body.cshift8 PRE_first_tail_x15_r0_body.ncl86 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_8] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR9
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 9 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl102`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR9 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S102.tab.length PRE_first_tail_x15_r0_body.s102.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P9.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P9 483 PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.s104.ffi PRE_first_tail_x15_r0_body.s103.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_9
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_9
  have hcl : SSt (· < 483) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S102.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_9] <;> decide) PRE_first_tail_x15_r0_body.cnodesK9 PRE_first_tail_x15_r0_body.cobjsK9
      PRE_first_tail_x15_r0_body.citemsK9 PRE_first_tail_x15_r0_body.cbd9 PRE_first_tail_x15_r0_body.csst9
  exact PRE_first_tail_x15_r0_body.cshift9 PRE_first_tail_x15_r0_body.ncl102 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_9] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR10
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 10 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl110`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR10 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S110.tab.length PRE_first_tail_x15_r0_body.s110.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P10.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P10 506 PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.s112.ffi PRE_first_tail_x15_r0_body.s111.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_10
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_10
  have hcl : SSt (· < 506) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S110.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_10] <;> decide) PRE_first_tail_x15_r0_body.cnodesK10 PRE_first_tail_x15_r0_body.cobjsK10
      PRE_first_tail_x15_r0_body.citemsK10 PRE_first_tail_x15_r0_body.cbd10 PRE_first_tail_x15_r0_body.csst10
  exact PRE_first_tail_x15_r0_body.cshift10 PRE_first_tail_x15_r0_body.ncl110 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_10] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR11
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 11 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl114`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR11 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S114.tab.length PRE_first_tail_x15_r0_body.s114.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P11.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P11 523 PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.s116.ffi PRE_first_tail_x15_r0_body.s115.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_11
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_11
  have hcl : SSt (· < 523) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S114.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_11] <;> decide) PRE_first_tail_x15_r0_body.cnodesK11 PRE_first_tail_x15_r0_body.cobjsK11
      PRE_first_tail_x15_r0_body.citemsK11 PRE_first_tail_x15_r0_body.cbd11 PRE_first_tail_x15_r0_body.csst11
  exact PRE_first_tail_x15_r0_body.cshift11 PRE_first_tail_x15_r0_body.ncl114 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_11] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR12
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 12 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl131`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR12 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S131.tab.length PRE_first_tail_x15_r0_body.s131.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P12.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P12 614 PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.s133.ffi PRE_first_tail_x15_r0_body.s132.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_12
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_12
  have hcl : SSt (· < 614) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s133.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S131.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_12] <;> decide) PRE_first_tail_x15_r0_body.cnodesK12 PRE_first_tail_x15_r0_body.cobjsK12
      PRE_first_tail_x15_r0_body.citemsK12 PRE_first_tail_x15_r0_body.cbd12 PRE_first_tail_x15_r0_body.csst12
  exact PRE_first_tail_x15_r0_body.cshift12 PRE_first_tail_x15_r0_body.ncl131 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_12] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR13
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 13 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl139`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR13 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S139.tab.length PRE_first_tail_x15_r0_body.s139.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P13.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P13 635 PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.s141.ffi PRE_first_tail_x15_r0_body.s140.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_13
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_13
  have hcl : SSt (· < 635) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S139.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_13] <;> decide) PRE_first_tail_x15_r0_body.cnodesK13 PRE_first_tail_x15_r0_body.cobjsK13
      PRE_first_tail_x15_r0_body.citemsK13 PRE_first_tail_x15_r0_body.cbd13 PRE_first_tail_x15_r0_body.csst13
  exact PRE_first_tail_x15_r0_body.cshift13 PRE_first_tail_x15_r0_body.ncl139 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_13] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR14
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 14 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl143`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR14 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S143.tab.length PRE_first_tail_x15_r0_body.s143.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P14.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P14 652 PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.s145.ffi PRE_first_tail_x15_r0_body.s144.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_14
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_14
  have hcl : SSt (· < 652) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S143.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_14] <;> decide) PRE_first_tail_x15_r0_body.cnodesK14 PRE_first_tail_x15_r0_body.cobjsK14
      PRE_first_tail_x15_r0_body.citemsK14 PRE_first_tail_x15_r0_body.cbd14 PRE_first_tail_x15_r0_body.csst14
  exact PRE_first_tail_x15_r0_body.cshift14 PRE_first_tail_x15_r0_body.ncl143 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_14] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR15
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 15 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl160`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR15 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S160.tab.length PRE_first_tail_x15_r0_body.s160.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P15.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P15 743 PRE_first_tail_x15_r0_body.kappa15 PRE_first_tail_x15_r0_body.s162.ffi PRE_first_tail_x15_r0_body.s161.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_15
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_15
  have hcl : SSt (· < 743) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s162.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S160.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_15] <;> decide) PRE_first_tail_x15_r0_body.cnodesK15 PRE_first_tail_x15_r0_body.cobjsK15
      PRE_first_tail_x15_r0_body.citemsK15 PRE_first_tail_x15_r0_body.cbd15 PRE_first_tail_x15_r0_body.csst15
  exact PRE_first_tail_x15_r0_body.cshift15 PRE_first_tail_x15_r0_body.ncl160 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_15] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR16
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 16 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl168`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR16 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S168.tab.length PRE_first_tail_x15_r0_body.s168.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P16.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P16 764 PRE_first_tail_x15_r0_body.kappa16 PRE_first_tail_x15_r0_body.s170.ffi PRE_first_tail_x15_r0_body.s169.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_16
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_16
  have hcl : SSt (· < 764) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S168.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_16] <;> decide) PRE_first_tail_x15_r0_body.cnodesK16 PRE_first_tail_x15_r0_body.cobjsK16
      PRE_first_tail_x15_r0_body.citemsK16 PRE_first_tail_x15_r0_body.cbd16 PRE_first_tail_x15_r0_body.csst16
  exact PRE_first_tail_x15_r0_body.cshift16 PRE_first_tail_x15_r0_body.ncl168 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_16] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 17 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl172`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR17 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S172.tab.length PRE_first_tail_x15_r0_body.s172.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P17.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P17 781 PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.s174.ffi PRE_first_tail_x15_r0_body.s173.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_17
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_17
  have hcl : SSt (· < 781) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S172.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_17] <;> decide) PRE_first_tail_x15_r0_body.cnodesK17 PRE_first_tail_x15_r0_body.cobjsK17
      PRE_first_tail_x15_r0_body.citemsK17 PRE_first_tail_x15_r0_body.cbd17 PRE_first_tail_x15_r0_body.csst17
  exact PRE_first_tail_x15_r0_body.cshift17 PRE_first_tail_x15_r0_body.ncl172 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_17] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 18 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl189`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR18 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S189.tab.length PRE_first_tail_x15_r0_body.s189.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P18.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P18 872 PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.s191.ffi PRE_first_tail_x15_r0_body.s190.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_18
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_18
  have hcl : SSt (· < 872) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S189.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_18] <;> decide) PRE_first_tail_x15_r0_body.cnodesK18 PRE_first_tail_x15_r0_body.cobjsK18
      PRE_first_tail_x15_r0_body.citemsK18 PRE_first_tail_x15_r0_body.cbd18 PRE_first_tail_x15_r0_body.csst18
  exact PRE_first_tail_x15_r0_body.cshift18 PRE_first_tail_x15_r0_body.ncl189 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_18] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR19
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 19 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl197`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR19 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S197.tab.length PRE_first_tail_x15_r0_body.s197.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P19.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P19 893 PRE_first_tail_x15_r0_body.kappa19 PRE_first_tail_x15_r0_body.s199.ffi PRE_first_tail_x15_r0_body.s198.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_19
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_19
  have hcl : SSt (· < 893) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S197.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_19] <;> decide) PRE_first_tail_x15_r0_body.cnodesK19 PRE_first_tail_x15_r0_body.cobjsK19
      PRE_first_tail_x15_r0_body.citemsK19 PRE_first_tail_x15_r0_body.cbd19 PRE_first_tail_x15_r0_body.csst19
  exact PRE_first_tail_x15_r0_body.cshift19 PRE_first_tail_x15_r0_body.ncl197 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_19] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR20
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 20 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl201`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR20 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S201.tab.length PRE_first_tail_x15_r0_body.s201.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P20.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P20 910 PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.s203.ffi PRE_first_tail_x15_r0_body.s202.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_20
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_20
  have hcl : SSt (· < 910) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S201.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_20] <;> decide) PRE_first_tail_x15_r0_body.cnodesK20 PRE_first_tail_x15_r0_body.cobjsK20
      PRE_first_tail_x15_r0_body.citemsK20 PRE_first_tail_x15_r0_body.cbd20 PRE_first_tail_x15_r0_body.csst20
  exact PRE_first_tail_x15_r0_body.cshift20 PRE_first_tail_x15_r0_body.ncl201 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_20] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR21
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 21 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl217`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR21 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S217.tab.length PRE_first_tail_x15_r0_body.s217.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P21.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P21 996 PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.s219.ffi PRE_first_tail_x15_r0_body.s218.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_21
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_21
  have hcl : SSt (· < 996) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S217.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_21] <;> decide) PRE_first_tail_x15_r0_body.cnodesK21 PRE_first_tail_x15_r0_body.cobjsK21
      PRE_first_tail_x15_r0_body.citemsK21 PRE_first_tail_x15_r0_body.cbd21 PRE_first_tail_x15_r0_body.csst21
  exact PRE_first_tail_x15_r0_body.cshift21 PRE_first_tail_x15_r0_body.ncl217 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_21] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR22
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 22 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl225`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR22 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S225.tab.length PRE_first_tail_x15_r0_body.s225.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P22.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P22 1019 PRE_first_tail_x15_r0_body.kappa22 PRE_first_tail_x15_r0_body.s227.ffi PRE_first_tail_x15_r0_body.s226.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_22
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_22
  have hcl : SSt (· < 1019) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s227.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S225.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_22] <;> decide) PRE_first_tail_x15_r0_body.cnodesK22 PRE_first_tail_x15_r0_body.cobjsK22
      PRE_first_tail_x15_r0_body.citemsK22 PRE_first_tail_x15_r0_body.cbd22 PRE_first_tail_x15_r0_body.csst22
  exact PRE_first_tail_x15_r0_body.cshift22 PRE_first_tail_x15_r0_body.ncl225 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_22] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR23
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 23 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl229`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR23 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S229.tab.length PRE_first_tail_x15_r0_body.s229.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P23.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P23 1036 PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.s231.ffi PRE_first_tail_x15_r0_body.s230.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_23
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_23
  have hcl : SSt (· < 1036) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S229.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_23] <;> decide) PRE_first_tail_x15_r0_body.cnodesK23 PRE_first_tail_x15_r0_body.cobjsK23
      PRE_first_tail_x15_r0_body.citemsK23 PRE_first_tail_x15_r0_body.cbd23 PRE_first_tail_x15_r0_body.csst23
  exact PRE_first_tail_x15_r0_body.cshift23 PRE_first_tail_x15_r0_body.ncl229 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_23] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR24
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 24 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl246`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR24 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S246.tab.length PRE_first_tail_x15_r0_body.s246.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P24.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P24 1127 PRE_first_tail_x15_r0_body.kappa24 PRE_first_tail_x15_r0_body.s248.ffi PRE_first_tail_x15_r0_body.s247.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_24
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_24
  have hcl : SSt (· < 1127) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S246.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_24] <;> decide) PRE_first_tail_x15_r0_body.cnodesK24 PRE_first_tail_x15_r0_body.cobjsK24
      PRE_first_tail_x15_r0_body.citemsK24 PRE_first_tail_x15_r0_body.cbd24 PRE_first_tail_x15_r0_body.csst24
  exact PRE_first_tail_x15_r0_body.cshift24 PRE_first_tail_x15_r0_body.ncl246 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_24] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR25
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 25 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl254`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR25 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S254.tab.length PRE_first_tail_x15_r0_body.s254.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P25.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P25 1148 PRE_first_tail_x15_r0_body.kappa25 PRE_first_tail_x15_r0_body.s256.ffi PRE_first_tail_x15_r0_body.s255.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_25
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_25
  have hcl : SSt (· < 1148) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S254.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_25] <;> decide) PRE_first_tail_x15_r0_body.cnodesK25 PRE_first_tail_x15_r0_body.cobjsK25
      PRE_first_tail_x15_r0_body.citemsK25 PRE_first_tail_x15_r0_body.cbd25 PRE_first_tail_x15_r0_body.csst25
  exact PRE_first_tail_x15_r0_body.cshift25 PRE_first_tail_x15_r0_body.ncl254 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_25] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR26
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 26 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl258`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR26 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S258.tab.length PRE_first_tail_x15_r0_body.s258.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P26.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P26 1165 PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.s260.ffi PRE_first_tail_x15_r0_body.s259.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_26
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_26
  have hcl : SSt (· < 1165) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S258.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_26] <;> decide) PRE_first_tail_x15_r0_body.cnodesK26 PRE_first_tail_x15_r0_body.cobjsK26
      PRE_first_tail_x15_r0_body.citemsK26 PRE_first_tail_x15_r0_body.cbd26 PRE_first_tail_x15_r0_body.csst26
  exact PRE_first_tail_x15_r0_body.cshift26 PRE_first_tail_x15_r0_body.ncl258 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_26] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR27
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 27 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl275`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR27 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S275.tab.length PRE_first_tail_x15_r0_body.s275.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P27.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P27 1256 PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.s277.ffi PRE_first_tail_x15_r0_body.s276.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_27
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_27
  have hcl : SSt (· < 1256) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S275.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_27] <;> decide) PRE_first_tail_x15_r0_body.cnodesK27 PRE_first_tail_x15_r0_body.cobjsK27
      PRE_first_tail_x15_r0_body.citemsK27 PRE_first_tail_x15_r0_body.cbd27 PRE_first_tail_x15_r0_body.csst27
  exact PRE_first_tail_x15_r0_body.cshift27 PRE_first_tail_x15_r0_body.ncl275 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_27] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR28
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 28 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl283`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR28 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S283.tab.length PRE_first_tail_x15_r0_body.s283.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P28.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P28 1277 PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.s285.ffi PRE_first_tail_x15_r0_body.s284.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_28
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_28
  have hcl : SSt (· < 1277) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S283.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_28] <;> decide) PRE_first_tail_x15_r0_body.cnodesK28 PRE_first_tail_x15_r0_body.cobjsK28
      PRE_first_tail_x15_r0_body.citemsK28 PRE_first_tail_x15_r0_body.cbd28 PRE_first_tail_x15_r0_body.csst28
  exact PRE_first_tail_x15_r0_body.cshift28 PRE_first_tail_x15_r0_body.ncl283 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_28] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR29
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 29 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl287`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR29 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S287.tab.length PRE_first_tail_x15_r0_body.s287.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P29.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P29 1294 PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.s289.ffi PRE_first_tail_x15_r0_body.s288.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_29
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_29
  have hcl : SSt (· < 1294) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S287.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_29] <;> decide) PRE_first_tail_x15_r0_body.cnodesK29 PRE_first_tail_x15_r0_body.cobjsK29
      PRE_first_tail_x15_r0_body.citemsK29 PRE_first_tail_x15_r0_body.cbd29 PRE_first_tail_x15_r0_body.csst29
  exact PRE_first_tail_x15_r0_body.cshift29 PRE_first_tail_x15_r0_body.ncl287 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_29] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR30
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 30 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl304`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR30 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S304.tab.length PRE_first_tail_x15_r0_body.s304.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P30.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P30 1385 PRE_first_tail_x15_r0_body.kappa30 PRE_first_tail_x15_r0_body.s306.ffi PRE_first_tail_x15_r0_body.s305.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_30
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_30
  have hcl : SSt (· < 1385) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S304.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_30] <;> decide) PRE_first_tail_x15_r0_body.cnodesK30 PRE_first_tail_x15_r0_body.cobjsK30
      PRE_first_tail_x15_r0_body.citemsK30 PRE_first_tail_x15_r0_body.cbd30 PRE_first_tail_x15_r0_body.csst30
  exact PRE_first_tail_x15_r0_body.cshift30 PRE_first_tail_x15_r0_body.ncl304 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_30] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR31
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 31 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl312`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR31 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S312.tab.length PRE_first_tail_x15_r0_body.s312.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P31.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P31 1406 PRE_first_tail_x15_r0_body.kappa31 PRE_first_tail_x15_r0_body.s314.ffi PRE_first_tail_x15_r0_body.s313.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_31
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_31
  have hcl : SSt (· < 1406) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s314.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S312.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_31] <;> decide) PRE_first_tail_x15_r0_body.cnodesK31 PRE_first_tail_x15_r0_body.cobjsK31
      PRE_first_tail_x15_r0_body.citemsK31 PRE_first_tail_x15_r0_body.cbd31 PRE_first_tail_x15_r0_body.csst31
  exact PRE_first_tail_x15_r0_body.cshift31 PRE_first_tail_x15_r0_body.ncl312 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_31] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR32
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 32 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl316`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR32 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S316.tab.length PRE_first_tail_x15_r0_body.s316.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P32.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P32 1423 PRE_first_tail_x15_r0_body.kappa32 PRE_first_tail_x15_r0_body.s318.ffi PRE_first_tail_x15_r0_body.s317.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_32
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_32
  have hcl : SSt (· < 1423) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S316.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_32] <;> decide) PRE_first_tail_x15_r0_body.cnodesK32 PRE_first_tail_x15_r0_body.cobjsK32
      PRE_first_tail_x15_r0_body.citemsK32 PRE_first_tail_x15_r0_body.cbd32 PRE_first_tail_x15_r0_body.csst32
  exact PRE_first_tail_x15_r0_body.cshift32 PRE_first_tail_x15_r0_body.ncl316 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_32] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR33
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 33 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl332`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR33 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S332.tab.length PRE_first_tail_x15_r0_body.s332.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P33.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P33 1509 PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.s334.ffi PRE_first_tail_x15_r0_body.s333.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_33
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_33
  have hcl : SSt (· < 1509) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s334.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S332.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_33] <;> decide) PRE_first_tail_x15_r0_body.cnodesK33 PRE_first_tail_x15_r0_body.cobjsK33
      PRE_first_tail_x15_r0_body.citemsK33 PRE_first_tail_x15_r0_body.cbd33 PRE_first_tail_x15_r0_body.csst33
  exact PRE_first_tail_x15_r0_body.cshift33 PRE_first_tail_x15_r0_body.ncl332 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_33] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR34
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 34 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl340`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR34 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S340.tab.length PRE_first_tail_x15_r0_body.s340.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P34.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P34 1532 PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.s342.ffi PRE_first_tail_x15_r0_body.s341.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_34
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_34
  have hcl : SSt (· < 1532) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S340.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_34] <;> decide) PRE_first_tail_x15_r0_body.cnodesK34 PRE_first_tail_x15_r0_body.cobjsK34
      PRE_first_tail_x15_r0_body.citemsK34 PRE_first_tail_x15_r0_body.cbd34 PRE_first_tail_x15_r0_body.csst34
  exact PRE_first_tail_x15_r0_body.cshift34 PRE_first_tail_x15_r0_body.ncl340 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_34] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR35
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 35 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl344`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR35 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S344.tab.length PRE_first_tail_x15_r0_body.s344.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P35.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P35 1549 PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.s346.ffi PRE_first_tail_x15_r0_body.s345.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_35
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_35
  have hcl : SSt (· < 1549) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S344.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_35] <;> decide) PRE_first_tail_x15_r0_body.cnodesK35 PRE_first_tail_x15_r0_body.cobjsK35
      PRE_first_tail_x15_r0_body.citemsK35 PRE_first_tail_x15_r0_body.cbd35 PRE_first_tail_x15_r0_body.csst35
  exact PRE_first_tail_x15_r0_body.cshift35 PRE_first_tail_x15_r0_body.ncl344 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_35] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR36
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 36 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl361`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR36 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S361.tab.length PRE_first_tail_x15_r0_body.s361.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P36.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P36 1640 PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.s363.ffi PRE_first_tail_x15_r0_body.s362.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_36
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_36
  have hcl : SSt (· < 1640) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S361.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_36] <;> decide) PRE_first_tail_x15_r0_body.cnodesK36 PRE_first_tail_x15_r0_body.cobjsK36
      PRE_first_tail_x15_r0_body.citemsK36 PRE_first_tail_x15_r0_body.cbd36 PRE_first_tail_x15_r0_body.csst36
  exact PRE_first_tail_x15_r0_body.cshift36 PRE_first_tail_x15_r0_body.ncl361 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_36] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR37
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 37 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl369`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR37 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S369.tab.length PRE_first_tail_x15_r0_body.s369.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P37.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P37 1661 PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.s371.ffi PRE_first_tail_x15_r0_body.s370.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_37
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_37
  have hcl : SSt (· < 1661) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S369.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_37] <;> decide) PRE_first_tail_x15_r0_body.cnodesK37 PRE_first_tail_x15_r0_body.cobjsK37
      PRE_first_tail_x15_r0_body.citemsK37 PRE_first_tail_x15_r0_body.cbd37 PRE_first_tail_x15_r0_body.csst37
  exact PRE_first_tail_x15_r0_body.cshift37 PRE_first_tail_x15_r0_body.ncl369 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_37] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR38
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 38 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl373`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR38 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S373.tab.length PRE_first_tail_x15_r0_body.s373.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P38.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P38 1678 PRE_first_tail_x15_r0_body.kappa38 PRE_first_tail_x15_r0_body.s375.ffi PRE_first_tail_x15_r0_body.s374.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_38
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_38
  have hcl : SSt (· < 1678) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S373.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_38] <;> decide) PRE_first_tail_x15_r0_body.cnodesK38 PRE_first_tail_x15_r0_body.cobjsK38
      PRE_first_tail_x15_r0_body.citemsK38 PRE_first_tail_x15_r0_body.cbd38 PRE_first_tail_x15_r0_body.csst38
  exact PRE_first_tail_x15_r0_body.cshift38 PRE_first_tail_x15_r0_body.ncl373 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_38] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR39
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 39 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl390`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR39 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S390.tab.length PRE_first_tail_x15_r0_body.s390.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P39.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P39 1769 PRE_first_tail_x15_r0_body.kappa39 PRE_first_tail_x15_r0_body.s392.ffi PRE_first_tail_x15_r0_body.s391.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_39
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_39
  have hcl : SSt (· < 1769) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S390.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_39] <;> decide) PRE_first_tail_x15_r0_body.cnodesK39 PRE_first_tail_x15_r0_body.cobjsK39
      PRE_first_tail_x15_r0_body.citemsK39 PRE_first_tail_x15_r0_body.cbd39 PRE_first_tail_x15_r0_body.csst39
  exact PRE_first_tail_x15_r0_body.cshift39 PRE_first_tail_x15_r0_body.ncl390 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_39] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR40
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 40 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl398`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR40 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S398.tab.length PRE_first_tail_x15_r0_body.s398.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P40.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P40 1790 PRE_first_tail_x15_r0_body.kappa40 PRE_first_tail_x15_r0_body.s400.ffi PRE_first_tail_x15_r0_body.s399.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_40
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_40
  have hcl : SSt (· < 1790) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s400.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S398.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_40] <;> decide) PRE_first_tail_x15_r0_body.cnodesK40 PRE_first_tail_x15_r0_body.cobjsK40
      PRE_first_tail_x15_r0_body.citemsK40 PRE_first_tail_x15_r0_body.cbd40 PRE_first_tail_x15_r0_body.csst40
  exact PRE_first_tail_x15_r0_body.cshift40 PRE_first_tail_x15_r0_body.ncl398 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_40] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR41
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 41 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl402`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR41 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S402.tab.length PRE_first_tail_x15_r0_body.s402.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P41.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P41 1807 PRE_first_tail_x15_r0_body.kappa41 PRE_first_tail_x15_r0_body.s404.ffi PRE_first_tail_x15_r0_body.s403.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_41
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_41
  have hcl : SSt (· < 1807) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S402.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_41] <;> decide) PRE_first_tail_x15_r0_body.cnodesK41 PRE_first_tail_x15_r0_body.cobjsK41
      PRE_first_tail_x15_r0_body.citemsK41 PRE_first_tail_x15_r0_body.cbd41 PRE_first_tail_x15_r0_body.csst41
  exact PRE_first_tail_x15_r0_body.cshift41 PRE_first_tail_x15_r0_body.ncl402 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_41] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR42
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 42 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl419`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR42 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S419.tab.length PRE_first_tail_x15_r0_body.s419.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P42.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P42 1898 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.s421.ffi PRE_first_tail_x15_r0_body.s420.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_42
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_42
  have hcl : SSt (· < 1898) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s421.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S419.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_42] <;> decide) PRE_first_tail_x15_r0_body.cnodesK42 PRE_first_tail_x15_r0_body.cobjsK42
      PRE_first_tail_x15_r0_body.citemsK42 PRE_first_tail_x15_r0_body.cbd42 PRE_first_tail_x15_r0_body.csst42
  exact PRE_first_tail_x15_r0_body.cshift42 PRE_first_tail_x15_r0_body.ncl419 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_42] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR43
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 43 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl427`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR43 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S427.tab.length PRE_first_tail_x15_r0_body.s427.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P43.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P43 1919 PRE_first_tail_x15_r0_body.kappa43 PRE_first_tail_x15_r0_body.s429.ffi PRE_first_tail_x15_r0_body.s428.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_43
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_43
  have hcl : SSt (· < 1919) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S427.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_43] <;> decide) PRE_first_tail_x15_r0_body.cnodesK43 PRE_first_tail_x15_r0_body.cobjsK43
      PRE_first_tail_x15_r0_body.citemsK43 PRE_first_tail_x15_r0_body.cbd43 PRE_first_tail_x15_r0_body.csst43
  exact PRE_first_tail_x15_r0_body.cshift43 PRE_first_tail_x15_r0_body.ncl427 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_43] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR44
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 44 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl431`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR44 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S431.tab.length PRE_first_tail_x15_r0_body.s431.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P44.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P44 1936 PRE_first_tail_x15_r0_body.kappa44 PRE_first_tail_x15_r0_body.s433.ffi PRE_first_tail_x15_r0_body.s432.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_44
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_44
  have hcl : SSt (· < 1936) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S431.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_44] <;> decide) PRE_first_tail_x15_r0_body.cnodesK44 PRE_first_tail_x15_r0_body.cobjsK44
      PRE_first_tail_x15_r0_body.citemsK44 PRE_first_tail_x15_r0_body.cbd44 PRE_first_tail_x15_r0_body.csst44
  exact PRE_first_tail_x15_r0_body.cshift44 PRE_first_tail_x15_r0_body.ncl431 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_44] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR45
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 45 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl447`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR45 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S447.tab.length PRE_first_tail_x15_r0_body.s447.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P45.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.s449.ffi PRE_first_tail_x15_r0_body.s448.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_45
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_45
  have hcl : SSt (· < 2022) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S447.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_45] <;> decide) PRE_first_tail_x15_r0_body.cnodesK45 PRE_first_tail_x15_r0_body.cobjsK45
      PRE_first_tail_x15_r0_body.citemsK45 PRE_first_tail_x15_r0_body.cbd45 PRE_first_tail_x15_r0_body.csst45
  exact PRE_first_tail_x15_r0_body.cshift45 PRE_first_tail_x15_r0_body.ncl447 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_45] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR46
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 46 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl455`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR46 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S455.tab.length PRE_first_tail_x15_r0_body.s455.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P46.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P46 2045 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.s457.ffi PRE_first_tail_x15_r0_body.s456.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_46
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_46
  have hcl : SSt (· < 2045) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S455.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_46] <;> decide) PRE_first_tail_x15_r0_body.cnodesK46 PRE_first_tail_x15_r0_body.cobjsK46
      PRE_first_tail_x15_r0_body.citemsK46 PRE_first_tail_x15_r0_body.cbd46 PRE_first_tail_x15_r0_body.csst46
  exact PRE_first_tail_x15_r0_body.cshift46 PRE_first_tail_x15_r0_body.ncl455 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_46] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR47
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 47 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl459`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR47 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S459.tab.length PRE_first_tail_x15_r0_body.s459.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P47.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P47 2062 PRE_first_tail_x15_r0_body.kappa47 PRE_first_tail_x15_r0_body.s461.ffi PRE_first_tail_x15_r0_body.s460.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_47
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_47
  have hcl : SSt (· < 2062) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s461.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S459.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_47] <;> decide) PRE_first_tail_x15_r0_body.cnodesK47 PRE_first_tail_x15_r0_body.cobjsK47
      PRE_first_tail_x15_r0_body.citemsK47 PRE_first_tail_x15_r0_body.cbd47 PRE_first_tail_x15_r0_body.csst47
  exact PRE_first_tail_x15_r0_body.cshift47 PRE_first_tail_x15_r0_body.ncl459 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_47] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR48
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 48 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl476`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR48 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S476.tab.length PRE_first_tail_x15_r0_body.s476.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P48.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P48 2153 PRE_first_tail_x15_r0_body.kappa48 PRE_first_tail_x15_r0_body.s478.ffi PRE_first_tail_x15_r0_body.s477.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_48
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_48
  have hcl : SSt (· < 2153) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s478.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S476.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_48] <;> decide) PRE_first_tail_x15_r0_body.cnodesK48 PRE_first_tail_x15_r0_body.cobjsK48
      PRE_first_tail_x15_r0_body.citemsK48 PRE_first_tail_x15_r0_body.cbd48 PRE_first_tail_x15_r0_body.csst48
  exact PRE_first_tail_x15_r0_body.cshift48 PRE_first_tail_x15_r0_body.ncl476 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_48] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR49
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 49 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl484`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR49 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S484.tab.length PRE_first_tail_x15_r0_body.s484.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P49.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.s486.ffi PRE_first_tail_x15_r0_body.s485.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_49
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_49
  have hcl : SSt (· < 2174) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S484.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_49] <;> decide) PRE_first_tail_x15_r0_body.cnodesK49 PRE_first_tail_x15_r0_body.cobjsK49
      PRE_first_tail_x15_r0_body.citemsK49 PRE_first_tail_x15_r0_body.cbd49 PRE_first_tail_x15_r0_body.csst49
  exact PRE_first_tail_x15_r0_body.cshift49 PRE_first_tail_x15_r0_body.ncl484 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_49] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR50
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 50 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl488`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR50 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S488.tab.length PRE_first_tail_x15_r0_body.s488.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P50.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.s490.ffi PRE_first_tail_x15_r0_body.s489.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_50
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_50
  have hcl : SSt (· < 2191) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S488.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_50] <;> decide) PRE_first_tail_x15_r0_body.cnodesK50 PRE_first_tail_x15_r0_body.cobjsK50
      PRE_first_tail_x15_r0_body.citemsK50 PRE_first_tail_x15_r0_body.cbd50 PRE_first_tail_x15_r0_body.csst50
  exact PRE_first_tail_x15_r0_body.cshift50 PRE_first_tail_x15_r0_body.ncl488 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_50] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR51
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 51 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl505`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR51 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S505.tab.length PRE_first_tail_x15_r0_body.s505.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P51.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.s507.ffi PRE_first_tail_x15_r0_body.s506.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_51
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_51
  have hcl : SSt (· < 2282) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S505.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_51] <;> decide) PRE_first_tail_x15_r0_body.cnodesK51 PRE_first_tail_x15_r0_body.cobjsK51
      PRE_first_tail_x15_r0_body.citemsK51 PRE_first_tail_x15_r0_body.cbd51 PRE_first_tail_x15_r0_body.csst51
  exact PRE_first_tail_x15_r0_body.cshift51 PRE_first_tail_x15_r0_body.ncl505 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_51] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR52
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 52 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl513`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR52 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S513.tab.length PRE_first_tail_x15_r0_body.s513.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P52.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P52 2303 PRE_first_tail_x15_r0_body.kappa52 PRE_first_tail_x15_r0_body.s515.ffi PRE_first_tail_x15_r0_body.s514.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_52
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_52
  have hcl : SSt (· < 2303) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S513.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_52] <;> decide) PRE_first_tail_x15_r0_body.cnodesK52 PRE_first_tail_x15_r0_body.cobjsK52
      PRE_first_tail_x15_r0_body.citemsK52 PRE_first_tail_x15_r0_body.cbd52 PRE_first_tail_x15_r0_body.csst52
  exact PRE_first_tail_x15_r0_body.cshift52 PRE_first_tail_x15_r0_body.ncl513 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_52] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR53
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 53 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl517`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR53 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S517.tab.length PRE_first_tail_x15_r0_body.s517.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P53.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P53 2320 PRE_first_tail_x15_r0_body.kappa53 PRE_first_tail_x15_r0_body.s519.ffi PRE_first_tail_x15_r0_body.s518.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_53
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_53
  have hcl : SSt (· < 2320) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S517.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_53] <;> decide) PRE_first_tail_x15_r0_body.cnodesK53 PRE_first_tail_x15_r0_body.cobjsK53
      PRE_first_tail_x15_r0_body.citemsK53 PRE_first_tail_x15_r0_body.cbd53 PRE_first_tail_x15_r0_body.csst53
  exact PRE_first_tail_x15_r0_body.cshift53 PRE_first_tail_x15_r0_body.ncl517 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_53] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR54
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 54 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl534`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR54 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S534.tab.length PRE_first_tail_x15_r0_body.s534.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P54.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P54 2411 PRE_first_tail_x15_r0_body.kappa54 PRE_first_tail_x15_r0_body.s536.ffi PRE_first_tail_x15_r0_body.s535.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_54
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_54
  have hcl : SSt (· < 2411) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s536.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S534.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_54] <;> decide) PRE_first_tail_x15_r0_body.cnodesK54 PRE_first_tail_x15_r0_body.cobjsK54
      PRE_first_tail_x15_r0_body.citemsK54 PRE_first_tail_x15_r0_body.cbd54 PRE_first_tail_x15_r0_body.csst54
  exact PRE_first_tail_x15_r0_body.cshift54 PRE_first_tail_x15_r0_body.ncl534 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_54] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR55
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 55 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl542`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR55 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S542.tab.length PRE_first_tail_x15_r0_body.s542.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P55.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P55 2432 PRE_first_tail_x15_r0_body.kappa55 PRE_first_tail_x15_r0_body.s544.ffi PRE_first_tail_x15_r0_body.s543.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_55
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_55
  have hcl : SSt (· < 2432) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s544.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S542.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_55] <;> decide) PRE_first_tail_x15_r0_body.cnodesK55 PRE_first_tail_x15_r0_body.cobjsK55
      PRE_first_tail_x15_r0_body.citemsK55 PRE_first_tail_x15_r0_body.cbd55 PRE_first_tail_x15_r0_body.csst55
  exact PRE_first_tail_x15_r0_body.cshift55 PRE_first_tail_x15_r0_body.ncl542 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_55] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR56
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 56 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl546`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR56 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S546.tab.length PRE_first_tail_x15_r0_body.s546.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P56.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.s548.ffi PRE_first_tail_x15_r0_body.s547.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_56
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_56
  have hcl : SSt (· < 2449) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S546.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_56] <;> decide) PRE_first_tail_x15_r0_body.cnodesK56 PRE_first_tail_x15_r0_body.cobjsK56
      PRE_first_tail_x15_r0_body.citemsK56 PRE_first_tail_x15_r0_body.cbd56 PRE_first_tail_x15_r0_body.csst56
  exact PRE_first_tail_x15_r0_body.cshift56 PRE_first_tail_x15_r0_body.ncl546 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_56] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR57
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 57 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl562`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR57 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S562.tab.length PRE_first_tail_x15_r0_body.s562.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P57.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.s564.ffi PRE_first_tail_x15_r0_body.s563.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_57
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_57
  have hcl : SSt (· < 2535) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S562.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_57] <;> decide) PRE_first_tail_x15_r0_body.cnodesK57 PRE_first_tail_x15_r0_body.cobjsK57
      PRE_first_tail_x15_r0_body.citemsK57 PRE_first_tail_x15_r0_body.cbd57 PRE_first_tail_x15_r0_body.csst57
  exact PRE_first_tail_x15_r0_body.cshift57 PRE_first_tail_x15_r0_body.ncl562 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_57] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR58
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 58 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl570`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR58 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S570.tab.length PRE_first_tail_x15_r0_body.s570.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P58.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.s572.ffi PRE_first_tail_x15_r0_body.s571.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_58
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_58
  have hcl : SSt (· < 2558) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S570.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_58] <;> decide) PRE_first_tail_x15_r0_body.cnodesK58 PRE_first_tail_x15_r0_body.cobjsK58
      PRE_first_tail_x15_r0_body.citemsK58 PRE_first_tail_x15_r0_body.cbd58 PRE_first_tail_x15_r0_body.csst58
  exact PRE_first_tail_x15_r0_body.cshift58 PRE_first_tail_x15_r0_body.ncl570 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_58] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR59
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 59 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl574`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR59 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S574.tab.length PRE_first_tail_x15_r0_body.s574.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P59.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.s576.ffi PRE_first_tail_x15_r0_body.s575.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_59
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_59
  have hcl : SSt (· < 2575) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S574.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_59] <;> decide) PRE_first_tail_x15_r0_body.cnodesK59 PRE_first_tail_x15_r0_body.cobjsK59
      PRE_first_tail_x15_r0_body.citemsK59 PRE_first_tail_x15_r0_body.cbd59 PRE_first_tail_x15_r0_body.csst59
  exact PRE_first_tail_x15_r0_body.cshift59 PRE_first_tail_x15_r0_body.ncl574 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_59] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR60
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 60 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl591`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR60 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S591.tab.length PRE_first_tail_x15_r0_body.s591.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P60.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.s593.ffi PRE_first_tail_x15_r0_body.s592.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_60
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_60
  have hcl : SSt (· < 2666) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S591.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_60] <;> decide) PRE_first_tail_x15_r0_body.cnodesK60 PRE_first_tail_x15_r0_body.cobjsK60
      PRE_first_tail_x15_r0_body.citemsK60 PRE_first_tail_x15_r0_body.cbd60 PRE_first_tail_x15_r0_body.csst60
  exact PRE_first_tail_x15_r0_body.cshift60 PRE_first_tail_x15_r0_body.ncl591 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_60] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR61
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 61 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl599`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR61 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S599.tab.length PRE_first_tail_x15_r0_body.s599.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P61.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.s601.ffi PRE_first_tail_x15_r0_body.s600.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_61
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_61
  have hcl : SSt (· < 2687) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S599.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_61] <;> decide) PRE_first_tail_x15_r0_body.cnodesK61 PRE_first_tail_x15_r0_body.cobjsK61
      PRE_first_tail_x15_r0_body.citemsK61 PRE_first_tail_x15_r0_body.cbd61 PRE_first_tail_x15_r0_body.csst61
  exact PRE_first_tail_x15_r0_body.cshift61 PRE_first_tail_x15_r0_body.ncl599 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_61] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR62
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 62 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl603`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR62 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S603.tab.length PRE_first_tail_x15_r0_body.s603.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P62.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P62 2704 PRE_first_tail_x15_r0_body.kappa62 PRE_first_tail_x15_r0_body.s605.ffi PRE_first_tail_x15_r0_body.s604.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_62
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_62
  have hcl : SSt (· < 2704) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S603.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_62] <;> decide) PRE_first_tail_x15_r0_body.cnodesK62 PRE_first_tail_x15_r0_body.cobjsK62
      PRE_first_tail_x15_r0_body.citemsK62 PRE_first_tail_x15_r0_body.cbd62 PRE_first_tail_x15_r0_body.csst62
  exact PRE_first_tail_x15_r0_body.cshift62 PRE_first_tail_x15_r0_body.ncl603 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_62] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR63
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 63 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl620`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR63 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S620.tab.length PRE_first_tail_x15_r0_body.s620.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P63.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.s622.ffi PRE_first_tail_x15_r0_body.s621.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_63
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_63
  have hcl : SSt (· < 2795) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S620.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_63] <;> decide) PRE_first_tail_x15_r0_body.cnodesK63 PRE_first_tail_x15_r0_body.cobjsK63
      PRE_first_tail_x15_r0_body.citemsK63 PRE_first_tail_x15_r0_body.cbd63 PRE_first_tail_x15_r0_body.csst63
  exact PRE_first_tail_x15_r0_body.cshift63 PRE_first_tail_x15_r0_body.ncl620 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_63] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR64
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 64 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl628`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR64 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S628.tab.length PRE_first_tail_x15_r0_body.s628.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P64.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P64 2816 PRE_first_tail_x15_r0_body.kappa64 PRE_first_tail_x15_r0_body.s630.ffi PRE_first_tail_x15_r0_body.s629.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_64
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_64
  have hcl : SSt (· < 2816) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S628.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_64] <;> decide) PRE_first_tail_x15_r0_body.cnodesK64 PRE_first_tail_x15_r0_body.cobjsK64
      PRE_first_tail_x15_r0_body.citemsK64 PRE_first_tail_x15_r0_body.cbd64 PRE_first_tail_x15_r0_body.csst64
  exact PRE_first_tail_x15_r0_body.cshift64 PRE_first_tail_x15_r0_body.ncl628 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_64] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR65
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 65 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl632`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR65 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S632.tab.length PRE_first_tail_x15_r0_body.s632.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P65.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.s634.ffi PRE_first_tail_x15_r0_body.s633.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_65
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_65
  have hcl : SSt (· < 2833) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S632.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_65] <;> decide) PRE_first_tail_x15_r0_body.cnodesK65 PRE_first_tail_x15_r0_body.cobjsK65
      PRE_first_tail_x15_r0_body.citemsK65 PRE_first_tail_x15_r0_body.cbd65 PRE_first_tail_x15_r0_body.csst65
  exact PRE_first_tail_x15_r0_body.cshift65 PRE_first_tail_x15_r0_body.ncl632 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_65] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR66
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 66 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl649`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR66 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S649.tab.length PRE_first_tail_x15_r0_body.s649.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P66.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.s651.ffi PRE_first_tail_x15_r0_body.s650.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_66
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_66
  have hcl : SSt (· < 2924) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S649.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_66] <;> decide) PRE_first_tail_x15_r0_body.cnodesK66 PRE_first_tail_x15_r0_body.cobjsK66
      PRE_first_tail_x15_r0_body.citemsK66 PRE_first_tail_x15_r0_body.cbd66 PRE_first_tail_x15_r0_body.csst66
  exact PRE_first_tail_x15_r0_body.cshift66 PRE_first_tail_x15_r0_body.ncl649 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_66] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR67
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 67 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl657`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR67 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S657.tab.length PRE_first_tail_x15_r0_body.s657.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P67.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.s659.ffi PRE_first_tail_x15_r0_body.s658.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_67
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_67
  have hcl : SSt (· < 2945) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S657.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_67] <;> decide) PRE_first_tail_x15_r0_body.cnodesK67 PRE_first_tail_x15_r0_body.cobjsK67
      PRE_first_tail_x15_r0_body.citemsK67 PRE_first_tail_x15_r0_body.cbd67 PRE_first_tail_x15_r0_body.csst67
  exact PRE_first_tail_x15_r0_body.cshift67 PRE_first_tail_x15_r0_body.ncl657 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_67] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR68
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 68 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl661`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR68 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S661.tab.length PRE_first_tail_x15_r0_body.s661.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P68.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.s663.ffi PRE_first_tail_x15_r0_body.s662.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_68
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_68
  have hcl : SSt (· < 2962) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S661.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_68] <;> decide) PRE_first_tail_x15_r0_body.cnodesK68 PRE_first_tail_x15_r0_body.cobjsK68
      PRE_first_tail_x15_r0_body.citemsK68 PRE_first_tail_x15_r0_body.cbd68 PRE_first_tail_x15_r0_body.csst68
  exact PRE_first_tail_x15_r0_body.cshift68 PRE_first_tail_x15_r0_body.ncl661 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_68] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR69
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 69 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl677`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR69 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S677.tab.length PRE_first_tail_x15_r0_body.s677.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P69.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.s679.ffi PRE_first_tail_x15_r0_body.s678.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_69
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_69
  have hcl : SSt (· < 3048) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S677.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_69] <;> decide) PRE_first_tail_x15_r0_body.cnodesK69 PRE_first_tail_x15_r0_body.cobjsK69
      PRE_first_tail_x15_r0_body.citemsK69 PRE_first_tail_x15_r0_body.cbd69 PRE_first_tail_x15_r0_body.csst69
  exact PRE_first_tail_x15_r0_body.cshift69 PRE_first_tail_x15_r0_body.ncl677 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_69] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR70
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 70 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl685`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR70 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S685.tab.length PRE_first_tail_x15_r0_body.s685.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P70.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.s687.ffi PRE_first_tail_x15_r0_body.s686.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_70
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_70
  have hcl : SSt (· < 3071) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S685.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_70] <;> decide) PRE_first_tail_x15_r0_body.cnodesK70 PRE_first_tail_x15_r0_body.cobjsK70
      PRE_first_tail_x15_r0_body.citemsK70 PRE_first_tail_x15_r0_body.cbd70 PRE_first_tail_x15_r0_body.csst70
  exact PRE_first_tail_x15_r0_body.cshift70 PRE_first_tail_x15_r0_body.ncl685 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_70] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR71
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 71 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl689`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR71 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S689.tab.length PRE_first_tail_x15_r0_body.s689.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P71.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.s691.ffi PRE_first_tail_x15_r0_body.s690.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_71
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_71
  have hcl : SSt (· < 3088) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S689.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_71] <;> decide) PRE_first_tail_x15_r0_body.cnodesK71 PRE_first_tail_x15_r0_body.cobjsK71
      PRE_first_tail_x15_r0_body.citemsK71 PRE_first_tail_x15_r0_body.cbd71 PRE_first_tail_x15_r0_body.csst71
  exact PRE_first_tail_x15_r0_body.cshift71 PRE_first_tail_x15_r0_body.ncl689 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_71] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR72
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 72 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl706`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR72 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S706.tab.length PRE_first_tail_x15_r0_body.s706.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P72.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P72 3179 PRE_first_tail_x15_r0_body.kappa72 PRE_first_tail_x15_r0_body.s708.ffi PRE_first_tail_x15_r0_body.s707.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_72
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_72
  have hcl : SSt (· < 3179) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S706.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_72] <;> decide) PRE_first_tail_x15_r0_body.cnodesK72 PRE_first_tail_x15_r0_body.cobjsK72
      PRE_first_tail_x15_r0_body.citemsK72 PRE_first_tail_x15_r0_body.cbd72 PRE_first_tail_x15_r0_body.csst72
  exact PRE_first_tail_x15_r0_body.cshift72 PRE_first_tail_x15_r0_body.ncl706 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_72] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR73
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 73 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl714`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR73 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S714.tab.length PRE_first_tail_x15_r0_body.s714.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P73.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P73 3200 PRE_first_tail_x15_r0_body.kappa73 PRE_first_tail_x15_r0_body.s716.ffi PRE_first_tail_x15_r0_body.s715.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_73
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_73
  have hcl : SSt (· < 3200) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S714.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_73] <;> decide) PRE_first_tail_x15_r0_body.cnodesK73 PRE_first_tail_x15_r0_body.cobjsK73
      PRE_first_tail_x15_r0_body.citemsK73 PRE_first_tail_x15_r0_body.cbd73 PRE_first_tail_x15_r0_body.csst73
  exact PRE_first_tail_x15_r0_body.cshift73 PRE_first_tail_x15_r0_body.ncl714 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_73] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR74
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 74 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl718`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR74 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S718.tab.length PRE_first_tail_x15_r0_body.s718.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P74.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.s720.ffi PRE_first_tail_x15_r0_body.s719.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_74
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_74
  have hcl : SSt (· < 3217) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S718.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_74] <;> decide) PRE_first_tail_x15_r0_body.cnodesK74 PRE_first_tail_x15_r0_body.cobjsK74
      PRE_first_tail_x15_r0_body.citemsK74 PRE_first_tail_x15_r0_body.cbd74 PRE_first_tail_x15_r0_body.csst74
  exact PRE_first_tail_x15_r0_body.cshift74 PRE_first_tail_x15_r0_body.ncl718 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_74] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR75
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 75 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl735`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR75 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S735.tab.length PRE_first_tail_x15_r0_body.s735.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P75.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P75 3308 PRE_first_tail_x15_r0_body.kappa75 PRE_first_tail_x15_r0_body.s737.ffi PRE_first_tail_x15_r0_body.s736.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_75
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_75
  have hcl : SSt (· < 3308) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s737.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S735.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_75] <;> decide) PRE_first_tail_x15_r0_body.cnodesK75 PRE_first_tail_x15_r0_body.cobjsK75
      PRE_first_tail_x15_r0_body.citemsK75 PRE_first_tail_x15_r0_body.cbd75 PRE_first_tail_x15_r0_body.csst75
  exact PRE_first_tail_x15_r0_body.cshift75 PRE_first_tail_x15_r0_body.ncl735 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_75] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR76
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 76 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl743`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR76 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S743.tab.length PRE_first_tail_x15_r0_body.s743.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P76.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.s745.ffi PRE_first_tail_x15_r0_body.s744.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_76
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_76
  have hcl : SSt (· < 3329) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S743.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_76] <;> decide) PRE_first_tail_x15_r0_body.cnodesK76 PRE_first_tail_x15_r0_body.cobjsK76
      PRE_first_tail_x15_r0_body.citemsK76 PRE_first_tail_x15_r0_body.cbd76 PRE_first_tail_x15_r0_body.csst76
  exact PRE_first_tail_x15_r0_body.cshift76 PRE_first_tail_x15_r0_body.ncl743 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_76] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR77
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 77 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl747`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR77 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S747.tab.length PRE_first_tail_x15_r0_body.s747.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P77.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P77 3346 PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.s749.ffi PRE_first_tail_x15_r0_body.s748.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_77
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_77
  have hcl : SSt (· < 3346) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S747.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_77] <;> decide) PRE_first_tail_x15_r0_body.cnodesK77 PRE_first_tail_x15_r0_body.cobjsK77
      PRE_first_tail_x15_r0_body.citemsK77 PRE_first_tail_x15_r0_body.cbd77 PRE_first_tail_x15_r0_body.csst77
  exact PRE_first_tail_x15_r0_body.cshift77 PRE_first_tail_x15_r0_body.ncl747 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_77] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR78
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 78 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl764`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR78 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S764.tab.length PRE_first_tail_x15_r0_body.s764.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P78.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P78 3437 PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.s766.ffi PRE_first_tail_x15_r0_body.s765.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_78
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_78
  have hcl : SSt (· < 3437) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s766.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S764.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_78] <;> decide) PRE_first_tail_x15_r0_body.cnodesK78 PRE_first_tail_x15_r0_body.cobjsK78
      PRE_first_tail_x15_r0_body.citemsK78 PRE_first_tail_x15_r0_body.cbd78 PRE_first_tail_x15_r0_body.csst78
  exact PRE_first_tail_x15_r0_body.cshift78 PRE_first_tail_x15_r0_body.ncl764 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_78] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR79
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 79 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl772`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR79 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S772.tab.length PRE_first_tail_x15_r0_body.s772.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P79.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P79 3458 PRE_first_tail_x15_r0_body.kappa79 PRE_first_tail_x15_r0_body.s774.ffi PRE_first_tail_x15_r0_body.s773.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_79
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_79
  have hcl : SSt (· < 3458) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s774.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S772.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_79] <;> decide) PRE_first_tail_x15_r0_body.cnodesK79 PRE_first_tail_x15_r0_body.cobjsK79
      PRE_first_tail_x15_r0_body.citemsK79 PRE_first_tail_x15_r0_body.cbd79 PRE_first_tail_x15_r0_body.csst79
  exact PRE_first_tail_x15_r0_body.cshift79 PRE_first_tail_x15_r0_body.ncl772 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_79] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR80
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 80 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl776`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR80 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S776.tab.length PRE_first_tail_x15_r0_body.s776.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P80.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P80 3475 PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.s778.ffi PRE_first_tail_x15_r0_body.s777.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_80
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_80
  have hcl : SSt (· < 3475) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S776.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_80] <;> decide) PRE_first_tail_x15_r0_body.cnodesK80 PRE_first_tail_x15_r0_body.cobjsK80
      PRE_first_tail_x15_r0_body.citemsK80 PRE_first_tail_x15_r0_body.cbd80 PRE_first_tail_x15_r0_body.csst80
  exact PRE_first_tail_x15_r0_body.cshift80 PRE_first_tail_x15_r0_body.ncl776 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_80] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR81
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 81 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl792`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR81 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S792.tab.length PRE_first_tail_x15_r0_body.s792.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P81.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P81 3561 PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.s794.ffi PRE_first_tail_x15_r0_body.s793.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_81
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_81
  have hcl : SSt (· < 3561) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S792.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_81] <;> decide) PRE_first_tail_x15_r0_body.cnodesK81 PRE_first_tail_x15_r0_body.cobjsK81
      PRE_first_tail_x15_r0_body.citemsK81 PRE_first_tail_x15_r0_body.cbd81 PRE_first_tail_x15_r0_body.csst81
  exact PRE_first_tail_x15_r0_body.cshift81 PRE_first_tail_x15_r0_body.ncl792 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_81] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR82
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 82 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl800`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR82 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S800.tab.length PRE_first_tail_x15_r0_body.s800.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P82.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P82 3584 PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.s802.ffi PRE_first_tail_x15_r0_body.s801.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_82
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_82
  have hcl : SSt (· < 3584) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S800.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_82] <;> decide) PRE_first_tail_x15_r0_body.cnodesK82 PRE_first_tail_x15_r0_body.cobjsK82
      PRE_first_tail_x15_r0_body.citemsK82 PRE_first_tail_x15_r0_body.cbd82 PRE_first_tail_x15_r0_body.csst82
  exact PRE_first_tail_x15_r0_body.cshift82 PRE_first_tail_x15_r0_body.ncl800 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_82] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR83
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 83 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl804`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR83 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S804.tab.length PRE_first_tail_x15_r0_body.s804.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P83.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P83 3601 PRE_first_tail_x15_r0_body.kappa83 PRE_first_tail_x15_r0_body.s806.ffi PRE_first_tail_x15_r0_body.s805.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_83
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_83
  have hcl : SSt (· < 3601) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s806.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S804.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_83] <;> decide) PRE_first_tail_x15_r0_body.cnodesK83 PRE_first_tail_x15_r0_body.cobjsK83
      PRE_first_tail_x15_r0_body.citemsK83 PRE_first_tail_x15_r0_body.cbd83 PRE_first_tail_x15_r0_body.csst83
  exact PRE_first_tail_x15_r0_body.cshift83 PRE_first_tail_x15_r0_body.ncl804 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_83] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR84
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 84 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl821`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR84 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S821.tab.length PRE_first_tail_x15_r0_body.s821.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P84.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P84 3692 PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.s823.ffi PRE_first_tail_x15_r0_body.s822.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_84
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_84
  have hcl : SSt (· < 3692) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S821.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_84] <;> decide) PRE_first_tail_x15_r0_body.cnodesK84 PRE_first_tail_x15_r0_body.cobjsK84
      PRE_first_tail_x15_r0_body.citemsK84 PRE_first_tail_x15_r0_body.cbd84 PRE_first_tail_x15_r0_body.csst84
  exact PRE_first_tail_x15_r0_body.cshift84 PRE_first_tail_x15_r0_body.ncl821 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_84] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR85
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 85 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl829`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR85 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S829.tab.length PRE_first_tail_x15_r0_body.s829.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P85.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P85 3713 PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.s831.ffi PRE_first_tail_x15_r0_body.s830.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_85
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_85
  have hcl : SSt (· < 3713) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S829.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_85] <;> decide) PRE_first_tail_x15_r0_body.cnodesK85 PRE_first_tail_x15_r0_body.cobjsK85
      PRE_first_tail_x15_r0_body.citemsK85 PRE_first_tail_x15_r0_body.cbd85 PRE_first_tail_x15_r0_body.csst85
  exact PRE_first_tail_x15_r0_body.cshift85 PRE_first_tail_x15_r0_body.ncl829 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_85] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR86
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 86 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl833`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR86 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S833.tab.length PRE_first_tail_x15_r0_body.s833.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P86.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P86 3730 PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.s835.ffi PRE_first_tail_x15_r0_body.s834.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_86
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_86
  have hcl : SSt (· < 3730) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s835.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S833.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_86] <;> decide) PRE_first_tail_x15_r0_body.cnodesK86 PRE_first_tail_x15_r0_body.cobjsK86
      PRE_first_tail_x15_r0_body.citemsK86 PRE_first_tail_x15_r0_body.cbd86 PRE_first_tail_x15_r0_body.csst86
  exact PRE_first_tail_x15_r0_body.cshift86 PRE_first_tail_x15_r0_body.ncl833 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_86] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR87
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 87 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl850`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR87 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S850.tab.length PRE_first_tail_x15_r0_body.s850.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P87.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P87 3821 PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.s852.ffi PRE_first_tail_x15_r0_body.s851.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_87
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_87
  have hcl : SSt (· < 3821) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S850.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_87] <;> decide) PRE_first_tail_x15_r0_body.cnodesK87 PRE_first_tail_x15_r0_body.cobjsK87
      PRE_first_tail_x15_r0_body.citemsK87 PRE_first_tail_x15_r0_body.cbd87 PRE_first_tail_x15_r0_body.csst87
  exact PRE_first_tail_x15_r0_body.cshift87 PRE_first_tail_x15_r0_body.ncl850 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_87] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR88
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 88 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl858`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR88 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S858.tab.length PRE_first_tail_x15_r0_body.s858.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P88.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P88 3842 PRE_first_tail_x15_r0_body.kappa88 PRE_first_tail_x15_r0_body.s860.ffi PRE_first_tail_x15_r0_body.s859.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_88
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_88
  have hcl : SSt (· < 3842) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s860.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S858.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_88] <;> decide) PRE_first_tail_x15_r0_body.cnodesK88 PRE_first_tail_x15_r0_body.cobjsK88
      PRE_first_tail_x15_r0_body.citemsK88 PRE_first_tail_x15_r0_body.cbd88 PRE_first_tail_x15_r0_body.csst88
  exact PRE_first_tail_x15_r0_body.cshift88 PRE_first_tail_x15_r0_body.ncl858 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_88] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR89
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 89 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl862`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR89 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S862.tab.length PRE_first_tail_x15_r0_body.s862.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P89.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P89 3859 PRE_first_tail_x15_r0_body.kappa89 PRE_first_tail_x15_r0_body.s864.ffi PRE_first_tail_x15_r0_body.s863.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_89
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_89
  have hcl : SSt (· < 3859) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S862.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_89] <;> decide) PRE_first_tail_x15_r0_body.cnodesK89 PRE_first_tail_x15_r0_body.cobjsK89
      PRE_first_tail_x15_r0_body.citemsK89 PRE_first_tail_x15_r0_body.cbd89 PRE_first_tail_x15_r0_body.csst89
  exact PRE_first_tail_x15_r0_body.cshift89 PRE_first_tail_x15_r0_body.ncl862 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_89] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR90
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 90 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl879`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR90 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S879.tab.length PRE_first_tail_x15_r0_body.s879.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P90.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P90 3950 PRE_first_tail_x15_r0_body.kappa90 PRE_first_tail_x15_r0_body.s881.ffi PRE_first_tail_x15_r0_body.s880.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_90
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_90
  have hcl : SSt (· < 3950) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S879.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_90] <;> decide) PRE_first_tail_x15_r0_body.cnodesK90 PRE_first_tail_x15_r0_body.cobjsK90
      PRE_first_tail_x15_r0_body.citemsK90 PRE_first_tail_x15_r0_body.cbd90 PRE_first_tail_x15_r0_body.csst90
  exact PRE_first_tail_x15_r0_body.cshift90 PRE_first_tail_x15_r0_body.ncl879 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_90] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR91
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 91 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl887`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR91 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S887.tab.length PRE_first_tail_x15_r0_body.s887.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P91.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P91 3971 PRE_first_tail_x15_r0_body.kappa91 PRE_first_tail_x15_r0_body.s889.ffi PRE_first_tail_x15_r0_body.s888.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_91
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_91
  have hcl : SSt (· < 3971) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s889.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S887.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_91] <;> decide) PRE_first_tail_x15_r0_body.cnodesK91 PRE_first_tail_x15_r0_body.cobjsK91
      PRE_first_tail_x15_r0_body.citemsK91 PRE_first_tail_x15_r0_body.cbd91 PRE_first_tail_x15_r0_body.csst91
  exact PRE_first_tail_x15_r0_body.cshift91 PRE_first_tail_x15_r0_body.ncl887 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_91] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR92
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 92 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl891`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR92 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S891.tab.length PRE_first_tail_x15_r0_body.s891.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P92.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P92 3988 PRE_first_tail_x15_r0_body.kappa92 PRE_first_tail_x15_r0_body.s893.ffi PRE_first_tail_x15_r0_body.s892.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_92
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_92
  have hcl : SSt (· < 3988) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s893.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S891.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_92] <;> decide) PRE_first_tail_x15_r0_body.cnodesK92 PRE_first_tail_x15_r0_body.cobjsK92
      PRE_first_tail_x15_r0_body.citemsK92 PRE_first_tail_x15_r0_body.cbd92 PRE_first_tail_x15_r0_body.csst92
  exact PRE_first_tail_x15_r0_body.cshift92 PRE_first_tail_x15_r0_body.ncl891 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_92] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR93
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 93 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl907`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR93 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S907.tab.length PRE_first_tail_x15_r0_body.s907.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P93.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P93 4074 PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.s909.ffi PRE_first_tail_x15_r0_body.s908.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_93
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_93
  have hcl : SSt (· < 4074) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S907.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_93] <;> decide) PRE_first_tail_x15_r0_body.cnodesK93 PRE_first_tail_x15_r0_body.cobjsK93
      PRE_first_tail_x15_r0_body.citemsK93 PRE_first_tail_x15_r0_body.cbd93 PRE_first_tail_x15_r0_body.csst93
  exact PRE_first_tail_x15_r0_body.cshift93 PRE_first_tail_x15_r0_body.ncl907 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_93] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR94
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 94 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl915`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR94 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S915.tab.length PRE_first_tail_x15_r0_body.s915.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P94.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P94 4097 PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.s917.ffi PRE_first_tail_x15_r0_body.s916.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_94
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_94
  have hcl : SSt (· < 4097) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S915.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_94] <;> decide) PRE_first_tail_x15_r0_body.cnodesK94 PRE_first_tail_x15_r0_body.cobjsK94
      PRE_first_tail_x15_r0_body.citemsK94 PRE_first_tail_x15_r0_body.cbd94 PRE_first_tail_x15_r0_body.csst94
  exact PRE_first_tail_x15_r0_body.cshift94 PRE_first_tail_x15_r0_body.ncl915 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_94] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR95
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 95 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl919`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR95 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S919.tab.length PRE_first_tail_x15_r0_body.s919.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P95.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P95 4114 PRE_first_tail_x15_r0_body.kappa95 PRE_first_tail_x15_r0_body.s921.ffi PRE_first_tail_x15_r0_body.s920.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_95
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_95
  have hcl : SSt (· < 4114) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S919.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_95] <;> decide) PRE_first_tail_x15_r0_body.cnodesK95 PRE_first_tail_x15_r0_body.cobjsK95
      PRE_first_tail_x15_r0_body.citemsK95 PRE_first_tail_x15_r0_body.cbd95 PRE_first_tail_x15_r0_body.csst95
  exact PRE_first_tail_x15_r0_body.cshift95 PRE_first_tail_x15_r0_body.ncl919 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_95] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR96
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 96 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl936`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR96 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S936.tab.length PRE_first_tail_x15_r0_body.s936.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P96.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P96 4205 PRE_first_tail_x15_r0_body.kappa96 PRE_first_tail_x15_r0_body.s938.ffi PRE_first_tail_x15_r0_body.s937.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_96
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_96
  have hcl : SSt (· < 4205) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s938.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S936.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_96] <;> decide) PRE_first_tail_x15_r0_body.cnodesK96 PRE_first_tail_x15_r0_body.cobjsK96
      PRE_first_tail_x15_r0_body.citemsK96 PRE_first_tail_x15_r0_body.cbd96 PRE_first_tail_x15_r0_body.csst96
  exact PRE_first_tail_x15_r0_body.cshift96 PRE_first_tail_x15_r0_body.ncl936 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_96] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR97
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 97 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl944`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR97 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S944.tab.length PRE_first_tail_x15_r0_body.s944.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P97.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P97 4226 PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.s946.ffi PRE_first_tail_x15_r0_body.s945.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_97
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_97
  have hcl : SSt (· < 4226) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s946.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S944.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_97] <;> decide) PRE_first_tail_x15_r0_body.cnodesK97 PRE_first_tail_x15_r0_body.cobjsK97
      PRE_first_tail_x15_r0_body.citemsK97 PRE_first_tail_x15_r0_body.cbd97 PRE_first_tail_x15_r0_body.csst97
  exact PRE_first_tail_x15_r0_body.cshift97 PRE_first_tail_x15_r0_body.ncl944 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_97] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR98
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 98 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl948`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR98 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S948.tab.length PRE_first_tail_x15_r0_body.s948.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P98.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P98 4243 PRE_first_tail_x15_r0_body.kappa98 PRE_first_tail_x15_r0_body.s950.ffi PRE_first_tail_x15_r0_body.s949.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_98
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_98
  have hcl : SSt (· < 4243) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s950.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S948.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_98] <;> decide) PRE_first_tail_x15_r0_body.cnodesK98 PRE_first_tail_x15_r0_body.cobjsK98
      PRE_first_tail_x15_r0_body.citemsK98 PRE_first_tail_x15_r0_body.cbd98 PRE_first_tail_x15_r0_body.csst98
  exact PRE_first_tail_x15_r0_body.cshift98 PRE_first_tail_x15_r0_body.ncl948 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_98] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR99
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 99 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl965`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR99 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S965.tab.length PRE_first_tail_x15_r0_body.s965.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P99.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.s967.ffi PRE_first_tail_x15_r0_body.s966.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_99
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_99
  have hcl : SSt (· < 4334) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S965.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_99] <;> decide) PRE_first_tail_x15_r0_body.cnodesK99 PRE_first_tail_x15_r0_body.cobjsK99
      PRE_first_tail_x15_r0_body.citemsK99 PRE_first_tail_x15_r0_body.cbd99 PRE_first_tail_x15_r0_body.csst99
  exact PRE_first_tail_x15_r0_body.cshift99 PRE_first_tail_x15_r0_body.ncl965 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_99] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR100
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 100 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl973`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR100 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S973.tab.length PRE_first_tail_x15_r0_body.s973.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P100.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.s975.ffi PRE_first_tail_x15_r0_body.s974.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_100
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_100
  have hcl : SSt (· < 4355) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S973.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_100] <;> decide) PRE_first_tail_x15_r0_body.cnodesK100 PRE_first_tail_x15_r0_body.cobjsK100
      PRE_first_tail_x15_r0_body.citemsK100 PRE_first_tail_x15_r0_body.cbd100 PRE_first_tail_x15_r0_body.csst100
  exact PRE_first_tail_x15_r0_body.cshift100 PRE_first_tail_x15_r0_body.ncl973 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_100] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR101
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 101 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl977`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR101 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S977.tab.length PRE_first_tail_x15_r0_body.s977.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P101.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P101 4372 PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.s979.ffi PRE_first_tail_x15_r0_body.s978.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_101
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_101
  have hcl : SSt (· < 4372) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S977.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_101] <;> decide) PRE_first_tail_x15_r0_body.cnodesK101 PRE_first_tail_x15_r0_body.cobjsK101
      PRE_first_tail_x15_r0_body.citemsK101 PRE_first_tail_x15_r0_body.cbd101 PRE_first_tail_x15_r0_body.csst101
  exact PRE_first_tail_x15_r0_body.cshift101 PRE_first_tail_x15_r0_body.ncl977 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_101] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR102
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 102 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl994`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR102 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S994.tab.length PRE_first_tail_x15_r0_body.s994.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P102.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P102 4463 PRE_first_tail_x15_r0_body.kappa102 PRE_first_tail_x15_r0_body.s996.ffi PRE_first_tail_x15_r0_body.s995.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_102
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_102
  have hcl : SSt (· < 4463) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S994.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_102] <;> decide) PRE_first_tail_x15_r0_body.cnodesK102 PRE_first_tail_x15_r0_body.cobjsK102
      PRE_first_tail_x15_r0_body.citemsK102 PRE_first_tail_x15_r0_body.cbd102 PRE_first_tail_x15_r0_body.csst102
  exact PRE_first_tail_x15_r0_body.cshift102 PRE_first_tail_x15_r0_body.ncl994 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_102] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR103
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 103 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1002`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR103 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1002.tab.length PRE_first_tail_x15_r0_body.s1002.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P103.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.s1004.ffi PRE_first_tail_x15_r0_body.s1003.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_103
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_103
  have hcl : SSt (· < 4484) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1002.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_103] <;> decide) PRE_first_tail_x15_r0_body.cnodesK103 PRE_first_tail_x15_r0_body.cobjsK103
      PRE_first_tail_x15_r0_body.citemsK103 PRE_first_tail_x15_r0_body.cbd103 PRE_first_tail_x15_r0_body.csst103
  exact PRE_first_tail_x15_r0_body.cshift103 PRE_first_tail_x15_r0_body.ncl1002 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_103] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR104
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 104 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1006`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR104 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1006.tab.length PRE_first_tail_x15_r0_body.s1006.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P104.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.s1008.ffi PRE_first_tail_x15_r0_body.s1007.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_104
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_104
  have hcl : SSt (· < 4501) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1006.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_104] <;> decide) PRE_first_tail_x15_r0_body.cnodesK104 PRE_first_tail_x15_r0_body.cobjsK104
      PRE_first_tail_x15_r0_body.citemsK104 PRE_first_tail_x15_r0_body.cbd104 PRE_first_tail_x15_r0_body.csst104
  exact PRE_first_tail_x15_r0_body.cshift104 PRE_first_tail_x15_r0_body.ncl1006 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_104] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR105
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 105 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1022`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR105 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1022.tab.length PRE_first_tail_x15_r0_body.s1022.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P105.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.s1024.ffi PRE_first_tail_x15_r0_body.s1023.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_105
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_105
  have hcl : SSt (· < 4587) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1022.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_105] <;> decide) PRE_first_tail_x15_r0_body.cnodesK105 PRE_first_tail_x15_r0_body.cobjsK105
      PRE_first_tail_x15_r0_body.citemsK105 PRE_first_tail_x15_r0_body.cbd105 PRE_first_tail_x15_r0_body.csst105
  exact PRE_first_tail_x15_r0_body.cshift105 PRE_first_tail_x15_r0_body.ncl1022 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_105] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR106
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 106 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1030`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR106 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1030.tab.length PRE_first_tail_x15_r0_body.s1030.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P106.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.s1032.ffi PRE_first_tail_x15_r0_body.s1031.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_106
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_106
  have hcl : SSt (· < 4610) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1030.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_106] <;> decide) PRE_first_tail_x15_r0_body.cnodesK106 PRE_first_tail_x15_r0_body.cobjsK106
      PRE_first_tail_x15_r0_body.citemsK106 PRE_first_tail_x15_r0_body.cbd106 PRE_first_tail_x15_r0_body.csst106
  exact PRE_first_tail_x15_r0_body.cshift106 PRE_first_tail_x15_r0_body.ncl1030 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_106] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR107
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 107 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1034`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR107 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1034.tab.length PRE_first_tail_x15_r0_body.s1034.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P107.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P107 4627 PRE_first_tail_x15_r0_body.kappa107 PRE_first_tail_x15_r0_body.s1036.ffi PRE_first_tail_x15_r0_body.s1035.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_107
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_107
  have hcl : SSt (· < 4627) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1034.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_107] <;> decide) PRE_first_tail_x15_r0_body.cnodesK107 PRE_first_tail_x15_r0_body.cobjsK107
      PRE_first_tail_x15_r0_body.citemsK107 PRE_first_tail_x15_r0_body.cbd107 PRE_first_tail_x15_r0_body.csst107
  exact PRE_first_tail_x15_r0_body.cshift107 PRE_first_tail_x15_r0_body.ncl1034 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_107] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR108
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 108 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1051`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR108 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1051.tab.length PRE_first_tail_x15_r0_body.s1051.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P108.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P108 4718 PRE_first_tail_x15_r0_body.kappa108 PRE_first_tail_x15_r0_body.s1053.ffi PRE_first_tail_x15_r0_body.s1052.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_108
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_108
  have hcl : SSt (· < 4718) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1051.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_108] <;> decide) PRE_first_tail_x15_r0_body.cnodesK108 PRE_first_tail_x15_r0_body.cobjsK108
      PRE_first_tail_x15_r0_body.citemsK108 PRE_first_tail_x15_r0_body.cbd108 PRE_first_tail_x15_r0_body.csst108
  exact PRE_first_tail_x15_r0_body.cshift108 PRE_first_tail_x15_r0_body.ncl1051 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_108] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR109
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 109 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1059`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR109 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1059.tab.length PRE_first_tail_x15_r0_body.s1059.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P109.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.s1061.ffi PRE_first_tail_x15_r0_body.s1060.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_109
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_109
  have hcl : SSt (· < 4739) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1059.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_109] <;> decide) PRE_first_tail_x15_r0_body.cnodesK109 PRE_first_tail_x15_r0_body.cobjsK109
      PRE_first_tail_x15_r0_body.citemsK109 PRE_first_tail_x15_r0_body.cbd109 PRE_first_tail_x15_r0_body.csst109
  exact PRE_first_tail_x15_r0_body.cshift109 PRE_first_tail_x15_r0_body.ncl1059 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_109] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR110
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 110 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1063`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR110 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1063.tab.length PRE_first_tail_x15_r0_body.s1063.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P110.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P110 4756 PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.s1065.ffi PRE_first_tail_x15_r0_body.s1064.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_110
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_110
  have hcl : SSt (· < 4756) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1063.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_110] <;> decide) PRE_first_tail_x15_r0_body.cnodesK110 PRE_first_tail_x15_r0_body.cobjsK110
      PRE_first_tail_x15_r0_body.citemsK110 PRE_first_tail_x15_r0_body.cbd110 PRE_first_tail_x15_r0_body.csst110
  exact PRE_first_tail_x15_r0_body.cshift110 PRE_first_tail_x15_r0_body.ncl1063 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_110] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR111
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 111 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1080`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR111 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1080.tab.length PRE_first_tail_x15_r0_body.s1080.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P111.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P111 4847 PRE_first_tail_x15_r0_body.kappa111 PRE_first_tail_x15_r0_body.s1082.ffi PRE_first_tail_x15_r0_body.s1081.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_111
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_111
  have hcl : SSt (· < 4847) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1082.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1080.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_111] <;> decide) PRE_first_tail_x15_r0_body.cnodesK111 PRE_first_tail_x15_r0_body.cobjsK111
      PRE_first_tail_x15_r0_body.citemsK111 PRE_first_tail_x15_r0_body.cbd111 PRE_first_tail_x15_r0_body.csst111
  exact PRE_first_tail_x15_r0_body.cshift111 PRE_first_tail_x15_r0_body.ncl1080 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_111] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR112
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 112 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1088`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR112 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1088.tab.length PRE_first_tail_x15_r0_body.s1088.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P112.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P112 4868 PRE_first_tail_x15_r0_body.kappa112 PRE_first_tail_x15_r0_body.s1090.ffi PRE_first_tail_x15_r0_body.s1089.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_112
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_112
  have hcl : SSt (· < 4868) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1090.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1088.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_112] <;> decide) PRE_first_tail_x15_r0_body.cnodesK112 PRE_first_tail_x15_r0_body.cobjsK112
      PRE_first_tail_x15_r0_body.citemsK112 PRE_first_tail_x15_r0_body.cbd112 PRE_first_tail_x15_r0_body.csst112
  exact PRE_first_tail_x15_r0_body.cshift112 PRE_first_tail_x15_r0_body.ncl1088 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_112] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR113
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 113 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1092`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR113 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1092.tab.length PRE_first_tail_x15_r0_body.s1092.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P113.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P113 4885 PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.s1094.ffi PRE_first_tail_x15_r0_body.s1093.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_113
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_113
  have hcl : SSt (· < 4885) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1094.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1092.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_113] <;> decide) PRE_first_tail_x15_r0_body.cnodesK113 PRE_first_tail_x15_r0_body.cobjsK113
      PRE_first_tail_x15_r0_body.citemsK113 PRE_first_tail_x15_r0_body.cbd113 PRE_first_tail_x15_r0_body.csst113
  exact PRE_first_tail_x15_r0_body.cshift113 PRE_first_tail_x15_r0_body.ncl1092 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_113] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR114
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 114 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1109`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR114 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1109.tab.length PRE_first_tail_x15_r0_body.s1109.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P114.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P114 4976 PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.s1111.ffi PRE_first_tail_x15_r0_body.s1110.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_114
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_114
  have hcl : SSt (· < 4976) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1111.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1109.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_114] <;> decide) PRE_first_tail_x15_r0_body.cnodesK114 PRE_first_tail_x15_r0_body.cobjsK114
      PRE_first_tail_x15_r0_body.citemsK114 PRE_first_tail_x15_r0_body.cbd114 PRE_first_tail_x15_r0_body.csst114
  exact PRE_first_tail_x15_r0_body.cshift114 PRE_first_tail_x15_r0_body.ncl1109 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_114] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR115
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 115 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1117`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR115 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1117.tab.length PRE_first_tail_x15_r0_body.s1117.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P115.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P115 4997 PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.s1119.ffi PRE_first_tail_x15_r0_body.s1118.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_115
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_115
  have hcl : SSt (· < 4997) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1117.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_115] <;> decide) PRE_first_tail_x15_r0_body.cnodesK115 PRE_first_tail_x15_r0_body.cobjsK115
      PRE_first_tail_x15_r0_body.citemsK115 PRE_first_tail_x15_r0_body.cbd115 PRE_first_tail_x15_r0_body.csst115
  exact PRE_first_tail_x15_r0_body.cshift115 PRE_first_tail_x15_r0_body.ncl1117 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_115] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR116
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 116 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1121`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR116 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1121.tab.length PRE_first_tail_x15_r0_body.s1121.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P116.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P116 5014 PRE_first_tail_x15_r0_body.kappa116 PRE_first_tail_x15_r0_body.s1123.ffi PRE_first_tail_x15_r0_body.s1122.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_116
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_116
  have hcl : SSt (· < 5014) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1123.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1121.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_116] <;> decide) PRE_first_tail_x15_r0_body.cnodesK116 PRE_first_tail_x15_r0_body.cobjsK116
      PRE_first_tail_x15_r0_body.citemsK116 PRE_first_tail_x15_r0_body.cbd116 PRE_first_tail_x15_r0_body.csst116
  exact PRE_first_tail_x15_r0_body.cshift116 PRE_first_tail_x15_r0_body.ncl1121 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_116] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR117
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 117 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1137`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR117 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1137.tab.length PRE_first_tail_x15_r0_body.s1137.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P117.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P117 5100 PRE_first_tail_x15_r0_body.kappa117 PRE_first_tail_x15_r0_body.s1139.ffi PRE_first_tail_x15_r0_body.s1138.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_117
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_117
  have hcl : SSt (· < 5100) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1137.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_117] <;> decide) PRE_first_tail_x15_r0_body.cnodesK117 PRE_first_tail_x15_r0_body.cobjsK117
      PRE_first_tail_x15_r0_body.citemsK117 PRE_first_tail_x15_r0_body.cbd117 PRE_first_tail_x15_r0_body.csst117
  exact PRE_first_tail_x15_r0_body.cshift117 PRE_first_tail_x15_r0_body.ncl1137 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_117] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR118
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 118 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1145`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR118 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1145.tab.length PRE_first_tail_x15_r0_body.s1145.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P118.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P118 5123 PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.s1147.ffi PRE_first_tail_x15_r0_body.s1146.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_118
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_118
  have hcl : SSt (· < 5123) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1147.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1145.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_118] <;> decide) PRE_first_tail_x15_r0_body.cnodesK118 PRE_first_tail_x15_r0_body.cobjsK118
      PRE_first_tail_x15_r0_body.citemsK118 PRE_first_tail_x15_r0_body.cbd118 PRE_first_tail_x15_r0_body.csst118
  exact PRE_first_tail_x15_r0_body.cshift118 PRE_first_tail_x15_r0_body.ncl1145 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_118] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR119
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 119 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1149`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR119 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1149.tab.length PRE_first_tail_x15_r0_body.s1149.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P119.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P119 5140 PRE_first_tail_x15_r0_body.kappa119 PRE_first_tail_x15_r0_body.s1151.ffi PRE_first_tail_x15_r0_body.s1150.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_119
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_119
  have hcl : SSt (· < 5140) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1149.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_119] <;> decide) PRE_first_tail_x15_r0_body.cnodesK119 PRE_first_tail_x15_r0_body.cobjsK119
      PRE_first_tail_x15_r0_body.citemsK119 PRE_first_tail_x15_r0_body.cbd119 PRE_first_tail_x15_r0_body.csst119
  exact PRE_first_tail_x15_r0_body.cshift119 PRE_first_tail_x15_r0_body.ncl1149 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_119] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR120
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 120 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1166`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR120 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1166.tab.length PRE_first_tail_x15_r0_body.s1166.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P120.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P120 5231 PRE_first_tail_x15_r0_body.kappa120 PRE_first_tail_x15_r0_body.s1168.ffi PRE_first_tail_x15_r0_body.s1167.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_120
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_120
  have hcl : SSt (· < 5231) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1166.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_120] <;> decide) PRE_first_tail_x15_r0_body.cnodesK120 PRE_first_tail_x15_r0_body.cobjsK120
      PRE_first_tail_x15_r0_body.citemsK120 PRE_first_tail_x15_r0_body.cbd120 PRE_first_tail_x15_r0_body.csst120
  exact PRE_first_tail_x15_r0_body.cshift120 PRE_first_tail_x15_r0_body.ncl1166 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_120] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR121
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 121 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1174`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR121 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1174.tab.length PRE_first_tail_x15_r0_body.s1174.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P121.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.s1176.ffi PRE_first_tail_x15_r0_body.s1175.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_121
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_121
  have hcl : SSt (· < 5252) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1174.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_121] <;> decide) PRE_first_tail_x15_r0_body.cnodesK121 PRE_first_tail_x15_r0_body.cobjsK121
      PRE_first_tail_x15_r0_body.citemsK121 PRE_first_tail_x15_r0_body.cbd121 PRE_first_tail_x15_r0_body.csst121
  exact PRE_first_tail_x15_r0_body.cshift121 PRE_first_tail_x15_r0_body.ncl1174 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_121] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR122
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 122 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1178`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR122 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1178.tab.length PRE_first_tail_x15_r0_body.s1178.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P122.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P122 5269 PRE_first_tail_x15_r0_body.kappa122 PRE_first_tail_x15_r0_body.s1180.ffi PRE_first_tail_x15_r0_body.s1179.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_122
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_122
  have hcl : SSt (· < 5269) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1180.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1178.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_122] <;> decide) PRE_first_tail_x15_r0_body.cnodesK122 PRE_first_tail_x15_r0_body.cobjsK122
      PRE_first_tail_x15_r0_body.citemsK122 PRE_first_tail_x15_r0_body.cbd122 PRE_first_tail_x15_r0_body.csst122
  exact PRE_first_tail_x15_r0_body.cshift122 PRE_first_tail_x15_r0_body.ncl1178 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_122] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR123
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 123 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1195`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR123 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1195.tab.length PRE_first_tail_x15_r0_body.s1195.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P123.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.s1197.ffi PRE_first_tail_x15_r0_body.s1196.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_123
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_123
  have hcl : SSt (· < 5360) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1195.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_123] <;> decide) PRE_first_tail_x15_r0_body.cnodesK123 PRE_first_tail_x15_r0_body.cobjsK123
      PRE_first_tail_x15_r0_body.citemsK123 PRE_first_tail_x15_r0_body.cbd123 PRE_first_tail_x15_r0_body.csst123
  exact PRE_first_tail_x15_r0_body.cshift123 PRE_first_tail_x15_r0_body.ncl1195 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_123] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR124
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 124 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1203`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR124 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1203.tab.length PRE_first_tail_x15_r0_body.s1203.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P124.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P124 5381 PRE_first_tail_x15_r0_body.kappa124 PRE_first_tail_x15_r0_body.s1205.ffi PRE_first_tail_x15_r0_body.s1204.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_124
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_124
  have hcl : SSt (· < 5381) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1205.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1203.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_124] <;> decide) PRE_first_tail_x15_r0_body.cnodesK124 PRE_first_tail_x15_r0_body.cobjsK124
      PRE_first_tail_x15_r0_body.citemsK124 PRE_first_tail_x15_r0_body.cbd124 PRE_first_tail_x15_r0_body.csst124
  exact PRE_first_tail_x15_r0_body.cshift124 PRE_first_tail_x15_r0_body.ncl1203 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_124] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR125
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 125 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1207`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR125 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1207.tab.length PRE_first_tail_x15_r0_body.s1207.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P125.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P125 5398 PRE_first_tail_x15_r0_body.kappa125 PRE_first_tail_x15_r0_body.s1209.ffi PRE_first_tail_x15_r0_body.s1208.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_125
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_125
  have hcl : SSt (· < 5398) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1207.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_125] <;> decide) PRE_first_tail_x15_r0_body.cnodesK125 PRE_first_tail_x15_r0_body.cobjsK125
      PRE_first_tail_x15_r0_body.citemsK125 PRE_first_tail_x15_r0_body.cbd125 PRE_first_tail_x15_r0_body.csst125
  exact PRE_first_tail_x15_r0_body.cshift125 PRE_first_tail_x15_r0_body.ncl1207 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_125] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR126
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 126 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1224`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR126 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1224.tab.length PRE_first_tail_x15_r0_body.s1224.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P126.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P126 5489 PRE_first_tail_x15_r0_body.kappa126 PRE_first_tail_x15_r0_body.s1226.ffi PRE_first_tail_x15_r0_body.s1225.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_126
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_126
  have hcl : SSt (· < 5489) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1224.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_126] <;> decide) PRE_first_tail_x15_r0_body.cnodesK126 PRE_first_tail_x15_r0_body.cobjsK126
      PRE_first_tail_x15_r0_body.citemsK126 PRE_first_tail_x15_r0_body.cbd126 PRE_first_tail_x15_r0_body.csst126
  exact PRE_first_tail_x15_r0_body.cshift126 PRE_first_tail_x15_r0_body.ncl1224 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_126] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR127
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 127 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1232`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR127 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1232.tab.length PRE_first_tail_x15_r0_body.s1232.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P127.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.s1234.ffi PRE_first_tail_x15_r0_body.s1233.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_127
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_127
  have hcl : SSt (· < 5510) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1232.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_127] <;> decide) PRE_first_tail_x15_r0_body.cnodesK127 PRE_first_tail_x15_r0_body.cobjsK127
      PRE_first_tail_x15_r0_body.citemsK127 PRE_first_tail_x15_r0_body.cbd127 PRE_first_tail_x15_r0_body.csst127
  exact PRE_first_tail_x15_r0_body.cshift127 PRE_first_tail_x15_r0_body.ncl1232 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_127] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR128
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 128 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1236`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR128 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1236.tab.length PRE_first_tail_x15_r0_body.s1236.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P128.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P128 5527 PRE_first_tail_x15_r0_body.kappa128 PRE_first_tail_x15_r0_body.s1238.ffi PRE_first_tail_x15_r0_body.s1237.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_128
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_128
  have hcl : SSt (· < 5527) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1238.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1236.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_128] <;> decide) PRE_first_tail_x15_r0_body.cnodesK128 PRE_first_tail_x15_r0_body.cobjsK128
      PRE_first_tail_x15_r0_body.citemsK128 PRE_first_tail_x15_r0_body.cbd128 PRE_first_tail_x15_r0_body.csst128
  exact PRE_first_tail_x15_r0_body.cshift128 PRE_first_tail_x15_r0_body.ncl1236 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_128] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR129
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 129 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1252`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR129 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1252.tab.length PRE_first_tail_x15_r0_body.s1252.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P129.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P129 5613 PRE_first_tail_x15_r0_body.kappa129 PRE_first_tail_x15_r0_body.s1254.ffi PRE_first_tail_x15_r0_body.s1253.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_129
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_129
  have hcl : SSt (· < 5613) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1252.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_129] <;> decide) PRE_first_tail_x15_r0_body.cnodesK129 PRE_first_tail_x15_r0_body.cobjsK129
      PRE_first_tail_x15_r0_body.citemsK129 PRE_first_tail_x15_r0_body.cbd129 PRE_first_tail_x15_r0_body.csst129
  exact PRE_first_tail_x15_r0_body.cshift129 PRE_first_tail_x15_r0_body.ncl1252 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_129] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR130
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 130 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1260`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR130 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1260.tab.length PRE_first_tail_x15_r0_body.s1260.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P130.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.s1262.ffi PRE_first_tail_x15_r0_body.s1261.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_130
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_130
  have hcl : SSt (· < 5636) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1260.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_130] <;> decide) PRE_first_tail_x15_r0_body.cnodesK130 PRE_first_tail_x15_r0_body.cobjsK130
      PRE_first_tail_x15_r0_body.citemsK130 PRE_first_tail_x15_r0_body.cbd130 PRE_first_tail_x15_r0_body.csst130
  exact PRE_first_tail_x15_r0_body.cshift130 PRE_first_tail_x15_r0_body.ncl1260 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_130] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR131
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 131 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1264`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR131 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1264.tab.length PRE_first_tail_x15_r0_body.s1264.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P131.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.s1266.ffi PRE_first_tail_x15_r0_body.s1265.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_131
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_131
  have hcl : SSt (· < 5653) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1264.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_131] <;> decide) PRE_first_tail_x15_r0_body.cnodesK131 PRE_first_tail_x15_r0_body.cobjsK131
      PRE_first_tail_x15_r0_body.citemsK131 PRE_first_tail_x15_r0_body.cbd131 PRE_first_tail_x15_r0_body.csst131
  exact PRE_first_tail_x15_r0_body.cshift131 PRE_first_tail_x15_r0_body.ncl1264 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_131] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 132 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1281`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR132 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1281.tab.length PRE_first_tail_x15_r0_body.s1281.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P132.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.s1283.ffi PRE_first_tail_x15_r0_body.s1282.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_132
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_132
  have hcl : SSt (· < 5744) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1281.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_132] <;> decide) PRE_first_tail_x15_r0_body.cnodesK132 PRE_first_tail_x15_r0_body.cobjsK132
      PRE_first_tail_x15_r0_body.citemsK132 PRE_first_tail_x15_r0_body.cbd132 PRE_first_tail_x15_r0_body.csst132
  exact PRE_first_tail_x15_r0_body.cshift132 PRE_first_tail_x15_r0_body.ncl1281 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_132] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 133 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1289`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR133 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1289.tab.length PRE_first_tail_x15_r0_body.s1289.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P133.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.s1291.ffi PRE_first_tail_x15_r0_body.s1290.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_133
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_133
  have hcl : SSt (· < 5765) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1289.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_133] <;> decide) PRE_first_tail_x15_r0_body.cnodesK133 PRE_first_tail_x15_r0_body.cobjsK133
      PRE_first_tail_x15_r0_body.citemsK133 PRE_first_tail_x15_r0_body.cbd133 PRE_first_tail_x15_r0_body.csst133
  exact PRE_first_tail_x15_r0_body.cshift133 PRE_first_tail_x15_r0_body.ncl1289 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_133] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 134 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1293`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR134 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1293.tab.length PRE_first_tail_x15_r0_body.s1293.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P134.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.s1295.ffi PRE_first_tail_x15_r0_body.s1294.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_134
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_134
  have hcl : SSt (· < 5782) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1293.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_134] <;> decide) PRE_first_tail_x15_r0_body.cnodesK134 PRE_first_tail_x15_r0_body.cobjsK134
      PRE_first_tail_x15_r0_body.citemsK134 PRE_first_tail_x15_r0_body.cbd134 PRE_first_tail_x15_r0_body.csst134
  exact PRE_first_tail_x15_r0_body.cshift134 PRE_first_tail_x15_r0_body.ncl1293 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_134] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 135 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1310`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR135 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1310.tab.length PRE_first_tail_x15_r0_body.s1310.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P135.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.s1312.ffi PRE_first_tail_x15_r0_body.s1311.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_135
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_135
  have hcl : SSt (· < 5873) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1310.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_135] <;> decide) PRE_first_tail_x15_r0_body.cnodesK135 PRE_first_tail_x15_r0_body.cobjsK135
      PRE_first_tail_x15_r0_body.citemsK135 PRE_first_tail_x15_r0_body.cbd135 PRE_first_tail_x15_r0_body.csst135
  exact PRE_first_tail_x15_r0_body.cshift135 PRE_first_tail_x15_r0_body.ncl1310 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_135] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 136 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1318`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR136 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1318.tab.length PRE_first_tail_x15_r0_body.s1318.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P136.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.s1320.ffi PRE_first_tail_x15_r0_body.s1319.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_136
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_136
  have hcl : SSt (· < 5894) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1318.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_136] <;> decide) PRE_first_tail_x15_r0_body.cnodesK136 PRE_first_tail_x15_r0_body.cobjsK136
      PRE_first_tail_x15_r0_body.citemsK136 PRE_first_tail_x15_r0_body.cbd136 PRE_first_tail_x15_r0_body.csst136
  exact PRE_first_tail_x15_r0_body.cshift136 PRE_first_tail_x15_r0_body.ncl1318 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_136] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 137 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1322`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR137 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1322.tab.length PRE_first_tail_x15_r0_body.s1322.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P137.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.s1324.ffi PRE_first_tail_x15_r0_body.s1323.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_137
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_137
  have hcl : SSt (· < 5911) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1322.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_137] <;> decide) PRE_first_tail_x15_r0_body.cnodesK137 PRE_first_tail_x15_r0_body.cobjsK137
      PRE_first_tail_x15_r0_body.citemsK137 PRE_first_tail_x15_r0_body.cbd137 PRE_first_tail_x15_r0_body.csst137
  exact PRE_first_tail_x15_r0_body.cshift137 PRE_first_tail_x15_r0_body.ncl1322 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_137] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 138 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1339`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR138 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1339.tab.length PRE_first_tail_x15_r0_body.s1339.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P138.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.s1341.ffi PRE_first_tail_x15_r0_body.s1340.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_138
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_138
  have hcl : SSt (· < 6002) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1339.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_138] <;> decide) PRE_first_tail_x15_r0_body.cnodesK138 PRE_first_tail_x15_r0_body.cobjsK138
      PRE_first_tail_x15_r0_body.citemsK138 PRE_first_tail_x15_r0_body.cbd138 PRE_first_tail_x15_r0_body.csst138
  exact PRE_first_tail_x15_r0_body.cshift138 PRE_first_tail_x15_r0_body.ncl1339 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_138] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 139 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1347`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR139 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1347.tab.length PRE_first_tail_x15_r0_body.s1347.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P139.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.s1349.ffi PRE_first_tail_x15_r0_body.s1348.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_139
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_139
  have hcl : SSt (· < 6023) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1347.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_139] <;> decide) PRE_first_tail_x15_r0_body.cnodesK139 PRE_first_tail_x15_r0_body.cobjsK139
      PRE_first_tail_x15_r0_body.citemsK139 PRE_first_tail_x15_r0_body.cbd139 PRE_first_tail_x15_r0_body.csst139
  exact PRE_first_tail_x15_r0_body.cshift139 PRE_first_tail_x15_r0_body.ncl1347 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_139] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 140 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1351`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR140 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1351.tab.length PRE_first_tail_x15_r0_body.s1351.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P140.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.s1353.ffi PRE_first_tail_x15_r0_body.s1352.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_140
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_140
  have hcl : SSt (· < 6040) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1351.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_140] <;> decide) PRE_first_tail_x15_r0_body.cnodesK140 PRE_first_tail_x15_r0_body.cobjsK140
      PRE_first_tail_x15_r0_body.citemsK140 PRE_first_tail_x15_r0_body.cbd140 PRE_first_tail_x15_r0_body.csst140
  exact PRE_first_tail_x15_r0_body.cshift140 PRE_first_tail_x15_r0_body.ncl1351 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_140] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 141 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1367`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR141 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1367.tab.length PRE_first_tail_x15_r0_body.s1367.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P141.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.s1369.ffi PRE_first_tail_x15_r0_body.s1368.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_141
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_141
  have hcl : SSt (· < 6126) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1367.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_141] <;> decide) PRE_first_tail_x15_r0_body.cnodesK141 PRE_first_tail_x15_r0_body.cobjsK141
      PRE_first_tail_x15_r0_body.citemsK141 PRE_first_tail_x15_r0_body.cbd141 PRE_first_tail_x15_r0_body.csst141
  exact PRE_first_tail_x15_r0_body.cshift141 PRE_first_tail_x15_r0_body.ncl1367 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_141] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 142 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1375`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR142 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1375.tab.length PRE_first_tail_x15_r0_body.s1375.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P142.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.s1377.ffi PRE_first_tail_x15_r0_body.s1376.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_142
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_142
  have hcl : SSt (· < 6149) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1375.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_142] <;> decide) PRE_first_tail_x15_r0_body.cnodesK142 PRE_first_tail_x15_r0_body.cobjsK142
      PRE_first_tail_x15_r0_body.citemsK142 PRE_first_tail_x15_r0_body.cbd142 PRE_first_tail_x15_r0_body.csst142
  exact PRE_first_tail_x15_r0_body.cshift142 PRE_first_tail_x15_r0_body.ncl1375 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_142] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR143
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 143 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1379`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR143 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1379.tab.length PRE_first_tail_x15_r0_body.s1379.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P143.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P143 6166 PRE_first_tail_x15_r0_body.kappa143 PRE_first_tail_x15_r0_body.s1381.ffi PRE_first_tail_x15_r0_body.s1380.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_143
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_143
  have hcl : SSt (· < 6166) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1379.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_143] <;> decide) PRE_first_tail_x15_r0_body.cnodesK143 PRE_first_tail_x15_r0_body.cobjsK143
      PRE_first_tail_x15_r0_body.citemsK143 PRE_first_tail_x15_r0_body.cbd143 PRE_first_tail_x15_r0_body.csst143
  exact PRE_first_tail_x15_r0_body.cshift143 PRE_first_tail_x15_r0_body.ncl1379 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_143] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR144
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 144 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1396`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR144 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1396.tab.length PRE_first_tail_x15_r0_body.s1396.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P144.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P144 6257 PRE_first_tail_x15_r0_body.kappa144 PRE_first_tail_x15_r0_body.s1398.ffi PRE_first_tail_x15_r0_body.s1397.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_144
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_144
  have hcl : SSt (· < 6257) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1396.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_144] <;> decide) PRE_first_tail_x15_r0_body.cnodesK144 PRE_first_tail_x15_r0_body.cobjsK144
      PRE_first_tail_x15_r0_body.citemsK144 PRE_first_tail_x15_r0_body.cbd144 PRE_first_tail_x15_r0_body.csst144
  exact PRE_first_tail_x15_r0_body.cshift144 PRE_first_tail_x15_r0_body.ncl1396 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_144] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR145
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 145 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1404`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR145 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1404.tab.length PRE_first_tail_x15_r0_body.s1404.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P145.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P145 6278 PRE_first_tail_x15_r0_body.kappa145 PRE_first_tail_x15_r0_body.s1406.ffi PRE_first_tail_x15_r0_body.s1405.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_145
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_145
  have hcl : SSt (· < 6278) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1404.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_145] <;> decide) PRE_first_tail_x15_r0_body.cnodesK145 PRE_first_tail_x15_r0_body.cobjsK145
      PRE_first_tail_x15_r0_body.citemsK145 PRE_first_tail_x15_r0_body.cbd145 PRE_first_tail_x15_r0_body.csst145
  exact PRE_first_tail_x15_r0_body.cshift145 PRE_first_tail_x15_r0_body.ncl1404 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_145] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR146
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 146 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1408`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR146 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1408.tab.length PRE_first_tail_x15_r0_body.s1408.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P146.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P146 6295 PRE_first_tail_x15_r0_body.kappa146 PRE_first_tail_x15_r0_body.s1410.ffi PRE_first_tail_x15_r0_body.s1409.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_146
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_146
  have hcl : SSt (· < 6295) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1410.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1408.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_146] <;> decide) PRE_first_tail_x15_r0_body.cnodesK146 PRE_first_tail_x15_r0_body.cobjsK146
      PRE_first_tail_x15_r0_body.citemsK146 PRE_first_tail_x15_r0_body.cbd146 PRE_first_tail_x15_r0_body.csst146
  exact PRE_first_tail_x15_r0_body.cshift146 PRE_first_tail_x15_r0_body.ncl1408 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_146] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR147
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 147 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1425`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR147 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1425.tab.length PRE_first_tail_x15_r0_body.s1425.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P147.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P147 6386 PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.s1427.ffi PRE_first_tail_x15_r0_body.s1426.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_147
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_147
  have hcl : SSt (· < 6386) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1425.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_147] <;> decide) PRE_first_tail_x15_r0_body.cnodesK147 PRE_first_tail_x15_r0_body.cobjsK147
      PRE_first_tail_x15_r0_body.citemsK147 PRE_first_tail_x15_r0_body.cbd147 PRE_first_tail_x15_r0_body.csst147
  exact PRE_first_tail_x15_r0_body.cshift147 PRE_first_tail_x15_r0_body.ncl1425 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_147] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR148
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 148 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1433`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR148 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1433.tab.length PRE_first_tail_x15_r0_body.s1433.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P148.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P148 6407 PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.s1435.ffi PRE_first_tail_x15_r0_body.s1434.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_148
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_148
  have hcl : SSt (· < 6407) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1433.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_148] <;> decide) PRE_first_tail_x15_r0_body.cnodesK148 PRE_first_tail_x15_r0_body.cobjsK148
      PRE_first_tail_x15_r0_body.citemsK148 PRE_first_tail_x15_r0_body.cbd148 PRE_first_tail_x15_r0_body.csst148
  exact PRE_first_tail_x15_r0_body.cshift148 PRE_first_tail_x15_r0_body.ncl1433 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_148] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR149
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 149 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1437`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR149 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1437.tab.length PRE_first_tail_x15_r0_body.s1437.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P149.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P149 6424 PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.s1439.ffi PRE_first_tail_x15_r0_body.s1438.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_149
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_149
  have hcl : SSt (· < 6424) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1437.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_149] <;> decide) PRE_first_tail_x15_r0_body.cnodesK149 PRE_first_tail_x15_r0_body.cobjsK149
      PRE_first_tail_x15_r0_body.citemsK149 PRE_first_tail_x15_r0_body.cbd149 PRE_first_tail_x15_r0_body.csst149
  exact PRE_first_tail_x15_r0_body.cshift149 PRE_first_tail_x15_r0_body.ncl1437 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_149] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR150
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 150 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1454`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR150 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1454.tab.length PRE_first_tail_x15_r0_body.s1454.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P150.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P150 6515 PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.s1456.ffi PRE_first_tail_x15_r0_body.s1455.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_150
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_150
  have hcl : SSt (· < 6515) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1454.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_150] <;> decide) PRE_first_tail_x15_r0_body.cnodesK150 PRE_first_tail_x15_r0_body.cobjsK150
      PRE_first_tail_x15_r0_body.citemsK150 PRE_first_tail_x15_r0_body.cbd150 PRE_first_tail_x15_r0_body.csst150
  exact PRE_first_tail_x15_r0_body.cshift150 PRE_first_tail_x15_r0_body.ncl1454 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_150] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR151
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 151 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1462`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR151 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1462.tab.length PRE_first_tail_x15_r0_body.s1462.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P151.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P151 6536 PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.s1464.ffi PRE_first_tail_x15_r0_body.s1463.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_151
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_151
  have hcl : SSt (· < 6536) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1462.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_151] <;> decide) PRE_first_tail_x15_r0_body.cnodesK151 PRE_first_tail_x15_r0_body.cobjsK151
      PRE_first_tail_x15_r0_body.citemsK151 PRE_first_tail_x15_r0_body.cbd151 PRE_first_tail_x15_r0_body.csst151
  exact PRE_first_tail_x15_r0_body.cshift151 PRE_first_tail_x15_r0_body.ncl1462 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_151] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR152
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 152 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1466`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR152 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1466.tab.length PRE_first_tail_x15_r0_body.s1466.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P152.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P152 6553 PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.s1468.ffi PRE_first_tail_x15_r0_body.s1467.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_152
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_152
  have hcl : SSt (· < 6553) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1466.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_152] <;> decide) PRE_first_tail_x15_r0_body.cnodesK152 PRE_first_tail_x15_r0_body.cobjsK152
      PRE_first_tail_x15_r0_body.citemsK152 PRE_first_tail_x15_r0_body.cbd152 PRE_first_tail_x15_r0_body.csst152
  exact PRE_first_tail_x15_r0_body.cshift152 PRE_first_tail_x15_r0_body.ncl1466 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_152] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR153
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 153 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1482`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR153 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1482.tab.length PRE_first_tail_x15_r0_body.s1482.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P153.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P153 6639 PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.s1484.ffi PRE_first_tail_x15_r0_body.s1483.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_153
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_153
  have hcl : SSt (· < 6639) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1482.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_153] <;> decide) PRE_first_tail_x15_r0_body.cnodesK153 PRE_first_tail_x15_r0_body.cobjsK153
      PRE_first_tail_x15_r0_body.citemsK153 PRE_first_tail_x15_r0_body.cbd153 PRE_first_tail_x15_r0_body.csst153
  exact PRE_first_tail_x15_r0_body.cshift153 PRE_first_tail_x15_r0_body.ncl1482 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_153] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR154
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 154 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1490`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR154 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1490.tab.length PRE_first_tail_x15_r0_body.s1490.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P154.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P154 6662 PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.s1492.ffi PRE_first_tail_x15_r0_body.s1491.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_154
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_154
  have hcl : SSt (· < 6662) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1490.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_154] <;> decide) PRE_first_tail_x15_r0_body.cnodesK154 PRE_first_tail_x15_r0_body.cobjsK154
      PRE_first_tail_x15_r0_body.citemsK154 PRE_first_tail_x15_r0_body.cbd154 PRE_first_tail_x15_r0_body.csst154
  exact PRE_first_tail_x15_r0_body.cshift154 PRE_first_tail_x15_r0_body.ncl1490 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_154] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR155
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 155 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1494`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR155 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1494.tab.length PRE_first_tail_x15_r0_body.s1494.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P155.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P155 6679 PRE_first_tail_x15_r0_body.kappa155 PRE_first_tail_x15_r0_body.s1496.ffi PRE_first_tail_x15_r0_body.s1495.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_155
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_155
  have hcl : SSt (· < 6679) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1496.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1494.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_155] <;> decide) PRE_first_tail_x15_r0_body.cnodesK155 PRE_first_tail_x15_r0_body.cobjsK155
      PRE_first_tail_x15_r0_body.citemsK155 PRE_first_tail_x15_r0_body.cbd155 PRE_first_tail_x15_r0_body.csst155
  exact PRE_first_tail_x15_r0_body.cshift155 PRE_first_tail_x15_r0_body.ncl1494 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_155] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR156
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 156 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1511`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR156 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1511.tab.length PRE_first_tail_x15_r0_body.s1511.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P156.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P156 6770 PRE_first_tail_x15_r0_body.kappa156 PRE_first_tail_x15_r0_body.s1513.ffi PRE_first_tail_x15_r0_body.s1512.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_156
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_156
  have hcl : SSt (· < 6770) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1513.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1511.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_156] <;> decide) PRE_first_tail_x15_r0_body.cnodesK156 PRE_first_tail_x15_r0_body.cobjsK156
      PRE_first_tail_x15_r0_body.citemsK156 PRE_first_tail_x15_r0_body.cbd156 PRE_first_tail_x15_r0_body.csst156
  exact PRE_first_tail_x15_r0_body.cshift156 PRE_first_tail_x15_r0_body.ncl1511 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_156] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR157
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 157 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1519`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR157 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1519.tab.length PRE_first_tail_x15_r0_body.s1519.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P157.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P157 6791 PRE_first_tail_x15_r0_body.kappa157 PRE_first_tail_x15_r0_body.s1521.ffi PRE_first_tail_x15_r0_body.s1520.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_157
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_157
  have hcl : SSt (· < 6791) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1521.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1519.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_157] <;> decide) PRE_first_tail_x15_r0_body.cnodesK157 PRE_first_tail_x15_r0_body.cobjsK157
      PRE_first_tail_x15_r0_body.citemsK157 PRE_first_tail_x15_r0_body.cbd157 PRE_first_tail_x15_r0_body.csst157
  exact PRE_first_tail_x15_r0_body.cshift157 PRE_first_tail_x15_r0_body.ncl1519 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_157] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR158
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 158 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1523`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR158 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1523.tab.length PRE_first_tail_x15_r0_body.s1523.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P158.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P158 6808 PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.s1525.ffi PRE_first_tail_x15_r0_body.s1524.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_158
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_158
  have hcl : SSt (· < 6808) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1525.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1523.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_158] <;> decide) PRE_first_tail_x15_r0_body.cnodesK158 PRE_first_tail_x15_r0_body.cobjsK158
      PRE_first_tail_x15_r0_body.citemsK158 PRE_first_tail_x15_r0_body.cbd158 PRE_first_tail_x15_r0_body.csst158
  exact PRE_first_tail_x15_r0_body.cshift158 PRE_first_tail_x15_r0_body.ncl1523 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_158] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR159
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 159 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1540`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR159 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1540.tab.length PRE_first_tail_x15_r0_body.s1540.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P159.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P159 6899 PRE_first_tail_x15_r0_body.kappa159 PRE_first_tail_x15_r0_body.s1542.ffi PRE_first_tail_x15_r0_body.s1541.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_159
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_159
  have hcl : SSt (· < 6899) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1542.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1540.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_159] <;> decide) PRE_first_tail_x15_r0_body.cnodesK159 PRE_first_tail_x15_r0_body.cobjsK159
      PRE_first_tail_x15_r0_body.citemsK159 PRE_first_tail_x15_r0_body.cbd159 PRE_first_tail_x15_r0_body.csst159
  exact PRE_first_tail_x15_r0_body.cshift159 PRE_first_tail_x15_r0_body.ncl1540 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_159] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR160
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 160 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1548`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR160 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1548.tab.length PRE_first_tail_x15_r0_body.s1548.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P160.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P160 6920 PRE_first_tail_x15_r0_body.kappa160 PRE_first_tail_x15_r0_body.s1550.ffi PRE_first_tail_x15_r0_body.s1549.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_160
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_160
  have hcl : SSt (· < 6920) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1550.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1548.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_160] <;> decide) PRE_first_tail_x15_r0_body.cnodesK160 PRE_first_tail_x15_r0_body.cobjsK160
      PRE_first_tail_x15_r0_body.citemsK160 PRE_first_tail_x15_r0_body.cbd160 PRE_first_tail_x15_r0_body.csst160
  exact PRE_first_tail_x15_r0_body.cshift160 PRE_first_tail_x15_r0_body.ncl1548 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_160] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR161
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 161 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1552`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR161 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1552.tab.length PRE_first_tail_x15_r0_body.s1552.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P161.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P161 6937 PRE_first_tail_x15_r0_body.kappa161 PRE_first_tail_x15_r0_body.s1554.ffi PRE_first_tail_x15_r0_body.s1553.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_161
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_161
  have hcl : SSt (· < 6937) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1552.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_161] <;> decide) PRE_first_tail_x15_r0_body.cnodesK161 PRE_first_tail_x15_r0_body.cobjsK161
      PRE_first_tail_x15_r0_body.citemsK161 PRE_first_tail_x15_r0_body.cbd161 PRE_first_tail_x15_r0_body.csst161
  exact PRE_first_tail_x15_r0_body.cshift161 PRE_first_tail_x15_r0_body.ncl1552 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_161] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR162
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 162 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1569`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR162 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1569.tab.length PRE_first_tail_x15_r0_body.s1569.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P162.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P162 7028 PRE_first_tail_x15_r0_body.kappa162 PRE_first_tail_x15_r0_body.s1571.ffi PRE_first_tail_x15_r0_body.s1570.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_162
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_162
  have hcl : SSt (· < 7028) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1569.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_162] <;> decide) PRE_first_tail_x15_r0_body.cnodesK162 PRE_first_tail_x15_r0_body.cobjsK162
      PRE_first_tail_x15_r0_body.citemsK162 PRE_first_tail_x15_r0_body.cbd162 PRE_first_tail_x15_r0_body.csst162
  exact PRE_first_tail_x15_r0_body.cshift162 PRE_first_tail_x15_r0_body.ncl1569 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_162] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR163
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 163 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1577`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR163 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1577.tab.length PRE_first_tail_x15_r0_body.s1577.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P163.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P163 7049 PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.s1579.ffi PRE_first_tail_x15_r0_body.s1578.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_163
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_163
  have hcl : SSt (· < 7049) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1577.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_163] <;> decide) PRE_first_tail_x15_r0_body.cnodesK163 PRE_first_tail_x15_r0_body.cobjsK163
      PRE_first_tail_x15_r0_body.citemsK163 PRE_first_tail_x15_r0_body.cbd163 PRE_first_tail_x15_r0_body.csst163
  exact PRE_first_tail_x15_r0_body.cshift163 PRE_first_tail_x15_r0_body.ncl1577 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_163] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR164
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 164 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1581`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR164 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1581.tab.length PRE_first_tail_x15_r0_body.s1581.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P164.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P164 7066 PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.s1583.ffi PRE_first_tail_x15_r0_body.s1582.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_164
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_164
  have hcl : SSt (· < 7066) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1581.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_164] <;> decide) PRE_first_tail_x15_r0_body.cnodesK164 PRE_first_tail_x15_r0_body.cobjsK164
      PRE_first_tail_x15_r0_body.citemsK164 PRE_first_tail_x15_r0_body.cbd164 PRE_first_tail_x15_r0_body.csst164
  exact PRE_first_tail_x15_r0_body.cshift164 PRE_first_tail_x15_r0_body.ncl1581 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_164] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR165
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 165 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1597`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR165 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1597.tab.length PRE_first_tail_x15_r0_body.s1597.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P165.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P165 7152 PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.s1599.ffi PRE_first_tail_x15_r0_body.s1598.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_165
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_165
  have hcl : SSt (· < 7152) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1597.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_165] <;> decide) PRE_first_tail_x15_r0_body.cnodesK165 PRE_first_tail_x15_r0_body.cobjsK165
      PRE_first_tail_x15_r0_body.citemsK165 PRE_first_tail_x15_r0_body.cbd165 PRE_first_tail_x15_r0_body.csst165
  exact PRE_first_tail_x15_r0_body.cshift165 PRE_first_tail_x15_r0_body.ncl1597 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_165] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR166
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 166 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1605`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR166 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1605.tab.length PRE_first_tail_x15_r0_body.s1605.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P166.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P166 7175 PRE_first_tail_x15_r0_body.kappa166 PRE_first_tail_x15_r0_body.s1607.ffi PRE_first_tail_x15_r0_body.s1606.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_166
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_166
  have hcl : SSt (· < 7175) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1605.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_166] <;> decide) PRE_first_tail_x15_r0_body.cnodesK166 PRE_first_tail_x15_r0_body.cobjsK166
      PRE_first_tail_x15_r0_body.citemsK166 PRE_first_tail_x15_r0_body.cbd166 PRE_first_tail_x15_r0_body.csst166
  exact PRE_first_tail_x15_r0_body.cshift166 PRE_first_tail_x15_r0_body.ncl1605 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_166] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR167
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 167 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1609`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR167 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1609.tab.length PRE_first_tail_x15_r0_body.s1609.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P167.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P167 7192 PRE_first_tail_x15_r0_body.kappa167 PRE_first_tail_x15_r0_body.s1611.ffi PRE_first_tail_x15_r0_body.s1610.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_167
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_167
  have hcl : SSt (· < 7192) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1609.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_167] <;> decide) PRE_first_tail_x15_r0_body.cnodesK167 PRE_first_tail_x15_r0_body.cobjsK167
      PRE_first_tail_x15_r0_body.citemsK167 PRE_first_tail_x15_r0_body.cbd167 PRE_first_tail_x15_r0_body.csst167
  exact PRE_first_tail_x15_r0_body.cshift167 PRE_first_tail_x15_r0_body.ncl1609 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_167] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR168
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 168 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1626`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR168 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1626.tab.length PRE_first_tail_x15_r0_body.s1626.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P168.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P168 7283 PRE_first_tail_x15_r0_body.kappa168 PRE_first_tail_x15_r0_body.s1628.ffi PRE_first_tail_x15_r0_body.s1627.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_168
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_168
  have hcl : SSt (· < 7283) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1626.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_168] <;> decide) PRE_first_tail_x15_r0_body.cnodesK168 PRE_first_tail_x15_r0_body.cobjsK168
      PRE_first_tail_x15_r0_body.citemsK168 PRE_first_tail_x15_r0_body.cbd168 PRE_first_tail_x15_r0_body.csst168
  exact PRE_first_tail_x15_r0_body.cshift168 PRE_first_tail_x15_r0_body.ncl1626 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_168] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR169
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 169 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1634`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR169 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1634.tab.length PRE_first_tail_x15_r0_body.s1634.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P169.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P169 7304 PRE_first_tail_x15_r0_body.kappa169 PRE_first_tail_x15_r0_body.s1636.ffi PRE_first_tail_x15_r0_body.s1635.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_169
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_169
  have hcl : SSt (· < 7304) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1636.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1634.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_169] <;> decide) PRE_first_tail_x15_r0_body.cnodesK169 PRE_first_tail_x15_r0_body.cobjsK169
      PRE_first_tail_x15_r0_body.citemsK169 PRE_first_tail_x15_r0_body.cbd169 PRE_first_tail_x15_r0_body.csst169
  exact PRE_first_tail_x15_r0_body.cshift169 PRE_first_tail_x15_r0_body.ncl1634 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_169] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR170
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 170 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1638`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR170 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1638.tab.length PRE_first_tail_x15_r0_body.s1638.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P170.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P170 7321 PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.s1640.ffi PRE_first_tail_x15_r0_body.s1639.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_170
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_170
  have hcl : SSt (· < 7321) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1638.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_170] <;> decide) PRE_first_tail_x15_r0_body.cnodesK170 PRE_first_tail_x15_r0_body.cobjsK170
      PRE_first_tail_x15_r0_body.citemsK170 PRE_first_tail_x15_r0_body.cbd170 PRE_first_tail_x15_r0_body.csst170
  exact PRE_first_tail_x15_r0_body.cshift170 PRE_first_tail_x15_r0_body.ncl1638 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_170] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR171
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 171 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1655`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR171 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1655.tab.length PRE_first_tail_x15_r0_body.s1655.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P171.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P171 7412 PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.s1657.ffi PRE_first_tail_x15_r0_body.s1656.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_171
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_171
  have hcl : SSt (· < 7412) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1655.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_171] <;> decide) PRE_first_tail_x15_r0_body.cnodesK171 PRE_first_tail_x15_r0_body.cobjsK171
      PRE_first_tail_x15_r0_body.citemsK171 PRE_first_tail_x15_r0_body.cbd171 PRE_first_tail_x15_r0_body.csst171
  exact PRE_first_tail_x15_r0_body.cshift171 PRE_first_tail_x15_r0_body.ncl1655 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_171] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR172
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 172 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1663`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR172 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1663.tab.length PRE_first_tail_x15_r0_body.s1663.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P172.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P172 7433 PRE_first_tail_x15_r0_body.kappa172 PRE_first_tail_x15_r0_body.s1665.ffi PRE_first_tail_x15_r0_body.s1664.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_172
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_172
  have hcl : SSt (· < 7433) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1663.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_172] <;> decide) PRE_first_tail_x15_r0_body.cnodesK172 PRE_first_tail_x15_r0_body.cobjsK172
      PRE_first_tail_x15_r0_body.citemsK172 PRE_first_tail_x15_r0_body.cbd172 PRE_first_tail_x15_r0_body.csst172
  exact PRE_first_tail_x15_r0_body.cshift172 PRE_first_tail_x15_r0_body.ncl1663 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_172] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR173
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 173 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1667`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR173 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1667.tab.length PRE_first_tail_x15_r0_body.s1667.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P173.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P173 7450 PRE_first_tail_x15_r0_body.kappa173 PRE_first_tail_x15_r0_body.s1669.ffi PRE_first_tail_x15_r0_body.s1668.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_173
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_173
  have hcl : SSt (· < 7450) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1667.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_173] <;> decide) PRE_first_tail_x15_r0_body.cnodesK173 PRE_first_tail_x15_r0_body.cobjsK173
      PRE_first_tail_x15_r0_body.citemsK173 PRE_first_tail_x15_r0_body.cbd173 PRE_first_tail_x15_r0_body.csst173
  exact PRE_first_tail_x15_r0_body.cshift173 PRE_first_tail_x15_r0_body.ncl1667 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_173] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR174
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 174 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1684`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR174 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1684.tab.length PRE_first_tail_x15_r0_body.s1684.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P174.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P174 7541 PRE_first_tail_x15_r0_body.kappa174 PRE_first_tail_x15_r0_body.s1686.ffi PRE_first_tail_x15_r0_body.s1685.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_174
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_174
  have hcl : SSt (· < 7541) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1684.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_174] <;> decide) PRE_first_tail_x15_r0_body.cnodesK174 PRE_first_tail_x15_r0_body.cobjsK174
      PRE_first_tail_x15_r0_body.citemsK174 PRE_first_tail_x15_r0_body.cbd174 PRE_first_tail_x15_r0_body.csst174
  exact PRE_first_tail_x15_r0_body.cshift174 PRE_first_tail_x15_r0_body.ncl1684 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_174] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR175
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 175 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1692`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR175 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1692.tab.length PRE_first_tail_x15_r0_body.s1692.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P175.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P175 7562 PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.s1694.ffi PRE_first_tail_x15_r0_body.s1693.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_175
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_175
  have hcl : SSt (· < 7562) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1694.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1692.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_175] <;> decide) PRE_first_tail_x15_r0_body.cnodesK175 PRE_first_tail_x15_r0_body.cobjsK175
      PRE_first_tail_x15_r0_body.citemsK175 PRE_first_tail_x15_r0_body.cbd175 PRE_first_tail_x15_r0_body.csst175
  exact PRE_first_tail_x15_r0_body.cshift175 PRE_first_tail_x15_r0_body.ncl1692 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_175] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR176
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 176 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1696`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR176 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1696.tab.length PRE_first_tail_x15_r0_body.s1696.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P176.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P176 7579 PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.s1698.ffi PRE_first_tail_x15_r0_body.s1697.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_176
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_176
  have hcl : SSt (· < 7579) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1698.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1696.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_176] <;> decide) PRE_first_tail_x15_r0_body.cnodesK176 PRE_first_tail_x15_r0_body.cobjsK176
      PRE_first_tail_x15_r0_body.citemsK176 PRE_first_tail_x15_r0_body.cbd176 PRE_first_tail_x15_r0_body.csst176
  exact PRE_first_tail_x15_r0_body.cshift176 PRE_first_tail_x15_r0_body.ncl1696 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_176] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR177
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 177 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1712`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR177 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1712.tab.length PRE_first_tail_x15_r0_body.s1712.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P177.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P177 7665 PRE_first_tail_x15_r0_body.kappa177 PRE_first_tail_x15_r0_body.s1714.ffi PRE_first_tail_x15_r0_body.s1713.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_177
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_177
  have hcl : SSt (· < 7665) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1712.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_177] <;> decide) PRE_first_tail_x15_r0_body.cnodesK177 PRE_first_tail_x15_r0_body.cobjsK177
      PRE_first_tail_x15_r0_body.citemsK177 PRE_first_tail_x15_r0_body.cbd177 PRE_first_tail_x15_r0_body.csst177
  exact PRE_first_tail_x15_r0_body.cshift177 PRE_first_tail_x15_r0_body.ncl1712 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_177] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR178
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 178 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1720`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR178 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1720.tab.length PRE_first_tail_x15_r0_body.s1720.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P178.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P178 7688 PRE_first_tail_x15_r0_body.kappa178 PRE_first_tail_x15_r0_body.s1722.ffi PRE_first_tail_x15_r0_body.s1721.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_178
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_178
  have hcl : SSt (· < 7688) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1722.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1720.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_178] <;> decide) PRE_first_tail_x15_r0_body.cnodesK178 PRE_first_tail_x15_r0_body.cobjsK178
      PRE_first_tail_x15_r0_body.citemsK178 PRE_first_tail_x15_r0_body.cbd178 PRE_first_tail_x15_r0_body.csst178
  exact PRE_first_tail_x15_r0_body.cshift178 PRE_first_tail_x15_r0_body.ncl1720 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_178] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR179
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 179 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1724`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR179 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1724.tab.length PRE_first_tail_x15_r0_body.s1724.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P179.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P179 7705 PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.s1726.ffi PRE_first_tail_x15_r0_body.s1725.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_179
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_179
  have hcl : SSt (· < 7705) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1726.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1724.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_179] <;> decide) PRE_first_tail_x15_r0_body.cnodesK179 PRE_first_tail_x15_r0_body.cobjsK179
      PRE_first_tail_x15_r0_body.citemsK179 PRE_first_tail_x15_r0_body.cbd179 PRE_first_tail_x15_r0_body.csst179
  exact PRE_first_tail_x15_r0_body.cshift179 PRE_first_tail_x15_r0_body.ncl1724 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_179] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR180
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 180 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1741`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR180 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1741.tab.length PRE_first_tail_x15_r0_body.s1741.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P180.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P180 7796 PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.s1743.ffi PRE_first_tail_x15_r0_body.s1742.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_180
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_180
  have hcl : SSt (· < 7796) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1741.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_180] <;> decide) PRE_first_tail_x15_r0_body.cnodesK180 PRE_first_tail_x15_r0_body.cobjsK180
      PRE_first_tail_x15_r0_body.citemsK180 PRE_first_tail_x15_r0_body.cbd180 PRE_first_tail_x15_r0_body.csst180
  exact PRE_first_tail_x15_r0_body.cshift180 PRE_first_tail_x15_r0_body.ncl1741 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_180] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR181
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 181 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1749`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR181 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1749.tab.length PRE_first_tail_x15_r0_body.s1749.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P181.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P181 7817 PRE_first_tail_x15_r0_body.kappa181 PRE_first_tail_x15_r0_body.s1751.ffi PRE_first_tail_x15_r0_body.s1750.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_181
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_181
  have hcl : SSt (· < 7817) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1749.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_181] <;> decide) PRE_first_tail_x15_r0_body.cnodesK181 PRE_first_tail_x15_r0_body.cobjsK181
      PRE_first_tail_x15_r0_body.citemsK181 PRE_first_tail_x15_r0_body.cbd181 PRE_first_tail_x15_r0_body.csst181
  exact PRE_first_tail_x15_r0_body.cshift181 PRE_first_tail_x15_r0_body.ncl1749 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_181] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR182
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 182 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1753`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR182 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1753.tab.length PRE_first_tail_x15_r0_body.s1753.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P182.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P182 7834 PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.s1755.ffi PRE_first_tail_x15_r0_body.s1754.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_182
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_182
  have hcl : SSt (· < 7834) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1755.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1753.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_182] <;> decide) PRE_first_tail_x15_r0_body.cnodesK182 PRE_first_tail_x15_r0_body.cobjsK182
      PRE_first_tail_x15_r0_body.citemsK182 PRE_first_tail_x15_r0_body.cbd182 PRE_first_tail_x15_r0_body.csst182
  exact PRE_first_tail_x15_r0_body.cshift182 PRE_first_tail_x15_r0_body.ncl1753 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_182] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR183
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 183 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1770`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR183 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1770.tab.length PRE_first_tail_x15_r0_body.s1770.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P183.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P183 7925 PRE_first_tail_x15_r0_body.kappa183 PRE_first_tail_x15_r0_body.s1772.ffi PRE_first_tail_x15_r0_body.s1771.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_183
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_183
  have hcl : SSt (· < 7925) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1770.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_183] <;> decide) PRE_first_tail_x15_r0_body.cnodesK183 PRE_first_tail_x15_r0_body.cobjsK183
      PRE_first_tail_x15_r0_body.citemsK183 PRE_first_tail_x15_r0_body.cbd183 PRE_first_tail_x15_r0_body.csst183
  exact PRE_first_tail_x15_r0_body.cshift183 PRE_first_tail_x15_r0_body.ncl1770 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_183] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR184
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 184 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1778`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR184 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1778.tab.length PRE_first_tail_x15_r0_body.s1778.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P184.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P184 7946 PRE_first_tail_x15_r0_body.kappa184 PRE_first_tail_x15_r0_body.s1780.ffi PRE_first_tail_x15_r0_body.s1779.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_184
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_184
  have hcl : SSt (· < 7946) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1780.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1778.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_184] <;> decide) PRE_first_tail_x15_r0_body.cnodesK184 PRE_first_tail_x15_r0_body.cobjsK184
      PRE_first_tail_x15_r0_body.citemsK184 PRE_first_tail_x15_r0_body.cbd184 PRE_first_tail_x15_r0_body.csst184
  exact PRE_first_tail_x15_r0_body.cshift184 PRE_first_tail_x15_r0_body.ncl1778 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_184] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR185
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 185 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1782`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR185 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1782.tab.length PRE_first_tail_x15_r0_body.s1782.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P185.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P185 7963 PRE_first_tail_x15_r0_body.kappa185 PRE_first_tail_x15_r0_body.s1784.ffi PRE_first_tail_x15_r0_body.s1783.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_185
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_185
  have hcl : SSt (· < 7963) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1782.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_185] <;> decide) PRE_first_tail_x15_r0_body.cnodesK185 PRE_first_tail_x15_r0_body.cobjsK185
      PRE_first_tail_x15_r0_body.citemsK185 PRE_first_tail_x15_r0_body.cbd185 PRE_first_tail_x15_r0_body.csst185
  exact PRE_first_tail_x15_r0_body.cshift185 PRE_first_tail_x15_r0_body.ncl1782 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_185] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR186
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 186 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1799`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR186 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1799.tab.length PRE_first_tail_x15_r0_body.s1799.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P186.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P186 8054 PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.s1801.ffi PRE_first_tail_x15_r0_body.s1800.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_186
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_186
  have hcl : SSt (· < 8054) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1799.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_186] <;> decide) PRE_first_tail_x15_r0_body.cnodesK186 PRE_first_tail_x15_r0_body.cobjsK186
      PRE_first_tail_x15_r0_body.citemsK186 PRE_first_tail_x15_r0_body.cbd186 PRE_first_tail_x15_r0_body.csst186
  exact PRE_first_tail_x15_r0_body.cshift186 PRE_first_tail_x15_r0_body.ncl1799 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_186] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR187
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 187 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1807`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR187 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1807.tab.length PRE_first_tail_x15_r0_body.s1807.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P187.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P187 8075 PRE_first_tail_x15_r0_body.kappa187 PRE_first_tail_x15_r0_body.s1809.ffi PRE_first_tail_x15_r0_body.s1808.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_187
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_187
  have hcl : SSt (· < 8075) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1807.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_187] <;> decide) PRE_first_tail_x15_r0_body.cnodesK187 PRE_first_tail_x15_r0_body.cobjsK187
      PRE_first_tail_x15_r0_body.citemsK187 PRE_first_tail_x15_r0_body.cbd187 PRE_first_tail_x15_r0_body.csst187
  exact PRE_first_tail_x15_r0_body.cshift187 PRE_first_tail_x15_r0_body.ncl1807 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_187] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR188
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 188 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1811`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR188 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1811.tab.length PRE_first_tail_x15_r0_body.s1811.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P188.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P188 8092 PRE_first_tail_x15_r0_body.kappa188 PRE_first_tail_x15_r0_body.s1813.ffi PRE_first_tail_x15_r0_body.s1812.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_188
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_188
  have hcl : SSt (· < 8092) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1811.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_188] <;> decide) PRE_first_tail_x15_r0_body.cnodesK188 PRE_first_tail_x15_r0_body.cobjsK188
      PRE_first_tail_x15_r0_body.citemsK188 PRE_first_tail_x15_r0_body.cbd188 PRE_first_tail_x15_r0_body.csst188
  exact PRE_first_tail_x15_r0_body.cshift188 PRE_first_tail_x15_r0_body.ncl1811 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_188] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR189
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 189 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1827`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR189 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1827.tab.length PRE_first_tail_x15_r0_body.s1827.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P189.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P189 8178 PRE_first_tail_x15_r0_body.kappa189 PRE_first_tail_x15_r0_body.s1829.ffi PRE_first_tail_x15_r0_body.s1828.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_189
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_189
  have hcl : SSt (· < 8178) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1827.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_189] <;> decide) PRE_first_tail_x15_r0_body.cnodesK189 PRE_first_tail_x15_r0_body.cobjsK189
      PRE_first_tail_x15_r0_body.citemsK189 PRE_first_tail_x15_r0_body.cbd189 PRE_first_tail_x15_r0_body.csst189
  exact PRE_first_tail_x15_r0_body.cshift189 PRE_first_tail_x15_r0_body.ncl1827 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_189] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR190
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 190 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1835`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR190 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1835.tab.length PRE_first_tail_x15_r0_body.s1835.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P190.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.s1837.ffi PRE_first_tail_x15_r0_body.s1836.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_190
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_190
  have hcl : SSt (· < 8201) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1835.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_190] <;> decide) PRE_first_tail_x15_r0_body.cnodesK190 PRE_first_tail_x15_r0_body.cobjsK190
      PRE_first_tail_x15_r0_body.citemsK190 PRE_first_tail_x15_r0_body.cbd190 PRE_first_tail_x15_r0_body.csst190
  exact PRE_first_tail_x15_r0_body.cshift190 PRE_first_tail_x15_r0_body.ncl1835 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_190] at this; exact this)

end Host.Load.Run.Tpl
end

section -- SiteR191
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 191 of chain `PRE_first_tail_x15_r0_body` from the call state's full relation: the call's bookkeeping (`PRE_first_tail_x15_r0_body.ncl1839`), the relation's native facts,
its observers' and the canonical closedness (`sst_of_callK`). -/

theorem PRE_first_tail_x15_r0_body.cshiftR191 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1839.tab.length PRE_first_tail_x15_r0_body.s1839.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P191.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P191 8218 PRE_first_tail_x15_r0_body.kappa191 PRE_first_tail_x15_r0_body.s1841.ffi PRE_first_tail_x15_r0_body.s1840.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_191
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_191
  have hcl : SSt (· < 8218) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1839.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_191] <;> decide) PRE_first_tail_x15_r0_body.cnodesK191 PRE_first_tail_x15_r0_body.cobjsK191
      PRE_first_tail_x15_r0_body.citemsK191 PRE_first_tail_x15_r0_body.cbd191 PRE_first_tail_x15_r0_body.csst191
  exact PRE_first_tail_x15_r0_body.cshift191 PRE_first_tail_x15_r0_body.ncl1839 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_191] at this; exact this)

end Host.Load.Run.Tpl
end
