import host.ts.renameOrdinary.DriverMapSecond
import host.ts.RenameMapBodyEffects
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem MapBody157.active : isHalt MapBody157.input.ctl = false := by host_kernel_rfl

theorem MapBody157.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody157.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_for_body_heap_from_source P.F NR FR R live framed before after old old' MapBody157.input s result C D h MapBody157.sourceGuard MapBody157.sourceTest MapBody157.sourceUpdate MapBody157.sourceBody MapBody157.sourceEnv MapBody157.sourceNames MapBody157.sourceLabels MapBody157.sourceTail MapBody157.source_control MapBody157.source_frame run

theorem MapBody158.active : isHalt MapBody158.input.ctl = false := by host_kernel_rfl

theorem MapBody158.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody158.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_statement_heap P.F NR FR R live framed before after old old' MapBody158.input s result C D h MapBody158.sourceAction MapBody158.sourceEnv MapBody158.source_control run

theorem MapBody159.active : isHalt MapBody159.input.ctl = false := by host_kernel_rfl

theorem MapBody159.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody159.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_method_descent_heap P.F NR FR R live framed before after old old' MapBody159.input s result C₀ C D h MapBody159.sourceExpression MapBody159.sourceName MapBody159.sourceArgs MapBody159.sourceEnv MapBody159.sourceOptObject MapBody159.sourceOptCall MapBody159.source_control run

theorem MapBody160.active : isHalt MapBody160.input.ctl = false := by host_kernel_rfl

theorem MapBody160.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody160.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_variable_heap_from_source P.F NR FR R live framed before after old old' MapBody160.input s result C₀ C D h MapBody160.sourceName MapBody160.sourceEnv MapBody160.address MapBody160.sourceValue MapBody160.source_control MapBody160.source_lookup MapBody160.source_cell run

theorem MapBody161.active : isHalt MapBody161.input.ctl = false := by host_kernel_rfl

theorem MapBody161.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody161.input s)
    (notFramed : ¬ framed MapBody161.sourceAddress)
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨other,_,hr,_,heap⟩ := step_array_method_from_source_fields P.F NR FR R C₀ C live framed
    before after old old' MapBody161.input s h MapBody161.sourceAddress MapBody161.sourcePrototype
    MapBody161.sourceObject MapBody161.sourceParent MapBody161.sourceElements MapBody161.sourceName MapBody161.sourceArgs
    MapBody161.sourceEnv MapBody161.sourceOptObject MapBody161.sourceOptCall MapBody161.sourceMethod MapBody161.sourceWritable
    MapBody161.sourceEnumerable MapBody161.sourceTail MapBody161.source_control MapBody161.source_frame MapBody161.source_heap
    MapBody161.source_kind MapBody161.source_nonindex MapBody161.source_nonlength MapBody161.source_absent MapBody161.source_prototype
    MapBody161.source_parent MapBody161.source_parentKind MapBody161.source_property notFramed
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  exact (congrArg St.heap he).trans heap

theorem MapBody162.active : isHalt MapBody162.input.ctl = false := by host_kernel_rfl

theorem MapBody162.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody162.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_callStart_heap P.F NR FR R live framed before after old old' MapBody162.input s result C D h MapBody162.sourceMode MapBody162.sourceAddress MapBody162.sourceThis MapBody162.sourceArgs MapBody162.sourceEnv MapBody162.sourceTail MapBody162.source_control MapBody162.source_frame run

theorem MapBody163.active : isHalt MapBody163.input.ctl = false := by host_kernel_rfl

theorem MapBody163.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody163.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_identifier_call_heap P.F NR FR R live framed before after old old' MapBody163.input s result C₀ C D h MapBody163.sourceName MapBody163.sourceArgs MapBody163.sourceOptional MapBody163.sourceEnv MapBody163.source_control run

theorem MapBody164.active : isHalt MapBody164.input.ctl = false := by host_kernel_rfl

theorem MapBody164.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody164.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_variable_heap_from_source P.F NR FR R live framed before after old old' MapBody164.input s result C₀ C D h MapBody164.sourceName MapBody164.sourceEnv MapBody164.address MapBody164.sourceValue MapBody164.source_control MapBody164.source_lookup MapBody164.source_cell run

theorem MapBody165.active : isHalt MapBody165.input.ctl = false := by host_kernel_rfl

theorem MapBody165.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody165.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_callStart_heap P.F NR FR R live framed before after old old' MapBody165.input s result C D h (.callee MapBody165.sourceOptional) MapBody165.sourceAddress .undef MapBody165.sourceArgs MapBody165.sourceEnv MapBody165.sourceTail MapBody165.source_control MapBody165.source_frame run

