import host.sim.compose.a4b.fd_x4_L9.SliceData
import host.sim.template.a4pre_fd_x4_L9_r0.K0
import host.sim.template.a4pre_fd_x4_L9_r0.K1
import host.sim.template.a4pre_fd_x4_L9_r0.K2
import host.sim.template.a4pre_fd_x4_L9_r0.K3
import host.sim.template.a4pre_fd_x4_L9_r0.K4
import host.sim.template.a4pre_fd_x4_L9_r0.K5
import host.sim.template.BridgeLenLit
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl

theorem lengthStep {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t sa sb : St FF.S} {Sa Sb : SSrv}
    {C : CSrv} {γ : List Nat} {o : Obj}
    (h : RelB FF FR W [] M ν K sa ⟨Sa.tab, []⟩ t C)
    (hc : sa.ctl = .ret (.obj FDX4L9Frames.chunk))
    (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? FDX4L9Frames.chunk = some o) (hok : o.kind = .array [])
    (hp : Bridge.lenLitPatch sa Sa (F64.ofNat 1) = (sb, Sb))
    (hfr : K.fr FDX4L9Frames.chunk = some ([], γ.map natV)) (hlen : γ.length = 1) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' Sa.tab.length ∧
      RelB FF FR W [] M' ν K sb ⟨Sb.tab, []⟩ t' C ∧ t'.ffi = t.ffi := by
  have hk : o.kind = .array (([] : List Val) ++ []) := hok
  obtain ⟨hs, hr⟩ := Disp.bridge_len_lit h hc hst hfr ho hk
  simp only [List.length_map, List.length_nil, Nat.add_zero, hlen] at hs hr
  have es := congrArg (fun p : St FF.S × SSrv => p.1) hp
  have et := congrArg (fun p : St FF.S × SSrv => p.2.tab) hp
  simp only [Bridge.lenLitPatch] at es et
  subst es
  refine ⟨M, _, runC_one (by rw [h.isHalt, hc]; rfl) hs, Ext.refl _ _, ?_, rfl⟩
  rw [← et]
  exact hr

kernel_rfl stack24 : PRE_fd_x4_L9_r0.s7.stack = .e (.member kLength false) :: PRE_fd_x4_L9_r0.s7.stack.tail
kernel_rfl empty24 : arrOf PRE_fd_x4_L9_r0.s7 2834731 = []
kernel_rfl stack36 : PRE_fd_x4_L9_r0.s19.stack = .e (.member kLength false) :: PRE_fd_x4_L9_r0.s19.stack.tail
kernel_rfl empty36 : arrOf PRE_fd_x4_L9_r0.s19 2834731 = []

theorem length7 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_fd_x4_L9_r0.s7 ⟨PRE_fd_x4_L9_r0.S7.tab, []⟩ t C)
    (hfr : K.fr FDX4L9Frames.chunk = some ([], γ.map natV)) (hlen : γ.length = 1) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_fd_x4_L9_r0.S7.tab.length ∧
      RelB FF FR W [] M' ν K PRE_fd_x4_L9_r0.s8 ⟨PRE_fd_x4_L9_r0.S8.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h PRE_fd_x4_L9_r0.ctlA3 stack24 PRE_fd_x4_L9_r0.objA3
    (PRE_fd_x4_L9_r0.kindA3.trans (congrArg Kind.array empty24))
    (Option.some.inj PRE_fd_x4_L9_r0.patchB3) hfr hlen

theorem length19 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_fd_x4_L9_r0.s19 ⟨PRE_fd_x4_L9_r0.S19.tab, []⟩ t C)
    (hfr : K.fr FDX4L9Frames.chunk = some ([], γ.map natV)) (hlen : γ.length = 1) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_fd_x4_L9_r0.S19.tab.length ∧
      RelB FF FR W [] M' ν K PRE_fd_x4_L9_r0.s20 ⟨PRE_fd_x4_L9_r0.S20.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h PRE_fd_x4_L9_r0.ctlA7 stack36 PRE_fd_x4_L9_r0.objA7
    (PRE_fd_x4_L9_r0.kindA7.trans (congrArg Kind.array empty36))
    (Option.some.inj PRE_fd_x4_L9_r0.patchB7) hfr hlen

end Host.Ts.Sim.Compose.FDX4L9
