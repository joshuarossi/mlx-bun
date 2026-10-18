import host.ts.renameOrdinary.DriverMapBody
import host.ts.RenameMapBodyEffects
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem MapBody100.active : isHalt MapBody100.input.ctl = false := by host_kernel_rfl

theorem MapBody100.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody100.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_for_body_heap_from_source P.F NR FR R live framed before after old old' MapBody100.input s result C D h MapBody100.sourceGuard MapBody100.sourceTest MapBody100.sourceUpdate MapBody100.sourceBody MapBody100.sourceEnv MapBody100.sourceNames MapBody100.sourceLabels MapBody100.sourceTail MapBody100.source_control MapBody100.source_frame run

theorem MapBody101.active : isHalt MapBody101.input.ctl = false := by host_kernel_rfl

theorem MapBody101.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody101.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_statement_heap P.F NR FR R live framed before after old old' MapBody101.input s result C D h MapBody101.sourceAction MapBody101.sourceEnv MapBody101.source_control run

theorem MapBody102.active : isHalt MapBody102.input.ctl = false := by host_kernel_rfl

theorem MapBody102.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody102.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_method_descent_heap P.F NR FR R live framed before after old old' MapBody102.input s result C₀ C D h MapBody102.sourceExpression MapBody102.sourceName MapBody102.sourceArgs MapBody102.sourceEnv MapBody102.sourceOptObject MapBody102.sourceOptCall MapBody102.source_control run

theorem MapBody103.active : isHalt MapBody103.input.ctl = false := by host_kernel_rfl

theorem MapBody103.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody103.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_variable_heap_from_source P.F NR FR R live framed before after old old' MapBody103.input s result C₀ C D h MapBody103.sourceName MapBody103.sourceEnv MapBody103.address MapBody103.sourceValue MapBody103.source_control MapBody103.source_lookup MapBody103.source_cell run

theorem MapBody104.active : isHalt MapBody104.input.ctl = false := by host_kernel_rfl

theorem MapBody104.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody104.input s)
    (notFramed : ¬ framed MapBody104.sourceAddress)
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨other,_,hr,_,heap⟩ := step_array_method_from_source_fields P.F NR FR R C₀ C live framed
    before after old old' MapBody104.input s h MapBody104.sourceAddress MapBody104.sourcePrototype
    MapBody104.sourceObject MapBody104.sourceParent MapBody104.sourceElements MapBody104.sourceName MapBody104.sourceArgs
    MapBody104.sourceEnv MapBody104.sourceOptObject MapBody104.sourceOptCall MapBody104.sourceMethod MapBody104.sourceWritable
    MapBody104.sourceEnumerable MapBody104.sourceTail MapBody104.source_control MapBody104.source_frame MapBody104.source_heap
    MapBody104.source_kind MapBody104.source_nonindex MapBody104.source_nonlength MapBody104.source_absent MapBody104.source_prototype
    MapBody104.source_parent MapBody104.source_parentKind MapBody104.source_property notFramed
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  exact (congrArg St.heap he).trans heap

theorem MapBody105.active : isHalt MapBody105.input.ctl = false := by host_kernel_rfl

theorem MapBody105.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody105.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_callStart_heap P.F NR FR R live framed before after old old' MapBody105.input s result C D h MapBody105.sourceMode MapBody105.sourceAddress MapBody105.sourceThis MapBody105.sourceArgs MapBody105.sourceEnv MapBody105.sourceTail MapBody105.source_control MapBody105.source_frame run

theorem MapBody106.active : isHalt MapBody106.input.ctl = false := by host_kernel_rfl

theorem MapBody106.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody106.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_identifier_call_heap P.F NR FR R live framed before after old old' MapBody106.input s result C₀ C D h MapBody106.sourceName MapBody106.sourceArgs MapBody106.sourceOptional MapBody106.sourceEnv MapBody106.source_control run

theorem MapBody107.active : isHalt MapBody107.input.ctl = false := by host_kernel_rfl

theorem MapBody107.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody107.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_variable_heap_from_source P.F NR FR R live framed before after old old' MapBody107.input s result C₀ C D h MapBody107.sourceName MapBody107.sourceEnv MapBody107.address MapBody107.sourceValue MapBody107.source_control MapBody107.source_lookup MapBody107.source_cell run

theorem MapBody108.active : isHalt MapBody108.input.ctl = false := by host_kernel_rfl

theorem MapBody108.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody108.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_callStart_heap P.F NR FR R live framed before after old old' MapBody108.input s result C D h (.callee MapBody108.sourceOptional) MapBody108.sourceAddress .undef MapBody108.sourceArgs MapBody108.sourceEnv MapBody108.sourceTail MapBody108.source_control MapBody108.source_frame run

