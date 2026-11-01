import host.sim.compose.a4b.fd.SliceData
import host.sim.template.a4pre_fd_vw_r0.K6
import host.sim.template.a4pre_fd_vw_r0.K9
import host.sim.dispatch.BridgeLen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl

theorem lengthStep {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t sa sb : St FF.S} {Sa Sb : SSrv}
    {C : CSrv} {γ : List Nat} {o : Obj}
    (h : RelB FF FR W [] M ν K sa ⟨Sa.tab, []⟩ t C) (hlaws : FRLaws FR)
    (hc : sa.ctl = .ret (.obj FDFrames.chunk))
    (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? FDFrames.chunk = some o) (hok : o.kind = .array [])
    (hp : Bridge.lenPatch sa Sa (.var 12) = (sb, Sb))
    (hfr : K.fr FDFrames.chunk = some ([], γ.map natV)) (hv : ν 12 = F64.ofNat γ.length) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' Sa.tab.length ∧
      RelB FF FR W [] M' ν K sb ⟨Sb.tab, []⟩ t' C ∧ t'.ffi = t.ffi := by
  have heval : (.var 12 : SymE).eval ν = F64.ofNat ((γ.map natV).length + ([] : List Val).length) := by
    simpa only [SymE.eval, List.length_map, List.length_nil, Nat.add_zero] using hv
  obtain ⟨hs, he, hr⟩ := Disp.bridge_len h hlaws hc hst hfr ho hok (.var 12) heval
  let M' := M.setNum Sa.tab.length (.lit (F64.ofNat γ.length))
  let t' : St FF.S := { t with stack := sa.stack.tail.map M.frame ++ [] }.ret (natV γ.length)
  have rel : RelB FF FR W [] M' ν K sb ⟨Sb.tab, []⟩ t' C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF FR W [] M' ν K p.1 ⟨p.2.tab, []⟩ t' C) hp).mp
      (by simpa only [Bridge.lenPatch, M', t', List.length_map, List.length_nil, Nat.add_zero] using hr)
  have hrun : runC FF 1 t C = some (t', C) := by
    simpa only [t', List.length_map, List.length_nil, Nat.add_zero] using
      (runC_one (by rw [h.isHalt, hc]; rfl) hs)
  exact ⟨M', t', hrun, by simpa only [M', List.length_map, List.length_nil, Nat.add_zero] using he, rel, rfl⟩

kernel_rfl stack24 : PRE_fd_vw_r0.s7.stack = .e (.member kLength false) :: PRE_fd_vw_r0.s7.stack.tail
kernel_rfl empty24 : arrOf PRE_fd_vw_r0.s7 2825053 = []
kernel_rfl stack36 : PRE_fd_vw_r0.s19.stack = .e (.member kLength false) :: PRE_fd_vw_r0.s19.stack.tail
kernel_rfl empty36 : arrOf PRE_fd_vw_r0.s19 2825053 = []

theorem length7 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_fd_vw_r0.s7 ⟨PRE_fd_vw_r0.S7.tab, []⟩ t C)
    (hlaws : FRLaws FR) (hfr : K.fr FDFrames.chunk = some ([], γ.map natV))
    (hv : ν 12 = F64.ofNat γ.length) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_fd_vw_r0.S7.tab.length ∧
      RelB FF FR W [] M' ν K PRE_fd_vw_r0.s8 ⟨PRE_fd_vw_r0.S8.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h hlaws PRE_fd_vw_r0.ctlA3 stack24 PRE_fd_vw_r0.objA3
    (PRE_fd_vw_r0.kindA3.trans (congrArg Kind.array empty24))
    (Option.some.inj PRE_fd_vw_r0.patchB3) hfr hv

theorem length19 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_fd_vw_r0.s19 ⟨PRE_fd_vw_r0.S19.tab, []⟩ t C)
    (hlaws : FRLaws FR) (hfr : K.fr FDFrames.chunk = some ([], γ.map natV))
    (hv : ν 12 = F64.ofNat γ.length) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_fd_vw_r0.S19.tab.length ∧
      RelB FF FR W [] M' ν K PRE_fd_vw_r0.s20 ⟨PRE_fd_vw_r0.S20.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h hlaws PRE_fd_vw_r0.ctlA7 stack36 PRE_fd_vw_r0.objA7
    (PRE_fd_vw_r0.kindA7.trans (congrArg Kind.array empty36))
    (Option.some.inj PRE_fd_vw_r0.patchB7) hfr hv

end Host.Ts.Sim.Compose.FDVW
