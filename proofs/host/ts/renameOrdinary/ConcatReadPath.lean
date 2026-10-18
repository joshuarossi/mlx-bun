import host.ts.renameOrdinary.ConcatReadCall
import host.ts.RenameRouteHeapFields
import host.ts.RenameRouteReadFields
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- All ten actual source argument-evaluation steps preserve the native-written
slot. The literal offset comes from the source AST and is retained through the
last argument continuation; the original Bun read then returns its handle. -/
theorem concat_read_handle (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' HandleBlock342.input s)
    (slot : (slotKindRole 29372).Holds ν C R (objectKindAt s (R.a 3126700))) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ReadHandle352.output result ∧
      result.ctl = .ret (.big (Int.ofNat (R.handle 29372))) ∧ result.heap = s.heap := by
  let NR := NumberRoles ν₀ ν C₀ C
  let s342 := s
  have h342 := h
  obtain ⟨s343,hr342,h343⟩ := HandleBlock342.transport NR FR R C₀ C live framed before after old old' s342 h342
  obtain ⟨s344,hr343,h344⟩ := HandleDeclaration343.transport NR FR R C₀ C live framed before after old old' s343 h343
  obtain ⟨s345,hr344,h345⟩ := ReadMethod344.transport NR FR R C₀ C live framed before after old old' s344 h344
  obtain ⟨v345,hr345,h346,_⟩ := ReadVariable345.transport NR FR R C₀ C live framed before after old old' s345 h345
  let s346 := s345.ret v345
  obtain ⟨s347,hr346,h347⟩ := ReadLookup346.transport NR FR R C₀ C live framed before after old old' s346 h346
  obtain ⟨s348,hr347,h348⟩ := ReadCallee347.transport NR FR R C₀ C live framed before after old old' s347 h347
  obtain ⟨v348,hr348,h349,_⟩ := ReadPointer348.transport NR FR R C₀ C live framed before after old old' s348 h348
  let s349 := s348.ret v348
  obtain ⟨s350,hr349,h350⟩ := ReadArgument349.transport NR FR R C₀ C live framed before after old old' s349 h349
  obtain ⟨hr350,h351,_,_⟩ := ReadOffset350.transport FR R ν₀ ν C₀ C live framed before after old old' s350 h350
  let s351 := s350.ret ReadOffset350.sourceValue
  obtain ⟨s352,hr351,h352⟩ := ReadArgument351.transport NR FR R C₀ C live framed before after old old' s351 h351
  have hh343 := step_block_next_heap P.F NR FR R live framed before after old old' HandleBlock342.input s342 s343 C C h342
    HandleBlock342.sourceValue HandleBlock342.sourceStatement HandleBlock342.sourceRest HandleBlock342.sourceEnv HandleBlock342.sourceTail
    HandleBlock342.source_control HandleBlock342.source_frame hr342
  have hh344 := step_statement_heap P.F NR FR R live framed before after old old' HandleDeclaration343.input s343 s344 C C h343
    HandleDeclaration343.sourceAction HandleDeclaration343.sourceEnv HandleDeclaration343.source_control hr343
  have hh345 := step_method_descent_heap P.F NR FR R live framed before after old old' ReadMethod344.input s344 s345 C₀ C C h344
    ReadMethod344.sourceExpression ReadMethod344.sourceName ReadMethod344.sourceArgs ReadMethod344.sourceEnv ReadMethod344.sourceOptObject ReadMethod344.sourceOptCall ReadMethod344.source_control hr344
  have hh346 : s346.heap = s345.heap := rfl
  have hh347 := step_method_data_heap P.F NR FR R live framed before after old old' ReadLookup346.input s346 s347 C C h346
    ReadLookup346.sourceAddress ReadLookup346.sourceObject ReadLookup346.sourceName ReadLookup346.sourceArgs ReadLookup346.sourceEnv
    ReadLookup346.sourceOptObject ReadLookup346.sourceOptCall ReadLookup346.sourceMethod ReadLookup346.sourceWritable ReadLookup346.sourceEnumerable ReadLookup346.sourceTail
    ReadLookup346.source_control ReadLookup346.source_frame ReadLookup346.source_heap ReadLookup346.source_kind ReadLookup346.source_property hr346
  have hh348 := step_callStart_heap P.F NR FR R live framed before after old old' ReadCallee347.input s347 s348 C C h347
    ReadCallee347.sourceMode ReadCallee347.sourceAddress ReadCallee347.sourceThis ReadCallee347.sourceArgs ReadCallee347.sourceEnv ReadCallee347.sourceTail
    ReadCallee347.source_control ReadCallee347.source_frame hr347
  have hh349 : s349.heap = s348.heap := rfl
  have hh350 := step_argument_heap_from_source P.F NR FR R live framed before after old old' ReadArgument349.input s349 s350 C C h349
    ReadArgument349.sourceValue ReadArgument349.sourceKind ReadArgument349.sourceFunction ReadArgument349.sourceThis ReadArgument349.sourceAcc
    ReadArgument349.sourceRest ReadArgument349.sourceEnv ReadArgument349.sourceTail ReadArgument349.source_control ReadArgument349.source_frame (by decide) hr349
  have hh351 : s351.heap = s350.heap := rfl
  have hh352 := step_argument_heap_from_source P.F NR FR R live framed before after old old' ReadArgument351.input s351 s352 C C h351
    ReadArgument351.sourceValue ReadArgument351.sourceKind ReadArgument351.sourceFunction ReadArgument351.sourceThis ReadArgument351.sourceAcc
    ReadArgument351.sourceRest ReadArgument351.sourceEnv ReadArgument351.sourceTail ReadArgument351.source_control ReadArgument351.source_frame (by decide) hr351
  have heap352 : s352.heap = s.heap := hh352.trans (hh351.trans (hh350.trans (hh349.trans (hh348.trans (hh347.trans (hh346.trans (hh345.trans (hh344.trans hh343))))))))
  have offset352 : (Annotated.Value.literal (.lit (F64.zero false))).Holds ν C R (callArgument s352.ctl 1) := by
    obtain ⟨f,fs,hf,hfr,_⟩ := h351.stack_view ReadArgument351.source_frame
    obtain ⟨fn,this,acc,hframe,_,_,hacc⟩ := hfr.args_view
    have sourceAcc : ReadArgument351.sourceAcc = [.ptr (.js 3126700) 0] := by host_kernel_rfl
    rw [sourceAcc] at hacc
    cases hacc with | cons hv htail =>
      cases htail
      rw [hframe] at hf
      have hr := hr351
      change interpC (step P.F s351).run C = some (s352,C) at hr
      have hc351 : s351.ctl = .ret (.num zeroN) := by host_kernel_rfl
      rw [step_argument_eq P.F s351 (.num zeroN) ReadArgument351.sourceKind fn this _ ReadArgument351.sourceRest
        (R.env ReadArgument351.sourceEnv) fs hc351 hf (by decide)] at hr
      have he := congrArg Prod.fst (Option.some.inj hr)
      dsimp only at he
      rw [← (congrArg St.ctl he)]
      exact .literal (.lit (F64.zero false)) (F64.zero false) rfl
  have slot352 : (slotKindRole 29372).Holds ν C R (objectKindAt s352 (R.a 3126700)) := by
    simpa only [objectKindAt,St.obj?,heap352] using slot
  obtain ⟨hr352,h353⟩ := ReadHandle352.transport NR FR R C₀ C ν live framed before after old old' s352 h352 offset352 slot352
  let result := s352.ret (.big (Int.ofNat (R.handle 29372)))
  have run : runC P.F 11 s C = some (result,C) := by
    apply runC_cons P.F 10 s342 s343 result C C C (h342.control.isHalt_eq.trans (by host_kernel_rfl)) hr342
    apply runC_cons P.F 9 s343 s344 result C C C (h343.control.isHalt_eq.trans (by host_kernel_rfl)) hr343
    apply runC_cons P.F 8 s344 s345 result C C C (h344.control.isHalt_eq.trans (by host_kernel_rfl)) hr344
    apply runC_cons P.F 7 s345 s346 result C C C (h345.control.isHalt_eq.trans (by host_kernel_rfl)) hr345
    apply runC_cons P.F 6 s346 s347 result C C C (h346.control.isHalt_eq.trans (by host_kernel_rfl)) hr346
    apply runC_cons P.F 5 s347 s348 result C C C (h347.control.isHalt_eq.trans (by host_kernel_rfl)) hr347
    apply runC_cons P.F 4 s348 s349 result C C C (h348.control.isHalt_eq.trans (by host_kernel_rfl)) hr348
    apply runC_cons P.F 3 s349 s350 result C C C (h349.control.isHalt_eq.trans (by host_kernel_rfl)) hr349
    apply runC_cons P.F 2 s350 s351 result C C C (h350.control.isHalt_eq.trans (by host_kernel_rfl)) hr350
    apply runC_cons P.F 1 s351 s352 result C C C (h351.control.isHalt_eq.trans (by host_kernel_rfl)) hr351
    apply runC_cons P.F 0 s352 result result C C C (h352.control.isHalt_eq.trans (by host_kernel_rfl)) hr352
    rfl
  exact ⟨result,run,h353,rfl,heap352⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
