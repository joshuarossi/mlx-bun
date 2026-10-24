import host.sim.world.LF
import host.load.nat.Core
import host.sim.extract.CacheEnd
import host.sim.native.gen.Rel
import host.load.CacheValues
namespace Host.Ts.Sim
open Host.Ts Host.Load.Extract

/-! # The program's caches over a world

`Host.Ts.Sim.ExtractSim.cachesT` (the `cache` binding's caches, offsets dropped) over any FFI state
type, its tensors read through a projection `mx` to the mlx state (`cachesTW`; `privateFieldW`,
`classNameW`, `tensorW`, `optionalTensorW`, `slotValW`, `cacheTW`), and under the relation with
frames `W` (`RelB.cachesTW_end`): at a fixed, unframed binding cell, with the cache list unframed in
the end context and every object and cell the extraction reads outside `W`'s domain `wl` and no
array but the list (`cachesOkWB`, a kernel check of the source), and the general native relation
at the mlx states (`G.MRw`), the target's caches extract to the source's with their tensor nodes'
images (`cacheRW_nodes`). -/

section Defs
variable {S : Type}

/-- `Extract.privateField` over any state. -/
def privateFieldW (s : St S) (v : Val) (n : List Char) : Option Val :=
  (objectW s v).bind fun o => ExtractSim.pick n o.priv

/-- `ExtractSim.ctorName` over any state. -/
def ctorNameW (s : St S) (c : Nat) : Option (List Char) :=
  (s.obj? c).bind fun co => match co.kind with
    | .fn (.klass _ ((n, cell) :: _) _ _) => match s.cell? cell with
      | some (some (.obj d)) => bif Nat.beq c d then some n else none
      | _ => none
    | _ => none

/-- `Extract.className` over any state. -/
def classNameW (s : St S) (v : Val) : Option (List Char) :=
  (objectW s v).bind fun o => (ownW s o.proto chars!"constructor").bind fun cv => match cv with
    | .obj c => ctorNameW s c
    | _ => none

/-- `Extract.tensor` over any state, the native state read through `mx`. -/
def tensorW (mx : S → Host.Mlx.Ffi.St) (s : St S) (v : Val) : Option Tensor :=
  ((privateFieldW s v chars!"handle").bind nat).bind fun h =>
    ((mx s.ffi).nodeId? h).bind fun i => ((mx s.ffi).nodes.get i).map fun nd => (⟨h, i, nd⟩ : Tensor)

def optionalTensorW (mx : S → Host.Mlx.Ffi.St) (s : St S) : Val → Option (Option Tensor)
  | .null => some none
  | v => (tensorW mx s v).map some

/-- A cache slot's value (`conv`/`keys`, `recurrent`/`values`). -/
def slotValW (s : St S) (v : Val) (p o : List Char) : Option Val :=
  (privateFieldW s v p).orElse fun _ => ownW s v o

/-- `ExtractSim.cacheT` over any state. -/
def cacheTW (mx : S → Host.Mlx.Ffi.St) (s : St S) (v : Val) : Option Cache :=
  (classNameW s v).bind fun cls => ((slotValW s v chars!"conv" chars!"keys").bind (optionalTensorW mx s)).bind
    fun first => ((slotValW s v chars!"recurrent" chars!"values").bind (optionalTensorW mx s)).bind
      fun second => some ⟨cls, 0, first, second⟩

/-- **The program's caches** (`ExtractSim.cachesT` over any state): the `cache` binding's caches. -/
def cachesTW (mx : S → Host.Mlx.Ffi.St) (s : St S) (env : Env) : Option (List Cache) :=
  ((bindingOf s env chars!"cache").bind (elementsW s)).bind (List.mapM (cacheTW mx s))

/-! ### The kernel check of the source -/

def isArrayB : Kind → Bool
  | .array _ => true
  | _ => false

/-- An object the extraction reads: outside `wl`, no array. -/
def okObjB (s : St S) (wl : List Nat) : Val → Bool
  | .obj a => !(wl.contains a) && match s.obj? a with
    | some o => !(isArrayB o.kind)
    | none => true
  | _ => true

/-- A tensor slot: its value an object the extraction reads, its handle no number. -/
def slotOkWB (s : St S) (wl : List Nat) (v : Val) (p o : List Char) : Bool :=
  match slotValW s v p o with
  | some w => okObjB s wl w && match privateFieldW s w chars!"handle" with
    | some (.num _) => false
    | _ => true
  | none => true

/-- A constructor: an object the extraction reads, its class name's cell outside `wl`. -/
def ctorOkB (s : St S) (wl : List Nat) (c : Nat) : Bool :=
  okObjB s wl (.obj c) && match s.obj? c with
    | some co => match co.kind with
      | .fn (.klass _ ((_, cell) :: _) _ _) => match s.cell? cell with
        | some _ => !(wl.contains cell)
        | none => false
      | _ => true
    | none => true

/-- A cache object, its prototype and constructor, and its two slots. -/
def cacheOkWB (s : St S) (wl : List Nat) (v : Val) : Bool :=
  okObjB s wl v && (match objectW s v with
    | some o => okObjB s wl o.proto && match ownW s o.proto chars!"constructor" with
      | some (.obj c) => ctorOkB s wl c
      | _ => true
    | none => true) &&
  slotOkWB s wl v chars!"conv" chars!"keys" && slotOkWB s wl v chars!"recurrent" chars!"values"

/-- **The kernel check of the source's caches**: the cache list outside `wl`, and every cache. -/
def cachesOkWB (s : St S) (env : Env) (wl : List Nat) : Bool :=
  match bindingOf s env chars!"cache" with
  | some (.obj aL) => !(wl.contains aL) && match elementsW s (.obj aL) with
    | some es => es.all (cacheOkWB s wl)
    | none => true
  | _ => true

end Defs

/-! ## Tensors and caches under the map -/

/-- Related tensors: the handle's and the node's images. -/
def TensorRW (M : Map) (T T' : Tensor) : Prop := T'.handle = M.handle T.handle ∧ T'.node = M.node T.node

/-- Related caches: the same operation, related tensors. -/
def CacheRW (M : Map) (c c' : Cache) : Prop :=
  c'.operation = c.operation ∧ ExtractSim.ORel (TensorRW M) c.first c'.first ∧
    ExtractSim.ORel (TensorRW M) c.second c'.second

theorem oRelW_node {M : Map} :
    ∀ {T T' : Option Tensor}, ExtractSim.ORel (TensorRW M) T T' → T'.map Tensor.node = (T.map Tensor.node).map M.node
  | none, none, _ => rfl
  | some _, some _, h => by simp only [Option.map_some]; rw [h.2]
  | none, some _, h => h.elim
  | some _, none, h => h.elim

theorem cacheRW_nodes {M : Map} :
    ∀ {cs cs' : List Cache}, ExtractSim.LRel (CacheRW M) cs cs' →
      cs'.map ExtractSim.nodePair = (cs.map ExtractSim.nodePair).map fun p => (p.1.map M.node, p.2.map M.node)
  | [], [], _ => rfl
  | c :: cs, c' :: cs', ⟨hc, hr⟩ => by
    simp only [List.map_cons, ExtractSim.nodePair]
    rw [oRelW_node hc.2.1, oRelW_node hc.2.2, cacheRW_nodes hr]
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

section Rel
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {wl : List Nat}

/-- An object at a framed address outside `W` is a framed array: a non-array outside `W` is unframed. -/
theorem RelB.fr_none_of (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o)
    (hw : W a = none) (hna : isArrayB o.kind = false) : K.fr a = none := by
  cases hfr : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨o', _, hfo⟩ := h.obj?_framed ho hfr hw
    obtain ⟨xs, hk, -⟩ := hfo
    rw [hk] at hna
    cases hna

theorem w_none_of {a : Nat} (hW : ∀ a w, W a = some w → a ∈ wl) (hn : wl.contains a = false) : W a = none := by
  cases hwa : W a with
  | none => rfl
  | some w =>
    have := List.contains_iff_mem.mpr (hW a w hwa)
    rw [hn] at this
    cases this

/-- **An object the extraction reads has the image**, outside `W` and no array. -/
theorem RelB.obj_okW (h : RelB F FR W stk M ν K s S t C) (hW : ∀ a w, W a = some w → a ∈ wl) {a : Nat} {o : Obj}
    (hok : okObjB s wl (.obj a) = true) (ho : s.obj? a = some o) :
    W a = none ∧ t.obj? (M.a a) = some (M.obj o) := by
  simp only [okObjB, ho, Bool.and_eq_true, Bool.not_eq_true'] at hok
  have hw := w_none_of hW hok.1
  exact ⟨hw, h.obj? ho (h.fr_none_of ho hw hok.2)⟩

theorem RelB.privateFieldW_img (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj} (ho : s.obj? a = some o)
    (ht : t.obj? (M.a a) = some (M.obj o)) (n : List Char) :
    privateFieldW t (.obj (M.a a)) n = (privateFieldW s (.obj a) n).map M.val := by
  show (t.obj? (M.a a)).bind (fun o => ExtractSim.pick n o.priv) =
    ((s.obj? a).bind (fun o => ExtractSim.pick n o.priv)).map M.val
  rw [ht, ho]
  exact ExtractSim.pick_map n o.priv

theorem RelB.privateFieldW_supp (h : RelB F FR W stk M ν K s S t C) {a : Nat} {n : List Char} {w : Val}
    (hw : privateFieldW s (.obj a) n = some w) : Supp.val (Present s) S.tab.length w := by
  change (s.obj? a).bind (fun o => ExtractSim.pick n o.priv) = some w at hw
  cases ho : s.obj? a with
  | none => rw [ho] at hw; cases hw
  | some o =>
    rw [ho] at hw
    exact ExtractSim.pick_supp (h.obj?_supp ho).2.2.2 hw

theorem RelB.beq_mapW (h : RelB F FR W stk M ν K s S t C) {a b : Nat} (ha : Present s a) (hb : Present s b) :
    Nat.beq (M.a a) (M.a b) = Nat.beq a b := by
  cases e : Nat.beq a b with
  | true => rw [Nat.eq_of_beq_eq_true e, Nat.beq_refl]
  | false =>
    cases e' : Nat.beq (M.a a) (M.a b) with
    | false => rfl
    | true =>
      have := h.inj a b ha hb (Nat.eq_of_beq_eq_true e')
      subst this
      rw [Nat.beq_refl] at e
      cases e

/-- **A constructor's class name under the map.** -/
theorem RelB.ctorNameW_map (h : RelB F FR W stk M ν K s S t C) (hW : ∀ a w, W a = some w → a ∈ wl) {c : Nat}
    (hc : Present s c) (hok : ctorOkB s wl c = true) : ctorNameW t (M.a c) = ctorNameW s c := by
  have hok' := hok
  simp only [ctorOkB, Bool.and_eq_true] at hok'
  have hwc : W c = none := by
    have h1 := hok'.1
    simp only [okObjB, Bool.and_eq_true, Bool.not_eq_true'] at h1
    exact w_none_of hW h1.1
  unfold ctorNameW
  cases hco : s.obj? c with
  | none => rw [h.obj?_noneW hc hco hwc]; rfl
  | some co =>
    obtain ⟨-, ht⟩ := h.obj_okW hW hok'.1 hco
    rw [ht]
    simp only [Option.bind_some]
    have hsk := (h.obj?_supp hco).1
    have hk2 := hok'.2
    rw [hco] at hk2
    dsimp only at hk2
    revert hsk hk2
    show Supp.kind (Present s) S.tab.length co.kind → _ →
      (match M.kind co.kind with
        | .fn (.klass _ ((n, cell) :: _) _ _) => match t.cell? cell with
          | some (some (.obj d)) => bif Nat.beq (M.a c) d then some n else none
          | _ => none
        | _ => none) = _
    cases co.kind with
    | fn cd =>
      cases cd with
      | klass ctor env par inst =>
        cases env with
        | nil => intro _ _; rfl
        | cons p rest =>
          obtain ⟨nm, cell⟩ := p
          intro hsk hk2
          dsimp only at hk2
          have hpc : Present s cell := hsk.1 _ (List.mem_cons_self ..)
          show (match t.cell? (M.a cell) with
            | some (some (.obj d)) => bif Nat.beq (M.a c) d then some nm else none
            | _ => none) = (match s.cell? cell with
            | some (some (.obj d)) => bif Nat.beq c d then some nm else none
            | _ => none)
          cases hcl : s.cell? cell with
          | none => rw [hcl] at hk2; simp at hk2
          | some w =>
            rw [hcl] at hk2
            have hk3 : wl.contains cell = false := by simpa using hk2
            rw [h.cell? hcl (.inl (w_none_of hW hk3))]
            cases w with
            | none => rfl
            | some x =>
              cases x with
              | obj d =>
                have hpd : Present s d := h.cell?_supp hcl
                show (bif Nat.beq (M.a c) (M.a d) then some nm else none) = _
                rw [h.beq_mapW hc hpd]
              | _ => rfl
      | _ => intro _ _; rfl
    | _ => intro _ _; rfl

/-- **A cache object's class name under the map.** -/
theorem RelB.classNameW_map (h : RelB F FR W stk M ν K s S t C) (hW : ∀ a w, W a = some w → a ∈ wl) {a : Nat}
    {o : Obj} (ho : s.obj? a = some o) (ht : t.obj? (M.a a) = some (M.obj o))
    (hok : okObjB s wl o.proto && (match ownW s o.proto chars!"constructor" with
      | some (.obj c) => ctorOkB s wl c
      | _ => true) = true) :
    classNameW t (.obj (M.a a)) = classNameW s (.obj a) := by
  show (t.obj? (M.a a)).bind (fun o => (ownW t o.proto chars!"constructor").bind fun cv => match cv with
      | .obj c => ctorNameW t c
      | _ => none) =
    (s.obj? a).bind (fun o => (ownW s o.proto chars!"constructor").bind fun cv => match cv with
      | .obj c => ctorNameW s c
      | _ => none)
  rw [ht, ho]
  simp only [Option.bind_some]
  show (ownW t (M.val o.proto) chars!"constructor").bind _ = (ownW s o.proto chars!"constructor").bind _
  simp only [Bool.and_eq_true] at hok
  cases hpr : o.proto with
  | obj pa =>
    rw [hpr] at hok
    have hpa : Present s pa := by have := (h.obj?_supp ho).2.1; rw [hpr] at this; exact this
    have hwpa : W pa = none := by
      simp only [okObjB, Bool.and_eq_true, Bool.not_eq_true'] at hok
      exact w_none_of hW hok.1.1
    show (ownW t (.obj (M.a pa)) chars!"constructor").bind _ = _
    rw [h.ownW_map hpa hwpa]
    cases hcn : ownW s (.obj pa) chars!"constructor" with
    | none => rfl
    | some cv =>
      simp only [Option.map_some, Option.bind_some]
      cases cv with
      | obj c =>
        rw [hcn] at hok
        exact h.ctorNameW_map hW (h.ownW_supp hcn) hok.2
      | _ => rfl
  | _ => rfl

/-- **A tensor under the map** (`ExtractSim.tensor_rel` over a world): its handle a bigint, the general
native relation at the mlx states. -/
theorem RelB.tensorW_rel (h : RelB F FR W stk M ν K s S t C) {mx : F.S → Host.Mlx.Ffi.St} {P : LoadP} {NB n : Nat}
    (hm : G.MRw P NB M n (mx s.ffi) (mx t.ffi)) {a : Nat} {o : Obj} (ho : s.obj? a = some o)
    (ht : t.obj? (M.a a) = some (M.obj o))
    (hb : ∀ w, privateFieldW s (.obj a) chars!"handle" = some w → ∀ x, w ≠ .num x) {T : Tensor}
    (hT : tensorW mx s (.obj a) = some T) : ∃ T', tensorW mx t (.obj (M.a a)) = some T' ∧ TensorRW M T T' := by
  unfold tensorW at hT ⊢
  rw [h.privateFieldW_img ho ht]
  cases hpf : privateFieldW s (.obj a) chars!"handle" with
  | none => rw [hpf] at hT; cases hT
  | some w =>
    rw [hpf] at hT
    simp only [Option.bind_some, Option.map_some] at hT ⊢
    cases w with
    | big i =>
      cases i with
      | ofNat hh =>
        simp only [nat, Option.bind_some] at hT
        cases hid : (mx s.ffi).nodeId? hh with
        | none => rw [hid] at hT; cases hT
        | some i =>
          rw [hid] at hT
          simp only [Option.bind_some] at hT
          cases hnd : (mx s.ffi).nodes.get i with
          | none => rw [hnd] at hT; cases hT
          | some nd =>
            rw [hnd] at hT
            simp only [Option.map_some, Option.some.injEq] at hT
            subst hT
            have h0 : Nat.beq hh 0 = false := by
              cases e : Nat.beq hh 0
              · rfl
              · simp [Host.Mlx.Ffi.St.nodeId?, e] at hid
            have harr : (mx s.ffi).arrs.get hh = some i := by
              simpa [Host.Mlx.Ffi.St.nodeId?, h0] using hid
            have hph : PH (mx s.ffi) hh := .inl (by rw [harr]; rfl)
            obtain ⟨hbig, _, _⟩ := hm.present hh hph
            have himg := (hm.himg hh hph).1
            have hy : (mx t.ffi).arrs.get (M.handle hh) = some (M.node i) := by
              rw [hm.arrs hh hph, harr]; rfl
            obtain ⟨nd', hnd', -⟩ := hm.nodes i nd hnd
            have h0' : Nat.beq (M.handle hh) 0 = false := by
              cases e : Nat.beq (M.handle hh) 0
              · rfl
              · rw [Nat.eq_of_beq_eq_true e] at himg; omega
            refine ⟨⟨M.handle hh, M.node i, nd'⟩, ?_, rfl, rfl⟩
            have hv' : M.val (.big (Int.ofNat hh)) = .big (Int.ofNat (M.handle hh)) := by
              show Val.big (M.big (Int.ofNat hh)) = _; rw [hbig]
            have hid' : (mx t.ffi).nodeId? (M.handle hh) = some (M.node i) := by
              simp only [Host.Mlx.Ffi.St.nodeId?, h0', Bool.cond_false]; exact hy
            rw [hv']
            simp only [nat, Option.bind_some, hid', hnd', Option.map_some]
      | negSucc _ => simp [nat] at hT
    | num x => exact absurd rfl (hb _ hpf x)
    | _ => simp [nat] at hT

/-- **A cache slot's tensor under the map.** -/
theorem RelB.slotW_rel (h : RelB F FR W stk M ν K s S t C) (hW : ∀ a w, W a = some w → a ∈ wl)
    {mx : F.S → Host.Mlx.Ffi.St} {P : LoadP} {NB n : Nat} (hm : G.MRw P NB M n (mx s.ffi) (mx t.ffi))
    {a : Nat} {o : Obj} (ho : s.obj? a = some o) (ht : t.obj? (M.a a) = some (M.obj o)) (hp : Present s a)
    (hw : W a = none) {p q : List Char} (hok : slotOkWB s wl (.obj a) p q = true) {T : Option Tensor}
    (hs : (slotValW s (.obj a) p q).bind (optionalTensorW mx s) = some T) :
    ∃ T', (slotValW t (.obj (M.a a)) p q).bind (optionalTensorW mx t) = some T' ∧ ExtractSim.ORel (TensorRW M) T T' := by
  have hsv : slotValW t (.obj (M.a a)) p q = (slotValW s (.obj a) p q).map M.val := by
    unfold slotValW
    rw [h.privateFieldW_img ho ht, h.ownW_map hp hw]
    cases privateFieldW s (.obj a) p <;> rfl
  rw [hsv]
  cases hx : slotValW s (.obj a) p q with
  | none => rw [hx] at hs; cases hs
  | some w =>
    rw [hx] at hs
    simp only [Option.bind_some] at hs
    simp only [Option.map_some, Option.bind_some]
    simp only [slotOkWB, hx, Bool.and_eq_true] at hok
    cases w with
    | null => cases hs; exact ⟨none, rfl, trivial⟩
    | obj b =>
      cases hb : s.obj? b with
      | none =>
        have : tensorW mx s (.obj b) = none := by
          unfold tensorW privateFieldW; simp [objectW, hb]
        simp only [optionalTensorW, this, Option.map_none] at hs
        cases hs
      | some ob =>
        obtain ⟨-, htb⟩ := h.obj_okW hW hok.1 hb
        have hbig : ∀ w, privateFieldW s (.obj b) chars!"handle" = some w → ∀ x, w ≠ .num x := by
          intro w hw' x hx'
          rw [hw', hx'] at hok
          simp at hok
        simp only [optionalTensorW] at hs ⊢
        cases hT : tensorW mx s (.obj b) with
        | none => rw [hT] at hs; cases hs
        | some T0 =>
          rw [hT] at hs
          cases hs
          obtain ⟨T', h1, h2⟩ := h.tensorW_rel hm hb htb hbig hT
          exact ⟨some T', by show (tensorW mx t (.obj (M.a b))).map some = _; rw [h1]; rfl, h2⟩
    | _ =>
      simp only [optionalTensorW, tensorW, privateFieldW, objectW, Option.bind_none, Option.map_none] at hs
      cases hs

/-- **A source cache's image extracts on the target** (`ExtractSim.cacheT_exists` over a world). -/
theorem RelB.cacheTW_rel (h : RelB F FR W stk M ν K s S t C) (hW : ∀ a w, W a = some w → a ∈ wl)
    {mx : F.S → Host.Mlx.Ffi.St} {P : LoadP} {NB n : Nat} (hm : G.MRw P NB M n (mx s.ffi) (mx t.ffi))
    {v : Val} (hv : Supp.val (Present s) S.tab.length v) (hok : cacheOkWB s wl v = true) {c : Cache}
    (hs : cacheTW mx s v = some c) : ∃ c', cacheTW mx t (M.val v) = some c' ∧ CacheRW M c c' := by
  cases v with
  | obj a =>
    cases ho : s.obj? a with
    | none =>
      exfalso
      unfold cacheTW classNameW at hs
      simp [objectW, ho] at hs
    | some o =>
      simp only [cacheOkWB, Bool.and_eq_true] at hok
      obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := hok
      obtain ⟨hw, ht⟩ := h.obj_okW hW h1 ho
      have h2' : (okObjB s wl o.proto && (match ownW s o.proto chars!"constructor" with
          | some (.obj c) => ctorOkB s wl c
          | _ => true)) = true := by
        rw [show objectW s (.obj a) = some o from ho] at h2; exact h2
      have hcls := h.classNameW_map hW ho ht h2'
      unfold cacheTW at hs ⊢
      rw [show M.val (.obj a) = .obj (M.a a) from rfl, hcls]
      cases hcn : classNameW s (.obj a) with
      | none => rw [hcn] at hs; cases hs
      | some cls =>
        rw [hcn] at hs
        simp only [Option.bind_some] at hs ⊢
        cases hf : (slotValW s (.obj a) chars!"conv" chars!"keys").bind (optionalTensorW mx s) with
        | none => rw [hf] at hs; cases hs
        | some f =>
          rw [hf] at hs
          simp only [Option.bind_some] at hs
          cases hsc : (slotValW s (.obj a) chars!"recurrent" chars!"values").bind (optionalTensorW mx s) with
          | none => rw [hsc] at hs; cases hs
          | some sc =>
            rw [hsc] at hs
            simp only [Option.bind_some, Option.some.injEq] at hs
            subst hs
            obtain ⟨f', hf', rf⟩ := h.slotW_rel hW hm ho ht hv hw h3 hf
            obtain ⟨sc', hsc', rsc⟩ := h.slotW_rel hW hm ho ht hv hw h4 hsc
            rw [hf']
            simp only [Option.bind_some]
            rw [hsc']
            exact ⟨_, rfl, rfl, rf, rsc⟩
  | _ =>
    exfalso
    unfold cacheTW classNameW at hs
    simp [objectW] at hs

/-- **The target's cache binding extracts to the source caches' images** (`ExtractSim.cachesT_end`
over a world): at a fixed binding cell outside `W`, the cache list unframed, the source checked
(`cachesOkWB`), the general native relation at the mlx states. -/
theorem RelB.cachesTW_end (h : RelB F FR W stk M ν K s S t C) (hW : ∀ a w, W a = some w → a ∈ wl)
    {mx : F.S → Host.Mlx.Ffi.St} {P : LoadP} {NB n : Nat} (hm : G.MRw P NB M n (mx s.ffi) (mx t.ffi))
    {env : Env} {cc aL : Nat} (hcc : lookupEnv chars!"cache" env = some cc) (hfix : M.a cc = cc)
    (hwc : W cc = none) (hcell : s.cell? cc = some (some (.obj aL))) (hfr : K.fr aL = none)
    (hok : cachesOkWB s env wl = true) {cs : List Cache} (hs : cachesTW mx s env = some cs) :
    ∃ cs', cachesTW mx t env = some cs' ∧ ExtractSim.LRel (CacheRW M) cs cs' := by
  have hbs : bindingOf s env chars!"cache" = some (.obj aL) := by
    unfold bindingOf; rw [hcc, Option.bind_some, hcell]; rfl
  have hbt : bindingOf t env chars!"cache" = some (.obj (M.a aL)) := by
    have := h.cell? hcell (.inl hwc)
    rw [hfix] at this
    unfold bindingOf; rw [hcc, Option.bind_some, this]; rfl
  unfold cachesOkWB at hok
  rw [hbs] at hok
  dsimp only at hok
  unfold cachesTW at hs ⊢
  rw [hbs] at hs
  rw [hbt]
  simp only [Option.bind_some] at hs ⊢
  cases hoL : s.obj? aL with
  | none =>
    exfalso
    have : elementsW s (.obj aL) = none := by simp [elementsW, objectW, hoL]
    rw [this] at hs; cases hs
  | some oL =>
    have htL : t.obj? (M.a aL) = some (M.obj oL) := h.obj? hoL hfr
    have hsk := (h.obj?_supp hoL).1
    have hel : elementsW t (.obj (M.a aL)) = (elementsW s (.obj aL)).map M.vals := by
      show ((t.obj? (M.a aL)).bind fun o => match o.kind with | .array es => some es | _ => none) =
        ((s.obj? aL).bind fun o => match o.kind with | .array es => some es | _ => none).map M.vals
      rw [htL, hoL]
      show (match M.kind oL.kind with | .array es => some es | _ => none) =
        (match oL.kind with | .array es => some es | _ => none).map M.vals
      cases oL.kind <;> rfl
    rw [hel]
    cases he : elementsW s (.obj aL) with
    | none => rw [he] at hs; cases hs
    | some es =>
      rw [he] at hs hok
      simp only [Option.map_some, Option.bind_some] at hs ⊢
      simp only [Bool.and_eq_true] at hok
      have hsup : ∀ v ∈ es, Supp.val (Present s) S.tab.length v := by
        have hk : oL.kind = .array es := by
          have h2 : (match oL.kind with | .array es => some es | _ => none) = some es := by
            have h3 : ((s.obj? aL).bind fun o => match o.kind with | .array es => some es | _ => none) =
                some es := he
            rw [hoL] at h3; exact h3
          revert h2
          cases oL.kind with
          | array xs => intro h2; cases h2; rfl
          | _ => intro h2; cases h2
        rw [hk] at hsk
        exact hsk
      rw [show M.vals es = es.map M.val from rfl, ExtractSim.mapM_map]
      exact ExtractSim.mapM_exists es (fun v hv c hcv =>
        h.cacheTW_rel hW hm (hsup v hv) (List.all_eq_true.mp hok.2 v hv) hcv) hs

end Rel

end Host.Ts.Sim

/-! ## The load world's extraction, and a state with another native part -/

namespace Host.Ts.Sim
open Host.Ts Host.Load.Extract

theorem objectW_lf (s : St Host.Load.LSt) (v : Val) : objectW s v = Host.Load.Extract.object s v := by
  cases v <;> rfl

theorem privateFieldW_lf (s : St Host.Load.LSt) (v : Val) (n : List Char) :
    privateFieldW s v n = Host.Load.Extract.privateField s v n := by
  unfold privateFieldW
  rw [objectW_lf, ExtractSim.privateField_eq]

theorem classNameW_lf (s : St Host.Load.LSt) (v : Val) : classNameW s v = Host.Load.Extract.className s v := by
  unfold classNameW
  rw [objectW_lf, ExtractSim.className_eq]
  simp only [ownW_lf]
  rfl

theorem tensorW_lf (s : St Host.Load.LSt) (v : Val) :
    tensorW (fun x => x.mlx) s v = Host.Load.Extract.tensor s v := by
  rw [ExtractSim.tensor_eq]
  unfold tensorW
  rw [privateFieldW_lf]

theorem optionalTensorW_lf (s : St Host.Load.LSt) (v : Val) :
    optionalTensorW (fun x => x.mlx) s v = Host.Load.Extract.optionalTensor s v := by
  cases v <;> simp only [optionalTensorW, Host.Load.Extract.optionalTensor, tensorW_lf]

/-- **`cacheTW` is `ExtractSim.cacheT` in the load world.** -/
theorem cacheTW_lf (s : St Host.Load.LSt) (v : Val) : cacheTW (fun x => x.mlx) s v = ExtractSim.cacheT s v := by
  have e1 : optionalTensorW (fun x => x.mlx) s = Host.Load.Extract.optionalTensor s := funext (optionalTensorW_lf s)
  have e2 : ∀ p o, slotValW s v p o =
      (Host.Load.Extract.privateField s v p).orElse fun _ => Host.Load.Extract.own s v o := fun p o => by
    unfold slotValW; rw [privateFieldW_lf, ownW_lf]
  unfold cacheTW ExtractSim.cacheT
  rw [classNameW_lf, e2, e2, e1]
  rfl

/-- **`cachesTW` is `ExtractSim.cachesT` in the load world.** -/
theorem cachesTW_lf (s : St Host.Load.LSt) (env : Env) :
    cachesTW (fun x => x.mlx) s env = ExtractSim.cachesT s env := by
  have h1 : elementsW s = Host.Load.Extract.elements s := funext (elementsW_lf s)
  have h2 : cacheTW (fun x => x.mlx) s = ExtractSim.cacheT s := funext (cacheTW_lf s)
  unfold cachesTW ExtractSim.cachesT
  rw [h1, h2]

/-- `cachesTW` reads a state's native part only through `mx`. -/
theorem cachesTW_reFfi {S T : Type} (mx : T → Host.Mlx.Ffi.St) (s : St S) (f : S → T) (env : Env) :
    cachesTW mx (s.reFfi (f s.ffi)) env = cachesTW (fun z => mx (f z)) s env := rfl

end Host.Ts.Sim
