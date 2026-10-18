import host.ts.RenameParametricDescent
import host.ts.RenameParametricControl

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

/-- The exact live-set extension from allocating the ordered parameter cells. -/
def CellsLive (live : Nat → Prop) (start : Nat) : List Name → Nat → Prop
  | [] => live
  | _ :: ns => CellsLive (LiveAfter live start) (start+1) ns

theorem CellsLive.grow (live : Nat → Prop) (start : Nat) (names : List Name) :
    ∀ a, live a → CellsLive live start names a := by
  induction names generalizing live start with
  | nil => exact fun _ ha => ha
  | cons n ns ih => exact fun a ha => ih _ _ a (Or.inl ha)

theorem allocCells_next {S : Type} (s : St S) (names : List Name) (env : Env) :
    (allocCells s names env).2.next = s.next + names.length := by
  induction names generalizing s env with
  | nil => simp only [allocCells,List.length_nil,Nat.add_zero]
  | cons n ns ih =>
    simp only [allocCells,ih,St.alloc,List.length_cons]
    omega

/-- Parameter allocation preserves the entire host/native state relation. The
returned environments are derived from the allocator, with no target premise. -/
theorem allocCells_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (names : List Name) (env : Env) (he : treeSupport live (Encode.env env))
    (hs : s₀.next + names.length ≤ 2^64) (ht : s.next + names.length ≤ 2^64) :
    StateR NR FR R (CellsLive live s₀.next names) framed before after old old'
      (allocCells s₀ names env).2 (allocCells s names (R.env env)).2 ∧
    (allocCells s names (R.env env)).1 = R.env (allocCells s₀ names env).1 ∧
    treeSupport (CellsLive live s₀.next names) (Encode.env (allocCells s₀ names env).1) := by
  induction names generalizing live s₀ s env with
  | nil => exact ⟨h,rfl,he⟩
  | cons n ns ih =>
    have hsb : s₀.next < 2^64 := by simp only [List.length_cons] at hs; omega
    have htb : s.next < 2^64 := by simp only [List.length_cons] at ht; omega
    have ha := h.alloc (.cell none) (.cell none) .uninitialized True.intro hsb htb
    have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
    have hen : treeSupport (LiveAfter live s₀.next) (Encode.env ((n,s₀.next)::env)) := by
      change (True ∧ LiveAfter live s₀.next s₀.next ∧ True) ∧ treeSupport (LiveAfter live s₀.next) (Encode.env env)
      exact ⟨⟨True.intro,Or.inr rfl,True.intro⟩,treeSupport_mono (fun _ => Or.inl) _ he⟩
    have hsn : (s₀.alloc (.cell none)).2.next + ns.length ≤ 2^64 := by
      change s₀.next+1+ns.length ≤ 2^64
      simp only [List.length_cons] at hs; omega
    have htn : (s.alloc (.cell none)).2.next + ns.length ≤ 2^64 := by
      change s.next+1+ns.length ≤ 2^64
      simp only [List.length_cons] at ht; omega
    have result := ih ha ((n,s₀.next)::env) hen hsn htn
    simpa only [allocCells,CellsLive,Ren.env,List.map_cons,hn,St.alloc] using result

theorem vals_roles {NR : NumV → NumV → Prop} {R : Ren} {xs ys : List Val}
    (h : ListR (ValueR NR R) xs ys) : TreeR NR R (Encode.vals xs) (Encode.vals ys) := by
  induction h with
  | nil => exact .node _ .nil
  | cons h _ ih => cases ih with
    | node tag ht => exact .node _ (.cons (.value h) ht)

theorem vals_support {live : Nat → Prop} (xs : List Val) (h : listSupport (valueSupport live) xs) :
    treeSupport live (Encode.vals xs) := by
  induction xs with
  | nil => exact True.intro
  | cons x xs ih => exact ⟨h.1,ih h.2⟩

/-- This is the actual final expression of `enterClosure`. -/
def parameterContinuation {S : Type} (s : St S) (f : Func) (b : Boundary) (args : List Val) (env : Env) : St S :=
  (((s.push (.k (.fn b))).push (.k (.params f (fnParams f) args env))).ret .undef)

