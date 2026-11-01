import host.route.cert.One.CertH
import host.route.cert.Row.Hooks
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.Cert.One
open Host.Route.Cert.Row

/-! # The one-token prompt's carriers are the shared tail's -/

theorem rowCr_one : rowCr 0 1 = Host.Route.PrefGraph.oneCarriers := rfl
theorem rowToks_one : rowToks 1 0 = 17776 := rfl

end Host.Route.Cert.One
