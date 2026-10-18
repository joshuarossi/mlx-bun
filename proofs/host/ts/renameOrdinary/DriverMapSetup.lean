import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriverArrayLength
import host.ts.RenameRouteDriverMapControl
import host.ts.RenameRouteDriverBinding
import host.ts.RenameRouteDriverPreparation
import host.ts.RenameRouteDriverStructural
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary

host_transport_preparation P.F, P.RestStream.micro0.micro0.s74 to P.RestStream.micro0.micro0.s75 as MapSetup74
host_transport_preparation P.F, P.RestStream.micro0.micro0.s75 to P.RestStream.micro0.micro0.s76 as MapSetup75
host_transport_structural P.F, P.RestStream.micro0.micro0.s76 to P.RestStream.micro0.micro0.s77 as MapSetup76
host_transport_map_control P.F, P.RestStream.micro0.micro0.s77 to P.RestStream.micro0.micro0.s78 as MapSetup77
host_transport_array_length P.F, P.RestStream.micro0.micro0.s78 to P.RestStream.micro0.micro0.s79 as MapSetup78
host_transport_binding P.F, P.RestStream.micro0.micro0.s79 to P.RestStream.micro0.micro0.s80 as MapSetup79
host_transport_binding P.F, P.RestStream.micro0.micro0.s80 to P.RestStream.micro0.micro0.s81 as MapSetup80
host_transport_binding P.F, P.RestStream.micro0.micro0.s81 to P.RestStream.micro0.micro0.s82 as MapSetup81
host_transport_preparation P.F, P.RestStream.micro0.micro0.s82 to P.RestStream.micro0.micro0.s83 as MapSetup82
host_transport_preparation P.F, P.RestStream.micro0.micro0.s83 to P.RestStream.micro0.micro0.s84 as MapSetup83
host_transport_preparation P.F, P.RestStream.micro0.micro0.s84 to P.RestStream.micro0.micro0.s85 as MapSetup84
host_transport_binding P.F, P.RestStream.micro0.micro0.s85 to P.RestStream.micro0.micro0.s86 as MapSetup85
host_transport_binding P.F, P.RestStream.micro0.micro0.s86 to P.RestStream.micro0.micro0.s87 as MapSetup86
host_transport_binding P.F, P.RestStream.micro0.micro0.s87 to P.RestStream.micro0.micro0.s88 as MapSetup87

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem map_setup_active74 : isHalt P.RestStream.micro0.micro0.s74.ctl = false := by host_kernel_rfl
theorem map_setup_active75 : isHalt P.RestStream.micro0.micro0.s75.ctl = false := by host_kernel_rfl
theorem map_setup_active76 : isHalt P.RestStream.micro0.micro0.s76.ctl = false := by host_kernel_rfl
theorem map_setup_active77 : isHalt P.RestStream.micro0.micro0.s77.ctl = false := by host_kernel_rfl
theorem map_setup_active78 : isHalt P.RestStream.micro0.micro0.s78.ctl = false := by host_kernel_rfl
theorem map_setup_active79 : isHalt P.RestStream.micro0.micro0.s79.ctl = false := by host_kernel_rfl
theorem map_setup_active80 : isHalt P.RestStream.micro0.micro0.s80.ctl = false := by host_kernel_rfl
theorem map_setup_active81 : isHalt P.RestStream.micro0.micro0.s81.ctl = false := by host_kernel_rfl
theorem map_setup_active82 : isHalt P.RestStream.micro0.micro0.s82.ctl = false := by host_kernel_rfl
theorem map_setup_active83 : isHalt P.RestStream.micro0.micro0.s83.ctl = false := by host_kernel_rfl
theorem map_setup_active84 : isHalt P.RestStream.micro0.micro0.s84.ctl = false := by host_kernel_rfl
theorem map_setup_active85 : isHalt P.RestStream.micro0.micro0.s85.ctl = false := by host_kernel_rfl
theorem map_setup_active86 : isHalt P.RestStream.micro0.micro0.s86.ctl = false := by host_kernel_rfl
theorem map_setup_active87 : isHalt P.RestStream.micro0.micro0.s87.ctl = false := by host_kernel_rfl
theorem map_setup_next80 : P.RestStream.micro0.micro0.s80.next = P.RestStream.micro0.micro0.s74.next := by host_kernel_rfl
theorem map_setup_next84 : P.RestStream.micro0.micro0.s84.next = P.RestStream.micro0.micro0.s74.next := by host_kernel_rfl
theorem map_setup_next86 : P.RestStream.micro0.micro0.s86.next = P.RestStream.micro0.micro0.s74.next+1 := by host_kernel_rfl
theorem map_length_two : MapSetup78.sourceLength = 2 := by host_kernel_rfl

