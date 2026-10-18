import host.mlx.NativeIdentitySeed
import host.mlx.NativeAnnotationSupport

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated.Initial
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def objectNumber : NumV → Number
  | .lit x => .literal (.lit x)
  | .ref _ => .literal (.lit (F64.ofNat 0))
def checkObjectNumber : NumV → Bool
  | .lit _ => true
  | .ref _ => false
def objectConfig (c : Cfg) : Config :=
  ⟨c.outs.map (fun (shape,dtype) => (shape.map literalDimension,dtype)),
    c.grid.map objectNumber,c.group.map objectNumber,c.ints.map (fun (name,n) => (name,objectNumber n)),
    c.dtypes,c.init.map objectNumber⟩
def checkObjectConfig (c : Cfg) : Bool :=
  c.outs.all (fun pair => pair.1.all checkDimension) &&
  c.grid.all checkObjectNumber && c.group.all checkObjectNumber &&
  c.ints.all (fun pair => checkObjectNumber pair.2) && c.init.all checkObjectNumber

def objectPayload : Arg → Owned.Annotated.Tree
  | .null => .node "Arg.null" []
  | .num (.lit x) => .node "Arg.num" [.number (.lit x)]
  | .extPtr region offset => .node "Arg.extPtr" [.region region,.atom Nat offset]
  | _ => .node "Arg.null" []
def checkObjectPayload : Arg → Bool
  | .null | .num (.lit _) | .extPtr _ _ => true
  | _ => false
def objectTrace (t : Ffi.Trace) : Trace := ⟨t.ins,t.outs,t.order⟩
def checkObjectTrace (limit : Nat) (t : Ffi.Trace) : Bool :=
  (t.ins++t.outs++t.order).all (fun i => Nat.blt i limit)
def objectClosure : Clo → Closure
  | .empty => .empty
  | .fn callback payload => .fn callback (objectPayload payload)
  | .compiled callback payload shapeless traces =>
      .compiled callback (objectPayload payload) shapeless (traces.map objectTrace)
def checkObjectClosure (limit : Nat) : Clo → Bool
  | .empty => true
  | .fn _ payload => checkObjectPayload payload
  | .compiled _ payload _ traces => checkObjectPayload payload && traces.all (checkObjectTrace limit)

def objectRole : Ffi.Obj → Object
  | .stream => .stream
  | .str text => .str text
  | .vec nodes => .vec nodes
  | .vstr length => .vstr length
  | .kernel name body header inputs outputs => .kernel name body header inputs outputs
  | .cfg config => .config (objectConfig config)
  | .clo closure => .closure (objectClosure closure)
  | .amap file => .amap file
  | .smap => .smap
  | .device => .device
  | .dinfo => .dinfo
def checkObject (limit : Nat) : Ffi.Obj → Bool
  | .vec nodes => nodes.all (fun i => Nat.blt i limit)
  | .cfg config => checkObjectConfig config
  | .clo closure => checkObjectClosure limit closure
  | _ => true

private theorem checked_list {α β : Type} (f : α → β) (check : α → Bool) (rel : β → α → Prop)
    (step : ∀ x, check x = true → rel (f x) x) (xs : List α) (safe : xs.all check = true) :
    ListR rel (xs.map f) xs := by
  induction xs with
  | nil => exact .nil
  | cons x xs ih =>
    have split := Bool.and_eq_true_iff.mp safe
    exact .cons (step x split.1) (ih split.2)

theorem objectNumber_holds (ν : Nat → F64) (C : CSrv) (n : NumV)
    (safe : checkObjectNumber n = true) : (objectNumber n).Holds ν C n := by
  cases n with
  | lit x => exact .literal (.lit x) x rfl
  | ref i => cases safe

private theorem objectOption_holds (ν : Nat → F64) (C : CSrv) (o : Option NumV)
    (safe : o.all checkObjectNumber = true) :
    NativeRoles.OptionR (Number.Holds ν C) (o.map objectNumber) o := by
  cases o with
  | none => exact .none
  | some n => exact .some (objectNumber_holds ν C n safe)

theorem objectConfig_holds (ν : Nat → F64) (C : CSrv) (c : Cfg)
    (safe : checkObjectConfig c = true) : (objectConfig c).Holds ν C c := by
  simp only [checkObjectConfig,Bool.and_eq_true_iff] at safe
  obtain ⟨⟨⟨⟨outs,grid⟩,group⟩,ints⟩,init⟩ := safe
  refine ⟨?_,checked_list _ _ _ (objectNumber_holds ν C) _ grid,
    checked_list _ _ _ (objectNumber_holds ν C) _ group,?_,rfl,?_⟩
  · exact checked_list _ _ _ (fun pair checked => ⟨literalShape_holds ν C pair.1 checked,rfl⟩) _ outs
  · exact checked_list _ _ _ (fun pair checked => ⟨rfl,objectNumber_holds ν C pair.2 checked⟩) _ ints
  · exact objectOption_holds ν C c.init init

