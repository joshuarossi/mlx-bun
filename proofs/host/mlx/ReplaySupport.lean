import host.mlx.ReplayPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

private theorem lift_support {α : Type} {P Q : α → Prop} (f : ∀ i, P i → Q i) :
    ∀ xs, listSupport P xs → listSupport Q xs
  | [], _ => True.intro
  | i::is, h => ⟨f i h.1,lift_support f is h.2⟩

private theorem find_support {α : Type} {P : α → Prop} (f : α → Bool) :
    ∀ xs, listSupport P xs → ∀ x, xs.find? f = some x → P x := by
  intro xs
  induction xs with
  | nil => intro _ x found; cases found
  | cons a xs ih =>
    intro supported x found
    cases hf : f a with
    | false =>
      simp only [List.find?_cons,hf] at found
      exact ih supported.2 x found
    | true =>
      simp only [List.find?_cons,hf] at found
      cases found; exact supported.1

theorem substOf_support {N : Nat → Prop} (m : List (Nat × Nat))
    (values : listSupport (fun p : Nat × Nat => N p.2) m) (n : Nat) (held : N n) :
    N (substOf m n) := by
  unfold substOf
  cases found : m.find? (fun p => Nat.beq p.1 n) with
  | none => simpa only [Option.map_none,Option.getD_none] using held
  | some p =>
    simpa only [Option.map_some,Option.getD_some] using find_support (fun p : Nat × Nat => Nat.beq p.1 n) m values p found

theorem substOf_support_list {N : Nat → Prop} (m : List (Nat × Nat))
    (values : listSupport (fun p : Nat × Nat => N p.2) m) :
    ∀ xs, listSupport N xs → listSupport N (xs.map (substOf m))
  | [], _ => True.intro
  | n::ns, h => ⟨substOf_support m values n h.1,substOf_support_list m values ns h.2⟩

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

theorem zip_support_right {N : Nat → Prop} (left : List Nat) :
    ∀ right, listSupport N right → listSupport (fun p : Nat × Nat => N p.2) (left.zip right) := by
  induction left with
  | nil => intro right _; exact True.intro
  | cons a left ih =>
    intro right supported
    cases right with
    | nil => exact True.intro
    | cons b right => exact ⟨supported.1,ih right supported.2⟩

/-- Original replay only grows selected graph support. Each newly substituted
producer is either a fresh node or an already supported alias input. -/
theorem ReplayPlan.support {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result)
    (values : listSupport (fun p : Nat × Nat => N p.2) m) :
    (∀ i, N i → K i) ∧ listSupport (fun p : Nat × Nat => K p.2) result := by
  induction plan with
  | done => exact ⟨fun _ h => h,values⟩
  | leaf nd live full node leaf rest ih => exact ih values
  | unchanged nd live full node kernel same inputs keys rest ih => exact ih values
  | @kernel N K s final m result n ns nd live full node kernel inputs keys create rest ih =>
    have lifted := lift_support (P := fun p : Nat × Nat => N p.2)
      (Q := fun p : Nat × Nat => p.2 = s.nnext ∨ N p.2) (fun _ h => Or.inr h) m values
    obtain ⟨inclusion,resultSupport⟩ := ih ⟨Or.inl rfl,lifted⟩
    exact ⟨fun i hi => inclusion i (Or.inr hi),resultSupport⟩
  | @node N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata shape dt read infer transport rest ih =>
    have lifted := lift_support (P := fun p : Nat × Nat => N p.2)
      (Q := fun p : Nat × Nat => p.2 = s.nnext ∨ N p.2) (fun _ h => Or.inr h) m values
    obtain ⟨inclusion,resultSupport⟩ := ih ⟨Or.inl rfl,lifted⟩
    exact ⟨fun i hi => inclusion i (Or.inr hi),resultSupport⟩
  | @same N K s final m result n ns nd live full node leaf kernel changed inputs substituted keys metadata index output read infer outputAt transport rest ih =>
    exact ih ⟨nth_support _ index output substituted outputAt,values⟩

theorem ReplayPlan.output_support {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {NodeRel : Nat → Node → Node → Prop} {cls : Nat} {N K : Nat → Prop}
    {s final : St} {m result : List (Nat × Nat)} {order : List Nat}
    (plan : ReplayPlan NR R boundary cls NodeRel N s m order K final result)
    (values : listSupport (fun p : Nat × Nat => N p.2) m)
    (outputs : List Nat) (held : listSupport N outputs) :
    (∀ i, N i → K i) ∧ listSupport K (outputs.map (substOf result)) := by
  obtain ⟨inclusion,resultSupport⟩ := plan.support values
  exact ⟨inclusion,substOf_support_list result resultSupport outputs (lift_support inclusion outputs held)⟩

end Host.Mlx.Ffi.NativeRoles
