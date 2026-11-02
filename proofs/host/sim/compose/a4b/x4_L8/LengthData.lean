import host.sim.compose.a4b.x4_L8.SliceData
import host.sim.template.a4pre_first_tail_x4_L8_r0.K6
import host.sim.template.a4pre_first_tail_x4_L8_r0.K9
import host.sim.template.BridgeLenLit
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl

theorem lengthStep {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t sa sb : St FF.S} {Sa Sb : SSrv}
    {C : CSrv} {γ : List Nat} {o : Obj}
    (h : RelB FF FR W [] M ν K sa ⟨Sa.tab, []⟩ t C)
    (hc : sa.ctl = .ret (.obj VWFrames.chunk))
    (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? VWFrames.chunk = some o) (hok : o.kind = .array [])
    (hp : Bridge.lenLitPatch sa Sa (F64.ofNat 7) = (sb, Sb))
    (hfr : K.fr VWFrames.chunk = some ([], γ.map natV)) (hlen : γ.length = 7) :
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

kernel_rfl stack24 : PRE_first_tail_x4_L8_r0.s24.stack = .e (.member kLength false) :: PRE_first_tail_x4_L8_r0.s24.stack.tail
kernel_rfl empty24 : arrOf PRE_first_tail_x4_L8_r0.s24 2673467 = []
kernel_rfl stack36 : PRE_first_tail_x4_L8_r0.s36.stack = .e (.member kLength false) :: PRE_first_tail_x4_L8_r0.s36.stack.tail
kernel_rfl empty36 : arrOf PRE_first_tail_x4_L8_r0.s36 2673467 = []

theorem length24 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_first_tail_x4_L8_r0.s24 ⟨PRE_first_tail_x4_L8_r0.S24.tab, []⟩ t C)
    (hfr : K.fr VWFrames.chunk = some ([], γ.map natV)) (hlen : γ.length = 7) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_first_tail_x4_L8_r0.S24.tab.length ∧
      RelB FF FR W [] M' ν K PRE_first_tail_x4_L8_r0.s25 ⟨PRE_first_tail_x4_L8_r0.S25.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h PRE_first_tail_x4_L8_r0.ctlA8 stack24 PRE_first_tail_x4_L8_r0.objA8
    (PRE_first_tail_x4_L8_r0.kindA8.trans (congrArg Kind.array empty24))
    (Option.some.inj PRE_first_tail_x4_L8_r0.patchB8) hfr hlen

theorem length36 {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR W [] M ν K PRE_first_tail_x4_L8_r0.s36 ⟨PRE_first_tail_x4_L8_r0.S36.tab, []⟩ t C)
    (hfr : K.fr VWFrames.chunk = some ([], γ.map natV)) (hlen : γ.length = 7) :
    ∃ M' t', runC FF 1 t C = some (t', C) ∧ Ext M M' PRE_first_tail_x4_L8_r0.S36.tab.length ∧
      RelB FF FR W [] M' ν K PRE_first_tail_x4_L8_r0.s37 ⟨PRE_first_tail_x4_L8_r0.S37.tab, []⟩ t' C ∧ t'.ffi = t.ffi :=
  lengthStep h PRE_first_tail_x4_L8_r0.ctlA12 stack36 PRE_first_tail_x4_L8_r0.objA12
    (PRE_first_tail_x4_L8_r0.kindA12.trans (congrArg Kind.array empty36))
    (Option.some.inj PRE_first_tail_x4_L8_r0.patchB12) hfr hlen

end Host.Ts.Sim.Compose.VWFirst.X4_L8