theorem MapBody109.active : isHalt MapBody109.input.ctl = false := by host_kernel_rfl

theorem MapBody109.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody109.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_descent_heap_from_source P.F NR FR R live framed before after old old' MapBody109.input s result C D h MapBody109.descent MapBody109.sourceEnv MapBody109.source_control run

theorem MapBody110.active : isHalt MapBody110.input.ctl = false := by host_kernel_rfl

theorem MapBody110.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody110.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody110.input s result C₀ C D h MapBody110.sourceEnv MapBody110.sourceAddress MapBody110.sourceValue MapBody110.source_control MapBody110.source_lookup MapBody110.source_cell run

theorem MapBody111.active : isHalt MapBody111.input.ctl = false := by host_kernel_rfl

theorem MapBody111.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody111.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_index_left_heap_from_source P.F NR FR R live framed before after old old' MapBody111.input s result C D h MapBody111.sourceValue MapBody111.sourceKey MapBody111.sourceEnv MapBody111.sourceTail MapBody111.source_control MapBody111.source_frame run

theorem MapBody112.active : isHalt MapBody112.input.ctl = false := by host_kernel_rfl

theorem MapBody112.heap (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody112.input s)
    
    (run : interpC (step P.F s).run C = some (result,D)) : result.heap = s.heap := by
  exact step_variable_heap_from_source P.F NR FR R live framed before after old old' MapBody112.input s result C₀ C D h MapBody112.sourceName MapBody112.sourceEnv MapBody112.address MapBody112.sourceValue MapBody112.source_control MapBody112.source_lookup MapBody112.source_cell run

