import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriverMapControl
import host.ts.RenameRouteDriverParameters
import host.ts.RenameRouteDriverBinding
import host.ts.RenameRouteDriverGlobal
import host.ts.RenameRouteDriverPreparation
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary

host_transport_step P.F, P.RestStream.micro0.micro0.s60 to P.RestStream.micro0.micro0.s61 as MapEntry60
host_transport_parameter P.F, P.RestStream.micro0.micro0.s61 to P.RestStream.micro0.micro0.s62 as MapEntry61
host_transport_binding P.F, P.RestStream.micro0.micro0.s62 to P.RestStream.micro0.micro0.s63 as MapEntry62
host_transport_parameter P.F, P.RestStream.micro0.micro0.s63 to P.RestStream.micro0.micro0.s64 as MapEntry63
host_transport_binding P.F, P.RestStream.micro0.micro0.s64 to P.RestStream.micro0.micro0.s65 as MapEntry64
host_transport_parameter P.F, P.RestStream.micro0.micro0.s65 to P.RestStream.micro0.micro0.s66 as MapEntry65
host_transport_preparation P.F, P.RestStream.micro0.micro0.s66 to P.RestStream.micro0.micro0.s67 as MapEntry66
host_transport_map_control P.F, P.RestStream.micro0.micro0.s67 to P.RestStream.micro0.micro0.s68 as MapEntry67
host_transport_structural P.F, P.RestStream.micro0.micro0.s68 to P.RestStream.micro0.micro0.s69 as MapEntry68
host_transport_step P.F, P.RestStream.micro0.micro0.s69 to P.RestStream.micro0.micro0.s70 as MapEntry69
host_transport_structural P.F, P.RestStream.micro0.micro0.s70 to P.RestStream.micro0.micro0.s71 as MapEntry70
host_transport_global P.F, P.RestStream.micro0.micro0.s71 to P.RestStream.micro0.micro0.s72 as MapEntry71
host_transport_map_control P.F, P.RestStream.micro0.micro0.s72 to P.RestStream.micro0.micro0.s73 as MapEntry72
host_transport_map_control P.F, P.RestStream.micro0.micro0.s73 to P.RestStream.micro0.micro0.s74 as MapEntry73

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem map_active60 : isHalt P.RestStream.micro0.micro0.s60.ctl = false := by host_kernel_rfl
theorem map_active61 : isHalt P.RestStream.micro0.micro0.s61.ctl = false := by host_kernel_rfl
theorem map_active62 : isHalt P.RestStream.micro0.micro0.s62.ctl = false := by host_kernel_rfl
theorem map_active63 : isHalt P.RestStream.micro0.micro0.s63.ctl = false := by host_kernel_rfl
theorem map_active64 : isHalt P.RestStream.micro0.micro0.s64.ctl = false := by host_kernel_rfl
theorem map_active65 : isHalt P.RestStream.micro0.micro0.s65.ctl = false := by host_kernel_rfl
theorem map_active66 : isHalt P.RestStream.micro0.micro0.s66.ctl = false := by host_kernel_rfl
theorem map_active67 : isHalt P.RestStream.micro0.micro0.s67.ctl = false := by host_kernel_rfl
theorem map_active68 : isHalt P.RestStream.micro0.micro0.s68.ctl = false := by host_kernel_rfl
theorem map_active69 : isHalt P.RestStream.micro0.micro0.s69.ctl = false := by host_kernel_rfl
theorem map_active70 : isHalt P.RestStream.micro0.micro0.s70.ctl = false := by host_kernel_rfl
theorem map_active71 : isHalt P.RestStream.micro0.micro0.s71.ctl = false := by host_kernel_rfl
theorem map_active72 : isHalt P.RestStream.micro0.micro0.s72.ctl = false := by host_kernel_rfl
theorem map_active73 : isHalt P.RestStream.micro0.micro0.s73.ctl = false := by host_kernel_rfl
theorem map_next62 : P.RestStream.micro0.micro0.s62.next = P.RestStream.micro0.micro0.s60.next+3 := by host_kernel_rfl
theorem map_next64 : P.RestStream.micro0.micro0.s64.next = P.RestStream.micro0.micro0.s60.next+3 := by host_kernel_rfl
theorem map_next65 : P.RestStream.micro0.micro0.s65.next = P.RestStream.micro0.micro0.s60.next+3 := by host_kernel_rfl
theorem map_call_cost : 2+(paramNames MapEntry60.sourceFunction).length = 4 := by host_kernel_rfl

def mapCallLive (live : Nat → Prop) :=
  ClosureLive live P.RestStream.micro0.micro0.s60.next MapEntry60.sourceArrow MapEntry60.sourceHome MapEntry60.sourceFunction
