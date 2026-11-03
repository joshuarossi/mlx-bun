import host.route.cert.Head.VW.Cert
import host.route.cert.Row.Hooks
import host.sim.compose.a4b.PLTVWalk
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace ScrCrB
open Host.Ts Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl Host.Route Host.Route.Cert Host.Route.Cert.Fin
kernel_rfl hcr : Row.R1.ps.map (fun p => (p.1.map PLTVW.R.data.nodeF, p.2.map PLTVW.R.data.nodeF)) = carriersOf (certAt Head.VW.headCert.cert)
kernel_rfl hto : PLTVW.R.data.nodeF 17776 = certAt Head.VW.headCert.cert Tpl.Ordinary.tokenNode
end ScrCrB
