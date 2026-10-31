import host.sim.template.a4dec_clear.NCl0
import host.sim.template.a4dec_clear.SiteCl0
import host.sim.template.a4dec_clear.GlueN1
import host.sim.template.a4dec_clear.SiteCl1
import host.sim.template.a4dec_clear.GlueN2
import host.sim.template.a4dec_clear.SiteCl2
import host.sim.template.a4dec_clear.GlueN3
import host.sim.template.a4dec_clear.SiteZ0
import host.sim.template.a4dec_clear.SiteZ1
import host.sim.template.a4dec_clear.SiteZ2
import host.sim.template.a4dec_clear.EFacts
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The JS bookkeeping of chain `DEC_clear` at its end (boundary 11): the start's and every piece's step. -/

theorem DEC_clear.jcl0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.s0 := DEC_clear.jclean0
theorem DEC_clear.jcl2 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_clear.s2 := DEC_clear.cjcl0 DEC_clear.jcl0
theorem DEC_clear.jcl4 : Conv.JClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clear.s4 := DEC_clear.gjcl1 DEC_clear.jcl2
theorem DEC_clear.jcl6 : Conv.JClean (⟨29432, 24913, 3123900, 353⟩ : Conv.Cnt) DEC_clear.s6 := DEC_clear.cjcl1 DEC_clear.jcl4
theorem DEC_clear.jcl8 : Conv.JClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s8 := DEC_clear.gjcl2 DEC_clear.jcl6
theorem DEC_clear.jcl10 : Conv.JClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s10 := DEC_clear.cjcl2 DEC_clear.jcl8
theorem DEC_clear.jcl11 : Conv.JClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s11 := DEC_clear.gjcl3 DEC_clear.jcl10
theorem DEC_clear.jclEnd : ∃ c, Conv.JClean c DEC_clear.s11 := ⟨_, DEC_clear.jcl11⟩

end Host.Load.Run.Tpl