theorem parameterContinuation_roles {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (f : Func)
    (b₀ b : Boundary) (args₀ args : List Val) (env : Env)
    (hb : TreeR NR R (Encode.bnd b₀) (Encode.bnd b))
    (ha : ListR (ValueR NR R) args₀ args)
    (hlb : treeSupport live (Encode.bnd b₀)) (hla : listSupport (valueSupport live) args₀)
    (hle : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old'
      (parameterContinuation s₀ f b₀ args₀ env) (parameterContinuation s f b args (R.env env)) := by
  have hfn : FrameR NR R (.k (.fn b₀)) (.k (.fn b)) :=
    .node _ (.cons (.node _ (.cons hb .nil)) .nil)
  have hp : FrameR NR R (.k (.params f (fnParams f) args₀ env))
      (.k (.params f (fnParams f) args (R.env env))) :=
    .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _)
      (.cons (vals_roles ha) (.cons (env_roles NR R env) .nil))))) .nil)
  have hfnl : treeSupport live (Encode.frame (.k (.fn b₀))) := ⟨⟨hlb,True.intro⟩,True.intro⟩
  have hpl : treeSupport live (Encode.frame (.k (.params f (fnParams f) args₀ env))) :=
    ⟨⟨True.intro,True.intro,vals_support args₀ hla,hle,True.intro⟩,True.intro⟩
  exact (h.restack (.cons hp (.cons hfn h.stack)) ⟨hpl,hfnl,h.stackLive⟩).go
    (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩

theorem enterClosure_arrow_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (f : Func) (env : Env)
    (home₀ home this₀ this : Val) (args₀ args : List Val) (b₀ b : Boundary)
    (hb : TreeR NR R (Encode.bnd b₀) (Encode.bnd b)) (ha : ListR (ValueR NR R) args₀ args)
    (hlb : treeSupport live (Encode.bnd b₀)) (hla : listSupport (valueSupport live) args₀)
    (hle : treeSupport live (Encode.env env))
    (hs : s₀.next + (paramNames f).length ≤ 2^64) (ht : s.next + (paramNames f).length ≤ 2^64) :
    ∃ result₀ result,
      interpC (enterClosure F s₀ f env true home₀ this₀ args₀ b₀).run C₀ = some (result₀,C₀) ∧
      interpC (enterClosure F s f (R.env env) true home this args b).run C = some (result,C) ∧
      StateR NR FR R (CellsLive live s₀.next (paramNames f)) framed before after old old' result₀ result := by
  obtain ⟨hh,he,hel⟩ := allocCells_roles h (paramNames f) env hle hs ht
  have hg := CellsLive.grow live s₀.next (paramNames f)
  have hr := parameterContinuation_roles hh f b₀ b args₀ args (allocCells s₀ (paramNames f) env).1 hb ha
    (treeSupport_mono hg _ hlb) (listSupport_mono (valueSupport_mono hg) _ hla) hel
  refine ⟨_,_,?_,?_,hr⟩
  · rfl
  · simp only [enterClosure,Bool.cond_true]
    rw [he]
    rfl

theorem allocated_binding_support {S : Type} {live : Nat → Prop} (s : St S) (name : Name) (env : Env)
    (h : treeSupport live (Encode.env env)) :
    treeSupport (LiveAfter live s.next) (Encode.env ((name,s.next)::env)) := by
  change (True ∧ LiveAfter live s.next s.next ∧ True) ∧ treeSupport (LiveAfter live s.next) (Encode.env env)
  exact ⟨⟨True.intro,Or.inr rfl,True.intro⟩,treeSupport_mono (fun _ => Or.inl) _ h⟩

theorem allocated_binding_map {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (h : HeapR NR R live framed before after s₀ s) (name : Name) (env : Env) :
    R.env ((name,s₀.next)::env) = (name,s.next)::R.env env := by
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.fresh 0
  simp only [Ren.env,List.map_cons,hn]

theorem enterClosure_plain_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (f : Func) (env : Env)
    (this₀ this : Val) (args₀ args : List Val) (b₀ b : Boundary)
    (hthis : ValueR NR R this₀ this) (hlthis : valueSupport live this₀)
    (hb : TreeR NR R (Encode.bnd b₀) (Encode.bnd b)) (ha : ListR (ValueR NR R) args₀ args)
    (hlb : treeSupport live (Encode.bnd b₀)) (hla : listSupport (valueSupport live) args₀)
    (hle : treeSupport live (Encode.env env))
    (hs : s₀.next + 1 + (paramNames f).length ≤ 2^64)
    (ht : s.next + 1 + (paramNames f).length ≤ 2^64) :
    ∃ result₀ result,
      interpC (enterClosure F s₀ f env false .undef this₀ args₀ b₀).run C₀ = some (result₀,C₀) ∧
      interpC (enterClosure F s f (R.env env) false .undef this args b).run C = some (result,C) ∧
      StateR NR FR R (CellsLive (LiveAfter live s₀.next) (s₀.next+1) (paramNames f))
        framed before after old old' result₀ result := by
  have hv : treeSupport (LiveAfter live s₀.next) (Encode.hobj (.cell (some this₀))) :=
    ⟨valueSupport_mono (fun _ => Or.inl) _ hlthis,True.intro⟩
  have hh := h.alloc (.cell (some this₀)) (.cell (some this)) (.cell hthis) hv (by omega) (by omega)
  have hg : ∀ a, live a → LiveAfter live s₀.next a := fun _ => Or.inl
  have result := enterClosure_arrow_roles F NR FR R C₀ C _ framed before after old old'
    (s₀.alloc (.cell (some this₀))).2 (s.alloc (.cell (some this))).2 hh f ((nThis,s₀.next)::env)
    .undef .undef this₀ this args₀ args b₀ b hb ha
    (treeSupport_mono hg _ hlb) (listSupport_mono (valueSupport_mono hg) _ hla)
    (allocated_binding_support s₀ nThis env hle) hs ht
  rw [allocated_binding_map h.heap] at result
  exact result

theorem enterClosure_home_eq (F : Ffi) (s : St F.S) (f : Func) (env : Env)
    (home this : Val) (args : List Val) (b : Boundary) (hn : home ≠ .undef) :
    enterClosure F s f env false home this args b =
      let s₁ := (s.alloc (.cell (some this))).2
      let s₂ := (s₁.alloc (.cell (some home))).2
      enterClosure F s₂ f ((nHome,s₁.next)::(nThis,s.next)::env) true .undef this args b := by
  cases home <;> first | exact False.elim (hn rfl) | rfl

theorem enterClosure_home_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (f : Func) (env : Env)
    (home₀ home this₀ this : Val) (args₀ args : List Val) (b₀ b : Boundary)
    (hhome : ValueR NR R home₀ home) (hn : home₀ ≠ .undef) (hlhome : valueSupport live home₀)
    (hthis : ValueR NR R this₀ this) (hlthis : valueSupport live this₀)
    (hb : TreeR NR R (Encode.bnd b₀) (Encode.bnd b)) (ha : ListR (ValueR NR R) args₀ args)
    (hlb : treeSupport live (Encode.bnd b₀)) (hla : listSupport (valueSupport live) args₀)
    (hle : treeSupport live (Encode.env env))
    (hs : s₀.next + 2 + (paramNames f).length ≤ 2^64)
    (ht : s.next + 2 + (paramNames f).length ≤ 2^64) :
    ∃ result₀ result,
      interpC (enterClosure F s₀ f env false home₀ this₀ args₀ b₀).run C₀ = some (result₀,C₀) ∧
      interpC (enterClosure F s f (R.env env) false home this args b).run C = some (result,C) ∧
      StateR NR FR R (CellsLive (LiveAfter (LiveAfter live s₀.next) (s₀.next+1))
        (s₀.next+2) (paramNames f)) framed before after old old' result₀ result := by
  have hn' : home ≠ .undef := by cases hhome <;> simp_all
  have hg₁ : ∀ a, live a → LiveAfter live s₀.next a := fun _ => Or.inl
  have htcell : treeSupport (LiveAfter live s₀.next) (Encode.hobj (.cell (some this₀))) :=
    ⟨valueSupport_mono hg₁ _ hlthis,True.intro⟩
  have hh₁ := h.alloc (.cell (some this₀)) (.cell (some this)) (.cell hthis) htcell (by omega) (by omega)
  let s₀₁ := (s₀.alloc (.cell (some this₀))).2
  let s₁ := (s.alloc (.cell (some this))).2
  have hg₂ : ∀ a, live a → LiveAfter (LiveAfter live s₀.next) s₀₁.next a := fun _ h => Or.inl (Or.inl h)
  have hhcell : treeSupport (LiveAfter (LiveAfter live s₀.next) s₀₁.next) (Encode.hobj (.cell (some home₀))) :=
    ⟨valueSupport_mono hg₂ _ hlhome,True.intro⟩
  have hh₂ := hh₁.alloc (.cell (some home₀)) (.cell (some home)) (.cell hhome) hhcell
    (show s₀₁.next < 2^64 from by change s₀.next+1 < 2^64; omega)
    (show s₁.next < 2^64 from by change s.next+1 < 2^64; omega)
  have result := enterClosure_arrow_roles F NR FR R C₀ C _ framed before after old old'
    (s₀₁.alloc (.cell (some home₀))).2 (s₁.alloc (.cell (some home))).2 hh₂ f
    ((nHome,s₀₁.next)::(nThis,s₀.next)::env) .undef .undef this₀ this args₀ args b₀ b hb ha
    (treeSupport_mono hg₂ _ hlb) (listSupport_mono (valueSupport_mono hg₂) _ hla)
    (allocated_binding_support s₀₁ nHome _ (allocated_binding_support s₀ nThis env hle)) hs ht
  rw [allocated_binding_map hh₁.heap,allocated_binding_map h.heap] at result
  rw [enterClosure_home_eq F s₀ f env home₀ this₀ args₀ b₀ hn,
    enterClosure_home_eq F s f (R.env env) home this args b hn']
  exact result

end Host.Ts.Owned.Parametric
