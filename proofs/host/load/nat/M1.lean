import host.load.nat.Props
namespace Host.Ts.FfiNat
open Host.Ts
set_option maxHeartbeats 4000000

rel_derive retS
rel_derive_ffi retS
rel_derive typedGet
rel_derive_ffi typedGet
rel_derive ownGet
rel_derive_ffi ownGet
rel_derive getChain
rel_derive_ffi getChain
rel_derive protoOf
rel_derive_ffi protoOf
rel_derive lookup
rel_derive_ffi lookup
rel_derive dataOf
rel_derive_ffi dataOf
rel_derive defineData
rel_derive_ffi defineData

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiReadSim F1 F2]

/-- Data properties defined in order (object spread, `Object.assign`, rest objects). -/
@[rel_simp] theorem foldl_defineData_reFfi (o : Nat) : ∀ (kvs : List (PKey × Val)) (s : St F1.S) (x : F2.S),
    FfiRel.R s.ffi x → kvs.foldl (fun s (k, v) => defineData F2 s o k v) (s.reFfi x) =
      (kvs.foldl (fun s (k, v) => defineData F1 s o k v) s).reFfi x
  | [], _, _, _ => rfl
  | (k, v) :: kvs, s, x, hx => by
    show List.foldl (fun s (k, v) => defineData F2 s o k v) (defineData F2 (s.reFfi x) o k v) kvs =
      (List.foldl (fun s (k, v) => defineData F1 s o k v) (defineData F1 s o k v) kvs).reFfi x
    rw [rel_defineData _ _ s x hx o k v]
    exact foldl_defineData_reFfi o kvs _ x (by rw [rel_defineData_ffi]; exact hx)

end

@[rel_simp] theorem foldl_defineData_ffi (F : Ffi) (o : Nat) : ∀ (kvs : List (PKey × Val)) (s : St F.S),
    (kvs.foldl (fun s (k, v) => defineData F s o k v) s).ffi = s.ffi
  | [], _ => rfl
  | (k, v) :: kvs, s => by
    show (List.foldl (fun s (k, v) => defineData F s o k v) (defineData F s o k v) kvs).ffi = s.ffi
    rw [foldl_defineData_ffi F o kvs]
    exact rel_defineData_ffi F s o k v

rel_derive isArrayAt
rel_derive_ffi isArrayAt
set_option maxHeartbeats 20000000 in
rel_derive jsonLoop
rel_derive_ffi jsonLoop
rel_derive syntaxErr
rel_derive_ffi syntaxErr
rel_derive jsonStep
rel_derive_ffi jsonStep
rel_derive_indep numConc
rel_derive_indep primStr
rel_derive ownKeys
rel_derive_ffi ownKeys
rel_derive dataProps.go
rel_derive_ffi dataProps.go
rel_derive dataProps
rel_derive_ffi dataProps
section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]

/-- The serializer's mutual recursion, on the shared fuel. -/
theorem rel_json_all (s : St F1.S) (x : F2.S) (hx : FfiRel.R s.ffi x) : ∀ f : Nat,
    (∀ v, MR CRel.r (jsonSer F1 s f v) (jsonSer F2 (s.reFfi x) f v)) ∧
    (∀ es, MR CRel.r (jsonItems F1 s f es) (jsonItems F2 (s.reFfi x) f es)) ∧
    (∀ kvs, MR CRel.r (jsonProps F1 s f kvs) (jsonProps F2 (s.reFfi x) f kvs))
  | 0 => ⟨fun v => by unfold jsonSer; rel_auto, fun es => by unfold jsonItems; rel_auto,
      fun kvs => by unfold jsonProps; rel_auto⟩
  | f + 1 => by
    obtain ⟨ih1, ih2, ih3⟩ := rel_json_all s x hx f
    exact ⟨fun v => by unfold jsonSer; rel_auto, fun es => by unfold jsonItems; rel_auto,
      fun kvs => by unfold jsonProps; rel_auto⟩

theorem rel_jsonSer (a0 : St F1.S) (a0_x : F2.S) (a0_hx : FfiRel.R a0.ffi a0_x) (a1 : Nat) (a2 : Val) :
    MR CRel.r (jsonSer F1 a0 a1 a2) (jsonSer F2 (a0.reFfi a0_x) a1 a2) := (rel_json_all a0 a0_x a0_hx a1).1 a2

end

rel_derive viewBytes
rel_derive_ffi viewBytes
rel_derive newTyped
rel_derive_ffi newTyped
rel_derive typedElems
rel_derive_ffi typedElems
rel_derive elemsOf
rel_derive_ffi elemsOf
rel_derive partBytes
rel_derive_ffi partBytes
rel_derive readCStr
rel_derive_ffi readCStr
rel_derive hostN
rel_derive_ffi hostN
rel_derive evLit
rel_derive_ffi evLit
rel_derive_state throwErr
rel_derive_state refErr
rel_derive readProp
rel_derive_ffi readProp
rel_derive readVar
rel_derive_ffi readVar
rel_derive tmplNext
rel_derive_ffi tmplNext
rel_derive arrayNext
rel_derive_ffi arrayNext
rel_derive methodProp
rel_derive_ffi methodProp
rel_derive objNext
rel_derive_ffi objNext
rel_derive defineProp
rel_derive_ffi defineProp

end Host.Ts.FfiNat
