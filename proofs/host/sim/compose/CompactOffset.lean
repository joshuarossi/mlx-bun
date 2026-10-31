import host.sim.compose.PreCall
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template

/-- Compaction adds the discarded source addresses to the existing offset. -/
theorem prefillCompactPair_offset {P : LoadP} {κ : Map} {θ : Nat → SymE} {sm sc : St FF.S}
    {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame} {S : SSrv} {x : SegInst FF}
    (h : RelB FF FR W [] x.M x.ν x.K sm S x.t x.C) (hle : sc.next ≤ sm.next) :
    (prefillCompactPair P κ θ sm sc x).K.D = x.K.D + (sm.next - sc.next) := by
  change x.t.next - sc.next = _
  have he : x.t.next = sm.next + x.K.D := h.offset
  omega

end Host.Ts.Sim.Compose
