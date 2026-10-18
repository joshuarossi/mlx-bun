import host.load.Growth
import host.ts.ast.inference.models.qwen.Qwen3827bTrellisM1max
import host.ts.ast.mlx.Ops

namespace Host.Load.CacheBoundary
open Host.Ts

/-- The complete repository method, including all 64 layer calls. -/
def runMethod : Option Func :=
  Sources.Inference.Models.Qwen.Qwen3827bTrellisM1max.ast.findSome? fun item =>
    let statement := match item with
      | .stmt s | .export_ s => some s
      | _ => none
    statement.bind fun s => match s with
      | .cls (.mk (some name) _ members) =>
        if nameEq name chars!"Qwen38TrellisM1Max" then members.findSome? fun m => match m with
          | .method false .method (.priv key) f =>
            if nameEq key chars!"run" then some f else none
          | _ => none
        else none
      | _ => none

structure Roots where
  method : Nat
  body : Func
  model : Nat
  layerArray : Val
  cacheArray : Val
  phase : Val
  scope : Val
  layers : List Val
  caches : List Val
  hidden : Extract.Tensor

def roots (s : St LSt) : Option Roots := do
  let .call (.obj method) (.obj model) [layerArray, cacheArray, phase, scope] := s.ctl | none
  let o ← s.obj? method
  let .fn (.closure body _ _ _) := o.kind | none
  pure ⟨method, body, model, layerArray, cacheArray, phase, scope,
    ← Extract.elements s layerArray, ← Extract.elements s cacheArray,
    ← (Extract.privateField s scope chars!"hidden").bind (Extract.tensor s)⟩

def isRunCall (s : St LSt) : Bool :=
  match roots s with
  | some r => runMethod == some r.body
  | none => false

def itemMethod : Option Func :=
  Sources.Mlx.Ops.ast.findSome? fun item =>
    match item with
    | .export_ (.func (.mk (some name) params rest body a g props)) =>
      if nameEq name chars!"itemUint32" then some (.mk (some name) params rest body a g props) else none
    | _ => none

def isItemCall (s : St LSt) : Bool :=
  match s.ctl with
  | .call (.obj method) _ [_] => match s.obj? method with
    | some o => match o.kind with
      | .fn (.closure body _ _ _) => itemMethod == some body
      | _ => false
    | none => false
  | _ => false

/-- Structural form of the selected source callee, used in kernel-facing
boundary projections without executing the derived recursive AST equality. -/
def calledBody (s : St LSt) : Option Func := do
  let .call (.obj method) _ [_] := s.ctl | none
  let o ← s.obj? method
  let .fn (.closure body _ _ _) := o.kind | none
  pure body

def itemInput (s : St LSt) : Option Extract.Tensor := do
  let .call (.obj _) _ [arg] := s.ctl | none
  Extract.tensor s arg

/-- Entry specialization only. A caller must separately prove reachability
and incoming cache contents at the desired position. -/
def atOffsets (s : St LSt) (caches : List Val) (position : Nat) : St LSt :=
  caches.foldl (fun s value => match value with
    | .obj address => Growth.atOffset s address position
    | _ => s) s

def cacheGeometry (position capacity : Nat) (c : Extract.Cache) : Bool :=
  c.offset == position &&
  if nameEq c.operation chars!"KVCache" then
    match c.first, c.second with
    | some key, some value =>
      key.value.dtype == 12 && value.value.dtype == 12 &&
      key.value.shape == [1,4,capacity,256].map Host.Mlx.Ffi.Dim.lit &&
      value.value.shape == [1,4,capacity,256].map Host.Mlx.Ffi.Dim.lit
    | _, _ => false
  else nameEq c.operation chars!"SSMCache" && c.first.isSome && c.second.isSome

def EntryAt (s : St LSt) (r : Roots) (position capacity : Nat) : Prop :=
  roots s = some r ∧ runMethod = some r.body ∧
  r.layers.length = 64 ∧ r.caches.length = 64 ∧ r.phase = .str chars!"decode" ∧
  ((Extract.privateField s (.obj r.model) chars!"one").bind (Extract.elements s)) = some r.layers ∧
  Growth.tensorHeader r.hidden [1,1,5120] ∧
  ∃ caches, r.caches.mapM (Extract.cache s) = some caches ∧
    caches.all (cacheGeometry position capacity) = true ∧
    (caches.filter fun c => nameEq c.operation chars!"KVCache").length = 16

structure Outcome where
  hidden : Extract.Tensor
  caches : List Extract.Cache

def outcome (s : St LSt) (r : Roots) : Option Outcome := do
  let .ret value := s.ctl | none
  pure ⟨← Extract.tensor s value, ← r.caches.mapM (Extract.cache s)⟩

end Host.Load.CacheBoundary
