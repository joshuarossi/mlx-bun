import host.ts.renameOrdinary.RankOriginRemaining
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteArgumentFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The real handle getter returns the owned private occurrence unchanged,
through the disposed guard and return frames, into the shape-call argument.
The owned value is supplied only at the initial object field. -/
theorem shape_handle_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.micro3275.s30 s)
    (field : PrivateData s (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
      Handle40.sourceName (.big (Int.ofNat (R.handle 29363)))) :
    ∃ result, runC P.F 16 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.micro3275.s46 result ∧
      callArgument result.ctl 0 = .big (Int.ofNat (R.handle 29363)) ∧ result.heap = s.heap := by
  obtain ⟨s31,hr30,h31⟩ := GetterBlock30.transport NR FR R C₀ C live framed before after old old' s h
  have hh31 := step_block_next_heap P.F NR FR R live framed before after old old' GetterBlock30.input s s31 C C h
    GetterBlock30.sourceValue GetterBlock30.sourceStatement GetterBlock30.sourceRest GetterBlock30.sourceEnv GetterBlock30.sourceTail
    GetterBlock30.source_control GetterBlock30.source_frame hr30
  have heap31 : s31.heap = s.heap := hh31
  obtain ⟨s32,hr31,h32⟩ := DisposedTest31.transport NR FR R C₀ C live framed before after old old' s31 h31
  have hh32 := step_statement_heap P.F NR FR R live framed before after old old' DisposedTest31.input s31 s32 C C h31 DisposedTest31.sourceAction DisposedTest31.sourceEnv DisposedTest31.source_control hr31
  have heap32 : s32.heap = s.heap := hh32.trans heap31
  obtain ⟨s33,hr32,h33⟩ := PrivateDisposed32.transport NR FR R C₀ C live framed before after old old' s32 h32
  have hh33 := step_private_descent_heap P.F NR FR R live framed before after old old' PrivateDisposed32.input s32 s33 C₀ C C h32
    PrivateDisposed32.sourceObject PrivateDisposed32.sourceName PrivateDisposed32.sourceOptional PrivateDisposed32.sourceEnv PrivateDisposed32.sourceBrand
    PrivateDisposed32.source_control PrivateDisposed32.source_brand hr32
  have heap33 : s33.heap = s.heap := hh33.trans heap32
  obtain ⟨s34,hr33,h34⟩ := This33.transport NR FR R C₀ C live framed before after old old' s33 h33
  have hh34 := step_this_heap_from_source P.F NR FR R live framed before after old old' This33.input s33 s34 C₀ C C h33
    This33.sourceEnv This33.sourceAddress This33.sourceValue This33.source_control This33.source_lookup This33.source_cell hr33
  have heap34 : s34.heap = s.heap := hh34.trans heap33
  obtain ⟨s35,hr34,h35⟩ := Disposed34.transport NR FR R C₀ C live framed before after old old' s34 h34
  have hh35 := Disposed34.heap_frame NR FR R C₀ C C live framed before after old old' s34 s35 h34 hr34
  have heap35 : s35.heap = s.heap := hh35.trans heap34
  obtain ⟨s36,hr35,h36⟩ := DisposedBranch35.transport NR FR R C₀ C live framed before after old old' s35 h35
  have hh36 := step_if_heap P.F NR FR R live framed before after old old' DisposedBranch35.input s35 s36 C C h35
    DisposedBranch35.sourceGuard DisposedBranch35.sourceYes DisposedBranch35.sourceNo DisposedBranch35.sourceEnv DisposedBranch35.sourceTail DisposedBranch35.source_control DisposedBranch35.source_frame hr35
  have heap36 : s36.heap = s.heap := hh36.trans heap35
  obtain ⟨s37,hr36,h37⟩ := GetterBlock36.transport NR FR R C₀ C live framed before after old old' s36 h36
  have hh37 := step_block_next_heap P.F NR FR R live framed before after old old' GetterBlock36.input s36 s37 C C h36
    GetterBlock36.sourceValue GetterBlock36.sourceStatement GetterBlock36.sourceRest GetterBlock36.sourceEnv GetterBlock36.sourceTail
    GetterBlock36.source_control GetterBlock36.source_frame hr36
  have heap37 : s37.heap = s.heap := hh37.trans heap36
  obtain ⟨s38,hr37,h38⟩ := HandleReturn37.transport NR FR R C₀ C live framed before after old old' s37 h37
  have hh38 := step_statement_heap P.F NR FR R live framed before after old old' HandleReturn37.input s37 s38 C C h37
    (.returnExpression HandleReturn37.sourceExpression) HandleReturn37.sourceEnv HandleReturn37.source_control hr37
  have heap38 : s38.heap = s.heap := hh38.trans heap37
  obtain ⟨s39,hr38,h39⟩ := PrivateHandle38.transport NR FR R C₀ C live framed before after old old' s38 h38
  have hh39 := step_private_descent_heap P.F NR FR R live framed before after old old' PrivateHandle38.input s38 s39 C₀ C C h38
    PrivateHandle38.sourceObject PrivateHandle38.sourceName PrivateHandle38.sourceOptional PrivateHandle38.sourceEnv PrivateHandle38.sourceBrand
    PrivateHandle38.source_control PrivateHandle38.source_brand hr38
  have heap39 : s39.heap = s.heap := hh39.trans heap38
  obtain ⟨s40,hr39,h40⟩ := This39.transport NR FR R C₀ C live framed before after old old' s39 h39
  have hh40 := step_this_heap_from_source P.F NR FR R live framed before after old old' This39.input s39 s40 C₀ C C h39
    This39.sourceEnv This39.sourceAddress This39.sourceValue This39.source_control This39.source_lookup This39.source_cell hr39
  have heap40 : s40.heap = s.heap := hh40.trans heap39
  obtain ⟨s41,hr40,h41⟩ := Handle40.transport NR FR R C₀ C live framed before after old old' s40 h40
  have hh41 := Handle40.heap_frame NR FR R C₀ C C live framed before after old old' s40 s41 h40 hr40
  have heap41 : s41.heap = s.heap := hh41.trans heap40
  have fixed40 := field.heap_eq heap40
  have hc41 := (step_private_data_fields P.F NR FR R live framed before after old old' Handle40.input s40 s41 C C h40
    Handle40.sourceAddress Handle40.sourceBrand Handle40.sourceName (.big (Int.ofNat (R.handle 29363))) Handle40.sourceTail
    Handle40.source_control Handle40.source_frame fixed40 hr40).1
  obtain ⟨s42,hr41,h42⟩ := HandleReturn41.transport NR FR R C₀ C live framed before after old old' s41 h41
  have hh42 := step_return_exit_heap P.F NR FR R live framed before after old old' HandleReturn41.input s41 s42 C C h41
    HandleReturn41.sourceValue HandleReturn41.sourceAction HandleReturn41.sourceEnv HandleReturn41.sourceTail HandleReturn41.source_control HandleReturn41.source_frame hr41
  have heap42 : s42.heap = s.heap := hh42.trans heap41
  have hc42 := step_return_exit_control P.F NR FR R live framed before after old old' HandleReturn41.input s41 s42 C C h41
    (.big (Int.ofNat (R.handle 29363))) HandleReturn41.sourceAction HandleReturn41.sourceEnv HandleReturn41.sourceTail HandleReturn41.source_frame hc41 hr41
  obtain ⟨s43,hr42,h43⟩ := HandleReturn42.transport NR FR R C₀ C live framed before after old old' s42 h42
  have hh43 := step_return_unwind_heap P.F NR FR R live framed before after old old' HandleReturn42.input s42 s43 C C h42
    HandleReturn42.sourceValue HandleReturn42.sourceAction HandleReturn42.sourceEnv HandleReturn42.sourceTail HandleReturn42.source_control HandleReturn42.source_frame hr42
  have heap43 : s43.heap = s.heap := hh43.trans heap42
  have hc43 := step_return_unwind_control P.F NR FR R live framed before after old old' HandleReturn42.input s42 s43 C C h42
    (.big (Int.ofNat (R.handle 29363))) HandleReturn42.sourceAction HandleReturn42.sourceEnv HandleReturn42.sourceTail HandleReturn42.source_frame hc42 hr42
  obtain ⟨s44,hr43,h44⟩ := HandleReturn43.transport NR FR R C₀ C live framed before after old old' s43 h43
  have hh44 := step_return_unwind_heap P.F NR FR R live framed before after old old' HandleReturn43.input s43 s44 C C h43
    HandleReturn43.sourceValue HandleReturn43.sourceAction HandleReturn43.sourceEnv HandleReturn43.sourceTail HandleReturn43.source_control HandleReturn43.source_frame hr43
  have heap44 : s44.heap = s.heap := hh44.trans heap43
  have hc44 := step_return_unwind_control P.F NR FR R live framed before after old old' HandleReturn43.input s43 s44 C C h43
    (.big (Int.ofNat (R.handle 29363))) HandleReturn43.sourceAction HandleReturn43.sourceEnv HandleReturn43.sourceTail HandleReturn43.source_frame hc43 hr43
  obtain ⟨s45,hr44,h45⟩ := HandleReturn44.transport NR FR R C₀ C live framed before after old old' s44 h44
  have hh45 := step_return_unwind_heap P.F NR FR R live framed before after old old' HandleReturn44.input s44 s45 C C h44
    HandleReturn44.sourceValue HandleReturn44.sourceAction HandleReturn44.sourceEnv HandleReturn44.sourceTail HandleReturn44.source_control HandleReturn44.source_frame hr44
  have heap45 : s45.heap = s.heap := hh45.trans heap44
  have hc45 := step_return_unwind_control P.F NR FR R live framed before after old old' HandleReturn44.input s44 s45 C C h44
    (.big (Int.ofNat (R.handle 29363))) HandleReturn44.sourceAction HandleReturn44.sourceEnv HandleReturn44.sourceTail HandleReturn44.source_frame hc44 hr44
  obtain ⟨s46,hr45,h46⟩ := ShapeArgument45.transport NR FR R C₀ C live framed before after old old' s45 h45
  have hh46 := step_argument_heap_from_source P.F NR FR R live framed before after old old' ShapeArgument45.input s45 s46 C C h45
    ShapeArgument45.sourceValue ShapeArgument45.sourceKind ShapeArgument45.sourceFunction ShapeArgument45.sourceThis ShapeArgument45.sourceAcc ShapeArgument45.sourceRest
    ShapeArgument45.sourceEnv ShapeArgument45.sourceTail ShapeArgument45.source_control ShapeArgument45.source_frame (by decide) hr45
  have heap46 : s46.heap = s.heap := hh46.trans heap45
  have slot := step_argument_last P.F NR FR R live framed before after old old' ShapeArgument45.input s45 s46 C C h45
    ShapeArgument45.sourceValue (.big (Int.ofNat (R.handle 29363))) ShapeArgument45.sourceFunction ShapeArgument45.sourceThis
    ShapeArgument45.sourceAcc ShapeArgument45.sourceEnv ShapeArgument45.sourceTail ShapeArgument45.source_control hc45
    ShapeArgument45.source_frame hr45
  have accEmpty : ShapeArgument45.sourceAcc.length = 0 := by host_kernel_rfl
  rw [accEmpty] at slot
  refine ⟨s46,?_,h46,slot,heap46⟩
  apply runC_cons P.F 15 s s31 s46 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr30
  apply runC_cons P.F 14 s31 s32 s46 C C C (h31.control.isHalt_eq.trans (by host_kernel_rfl)) hr31
  apply runC_cons P.F 13 s32 s33 s46 C C C (h32.control.isHalt_eq.trans (by host_kernel_rfl)) hr32
  apply runC_cons P.F 12 s33 s34 s46 C C C (h33.control.isHalt_eq.trans (by host_kernel_rfl)) hr33
  apply runC_cons P.F 11 s34 s35 s46 C C C (h34.control.isHalt_eq.trans (by host_kernel_rfl)) hr34
  apply runC_cons P.F 10 s35 s36 s46 C C C (h35.control.isHalt_eq.trans (by host_kernel_rfl)) hr35
  apply runC_cons P.F 9 s36 s37 s46 C C C (h36.control.isHalt_eq.trans (by host_kernel_rfl)) hr36
  apply runC_cons P.F 8 s37 s38 s46 C C C (h37.control.isHalt_eq.trans (by host_kernel_rfl)) hr37
  apply runC_cons P.F 7 s38 s39 s46 C C C (h38.control.isHalt_eq.trans (by host_kernel_rfl)) hr38
  apply runC_cons P.F 6 s39 s40 s46 C C C (h39.control.isHalt_eq.trans (by host_kernel_rfl)) hr39
  apply runC_cons P.F 5 s40 s41 s46 C C C (h40.control.isHalt_eq.trans (by host_kernel_rfl)) hr40
  apply runC_cons P.F 4 s41 s42 s46 C C C (h41.control.isHalt_eq.trans (by host_kernel_rfl)) hr41
  apply runC_cons P.F 3 s42 s43 s46 C C C (h42.control.isHalt_eq.trans (by host_kernel_rfl)) hr42
  apply runC_cons P.F 2 s43 s44 s46 C C C (h43.control.isHalt_eq.trans (by host_kernel_rfl)) hr43
  apply runC_cons P.F 1 s44 s45 s46 C C C (h44.control.isHalt_eq.trans (by host_kernel_rfl)) hr44
  apply runC_cons P.F 0 s45 s46 s46 C C C (h45.control.isHalt_eq.trans (by host_kernel_rfl)) hr45
  rfl
end Host.Load.Run.Full.Ordinary.RankOrigin
