import host.ts.MapLookup
import host.ts.RenameCleanupViews
import host.ts.RenameParametricNativeCall

set_option Elab.async false
namespace Host.Ts

theorem mapEntryValue_string (F : Ffi) (s : St F.S) (key : Name) (entries : List (Val × Val)) :
    mapEntryValue F s (.str key) entries = M.pure ((StringIndex.firstValue (pack key) entries).getD .undef) := by
  rw [mapEntryValue_eq_linear]
  change mapEntryValueLinear F s (.str key) entries = _
  unfold mapEntryValueLinear
  rw [findEntry_string, ← StringIndex.firstCode_value]
  generalize StringIndex.firstCode (pack key) entries 0 = found
  cases found with
  | none => rfl
  | some index =>
    change M.pure ((nth? entries index).elim .undef Prod.snd) =
      M.pure (((nth? entries index).map Prod.snd).getD .undef)
    cases nth? entries index <;> rfl

end Host.Ts
namespace Host.Ts.Owned.Parametric

theorem kind_string_map {NR : NumV → NumV → Prop} {R : Ren}
    {entries : List (Val × Val)} {kind : Kind}
    (relation : TreeR NR R (Encode.kind (.map entries)) (Encode.kind kind)) :
    ∃ targetEntries, kind = .map targetEntries ∧
      TreeR NR R (Encode.pairs entries) (Encode.pairs targetEntries) := by
  have tags := relation.tag_eq
  cases kind <;> simp only [Encode.kind,treeTag] at tags
  all_goals try contradiction
  case map targetEntries =>
    cases relation with | node tag fields =>
      cases fields with | cons pairs rest => exact ⟨targetEntries,rfl,pairs⟩

