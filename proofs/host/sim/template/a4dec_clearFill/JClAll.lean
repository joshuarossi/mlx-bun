import host.sim.template.a4dec_clearFill.NCl0
import host.sim.template.a4dec_clearFill.SiteCl0
import host.sim.template.a4dec_clearFill.GlueN1
import host.sim.template.a4dec_clearFill.SiteCl1
import host.sim.template.a4dec_clearFill.GlueN2
import host.sim.template.a4dec_clearFill.SiteCl2
import host.sim.template.a4dec_clearFill.GlueN3
import host.sim.template.a4dec_clearFill.SiteZ0
import host.sim.template.a4dec_clearFill.SiteZ1
import host.sim.template.a4dec_clearFill.SiteZ2
import host.sim.template.a4dec_clearFill.EFacts
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The JS bookkeeping of chain `DEC_clearFill` at its end (boundary 11): the start's and every piece's step. -/

theorem DEC_clearFill.jcl0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.s0 := DEC_clearFill.jclean0
theorem DEC_clearFill.jcl2 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearFill.s2 := DEC_clearFill.cjcl0 DEC_clearFill.jcl0
theorem DEC_clearFill.jcl4 : Conv.JClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clearFill.s4 := DEC_clearFill.gjcl1 DEC_clearFill.jcl2
theorem DEC_clearFill.jcl6 : Conv.JClean (⟨29432, 24881, 3123900, 289⟩ : Conv.Cnt) DEC_clearFill.s6 := DEC_clearFill.cjcl1 DEC_clearFill.jcl4
theorem DEC_clearFill.jcl8 : Conv.JClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s8 := DEC_clearFill.gjcl2 DEC_clearFill.jcl6
theorem DEC_clearFill.jcl10 : Conv.JClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s10 := DEC_clearFill.cjcl2 DEC_clearFill.jcl8
theorem DEC_clearFill.jcl11 : Conv.JClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s11 := DEC_clearFill.gjcl3 DEC_clearFill.jcl10
theorem DEC_clearFill.jclEnd : ∃ c, Conv.JClean c DEC_clearFill.s11 := ⟨_, DEC_clearFill.jcl11⟩

end Host.Load.Run.Tpl
