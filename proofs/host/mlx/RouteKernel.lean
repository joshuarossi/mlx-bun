import host.mlx.KernelSources
import host.mlx.KernelPorts
import host.mlx.PrefillKernelSources
import host.mlx.FfiEvalPrefill
namespace Host.Mlx
open Host.Mlx.FfiEval Host.Mlx.PrefillSources

/-! # The route's kernel table

The route's custom kernels are the decode kernels (`Kernel`: names `FfiEval.kernelNames`, bodies
`SourceKernels.sources`, ports `KernelPorts`) and the prefill kernels (`PrefillKernel`: names, bodies and ports
`PrefillSources`). KernelSourceBinding.ts generates both tables from the TypeScript constructors and checks
them; this table only refers to them. `routeKernelOf` reads a name as a route kernel: a decode name as before
(`FfiEval.kernelOf`), else a prefill name.

Resolution over the table (`routeKernelName?`, `ffiGraphR`) is a layer over the decode resolution
(`FfiEval.kernelName?`, `ffiGraphP`): it resolves every kernel object and graph node the decode resolution
does, to the same name and node (`kernelName?_route`, `ffiGraphP_route`), and in addition the prefill kernels'
objects with their bodies (`routeKernelName?_prefill`); on a state none of whose kernel objects resolves to a
prefill kernel the two graphs are equal (`ffiGraphR_decodeOnly`). -/

inductive RouteKernel where
  | decode (k : Kernel)
  | prefill (k : PrefillKernel)
  deriving DecidableEq

def PrefillKernel.all : List PrefillKernel :=
  [.affine3Rows, .affine4Rows, .affineSplitMma, .gateUpCodebookMma, .gateUpMmaWide, .downMmaWide, .downK3iMmaWide,
    .aneTrellisFill, .aneTrellisFillK3i, .aneWriteHalf, .vectorExpand]

theorem PrefillKernel.mem_all (k : PrefillKernel) : k ∈ PrefillKernel.all := by cases k <;> decide

/-- The prefill kernel of a constructor name. -/
def prefillOf (name : List Char) : Option PrefillKernel := PrefillKernel.all.find? (PrefillSources.name · = name)

/-- The route kernel of a constructor name: a decode kernel's name as `FfiEval.kernelOf` reads it, else a
prefill kernel's. -/
def routeKernelOf (name : List Char) : Option RouteKernel :=
  match kernelOf name with
  | some k => some (.decode k)
  | none => (prefillOf name).map .prefill

namespace RouteKernel

def source : RouteKernel → List Char
  | .decode k => SourceKernels.sources.source k
  | .prefill k => PrefillSources.source k

def header : RouteKernel → List Char
  | .decode k => SourceKernels.sources.header k
  | .prefill k => PrefillSources.header k

def inputNames : RouteKernel → List (List Char)
  | .decode k => KernelPorts.inputNames k
  | .prefill k => PrefillSources.inputNames k

def outputNames : RouteKernel → List (List Char)
  | .decode k => KernelPorts.outputNames k
  | .prefill k => PrefillSources.outputNames k

def rowContiguous : RouteKernel → Bool
  | .decode k => KernelPorts.rowContiguous k
  | .prefill k => PrefillSources.rowContiguous k

def atomicOutputs : RouteKernel → Bool
  | .decode k => KernelPorts.atomicOutputs k
  | .prefill k => PrefillSources.atomicOutputs k

end RouteKernel

theorem prefillOf_name {name : List Char} {k : PrefillKernel} (h : prefillOf name = some k) :
    PrefillSources.name k = name := by
  have := List.find?_some h
  simpa using this

theorem prefillOf_self (k : PrefillKernel) : prefillOf (PrefillSources.name k) = some k := by
  cases k <;> decide +kernel

/-- No prefill name is a decode name. -/
theorem kernelOf_prefill (k : PrefillKernel) : kernelOf (PrefillSources.name k) = none := by
  cases k <;> decide +kernel

theorem routeKernelOf_decode {name : List Char} {k : Kernel} (h : kernelOf name = some k) :
    routeKernelOf name = some (.decode k) := by
  simp [routeKernelOf, h]

theorem routeKernelOf_prefill (k : PrefillKernel) : routeKernelOf (PrefillSources.name k) = some (.prefill k) := by
  simp [routeKernelOf, kernelOf_prefill, prefillOf_self]

