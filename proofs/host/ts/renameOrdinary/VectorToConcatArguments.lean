import host.ts.renameOrdinary.VectorToConcatCallbackPrefix
import host.ts.RenameIdentifierArguments
import host.mlx.NativeSymbol
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem argument_source_frame : OutputVariable328.input.stack = .c (.args 0 (.obj 4708) (.obj 4817) []
    [.expr (.id VectorVariable330.sourceName),.expr (.id AxisVariable332.sourceName),.expr (.id StreamVariable334.sourceName)]
    OutputVariable328.sourceEnv)::OutputArgument329.sourceTail := by host_kernel_rfl
theorem argument_source_lookup_vector : lookupEnv VectorVariable330.sourceName OutputVariable328.sourceEnv = some VectorVariable330.address := by host_kernel_rfl
theorem argument_source_lookup_axis : lookupEnv AxisVariable332.sourceName OutputVariable328.sourceEnv = some AxisVariable332.address := by host_kernel_rfl
theorem argument_source_lookup_stream : lookupEnv StreamVariable334.sourceName OutputVariable328.sourceEnv = some StreamVariable334.address := by host_kernel_rfl
theorem argument_source_cell_pointer : OutputVariable328.input.heap.get OutputVariable328.address = some (.cell (some (.ptr (.js 3126700) 0))) := by host_kernel_rfl
theorem argument_source_cell_vector : OutputVariable328.input.heap.get VectorVariable330.address = some (.cell (some (.big 29371))) := by host_kernel_rfl
theorem argument_source_cell_axis : OutputVariable328.input.heap.get AxisVariable332.address = some (.cell (some (.num (.lit (F64.fin false 1 0))))) := by host_kernel_rfl
theorem argument_source_cell_stream : OutputVariable328.input.heap.get StreamVariable334.address = some (.cell (some (.big 2))) := by host_kernel_rfl