theorem HeapR.map_notFramed {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {source target : St S}
    (relation : HeapR NR R live framed before after source target) (owner : Nat) (object : Obj)
    (entries : List (Val × Val)) (alive : live owner)
    (read : source.heap.get owner = some (.obj object)) (kind : object.kind = .map entries) :
    ¬ framed owner := by
  have slot := relation.lookup owner alive
  rw [read] at slot
  generalize target.heap.get (R.a owner) = found at slot
  cases slot with
  | regular notFramed => exact notFramed
  | framed _ sourceKind => rw [kind] at sourceKind; cases sourceKind

/-- String queries preserve the original first matching entry, even when
numeric keys elsewhere in the map have different meanings. -/
theorem string_map_value_related {NR : NumV → NumV → Prop} {R : Ren}
    (code : Nat) {entries targetEntries : List (Val × Val)}
    (relation : TreeR NR R (Encode.pairs entries) (Encode.pairs targetEntries)) :
    ValueR NR R ((StringIndex.firstValue code entries).getD .undef)
      ((StringIndex.firstValue code targetEntries).getD .undef) := by
  induction entries generalizing targetEntries with
  | nil => rw [pairs_nil_view relation]; exact .undef
  | cons pair rest induction =>
    rcases pair with ⟨key,value⟩
    obtain ⟨key',value',rest',rfl,keyRelation,valueRelation,tail⟩ := pairs_cons_view relation
    cases keyRelation <;> simp only [StringIndex.firstValue]
    all_goals try exact induction tail
    case str name =>
      cases Nat.beq (pack name) code
      · exact induction tail
      · exact valueRelation

theorem string_map_value_support {live : Nat → Prop} (code : Nat) (entries : List (Val × Val))
    (support : treeSupport live (Encode.pairs entries)) :
    valueSupport live ((StringIndex.firstValue code entries).getD .undef) := by
  induction entries with
  | nil => trivial
  | cons pair rest induction =>
    rcases pair with ⟨key,value⟩
    have valueLive : valueSupport live value := support.1.2.1
    have tailLive : treeSupport live (Encode.pairs rest) := support.2
    cases key <;> simp only [StringIndex.firstValue]
    all_goals try exact induction tailLive
    case str name =>
      cases Nat.beq (pack name) code
      · exact induction tailLive
      · exact valueLive

theorem step_string_map_get_eq (F : Ffi) (s : St F.S) (callee owner : Nat)
    (function object : Obj) (data : List Val) (key : Name) (extra : List Val)
    (entries : List (Val × Val))
    (control : s.ctl = .call (.obj callee) (.obj owner) (.str key::extra))
    (functionRead : s.heap.get callee = some (.obj function))
    (functionKind : function.kind = .fn (.native (.map .get) data))
    (objectRead : s.heap.get owner = some (.obj object))
    (objectKind : object.kind = .map entries) :
    step F s = M.pure (s.ret ((StringIndex.firstValue (pack key) entries).getD .undef)) := by
  rw [step_native_eq F s callee function (.map .get) data (.obj owner) (.str key::extra)
    control functionRead functionKind]
  simp only [callNative,mapN,mapN.withMap,mapOf,St.obj?,objectRead,objectKind,Host.Ts.arg,nthD,
    mapEntryValue_string,retS]
  rfl

/-- The original Map.get builtin derives its target lookup and result from
the current source map. It neither allocates nor changes the number server. -/
theorem step_string_map_get_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (source target : St F.S)
    (relation : StateR NR FR R live framed before after old old' source target)
    (callee owner : Nat) (function object : Obj) (data : List Val) (key : Name)
    (extra : List Val) (entries : List (Val × Val))
    (control : source.ctl = .call (.obj callee) (.obj owner) (.str key::extra))
    (functionRead : source.heap.get callee = some (.obj function))
    (functionKind : function.kind = .fn (.native (.map .get) data))
    (objectRead : source.heap.get owner = some (.obj object))
    (objectKind : object.kind = .map entries) :
    ∃ value,
      interpC (step F source).run C₀ = some (source.ret ((StringIndex.firstValue (pack key) entries).getD .undef),C₀) ∧
      interpC (step F target).run C = some (target.ret value,C) ∧
      StateR NR FR R live framed before after old old'
        (source.ret ((StringIndex.firstValue (pack key) entries).getD .undef)) (target.ret value) ∧
      ValueR NR R ((StringIndex.firstValue (pack key) entries).getD .undef) value := by
  obtain ⟨targetFunction,targetData,receiver,args,targetControl,targetFunctionRead,targetFunctionKind,
    dataRelation,receiverRelation,argsRelation⟩ := relation.native_call_view callee function (.map .get)
      data (.obj owner) (.str key::extra) control functionRead functionKind
  cases receiverRelation
  cases argsRelation with | cons keyRelation extraRelation =>
    cases keyRelation
    have ownerLive : live owner := by
      have support := relation.controlLive
      rw [control] at support
      exact support.2.1
    obtain ⟨targetObject,targetRead,objectRelation,objectLive⟩ :=
      relation.heap.readObject owner object ownerLive
        (relation.heap.map_notFramed owner object entries ownerLive objectRead objectKind) objectRead
    have kindRelation := objectRelation.kind
    rw [objectKind] at kindRelation
    obtain ⟨targetEntries,targetKind,pairsRelation⟩ := kind_string_map kindRelation
    have entriesLive : treeSupport live (Encode.pairs entries) := by
      have kindLive := objectLive.1
      rw [objectKind] at kindLive
      exact kindLive.1
    have valueRelation := string_map_value_related (pack key) pairsRelation
    refine ⟨(StringIndex.firstValue (pack key) targetEntries).getD .undef,?_,?_,?_,valueRelation⟩
    · rw [step_string_map_get_eq F source callee owner function object data key extra entries
        control functionRead functionKind objectRead objectKind]; rfl
    · rw [step_string_map_get_eq F target (R.a callee) (R.a owner) targetFunction targetObject targetData
        key _ targetEntries targetControl targetFunctionRead targetFunctionKind targetRead targetKind]; rfl
    · exact relation.go (.node _ (.cons (.value valueRelation) .nil))
        ⟨string_map_value_support (pack key) entries entriesLive,True.intro⟩

end Host.Ts.Owned.Parametric
