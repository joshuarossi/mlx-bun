import host.sim.extract.Basic
namespace Host.Load.Extract
open Host.Ts Host.Ts.Sim

/-! # Images of extracted data, and tensors under the map

`Tensor.map M` sends a handle to `M.handle`, a node id to `M.node` and the node to
its image (`Node.map`: primitive, inputs and dimensions mapped). The structures
lift it field by field. The target's node at an image id agrees with the image
only on fully corresponding nodes (`NodeR`, `Full`), so `TensorR` relates
extracted tensors and `TensorR` with `Full` gives `Tensor.map`. -/

def Node.map (M : Map) (nd : Host.Mlx.Ffi.Node) : Host.Mlx.Ffi.Node :=
  ⟨M.prim nd.prim, nd.ins.map M.node, M.dims nd.shape, nd.dtype⟩

def Tensor.map (M : Map) (T : Tensor) : Tensor := ⟨M.handle T.handle, M.node T.node, Node.map M T.value⟩

def Linear.map (M : Map) (l : Linear) : Linear :=
  { l with words := l.words.map M, scales := l.scales.map M, biases := l.biases.map (Tensor.map M) }

def Trellis.map (M : Map) (x : Trellis) : Trellis :=
  { x with codes := x.codes.map M, scales := x.scales.map M }

def Mlp.map (M : Map) (m : Mlp) : Mlp :=
  { m with norm := m.norm.map M, gate := m.gate.map M, up := m.up.map M, down := m.down.map M }

def Stage.map (M : Map) (st : Stage) : Stage :=
  ⟨st.attention, st.layerOperation, st.mixerOperation, st.inputNorm.map M,
    st.linears.map (fun p => (p.1, p.2.map M)), st.tensors.map (fun p => (p.1, p.2.map M)), st.mlp.map M⟩

def Model.map (M : Map) (m : Model) : Model :=
  ⟨m.embedding.map (fun p => (p.1, p.2.map M)), m.finalNorm.map M, m.head.map M, m.stages.map (Stage.map M)⟩

/-- Caches keep their (source) offset; their tensors are images. -/
def Cache.map (M : Map) (c : Cache) : Cache :=
  { c with first := c.first.map (Tensor.map M), second := c.second.map (Tensor.map M) }

def Loaded.map (M : Map) (l : Loaded) : Loaded := ⟨l.model.map M, l.cache.map (Cache.map M)⟩

end Host.Load.Extract

namespace Host.Ts.Sim.ExtractSim
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract

/-- Related optional values. -/
def ORel {α β : Type} (R : α → β → Prop) : Option α → Option β → Prop
  | none, none => True
  | some a, some b => R a b
  | _, _ => False

/-- Related lists, elementwise. -/
def LRel {α β : Type} (R : α → β → Prop) : List α → List β → Prop
  | [], [] => True
  | a :: as, b :: bs => R a b ∧ LRel R as bs
  | _, _ => False

