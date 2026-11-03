import host.route.cert.VW15.Cert
import host.route.cert.VW8.Cert
import host.route.cert.VW6.Cert
import host.route.cert.Fin.VW.Cert
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace ScrCrA
open Host.Route Host.Route.Cert
kernel_rfl c15 : VW15.cert.carriers = Fin.VW.finCert.ps
kernel_rfl c8 : VW8.cert.carriers = Fin.VW.finCert.ps
kernel_rfl c6 : VW6.cert.carriers = Fin.VW.finCert.ps
end ScrCrA
