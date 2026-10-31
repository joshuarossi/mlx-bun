import host.sim.template.a4dec_grow.NCl0
import host.sim.template.a4dec_grow.SiteCl0
import host.sim.template.a4dec_grow.GlueN1
import host.sim.template.a4dec_grow.SiteCl1
import host.sim.template.a4dec_grow.GlueN2
import host.sim.template.a4dec_grow.SiteCl2
import host.sim.template.a4dec_grow.GlueN3
import host.sim.template.a4dec_grow.SiteZ0
import host.sim.template.a4dec_grow.SiteZ1
import host.sim.template.a4dec_grow.SiteZ2
import host.sim.template.a4dec_grow.EFacts
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The JS bookkeeping of chain `DEC_grow` at its end (boundary 11): the start's and every piece's step. -/

theorem DEC_grow.jcl0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_grow.s0 := DEC_grow.jclean0
theorem DEC_grow.jcl2 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_grow.s2 := DEC_grow.cjcl0 DEC_grow.jcl0
theorem DEC_grow.jcl4 : Conv.JClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_grow.s4 := DEC_grow.gjcl1 DEC_grow.jcl2
theorem DEC_grow.jcl6 : Conv.JClean (⟨29432, 24977, 3123899, 385⟩ : Conv.Cnt) DEC_grow.s6 := DEC_grow.cjcl1 DEC_grow.jcl4
theorem DEC_grow.jcl8 : Conv.JClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s8 := DEC_grow.gjcl2 DEC_grow.jcl6
theorem DEC_grow.jcl10 : Conv.JClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s10 := DEC_grow.cjcl2 DEC_grow.jcl8
theorem DEC_grow.jcl11 : Conv.JClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s11 := DEC_grow.gjcl3 DEC_grow.jcl10
theorem DEC_grow.jclEnd : ∃ c, Conv.JClean c DEC_grow.s11 := ⟨_, DEC_grow.jcl11⟩

end Host.Load.Run.Tpl
