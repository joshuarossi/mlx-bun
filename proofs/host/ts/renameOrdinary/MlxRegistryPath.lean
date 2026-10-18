import host.ts.renameOrdinary.MlxRegistrySteps
import host.ts.RenameRoutePrivateFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- Registration and constructor return execute their original source body.
Every heap slot is preserved, including the owned #handle established before
this block and any exact caller-cell annotation needed afterward. -/
theorem register_and_return_constructor (NR : NumV → NumV → Prop)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' RegistryStatement391.input s) :
    ∃ result, runC P.F 18 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ConstructorReturn408.output result ∧
      result.ctl = .ret (.obj (R.a 3126703)) ∧ result.heap = s.heap := by
  obtain ⟨s392,r391,h392⟩ := RegistryStatement391.transport NR FR R C₀ C live framed before after old old' s h
  have heap392 := step_block_next_heap P.F NR FR R live framed before after old old' _ _ _ C C h RegistryStatement391.sourceValue RegistryStatement391.sourceStatement RegistryStatement391.sourceRest RegistryStatement391.sourceEnv RegistryStatement391.sourceTail RegistryStatement391.source_control RegistryStatement391.source_frame r391
  obtain ⟨s393,r392,h393⟩ := RegistryExpression392.transport NR FR R C₀ C live framed before after old old' s392 h392
  have heap393 := step_statement_heap P.F NR FR R live framed before after old old' _ _ _ C C h392 RegistryExpression392.sourceAction RegistryExpression392.sourceEnv RegistryExpression392.source_control r392
  obtain ⟨s394,r393,h394⟩ := RegistryMethod393.transport NR FR R C₀ C live framed before after old old' s393 h393
  have heap394 := step_method_descent_heap P.F NR FR R live framed before after old old' _ _ _ C₀ C C h393 RegistryMethod393.sourceExpression RegistryMethod393.sourceName RegistryMethod393.sourceArgs RegistryMethod393.sourceEnv RegistryMethod393.sourceOptObject RegistryMethod393.sourceOptCall RegistryMethod393.source_control r393
  obtain ⟨v394,r394,h395,_⟩ := RegistryVariable394.transport NR FR R C₀ C live framed before after old old' s394 h394
  let s395 := s394.ret v394
  have heap395 : s395.heap = s394.heap := rfl
  obtain ⟨s396,r395,h396⟩ := RegistryMethod395.transport NR FR R C₀ C live framed before after old old' s395 h395
  have heap396 := RegistryMethod395.heap_frame NR FR R C₀ C C live framed before after old old' s395 s396 h395 r395
  obtain ⟨s397,r396,h397⟩ := RegistryArguments396.transport NR FR R C₀ C live framed before after old old' s396 h396
  have heap397 := step_callStart_heap P.F NR FR R live framed before after old old' _ _ _ C C h396 RegistryArguments396.sourceMode RegistryArguments396.sourceAddress RegistryArguments396.sourceThis RegistryArguments396.sourceArgs RegistryArguments396.sourceEnv RegistryArguments396.sourceTail RegistryArguments396.source_control RegistryArguments396.source_frame r396
  obtain ⟨s398,r397,h398⟩ := RegistryThis397.transport NR FR R C₀ C live framed before after old old' s397 h397
  have heap398 := step_this_heap_from_source P.F NR FR R live framed before after old old' _ _ _ C₀ C C h397 RegistryThis397.sourceEnv RegistryThis397.sourceAddress RegistryThis397.sourceValue RegistryThis397.source_control RegistryThis397.source_lookup RegistryThis397.source_cell r397
  obtain ⟨s399,r398,h399⟩ := RegistryArguments398.transport NR FR R C₀ C live framed before after old old' s398 h398
  have heap399 := step_argument_heap_from_source P.F NR FR R live framed before after old old' _ _ _ C C h398 RegistryArguments398.sourceValue RegistryArguments398.sourceKind RegistryArguments398.sourceFunction RegistryArguments398.sourceThis RegistryArguments398.sourceAcc RegistryArguments398.sourceRest RegistryArguments398.sourceEnv RegistryArguments398.sourceTail RegistryArguments398.source_control RegistryArguments398.source_frame (by decide) r398
  obtain ⟨v399,r399,h400,_⟩ := RegistryHandle399.transport NR FR R C₀ C live framed before after old old' s399 h399
  let s400 := s399.ret v399
  have heap400 : s400.heap = s399.heap := rfl
  obtain ⟨s401,r400,h401⟩ := RegistryArguments400.transport NR FR R C₀ C live framed before after old old' s400 h400
  have heap401 := step_argument_heap_from_source P.F NR FR R live framed before after old old' _ _ _ C C h400 RegistryArguments400.sourceValue RegistryArguments400.sourceKind RegistryArguments400.sourceFunction RegistryArguments400.sourceThis RegistryArguments400.sourceAcc RegistryArguments400.sourceRest RegistryArguments400.sourceEnv RegistryArguments400.sourceTail RegistryArguments400.source_control RegistryArguments400.source_frame (by decide) r400
  obtain ⟨s402,r401,h402⟩ := RegistryToken401.transport NR FR R C₀ C live framed before after old old' s401 h401
  have heap402 := step_private_descent_heap P.F NR FR R live framed before after old old' _ _ _ C₀ C C h401 RegistryToken401.sourceObject RegistryToken401.sourceName RegistryToken401.sourceOptional RegistryToken401.sourceEnv RegistryToken401.sourceBrand RegistryToken401.source_control RegistryToken401.source_brand r401
  obtain ⟨s403,r402,h403⟩ := RegistryThis402.transport NR FR R C₀ C live framed before after old old' s402 h402
  have heap403 := step_this_heap_from_source P.F NR FR R live framed before after old old' _ _ _ C₀ C C h402 RegistryThis402.sourceEnv RegistryThis402.sourceAddress RegistryThis402.sourceValue RegistryThis402.source_control RegistryThis402.source_lookup RegistryThis402.source_cell r402
  obtain ⟨s404,r403,h404⟩ := RegistryToken403.transport NR FR R C₀ C live framed before after old old' s403 h403
  have heap404 := RegistryToken403.heap_frame NR FR R C₀ C C live framed before after old old' s403 s404 h403 r403
  obtain ⟨s405,r404,h405⟩ := RegistryArguments404.transport NR FR R C₀ C live framed before after old old' s404 h404
  have heap405 := step_argument_heap_from_source P.F NR FR R live framed before after old old' _ _ _ C C h404 RegistryArguments404.sourceValue RegistryArguments404.sourceKind RegistryArguments404.sourceFunction RegistryArguments404.sourceThis RegistryArguments404.sourceAcc RegistryArguments404.sourceRest RegistryArguments404.sourceEnv RegistryArguments404.sourceTail RegistryArguments404.source_control RegistryArguments404.source_frame (by decide) r404
  obtain ⟨r405,h406⟩ := RegistryRegister405.transport NR FR R C₀ C live framed before after old old' s405 h405
  let s406 := s405.ret .undef
  have heap406 : s406.heap = s405.heap := rfl
  obtain ⟨s407,r406,h407⟩ := RegistryBlock406.transport NR FR R C₀ C live framed before after old old' s406 h406
  have heap407 := step_return_exit_heap P.F NR FR R live framed before after old old' _ _ _ C C h406 RegistryBlock406.sourceValue RegistryBlock406.sourceAction RegistryBlock406.sourceEnv RegistryBlock406.sourceTail RegistryBlock406.source_control RegistryBlock406.source_frame r406
  obtain ⟨s408,r407,h408⟩ := RegistryScope407.transport NR FR R C₀ C live framed before after old old' s407 h407
  have heap408 := step_return_exit_heap P.F NR FR R live framed before after old old' _ _ _ C C h407 RegistryScope407.sourceValue RegistryScope407.sourceAction RegistryScope407.sourceEnv RegistryScope407.sourceTail RegistryScope407.source_control RegistryScope407.source_frame r407
  obtain ⟨s409,r408,h409,ctl409,heap409⟩ := ConstructorReturn408.transport NR FR R C₀ C live framed before after old old' s408 h408
  refine ⟨s409,?_,h409,ctl409,?_⟩
  · apply runC_cons P.F 17 s s392 s409 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r391
    apply runC_cons P.F 16 s392 s393 s409 C C C (h392.control.isHalt_eq.trans (by host_kernel_rfl)) r392
    apply runC_cons P.F 15 s393 s394 s409 C C C (h393.control.isHalt_eq.trans (by host_kernel_rfl)) r393
    apply runC_cons P.F 14 s394 s395 s409 C C C (h394.control.isHalt_eq.trans (by host_kernel_rfl)) r394
    apply runC_cons P.F 13 s395 s396 s409 C C C (h395.control.isHalt_eq.trans (by host_kernel_rfl)) r395
    apply runC_cons P.F 12 s396 s397 s409 C C C (h396.control.isHalt_eq.trans (by host_kernel_rfl)) r396
    apply runC_cons P.F 11 s397 s398 s409 C C C (h397.control.isHalt_eq.trans (by host_kernel_rfl)) r397
    apply runC_cons P.F 10 s398 s399 s409 C C C (h398.control.isHalt_eq.trans (by host_kernel_rfl)) r398
    apply runC_cons P.F 9 s399 s400 s409 C C C (h399.control.isHalt_eq.trans (by host_kernel_rfl)) r399
    apply runC_cons P.F 8 s400 s401 s409 C C C (h400.control.isHalt_eq.trans (by host_kernel_rfl)) r400
    apply runC_cons P.F 7 s401 s402 s409 C C C (h401.control.isHalt_eq.trans (by host_kernel_rfl)) r401
    apply runC_cons P.F 6 s402 s403 s409 C C C (h402.control.isHalt_eq.trans (by host_kernel_rfl)) r402
    apply runC_cons P.F 5 s403 s404 s409 C C C (h403.control.isHalt_eq.trans (by host_kernel_rfl)) r403
    apply runC_cons P.F 4 s404 s405 s409 C C C (h404.control.isHalt_eq.trans (by host_kernel_rfl)) r404
    apply runC_cons P.F 3 s405 s406 s409 C C C (h405.control.isHalt_eq.trans (by host_kernel_rfl)) r405
    apply runC_cons P.F 2 s406 s407 s409 C C C (h406.control.isHalt_eq.trans (by host_kernel_rfl)) r406
    apply runC_cons P.F 1 s407 s408 s409 C C C (h407.control.isHalt_eq.trans (by host_kernel_rfl)) r407
    apply runC_cons P.F 0 s408 s409 s409 C C C (h408.control.isHalt_eq.trans (by host_kernel_rfl)) r408
    rfl
  · exact heap409.trans (heap408.trans (heap407.trans (heap406.trans (heap405.trans (heap404.trans (heap403.trans (heap402.trans (heap401.trans (heap400.trans (heap399.trans (heap398.trans (heap397.trans (heap396.trans (heap395.trans (heap394.trans (heap393.trans (heap392)))))))))))))))))
end Host.Load.Run.Full.Ordinary.VectorToConcat
