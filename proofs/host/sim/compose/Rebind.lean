import host.sim.compose.Literal
import host.sim.conv.RebindVar

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-- A checked chain can rename a table variable at a seam while retaining the
same source state, target state, map and context. -/
theorem cut_rebindVar {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {s : St F.S} {S : SSrv} {old fresh : Nat}
    {Q B Q' B' : SegInst F → Prop}
    (hne : old ≠ fresh) (htab : ∀ e ∈ S.tab, e.noVar fresh = true)
    (hpost : ∀ x, Q x → B x →
      RelB F FR W [] x.M x.ν x.K s ⟨S.tab, []⟩ x.t x.C →
      Q' { x with ν := upd x.ν fresh (x.ν old) } ∧
      B' { x with ν := upd x.ν fresh (x.ν old) }) :
    CutConv ((Cut.mk s S.tab (Conv.relB F FR W [] Q)).with B)
      ((Cut.mk s (S.tab.map (·.subst (fun v => if v = old then .var fresh else .var v)))
        (Conv.relB F FR W [] Q')).with B') := by
  rintro x ⟨hr, hq⟩ hb
  have h := hr.rebindVar hne htab (newOracle := []) (fun _ h => nomatch h)
  obtain ⟨hq', hb'⟩ := hpost x hq hb hr
  exact ⟨{ x with ν := upd x.ν fresh (x.ν old) }, rfl, rfl, ⟨h, hq'⟩, hb'⟩

end Host.Ts.Sim.Compose