theorem MapBody166.active : isHalt MapBody166.input.ctl = false := by host_kernel_rfl

theorem MapBody166.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody166.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_descent_heap_from_source P.F NR FR R live framed before after old old' MapBody166.input s result C D h MapBody166.descent MapBody166.sourceEnv MapBody166.source_control run

theorem MapBody167.active : isHalt MapBody167.input.ctl = false := by host_kernel_rfl

theorem MapBody167.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody167.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody167.input s result C₀ C D h MapBody167.sourceEnv MapBody167.sourceAddress MapBody167.sourceValue MapBody167.source_control MapBody167.source_lookup MapBody167.source_cell run

theorem MapBody168.active : isHalt MapBody168.input.ctl = false := by host_kernel_rfl

theorem MapBody168.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody168.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_index_left_heap_from_source P.F NR FR R live framed before after old old' MapBody168.input s result C D h MapBody168.sourceValue MapBody168.sourceKey MapBody168.sourceEnv MapBody168.sourceTail MapBody168.source_control MapBody168.source_frame run

theorem MapBody169.active : isHalt MapBody169.input.ctl = false := by host_kernel_rfl

theorem MapBody169.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody169.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_variable_heap_from_source P.F NR FR R live framed before after old old' MapBody169.input s result C₀ C D h MapBody169.sourceName MapBody169.sourceEnv MapBody169.address MapBody169.sourceValue MapBody169.source_control MapBody169.source_lookup MapBody169.source_cell run

