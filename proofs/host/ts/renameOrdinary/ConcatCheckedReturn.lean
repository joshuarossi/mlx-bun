import host.ts.renameOrdinary.ConcatStatusTest
import host.ts.renameOrdinary.ConcatStatusPrefix
import host.ts.RenameRouteCellFields
import host.ts.RenameRouteReadFields
import host.ts.RenameRouteFields
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem status_cell_address : StatusVariable359.address = StatusBinding340.sourceAddress := by host_kernel_rfl
theorem handle_cell_address : HandleVariable366.address = HandleBinding354.sourceAddress := by host_kernel_rfl
theorem status_lookup_at_handle_bind : lookupEnv StatusVariable359.sourceName HandleBinding354.sourceEnv = some StatusVariable359.address := by host_kernel_rfl
theorem status_not_handle_cell : StatusVariable359.address ≠ HandleBinding354.sourceAddress := by decide +kernel

/-- The real outArray caller stores the produced handle, reads its previously
derived literal status, proves the error guard false, and returns the owned
handle through its lexical/function frames in 18 original machine steps. -/
theorem concat_checked_return_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' HandleValue353.input s)
    (handle : s.ctl = .ret (.big (Int.ofNat (R.handle 29372))))
    (status : s.heap.get (R.a StatusBinding340.sourceAddress) = some (.cell (some (.num zeroN))))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 18 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' HandleCallUnwind370.output result ∧
      result.ctl = .ret (.big (Int.ofNat (R.handle 29372))) ∧
      (∀ a, live a → a ≠ HandleBinding354.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let s353 := s
  have h353 := h
  obtain ⟨s354,hr353,h354⟩ := HandleValue353.transport NR FR R C₀ C live framed before after old old' s353 h353
  have hc354 : s354.ctl = .bind (.id HandleBinding354.sourceName) (.big (Int.ofNat (R.handle 29372)))
      (R.env HandleBinding354.sourceEnv) .init HandleBinding354.sourceKind :=
    step_declaration_control P.F NR FR R live framed before after old old' HandleValue353.input s353 s354 C C h353
      (.big (Int.ofNat (R.handle 29372))) HandleValue353.sourceKind HandleValue353.sourcePattern HandleValue353.sourceRest
      HandleValue353.sourceEnv HandleValue353.sourceTail HandleValue353.source_frame handle (by decide) hr353
  have hh354 := step_declaration_value_heap P.F NR FR R live framed before after old old' HandleValue353.input s353 s354 C C h353
    HandleValue353.sourceValue HandleValue353.sourceKind HandleValue353.sourcePattern HandleValue353.sourceRest HandleValue353.sourceEnv HandleValue353.sourceTail
    HandleValue353.source_control HandleValue353.source_frame (by decide) hr353
  have bound354 : s354.next ≤ 2^64 := (h.target_next_eq h354 (by host_kernel_rfl)).symm ▸ bound
  obtain ⟨s355,hr354,h355⟩ := HandleBinding354.transport NR FR R C₀ C live framed before after old old' s354 h354 bound354
  have handle355 := step_bind_init_cell_fields P.F NR FR R live framed before after old old' HandleBinding354.input s354 s355 C C h354
    HandleBinding354.sourceName HandleBinding354.sourceValue (.big (Int.ofNat (R.handle 29372))) HandleBinding354.sourceEnv HandleBinding354.sourceKind
    HandleBinding354.sourceAddress HandleBinding354.source_control hc354 HandleBinding354.source_lookup bound354 hr354
  have status355 : s355.heap.get (R.a StatusVariable359.address) = some (.cell (some (.num zeroN))) := by
    have hl := h354.controlLive
    change treeSupport live (Encode.ctl HandleBinding354.input.ctl) at hl
    rw [HandleBinding354.source_control] at hl
    have statusLive := env_lookup_live _ _ _ hl.2.2.1 status_lookup_at_handle_bind
    have handleLive := env_lookup_live _ _ _ hl.2.2.1 HandleBinding354.source_lookup
    have ne : R.a StatusVariable359.address ≠ R.a HandleBinding354.sourceAddress := fun he =>
      status_not_handle_cell (h354.heap.inj _ _ statusLive handleLive he)
    have hh := step_bind_init_heap_other P.F NR FR R live framed before after old old' HandleBinding354.input s354 s355 C C h354
      HandleBinding354.sourceName HandleBinding354.sourceValue HandleBinding354.sourceEnv HandleBinding354.sourceKind HandleBinding354.sourceAddress
      HandleBinding354.source_control HandleBinding354.source_lookup bound354 hr354 _ ne
    rw [hh,hh354,status_cell_address]
    exact status
  obtain ⟨s356,hr355,h356⟩ := HandleDone355.transport NR FR R C₀ C live framed before after old old' s355 h355
  obtain ⟨s357,hr356,h357⟩ := StatusBlock356.transport NR FR R C₀ C live framed before after old old' s356 h356
  obtain ⟨s358,hr357,h358⟩ := StatusIf357.transport NR FR R C₀ C live framed before after old old' s357 h357
  obtain ⟨s359,hr358,h359⟩ := StatusTest358.transport NR FR R C₀ C live framed before after old old' s358 h358
  have hh356 := step_declaration_next_heap P.F NR FR R live framed before after old old' HandleDone355.input s355 s356 C C h355
    HandleDone355.sourceValue HandleDone355.sourceKind HandleDone355.sourceRest HandleDone355.sourceEnv HandleDone355.sourceTail HandleDone355.source_control HandleDone355.source_frame hr355
  have hh357 := step_block_next_heap P.F NR FR R live framed before after old old' StatusBlock356.input s356 s357 C C h356
    StatusBlock356.sourceValue StatusBlock356.sourceStatement StatusBlock356.sourceRest StatusBlock356.sourceEnv StatusBlock356.sourceTail StatusBlock356.source_control StatusBlock356.source_frame hr356
  have hh358 := step_statement_heap P.F NR FR R live framed before after old old' StatusIf357.input s357 s358 C C h357
    StatusIf357.sourceAction StatusIf357.sourceEnv StatusIf357.source_control hr357
  have hh359 := step_descent_heap_from_source P.F NR FR R live framed before after old old' StatusTest358.input s358 s359 C C h358
    StatusTest358.descent StatusTest358.sourceEnv StatusTest358.source_control hr358
  have heap359 : s359.heap = s355.heap := hh359.trans (hh358.trans (hh357.trans hh356))
  obtain ⟨v359,hr359,h360,_⟩ := StatusVariable359.transport NR FR R C₀ C live framed before after old old' s359 h359
  let s360 := s359.ret v359
  have status359 : s359.heap.get (R.a StatusVariable359.address) = some (.cell (some (.num zeroN))) := heap359 ▸ status355
  obtain ⟨hc360,_⟩ := step_variable_cell_fields P.F NR FR R live framed before after old old' StatusVariable359.input s359 s360 C C h359
    StatusVariable359.sourceName StatusVariable359.sourceEnv StatusVariable359.address (.num zeroN)
    StatusVariable359.source_control StatusVariable359.source_lookup status359 hr359
  obtain ⟨s361,hr360,h361⟩ := StatusLeft360.transport NR FR R C₀ C live framed before after old old' s360 h360
  obtain ⟨fs,hf361,_,hh361⟩ := step_binary_left_saved_fields P.F NR FR R live framed before after old old' StatusLeft360.input s360 s361 C C h360
    (.num zeroN) StatusLeft360.sourceOp StatusLeft360.sourceRight StatusLeft360.sourceEnv StatusLeft360.sourceTail StatusLeft360.source_frame hc360 hr360
  obtain ⟨hr361,h362,_,_⟩ := StatusZero361.transport FR R ν₀ ν C₀ C live framed before after old old' s361 h361
  let s362 := s361.ret StatusZero361.sourceValue
  have hc362 : s362.ctl = .ret (.num zeroN) := by host_kernel_rfl
  have hf362 : s362.stack = .e (.binR .sne (.num zeroN))::fs := hf361
  obtain ⟨hr362,h363⟩ := StatusComparison362.transport ν₀ ν C₀ C FR R live framed before after old old' s362 h362 fs hc362 hf362
  let s363 := {s362 with stack := fs}.ret (.bool false)
  obtain ⟨s364,hr363,h364⟩ := StatusBranch363.transport NR FR R C₀ C live framed before after old old' s363 h363
  obtain ⟨s365,hr364,h365⟩ := HandleReturnBlock364.transport NR FR R C₀ C live framed before after old old' s364 h364
  obtain ⟨s366,hr365,h366⟩ := HandleReturn365.transport NR FR R C₀ C live framed before after old old' s365 h365
  have hh364 := step_if_heap P.F NR FR R live framed before after old old' StatusBranch363.input s363 s364 C C h363
    StatusBranch363.sourceGuard StatusBranch363.sourceYes StatusBranch363.sourceNo StatusBranch363.sourceEnv StatusBranch363.sourceTail StatusBranch363.source_control StatusBranch363.source_frame hr363
  have hh365 := step_block_next_heap P.F NR FR R live framed before after old old' HandleReturnBlock364.input s364 s365 C C h364
    HandleReturnBlock364.sourceValue HandleReturnBlock364.sourceStatement HandleReturnBlock364.sourceRest HandleReturnBlock364.sourceEnv HandleReturnBlock364.sourceTail
    HandleReturnBlock364.source_control HandleReturnBlock364.source_frame hr364
  have hh366 := step_statement_heap P.F NR FR R live framed before after old old' HandleReturn365.input s365 s366 C C h365
    HandleReturn365.sourceAction HandleReturn365.sourceEnv HandleReturn365.source_control hr365
  have heap366 : s366.heap = s355.heap := hh366.trans (hh365.trans (hh364.trans (hh361.trans heap359)))
  have handle366 : s366.heap.get (R.a HandleVariable366.address) = some (.cell (some (.big (Int.ofNat (R.handle 29372))))) := by
    rw [heap366,handle_cell_address]
    exact handle355
  obtain ⟨v366,hr366,h367,_⟩ := HandleVariable366.transport NR FR R C₀ C live framed before after old old' s366 h366
  let s367 := s366.ret v366
  obtain ⟨hc367,_⟩ := step_variable_cell_fields P.F NR FR R live framed before after old old' HandleVariable366.input s366 s367 C C h366
    HandleVariable366.sourceName HandleVariable366.sourceEnv HandleVariable366.address (.big (Int.ofNat (R.handle 29372)))
    HandleVariable366.source_control HandleVariable366.source_lookup handle366 hr366
  obtain ⟨s368,hr367,h368⟩ := HandleReturn367.transport NR FR R C₀ C live framed before after old old' s367 h367
  have hc368 : s368.ctl = .abr (.ret (.big (Int.ofNat (R.handle 29372)))) :=
    step_return_exit_control P.F NR FR R live framed before after old old' HandleReturn367.input s367 s368 C C h367
      (.big (Int.ofNat (R.handle 29372))) HandleReturn367.sourceAction HandleReturn367.sourceEnv HandleReturn367.sourceTail HandleReturn367.source_frame hc367 hr367
  obtain ⟨s369,hr368,h369⟩ := HandleBlockUnwind368.transport NR FR R C₀ C live framed before after old old' s368 h368
  have hc369 : s369.ctl = .abr (.ret (.big (Int.ofNat (R.handle 29372)))) :=
    step_return_unwind_control P.F NR FR R live framed before after old old' HandleBlockUnwind368.input s368 s369 C C h368
      (.big (Int.ofNat (R.handle 29372))) HandleBlockUnwind368.sourceAction HandleBlockUnwind368.sourceEnv HandleBlockUnwind368.sourceTail HandleBlockUnwind368.source_frame hc368 hr368
  obtain ⟨s370,hr369,h370⟩ := HandleScopeUnwind369.transport NR FR R C₀ C live framed before after old old' s369 h369
  have hc370 : s370.ctl = .abr (.ret (.big (Int.ofNat (R.handle 29372)))) :=
    step_return_unwind_control P.F NR FR R live framed before after old old' HandleScopeUnwind369.input s369 s370 C C h369
      (.big (Int.ofNat (R.handle 29372))) HandleScopeUnwind369.sourceAction HandleScopeUnwind369.sourceEnv HandleScopeUnwind369.sourceTail HandleScopeUnwind369.source_frame hc369 hr369
  obtain ⟨s371,hr370,h371⟩ := HandleCallUnwind370.transport NR FR R C₀ C live framed before after old old' s370 h370
  have hc371 : s371.ctl = .ret (.big (Int.ofNat (R.handle 29372))) :=
    step_return_unwind_control P.F NR FR R live framed before after old old' HandleCallUnwind370.input s370 s371 C C h370
      (.big (Int.ofNat (R.handle 29372))) HandleCallUnwind370.sourceAction HandleCallUnwind370.sourceEnv HandleCallUnwind370.sourceTail HandleCallUnwind370.source_frame hc370 hr370
  have run : runC P.F 18 s C = some (s371,C) := by
    apply runC_cons P.F 17 s353 s354 s371 C C C (h353.control.isHalt_eq.trans (by host_kernel_rfl)) hr353
    apply runC_cons P.F 16 s354 s355 s371 C C C (h354.control.isHalt_eq.trans (by host_kernel_rfl)) hr354
    apply runC_cons P.F 15 s355 s356 s371 C C C (h355.control.isHalt_eq.trans (by host_kernel_rfl)) hr355
    apply runC_cons P.F 14 s356 s357 s371 C C C (h356.control.isHalt_eq.trans (by host_kernel_rfl)) hr356
    apply runC_cons P.F 13 s357 s358 s371 C C C (h357.control.isHalt_eq.trans (by host_kernel_rfl)) hr357
    apply runC_cons P.F 12 s358 s359 s371 C C C (h358.control.isHalt_eq.trans (by host_kernel_rfl)) hr358
    apply runC_cons P.F 11 s359 s360 s371 C C C (h359.control.isHalt_eq.trans (by host_kernel_rfl)) hr359
    apply runC_cons P.F 10 s360 s361 s371 C C C (h360.control.isHalt_eq.trans (by host_kernel_rfl)) hr360
    apply runC_cons P.F 9 s361 s362 s371 C C C (h361.control.isHalt_eq.trans (by host_kernel_rfl)) hr361
    apply runC_cons P.F 8 s362 s363 s371 C C C (h362.control.isHalt_eq.trans (by host_kernel_rfl)) hr362
    apply runC_cons P.F 7 s363 s364 s371 C C C (h363.control.isHalt_eq.trans (by host_kernel_rfl)) hr363
    apply runC_cons P.F 6 s364 s365 s371 C C C (h364.control.isHalt_eq.trans (by host_kernel_rfl)) hr364
    apply runC_cons P.F 5 s365 s366 s371 C C C (h365.control.isHalt_eq.trans (by host_kernel_rfl)) hr365
    apply runC_cons P.F 4 s366 s367 s371 C C C (h366.control.isHalt_eq.trans (by host_kernel_rfl)) hr366
    apply runC_cons P.F 3 s367 s368 s371 C C C (h367.control.isHalt_eq.trans (by host_kernel_rfl)) hr367
    apply runC_cons P.F 2 s368 s369 s371 C C C (h368.control.isHalt_eq.trans (by host_kernel_rfl)) hr368
    apply runC_cons P.F 1 s369 s370 s371 C C C (h369.control.isHalt_eq.trans (by host_kernel_rfl)) hr369
    apply runC_cons P.F 0 s370 s371 s371 C C C (h370.control.isHalt_eq.trans (by host_kernel_rfl)) hr370
    rfl
  have hh368 := step_return_exit_heap P.F NR FR R live framed before after old old' _ _ _ C C h367
    HandleReturn367.sourceValue HandleReturn367.sourceAction HandleReturn367.sourceEnv HandleReturn367.sourceTail
    HandleReturn367.source_control HandleReturn367.source_frame hr367
  have hh369 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h368
    HandleBlockUnwind368.sourceValue HandleBlockUnwind368.sourceAction HandleBlockUnwind368.sourceEnv HandleBlockUnwind368.sourceTail
    HandleBlockUnwind368.source_control HandleBlockUnwind368.source_frame hr368
  have hh370 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h369
    HandleScopeUnwind369.sourceValue HandleScopeUnwind369.sourceAction HandleScopeUnwind369.sourceEnv HandleScopeUnwind369.sourceTail
    HandleScopeUnwind369.source_control HandleScopeUnwind369.source_frame hr369
  have hh371 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h370
    HandleCallUnwind370.sourceValue HandleCallUnwind370.sourceAction HandleCallUnwind370.sourceEnv HandleCallUnwind370.sourceTail
    HandleCallUnwind370.source_control HandleCallUnwind370.source_frame hr370
  have heap371 : s371.heap = s355.heap := hh371.trans (hh370.trans (hh369.trans (hh368.trans heap366)))
  have frame (a : Nat) (ha : live a) (other : a ≠ HandleBinding354.sourceAddress) :
      s371.heap.get (R.a a) = s.heap.get (R.a a) := by
    have hl := h354.controlLive
    change treeSupport live (Encode.ctl HandleBinding354.input.ctl) at hl
    rw [HandleBinding354.source_control] at hl
    have handleLive := env_lookup_live _ _ _ hl.2.2.1 HandleBinding354.source_lookup
    have otherMapped : R.a a ≠ R.a HandleBinding354.sourceAddress := fun he => other (h354.heap.inj _ _ ha handleLive he)
    have storeFrame := step_bind_init_heap_other P.F NR FR R live framed before after old old' _ _ _ C C h354
      HandleBinding354.sourceName HandleBinding354.sourceValue HandleBinding354.sourceEnv HandleBinding354.sourceKind
      HandleBinding354.sourceAddress HandleBinding354.source_control HandleBinding354.source_lookup bound354 hr354 (R.a a) otherMapped
    exact (congrArg (fun hp => hp.get (R.a a)) heap371).trans (storeFrame.trans (congrArg (fun hp => hp.get (R.a a)) hh354))
  exact ⟨s371,run,h371,hc371,frame⟩

theorem concat_checked_return (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' HandleValue353.input s)
    (handle : s.ctl = .ret (.big (Int.ofNat (R.handle 29372))))
    (status : s.heap.get (R.a StatusBinding340.sourceAddress) = some (.cell (some (.num zeroN))))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 18 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' HandleCallUnwind370.output result ∧
      result.ctl = .ret (.big (Int.ofNat (R.handle 29372))) := by
  obtain ⟨result,run,related,handle,_⟩ := concat_checked_return_framed ν₀ ν C₀ C FR R live framed before after old old'
    s h handle status bound
  exact ⟨result,run,related,handle⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
