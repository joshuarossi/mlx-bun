import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriverParameters
import host.ts.RenameRouteDriverBinding
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary

host_transport_parameter P.F, P.RestStream.micro0.micro0.s40 to P.RestStream.micro0.micro0.s41 as Parameter40
host_transport_binding P.F, P.RestStream.micro0.micro0.s41 to P.RestStream.micro0.micro0.s42 as Parameter41
host_transport_parameter P.F, P.RestStream.micro0.micro0.s42 to P.RestStream.micro0.micro0.s43 as Parameter42
host_transport_binding P.F, P.RestStream.micro0.micro0.s43 to P.RestStream.micro0.micro0.s44 as Parameter43
host_transport_parameter P.F, P.RestStream.micro0.micro0.s44 to P.RestStream.micro0.micro0.s45 as Parameter44
host_transport_step P.F, P.RestStream.micro0.micro0.s45 to P.RestStream.micro0.micro0.s46 as Parameter45
host_transport_parameter P.F, P.RestStream.micro0.micro0.s46 to P.RestStream.micro0.micro0.s47 as Parameter46
host_transport_binding P.F, P.RestStream.micro0.micro0.s47 to P.RestStream.micro0.micro0.s48 as Parameter47
host_transport_parameter P.F, P.RestStream.micro0.micro0.s48 to P.RestStream.micro0.micro0.s49 as Parameter48

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem parameter_active40 : isHalt P.RestStream.micro0.micro0.s40.ctl = false := by host_kernel_rfl
theorem parameter_active41 : isHalt P.RestStream.micro0.micro0.s41.ctl = false := by host_kernel_rfl
theorem parameter_active42 : isHalt P.RestStream.micro0.micro0.s42.ctl = false := by host_kernel_rfl
theorem parameter_active43 : isHalt P.RestStream.micro0.micro0.s43.ctl = false := by host_kernel_rfl
theorem parameter_active44 : isHalt P.RestStream.micro0.micro0.s44.ctl = false := by host_kernel_rfl
theorem parameter_active45 : isHalt P.RestStream.micro0.micro0.s45.ctl = false := by host_kernel_rfl
theorem parameter_active46 : isHalt P.RestStream.micro0.micro0.s46.ctl = false := by host_kernel_rfl
theorem parameter_active47 : isHalt P.RestStream.micro0.micro0.s47.ctl = false := by host_kernel_rfl
theorem parameter_active48 : isHalt P.RestStream.micro0.micro0.s48.ctl = false := by host_kernel_rfl
theorem parameter_next41 : P.RestStream.micro0.micro0.s41.next = P.RestStream.micro0.micro0.s40.next := by host_kernel_rfl
theorem parameter_next43 : P.RestStream.micro0.micro0.s43.next = P.RestStream.micro0.micro0.s40.next := by host_kernel_rfl
theorem parameter_next47 : P.RestStream.micro0.micro0.s47.next = P.RestStream.micro0.micro0.s40.next := by host_kernel_rfl
theorem parameter_next48 : P.RestStream.micro0.micro0.s48.next = P.RestStream.micro0.micro0.s40.next := by host_kernel_rfl

/-- The actual concat helper binds its two supplied arguments, reads the
default GPU stream, initializes that parameter and hoists its real body. -/
theorem concat_parameters_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s40 s)
    (targetBound : s.next + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR NR FR R (CellsLive live P.RestStream.micro0.micro0.s48.next (blockNames Parameter48.sourceBody))
        framed before after old old' P.RestStream.micro0.micro0.s49 result := by
  have hb : s.next ≤ 2^64 := Nat.le_trans (Nat.le_add_right _ _) targetBound
  obtain ⟨s41,hr40,h41⟩ := Parameter40.transport NR FR R C₀ C live framed before after old old' s h
  have hb41 : s41.next ≤ 2^64 := by rw [h.target_next_eq h41 parameter_next41]; exact hb
  obtain ⟨s42,hr41,h42⟩ := Parameter41.transport NR FR R C₀ C live framed before after old old' s41 h41 hb41
  obtain ⟨s43,hr42,h43⟩ := Parameter42.transport NR FR R C₀ C live framed before after old old' s42 h42
  have hb43 : s43.next ≤ 2^64 := by rw [h.target_next_eq h43 parameter_next43]; exact hb
  obtain ⟨s44,hr43,h44⟩ := Parameter43.transport NR FR R C₀ C live framed before after old old' s43 h43 hb43
  obtain ⟨s45,hr44,h45⟩ := Parameter44.transport NR FR R C₀ C live framed before after old old' s44 h44
  obtain ⟨v45,hr45,h46,_⟩ := Parameter45.transport NR FR R C₀ C live framed before after old old' s45 h45
  let s46 := s45.ret v45
  obtain ⟨s47,hr46,h47⟩ := Parameter46.transport NR FR R C₀ C live framed before after old old' s46 h46
  have hb47 : s47.next ≤ 2^64 := by rw [h.target_next_eq h47 parameter_next47]; exact hb
  obtain ⟨s48,hr47,h48⟩ := Parameter47.transport NR FR R C₀ C live framed before after old old' s47 h47 hb47
  have hb48 : s48.next + (blockNames Parameter48.sourceBody).length ≤ 2^64 := by
    rw [h.target_next_eq h48 parameter_next48]; exact targetBound
  obtain ⟨result,hr48,h49⟩ := Parameter48.transport NR FR R C₀ C live framed before after old old' s48 h48 hb48
  refine ⟨result,?_,h49⟩
  apply runC_cons P.F 8 s s41 result C C C (h.control.isHalt_eq.trans parameter_active40) hr40
  apply runC_cons P.F 7 s41 s42 result C C C (h41.control.isHalt_eq.trans parameter_active41) hr41
  apply runC_cons P.F 6 s42 s43 result C C C (h42.control.isHalt_eq.trans parameter_active42) hr42
  apply runC_cons P.F 5 s43 s44 result C C C (h43.control.isHalt_eq.trans parameter_active43) hr43
  apply runC_cons P.F 4 s44 s45 result C C C (h44.control.isHalt_eq.trans parameter_active44) hr44
  apply runC_cons P.F 3 s45 s46 result C C C (h45.control.isHalt_eq.trans parameter_active45) hr45
  apply runC_cons P.F 2 s46 s47 result C C C (h46.control.isHalt_eq.trans parameter_active46) hr46
  apply runC_cons P.F 1 s47 s48 result C C C (h47.control.isHalt_eq.trans parameter_active47) hr47
  apply runC_cons P.F 0 s48 result result C C C (h48.control.isHalt_eq.trans parameter_active48) hr48
  rfl

/-- error: host_transport_step: unsupported source constructor Host.Ts.Ctl.construct -/
#guard_msgs in
host_transport_parameter P.F, P.RestStream.micro0.micro0.s12 to P.RestStream.micro0.micro0.s13 as UnsupportedConstructParameter

end Host.Load.Run.Full.Ordinary