/-- The real identifier reads and argument collector transfer the fixed
incoming cell roles to the native concat call. No target lookup, target
argument list or target execution is a premise. -/
theorem concat_argument_roles (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' OutputVariable328.input s)
    (vectorRole : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt s (R.a VectorVariable330.address)))
    (axisRole : (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (cellValueAt s (R.a AxisVariable332.address)))
    (streamRole : (Annotated.Value.handle 2).Holds ν C R (cellValueAt s (R.a StreamVariable334.address))) :
    ∃ result, runC P.F 8 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' StreamArgument335.output result ∧
      (Annotated.Value.handle 29371).Holds ν C R (callArgument result.ctl 1) ∧
      (Annotated.Value.literal (.lit (F64.fin false 1 0))).Holds ν C R (callArgument result.ctl 2) ∧
      (Annotated.Value.handle 2).Holds ν C R (callArgument result.ctl 3) ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  have hc := (h.control_view OutputVariable328.source_control).ev_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view argument_source_frame
  obtain ⟨fn,this,acc,hft,hfn,hthis,hacc⟩ := hfr.args_view
  cases hfn
  cases hthis
  cases hacc
  rw [hft] at hf
  have hl := h.controlLive
  rw [OutputVariable328.source_control] at hl
  have envLive : treeSupport live (Encode.env OutputVariable328.sourceEnv) := hl.2.1
  obtain ⟨v₁,hv₁,hr₁,_⟩ := h.heap.readCell OutputVariable328.address (.ptr (.js 3126700) 0)
    (env_lookup_live _ _ _ envLive OutputVariable328.source_lookup) argument_source_cell_pointer
  obtain ⟨v₂,hv₂,_,_⟩ := h.heap.readCell VectorVariable330.address (.big 29371)
    (env_lookup_live _ _ _ envLive argument_source_lookup_vector) argument_source_cell_vector
  obtain ⟨v₃,hv₃,_,_⟩ := h.heap.readCell AxisVariable332.address (.num (.lit (F64.fin false 1 0)))
    (env_lookup_live _ _ _ envLive argument_source_lookup_axis) argument_source_cell_axis
  obtain ⟨v₄,hv₄,_,_⟩ := h.heap.readCell StreamVariable334.address (.big 2)
    (env_lookup_live _ _ _ envLive argument_source_lookup_stream) argument_source_cell_stream
  cases hr₁
  have ev : v₂ = .big (Int.ofNat (R.handle 29371)) := fixed_handle_value (by simpa only [cellValueAt,hv₂] using vectorRole)
  have ea : v₃ = .num (.lit (F64.fin false 1 0)) := fixed_literal_value (by simpa only [cellValueAt,hv₃] using axisRole)
  have es : v₄ = .big (Int.ofNat (R.handle 2)) := fixed_handle_value (by simpa only [cellValueAt,hv₄] using streamRole)
  subst v₂; subst v₃; subst v₄
  have lookup (name : Name) (a : Nat) (he : lookupEnv name OutputVariable328.sourceEnv = some a) :
      lookupEnv name (R.env OutputVariable328.sourceEnv) = some (R.a a) := by rw [lookupEnv_map,he]; rfl
  have exactRun := run_identifier_arguments4 P.F s C (.obj (R.a 4708)) (.obj (R.a 4817))
    OutputVariable328.sourceName VectorVariable330.sourceName AxisVariable332.sourceName StreamVariable334.sourceName
    (R.a OutputVariable328.address) (R.a VectorVariable330.address) (R.a AxisVariable332.address) (R.a StreamVariable334.address)
    (.ptr (.js (R.a 3126700)) 0) (.big (Int.ofNat (R.handle 29371))) (.num (.lit (F64.fin false 1 0))) (.big (Int.ofNat (R.handle 2)))
    (R.env OutputVariable328.sourceEnv) fs hc hf (lookup _ _ OutputVariable328.source_lookup)
    (lookup _ _ argument_source_lookup_vector) (lookup _ _ argument_source_lookup_axis) (lookup _ _ argument_source_lookup_stream)
    hv₁ hv₂ hv₃ hv₄
  obtain ⟨v328,hr328,h329,_⟩ := OutputVariable328.transport NR FR R C₀ C live framed before after old old' s h
  let s329 := s.ret v328
  obtain ⟨s330,hr329,h330⟩ := OutputArgument329.transport NR FR R C₀ C live framed before after old old' s329 h329
  obtain ⟨v330,hr330,h331,_⟩ := VectorVariable330.transport NR FR R C₀ C live framed before after old old' s330 h330
  let s331 := s330.ret v330
  obtain ⟨s332,hr331,h332⟩ := VectorArgument331.transport NR FR R C₀ C live framed before after old old' s331 h331
  obtain ⟨v332,hr332,h333,_⟩ := AxisVariable332.transport NR FR R C₀ C live framed before after old old' s332 h332
  let s333 := s332.ret v332
  obtain ⟨s334,hr333,h334⟩ := AxisArgument333.transport NR FR R C₀ C live framed before after old old' s333 h333
  obtain ⟨v334,hr334,h335,_⟩ := StreamVariable334.transport NR FR R C₀ C live framed before after old old' s334 h334
  let s335 := s334.ret v334
  obtain ⟨result,hr335,h336⟩ := StreamArgument335.transport NR FR R C₀ C live framed before after old old' s335 h335
  have run : runC P.F 8 s C = some (result,C) := by
    apply runC_cons P.F 7 s s329 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr328
    apply runC_cons P.F 6 s329 s330 result C C C (h329.control.isHalt_eq.trans (by host_kernel_rfl)) hr329
    apply runC_cons P.F 5 s330 s331 result C C C (h330.control.isHalt_eq.trans (by host_kernel_rfl)) hr330
    apply runC_cons P.F 4 s331 s332 result C C C (h331.control.isHalt_eq.trans (by host_kernel_rfl)) hr331
    apply runC_cons P.F 3 s332 s333 result C C C (h332.control.isHalt_eq.trans (by host_kernel_rfl)) hr332
    apply runC_cons P.F 2 s333 s334 result C C C (h333.control.isHalt_eq.trans (by host_kernel_rfl)) hr333
    apply runC_cons P.F 1 s334 s335 result C C C (h334.control.isHalt_eq.trans (by host_kernel_rfl)) hr334
    apply runC_cons P.F 0 s335 result result C C C (h335.control.isHalt_eq.trans (by host_kernel_rfl)) hr335
    rfl
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans exactRun))
  dsimp only at he
  refine ⟨result,run,h336,?_,?_,?_,?_,?_,?_⟩
  · rw [he]; exact .handle _
  · rw [he]; exact .literal _ _ rfl
  · rw [he]; exact .handle _
  · rw [he]; rfl
  · rw [he]; rfl
  · rw [he]; rfl
end Host.Load.Run.Full.Ordinary.VectorToConcat
