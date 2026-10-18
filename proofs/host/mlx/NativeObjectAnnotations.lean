import host.mlx.NativeAnnotationResources

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned
open Host.Ts.Owned.Parametric

structure Trace where
  ins : List Nat
  outs : List Nat
  order : List Nat

structure Trace.Holds (R : Ren) (r : Trace) (t : Ffi.Trace) : Prop where
  ins : t.ins = r.ins.map R.node
  outs : t.outs = r.outs.map R.node
  order : t.order = r.order.map R.node

theorem Trace.paired {R : Ren} {r : Trace} {t₀ t : Ffi.Trace}
    (h₀ : r.Holds Owned.Annotated.identity t₀) (h : r.Holds R t) : NativeRoles.TraceR R t₀ t := by
  have hi : t₀.ins = r.ins := by simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using h₀.ins
  have ho : t₀.outs = r.outs := by simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using h₀.outs
  have hr : t₀.order = r.order := by simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using h₀.order
  exact ⟨h.ins.trans (congrArg (List.map R.node) hi).symm,
    h.outs.trans (congrArg (List.map R.node) ho).symm,h.order.trans (congrArg (List.map R.node) hr).symm⟩

inductive Closure : Type 1 where
  | empty
  | fn (callback : Nat) (payload : Owned.Annotated.Tree)
  | compiled (callback : Nat) (payload : Owned.Annotated.Tree) (shapeless : Bool) (traces : List Trace)

inductive Closure.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : Closure → Clo → Prop where
  | empty : Holds ν C R .empty .empty
  | fn (cb : Nat) {r : Owned.Annotated.Tree} {a : Arg} : r.Holds ν C R (Owned.Parametric.arg a) →
      Holds ν C R (.fn cb r) (.fn (R.region cb) a)
  | compiled (cb : Nat) (shapeless : Bool) {r : Owned.Annotated.Tree} {a : Arg}
      {rs : List Trace} {ts : List Ffi.Trace} :
      r.Holds ν C R (Owned.Parametric.arg a) → ListR (Trace.Holds R) rs ts →
      Holds ν C R (.compiled cb r shapeless rs) (.compiled (R.region cb) a shapeless ts)

theorem Closure.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {r : Closure} {c₀ c : Clo}
    (h₀ : r.Holds ν₀ C₀ Owned.Annotated.identity c₀) (h : r.Holds ν C R c) :
    NativeRoles.CloR (NumberRoles ν₀ ν C₀ C) R c₀ c := by
  cases h₀ <;> cases h
  case empty => exact .empty
  case fn => exact .fn _ (Owned.Annotated.Tree.paired (by assumption) (by assumption))
  case compiled =>
    exact .compiled _ _ (Owned.Annotated.Tree.paired (by assumption) (by assumption))
      (pairedList (p := Trace.Holds Owned.Annotated.identity) (q := Trace.Holds R)
        (by assumption) (by assumption) (fun _ _ _ => Trace.paired))

/-- Native object roles fix every resource position, including callback payloads
and ordered compiled traces, before interpretation in either run. -/
inductive Object : Type 1 where
  | stream
  | str (s : List Char)
  | vec (nodes : List Nat)
  | vstr (length : Nat)
  | kernel (name source header : List Char) (inputs outputs : Nat)
  | config (c : Config)
  | closure (c : Closure)
  | amap (file : Option (List Char))
  | smap
  | device
  | dinfo

inductive Object.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : Object → Obj → Prop where
  | stream : Holds ν C R .stream .stream
  | str (s : List Char) : Holds ν C R (.str s) (.str s)
  | vec (nodes : List Nat) : Holds ν C R (.vec nodes) (.vec (nodes.map R.node))
  | vstr (length : Nat) : Holds ν C R (.vstr length) (.vstr length)
  | kernel (name source header : List Char) (inputs outputs : Nat) :
      Holds ν C R (.kernel name source header inputs outputs) (.kernel name source header inputs outputs)
  | config {r : Config} {c : Cfg} : r.Holds ν C c → Holds ν C R (.config r) (.cfg c)
  | closure {r : Closure} {c : Clo} : r.Holds ν C R c → Holds ν C R (.closure r) (.clo c)
  | amap (file : Option (List Char)) : Holds ν C R (.amap file) (.amap file)
  | smap : Holds ν C R .smap .smap
  | device : Holds ν C R .device .device
  | dinfo : Holds ν C R .dinfo .dinfo