/-- An extracted target tensor corresponds to an extracted source tensor. -/
def TensorR (P : LoadP) (M : Map) (T T' : Tensor) : Prop :=
  T'.handle = M.handle T.handle ∧ T'.node = M.node T.node ∧ NodeR P M T.node T.value T'.value

/-- A natural number read by `nat`: kept when below the handle band (fixed bigints or literals). -/
def NatR (P : LoadP) (k k' : Nat) : Prop := k < P.lo → k' = k

theorem TensorR.map_eq {P : LoadP} {M : Map} {T T' : Tensor} (h : TensorR P M T T') (hf : Full P T.node) :
    T' = T.map M := by
  obtain ⟨h1, h2, hs, hd, _, hpi⟩ := h
  obtain ⟨hp, hi⟩ := hpi hf
  obtain ⟨th, tn, ⟨tp, ti, ts, td⟩⟩ := T'
  simp only at h1 h2 hs hd hp hi
  subst h1 h2 hs hd hp hi
  rfl

section
variable {P : LoadP} {r : List NumV} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St LSt} {S : SSrv} {C : CSrv}

/-- The native relation of the states. -/
theorem mr (h : Rel LF (LR P r) M ν K s S t C) : MRw { P with rest := r } M S.tab.length s.ffi.mlx t.ffi.mlx :=
  h.ffi.mlx.toMRw

theorem nat_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} {k k' : Nat} (hs : nat v = some k)
    (ht : nat (M.val v) = some k') : NatR P k k' := by
  intro hlo
  cases v with
  | big i =>
    cases i with
    | ofNat n =>
      simp only [nat, Option.some.injEq] at hs
      subst hs
      have e : M.big (Int.ofNat n) = Int.ofNat n := (mr h).bigFix _ (by simp; omega)
      have ht' : nat (.big (M.big (Int.ofNat n))) = some k' := ht
      rw [e] at ht'
      simpa [nat] using ht'.symm
    | negSucc _ => simp [nat] at hs
  | num x =>
    cases x with
    | lit y =>
      have : nat (M.val (.num (.lit y))) = nat (.num (.lit y)) := rfl
      rw [this, hs] at ht
      exact (Option.some.inj ht).symm
    | ref _ => simp [nat] at hs
  | _ => simp [nat] at hs

theorem tensor_eq (s : St LSt) (v : Val) :
    tensor s v = ((privateField s v chars!"handle").bind nat).bind fun h =>
      (s.ffi.mlx.nodeId? h).bind fun i => (s.ffi.mlx.nodes.get i).map fun nd => (⟨h, i, nd⟩ : Tensor) := by
  unfold tensor
  cases (privateField s v chars!"handle").bind nat with
  | none => rfl
  | some h =>
    simp only [Option.bind_eq_bind, Option.bind_some]
    cases s.ffi.mlx.nodeId? h with
    | none => rfl
    | some i =>
      simp only [Option.bind_some]
      cases s.ffi.mlx.nodes.get i <;> rfl

/-- A tensor whose handle is a bigint (`MlxHandle = bigint`). -/
theorem tensor_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v)
    (hb : ∀ w, privateField s v chars!"handle" = some w → ∀ x, w ≠ .num x) {T : Tensor}
    (hT : tensor s v = some T) : ∃ T', tensor t (M.val v) = some T' ∧ TensorR P M T T' := by
  have hm := mr h
  rw [tensor_eq] at hT ⊢
  rw [privateField_map h hv]
  cases hpf : privateField s v chars!"handle" with
  | none => rw [hpf] at hT; cases hT
  | some w =>
    rw [hpf] at hT
    simp only [Option.bind_some, Option.map_some] at hT ⊢
    cases w with
    | big i =>
      cases i with
      | ofNat hh =>
        simp only [nat, Option.bind_some] at hT
        cases hid : s.ffi.mlx.nodeId? hh with
        | none => rw [hid] at hT; cases hT
        | some i =>
          rw [hid] at hT
          simp only [Option.bind_some] at hT
          cases hnd : s.ffi.mlx.nodes.get i with
          | none => rw [hnd] at hT; cases hT
          | some nd =>
            rw [hnd] at hT
            simp only [Option.map_some, Option.some.injEq] at hT
            subst hT
            have h0 : Nat.beq hh 0 = false := by
              cases e : Nat.beq hh 0
              · rfl
              · simp [Host.Mlx.Ffi.St.nodeId?, e] at hid
            have harr : s.ffi.mlx.arrs.get hh = some i := by
              simpa [Host.Mlx.Ffi.St.nodeId?, h0] using hid
            have hph : PH s.ffi.mlx hh := .inl (by rw [harr]; rfl)
            obtain ⟨hbig, _, _⟩ := hm.present hh hph
            have himg := (hm.himg hh hph).1
            have hy : t.ffi.mlx.arrs.get (M.handle hh) = some (M.node i) := by
              rw [hm.arrs hh hph, harr]; rfl
            obtain ⟨nd', hnd', hR⟩ := hm.nodes i nd hnd
            have h0' : Nat.beq (M.handle hh) 0 = false := by
              cases e : Nat.beq (M.handle hh) 0
              · rfl
              · rw [Nat.eq_of_beq_eq_true e] at himg; omega
            refine ⟨⟨M.handle hh, M.node i, nd'⟩, ?_, rfl, rfl, hR⟩
            have hv' : M.val (.big (Int.ofNat hh)) = .big (Int.ofNat (M.handle hh)) := by
              show Val.big (M.big (Int.ofNat hh)) = _; rw [hbig]
            have hid' : t.ffi.mlx.nodeId? (M.handle hh) = some (M.node i) := by
              simp only [Host.Mlx.Ffi.St.nodeId?, h0', Bool.cond_false]; exact hy
            rw [hv']
            simp only [nat, Option.bind_some, hid', hnd', Option.map_some]
      | negSucc _ => simp [nat] at hT
    | num x => exact absurd rfl (hb _ hpf x)
    | _ => simp [nat] at hT

theorem fieldTensor_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v)
    (hb : ∀ v w, privateField s v chars!"handle" = some w → ∀ x, w ≠ .num x) {n : List Char} {T : Tensor}
    (hT : fieldTensor s v n = some T) : ∃ T', fieldTensor t (M.val v) n = some T' ∧ TensorR P M T T' := by
  unfold fieldTensor at hT ⊢
  rw [own_map h hv]
  cases ho : own s v n with
  | none => rw [ho] at hT; cases hT
  | some w =>
    rw [ho] at hT
    exact tensor_rel h (own_supp h ho) (hb w) hT

theorem optionalTensor_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v)
    (hb : ∀ v w, privateField s v chars!"handle" = some w → ∀ x, w ≠ .num x) {T : Option Tensor}
    (hT : optionalTensor s v = some T) :
    ∃ T', optionalTensor t (M.val v) = some T' ∧ ORel (TensorR P M) T T' := by
  by_cases hn : v = .null
  · subst hn; cases hT; exact ⟨none, rfl, trivial⟩
  · have e1 : optionalTensor s v = (tensor s v).map some := by
      cases v <;> first | rfl | exact absurd rfl hn
    have e2 : optionalTensor t (M.val v) = (tensor t (M.val v)).map some := by
      cases v <;> first | rfl | exact absurd rfl hn
    rw [e1] at hT
    rw [e2]
    cases ht : tensor s v with
    | none => rw [ht] at hT; cases hT
    | some T0 =>
      rw [ht] at hT
      cases hT
      obtain ⟨T', h1, h2⟩ := tensor_rel h hv (hb _) ht
      exact ⟨some T', by rw [h1]; rfl, h2⟩

end
end Host.Ts.Sim.ExtractSim
