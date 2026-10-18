import host.ts.RenameClosureStackEffects
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- The receiver/home prefix of the original `enterClosure`, before its
ordered parameter-cell allocation. -/
def closureStart {S : Type} (s : St S) (env : Env) (arrow : Bool) (home this : Val) : Env × St S :=
  bif arrow then (env,s) else
    let (cell,t) := s.alloc (.cell (some this))
    let e := (nThis,cell)::env
    match home with
    | .undef => (e,t)
    | v => let (cell2,u) := t.alloc (.cell (some v)); ((nHome,cell2)::e,u)
def closureEnvironment {S : Type} (s : St S) (f : Func) (env : Env) (arrow : Bool) (home this : Val) : Env :=
  let start := closureStart s env arrow home this
  (allocCells start.2 (paramNames f) start.1).1
def closureState {S : Type} (s : St S) (f : Func) (env : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (boundary : Boundary) : St S :=
  let start := closureStart s env arrow home this
  parameterContinuation (allocCells start.2 (paramNames f) start.1).2 f boundary args
    (closureEnvironment s f env arrow home this)

theorem enterClosure_state (F : Ffi) (s : St F.S) (f : Func) (env : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (boundary : Boundary) :
    enterClosure F s f env arrow home this args boundary =
      M.pure (closureState s f env arrow home this args boundary) := by
  cases arrow <;> cases home <;> rfl
theorem closureStart_stack {S : Type} (s : St S) (env : Env) (arrow : Bool) (home this : Val) :
    (closureStart s env arrow home this).2.stack = s.stack := by cases arrow <;> cases home <;> rfl
theorem closureState_stack {S : Type} (s : St S) (f : Func) (env : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (boundary : Boundary) :
    (closureState s f env arrow home this args boundary).stack =
      .k (.params f (fnParams f) args (closureEnvironment s f env arrow home this))::
        .k (.fn boundary)::s.stack := by
  simp only [closureState,parameterContinuation,St.push,St.ret,allocCells_stack,closureStart_stack]
theorem closureState_control {S : Type} (s : St S) (f : Func) (env : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (boundary : Boundary) :
    (closureState s f env arrow home this args boundary).ctl = .ret .undef := rfl
theorem closureState_heap_below (F : Ffi) (s : St F.S) (f : Func) (env : Env) (arrow : Bool) (home this : Val)
    (args : List Val) (boundary : Boundary) (bound : s.next+2+(paramNames f).length ≤ 2^64) :
    ∀ a, a < s.next → (closureState s f env arrow home this args boundary).heap.get a = s.heap.get a := by
  apply enterClosure_heap_below F s _ (⟨[]⟩ : CSrv) (⟨[]⟩ : CSrv)
    f env arrow home this args boundary bound
  rw [enterClosure_state]
  rfl

theorem closureStart_home {S : Type} (s : St S) (env : Env) (home this : Val) (nonempty : home ≠ .undef) :
    closureStart s env false home this =
      ((nHome,s.next+1)::(nThis,s.next)::env,
        ((s.alloc (.cell (some this))).2.alloc (.cell (some home))).2) := by
  cases home <;> first | exact False.elim (nonempty rfl) | rfl

/-- Parameter allocation preserves the receiver cell created by this exact
entry, even when a separate home cell is allocated before the parameters. -/
theorem closureState_receiver (F : Ffi) (s : St F.S) (f : Func) (env : Env) (home this : Val)
    (args : List Val) (boundary : Boundary) (bound : s.next+2+(paramNames f).length ≤ 2^64) :
    (closureState s f env false home this args boundary).heap.get s.next = some (.cell (some this)) := by
  have firstBound : s.next < 2^64 := by omega
  let receiver := (s.alloc (.cell (some this))).2
  have receiverNext : receiver.next = s.next+1 := rfl
  have receiverCell : receiver.heap.get s.next = some (.cell (some this)) := by
    simp only [receiver,St.alloc,PTrie.get_set_u64 _ _ _ firstBound,ite_true]
  by_cases empty : home = .undef
  · subst home
    change (allocCells receiver (paramNames f) ((nThis,s.next)::env)).2.heap.get s.next = _
    rw [allocCells_heap_below receiver (paramNames f) ((nThis,s.next)::env) s.next
      (by rw [receiverNext]; omega) (by rw [receiverNext]; omega)]
    exact receiverCell
  · unfold closureState
    rw [closureStart_home s env home this empty]
    let withHome := (receiver.alloc (.cell (some home))).2
    have homeNext : withHome.next = s.next+2 := by change s.next+1+1 = s.next+2; omega
    change (allocCells withHome (paramNames f) ((nHome,s.next+1)::(nThis,s.next)::env)).2.heap.get s.next = _
    rw [allocCells_heap_below withHome (paramNames f) _ s.next
      (by rw [homeNext]; omega) (by rw [homeNext]; omega)]
    exact (alloc_heap_below receiver (.cell (some home)) s.next
      (by rw [receiverNext]; omega) (by rw [receiverNext]; omega)).trans receiverCell

theorem ClosureLive.receiver (live : Nat → Prop) (start : Nat) (home : Val) (f : Func) :
    ClosureLive live start false home f start := by
  cases home <;> unfold ClosureLive
  all_goals first
    | exact CellsLive.grow _ _ _ start (Or.inr rfl)
    | exact CellsLive.grow _ _ _ start (Or.inl (Or.inr rfl))

/-- The environment inside the real target scheduler is determined by the
checked whole-state relation, rather than being an additional target input. -/
theorem closureEnvironment_from_state {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St S} (f : Func) (env₀ env : Env) (arrow : Bool) (home₀ home this₀ this : Val)
    (args₀ args : List Val)
    (post : StateR NR FR R live framed before after old old'
      (closureState s₀ f env₀ arrow home₀ this₀ args₀ .call)
      (closureState s f env arrow home this args .call)) :
    closureEnvironment s f env arrow home this = R.env (closureEnvironment s₀ f env₀ arrow home₀ this₀) := by
  have relation := post.stack
  rw [closureState_stack,closureState_stack] at relation
  cases relation with
  | cons head _ =>
    obtain ⟨targetArgs,frameEq,_⟩ := head.params_view
    exact (FnF.params.inj (Frame.k.inj frameEq)).2.2.2
end Host.Ts.Owned.Parametric