theorem objectPayload_holds (ν : Nat → F64) (C : CSrv) (a : Arg)
    (safe : checkObjectPayload a = true) :
    (objectPayload a).Holds ν C Owned.Annotated.identity (Owned.Parametric.arg a) := by
  cases a with
  | null => exact .node _ .nil
  | num n => cases n with
    | lit x => exact .node _ (.cons (.number (.lit x) (.lit x) rfl) .nil)
    | ref i => cases safe
  | extPtr region offset => exact .node _ (.cons (.region region) (.cons (.atom _ _) .nil))
  | _ => cases safe

theorem objectTrace_holds (t : Ffi.Trace) : (objectTrace t).Holds Owned.Annotated.identity t := by
  constructor <;> simp only [objectTrace,Owned.Annotated.identity,List.map_id_fun,id_eq]

theorem objectClosure_holds (ν : Nat → F64) (C : CSrv) (limit : Nat) (c : Clo)
    (safe : checkObjectClosure limit c = true) :
    (objectClosure c).Holds ν C Owned.Annotated.identity c := by
  cases c with
  | empty => exact .empty
  | fn callback payload => exact .fn callback (objectPayload_holds ν C payload safe)
  | compiled callback payload shapeless traces =>
    have split := Bool.and_eq_true_iff.mp safe
    exact .compiled callback shapeless (objectPayload_holds ν C payload split.1)
      (checked_list _ _ _ (fun t _ => objectTrace_holds t) traces split.2)

theorem objectRole_holds (ν : Nat → F64) (C : CSrv) (limit : Nat) (o : Ffi.Obj)
    (safe : checkObject limit o = true) : (objectRole o).Holds ν C Owned.Annotated.identity o := by
  cases o with
  | vec nodes => simpa only [objectRole,Owned.Annotated.identity,List.map_id_fun,id_eq] using
      (Object.Holds.vec (ν:=ν) (C:=C) (R:=Owned.Annotated.identity) nodes)
  | cfg config => exact .config (objectConfig_holds ν C config safe)
  | clo closure => exact .closure (objectClosure_holds ν C limit closure safe)
  | _ => constructor

private theorem supported_list (limit : Nat) (xs : List Nat) (safe : xs.all (fun i => Nat.blt i limit) = true) :
    listSupport (fun i => i < limit) xs := by
  induction xs with
  | nil => trivial
  | cons x xs ih =>
    have split := Bool.and_eq_true_iff.mp safe
    exact ⟨Nat.blt_eq.mp split.1,ih split.2⟩

theorem objectTrace_supported (limit : Nat) (t : Ffi.Trace) (safe : checkObjectTrace limit t = true) :
    (objectTrace t).Supported (fun i => i < limit) := by
  have all := supported_list limit _ safe
  have append {xs ys : List Nat} (h : listSupport (fun i => i < limit) (xs++ys)) :
      listSupport (fun i => i < limit) xs ∧ listSupport (fun i => i < limit) ys := by
    induction xs with
    | nil => exact ⟨trivial,h⟩
    | cons x xs ih =>
      have split := ih h.2
      exact ⟨⟨h.1,split.1⟩,split.2⟩
  have split := append all
  have rest := append split.1
  exact ⟨rest.1,rest.2,split.2⟩

theorem objectRole_supported (limit : Nat) (o : Ffi.Obj) (safe : checkObject limit o = true) :
    (objectRole o).Supported (fun i => i < limit) := by
  cases o with
  | vec nodes => exact supported_list limit nodes safe
  | clo closure =>
    cases closure with
    | compiled callback payload shapeless traces =>
      have checked := (Bool.and_eq_true_iff.mp safe).2
      clear safe
      change listSupport (Trace.Supported (fun i => i < limit)) (traces.map objectTrace)
      induction traces with
      | nil => trivial
      | cons t ts ih =>
        have split := Bool.and_eq_true_iff.mp checked
        exact ⟨objectTrace_supported limit t split.1,ih split.2⟩
    | _ => trivial
  | _ => trivial

def objectRoles (s : St) (i : Nat) : Object :=
  match s.objs.get i with
  | some o => objectRole o
  | none => .stream

theorem objectRoles_holds (s : St) (safe : allPaged (checkObject s.nnext) s.objs = true)
    (ν : Nat → F64) (C : CSrv) (i : Nat) (o : Ffi.Obj) (read : s.objs.get i = some o) :
    (objectRoles s i).Holds ν C Owned.Annotated.identity o := by
  simp only [objectRoles,read]
  exact objectRole_holds ν C s.nnext o (allPaged_get _ _ safe i o read)

theorem objectRoles_supported (s : St) (safe : allPaged (checkObject s.nnext) s.objs = true) (i : Nat) :
    (objectRoles s i).Supported (fun n => n < s.nnext) := by
  cases read : s.objs.get i with
  | none => simp only [objectRoles,read]; trivial
  | some o =>
    simp only [objectRoles,read]
    exact objectRole_supported s.nnext o (allPaged_get _ _ safe i o read)

end Host.Mlx.Ffi.Annotated.Initial
