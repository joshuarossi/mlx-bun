import host.ts.RenameParametricViews

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem kind_native {NR : NumV → NumV → Prop} {R : Ren}
    {n : Native} {data : List Val} {k : Kind}
    (h : TreeR NR R (Encode.kind (.fn (.native n data))) (Encode.kind k)) :
    ∃ data', k = .fn (.native n data') ∧ ListR (ValueR NR R) data data' := by
  have ht := h.tag_eq
  cases k <;> simp only [Encode.kind,treeTag] at ht
  all_goals try contradiction
  case fn c =>
    cases h with | node tag hs =>
      cases hs with | cons hc hs =>
        have ht := hc.tag_eq
        cases c <;> simp only [Encode.code,treeTag] at ht
        all_goals try contradiction
        case native n' data' =>
          cases hc with | node tag hs =>
            cases hs with | cons hn hs =>
              cases hs with | cons hd hs =>
                cases hn
                exact ⟨data',rfl,vals_roles_of hd⟩

/-- A source native function lookup determines the target builtin and its
captured data using the live heap relation. -/
theorem StateR.native_call_view {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (n : Native) (data₀ : List Val) (this₀ : Val) (args₀ : List Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ args₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .fn (.native n data₀)) :
    ∃ (o : Obj) (data : List Val) (this : Val) (args : List Val),
      s.ctl = .call (.obj (R.a a)) this args ∧
      s.heap.get (R.a a) = some (.obj o) ∧ o.kind = .fn (.native n data) ∧
      ListR (ValueR NR R) data₀ data ∧ ValueR NR R this₀ this ∧
      ListR (ValueR NR R) args₀ args := by
  obtain ⟨callee,this,args,hc,hcallee,hthis,hargs⟩ := (h.control_view hc₀).call_view
  have hcallee : callee = .obj (R.a a) := by cases hcallee; rfl
  rw [hcallee] at hc
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have hnf := h.heap.function_notFramed a o₀ _ ha ho₀ hk₀
  obtain ⟨o,ho,hr,_⟩ := h.heap.readObject a o₀ ha hnf ho₀
  have hk := hr.kind
  rw [hk₀] at hk
  obtain ⟨data,hk,hdata⟩ := kind_native hk
  exact ⟨o,data,this,args,hc,ho,hk,hdata,hthis,hargs⟩

theorem step_native_eq (F : Ffi) (s : St F.S) (a : Nat) (o : Obj)
    (n : Native) (data : List Val) (this : Val) (args : List Val)
    (hc : s.ctl = .call (.obj a) this args) (ho : s.heap.get a = some (.obj o))
    (hk : o.kind = .fn (.native n data)) :
    step F s = callNative F s n data this args := by
  simp only [step,hc,callStep,St.obj?,ho,hk]

end Host.Ts.Owned.Parametric
