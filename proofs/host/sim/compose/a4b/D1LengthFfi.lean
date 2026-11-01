import host.sim.compose.a4b.D1LengthData
import host.sim.template.a4pre_d1_input.LengthStep

namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl

theorem length6_ffi {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
    (h : RelB FF FR W [] M ν K D1StageSplit.s6 ⟨D1StageSplit.S6.tab, []⟩ t C)
    (hlaws : FRLaws FR) (hfr : K.fr 2673479 = some ([], π.map natV))
    (hlen : π.length = 1) (hv : ν 9 = F64.ofNat 1) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' D1StageSplit.S6.tab.length ∧
      RelB FF FR W [] M' ν K D1StageSplit.s7 ⟨D1StageSplit.S7.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  D1Length.step_ffi h hlaws D1StageSplit.ctlA3 stack6 D1StageSplit.objA3
    (D1StageSplit.kindA3.trans (congrArg Kind.array empty6)) (Option.some.inj D1StageSplit.patchB3) hfr hlen hv

theorem length18_ffi {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
    (h : RelB FF FR W [] M ν K D1StageSplit.s18 ⟨D1StageSplit.S18.tab, []⟩ t C)
    (hlaws : FRLaws FR) (hfr : K.fr 2673479 = some ([], π.map natV))
    (hlen : π.length = 1) (hv : ν 9 = F64.ofNat 1) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' D1StageSplit.S18.tab.length ∧
      RelB FF FR W [] M' ν K D1StageSplit.s19 ⟨D1StageSplit.S19.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  D1Length.step_ffi h hlaws D1StageSplit.ctlA7 stack18 D1StageSplit.objA7
    (D1StageSplit.kindA7.trans (congrArg Kind.array empty18)) (Option.some.inj D1StageSplit.patchB7) hfr hlen hv

end Host.Ts.Sim.Compose.D1Split
