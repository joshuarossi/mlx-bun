import host.sim.compose.a4b.VWSliceData
import host.sim.template.a4pre_first_tail_x15_r0.K6
import host.sim.template.a4pre_first_tail_x15_r0.K9
import host.sim.dispatch.BridgeLen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl

theorem lengthStep {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t sa sb : St FF.S} {Sa Sb : SSrv}
    {C : CSrv} {γ : List Nat} {o : Obj}
    (h : RelB FF FR W [] M ν K sa ⟨Sa.tab, []⟩ t C) (hlaws : FRLaws FR)
    (hc : sa.ctl = .ret (.obj VWFrames.chunk))
    (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? VWFrames.chunk = some o) (hok : o.kind = .array [])
    (hp : Bridge.lenPatch sa Sa (.var 1087) = (sb, Sb))
    (hfr : K.fr VWFrames.chunk = some ([], γ.map natV)) (hv : ν 1087 = F64.ofNat γ.length) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' Sa.tab.length ∧
      RelB FF FR W [] M' ν K sb ⟨Sb.tab, []⟩ t' C ∧ t'.ffi = t.ffi := by
  have heval : (.var 1087 : SymE).eval ν = F64.ofNat ((γ.map natV).length + ([] : List Val).length) := by
    simpa only [SymE.eval, List.length_map, List.length_nil, Nat.add_zero] using hv
  obtain ⟨hs, he, hr⟩ := Disp.bridge_len h hlaws hc hst hfr ho hok (.var 1087) heval
  let M' := M.setNum Sa.tab.length (.lit (F64.ofNat γ.length))
  let t' : St FF.S := { t with stack := sa.stack.tail.map M.frame ++ [] }.ret (natV γ.length)
  have rel : RelB FF FR W [] M' ν K sb ⟨Sb.tab, []⟩ t' C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF FR W [] M' ν K p.1 ⟨p.2.tab, []⟩ t' C) hp).mp
      (by simpa only [Bridge.lenPatch, M', t', List.length_map, List.length_nil, Nat.add_zero] using hr)
  have hrun : runC FF 1 t C = some (t', C) := by
    simpa only [t', List.length_map, List.length_nil, Nat.add_zero] using
      (runC_one (by rw [h.isHalt, hc]; rfl) hs)
  exact ⟨M', t', hrun, by simpa only [M', List.length_map, List.length_nil, Nat.add_zero] using he, rel, rfl⟩

kernel_rfl stack24 : PRE_first_tail_x15_r0.s24.stack = .e (.member kLength false) :: PRE_first_tail_x15_r0.s24.stack.tail
kernel_rfl empty24 : arrOf PRE_first_tail_x15_r0.s24 2673467 = []
kernel_rfl stack36 : PRE_first_tail_x15_r0.s36.stack = .e (.member kLength false) :: PRE_first_tail_x15_r0.s36.stack.tail
kernel_rfl empty36 : arrOf PRE_first_tail_x15_r0.s36 2673467 = []

theorem length24 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_first_tail_x15_r0.s24 ⟨PRE_first_tail_x15_r0.S24.tab, []⟩ t C)
    (hlaws : FRLaws FR) (hfr : K.fr VWFrames.chunk = some ([], γ.map natV))
    (hv : ν 1087 = F64.ofNat γ.length) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_first_tail_x15_r0.S24.tab.length ∧
      RelB FF FR W [] M' ν K PRE_first_tail_x15_r0.s25 ⟨PRE_first_tail_x15_r0.S25.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h hlaws PRE_first_tail_x15_r0.ctlA8 stack24 PRE_first_tail_x15_r0.objA8
    (PRE_first_tail_x15_r0.kindA8.trans (congrArg Kind.array empty24))
    (Option.some.inj PRE_first_tail_x15_r0.patchB8) hfr hv

theorem length36 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_first_tail_x15_r0.s36 ⟨PRE_first_tail_x15_r0.S36.tab, []⟩ t C)
    (hlaws : FRLaws FR) (hfr : K.fr VWFrames.chunk = some ([], γ.map natV))
    (hv : ν 1087 = F64.ofNat γ.length) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_first_tail_x15_r0.S36.tab.length ∧
      RelB FF FR W [] M' ν K PRE_first_tail_x15_r0.s37 ⟨PRE_first_tail_x15_r0.S37.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h hlaws PRE_first_tail_x15_r0.ctlA12 stack36 PRE_first_tail_x15_r0.objA12
    (PRE_first_tail_x15_r0.kindA12.trans (congrArg Kind.array empty36))
    (Option.some.inj PRE_first_tail_x15_r0.patchB12) hfr hv

end Host.Ts.Sim.Compose.VWFirst