theorem routeKernelOf_some {name : List Char} {k : RouteKernel} (h : routeKernelOf name = some k) :
    (∃ d, k = .decode d ∧ kernelOf name = some d) ∨ (∃ p, k = .prefill p ∧ PrefillSources.name p = name) := by
  unfold routeKernelOf at h
  split at h
  · rename_i d hd
    exact .inl ⟨d, (Option.some.inj h).symm, hd⟩
  · obtain ⟨p, hp, rfl⟩ := Option.map_eq_some_iff.mp h
    exact .inr ⟨p, rfl, prefillOf_name hp⟩

/-! ## Resolution

As `FfiEval.kernelName?`, parametrized by the decode kernels' bodies `S` (the route's are `SourceKernels.sources`;
the prefill bodies are always `PrefillSources`'). -/

/-- A table kernel's body and header with the decode bodies `S`. -/
def RouteKernel.sourceWith (S : KernelSources) : RouteKernel → List Char
  | .decode k => S.source k
  | .prefill k => PrefillSources.source k

def RouteKernel.headerWith (S : KernelSources) : RouteKernel → List Char
  | .decode k => S.header k
  | .prefill k => PrefillSources.header k

theorem RouteKernel.sourceWith_sources (k : RouteKernel) : k.sourceWith SourceKernels.sources = k.source := by
  cases k <;> rfl

theorem RouteKernel.headerWith_sources (k : RouteKernel) : k.headerWith SourceKernels.sources = k.header := by
  cases k <;> rfl

/-- The route name of FFI kernel object `h`, if its body is the table's for that name. -/
def routeKernelName? (S : KernelSources) (s : Ffi.St) (h : Nat) : Option (List Char) :=
  match s.obj? h with
  | some (.kernel name src hdr _ _) => (routeKernelOf name).bind fun k =>
    if src = k.sourceWith S ∧ hdr = k.headerWith S then some name else none
  | _ => none

/-- **Agreement.** A kernel object the decode resolution names has that name in the table. -/
theorem kernelName?_route {S : KernelSources} {s : Ffi.St} {h : Nat} {name : List Char}
    (hk : kernelName? S s h = some name) : routeKernelName? S s h = some name := by
  unfold kernelName? at hk
  unfold routeKernelName?
  split at hk
  · rename_i nm src hdr nIn nOut ho
    rw [ho]
    simp only at hk ⊢
    cases hkk : kernelOf nm with
    | none => rw [hkk] at hk; cases hk
    | some k =>
      rw [hkk] at hk
      simp only [Option.bind_some] at hk
      rw [routeKernelOf_decode hkk, Option.bind_some]
      exact hk
  · cases hk