def mapBodyLive (live : Nat → Prop) :=
  CellsLive (mapCallLive live) P.RestStream.micro0.micro0.s65.next (blockNames MapEntry65.sourceBody)

/-- The actual inherited map helper binds its callback and absent thisArg,
hoists its body and takes its real false thisArg guard. -/
theorem map_entry_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s60 s)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (targetBound : s.next+4+(blockNames MapEntry65.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR NR FR R (mapBodyLive live) framed before after old old' P.RestStream.micro0.micro0.s74 result := by
  have hbcall : s.next+2+(paramNames MapEntry60.sourceFunction).length ≤ 2^64 := by
    rw [Nat.add_assoc,map_call_cost]
    omega
  obtain ⟨s61,hr60,h61⟩ := MapEntry60.transport NR FR R C₀ C live framed before after old old' s h hbcall
  obtain ⟨s62,hr61,h62⟩ := MapEntry61.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s61 h61
  have hb62 : s62.next ≤ 2^64 := by rw [h.target_next_add h62 3 map_next62]; omega
  obtain ⟨s63,hr62,h63⟩ := MapEntry62.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s62 h62 hb62
  obtain ⟨s64,hr63,h64⟩ := MapEntry63.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s63 h63
  have hb64 : s64.next ≤ 2^64 := by rw [h.target_next_add h64 3 map_next64]; omega
  obtain ⟨s65,hr64,h65⟩ := MapEntry64.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s64 h64 hb64
  have hb65 : s65.next+(blockNames MapEntry65.sourceBody).length ≤ 2^64 := by
    rw [h.target_next_add h65 3 map_next65]; omega
  obtain ⟨s66,hr65,h66⟩ := MapEntry65.transport NR FR R C₀ C (mapCallLive live) framed before after old old' s65 h65 hb65
  obtain ⟨s67,hr66,h67⟩ := MapEntry66.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s66 h66
  obtain ⟨s68,hr67,h68⟩ := MapEntry67.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s67 h67
  obtain ⟨s69,hr68,h69⟩ := MapEntry68.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s68 h68
  obtain ⟨v69,hr69,h70,_⟩ := MapEntry69.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s69 h69
  let s70 := s69.ret v69
  obtain ⟨s71,hr70,h71⟩ := MapEntry70.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s70 h70
  have hg : mapBodyLive live aGlobal := CellsLive.grow _ _ _ _ (ClosureLive.grow _ _ _ _ _ _ globalLive)
  obtain ⟨v71,hr71,h72,_⟩ := MapEntry71.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s71 h71 hg globalFixed
  let s72 := s71.ret v71
  obtain ⟨s73,hr72,h73⟩ := MapEntry72.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s72 h72
  obtain ⟨result,hr73,h74⟩ := MapEntry73.transport NR FR R C₀ C (mapBodyLive live) framed before after old old' s73 h73
  refine ⟨result,?_,h74⟩
  apply runC_cons P.F 13 s s61 result C C C (h.control.isHalt_eq.trans map_active60) hr60
  apply runC_cons P.F 12 s61 s62 result C C C (h61.control.isHalt_eq.trans map_active61) hr61
  apply runC_cons P.F 11 s62 s63 result C C C (h62.control.isHalt_eq.trans map_active62) hr62
  apply runC_cons P.F 10 s63 s64 result C C C (h63.control.isHalt_eq.trans map_active63) hr63
  apply runC_cons P.F 9 s64 s65 result C C C (h64.control.isHalt_eq.trans map_active64) hr64
  apply runC_cons P.F 8 s65 s66 result C C C (h65.control.isHalt_eq.trans map_active65) hr65
  apply runC_cons P.F 7 s66 s67 result C C C (h66.control.isHalt_eq.trans map_active66) hr66
  apply runC_cons P.F 6 s67 s68 result C C C (h67.control.isHalt_eq.trans map_active67) hr67
  apply runC_cons P.F 5 s68 s69 result C C C (h68.control.isHalt_eq.trans map_active68) hr68
  apply runC_cons P.F 4 s69 s70 result C C C (h69.control.isHalt_eq.trans map_active69) hr69
  apply runC_cons P.F 3 s70 s71 result C C C (h70.control.isHalt_eq.trans map_active70) hr70
  apply runC_cons P.F 2 s71 s72 result C C C (h71.control.isHalt_eq.trans map_active71) hr71
  apply runC_cons P.F 1 s72 s73 result C C C (h72.control.isHalt_eq.trans map_active72) hr72
  apply runC_cons P.F 0 s73 result result C C C (h73.control.isHalt_eq.trans map_active73) hr73
  rfl

end Host.Load.Run.Full.Ordinary
