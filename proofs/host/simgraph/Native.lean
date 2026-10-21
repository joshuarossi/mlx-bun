import host.simgraph.Embed
import host.ts.RenameIntegerPacking
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Ts
open Host.Mlx.Ffi (Dim Prim Node Cfg dimOf)

/-! # The template iteration's native state and its instances

The template is a native state `s` of a symbolic run, whose cache-offset
dimensions are numbers of the symbolic server; an iteration is a native
state `t` of the concrete run.

* `symNums cls`: reads `s`'s numbers symbolically. `cls` classifies the
  numbers that are dimensions (`SDim.pos`, `SDim.pos1`, or integer
  literals); words and bytes resolve only when literal.
  `symGraph cls Ks s` is the template graph the kernel matches once.
* `resolvePrim_img`: resolution commutes with a syntactic image of a node
  (numbers, dimensions, bytes and object handles renamed) and a map of the
  resolved dimensions, when the two readings agree.
* `NativeImage σ I D s t`: the nodes of `s` in domain `D` are in `t`, node
  `i` at `σ i` as its image under `I`. The domain `dom base shared` is the
  nodes created since the template began (ids from `base`) and the old nodes
  `shared` the iteration's replayed closures read (compute_g's bf16 zero
  constant); the other old nodes (weights, caches, the fed-back token) need
  not correspond: their values enter as step inputs. `embeds_of_image`: then
  `t`'s concrete graph carries the template's graph on `D`
  (`restrictTo D (symGraph cls Ks s)`) evaluated at offset `n`, whenever
  `s`'s numbers read at the iteration's valuation agree with `t`'s and
  `cls` classifies the offset dimensions correctly there. -/

/-! ## Syntactic images of native nodes -/

/-- A renaming of the native data a node mentions. -/
structure SynImg where
  num : NumV → NumV
  dim : Dim → Dim
  byte : Byte → Byte
  arg : Arg → Arg
  obj : Nat → Nat

def SynImg.id : SynImg := ⟨fun x => x, fun d => d, fun b => b, fun a => a, fun h => h⟩

def cfgI (I : SynImg) (c : Cfg) : Cfg :=
  ⟨c.outs.map fun o => (o.1.map I.dim, o.2), c.grid.map I.num, c.group.map I.num,
    c.ints.map fun t => (t.1, I.num t.2), c.dtypes, c.init.map I.num⟩

def primI (I : SynImg) : Prim → Prim
  | .data bytes => .data (bytes.map I.byte)
  | .load f k => .load f k
  | .tracer i => .tracer i
  | .zeros => .zeros
  | .arange a b c => .arange (I.num a) (I.num b) (I.num c)
  | .reshape s => .reshape (s.map I.dim)
  | .transpose ax => .transpose ax
  | .slice a b c => .slice (a.map I.dim) (b.map I.dim) (c.map I.dim)
  | .sliceUpdate a b c => .sliceUpdate (a.map I.dim) (b.map I.dim) (c.map I.dim)
  | .sliceDynamic ax sz => .sliceDynamic ax (sz.map I.dim)
  | .concat a => .concat a
  | .unary op => .unary op
  | .binary op => .binary op
  | .astype d => .astype d
  | .contiguous => .contiguous
  | .rmsNorm eps => .rmsNorm (I.num eps)
  | .rope d t base scale off => .rope d t (I.arg base) (I.num scale) (I.num off)
  | .sdpa scale m => .sdpa (I.num scale) m
  | .qmm t g b m => .qmm t g b m
  | .dequantize g b m d => .dequantize g b m d
  | .take a => .take a
  | .conv1d a b c d => .conv1d a b c d
  | .logsumexp a k => .logsumexp a k
  | .kernel k c o => .kernel (I.obj k) (cfgI I c) o
  | .replayed c p => .replayed (I.obj c) (primI I p)

/-- The image of a node: its data renamed by `I`, its arguments by `σ`. -/
def nodeI (σ : Nat → Nat) (I : SynImg) (nd : Node) : Node :=
  ⟨primI I nd.prim, nd.ins.map σ, nd.shape.map I.dim, nd.dtype⟩