/-- The first callback index is read from the map's executed initializer.
All thirteen intervening original operations preserve the complete heap. -/
theorem map_body_to_index (NR : NumV → NumV → Prop)
    (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapBody100.input s)
    (resultNotFramed : ¬ framed 3126677)
    (indexCell : s.heap.get (R.a 3126679) = some (.cell (some (natV 0)))) :
    ∃ result, runC P.F 13 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' MapBody113.input result ∧
      result.ctl = .ret (natV 0) ∧ result.heap = s.heap := by
  obtain ⟨s101,hr100,h101⟩ := MapBody100.transport NR FR R C₀ C live framed before after old old' s h
  have heap101 : s101.heap = s.heap := MapBody100.heap NR FR R C₀ C C live framed before after old old' s s101 h hr100
  obtain ⟨s102,hr101,h102⟩ := MapBody101.transport NR FR R C₀ C live framed before after old old' s101 h101
  have heap102 : s102.heap = s101.heap := MapBody101.heap NR FR R C₀ C C live framed before after old old' s101 s102 h101 hr101
  obtain ⟨s103,hr102,h103⟩ := MapBody102.transport NR FR R C₀ C live framed before after old old' s102 h102
  have heap103 : s103.heap = s102.heap := MapBody102.heap NR FR R C₀ C C live framed before after old old' s102 s103 h102 hr102
  obtain ⟨v103,hr103,h104,_⟩ := MapBody103.transport NR FR R C₀ C live framed before after old old' s103 h103
  let s104 := s103.ret v103
  have heap104 : s104.heap = s103.heap := MapBody103.heap NR FR R C₀ C C live framed before after old old' s103 s104 h103 hr103
  obtain ⟨s105,hr104,h105⟩ := MapBody104.transport NR FR R C₀ C live framed before after old old' s104 h104 resultNotFramed
  have heap105 : s105.heap = s104.heap := MapBody104.heap NR FR R C₀ C C live framed before after old old' s104 s105 h104 resultNotFramed hr104
  obtain ⟨s106,hr105,h106⟩ := MapBody105.transport NR FR R C₀ C live framed before after old old' s105 h105
  have heap106 : s106.heap = s105.heap := MapBody105.heap NR FR R C₀ C C live framed before after old old' s105 s106 h105 hr105
  obtain ⟨s107,hr106,h107⟩ := MapBody106.transport NR FR R C₀ C live framed before after old old' s106 h106
  have heap107 : s107.heap = s106.heap := MapBody106.heap NR FR R C₀ C C live framed before after old old' s106 s107 h106 hr106
  obtain ⟨v107,hr107,h108,_⟩ := MapBody107.transport NR FR R C₀ C live framed before after old old' s107 h107
  let s108 := s107.ret v107
  have heap108 : s108.heap = s107.heap := MapBody107.heap NR FR R C₀ C C live framed before after old old' s107 s108 h107 hr107
  obtain ⟨s109,hr108,h109⟩ := MapBody108.transport NR FR R C₀ C live framed before after old old' s108 h108
  have heap109 : s109.heap = s108.heap := MapBody108.heap NR FR R C₀ C C live framed before after old old' s108 s109 h108 hr108
  obtain ⟨s110,hr109,h110⟩ := MapBody109.transport NR FR R C₀ C live framed before after old old' s109 h109
  have heap110 : s110.heap = s109.heap := MapBody109.heap NR FR R C₀ C C live framed before after old old' s109 s110 h109 hr109
  obtain ⟨s111,hr110,h111⟩ := MapBody110.transport NR FR R C₀ C live framed before after old old' s110 h110
  have heap111 : s111.heap = s110.heap := MapBody110.heap NR FR R C₀ C C live framed before after old old' s110 s111 h110 hr110
  obtain ⟨s112,hr111,h112⟩ := MapBody111.transport NR FR R C₀ C live framed before after old old' s111 h111
  have heap112 : s112.heap = s111.heap := MapBody111.heap NR FR R C₀ C C live framed before after old old' s111 s112 h111 hr111
  obtain ⟨v112,hr112,h113,_⟩ := MapBody112.transport NR FR R C₀ C live framed before after old old' s112 h112
  let s113 := s112.ret v112
  have heap113 : s113.heap = s112.heap := MapBody112.heap NR FR R C₀ C C live framed before after old old' s112 s113 h112 hr112
  have heap : s112.heap = s.heap := by
    rw [heap112,heap111,heap110,heap109,heap108,heap107,heap106,heap105,heap104,heap103,heap102,heap101]
  have lookup : lookupEnv MapBody112.sourceName (R.env MapBody112.sourceEnv) = some (R.a 3126679) := by
    rw [lookupEnv_map,MapBody112.source_lookup]
    rfl
  have hc := (h112.control_view MapBody112.source_control).ev_view
  have cell : s112.heap.get (R.a 3126679) = some (.cell (some (natV 0))) := by rw [heap]; exact indexCell
  have exactRun : interpC (step P.F s112).run C = some (s112.ret (natV 0),C) := by
    rw [step_variable_eq P.F s112 MapBody112.sourceName (R.env MapBody112.sourceEnv) (R.a 3126679)
      (natV 0) hc lookup cell]
    rfl
  have he := congrArg (fun p : St P.F.S × CSrv => p.1.ctl) (Option.some.inj (hr112.symm.trans exactRun))
  have hv : v112 = natV 0 := Ctl.ret.inj he
  refine ⟨s113,?_,h113,?_,heap113.trans heap⟩
  · apply runC_cons P.F 12 s s101 s113 C C C (h.control.isHalt_eq.trans MapBody100.active) hr100
    apply runC_cons P.F 11 s101 s102 s113 C C C (h101.control.isHalt_eq.trans MapBody101.active) hr101
    apply runC_cons P.F 10 s102 s103 s113 C C C (h102.control.isHalt_eq.trans MapBody102.active) hr102
    apply runC_cons P.F 9 s103 s104 s113 C C C (h103.control.isHalt_eq.trans MapBody103.active) hr103
    apply runC_cons P.F 8 s104 s105 s113 C C C (h104.control.isHalt_eq.trans MapBody104.active) hr104
    apply runC_cons P.F 7 s105 s106 s113 C C C (h105.control.isHalt_eq.trans MapBody105.active) hr105
    apply runC_cons P.F 6 s106 s107 s113 C C C (h106.control.isHalt_eq.trans MapBody106.active) hr106
    apply runC_cons P.F 5 s107 s108 s113 C C C (h107.control.isHalt_eq.trans MapBody107.active) hr107
    apply runC_cons P.F 4 s108 s109 s113 C C C (h108.control.isHalt_eq.trans MapBody108.active) hr108
    apply runC_cons P.F 3 s109 s110 s113 C C C (h109.control.isHalt_eq.trans MapBody109.active) hr109
    apply runC_cons P.F 2 s110 s111 s113 C C C (h110.control.isHalt_eq.trans MapBody110.active) hr110
    apply runC_cons P.F 1 s111 s112 s113 C C C (h111.control.isHalt_eq.trans MapBody111.active) hr111
    apply runC_cons P.F 0 s112 s113 s113 C C C (h112.control.isHalt_eq.trans MapBody112.active) hr112
    rfl
  · change Ctl.ret v112 = Ctl.ret (natV 0)
    rw [hv]

end Host.Load.Run.Full.Ordinary