/-- The second callback index is read from the map's executed first update.
All thirteen intervening original operations preserve the complete heap. -/
theorem map_second_body_to_index (NR : NumV → NumV → Prop)
    (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody157.input s)
    (resultNotFramed : ¬ framed 3126677)
    (indexCell : s.heap.get (R.a 3126683) = some (.cell (some (natV 1)))) :
    ∃ result, runC P.F 13 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' MapBody170.input result ∧
      result.ctl = .ret (natV 1) ∧ result.heap = s.heap := by
  obtain ⟨s101,hr100,h101⟩ := MapBody157.transport NR FR R C₀ C live framed before after old old' s h
  have heap101 : s101.heap = s.heap := MapBody157.heap NR FR R C₀ C C live framed before after old old' s s101 h hr100
  obtain ⟨s102,hr101,h102⟩ := MapBody158.transport NR FR R C₀ C live framed before after old old' s101 h101
  have heap102 : s102.heap = s101.heap := MapBody158.heap NR FR R C₀ C C live framed before after old old' s101 s102 h101 hr101
  obtain ⟨s103,hr102,h103⟩ := MapBody159.transport NR FR R C₀ C live framed before after old old' s102 h102
  have heap103 : s103.heap = s102.heap := MapBody159.heap NR FR R C₀ C C live framed before after old old' s102 s103 h102 hr102
  obtain ⟨v103,hr103,h104,_⟩ := MapBody160.transport NR FR R C₀ C live framed before after old old' s103 h103
  let s104 := s103.ret v103
  have heap104 : s104.heap = s103.heap := MapBody160.heap NR FR R C₀ C C live framed before after old old' s103 s104 h103 hr103
  obtain ⟨s105,hr104,h105⟩ := MapBody161.transport NR FR R C₀ C live framed before after old old' s104 h104 resultNotFramed
  have heap105 : s105.heap = s104.heap := MapBody161.heap NR FR R C₀ C C live framed before after old old' s104 s105 h104 resultNotFramed hr104
  obtain ⟨s106,hr105,h106⟩ := MapBody162.transport NR FR R C₀ C live framed before after old old' s105 h105
  have heap106 : s106.heap = s105.heap := MapBody162.heap NR FR R C₀ C C live framed before after old old' s105 s106 h105 hr105
  obtain ⟨s107,hr106,h107⟩ := MapBody163.transport NR FR R C₀ C live framed before after old old' s106 h106
  have heap107 : s107.heap = s106.heap := MapBody163.heap NR FR R C₀ C C live framed before after old old' s106 s107 h106 hr106
  obtain ⟨v107,hr107,h108,_⟩ := MapBody164.transport NR FR R C₀ C live framed before after old old' s107 h107
  let s108 := s107.ret v107
  have heap108 : s108.heap = s107.heap := MapBody164.heap NR FR R C₀ C C live framed before after old old' s107 s108 h107 hr107
  obtain ⟨s109,hr108,h109⟩ := MapBody165.transport NR FR R C₀ C live framed before after old old' s108 h108
  have heap109 : s109.heap = s108.heap := MapBody165.heap NR FR R C₀ C C live framed before after old old' s108 s109 h108 hr108
  obtain ⟨s110,hr109,h110⟩ := MapBody166.transport NR FR R C₀ C live framed before after old old' s109 h109
  have heap110 : s110.heap = s109.heap := MapBody166.heap NR FR R C₀ C C live framed before after old old' s109 s110 h109 hr109
  obtain ⟨s111,hr110,h111⟩ := MapBody167.transport NR FR R C₀ C live framed before after old old' s110 h110
  have heap111 : s111.heap = s110.heap := MapBody167.heap NR FR R C₀ C C live framed before after old old' s110 s111 h110 hr110
  obtain ⟨s112,hr111,h112⟩ := MapBody168.transport NR FR R C₀ C live framed before after old old' s111 h111
  have heap112 : s112.heap = s111.heap := MapBody168.heap NR FR R C₀ C C live framed before after old old' s111 s112 h111 hr111
  obtain ⟨v112,hr112,h113,_⟩ := MapBody169.transport NR FR R C₀ C live framed before after old old' s112 h112
  let s113 := s112.ret v112
  have heap113 : s113.heap = s112.heap := MapBody169.heap NR FR R C₀ C C live framed before after old old' s112 s113 h112 hr112
  have heap : s112.heap = s.heap := by
    rw [heap112,heap111,heap110,heap109,heap108,heap107,heap106,heap105,heap104,heap103,heap102,heap101]
  have lookup : lookupEnv MapBody169.sourceName (R.env MapBody169.sourceEnv) = some (R.a 3126683) := by
    rw [lookupEnv_map,MapBody169.source_lookup]
    rfl
  have hc := (h112.control_view MapBody169.source_control).ev_view
  have cell : s112.heap.get (R.a 3126683) = some (.cell (some (natV 1))) := by rw [heap]; exact indexCell
  have exactRun : interpC (step P.F s112).run C = some (s112.ret (natV 1),C) := by
    rw [step_variable_eq P.F s112 MapBody169.sourceName (R.env MapBody169.sourceEnv) (R.a 3126683)
      (natV 1) hc lookup cell]
    rfl
  have he := congrArg (fun p : St P.F.S × CSrv => p.1.ctl) (Option.some.inj (hr112.symm.trans exactRun))
  have hv : v112 = natV 1 := Ctl.ret.inj he
  refine ⟨s113,?_,h113,?_,heap113.trans heap⟩
  · apply runC_cons P.F 12 s s101 s113 C C C (h.control.isHalt_eq.trans MapBody157.active) hr100
    apply runC_cons P.F 11 s101 s102 s113 C C C (h101.control.isHalt_eq.trans MapBody158.active) hr101
    apply runC_cons P.F 10 s102 s103 s113 C C C (h102.control.isHalt_eq.trans MapBody159.active) hr102
    apply runC_cons P.F 9 s103 s104 s113 C C C (h103.control.isHalt_eq.trans MapBody160.active) hr103
    apply runC_cons P.F 8 s104 s105 s113 C C C (h104.control.isHalt_eq.trans MapBody161.active) hr104
    apply runC_cons P.F 7 s105 s106 s113 C C C (h105.control.isHalt_eq.trans MapBody162.active) hr105
    apply runC_cons P.F 6 s106 s107 s113 C C C (h106.control.isHalt_eq.trans MapBody163.active) hr106
    apply runC_cons P.F 5 s107 s108 s113 C C C (h107.control.isHalt_eq.trans MapBody164.active) hr107
    apply runC_cons P.F 4 s108 s109 s113 C C C (h108.control.isHalt_eq.trans MapBody165.active) hr108
    apply runC_cons P.F 3 s109 s110 s113 C C C (h109.control.isHalt_eq.trans MapBody166.active) hr109
    apply runC_cons P.F 2 s110 s111 s113 C C C (h110.control.isHalt_eq.trans MapBody167.active) hr110
    apply runC_cons P.F 1 s111 s112 s113 C C C (h111.control.isHalt_eq.trans MapBody168.active) hr111
    apply runC_cons P.F 0 s112 s113 s113 C C C (h112.control.isHalt_eq.trans MapBody169.active) hr112
    rfl
  · change Ctl.ret v112 = Ctl.ret (natV 1)
    rw [hv]

end Host.Load.Run.Full.Ordinary
