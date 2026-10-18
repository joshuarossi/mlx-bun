import host.load.Extract
import host.ts.ast.inference.state.Kv
import host.mlx.GlueKv

namespace Host.Load.Growth
open Host.Ts

/-- The method is selected from the pinned repository AST, rather than copied
into a proof driver. -/
def updateMethod : Option Func :=
  Sources.Inference.State.Kv.ast.findSome? fun item =>
    let statement := match item with
      | .stmt s | .export_ s => some s
      | _ => none
    statement.bind fun s => match s with
      | .cls (.mk (some name) _ members) =>
        if nameEq name chars!"KVCache" then members.findSome? fun m => match m with
          | .method false .method (.id key) f =>
            if nameEq key chars!"updateAndFetch" then some f else none
          | _ => none
        else none
      | _ => none

/-- Addresses and tensor carriers at a method-local source cut. The full
machine state retains the caller stack, captured scope and all other roots. -/
structure Roots where
  method : Nat
  body : Func
  cache : Nat
  key : Val
  value : Val
  oldKey : Extract.Tensor
  oldValue : Extract.Tensor
  newKey : Extract.Tensor
  newValue : Extract.Tensor

def roots (s : St LSt) : Option Roots := do
  let .call (.obj method) (.obj cache) [key, value] := s.ctl | none
  let o ← s.obj? method
  let .fn (.closure f _ _ _) := o.kind | none
  let oldKey ← Extract.fieldTensor s (.obj cache) chars!"keys"
  let oldValue ← Extract.fieldTensor s (.obj cache) chars!"values"
  let newKey ← Extract.tensor s key
  let newValue ← Extract.tensor s value
  pure ⟨method, f, cache, key, value, oldKey, oldValue, newKey, newValue⟩

def isUpdateCall (s : St LSt) : Bool :=
  match roots s with
  | some r => updateMethod == some r.body
  | none => false

/-- A candidate specialization of an entry state. This changes only the
receiver's offset property; it does not establish that the entry is reachable.
The source loop invariant must supply that separate obligation. -/
def atOffset (s : St LSt) (cache offset : Nat) : St LSt :=
  match s.obj? cache with
  | none => s
  | some o => s.setObj cache { o with props := o.props.map fun (key, prop) =>
      if (keyEq key (.str (chars!"offset"))) then
        match prop with
        | .data _ writable enumerable =>
          (key, .data (.num (.lit (F64.ofNat offset))) writable enumerable)
        | _ => (key, prop)
      else (key, prop) }

def tensorHeader (t : Extract.Tensor) (shape : List Nat) : Prop :=
  t.value.dtype = 12 ∧ t.value.shape = shape.map (fun n => Host.Mlx.Ffi.Dim.lit n)

/-- Explicit geometric and source-code obligations at positive-capacity
growth. There is deliberately no assumption that this entry follows from
initialization: the source-level cache invariant must prove that connection. -/
def EntryAt (s : St LSt) (r : Roots) (capacity : Nat) : Prop :=
  roots s = some r ∧
  updateMethod = some r.body ∧
  Extract.className s (.obj r.cache) = some chars!"KVCache" ∧
  Extract.own s (.obj r.cache) chars!"offset" = some (.num (.lit (F64.ofNat capacity))) ∧
  tensorHeader r.oldKey [1, 4, capacity, 256] ∧
  tensorHeader r.oldValue [1, 4, capacity, 256] ∧
  tensorHeader r.newKey [1, 4, 1, 256] ∧
  tensorHeader r.newValue [1, 4, 1, 256]

def Entry (s : St LSt) (r : Roots) : Prop := EntryAt s r 256

def CapacityInvariant (capacity : Nat) : Prop := 0 < capacity ∧ capacity % 256 = 0

/-- The content obligation belongs to the incoming cache invariant, not to
checkpoint assumptions. `eval` is the evaluation of the incoming real graph. -/
def ContentsAt (eval : Nat → Option Host.Mlx.Value) (r : Roots) (capacity : Nat)
    (keys values : Fin 4 → Fin capacity → Fin 256 → Host.Mlx.BF)
    (key value : Fin 4 → Fin 256 → Host.Mlx.BF) : Prop :=
  ∃ oldK oldV k v,
    eval r.oldKey.node = some oldK ∧ eval r.oldValue.node = some oldV ∧
    eval r.newKey.node = some k ∧ eval r.newValue.node = some v ∧
    Host.Mlx.GlueKv.Holds oldK capacity capacity keys ∧
    Host.Mlx.GlueKv.Holds oldV capacity capacity values ∧
    Host.Mlx.Tensor4 k 4 1 256 (fun h _ i => key h i) ∧
    Host.Mlx.Tensor4 v 4 1 256 (fun h _ i => value h i)

def Contents (eval : Nat → Option Host.Mlx.Value) (r : Roots) := ContentsAt eval r 256

structure Outcome where
  offset : Nat
  bufferKey : Extract.Tensor
  bufferValue : Extract.Tensor
  fetchedKey : Extract.Tensor
  fetchedValue : Extract.Tensor

def outcome (s : St LSt) (cache : Nat) : Option Outcome := do
  let .ret pair := s.ctl | none
  let [key, value] ← Extract.elements s pair | none
  let offset ← (Extract.own s (.obj cache) chars!"offset").bind Extract.nat
  pure ⟨offset, ← Extract.fieldTensor s (.obj cache) chars!"keys",
    ← Extract.fieldTensor s (.obj cache) chars!"values",
    ← Extract.tensor s key, ← Extract.tensor s value⟩

end Host.Load.Growth