theorem Object.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {r : Object} {o₀ o : Obj}
    (h₀ : r.Holds ν₀ C₀ Owned.Annotated.identity o₀) (h : r.Holds ν C R o) :
    NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R o₀ o := by
  cases h₀ <;> cases h
  case stream => exact .stream
  case str s => exact .str s
  case vec nodes => simpa only [Owned.Annotated.identity,List.map_id_fun,id_eq] using
    (NativeRoles.ObjectR.vec (NR := NumberRoles ν₀ ν C₀ C) (R := R) nodes)
  case vstr length => exact .vstr length
  case kernel name source header inputs outputs => exact .kernel name source header inputs outputs
  case config => exact .cfg (Config.paired (by assumption) (by assumption))
  case closure => exact .clo (Closure.paired (by assumption) (by assumption))
  case amap file => exact .amap file
  case smap => exact .smap
  case device => exact .device
  case dinfo => exact .dinfo

structure ObjectRel (roles : Nat → Object) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (i : Nat) (o₀ o : Obj) : Prop where
  source : (roles i).Holds ν₀ C₀ Owned.Annotated.identity o₀
  target : (roles i).Holds ν C R o

theorem ObjectRel.base {roles : Nat → Object} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {i : Nat} {o₀ o : Obj} (h : ObjectRel roles ν₀ ν C₀ C R i o₀ o) :
    NativeRoles.ObjectR (NumberRoles ν₀ ν C₀ C) R o₀ o := Object.paired h.source h.target

theorem Closure.Holds.mono {ν : Nat → F64} {C D : CSrv} {R : Ren} {r : Closure} {c : Clo}
    (h : r.Holds ν C R c) (he : TableExtends C D) : r.Holds ν D R c := by
  cases h with
  | empty => exact .empty
  | fn cb hp => exact .fn cb (hp.mono he)
  | compiled cb sl hp ht => exact .compiled cb sl (hp.mono he) ht

theorem Object.Holds.mono {ν : Nat → F64} {C D : CSrv} {R : Ren} {r : Object} {o : Obj}
    (h : r.Holds ν C R o) (he : TableExtends C D) : r.Holds ν D R o := by
  cases h with
  | stream => exact .stream
  | str s => exact .str s
  | vec ns => exact .vec ns
  | vstr len => exact .vstr len
  | kernel name source header inputs outputs => exact .kernel name source header inputs outputs
  | config h => exact .config (h.mono he)
  | closure h => exact .closure (h.mono he)
  | amap file => exact .amap file
  | smap => exact .smap
  | device => exact .device
  | dinfo => exact .dinfo

def Trace.rename (K : Ren) (r : Trace) : Trace :=
  ⟨r.ins.map K.node,r.outs.map K.node,r.order.map K.node⟩

theorem Trace.holds_rename (R K : Ren) (r : Trace) (t : Ffi.Trace) :
    (r.rename K).Holds R t ↔ r.Holds (Owned.Annotated.composeResources R K) t := by
  constructor <;> intro h <;> constructor
  all_goals first
    | simpa only [Trace.rename,List.map_map,Function.comp_def,Owned.Annotated.composeResources] using h.ins
    | simpa only [Trace.rename,List.map_map,Function.comp_def,Owned.Annotated.composeResources] using h.outs
    | simpa only [Trace.rename,List.map_map,Function.comp_def,Owned.Annotated.composeResources] using h.order

def Closure.subst (θ : Nat → SymE) : Closure → Closure
  | .empty => .empty
  | .fn cb p => .fn cb (p.subst θ)
  | .compiled cb p sl ts => .compiled cb (p.subst θ) sl ts

