import host.sim.template.a4dec_clearGrow.NCl0
import host.sim.template.a4dec_clearGrow.SiteCl0
import host.sim.template.a4dec_clearGrow.GlueN1
import host.sim.template.a4dec_clearGrow.SiteCl1
import host.sim.template.a4dec_clearGrow.GlueN2
import host.sim.template.a4dec_clearGrow.SiteCl2
import host.sim.template.a4dec_clearGrow.GlueN3
import host.sim.template.a4dec_clearGrow.SiteZ0
import host.sim.template.a4dec_clearGrow.SiteZ1
import host.sim.template.a4dec_clearGrow.SiteZ2
import host.sim.template.a4dec_clearGrow.EFacts
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The JS bookkeeping of chain `DEC_clearGrow` at its end (boundary 11): the start's and every piece's step. -/

theorem DEC_clearGrow.jcl0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearGrow.s0 := DEC_clearGrow.jclean0
theorem DEC_clearGrow.jcl2 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clearGrow.s2 := DEC_clearGrow.cjcl0 DEC_clearGrow.jcl0
theorem DEC_clearGrow.jcl4 : Conv.JClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clearGrow.s4 := DEC_clearGrow.gjcl1 DEC_clearGrow.jcl2
theorem DEC_clearGrow.jcl6 : Conv.JClean (⟨29432, 24977, 3123900, 385⟩ : Conv.Cnt) DEC_clearGrow.s6 := DEC_clearGrow.cjcl1 DEC_clearGrow.jcl4
theorem DEC_clearGrow.jcl8 : Conv.JClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s8 := DEC_clearGrow.gjcl2 DEC_clearGrow.jcl6
theorem DEC_clearGrow.jcl10 : Conv.JClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s10 := DEC_clearGrow.cjcl2 DEC_clearGrow.jcl8
theorem DEC_clearGrow.jcl11 : Conv.JClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s11 := DEC_clearGrow.gjcl3 DEC_clearGrow.jcl10
theorem DEC_clearGrow.jclEnd : ∃ c, Conv.JClean c DEC_clearGrow.s11 := ⟨_, DEC_clearGrow.jcl11⟩

end Host.Load.Run.Tpl
