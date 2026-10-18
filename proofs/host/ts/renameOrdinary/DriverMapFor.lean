import host.ts.renameOrdinary.DriverMapSetup
import host.ts.RenameRouteDriverFor

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary

host_transport_preparation P.F, P.RestStream.micro0.micro0.s88 to P.RestStream.micro0.micro0.s89 as MapFor88
host_transport_for P.F, P.RestStream.micro0.micro0.s89 to P.RestStream.micro0.micro0.s90 as MapFor89
host_transport_literal P.F, P.RestStream.micro0.micro0.s90 to P.RestStream.micro0.micro0.s91 as MapFor90
host_transport_binding P.F, P.RestStream.micro0.micro0.s91 to P.RestStream.micro0.micro0.s92 as MapFor91
host_transport_binding P.F, P.RestStream.micro0.micro0.s92 to P.RestStream.micro0.micro0.s93 as MapFor92
host_transport_binding P.F, P.RestStream.micro0.micro0.s93 to P.RestStream.micro0.micro0.s94 as MapFor93
host_transport_for P.F, P.RestStream.micro0.micro0.s94 to P.RestStream.micro0.micro0.s95 as MapFor94
host_transport_structural P.F, P.RestStream.micro0.micro0.s95 to P.RestStream.micro0.micro0.s96 as MapFor95
host_transport_step P.F, P.RestStream.micro0.micro0.s96 to P.RestStream.micro0.micro0.s97 as MapFor96
host_transport_structural P.F, P.RestStream.micro0.micro0.s97 to P.RestStream.micro0.micro0.s98 as MapFor97
host_transport_step P.F, P.RestStream.micro0.micro0.s98 to P.RestStream.micro0.micro0.s99 as MapFor98

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem map_for_active88 : isHalt P.RestStream.micro0.micro0.s88.ctl = false := by host_kernel_rfl
theorem map_for_active89 : isHalt P.RestStream.micro0.micro0.s89.ctl = false := by host_kernel_rfl
theorem map_for_active90 : isHalt P.RestStream.micro0.micro0.s90.ctl = false := by host_kernel_rfl
theorem map_for_active91 : isHalt P.RestStream.micro0.micro0.s91.ctl = false := by host_kernel_rfl
theorem map_for_active92 : isHalt P.RestStream.micro0.micro0.s92.ctl = false := by host_kernel_rfl
theorem map_for_active93 : isHalt P.RestStream.micro0.micro0.s93.ctl = false := by host_kernel_rfl
theorem map_for_active94 : isHalt P.RestStream.micro0.micro0.s94.ctl = false := by host_kernel_rfl
theorem map_for_active95 : isHalt P.RestStream.micro0.micro0.s95.ctl = false := by host_kernel_rfl
theorem map_for_active96 : isHalt P.RestStream.micro0.micro0.s96.ctl = false := by host_kernel_rfl
theorem map_for_active97 : isHalt P.RestStream.micro0.micro0.s97.ctl = false := by host_kernel_rfl
theorem map_for_active98 : isHalt P.RestStream.micro0.micro0.s98.ctl = false := by host_kernel_rfl
theorem map_for_next89 : P.RestStream.micro0.micro0.s89.next = P.RestStream.micro0.micro0.s88.next := by host_kernel_rfl
theorem map_for_next92 : P.RestStream.micro0.micro0.s92.next = P.RestStream.micro0.micro0.s88.next+1 := by host_kernel_rfl
theorem map_for_next94 : P.RestStream.micro0.micro0.s94.next = P.RestStream.micro0.micro0.s88.next+1 := by host_kernel_rfl
def mapForLive (live : Nat → Prop) := CellsLive live P.RestStream.micro0.micro0.s89.next [MapFor89.sourceName]
def mapIterationLive (live : Nat → Prop) := LiveAfter (mapForLive live) P.RestStream.micro0.micro0.s94.next