/-- A table name that is a decode name resolves as the decode resolution does. -/
theorem routeKernelName?_decode {S : KernelSources} {s : Ffi.St} {h : Nat} {name : List Char}
    (hk : routeKernelName? S s h = some name) (hd : (kernelOf name).isSome) : kernelName? S s h = some name := by
  unfold routeKernelName? at hk
  unfold kernelName?
  split at hk
  · rename_i nm src hdr nIn nOut ho
    rw [ho]
    simp only at hk ⊢
    obtain ⟨k, hkk, hb⟩ := Option.bind_eq_some_iff.mp hk
    have hn : nm = name := by split at hb <;> simp_all
    subst hn
    obtain ⟨d, hd'⟩ := Option.isSome_iff_exists.mp hd
    rw [routeKernelOf_decode hd'] at hkk
    cases hkk
    rw [hd', Option.bind_some]
    exact hb
  · cases hk

/-- A prefill kernel's object, with its body, resolves to its name. -/
theorem routeKernelName?_prefill (S : KernelSources) {s : Ffi.St} {h : Nat} (k : PrefillKernel) {nIn nOut : Nat}
    (ho : s.obj? h = some (.kernel (PrefillSources.name k) (PrefillSources.source k) (PrefillSources.header k) nIn nOut)) :
    routeKernelName? S s h = some (PrefillSources.name k) := by
  unfold routeKernelName?
  rw [ho]
  simp [routeKernelOf_prefill, RouteKernel.sourceWith, RouteKernel.headerWith]

/-- `resolvePrim` only reads kernel names: a name function that extends another resolves every primitive the
other does, to the same primitive. -/
theorem resolvePrim_mono {δ κ : Type} (N : Nums δ) {kn kn' : Nat → Option (List Char)}
    (hk : ∀ h n, kn h = some n → kn' h = some n) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) (r : RPrim δ κ), resolvePrim N kn shape dtype p = some r → resolvePrim N kn' shape dtype p = some r
  | .kernel h c i, r, e => by
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def, Option.bind_eq_some_iff] at e ⊢
    obtain ⟨n, hn, rest⟩ := e
    exact ⟨n, hk h n hn, rest⟩
  | .replayed c p, r, e => by
    simp only [resolvePrim, Option.map_eq_some_iff] at e ⊢
    obtain ⟨q, hq, rfl⟩ := e
    exact ⟨q, resolvePrim_mono N hk shape dtype p q hq, rfl⟩
  | .data _, _, e | .load _ _, _, e | .tracer _, _, e | .zeros, _, e | .arange _ _ _, _, e | .reshape _, _, e
  | .transpose _, _, e | .slice _ _ _, _, e | .sliceUpdate _ _ _, _, e | .sliceDynamic _ _, _, e | .concat _, _, e
  | .unary _, _, e | .binary _, _, e | .astype _, _, e | .contiguous, _, e | .rmsNorm _, _, e
  | .rope _ _ _ _ _, _, e | .sdpa _ _, _, e | .qmm _ _ _ _, _, e | .dequantize _ _ _ _, _, e | .take _, _, e
  | .conv1d _ _ _ _, _, e | .logsumexp _ _, _, e => e

theorem resolvePrimP_mono {κ : Type} (N : Nums Int) {kn kn' : Nat → Option (List Char)}
    (hk : ∀ h n, kn h = some n → kn' h = some n) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) (r : RPrim Int κ), resolvePrimP N kn shape dtype p = some r →
      resolvePrimP N kn' shape dtype p = some r
  | .arange a b c, r, e => e
  | .replayed c p, r, e => by
    simp only [resolvePrimP, Option.map_eq_some_iff] at e ⊢
    obtain ⟨q, hq, rfl⟩ := e
    exact ⟨q, resolvePrimP_mono N hk shape dtype p q hq, rfl⟩
  | .data _, r, e | .load _ _, r, e | .tracer _, r, e | .zeros, r, e | .reshape _, r, e
  | .transpose _, r, e | .slice _ _ _, r, e | .sliceUpdate _ _ _, r, e | .sliceDynamic _ _, r, e | .concat _, r, e
  | .unary _, r, e | .binary _, r, e | .astype _, r, e | .contiguous, r, e | .rmsNorm _, r, e
  | .rope _ _ _ _ _, r, e | .sdpa _ _, r, e | .qmm _ _ _ _, r, e | .dequantize _ _ _ _, r, e | .take _, r, e
  | .conv1d _ _ _ _, r, e | .logsumexp _ _, r, e | .kernel _ _ _, r, e =>
    resolvePrim_mono N hk shape dtype _ r e

/-- The FFI model's graph resolved with the route's kernel table (`resolvePrimP`). -/
def ffiGraphR {κ : Type} (N : Nums Int) (S : KernelSources) (s : Ffi.St) (i : Nat) : Option (RNode Int κ) :=
  (s.nodes.get i).bind (resolveNodeP N (routeKernelName? S s))

/-- **Agreement.** Every node of the decode-resolved graph is a node of the table-resolved graph. -/
theorem ffiGraphP_route {κ : Type} (N : Nums Int) (S : KernelSources) (s : Ffi.St) (i : Nat) (nd : RNode Int κ)
    (h : ffiGraphP N S s i = some nd) : ffiGraphR N S s i = some nd := by
  unfold ffiGraphP at h
  unfold ffiGraphR
  obtain ⟨n, hn, hr⟩ := Option.bind_eq_some_iff.mp h
  rw [hn, Option.bind_some]
  unfold resolveNodeP at hr ⊢
  obtain ⟨p, hp, rfl⟩ := Option.map_eq_some_iff.mp hr
  rw [resolvePrimP_mono N (fun _ _ e => kernelName?_route e) n.shape n.dtype n.prim p hp]
  rfl

/-- An FFI state whose kernel objects the table resolves only to decode kernels. -/
def DecodeOnly (S : KernelSources) (s : Ffi.St) : Prop :=
  ∀ h name, routeKernelName? S s h = some name → (kernelOf name).isSome

/-- **Decode-only states resolve as before**: their table-resolved graph is the decode-resolved graph. -/
theorem ffiGraphR_decodeOnly {κ : Type} (N : Nums Int) {S : KernelSources} {s : Ffi.St} (hd : DecodeOnly S s) :
    ffiGraphR (κ := κ) N S s = ffiGraphP N S s := by
  have hk : routeKernelName? S s = kernelName? S s := by
    funext h
    cases e : routeKernelName? S s h with
    | some name => exact (routeKernelName?_decode e (hd h name e)).symm
    | none =>
      cases e' : kernelName? S s h with
      | none => rfl
      | some name => rw [kernelName?_route e'] at e; cases e
  funext i
  unfold ffiGraphR ffiGraphP
  rw [hk]

end Host.Mlx
