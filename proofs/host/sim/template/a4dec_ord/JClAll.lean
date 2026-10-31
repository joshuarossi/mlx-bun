import host.sim.template.a4dec_ord.NCl0
import host.sim.template.a4dec_ord.SiteCl0
import host.sim.template.a4dec_ord.GlueN1
import host.sim.template.a4dec_ord.SiteCl1
import host.sim.template.a4dec_ord.GlueN2
import host.sim.template.a4dec_ord.SiteCl2
import host.sim.template.a4dec_ord.GlueN3
import host.sim.template.a4dec_ord.SiteZ0
import host.sim.template.a4dec_ord.SiteZ1
import host.sim.template.a4dec_ord.SiteZ2
import host.sim.template.a4dec_ord.EFacts
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The JS bookkeeping of chain `DEC_ord` at its end (boundary 11): the start's and every piece's step. -/

theorem DEC_ord.jcl0 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.s0 := DEC_ord.jclean0
theorem DEC_ord.jcl2 : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_ord.s2 := DEC_ord.cjcl0 DEC_ord.jcl0
theorem DEC_ord.jcl4 : Conv.JClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_ord.s4 := DEC_ord.gjcl1 DEC_ord.jcl2
theorem DEC_ord.jcl6 : Conv.JClean (⟨29432, 24913, 3123899, 353⟩ : Conv.Cnt) DEC_ord.s6 := DEC_ord.cjcl1 DEC_ord.jcl4
theorem DEC_ord.jcl8 : Conv.JClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s8 := DEC_ord.gjcl2 DEC_ord.jcl6
theorem DEC_ord.jcl10 : Conv.JClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s10 := DEC_ord.cjcl2 DEC_ord.jcl8
theorem DEC_ord.jcl11 : Conv.JClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s11 := DEC_ord.gjcl3 DEC_ord.jcl10
theorem DEC_ord.jclEnd : ∃ c, Conv.JClean c DEC_ord.s11 := ⟨_, DEC_ord.jcl11⟩

end Host.Load.Run.Tpl
