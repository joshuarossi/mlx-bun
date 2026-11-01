import host.sim.compose.ReservedPrefix
import host.sim.compose.a4b.SetupD1Values
import host.sim.template.a4pre_d1_body.Reserved
set_option Elab.async false
namespace Host.Ts.Sim.Compose.SetupD1Reserved
open Host.Ts Host.Load.Run.Tpl

theorem body_values {M M' : Map} {ν ν' : Nat → F64} {C C' : CSrv}
    (h : NumOK M ν ⟨D1Call.S1.tab, []⟩ C)
    (h' : NumOK M' ν' ⟨D1Body.S155.tab, []⟩ C')
    (he : Ext M M' 17) (hc : CSrv.Le C C') :
    ∀ j, j < 9 → ν' j = ν j :=
  valuation_prefix h h' D1BodyReserved.start D1BodyReserved.finish
    (he.mono (by decide)) hc

/-- The loaded budget and tokens remain attached to the endpoint's own map,
valuation and number server. The actual body run supplies server growth. -/
theorem body_reserved {T : Nat} {tk : Nat → Nat} {M M' : Map}
    {ν ν' : Nat → F64} {C C' : CSrv}
    (h : NumOK M ν ⟨D1Call.S1.tab, []⟩ C)
    (h' : NumOK M' ν' ⟨D1Body.S155.tab, []⟩ C')
    (he : Ext M M' 17) (hc : CSrv.Le C C')
    (hv : SetupD1Values.Reserved T tk ν) : SetupD1Values.Reserved T tk ν' := by
  intro j hj
  exact (body_values h h' he hc j hj).trans (hv j hj)

end Host.Ts.Sim.Compose.SetupD1Reserved