/-- The actual map for-loop initializes its index, copies its first lexical
iteration binding and evaluates both operands of the original comparison. -/
theorem map_for_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event)
    (s : St P.F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s88 s)
    (targetBound : s.next+2 ≤ 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (mapIterationLive live) framed before after old old'
        P.RestStream.micro0.micro0.s99 result := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨s89,hr88,h89⟩ := MapFor88.transport NR FR R C₀ C live framed before after old old' s h
  have hb89 : s89.next+1 ≤ 2^64 := by rw [h.target_next_eq h89 map_for_next89]; omega
  obtain ⟨s90,hr89,h90⟩ := MapFor89.transport NR FR R C₀ C live framed before after old old' s89 h89 hb89
  obtain ⟨hr90,h91,_,_⟩ := MapFor90.transport FR R ν₀ ν C₀ C (mapForLive live) framed before after old old' s90 h90
  let s91 := s90.ret MapFor90.sourceValue
  obtain ⟨s92,hr91,h92⟩ := MapFor91.transport NR FR R C₀ C (mapForLive live) framed before after old old' s91 h91
  have hb92 : s92.next ≤ 2^64 := by rw [h.target_next_add h92 1 map_for_next92]; omega
  obtain ⟨s93,hr92,h93⟩ := MapFor92.transport NR FR R C₀ C (mapForLive live) framed before after old old' s92 h92 hb92
  obtain ⟨s94,hr93,h94⟩ := MapFor93.transport NR FR R C₀ C (mapForLive live) framed before after old old' s93 h93
  have hb94 : s94.next < 2^64 := by rw [h.target_next_add h94 1 map_for_next94]; omega
  obtain ⟨s95,hr94,h95⟩ := MapFor94.transport NR FR R C₀ C (mapForLive live) framed before after old old' s94 h94 hb94
  obtain ⟨s96,hr95,h96⟩ := MapFor95.transport NR FR R C₀ C (mapIterationLive live) framed before after old old' s95 h95
  obtain ⟨v96,hr96,h97,_⟩ := MapFor96.transport NR FR R C₀ C (mapIterationLive live) framed before after old old' s96 h96
  let s97 := s96.ret v96
  obtain ⟨s98,hr97,h98⟩ := MapFor97.transport NR FR R C₀ C (mapIterationLive live) framed before after old old' s97 h97
  obtain ⟨v98,hr98,h99,_⟩ := MapFor98.transport NR FR R C₀ C (mapIterationLive live) framed before after old old' s98 h98
  let s99 := s98.ret v98
  refine ⟨s99,?_,h99⟩
  apply runC_cons P.F 10 s s89 s99 C C C (h.control.isHalt_eq.trans map_for_active88) hr88
  apply runC_cons P.F 9 s89 s90 s99 C C C (h89.control.isHalt_eq.trans map_for_active89) hr89
  apply runC_cons P.F 8 s90 s91 s99 C C C (h90.control.isHalt_eq.trans map_for_active90) hr90
  apply runC_cons P.F 7 s91 s92 s99 C C C (h91.control.isHalt_eq.trans map_for_active91) hr91
  apply runC_cons P.F 6 s92 s93 s99 C C C (h92.control.isHalt_eq.trans map_for_active92) hr92
  apply runC_cons P.F 5 s93 s94 s99 C C C (h93.control.isHalt_eq.trans map_for_active93) hr93
  apply runC_cons P.F 4 s94 s95 s99 C C C (h94.control.isHalt_eq.trans map_for_active94) hr94
  apply runC_cons P.F 3 s95 s96 s99 C C C (h95.control.isHalt_eq.trans map_for_active95) hr95
  apply runC_cons P.F 2 s96 s97 s99 C C C (h96.control.isHalt_eq.trans map_for_active96) hr96
  apply runC_cons P.F 1 s97 s98 s99 C C C (h97.control.isHalt_eq.trans map_for_active97) hr97
  apply runC_cons P.F 0 s98 s99 s99 C C C (h98.control.isHalt_eq.trans map_for_active98) hr98
  rfl

end Host.Load.Run.Full.Ordinary
