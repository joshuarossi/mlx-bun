import host.sim.compose.a4b.SetupCommonBase
import host.sim.template.a4pre_g0b.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

kernel_rfl oracle0 : (FillSetupEarly.setupRows.all fun r => goodLin r.ps (varsOf r.V m) PRE_g0b.S0.oracle) = true
kernel_rfl oracle3 : (FillSetupEarly.setupRows.all fun r => goodLin r.ps (varsOf r.V m) PRE_g0b.S3.oracle) = true
kernel_rfl oracle6 : (FillSetupEarly.setupRows.all fun r => goodLin r.ps (varsOf r.V m) PRE_g0b.S6.oracle) = true
kernel_rfl oracle9 : (FillSetupEarly.setupRows.all fun r => goodLin r.ps (varsOf r.V m) PRE_g0b.S9.oracle) = true
kernel_rfl oracle2 : (FillSetupEarly.setupRows.all fun r => goodLin r.ps (varsOf r.V m) PRE_g0b.S2.oracle) = true
kernel_rfl oracle5 : (FillSetupEarly.setupRows.all fun r => goodLin r.ps (varsOf r.V m) PRE_g0b.S5.oracle) = true
kernel_rfl oracle8 : (FillSetupEarly.setupRows.all fun r => goodLin r.ps (varsOf r.V m) PRE_g0b.S8.oracle) = true


end Host.Ts.Sim.Compose.SetupCommon