theorem Closure.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (r : Closure) (c : Clo) :
    (r.subst θ).Holds ν C R c ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C R c := by
  cases r <;> simp only [Closure.subst]
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | assumption
    | exact (Owned.Annotated.Tree.holds_subst θ _ _).mp (by assumption)
    | exact (Owned.Annotated.Tree.holds_subst θ _ _).mpr (by assumption)

def Closure.rename (K : Ren) : Closure → Closure
  | .empty => .empty
  | .fn cb p => .fn (K.region cb) (p.rename K)
  | .compiled cb p sl ts => .compiled (K.region cb) (p.rename K) sl (ts.map (Trace.rename K))

theorem Closure.holds_rename {ν : Nat → F64} {C : CSrv}
    (R K : Ren) (r : Closure) (c : Clo) :
    (r.rename K).Holds ν C R c ↔ r.Holds ν C (Owned.Annotated.composeResources R K) c := by
  cases r <;> simp only [Closure.rename]
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | exact (Owned.Annotated.Tree.holds_rename R K _ _).mp (by assumption)
    | exact (Owned.Annotated.Tree.holds_rename R K _ _).mpr (by assumption)
    | exact (list_map_holds (Trace.rename K) _ _ (Trace.holds_rename R K) _ _).mp (by assumption)
    | exact (list_map_holds (Trace.rename K) _ _ (Trace.holds_rename R K) _ _).mpr (by assumption)

def Object.subst (θ : Nat → SymE) : Object → Object
  | .config c => .config (c.subst θ)
  | .closure c => .closure (c.subst θ)
  | o => o

theorem Object.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (r : Object) (o : Obj) :
    (r.subst θ).Holds ν C R o ↔ r.Holds (Owned.Annotated.nextValuation θ ν) C R o := by
  cases r <;> simp only [Object.subst]
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | exact (Config.holds_subst θ _ _).mp (by assumption)
    | exact (Config.holds_subst θ _ _).mpr (by assumption)
    | exact (Closure.holds_subst θ _ _).mp (by assumption)
    | exact (Closure.holds_subst θ _ _).mpr (by assumption)

def Object.rename (K : Ren) : Object → Object
  | .vec ns => .vec (ns.map K.node)
  | .closure c => .closure (c.rename K)
  | o => o

theorem Object.holds_rename {ν : Nat → F64} {C : CSrv}
    (R K : Ren) (r : Object) (o : Obj) :
    (r.rename K).Holds ν C R o ↔ r.Holds ν C (Owned.Annotated.composeResources R K) o := by
  cases r <;> simp only [Object.rename]
  case vec ns =>
    constructor <;> intro h <;> cases h
    · simpa only [List.map_map,Function.comp_def,Owned.Annotated.composeResources] using
        (Object.Holds.vec (ν := ν) (C := C) (R := Owned.Annotated.composeResources R K) ns)
    · simpa only [List.map_map,Function.comp_def,Owned.Annotated.composeResources] using
        (Object.Holds.vec (ν := ν) (C := C) (R := R) (ns.map K.node))
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | assumption
    | exact (Closure.holds_rename R K _ _).mp (by assumption)
    | exact (Closure.holds_rename R K _ _).mpr (by assumption)

theorem Object.rebase {ν : Nat → F64} {C : CSrv}
    (R K : Ren) (θ : Nat → SymE) (r : Object) (o : Obj) :
    ((r.rename K).subst θ).Holds ν C R o ↔
      r.Holds (Owned.Annotated.nextValuation θ ν) C (Owned.Annotated.composeResources R K) o := by
  rw [Object.holds_subst,Object.holds_rename]

theorem ObjectRel.mono {roles : Nat → Object} {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren}
    {i : Nat} {o₀ o : Obj} (h : ObjectRel roles ν₀ ν C₀ C R i o₀ o)
    (he₀ : TableExtends C₀ D₀) (he : TableExtends C D) : ObjectRel roles ν₀ ν D₀ D R i o₀ o :=
  ⟨h.source.mono he₀,h.target.mono he⟩

end Host.Mlx.Ffi.Annotated
