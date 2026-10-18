import host.mlx.NativeProducerSupport

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

private theorem lift_support {α : Type} {P Q : α → Prop} (f : ∀ i, P i → Q i) :
    ∀ xs, listSupport P xs → listSupport Q xs
  | [], _ => True.intro
  | i::is, h => ⟨f i h.1,lift_support f is h.2⟩

private theorem nth_support {N : Nat → Prop} :
    ∀ xs index output, listSupport N xs → nth? xs index = some output → N output := by
  intro xs
  induction xs with
  | nil => intro index output _ found; cases index <;> cases found
  | cons x xs ih =>
    intro index output supported found
    cases index with
    | zero => cases found; exact supported.1
    | succ index => exact ih index output supported.2 found

/-- Cached replay preserves source producer closure through fresh nodes and
alias results, while retaining vectors and captured traces in the object store. -/
theorem ReplayPlan.producer_support {NR : NumV → NumV → Prop} {R : Ren} {boundary roots : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {H N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result)
    (support : ProducerSupport roots H N s)
    (values : listSupport (fun p : Nat × Nat => N p.2) m)
    (bound : s.nnext + order.length < 2^64) : ProducerSupport roots H K final := by
  induction plan with
  | done => exact support
  | leaf nd live full node leaf rest ih =>
    exact ih support values (by simp only [List.length_cons] at bound; omega)
  | unchanged nd live full node kernel same inputs keys rest ih =>
    exact ih support values (by simp only [List.length_cons] at bound; omega)
  | @kernel N K s final m result n ns nd live full node kernel inputs keys create rest ih =>
    have held := substOf_support_list m values nd.ins inputs
    have post := support.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),nd.shape,nd.dtype⟩ held (by omega)
    have lifted := lift_support (P := fun p : Nat × Nat => N p.2)
      (Q := fun p : Nat × Nat => p.2 = s.nnext ∨ N p.2) (fun _ h => Or.inr h) m values
    exact ih post ⟨Or.inl rfl,lifted⟩ (by simp only [St.addNode,List.length_cons] at bound ⊢; omega)
  | @node N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata shape dt read infer transport rest ih =>
    have post := support.addNode ⟨.replayed cls nd.prim,nd.ins.map (substOf m),shape,dt⟩ substituted (by omega)
    have lifted := lift_support (P := fun p : Nat × Nat => N p.2)
      (Q := fun p : Nat × Nat => p.2 = s.nnext ∨ N p.2) (fun _ h => Or.inr h) m values
    exact ih post ⟨Or.inl rfl,lifted⟩ (by simp only [St.addNode,List.length_cons] at bound ⊢; omega)
  | @same N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata index output read infer outputAt transport rest ih =>
    exact ih support ⟨nth_support _ index output substituted outputAt,values⟩
      (by simp only [List.length_cons] at bound; omega)

/-- An existing native output vector receives supported replay producers.
The caller supplies entry support and source reads, never a final support or
target vector/run premise. -/
theorem ProducerSupport.cached_result {NR : NumV → NumV → Prop} {R : Ren} {boundary roots : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {H N K : Nat → Prop}
    {s final : St} {result : List (Nat × Nat)} {trace : Trace} {inputs : List Nat}
    (support : ProducerSupport roots H N s)
    (plan : ReplayPlan NR R boundary cls NodeRel N s (trace.ins.zip inputs) trace.order K final result)
    (callback : Nat) (payload : Arg) (shapeless : Bool) (inv slot : Nat)
    (closureLive : H cls) (inputsLive : H inv)
    (sourceClosure : s.obj? cls = some (.clo (.compiled callback payload shapeless [trace])))
    (sourceInputs : s.obj? inv = some (.vec inputs))
    (nodesBound : s.nnext + trace.order.length < 2^64) (slotBound : slot < 2^64) :
    ProducerSupport roots H K (final.setObj slot (.vec (trace.outs.map (substOf result)))) ∧
      (∀ i, N i → K i) ∧ listSupport K (trace.outs.map (substOf result)) := by
  have values := zip_support_right trace.ins inputs (support.vector inv inputs inputsLive sourceInputs)
  have sourceTrace := support.single_trace cls callback payload shapeless trace closureLive sourceClosure
  obtain ⟨inclusion,outputs⟩ := plan.output_support values trace.outs sourceTrace.outputs
  exact ⟨(plan.producer_support support values nodesBound).setObj slot _ outputs slotBound,inclusion,outputs⟩

end Host.Mlx.Ffi.NativeRoles