/-- The actual map helper obtains the literal two from the owned array's
length, without requiring a target length or numeric interpretation premise. -/
theorem map_length_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s74 s)
    (notFramed : ¬ framed 3126664) (literalTwo : NR (.lit (F64.ofNat 2)) (.lit (F64.ofNat 2))) :
    ∃ result, runC P.F 5 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s79 result ∧
      result.ctl = .ret (natV 2) := by
  obtain ⟨s75,hr74,h75⟩ := MapSetup74.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s76,hr75,h76⟩ := MapSetup75.transport NR FR R C₀ C live framed before after old old' s75 h75
  obtain ⟨s77,hr76,h77⟩ := MapSetup76.transport NR FR R C₀ C live framed before after old old' s76 h76
  obtain ⟨s78,hr77,h78⟩ := MapSetup77.transport NR FR R C₀ C live framed before after old old' s77 h77
  obtain ⟨result,hr78,h79,hctl⟩ := MapSetup78.transport NR FR R C₀ C live framed before after old old' s78 h78 notFramed
    (by simpa only [map_length_two] using literalTwo)
  refine ⟨result,?_,h79,by simpa only [map_length_two] using hctl⟩
  apply runC_cons P.F 4 s s75 result C C C (h.control.isHalt_eq.trans map_setup_active74) hr74
  apply runC_cons P.F 3 s75 s76 result C C C (h75.control.isHalt_eq.trans map_setup_active75) hr75
  apply runC_cons P.F 2 s76 s77 result C C C (h76.control.isHalt_eq.trans map_setup_active76) hr76
  apply runC_cons P.F 1 s77 s78 result C C C (h77.control.isHalt_eq.trans map_setup_active77) hr77
  apply runC_cons P.F 0 s78 result result C C C (h78.control.isHalt_eq.trans map_setup_active78) hr78
  rfl

/-- The original map prelude binds its array length and allocates its result
array. This is the real fourteen-step source segment. -/
theorem map_setup_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s74 s)
    (notFramed : ¬ framed 3126664) (literalTwo : NR (.lit (F64.ofNat 2)) (.lit (F64.ofNat 2)))
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR NR FR R (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old'
        P.RestStream.micro0.micro0.s88 result := by
  obtain ⟨s79,hr74_79,h79,hctl79⟩ := map_length_transport NR FR R C₀ C live framed before after old old'
    s h notFramed literalTwo
  obtain ⟨s80,hr79,h80⟩ := MapSetup79.transport NR FR R C₀ C live framed before after old old' s79 h79
  have hb80 : s80.next ≤ 2^64 := by rw [h.target_next_eq h80 map_setup_next80]; omega
  obtain ⟨s81,hr80,h81⟩ := MapSetup80.transport NR FR R C₀ C live framed before after old old' s80 h80 hb80
  obtain ⟨s82,hr81,h82⟩ := MapSetup81.transport NR FR R C₀ C live framed before after old old' s81 h81
  obtain ⟨s83,hr82,h83⟩ := MapSetup82.transport NR FR R C₀ C live framed before after old old' s82 h82
  obtain ⟨s84,hr83,h84⟩ := MapSetup83.transport NR FR R C₀ C live framed before after old old' s83 h83
  have hb84 : s84.next < 2^64 := by rw [h.target_next_eq h84 map_setup_next84]; omega
  obtain ⟨s85,hr84,h85⟩ := MapSetup84.transport NR FR R C₀ C live framed before after old old' s84 h84 prototypeLive prototypeFixed hb84
  obtain ⟨s86,hr85,h86⟩ := MapSetup85.transport NR FR R C₀ C (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old' s85 h85
  have hb86 : s86.next ≤ 2^64 := by rw [h.target_next_add h86 1 map_setup_next86]; omega
  obtain ⟨s87,hr86,h87⟩ := MapSetup86.transport NR FR R C₀ C (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old' s86 h86 hb86
  obtain ⟨s88,hr87,h88⟩ := MapSetup87.transport NR FR R C₀ C (LiveAfter live P.RestStream.micro0.micro0.s84.next) framed before after old old' s87 h87
  refine ⟨s88,?_,h88⟩
  have htail : runC P.F 9 s79 C = some (s88,C) := by
    apply runC_cons P.F 8 s79 s80 s88 C C C (h79.control.isHalt_eq.trans map_setup_active79) hr79
    apply runC_cons P.F 7 s80 s81 s88 C C C (h80.control.isHalt_eq.trans map_setup_active80) hr80
    apply runC_cons P.F 6 s81 s82 s88 C C C (h81.control.isHalt_eq.trans map_setup_active81) hr81
    apply runC_cons P.F 5 s82 s83 s88 C C C (h82.control.isHalt_eq.trans map_setup_active82) hr82
    apply runC_cons P.F 4 s83 s84 s88 C C C (h83.control.isHalt_eq.trans map_setup_active83) hr83
    apply runC_cons P.F 3 s84 s85 s88 C C C (h84.control.isHalt_eq.trans map_setup_active84) hr84
    apply runC_cons P.F 2 s85 s86 s88 C C C (h85.control.isHalt_eq.trans map_setup_active85) hr85
    apply runC_cons P.F 1 s86 s87 s88 C C C (h86.control.isHalt_eq.trans map_setup_active86) hr86
    apply runC_cons P.F 0 s87 s88 s88 C C C (h87.control.isHalt_eq.trans map_setup_active87) hr87
    rfl
  exact runC_join P.F hr74_79 htail

end Host.Load.Run.Full.Ordinary
