import host.ts.RenameParametricNativeCall
import host.ts.RenameParametricArrayBinding
import host.ts.RenameParametricArrayLength
import host.ts.RenameParametricPropWrites
import host.ts.RenameParametricTypedElements
import host.ts.RenameParametricStatements

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem ObjectR.extensible_eq {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') : o'.extensible = o.extensible := by
  obtain ⟨kind,proto,props,priv,ext⟩ := o
  obtain ⟨kind',proto',props',priv',ext'⟩ := o'
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      cases hs with | cons hp hs =>
        cases hs with | cons hps hs =>
          cases hs with | cons hpriv hs =>
            cases hs with | cons he hs => cases he; rfl

theorem ObjectR.replace_array {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') (xs ys : List Val) (hr : ListR (ValueR NR R) xs ys) :
    ObjectR NR R {o with kind := .array xs} {o' with kind := .array ys} := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      exact .node _ (.cons (.node _ (.cons (vals_roles hr) .nil)) hs)

theorem step_array_push_eq (F : Ffi) (s : St F.S) (f a : Nat) (fo o : Obj)
    (data args values : List Val) (hc : s.ctl = .call (.obj f) (.obj a) args)
    (hf : s.heap.get f = some (.obj fo)) (hfk : fo.kind = .fn (.native (.arr .push) data))
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .array values) (he : o.extensible = true) :
    step F s = M.pure ((s.setObj a {o with kind := .array (values++args)}).ret (natV (len (values++args)))) := by
  rw [step_native_eq F s f fo (.arr .push) data (.obj a) args hc hf hfk]
  simp only [callNative,arrN,arrN.withArr,arrayOf,St.obj?,ho,hk,he,Bool.cond_true,setArray,retS]

/-- The original mutable Array.push builtin appends related argument values,
retains the object's header/private fields and returns the fixed new length. -/
theorem step_array_push_from_source (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (f a : Nat) (fo₀ o₀ : Obj) (data₀ args₀ values₀ : List Val)
    (hc₀ : s₀.ctl = .call (.obj f) (.obj a) args₀)
    (hf₀ : s₀.heap.get f = some (.obj fo₀)) (hfk₀ : fo₀.kind = .fn (.native (.arr .push) data₀))
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .array values₀) (he₀ : o₀.extensible = true)
    (notFramed : ¬ framed a) (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some
        ((s₀.setObj a {o₀ with kind := .array (values₀++args₀)}).ret (natV (len (values₀++args₀))),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.setObj a {o₀ with kind := .array (values₀++args₀)}).ret (natV (len (values₀++args₀)))) result ∧
      result.ctl = .ret (natV (len (values₀++args₀))) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨fo,data,this,args,hc,hf,hfk,_,hthis,hargs⟩ := h.native_call_view f fo₀ (.arr .push) data₀ (.obj a) args₀ hc₀ hf₀ hfk₀
  cases hthis
  have hl := h.controlLive
  rw [hc₀] at hl
  have ha : live a := hl.2.1
  obtain ⟨o,ho,hor,hos⟩ := h.heap.readObject a o₀ ha notFramed ho₀
  have hkind := hor.kind
  rw [hk₀] at hkind
  obtain ⟨values,hk,hvalues⟩ := kind_array hkind
  have he : o.extensible = true := hor.extensible_eq.trans he₀
  have hvl : listSupport (valueSupport live) values₀ := by
    have hkl : treeSupport live (Encode.kind (.array values₀)) := by simpa only [hk₀] using hos.1
    exact vals_support_of values₀ hkl.1
  have hal := vals_support_of args₀ hl.2.2.1
  have hrl := listSupport_append hvl hal
  have hr := hvalues.append hargs
  have hol : treeSupport live (Encode.obj {o₀ with kind := .array (values₀++args₀)}) :=
    ⟨⟨vals_support _ hrl,True.intro⟩,hos.2⟩
  have hh := h.setObject a _ _ ha notFramed (hor.replace_array _ _ hr) hol
    (Nat.lt_of_lt_of_le (h.heap.sourceBound a ha) sourceBound)
    (Nat.lt_of_lt_of_le (h.heap.targetBound a ha) targetBound)
  have hlen : len (values++args) = len (values₀++args₀) := by
    simpa only [len_list_length] using (listR_length_eq hr).symm
  have hnum : NR (.lit (F64.ofNat (len (values₀++args₀)))) (.lit (F64.ofNat (len (values₀++args₀)))) :=
    ⟨_,NumRole.literal ν₀ ν C₀ C _⟩
  refine ⟨(s.setObj (R.a a) {o with kind := .array (values++args)}).ret (natV (len (values₀++args₀))),?_,?_,?_,rfl⟩
  · rw [step_array_push_eq F s₀ f a fo₀ o₀ data₀ args₀ values₀ hc₀ hf₀ hfk₀ ho₀ hk₀ he₀]; rfl
  · rw [step_array_push_eq F s (R.a f) (R.a a) fo o data args values hc hf hfk ho hk he,hlen]; rfl
  · exact hh.go (.node _ (.cons (.value (.num hnum)) .nil)) ⟨True.intro,True.intro⟩

end Host.Ts.Owned.Parametric
