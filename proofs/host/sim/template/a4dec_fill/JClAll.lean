import host.sim.template.a4dec_fill.NCl0
import host.sim.template.a4dec_fill.SiteCl0
import host.sim.template.a4dec_fill.GlueN1
import host.sim.template.a4dec_fill.SiteCl1
import host.sim.template.a4dec_fill.GlueN2
import host.sim.template.a4dec_fill.SiteCl2
import host.sim.template.a4dec_fill.GlueN3
import host.sim.template.a4dec_fill.SiteZ0
import host.sim.template.a4dec_fill.SiteZ1
import host.sim.template.a4dec_fill.SiteZ2
import host.sim.template.a4dec_fill.EFacts
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The JS bookkeeping of chain `DEC_fill` at its end (boundary 11): the start's and every piece's step. -/

theorem DEC_fill.jcl0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_fill.s0 := DEC_fill.jclean0
theorem DEC_fill.jcl2 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_fill.s2 := DEC_fill.cjcl0 DEC_fill.jcl0
theorem DEC_fill.jcl4 : Conv.JClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_fill.s4 := DEC_fill.gjcl1 DEC_fill.jcl2
theorem DEC_fill.jcl6 : Conv.JClean (⟨29432, 24881, 3123899, 289⟩ : Conv.Cnt) DEC_fill.s6 := DEC_fill.cjcl1 DEC_fill.jcl4
theorem DEC_fill.jcl8 : Conv.JClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s8 := DEC_fill.gjcl2 DEC_fill.jcl6
theorem DEC_fill.jcl10 : Conv.JClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s10 := DEC_fill.cjcl2 DEC_fill.jcl8
theorem DEC_fill.jcl11 : Conv.JClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s11 := DEC_fill.gjcl3 DEC_fill.jcl10
theorem DEC_fill.jclEnd : ∃ c, Conv.JClean c DEC_fill.s11 := ⟨_, DEC_fill.jcl11⟩

end Host.Load.Run.Tpl