theorem primI_id (p : Prim) : primI SynImg.id p = p := by
  induction p <;> simp_all [primI, SynImg.id, cfgI]

/-! ## Resolution commutes with images -/

theorem mapM_img {α α' β γ : Type} (f : α → Option β) (g : α' → Option γ) (i : α → α') (h : β → γ)
    (hf : ∀ a b, f a = some b → g (i a) = some (h b)) :
    ∀ (l : List α) (bs : List β), l.mapM f = some bs → (l.map i).mapM g = some (bs.map h)
  | [], bs, e => by simp at e; subst e; rfl
  | a :: l, bs, e => by
    rw [List.mapM_cons] at e
    obtain ⟨b, hb, e⟩ := Option.bind_eq_some_iff.mp e
    obtain ⟨bs', hbs, e⟩ := Option.bind_eq_some_iff.mp e
    cases e
    rw [List.map_cons, List.mapM_cons, hf a b hb, mapM_img f g i h hf l bs' hbs]
    rfl

/-- The rope arguments of a primitive satisfy `A`. -/
def PrimArgs (A : Arg → Prop) : Prim → Prop
  | .rope _ _ b _ _ => A b
  | .replayed _ p => PrimArgs A p
  | _ => True

section
variable {δ δ' κ : Type} (N : Nums δ) (N' : Nums δ') (h : δ → δ') (I : SynImg)
    (kn kn' : Nat → Option (List Char)) (A : Arg → Prop)

/-- How the readings `N` (template) and `N'` (iteration) agree along `I` and `h`
(rope arguments only those satisfying `A`). -/
structure Agree : Prop where
  d : ∀ d y, N.d d = some y → N'.d (I.dim d) = some (h y)
  dim : ∀ x y, N.dim x = some y → N'.dim (I.num x) = some (h y)
  word : ∀ x w, N.word x = some w → N'.word (I.num x) = some w
  byte : ∀ b v, N.byte b = some v → N'.byte (I.byte b) = some v
  arg : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (I.arg a) = some v
  kernel : ∀ k name, kn k = some name → kn' (I.obj k) = some name

variable {N N' h I kn kn' A}

theorem resolveCfg_img (ha : Agree N N' h I kn kn' A) (c : Cfg) (rc : RCfg δ) (hr : resolveCfg N c = some rc) :
    resolveCfg N' (cfgI I c) = some (mapC h rc) := by
  obtain ⟨outs, grid, group, ints, dts, init⟩ := c
  have hO : ∀ o, outs.mapM (fun x => (x.1.mapM N.d).map (·, x.2)) = some o →
      (outs.map fun o => (o.1.map I.dim, o.2)).mapM (fun x => (x.1.mapM N'.d).map (·, x.2)) =
        some (o.map fun o => (o.1.map h, o.2)) :=
    mapM_img _ _ _ _ (fun ⟨s, d⟩ b hb => by
      obtain ⟨ys, hys, rfl⟩ := Option.map_eq_some_iff.mp hb
      simp [mapM_img N.d N'.d I.dim h ha.d s ys hys]) outs
  have hI : ∀ is, ints.mapM (fun x => (N.dim x.2).map (x.1, ·)) = some is →
      (ints.map fun t => (t.1, I.num t.2)).mapM (fun x => (N'.dim x.2).map (x.1, ·)) =
        some (is.map fun t => (t.1, h t.2)) :=
    mapM_img _ _ _ _ (fun ⟨s, v⟩ b hb => by
      obtain ⟨y, hy, rfl⟩ := Option.map_eq_some_iff.mp hb
      simp [ha.dim v y hy]) ints
  cases init with
  | none =>
    simp only [resolveCfg, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def, Option.some.injEq] at hr
    obtain ⟨o, ho, g, hg, gr, hgr, is, his, it, rfl, rfl⟩ := hr
    simp only [resolveCfg, cfgI, Option.bind_eq_bind, hO o ho, mapM_img N.dim N'.dim I.num h ha.dim grid g hg,
      mapM_img N.dim N'.dim I.num h ha.dim group gr hgr, hI is his, Option.map_none, Option.bind_some,
      Option.pure_def]
    rfl
  | some v =>
    simp only [resolveCfg, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def, Option.some.injEq,
      Option.map_eq_some_iff] at hr
    obtain ⟨o, ho, g, hg, gr, hgr, is, his, it, ⟨y, hy, rfl⟩, rfl⟩ := hr
    simp only [resolveCfg, cfgI, Option.bind_eq_bind, hO o ho, mapM_img N.dim N'.dim I.num h ha.dim grid g hg,
      mapM_img N.dim N'.dim I.num h ha.dim group gr hgr, hI is his, Option.map_some, ha.dim v y hy,
      Option.bind_some, Option.pure_def]
    rfl

theorem resolvePrim_img (ha : Agree N N' h I kn kn' A) :
    ∀ (shape : List Dim) (dt : Nat) (p : Prim), PrimArgs A p → ∀ (r : RPrim δ κ), resolvePrim N kn shape dt p = some r →
      resolvePrim N' kn' (shape.map I.dim) dt (primI I p) = some (renameCls I.obj (mapP h r)) := by
  intro shape dt p
  induction p with
  | data bytes =>
    intro hA r hr
    simp only [resolvePrim, Option.bind_eq_bind] at hr
    obtain ⟨bs, hbs, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨ds, hds, hr⟩ := Option.bind_eq_some_iff.mp hr
    cases hr
    simp only [resolvePrim, primI, Option.bind_eq_bind, mapM_img N.byte N'.byte I.byte (fun v => v) ha.byte bytes bs hbs,
      mapM_img N.d N'.d I.dim h ha.d shape ds hds, List.map_id', Option.bind_some]
    rfl
  | zeros =>
    intro hA r hr
    obtain ⟨ds, hds, rfl⟩ := Option.map_eq_some_iff.mp hr
    simp only [resolvePrim, primI, mapM_img N.d N'.d I.dim h ha.d shape ds hds, Option.map_some]
    rfl
  | reshape s =>
    intro hA r hr
    obtain ⟨ds, hds, rfl⟩ := Option.map_eq_some_iff.mp hr
    simp only [resolvePrim, primI, mapM_img N.d N'.d I.dim h ha.d s ds hds, Option.map_some]
    rfl
  | slice a b c =>
    intro hA r hr
    simp only [resolvePrim, Option.bind_eq_bind] at hr
    obtain ⟨x, hx, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨y, hy, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨z, hz, hr⟩ := Option.bind_eq_some_iff.mp hr
    cases hr
    simp only [resolvePrim, primI, Option.bind_eq_bind, mapM_img N.d N'.d I.dim h ha.d a x hx,
      mapM_img N.d N'.d I.dim h ha.d b y hy, mapM_img N.d N'.d I.dim h ha.d c z hz, Option.bind_some]
    rfl
  | sliceUpdate a b c =>
    intro hA r hr
    simp only [resolvePrim, Option.bind_eq_bind] at hr
    obtain ⟨x, hx, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨y, hy, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨z, hz, hr⟩ := Option.bind_eq_some_iff.mp hr
    cases hr
    simp only [resolvePrim, primI, Option.bind_eq_bind, mapM_img N.d N'.d I.dim h ha.d a x hx,
      mapM_img N.d N'.d I.dim h ha.d b y hy, mapM_img N.d N'.d I.dim h ha.d c z hz, Option.bind_some]
    rfl
  | sliceDynamic ax sz =>
    intro hA r hr
    obtain ⟨ds, hds, rfl⟩ := Option.map_eq_some_iff.mp hr
    simp only [resolvePrim, primI, mapM_img N.d N'.d I.dim h ha.d sz ds hds, Option.map_some]
    rfl
  | rmsNorm eps =>
    intro hA r hr
    obtain ⟨w, hw, rfl⟩ := Option.map_eq_some_iff.mp hr
    simp only [resolvePrim, primI, ha.word eps w hw, Option.map_some]
    rfl
  | rope d t base scale off =>
    intro hA r hr
    simp only [resolvePrim, Option.bind_eq_bind] at hr
    obtain ⟨b, hb, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨w, hw, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨o, ho, hr⟩ := Option.bind_eq_some_iff.mp hr
    cases hr
    simp only [resolvePrim, primI, Option.bind_eq_bind, ha.arg base b hA hb, ha.word scale w hw, ha.dim off o ho,
      Option.bind_some]
    rfl
  | sdpa scale m =>
    intro hA r hr
    obtain ⟨w, hw, rfl⟩ := Option.map_eq_some_iff.mp hr
    simp only [resolvePrim, primI, ha.word scale w hw, Option.map_some]
    rfl
  | kernel k c o =>
    intro hA r hr
    simp only [resolvePrim, Option.bind_eq_bind] at hr
    obtain ⟨name, hn, hr⟩ := Option.bind_eq_some_iff.mp hr
    obtain ⟨rc, hrc, hr⟩ := Option.bind_eq_some_iff.mp hr
    cases hr
    simp only [resolvePrim, primI, Option.bind_eq_bind, ha.kernel k name hn, resolveCfg_img ha c rc hrc,
      Option.bind_some]
    rfl
  | replayed c p ih =>
    intro hA r hr
    obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp hr
    simp only [resolvePrim, primI, ih hA q hq, Option.map_some]
    rfl
  | _ =>
    intro hA r hr
    simp only [resolvePrim, Option.some.injEq] at hr
    subst hr
    rfl

theorem resolveNode_img (ha : Agree N N' h I kn kn' A) (σ : Nat → Nat) (nd : Node) (r : RNode δ κ)
    (hA : PrimArgs A nd.prim) (hr : resolveNode N kn nd = some r) :
    resolveNode N' kn' (nodeI σ I nd) = some (renameN σ I.obj (mapN h r)) := by
  obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp hr
  simp only [resolveNode, nodeI, resolvePrim_img ha nd.shape nd.dtype nd.prim hA q hq, Option.map_some]
  rfl

end

/-! ## Reading the template symbolically -/

/-- A number's value, if it is a literal. -/
def litVal : NumV → Option F64
  | .lit f => some f
  | .ref _ => none

/-- A host byte, if it holds no reference and no bigint. -/
def symByte : Byte → Option Nat
  | .lit b => some b
  | .part k (.num x) i => concreteByte litVal (.part k (.num x) i)
  | .part _ (.big _) _ => none

/-- The template's reading: dimensions through the classifier `cls`,
f32 words and host bytes only when literal (no bigint cells). -/
def symNums (cls : NumV → Option SDim) : Nums SDim :=
  ⟨cls, fun x => (litVal x).map fun f => F64.f32Bits (F64.toF32 f), SDim.lit, symByte⟩

/-- The template graph: state `s` read symbolically. -/
def symGraph (cls : NumV → Option SDim) (Ks : KernelSources) (s : Ffi.St) : Nat → Option (RNode SDim InKey) :=
  ffiGraph (symNums cls) Ks s

/-- `cls` names the offset dimensions correctly at valuation `ν` and offset `n`. -/
def ClsSound (cls : NumV → Option SDim) (ν : NumV → Option F64) (n : Nat) : Prop :=
  ∀ x d, cls x = some d → ((ν x).bind F64.toInt?) = some (SDim.eval n d)

/-- Host bytes with their numbers renamed by `μ`, bigint cells by `β`. -/
def byteI (μ : NumV → NumV) (β : Int → Int) : Byte → Byte
  | .lit b => .lit b
  | .part k (.num x) i => .part k (.num (μ x)) i
  | .part k (.big j) i => .part k (.big (β j)) i

/-! ## Iterations as images of the template -/

/-- The image under the number map `μ`, bigint map `β`, argument map `α` and
object map `η` (the iteration map's `nv`, `big`, `arg`, `handle`):
dimensions are renormalized (`dimOf`), as the interpreter builds them from
numbers. -/
def dimI (μ : NumV → NumV) : Dim → Dim
  | .lit i => .lit i
  | .sym x => dimOf (μ x)

def numImg (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η : Nat → Nat) : SynImg :=
  ⟨μ, dimI μ, byteI μ β, α, η⟩

theorem concrete_dimOf (ν : NumV → Option F64) (hlit : ∀ f, ν (.lit f) = some f) (y : NumV) :
    (concrete ν).d (dimOf y) = (concrete ν).dim y := by
  cases y with
  | lit f =>
    cases hf : F64.toInt? f with
    | none => simp only [dimOf, hf]; rfl
    | some i =>
      simp only [dimOf, hf]
      show some i = (ν (.lit f)).bind F64.toInt?
      rw [hlit, Option.bind_some, hf]
  | ref _ => rfl

/-- **The template's symbolic reading agrees with the iteration's concrete one**
along `numImg μ β α η` at offset `n`: `μ` keeps literals, every template number
with a value at the iteration's valuation (`νs`) has it at its image, `cls`
is sound there, rope arguments satisfying `A` keep their value, kernel
objects keep their route names. -/
theorem agree_run (cls : NumV → Option SDim) (νs νt : NumV → Option F64) (n : Nat) (μ : NumV → NumV)
    (β : Int → Int) (α : Arg → Arg) (η : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νs x = some f → νt (μ x) = some f) (hcls : ClsSound cls νs n)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (kn kn' : Nat → Option (List Char)) (hk : ∀ k name, kn k = some name → kn' (η k) = some name) :
    Agree (symNums cls) (concrete νt) (SDim.eval n) (numImg μ β α η) kn kn' A where
  d := by
    intro d y hd
    cases d with
    | lit i => cases hd; rfl
    | sym x =>
      show (concrete νt).d (dimOf (μ x)) = some _
      rw [concrete_dimOf νt hlitt]
      obtain ⟨f, hf, hy⟩ := Option.bind_eq_some_iff.mp (hcls x y hd)
      show (νt (μ x)).bind F64.toInt? = _
      rw [hν x f hf]; exact hy
  dim := by
    intro x y hx
    obtain ⟨f, hf, hy⟩ := Option.bind_eq_some_iff.mp (hcls x y hx)
    show (νt (μ x)).bind F64.toInt? = _
    rw [hν x f hf]; exact hy
  word := by
    intro x w hw
    cases x with
    | lit f =>
      simp only [symNums, litVal, Option.map_some, Option.some.injEq] at hw
      subst hw
      show (νt (μ (.lit f))).map _ = _
      rw [hlitμ, hlitt]
      rfl
    | ref _ => simp [symNums, litVal] at hw
  byte := by
    intro b v hb
    match b, hb with
    | .lit _, hb => exact hb
    | .part k (.num x) i, hb =>
      cases x with
      | lit f =>
        show concreteByte νt (.part k (.num (μ (.lit f))) i) = some v
        rw [hlitμ]
        simp only [symNums, symByte, concreteByte, concreteCell, litVal, Option.bind_eq_bind] at hb ⊢
        rw [hlitt]
        exact hb
      | ref _ => simp [symNums, symByte, concreteByte, concreteCell, litVal] at hb
  arg := hα
  kernel := hk

/-- The nodes of `G` in domain `D`. -/
def restrictTo {δ κ : Type} (D : Nat → Bool) (G : Nat → Option (RNode δ κ)) (i : Nat) : Option (RNode δ κ) :=
  if D i then G i else none

/-- The template's domain: nodes from `base` on, and the shared old nodes. -/
def dom (base : Nat) (shared : List Nat) (i : Nat) : Bool := decide (base ≤ i) || shared.contains i

/-- The nodes of `G` from id `base` on. -/
def fresh {δ κ : Type} (base : Nat) (G : Nat → Option (RNode δ κ)) : Nat → Option (RNode δ κ) :=
  restrictTo (dom base []) G

/-- **The iteration's native graph contains the template's nodes on `D`.**
Every node of template state `s` in `D` is at `σ i` in iteration state `t`,
as its image under `I`; `σ` keeps every such node above everything below it. -/
structure NativeImage (σ : Nat → Nat) (I : SynImg) (D : Nat → Bool) (s t : Ffi.St) : Prop where
  nodes : ∀ i nd, D i = true → s.nodes.get i = some nd → t.nodes.get (σ i) = some (nodeI σ I nd)
  order : ∀ i j, D i = true → (s.nodes.get i).isSome → j < i → σ j < σ i

theorem mapN_id {κ : Type} (r : RNode Int κ) : mapN (fun i : Int => i) r = r := by
  obtain ⟨p, ins⟩ := r
  have : mapP (κ := κ) (fun i : Int => i) p = p := by
    induction p <;> simp_all [mapP, mapC]
  simp [mapN, this]

/-- **Template to iteration.** If iteration state `t` contains template state
`s`'s nodes on `D` under node map `σ` and image `numImg μ β α η`, the
template's numbers with a value at the iteration's valuation (`νs`) have it at
their image (`νt`) along `μ`, `cls` classifies the offset dimensions at
offset `n`, the rope arguments of `D`'s nodes keep their value, and kernel
objects keep their route names, then `t`'s graph carries the template's
graph on `D` evaluated at `n`. -/
theorem embeds_of_image (cls : NumV → Option SDim) (Ks : KernelSources) (s t : Ffi.St) (n : Nat) (D : Nat → Bool)
    (νs νt : NumV → Option F64) (μ : NumV → NumV) (β : Int → Int) (α : Arg → Arg) (η σ : Nat → Nat)
    (hlitμ : ∀ f, μ (.lit f) = .lit f) (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ x f, νs x = some f → νt (μ x) = some f) (hcls : ClsSound cls νs n)
    (A : Arg → Prop) (hα : ∀ a v, A a → Ffi.argNat a = some v → Ffi.argNat (α a) = some v)
    (hargs : ∀ i nd, D i = true → s.nodes.get i = some nd → PrimArgs A nd.prim)
    (hk : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks t (η k) = some name)
    (himg : NativeImage σ (numImg μ β α η) D s t) :
    Embeds σ η (mapG (SDim.eval n) (restrictTo D (symGraph cls Ks s))) (ffiGraph (concrete νt) Ks t) where
  node := by
    intro i r hr
    obtain ⟨r0, h0, rfl⟩ := Option.map_eq_some_iff.mp hr
    have hb : D i = true := by
      cases hd : D i
      · simp [restrictTo, hd] at h0
      · rfl
    simp only [restrictTo, hb, ↓reduceIte] at h0
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h0
    have h2 := resolveNode_img (agree_run cls νs νt n μ β α η hlitμ hlitt hν hcls A hα _ _ hk) σ nd r0
      (hargs i nd hb hnd) hres
    show (t.nodes.get (σ i)).bind _ = _
    rw [himg.nodes i nd hb hnd, Option.bind_some]
    exact h2
  order := by
    intro i j hi hj
    have hb : D i = true := by
      cases hd : D i
      · simp [mapG, restrictTo, hd] at hi
      · rfl
    apply himg.order i j hb _ hj
    simp only [mapG, restrictTo, hb, ↓reduceIte, symGraph, ffiGraph, Option.isSome_map] at hi
    cases hs : s.nodes.get i with
    | none => rw [hs] at hi; cases hi
    | some _ => rfl

/-! ## Offset numbers -/

/-- The template's offset `var p` and `var p + 1` at a valuation sending `p`
to offset `n`. -/
theorem offset_values (ρ : Nat → F64) (p n : Nat) (hρ : ρ p = F64.ofNat n) (hn : n + 1 < 2 ^ 53) :
    F64.toInt? (SymE.eval ρ (.var p)) = some (n : Int) ∧
      F64.toInt? (SymE.eval ρ (.bin .add (.var p) (.lit (F64.ofNat 1)))) = some ((n : Int) + 1) := by
  refine ⟨?_, ?_⟩
  · rw [SymE.eval, hρ, F64.toInt_ofNat53 n (by omega)]
  · rw [SymE.eval, SymE.eval, SymE.eval, hρ, F64.bin, F64.add_ofNat53 n 1 hn, F64.toInt_ofNat53 (n + 1) hn]
    simp

end Host.Mlx.SimGraph
