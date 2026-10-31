import host.sim.template.a4dec_ord.EEnd
import host.sim.template.a4dec_ord.SiteC0
import host.sim.template.a4dec_ord.SiteC1
import host.sim.template.a4dec_ord.SiteC2
import host.sim.template.a4dec_clear.EEnd
import host.sim.template.a4dec_clear.SiteC0
import host.sim.template.a4dec_clear.SiteC1
import host.sim.template.a4dec_clear.SiteC2
import host.sim.template.a4dec_grow.EEnd
import host.sim.template.a4dec_grow.SiteC0
import host.sim.template.a4dec_grow.SiteC1
import host.sim.template.a4dec_grow.SiteC2
import host.sim.template.a4dec_fill.EEnd
import host.sim.template.a4dec_fill.SiteC0
import host.sim.template.a4dec_fill.SiteC1
import host.sim.template.a4dec_fill.SiteC2
import host.sim.template.a4dec_clearFill.EEnd
import host.sim.template.a4dec_clearFill.SiteC0
import host.sim.template.a4dec_clearFill.SiteC1
import host.sim.template.a4dec_clearFill.SiteC2
import host.sim.template.a4dec_clearGrow.EEnd
import host.sim.template.a4dec_clearGrow.SiteC0
import host.sim.template.a4dec_clearGrow.SiteC1
import host.sim.template.a4dec_clearGrow.SiteC2
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.DEC.FixedCells

