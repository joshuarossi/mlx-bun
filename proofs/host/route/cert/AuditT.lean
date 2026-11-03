import host.route.cert.Fin.D1X0.Cert
import host.route.cert.Fin.X0.Cert
import host.route.cert.Fin.X4L7.Cert
import host.route.cert.X4L7.Cert
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Mlx.FfiEval Host.Load.Run.Full
theorem c0 : Expected.cacheOutputs.map (fun q => (some (certAt Host.Route.Cert.Fin.D1X0.d1Cert.cert q.1), some (certAt Host.Route.Cert.Fin.D1X0.d1Cert.cert q.2))) = Host.Route.Cert.Fin.X0.finCert.ps := by decide
theorem c7 : Host.Route.Cert.X4L7.cert.carriers = Host.Route.Cert.Fin.X4L7.finCert.ps := by decide
#print axioms c0
