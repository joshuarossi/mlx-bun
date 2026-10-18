import host.ts.renameOrdinary.DriverMapBody
import host.ts.RenameRouteComposition
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteArgumentFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The first map callback obtains its owned handle through the actual getter,
disposed guard, getter return and callback return into the array-push argument.
The owned value is supplied only at the initial object field. -/
theorem map_getter_handle_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' MapBody128.input s)
    (field : PrivateData s (R.a MapBody138.sourceAddress) (R.a MapBody138.sourceBrand)
      MapBody138.sourceName (.big (Int.ofNat (R.handle 25732)))) :
    ∃ result, runC P.F 18 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' MapBody145.output result ∧
      callArgument result.ctl 0 = .big (Int.ofNat (R.handle 25732)) ∧ result.heap = s.heap := by
  obtain ⟨s31,hr30,h31⟩ := MapBody128.transport NR FR R C₀ C live framed before after old old' s h
  have hh31 := step_block_next_heap P.F NR FR R live framed before after old old' MapBody128.input s s31 C C h
    MapBody128.sourceValue MapBody128.sourceStatement MapBody128.sourceRest MapBody128.sourceEnv MapBody128.sourceTail
    MapBody128.source_control MapBody128.source_frame hr30
  have heap31 : s31.heap = s.heap := hh31
  obtain ⟨s32,hr31,h32⟩ := MapBody129.transport NR FR R C₀ C live framed before after old old' s31 h31
  have hh32 := step_statement_heap P.F NR FR R live framed before after old old' MapBody129.input s31 s32 C C h31 MapBody129.sourceAction MapBody129.sourceEnv MapBody129.source_control hr31
  have heap32 : s32.heap = s.heap := hh32.trans heap31
  obtain ⟨s33,hr32,h33⟩ := MapBody130.transport NR FR R C₀ C live framed before after old old' s32 h32
  have hh33 := step_private_descent_heap P.F NR FR R live framed before after old old' MapBody130.input s32 s33 C₀ C C h32
    MapBody130.sourceObject MapBody130.sourceName MapBody130.sourceOptional MapBody130.sourceEnv MapBody130.sourceBrand
    MapBody130.source_control MapBody130.source_brand hr32
  have heap33 : s33.heap = s.heap := hh33.trans heap32
  obtain ⟨s34,hr33,h34⟩ := MapBody131.transport NR FR R C₀ C live framed before after old old' s33 h33
  have hh34 := step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody131.input s33 s34 C₀ C C h33
    MapBody131.sourceEnv MapBody131.sourceAddress MapBody131.sourceValue MapBody131.source_control MapBody131.source_lookup MapBody131.source_cell hr33
  have heap34 : s34.heap = s.heap := hh34.trans heap33
  obtain ⟨s35,hr34,h35⟩ := MapBody132.transport NR FR R C₀ C live framed before after old old' s34 h34
  have hh35 := MapBody132.heap_frame NR FR R C₀ C C live framed before after old old' s34 s35 h34 hr34
  have heap35 : s35.heap = s.heap := hh35.trans heap34
  obtain ⟨s36,hr35,h36⟩ := MapBody133.transport NR FR R C₀ C live framed before after old old' s35 h35
  have hh36 := step_if_heap P.F NR FR R live framed before after old old' MapBody133.input s35 s36 C C h35
    MapBody133.sourceGuard MapBody133.sourceYes MapBody133.sourceNo MapBody133.sourceEnv MapBody133.sourceTail MapBody133.source_control MapBody133.source_frame hr35
  have heap36 : s36.heap = s.heap := hh36.trans heap35
  obtain ⟨s37,hr36,h37⟩ := MapBody134.transport NR FR R C₀ C live framed before after old old' s36 h36
  have hh37 := step_block_next_heap P.F NR FR R live framed before after old old' MapBody134.input s36 s37 C C h36
    MapBody134.sourceValue MapBody134.sourceStatement MapBody134.sourceRest MapBody134.sourceEnv MapBody134.sourceTail
    MapBody134.source_control MapBody134.source_frame hr36
  have heap37 : s37.heap = s.heap := hh37.trans heap36
  obtain ⟨s38,hr37,h38⟩ := MapBody135.transport NR FR R C₀ C live framed before after old old' s37 h37
  have hh38 := step_statement_heap P.F NR FR R live framed before after old old' MapBody135.input s37 s38 C C h37
    (.returnExpression MapBody135.sourceExpression) MapBody135.sourceEnv MapBody135.source_control hr37
  have heap38 : s38.heap = s.heap := hh38.trans heap37
  obtain ⟨s39,hr38,h39⟩ := MapBody136.transport NR FR R C₀ C live framed before after old old' s38 h38
  have hh39 := step_private_descent_heap P.F NR FR R live framed before after old old' MapBody136.input s38 s39 C₀ C C h38
    MapBody136.sourceObject MapBody136.sourceName MapBody136.sourceOptional MapBody136.sourceEnv MapBody136.sourceBrand
    MapBody136.source_control MapBody136.source_brand hr38
  have heap39 : s39.heap = s.heap := hh39.trans heap38
  obtain ⟨s40,hr39,h40⟩ := MapBody137.transport NR FR R C₀ C live framed before after old old' s39 h39
  have hh40 := step_this_heap_from_source P.F NR FR R live framed before after old old' MapBody137.input s39 s40 C₀ C C h39
    MapBody137.sourceEnv MapBody137.sourceAddress MapBody137.sourceValue MapBody137.source_control MapBody137.source_lookup MapBody137.source_cell hr39
  have heap40 : s40.heap = s.heap := hh40.trans heap39
  obtain ⟨s41,hr40,h41⟩ := MapBody138.transport NR FR R C₀ C live framed before after old old' s40 h40
  have hh41 := MapBody138.heap_frame NR FR R C₀ C C live framed before after old old' s40 s41 h40 hr40
  have heap41 : s41.heap = s.heap := hh41.trans heap40
  have fixed40 := field.heap_eq heap40
  have hc41 := (step_private_data_fields P.F NR FR R live framed before after old old' MapBody138.input s40 s41 C C h40
    MapBody138.sourceAddress MapBody138.sourceBrand MapBody138.sourceName (.big (Int.ofNat (R.handle 25732))) MapBody138.sourceTail
    MapBody138.source_control MapBody138.source_frame fixed40 hr40).1
  obtain ⟨s42,hr41,h42⟩ := MapBody139.transport NR FR R C₀ C live framed before after old old' s41 h41
  have hh42 := step_return_exit_heap P.F NR FR R live framed before after old old' MapBody139.input s41 s42 C C h41
    MapBody139.sourceValue MapBody139.sourceAction MapBody139.sourceEnv MapBody139.sourceTail MapBody139.source_control MapBody139.source_frame hr41
  have heap42 : s42.heap = s.heap := hh42.trans heap41
  have hc42 := step_return_exit_control P.F NR FR R live framed before after old old' MapBody139.input s41 s42 C C h41
    (.big (Int.ofNat (R.handle 25732))) MapBody139.sourceAction MapBody139.sourceEnv MapBody139.sourceTail MapBody139.source_frame hc41 hr41
  obtain ⟨s43,hr42,h43⟩ := MapBody140.transport NR FR R C₀ C live framed before after old old' s42 h42
  have hh43 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody140.input s42 s43 C C h42
    MapBody140.sourceValue MapBody140.sourceAction MapBody140.sourceEnv MapBody140.sourceTail MapBody140.source_control MapBody140.source_frame hr42
  have heap43 : s43.heap = s.heap := hh43.trans heap42
  have hc43 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody140.input s42 s43 C C h42
    (.big (Int.ofNat (R.handle 25732))) MapBody140.sourceAction MapBody140.sourceEnv MapBody140.sourceTail MapBody140.source_frame hc42 hr42
  obtain ⟨s44,hr43,h44⟩ := MapBody141.transport NR FR R C₀ C live framed before after old old' s43 h43
  have hh44 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody141.input s43 s44 C C h43
    MapBody141.sourceValue MapBody141.sourceAction MapBody141.sourceEnv MapBody141.sourceTail MapBody141.source_control MapBody141.source_frame hr43
  have heap44 : s44.heap = s.heap := hh44.trans heap43
  have hc44 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody141.input s43 s44 C C h43
    (.big (Int.ofNat (R.handle 25732))) MapBody141.sourceAction MapBody141.sourceEnv MapBody141.sourceTail MapBody141.source_frame hc43 hr43
  obtain ⟨s45,hr44,h45⟩ := MapBody142.transport NR FR R C₀ C live framed before after old old' s44 h44
  have hh45 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody142.input s44 s45 C C h44
    MapBody142.sourceValue MapBody142.sourceAction MapBody142.sourceEnv MapBody142.sourceTail MapBody142.source_control MapBody142.source_frame hr44
  have heap45 : s45.heap = s.heap := hh45.trans heap44
  have hc45 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody142.input s44 s45 C C h44
    (.big (Int.ofNat (R.handle 25732))) MapBody142.sourceAction MapBody142.sourceEnv MapBody142.sourceTail MapBody142.source_frame hc44 hr44
  obtain ⟨s144,hr143,h144⟩ := MapBody143.transport NR FR R C₀ C live framed before after old old' s45 h45
  have hh144 := step_return_exit_heap P.F NR FR R live framed before after old old' MapBody143.input s45 s144 C C h45
    MapBody143.sourceValue MapBody143.sourceAction MapBody143.sourceEnv MapBody143.sourceTail MapBody143.source_control MapBody143.source_frame hr143
  have heap144 : s144.heap = s.heap := hh144.trans heap45
  have hc144 := step_return_exit_control P.F NR FR R live framed before after old old' MapBody143.input s45 s144 C C h45
    (.big (Int.ofNat (R.handle 25732))) MapBody143.sourceAction MapBody143.sourceEnv MapBody143.sourceTail MapBody143.source_frame hc45 hr143
  obtain ⟨s145,hr144,h145⟩ := MapBody144.transport NR FR R C₀ C live framed before after old old' s144 h144
  have hh145 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapBody144.input s144 s145 C C h144
    MapBody144.sourceValue MapBody144.sourceAction MapBody144.sourceEnv MapBody144.sourceTail MapBody144.source_control MapBody144.source_frame hr144
  have heap145 : s145.heap = s.heap := hh145.trans heap144
  have hc145 := step_return_unwind_control P.F NR FR R live framed before after old old' MapBody144.input s144 s145 C C h144
    (.big (Int.ofNat (R.handle 25732))) MapBody144.sourceAction MapBody144.sourceEnv MapBody144.sourceTail MapBody144.source_frame hc144 hr144
  obtain ⟨s46,hr45,h46⟩ := MapBody145.transport NR FR R C₀ C live framed before after old old' s145 h145
  have hh46 := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapBody145.input s145 s46 C C h145
    MapBody145.sourceValue MapBody145.sourceKind MapBody145.sourceFunction MapBody145.sourceThis MapBody145.sourceAcc MapBody145.sourceRest
    MapBody145.sourceEnv MapBody145.sourceTail MapBody145.source_control MapBody145.source_frame (by decide) hr45
  have heap46 : s46.heap = s.heap := hh46.trans heap145
  have slot := step_argument_last P.F NR FR R live framed before after old old' MapBody145.input s145 s46 C C h145
    MapBody145.sourceValue (.big (Int.ofNat (R.handle 25732))) MapBody145.sourceFunction MapBody145.sourceThis
    MapBody145.sourceAcc MapBody145.sourceEnv MapBody145.sourceTail MapBody145.source_control hc145
    MapBody145.source_frame hr45
  have accEmpty : MapBody145.sourceAcc.length = 0 := by host_kernel_rfl
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