/-! Static map facts only. Preservation of these identities across actual iterations is a separate obligation. -/
kernel_rfl ord_restart_2586 : Host.Load.Run.Tpl.DEC_ord.σ.a 2586 = 2586
kernel_rfl ord_restart_2589 : Host.Load.Run.Tpl.DEC_ord.σ.a 2589 = 2589
kernel_rfl ord_kappa0_2586 : Host.Load.Run.Tpl.DEC_ord.kappa0.a 2586 = 2586
kernel_rfl ord_kappa0_2589 : Host.Load.Run.Tpl.DEC_ord.kappa0.a 2589 = 2589
kernel_rfl ord_kappa1_2586 : Host.Load.Run.Tpl.DEC_ord.kappa1.a 2586 = 2586
kernel_rfl ord_kappa1_2589 : Host.Load.Run.Tpl.DEC_ord.kappa1.a 2589 = 2589
kernel_rfl ord_kappa2_2586 : Host.Load.Run.Tpl.DEC_ord.kappa2.a 2586 = 2586
kernel_rfl ord_kappa2_2589 : Host.Load.Run.Tpl.DEC_ord.kappa2.a 2589 = 2589
kernel_rfl clear_restart_2586 : Host.Load.Run.Tpl.DEC_clear.σ.a 2586 = 2586
kernel_rfl clear_restart_2589 : Host.Load.Run.Tpl.DEC_clear.σ.a 2589 = 2589
kernel_rfl clear_kappa0_2586 : Host.Load.Run.Tpl.DEC_clear.kappa0.a 2586 = 2586
kernel_rfl clear_kappa0_2589 : Host.Load.Run.Tpl.DEC_clear.kappa0.a 2589 = 2589
kernel_rfl clear_kappa1_2586 : Host.Load.Run.Tpl.DEC_clear.kappa1.a 2586 = 2586
kernel_rfl clear_kappa1_2589 : Host.Load.Run.Tpl.DEC_clear.kappa1.a 2589 = 2589
kernel_rfl clear_kappa2_2586 : Host.Load.Run.Tpl.DEC_clear.kappa2.a 2586 = 2586
kernel_rfl clear_kappa2_2589 : Host.Load.Run.Tpl.DEC_clear.kappa2.a 2589 = 2589
kernel_rfl grow_restart_2586 : Host.Load.Run.Tpl.DEC_grow.σ.a 2586 = 2586
kernel_rfl grow_restart_2589 : Host.Load.Run.Tpl.DEC_grow.σ.a 2589 = 2589
kernel_rfl grow_kappa0_2586 : Host.Load.Run.Tpl.DEC_grow.kappa0.a 2586 = 2586
kernel_rfl grow_kappa0_2589 : Host.Load.Run.Tpl.DEC_grow.kappa0.a 2589 = 2589
kernel_rfl grow_kappa1_2586 : Host.Load.Run.Tpl.DEC_grow.kappa1.a 2586 = 2586
kernel_rfl grow_kappa1_2589 : Host.Load.Run.Tpl.DEC_grow.kappa1.a 2589 = 2589
kernel_rfl grow_kappa2_2586 : Host.Load.Run.Tpl.DEC_grow.kappa2.a 2586 = 2586
kernel_rfl grow_kappa2_2589 : Host.Load.Run.Tpl.DEC_grow.kappa2.a 2589 = 2589
kernel_rfl fill_restart_2586 : Host.Load.Run.Tpl.DEC_fill.σ.a 2586 = 2586
kernel_rfl fill_restart_2589 : Host.Load.Run.Tpl.DEC_fill.σ.a 2589 = 2589
kernel_rfl fill_kappa0_2586 : Host.Load.Run.Tpl.DEC_fill.kappa0.a 2586 = 2586
kernel_rfl fill_kappa0_2589 : Host.Load.Run.Tpl.DEC_fill.kappa0.a 2589 = 2589
kernel_rfl fill_kappa1_2586 : Host.Load.Run.Tpl.DEC_fill.kappa1.a 2586 = 2586
kernel_rfl fill_kappa1_2589 : Host.Load.Run.Tpl.DEC_fill.kappa1.a 2589 = 2589
kernel_rfl fill_kappa2_2586 : Host.Load.Run.Tpl.DEC_fill.kappa2.a 2586 = 2586
kernel_rfl fill_kappa2_2589 : Host.Load.Run.Tpl.DEC_fill.kappa2.a 2589 = 2589
kernel_rfl clearFill_restart_2586 : Host.Load.Run.Tpl.DEC_clearFill.σ.a 2586 = 2586
kernel_rfl clearFill_restart_2589 : Host.Load.Run.Tpl.DEC_clearFill.σ.a 2589 = 2589
kernel_rfl clearFill_kappa0_2586 : Host.Load.Run.Tpl.DEC_clearFill.kappa0.a 2586 = 2586
kernel_rfl clearFill_kappa0_2589 : Host.Load.Run.Tpl.DEC_clearFill.kappa0.a 2589 = 2589
kernel_rfl clearFill_kappa1_2586 : Host.Load.Run.Tpl.DEC_clearFill.kappa1.a 2586 = 2586
kernel_rfl clearFill_kappa1_2589 : Host.Load.Run.Tpl.DEC_clearFill.kappa1.a 2589 = 2589
kernel_rfl clearFill_kappa2_2586 : Host.Load.Run.Tpl.DEC_clearFill.kappa2.a 2586 = 2586
kernel_rfl clearFill_kappa2_2589 : Host.Load.Run.Tpl.DEC_clearFill.kappa2.a 2589 = 2589
kernel_rfl clearGrow_restart_2586 : Host.Load.Run.Tpl.DEC_clearGrow.σ.a 2586 = 2586
kernel_rfl clearGrow_restart_2589 : Host.Load.Run.Tpl.DEC_clearGrow.σ.a 2589 = 2589
kernel_rfl clearGrow_kappa0_2586 : Host.Load.Run.Tpl.DEC_clearGrow.kappa0.a 2586 = 2586
kernel_rfl clearGrow_kappa0_2589 : Host.Load.Run.Tpl.DEC_clearGrow.kappa0.a 2589 = 2589
kernel_rfl clearGrow_kappa1_2586 : Host.Load.Run.Tpl.DEC_clearGrow.kappa1.a 2586 = 2586
kernel_rfl clearGrow_kappa1_2589 : Host.Load.Run.Tpl.DEC_clearGrow.kappa1.a 2589 = 2589
kernel_rfl clearGrow_kappa2_2586 : Host.Load.Run.Tpl.DEC_clearGrow.kappa2.a 2586 = 2586
kernel_rfl clearGrow_kappa2_2589 : Host.Load.Run.Tpl.DEC_clearGrow.kappa2.a 2589 = 2589
end Host.Ts.Sim.Compose.DEC.FixedCells
