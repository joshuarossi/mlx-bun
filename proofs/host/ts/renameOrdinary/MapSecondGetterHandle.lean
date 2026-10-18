import host.ts.renameOrdinary.DriverMapSecond
import host.ts.RenameRouteComposition
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteArgumentFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The second map callback obtains its owned handle through the actual getter,
disposed guard, getter return and callback return into the array-push argument.
The owned value is supplied only at the initial object field. -/
theorem map_second_getter_handle_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' MapBody185.input s)
    (field : PrivateData s (R.a MapBody195.sourceAddress) (R.a MapBody195.sourceBrand)
      MapBody195.sourceName (.big (Int.ofNat (R.handle 29363)))) :
    ∃ result, runC P.F 18 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' MapBody202.output result ∧
      callArgument result.ctl 0 = .big (Int.ofNat (R.handle 29363)) ∧ result.heap = s.heap := by
  obtain ⟨s31,hr30,h31⟩ := MapBody185.transport NR FR R C₀ C live framed before after old old' s h
  have hh31 := step_block_next_heap P.F NR FR R live framed before after old old' MapBody185.input s s31 C C h
    MapBody185.sourceValue MapBody185.sourceStatement MapBody185.sourceRest MapBody185.sourceEnv MapBody185.sourceTail
    MapBody185.source_control MapBody185.source_frame hr30
  have heap31 : s31.heap = s.heap := hh31
  obtain ⟨s32,hr31,h32⟩ := MapBody186.transport NR FR R C₀ C live framed before after old old' s31 h31
  have hh32 := step_statement_heap P.F NR FR R live framed before after old old' MapBody186.input s31 s32 C C h31 MapBody186.sourceAction MapBody186.sourceEnv MapBody186.source_control hr31
  have heap32 : s32.heap = s.heap := hh32.trans heap31
  obtain ⟨s33,hr32,h33⟩ := MapBody187.transport NR FR R C₀ C live framed before after old old' s32 h32
  have hh33 := step_private_descent_heap P.F NR FR R live framed before after old old' MapBody187.input s32 s33 C₀ C C h32
    MapBody187.sourceObject MapBody187.sourceName MapBody187.sourceOptional MapBody187.sourceEnv MapBody187.sourceBrand
    MapBody187.source_control MapBody187.source_brand hr32
  have heap33 : s33.heap = s.heap := hh33.trans heap32
  obtain ⟨s34,hr33,h34⟩ := MapBody188.transport NR FR R C₀ C live framed before after old old' s33 h33
  have hh34 := step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody188.input s33 s34 C₀ C C h33
    MapBody188.sourceEnv MapBody188.sourceAddress MapBody188.sourceValue MapBody188.source_control MapBody188.source_lookup MapBody188.source_cell hr33
  have heap34 : s34.heap = s.heap := hh34.trans heap33
  obtain ⟨s35,hr34,h35⟩ := MapBody189.transport NR FR R C₀ C live framed before after old old' s34 h34
  have hh35 := MapBody189.heap_frame NR FR R C₀ C C live framed before after old old' s34 s35 h34 hr34
  have heap35 : s35.heap = s.heap := hh35.trans heap34
  obtain ⟨s36,hr35,h36⟩ := MapBody190.transport NR FR R C₀ C live framed before after old old' s35 h35
  have hh36 := step_if_heap P.F NR FR R live framed before after old old' MapBody190.input s35 s36 C C h35
    MapBody190.sourceGuard MapBody190.sourceYes MapBody190.sourceNo MapBody190.sourceEnv MapBody190.sourceTail MapBody190.source_control MapBody190.source_frame hr35
  have heap36 : s36.heap = s.heap := hh36.trans heap35
  obtain ⟨s37,hr36,h37⟩ := MapBody191.transport NR FR R C₀ C live framed before after old old' s36 h36
  have hh37 := step_block_next_heap P.F NR FR R live framed before after old old' MapBody191.input s36 s37 C C h36
    MapBody191.sourceValue MapBody191.sourceStatement MapBody191.sourceRest MapBody191.sourceEnv MapBody191.sourceTail
    MapBody191.source_control MapBody191.source_frame hr36
  have heap37 : s37.heap = s.heap := hh37.trans heap36
  obtain ⟨s38,hr37,h38⟩ := MapBody192.transport NR FR R C₀ C live framed before after old old' s37 h37
  have hh38 := step_statement_heap P.F NR FR R live framed before after old old' MapBody192.input s37 s38 C C h37
    (.returnExpression MapBody192.sourceExpression) MapBody192.sourceEnv MapBody192.source_control hr37
  have heap38 : s38.heap = s.heap := hh38.trans heap37
  obtain ⟨s39,hr38,h39⟩ := MapBody193.transport NR FR R C₀ C live framed before after old old' s38 h38
  have hh39 := step_private_descent_heap P.F NR FR R live framed before after old old' MapBody193.input s38 s39 C₀ C C h38
    MapBody193.sourceObject MapBody193.sourceName MapBody193.sourceOptional MapBody193.sourceEnv MapBody193.sourceBrand
    MapBody193.source_control MapBody193.source_brand hr38
  have heap39 : s39.heap = s.heap := hh39.trans heap38
  obtain ⟨s40,hr39,h40⟩ := MapBody194.transport NR FR R C₀ C live framed before after old old' s39 h39
  have hh40 := step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody194.input s39 s40 C₀ C C h39
    MapBody194.sourceEnv MapBody194.sourceAddress MapBody194.sourceValue MapBody194.source_control MapBody194.source_lookup MapBody194.source_cell hr39
  have heap40 : s40.heap = s.heap := hh40.trans heap39
  obtain ⟨s41,hr40,h41⟩ := MapBody195.transport NR FR R C₀ C live framed before after old old' s40 h40
  have hh41 := MapBody195.heap_frame NR FR R C₀ C C live framed before after old old' s40 s41 h40 hr40
  have heap41 : s41.heap = s.heap := hh41.trans heap40
  have fixed40 := field.heap_eq heap40
  have hc41 := (step_private_data_fields P.F NR FR R live framed before after old old' MapBody195.input s40 s41 C C h40
    MapBody195.sourceAddress MapBody195.sourceBrand MapBody195.sourceName (.big (Int.ofNat (R.handle 29363))) MapBody195.sourceTail
    MapBody195.source_control MapBody195.source_frame fixed40 hr40).1
  obtain ⟨s42,hr41,h42⟩ := MapBody196.transport NR FR R C₀ C live framed before after old old' s41 h41
  have hh42 := step_return_exit_heap P.F NR FR R live framed before after old old' MapBody196.input s41 s42 C C h41
    MapBody196.sourceValue MapBody196.sourceAction MapBody196.sourceEnv MapBody196.sourceTail MapBody196.source_control MapBody196.source_frame hr41
  have heap42 : s42.heap = s.heap := hh42.trans heap41
  have hc42 := step_return_exit_control P.F NR FR R live framed before after old old' MapBody196.input s41 s42 C C h41
    (.big (Int.ofNat (R.handle 29363))) MapBody196.sourceAction MapBody196.sourceEnv MapBody196.sourceTail MapBody196.source_frame hc41 hr41
  obtain ⟨s43,hr42,h43⟩ := MapBody197.transport NR FR R C₀ C live framed before after old old' s42 h42
  have hh43 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody197.input s42 s43 C C h42
    MapBody197.sourceValue MapBody197.sourceAction MapBody197.sourceEnv MapBody197.sourceTail MapBody197.source_control MapBody197.source_frame hr42
  have heap43 : s43.heap = s.heap := hh43.trans heap42
  have hc43 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody197.input s42 s43 C C h42
    (.big (Int.ofNat (R.handle 29363))) MapBody197.sourceAction MapBody197.sourceEnv MapBody197.sourceTail MapBody197.source_frame hc42 hr42
  obtain ⟨s44,hr43,h44⟩ := MapBody198.transport NR FR R C₀ C live framed before after old old' s43 h43
  have hh44 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody198.input s43 s44 C C h43
    MapBody198.sourceValue MapBody198.sourceAction MapBody198.sourceEnv MapBody198.sourceTail MapBody198.source_control MapBody198.source_frame hr43
  have heap44 : s44.heap = s.heap := hh44.trans heap43
  have hc44 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody198.input s43 s44 C C h43
    (.big (Int.ofNat (R.handle 29363))) MapBody198.sourceAction MapBody198.sourceEnv MapBody198.sourceTail MapBody198.source_frame hc43 hr43
  obtain ⟨s45,hr44,h45⟩ := MapBody199.transport NR FR R C₀ C live framed before after old old' s44 h44
  have hh45 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody199.input s44 s45 C C h44
    MapBody199.sourceValue MapBody199.sourceAction MapBody199.sourceEnv MapBody199.sourceTail MapBody199.source_control MapBody199.source_frame hr44
  have heap45 : s45.heap = s.heap := hh45.trans heap44
  have hc45 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody199.input s44 s45 C C h44
    (.big (Int.ofNat (R.handle 29363))) MapBody199.sourceAction MapBody199.sourceEnv MapBody199.sourceTail MapBody199.source_frame hc44 hr44
  obtain ⟨s144,hr143,h144⟩ := MapBody200.transport NR FR R C₀ C live framed before after old old' s45 h45
  have hh144 := step_return_exit_heap P.F NR FR R live framed before after old old' MapBody200.input s45 s144 C C h45
    MapBody200.sourceValue MapBody200.sourceAction MapBody200.sourceEnv MapBody200.sourceTail MapBody200.source_control MapBody200.source_frame hr143
  have heap144 : s144.heap = s.heap := hh144.trans heap45
  have hc144 := step_return_exit_control P.F NR FR R live framed before after old old' MapBody200.input s45 s144 C C h45
    (.big (Int.ofNat (R.handle 29363))) MapBody200.sourceAction MapBody200.sourceEnv MapBody200.sourceTail MapBody200.source_frame hc45 hr143
  obtain ⟨s145,hr144,h145⟩ := MapBody201.transport NR FR R C₀ C live framed before after old old' s144 h144
  have hh145 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody201.input s144 s145 C C h144
    MapBody201.sourceValue MapBody201.sourceAction MapBody201.sourceEnv MapBody201.sourceTail MapBody201.source_control MapBody201.source_frame hr144
  have heap145 : s145.heap = s.heap := hh145.trans heap144
  have hc145 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody201.input s144 s145 C C h144
    (.big (Int.ofNat (R.handle 29363))) MapBody201.sourceAction MapBody201.sourceEnv MapBody201.sourceTail MapBody201.source_frame hc144 hr144
  obtain ⟨s46,hr45,h46⟩ := MapBody202.transport NR FR R C₀ C live framed before after old old' s145 h145
  have hh46 := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody202.input s145 s46 C C h145
    MapBody202.sourceValue MapBody202.sourceKind MapBody202.sourceFunction MapBody202.sourceThis MapBody202.sourceAcc MapBody202.sourceRest
    MapBody202.sourceEnv MapBody202.sourceTail MapBody202.source_control MapBody202.source_frame (by decide) hr45
  have heap46 : s46.heap = s.heap := hh46.trans heap145
  have slot := step_argument_last P.F NR FR R live framed before after old old' MapBody202.input s145 s46 C C h145
    MapBody202.sourceValue (.big (Int.ofNat (R.handle 29363))) MapBody202.sourceFunction MapBody202.sourceThis
    MapBody202.sourceAcc MapBody202.sourceEnv MapBody202.sourceTail MapBody202.source_control hc145
    MapBody202.source_frame hr45
  have accEmpty : MapBody202.sourceAcc.length = 0 := by host_kernel_rfl
  rw [accEmpty] at slot
  refine ⟨s46,?_,h46,slot,heap46⟩
  apply runC_cons P.F 17 s s31 s46 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr30
  apply runC_cons P.F 16 s31 s32 s46 C C C (h31.control.isHalt_eq.trans (by host_kernel_rfl)) hr31
  apply runC_cons P.F 15 s32 s33 s46 C C C (h32.control.isHalt_eq.trans (by host_kernel_rfl)) hr32
  apply runC_cons P.F 14 s33 s34 s46 C C C (h33.control.isHalt_eq.trans (by host_kernel_rfl)) hr33
  apply runC_cons P.F 13 s34 s35 s46 C C C (h34.control.isHalt_eq.trans (by host_kernel_rfl)) hr34
  apply runC_cons P.F 12 s35 s36 s46 C C C (h35.control.isHalt_eq.trans (by host_kernel_rfl)) hr35
  apply runC_cons P.F 11 s36 s37 s46 C C C (h36.control.isHalt_eq.trans (by host_kernel_rfl)) hr36
  apply runC_cons P.F 10 s37 s38 s46 C C C (h37.control.isHalt_eq.trans (by host_kernel_rfl)) hr37
  apply runC_cons P.F 9 s38 s39 s46 C C C (h38.control.isHalt_eq.trans (by host_kernel_rfl)) hr38
  apply runC_cons P.F 8 s39 s40 s46 C C C (h39.control.isHalt_eq.trans (by host_kernel_rfl)) hr39
  apply runC_cons P.F 7 s40 s41 s46 C C C (h40.control.isHalt_eq.trans (by host_kernel_rfl)) hr40
  apply runC_cons P.F 6 s41 s42 s46 C C C (h41.control.isHalt_eq.trans (by host_kernel_rfl)) hr41
  apply runC_cons P.F 5 s42 s43 s46 C C C (h42.control.isHalt_eq.trans (by host_kernel_rfl)) hr42
  apply runC_cons P.F 4 s43 s44 s46 C C C (h43.control.isHalt_eq.trans (by host_kernel_rfl)) hr43
  apply runC_cons P.F 3 s44 s45 s46 C C C (h44.control.isHalt_eq.trans (by host_kernel_rfl)) hr44
  apply runC_cons P.F 2 s45 s144 s46 C C C (h45.control.isHalt_eq.trans (by host_kernel_rfl)) hr143
  apply runC_cons P.F 1 s144 s145 s46 C C C (h144.control.isHalt_eq.trans (by host_kernel_rfl)) hr144
  apply runC_cons P.F 0 s145 s46 s46 C C C (h145.control.isHalt_eq.trans (by host_kernel_rfl)) hr45
  rfl
end Host.Load.Run.Full.Ordinary
