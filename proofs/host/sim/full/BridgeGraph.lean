import host.sim.full.BridgeRaise
import host.simgraph.LoadRel
import host.mlx.ane.Forward

/-! # The target's Neural Engine graph from the template's

The Neural Engine semantics runs over `Graph.ofState N S IS s b` (`FfiAneEval`): the resolved nodes,
the in-place writers, and the bridge's aliases, touches, wrap types and programs. On related states
(`G.MR`, `BRel`) the target's graph carries the template's on a domain of fully corresponding nodes
that are not shape-only data (`GraphImg`, `graphImg_of`), when the template's number reading `N` and
the target's `N'` agree along the map (`Agree`, `host.simgraph.Native`). So the graph facts of a
forward checked on the template hold at the node images on the target: a fill's (`fillAt_img`), a
reader's read chain (`ReadChain.img`, giving `ReadAt` by `aliasVal_readView`), the programs.

The template's reading `tplNums νs` agrees with the target's concrete one when the template's numbers
with a value at `νs` keep it at their images (`agree_tpl`); read literally (`litVal`) at the target's
server, the transfer needs nothing beyond the relation (`graphImg_lit`, and `graphImg_full` at the full
world's relation with the bridge active), on the domain `aneDom` the template decides. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.FfiAneEval (Graph Writer writerOf Fill Reader ReadAt)
open Host.Mlx.Ffi (Prim Node Dim)

theorem mapP_idI {κ : Type} (p : RPrim Int κ) : mapP (fun i : Int => i) p = p := by
  induction p <;> simp_all [mapP, mapC]

theorem mapC_idI (c : RCfg Int) : mapC (fun i : Int => i) c = c := by
  obtain ⟨outs, grid, group, ints, dts, init⟩ := c
  simp [mapC]

theorem cfgI_map (M : Map) (c : Ffi.Cfg) : cfgI (loadImg M) c = M.cfg c := by
  have hd : (loadImg M).dim = M.dim := funext (dimI_map M)
  have hds : ∀ l : List Dim, l.map (loadImg M).dim = M.dims l := fun l => by rw [hd]; rfl
  obtain ⟨outs, grid, group, ints, dts, init⟩ := c
  simp only [cfgI, Map.cfg, hds]
  rfl

theorem dims_loadImg (M : Map) (l : List Dim) : l.map (loadImg M).dim = M.dims l := by
  rw [show (loadImg M).dim = M.dim from funext (dimI_map M)]; rfl

/-! ## Resolution along the map -/

section
variable {N N' : Nums Int} {I : SynImg} {kn kn' : Nat → Option (List Char)} {A : Arg → Prop}

theorem resolvePrim_imgI (ha : Host.Mlx.SimGraph.Agree N N' (fun i => i) I kn kn' A) (shape : List Dim) (dt : Nat) (p : Prim)
    (hA : PrimArgs A p) {κ : Type} (r : RPrim Int κ) (hr : resolvePrim N kn shape dt p = some r) :
    resolvePrim N' kn' (shape.map I.dim) dt (primI I p) = some (renameCls I.obj r) := by
  have := resolvePrim_img ha shape dt p hA r hr
  rwa [mapP_idI] at this

/-- **Resolution with `arange` as data along the map.** -/
theorem resolvePrimP_imgI (ha : Host.Mlx.SimGraph.Agree N N' (fun i => i) I kn kn' A) (shape : List Dim) (dt : Nat) {κ : Type} :
    ∀ (p : Prim), PrimArgs A p → ∀ (r : RPrim Int κ), resolvePrimP N kn shape dt p = some r →
      resolvePrimP N' kn' (shape.map I.dim) dt (primI I p) = some (renameCls I.obj r)
  | .arange a b c, _, r, hr => by
    have e3 : ∀ ns, shape.mapM N.d = some ns → (shape.map I.dim).mapM N'.d = some ns := fun ns h => by
      have := mapM_img N.d N'.d I.dim (fun i => i) ha.d shape ns h
      rwa [List.map_id'] at this
    unfold resolvePrimP at hr ⊢
    simp only [primI]
    cases h1 : N.dim a with
    | none => simp [h1] at hr
    | some a' =>
      cases h2 : N.dim c with
      | none => simp [h1, h2] at hr
      | some c' =>
        cases h3 : shape.mapM N.d with
        | none => simp [h1, h2, h3] at hr
        | some ns =>
          simp only [h1, h2, h3, ha.dim a a' h1, ha.dim c c' h2, e3 ns h3, Option.bind_eq_bind, Option.bind_some]
            at hr ⊢
          rcases ns with _ | ⟨n, _ | ⟨_, _⟩⟩
          · cases hr
          · by_cases hc : dt = Ffi.dtInt32 ∧ 0 ≤ n
            · simp only [hc, and_self, ↓reduceIte, Option.pure_def, Option.some.injEq] at hr ⊢
              subst hr; rfl
            · simp only [hc, ↓reduceIte] at hr; cases hr
          · cases hr
  | .replayed c p, hA, r, hr => by
    simp only [resolvePrimP, Option.map_eq_some_iff] at hr
    obtain ⟨q, hq, rfl⟩ := hr
    simp only [primI, resolvePrimP, resolvePrimP_imgI ha shape dt p hA q hq, Option.map_some, renameCls]
  | .data _, hA, r, e | .load _ _, hA, r, e | .tracer _, hA, r, e | .zeros, hA, r, e | .reshape _, hA, r, e
  | .transpose _, hA, r, e | .slice _ _ _, hA, r, e | .sliceUpdate _ _ _, hA, r, e | .sliceDynamic _ _, hA, r, e
  | .concat _, hA, r, e | .unary _, hA, r, e | .binary _, hA, r, e | .astype _, hA, r, e | .contiguous, hA, r, e
  | .rmsNorm _, hA, r, e | .rope _ _ _ _ _, hA, r, e | .sdpa _ _, hA, r, e | .qmm _ _ _ _, hA, r, e
  | .dequantize _ _ _ _, hA, r, e | .take _, hA, r, e | .conv1d _ _ _ _, hA, r, e | .logsumexp _ _, hA, r, e
  | .kernel _ _ _, hA, r, e => resolvePrim_imgI ha shape dt _ hA r e

end

/-! ## The graph's parts along the map -/

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y)
include hr

/-- The native relation keeps every route kernel object. -/
theorem routeKernels_of_MR (S : KernelSources) :
    ∀ k name, routeKernelName? S x k = some name → routeKernelName? S y (M.handle k) = some name := by
  intro k name hk
  unfold routeKernelName? at hk ⊢
  cases ho : x.objs.get k with
  | none => simp [Ffi.St.obj?, ho] at hk
  | some o =>
    have hy := hr.objs k (.inr (by simp [ho]))
    rw [ho] at hy
    simp only [Ffi.St.obj?, ho] at hk
    cases o with
    | kernel nm src hdr a b =>
      simp only [Ffi.St.obj?, hy, Option.map_some, Map.nobj]
      exact hk
    | _ => simp at hk

variable {S : KernelSources} {N N' : Nums Int} {A : Arg → Prop}
  (ha : Host.Mlx.SimGraph.Agree N N' (fun i => i) (loadImg M) (routeKernelName? S x) (routeKernelName? S y) A)
include ha

/-- **A resolved node along the map.** -/
theorem ffiGraphR_img {j : Nat} (hF : Full P j)
    (hs : ∀ nd, x.nodes.get j = some nd → G.shapeOnly nd = false ∧ PrimArgs A nd.prim) {r : RNode Int Nat}
    (h : ffiGraphR N S x j = some r) : ffiGraphR N' S y (M.node j) = some (renameN M.node M.handle r) := by
  unfold ffiGraphR at h ⊢
  obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨hso, hA⟩ := hs nd hnd
  obtain ⟨nd', h1, hsh, hdt, -, hf⟩ := hr.nodes j nd hnd
  obtain ⟨hp, hins⟩ := hf hF
  have hp' := hp.exact hso
  rw [h1, Option.bind_some]
  unfold resolveNodeP at hres ⊢
  obtain ⟨q, hq, rfl⟩ := Option.map_eq_some_iff.mp hres
  have e := resolvePrimP_imgI ha nd.shape nd.dtype nd.prim hA q hq
  rw [primI_map, dims_loadImg] at e
  rw [hp', hsh, hdt, hins, e]
  rfl

/-- **An in-place writer along the map.** -/
theorem writerOf_img {IS : FfiAneEval.InPlaceSources} {j : Nat} (hF : Full P j)
    (hso : ∀ nd, x.nodes.get j = some nd → G.shapeOnly nd = false) {w : Writer} (h : writerOf N IS x j = some w) :
    writerOf N' IS y (M.node j) = some { w with ins := w.ins.map M.node } := by
  unfold writerOf at h ⊢
  obtain ⟨nd, hnd, hw⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨nd', h1, -, -, -, hf⟩ := hr.nodes j nd hnd
  obtain ⟨hp, hins⟩ := hf hF
  have hp' := hp.exact (hso nd hnd)
  rw [h1, Option.bind_some]
  split at hw
  · rename_i kh cfg hprim
    have hp2 : nd'.prim = .kernel (M.handle kh) (M.cfg cfg) 0 := by rw [hp', hprim]; rfl
    split
    case h_2 hne => exact (hne _ _ hp2).elim
    rename_i kh' cfg' heq
    rw [hp2] at heq
    injection heq with e1 e2
    subst e1 e2
    split at hw
    · rename_i name src hdr a b hobj
      have hxo : x.objs.get kh = some (.kernel name src hdr a b) := hobj
      have hy : y.obj? (M.handle kh) = some (.kernel name src hdr a b) := by
        show y.objs.get _ = _
        rw [hr.objs kh (.inr (by rw [hxo]; rfl)), hxo]
        rfl
      rw [hy]
      try dsimp only
      obtain ⟨k, hk, hw⟩ := Option.bind_eq_some_iff.mp hw
      rw [hk, Option.bind_some]
      split at hw
      · rename_i hsrc
        rw [if_pos hsrc]
        obtain ⟨c, hc, rfl⟩ := Option.map_eq_some_iff.mp hw
        obtain ⟨rc, hrc, htc⟩ := Option.bind_eq_some_iff.mp hc
        have e := resolveCfg_img ha cfg rc hrc
        rw [cfgI_map, mapC_idI] at e
        rw [e, Option.bind_some, htc, Option.map_some, hins]
      · cases hw
    · cases hw
  · cases hw

/-- **A wrap's type along the map.** -/
theorem wrapType_img {IS : FfiAneEval.InPlaceSources} {b b' : BSt} {j : Nat} {t}
    (h : (Graph.ofState N S IS x b).wrapType j = some t) : (Graph.ofState N' S IS y b').wrapType (M.node j) = some t := by
  show (y.nodes.get (M.node j)).bind _ = _
  obtain ⟨nd, hnd, hw⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨nd', h1, hsh, hdt, -, -⟩ := hr.nodes j nd hnd
  rw [h1, Option.bind_some, hdt, hsh]
  obtain ⟨dt, hdt0, hw⟩ := Option.bind_eq_some_iff.mp hw
  rw [hdt0, Option.bind_some]
  obtain ⟨sh, hsh0, rfl⟩ := Option.map_eq_some_iff.mp hw
  obtain ⟨ds, hds, hns⟩ := Option.bind_eq_some_iff.mp hsh0
  have e := mapM_img N.d N'.d (loadImg M).dim (fun i => i) ha.d nd.shape ds hds
  rw [List.map_id', dims_loadImg] at e
  rw [e, Option.bind_some, hns]
  rfl

end

/-! ## The graph along the map -/

/-- **The target's graph carries the template's on `D`** along the node map `σ` (closure tags renamed
by `cl`). -/
structure GraphImg (D : Nat → Prop) (σ cl : Nat → Nat) (Gx Gy : Graph) : Prop where
  node : ∀ j r, D j → Gx.node j = some r → Gy.node (σ j) = some (renameN σ cl r)
  writer : ∀ j w, D j → Gx.writer j = some w → Gy.writer (σ j) = some { w with ins := w.ins.map σ }
  aliasOf : ∀ j, D j → Gy.aliasOf (σ j) = Gx.aliasOf j
  touch : ∀ j, D j → Gy.touch (σ j) = Gx.touch j
  wrapType : ∀ j t, D j → Gx.wrapType j = some t → Gy.wrapType (σ j) = some t
  program : Gy.program = Gx.program
  order : ∀ i j, D i → (Gx.node i).isSome = true → j < i → σ j < σ i

/-- **Related states' graphs**: on a domain of fully corresponding template nodes below the counter, none
shape-only data, their rope arguments those `A` keeps. -/
theorem graphImg_of {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y)
    {S : KernelSources} {IS : FfiAneEval.InPlaceSources} {N N' : Nums Int} {A : Arg → Prop}
    (ha : Host.Mlx.SimGraph.Agree N N' (fun i => i) (loadImg M) (routeKernelName? S x) (routeKernelName? S y) A) {b b' : BSt}
    (hb : BRel M x.nnext y.nnext b b') {D : Nat → Prop}
    (hD : ∀ j, D j → Full P j ∧ j < x.nnext ∧ ∀ nd, x.nodes.get j = some nd → G.shapeOnly nd = false ∧ PrimArgs A nd.prim) :
    GraphImg D M.node M.handle (Graph.ofState N S IS x b) (Graph.ofState N' S IS y b') where
  node j r hj h := ffiGraphR_img hr ha (hD j hj).1 (hD j hj).2.2 h
  writer j w hj h := writerOf_img hr ha (hD j hj).1 (fun nd hn => ((hD j hj).2.2 nd hn).1) h
  aliasOf j hj := hb.aliases j (hD j hj).2.1
  touch j hj := hb.touch j (hD j hj).2.1
  wrapType j t _ h := wrapType_img hr ha h
  program := by show Host.Ts.nth? b'.programs = Host.Ts.nth? b.programs; rw [hb.programs]
  order i j hi hn hj := by
    have hpn : PN x i := by
      show (x.nodes.get i).isSome = true
      have : (ffiGraphR N S x i).isSome = true := hn
      unfold ffiGraphR at this
      cases e : x.nodes.get i with
      | none => rw [e] at this; cases this
      | some _ => rfl
    exact hr.norder i hpn (hD i hi).1 j hj

theorem GraphImg.mono {D D' : Nat → Prop} {σ cl : Nat → Nat} {Gx Gy : Graph} (h : GraphImg D σ cl Gx Gy)
    (hD : ∀ j, D' j → D j) : GraphImg D' σ cl Gx Gy where
  node j r hj := h.node j r (hD j hj)
  writer j w hj := h.writer j w (hD j hj)
  aliasOf j hj := h.aliasOf j (hD j hj)
  touch j hj := h.touch j (hD j hj)
  wrapType j t hj := h.wrapType j t (hD j hj)
  program := h.program
  order i j hi := h.order i j (hD i hi)

/-! ## Forward facts along the map -/

/-- A fill with its node ids renamed. -/
def fillImg (σ : Nat → Nat) (f : Fill) : Fill := { f with d := σ f.d, W := σ f.W, pre := f.pre.map σ }

section
variable {Dm : Nat → Prop} {σ cl : Nat → Nat} {Gx Gy : Graph} (h : GraphImg Dm σ cl Gx Gy)
include h

/-- **A fill's facts along the map.** -/
theorem fillAt_img {f : Fill} (hf : Fill.At Gx f) (hd : Dm f.d) (hW : Dm f.W) (hpre : ∀ j ∈ f.pre, Dm j) :
    Fill.At Gy (fillImg σ f) where
  touch := by show Gy.touch (σ f.d) = _; rw [h.touch _ hd]; exact hf.touch
  writer := by
    show Gy.writer (σ f.d) = some ⟨f.k, f.cfg, f.pre.map σ ++ [σ f.W]⟩
    rw [h.writer _ _ hd hf.writer, List.map_append]
    rfl
  wrap := by show Gy.aliasOf (σ f.W) = _; rw [h.aliasOf _ hW]; exact hf.wrap
  wrapType := h.wrapType _ _ hW hf.wrapType
  pure := by
    intro j hj
    obtain ⟨j0, hj0, rfl⟩ := List.mem_map.mp (show j ∈ f.pre.map σ from hj)
    rw [h.aliasOf _ (hpre j0 hj0)]
    exact hf.pure j0 hj0
  out := hf.out

/-- A reader's read chain as the FFI records it: the bf16 `astype` `b` of view `v2`, a reshape to `[M, D]`
of view `v1`, a slice of the first `M·D` halves of the output wrap `wo` of surface `so` (`aliasVal_readView`). -/
structure _root_.Host.Ts.Sim.Full.ReadChain (G : Graph) (b wo v1 v2 so len M D : Nat) : Prop where
  touch : G.touch b = some (.read [so])
  node : G.node b = some ⟨.astype Ffi.dtBf16, [v2]⟩
  wrap : G.aliasOf wo = some (.wrap so)
  wrapType : G.wrapType wo = some (.float16, [len])
  view1 : G.aliasOf v1 = some (.view so)
  node1 : G.node v1 = some ⟨.slice [0] [((M * D : Nat) : Int)] [1], [wo]⟩
  lt1 : wo < v1
  view2 : G.aliasOf v2 = some (.view so)
  node2 : G.node v2 = some ⟨.reshape [(M : Int), (D : Int)], [v1]⟩
  lt2 : v1 < v2

/-- **A read chain along the map.** -/
theorem ReadChain.img {b wo v1 v2 so len M D : Nat} (hc : ReadChain Gx b wo v1 v2 so len M D)
    (hb : Dm b) (hwo : Dm wo) (h1 : Dm v1) (h2 : Dm v2) : ReadChain Gy (σ b) (σ wo) (σ v1) (σ v2) so len M D where
  touch := by rw [h.touch _ hb]; exact hc.touch
  node := by rw [h.node _ _ hb hc.node]; rfl
  wrap := by rw [h.aliasOf _ hwo]; exact hc.wrap
  wrapType := h.wrapType _ _ hwo hc.wrapType
  view1 := by rw [h.aliasOf _ h1]; exact hc.view1
  node1 := by rw [h.node _ _ h1 hc.node1]; rfl
  lt1 := h.order _ _ h1 (by rw [hc.node1]; rfl) hc.lt1
  view2 := by rw [h.aliasOf _ h2]; exact hc.view2
  node2 := by rw [h.node _ _ h2 hc.node2]; rfl
  lt2 := h.order _ _ h2 (by rw [hc.node2]; rfl) hc.lt2

end

/-- **A read chain is a reader's facts** (`ReadAt` by `aliasVal_readView`). -/
theorem ReadChain.readAt {C : Inference.Contracts.Mlx.M1Max.Contract} (P : Host.Mlx.MlxPrefillContract C)
    (K : Host.Mlx.RouteKernelContract C) (weights : List Char → List Char → Option Value) {G : Graph}
    {b wo v1 v2 so len M D : Nat} (hc : ReadChain G b wo v1 v2 so len M D) : ReadAt P K weights G b v2 so len M D where
  touch := hc.touch
  node := hc.node
  isAlias := by rw [hc.view2]; rfl
  view := fun m => FfiAneEval.aliasVal_readView P K weights G m wo v1 v2 so len M D hc.wrap hc.wrapType hc.view1
    hc.node1 hc.lt1 hc.view2 hc.node2 hc.lt2

/-! ## The template's reading -/

/-- **The template's number reading** at valuation `νs`: the concrete reading, host bytes of bigint
cells unread. -/
def tplNums (νs : NumV → Option F64) : Nums Int :=
  ⟨(concrete νs).dim, (concrete νs).word, id, fun b => match b with
    | .part _ (.big _) _ => none
    | b => concreteByte νs b⟩

/-- **The template's reading agrees with the target's** along the map, when the template's numbers
with a value at `νs` have it at their images (`agree_run`'s pattern; rope arguments literal). -/
theorem agree_tpl {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y)
    (S : KernelSources) {νs νt : NumV → Option F64} (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ z f, νs z = some f → νt (M.nv z) = some f) :
    Host.Mlx.SimGraph.Agree (tplNums νs) (concrete νt) (fun i => i) (loadImg M) (routeKernelName? S x)
      (routeKernelName? S y) (fun a => okArg [] a = true) where
  d := by
    intro d yv hd
    cases d with
    | lit i => cases hd; rfl
    | sym z =>
      show (concrete νt).d (Host.Mlx.Ffi.dimOf (M.nv z)) = some yv
      rw [concrete_dimOf νt hlitt]
      obtain ⟨f, hf, hy⟩ := Option.bind_eq_some_iff.mp hd
      show (νt (M.nv z)).bind F64.toInt? = _
      rw [hν z f hf]; exact hy
  dim := by
    intro z yv hz
    obtain ⟨f, hf, hy⟩ := Option.bind_eq_some_iff.mp hz
    show (νt (M.nv z)).bind F64.toInt? = _
    rw [hν z f hf]; exact hy
  word := by
    intro z w hw
    obtain ⟨f, hf, hy⟩ := Option.map_eq_some_iff.mp hw
    show (νt (M.nv z)).map _ = _
    rw [hν z f hf, Option.map_some, hy]
  byte := by
    intro b v hb
    match b, hb with
    | .lit _, hb => exact hb
    | .part k (.num z) i, hb =>
      show concreteByte νt (.part k (.num (M.nv z)) i) = some v
      have hb' : concreteByte νs (.part k (.num z) i) = some v := hb
      cases hz : νs z with
      | none => simp [concreteByte, concreteCell, hz] at hb'
      | some f =>
        simp only [concreteByte, concreteCell, Option.bind_eq_bind] at hb' ⊢
        rw [hz] at hb'
        rw [hν z f hz]
        exact hb'
    | .part _ (.big _) _, hb => cases hb
  arg := arg_fixed M [] (fun i hi => by cases hi)
  kernel := routeKernels_of_MR hr S

/-- **The domain of the graph transfer**, decided on the template: fully corresponding nodes below the
counter, not shape-only data, their rope arguments literal. -/
def aneDom (P : LoadP) (x : NSt) (j : Nat) : Bool :=
  tplDom P.NL P.N0 [] x j && decide (j < x.nnext) && match x.nodes.get j with
    | some nd => !G.shapeOnly nd
    | none => true

theorem aneDom_spec {P : LoadP} {x : NSt} {j : Nat} (h : aneDom P x j = true) :
    Full P j ∧ j < x.nnext ∧
      ∀ nd, x.nodes.get j = some nd → G.shapeOnly nd = false ∧ PrimArgs (fun a => okArg [] a = true) nd.prim := by
  unfold aneDom at h
  rw [Bool.and_eq_true, Bool.and_eq_true, decide_eq_true_eq] at h
  obtain ⟨⟨hd, hlt⟩, hs⟩ := h
  refine ⟨tplDom_band hd, hlt, fun nd hn => ⟨?_, tplDom_args hd hn⟩⟩
  rw [hn] at hs
  simpa using hs

/-- A raise of a band-free `P` keeps the domain. -/
theorem aneDom_raise {P : LoadP} {x : NSt} {j : Nat} (hb : P.NL = P.N0) (k : Nat) (h : aneDom P x j = true) :
    aneDom (P.raise k) x j = true := by
  unfold aneDom tplDom at h ⊢
  simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq] at h ⊢
  refine ⟨⟨⟨?_, h.1.1.2⟩, h.1.2⟩, h.2⟩
  show j < k ∨ k ≤ j
  omega

/-- **The target's graph carries the template's**, read at `νs`, on `aneDom`. -/
theorem graphImg_tpl {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y)
    {S : KernelSources} {IS : FfiAneEval.InPlaceSources} {b b' : BSt} (hb : BRel M x.nnext y.nnext b b')
    {νs νt : NumV → Option F64} (hlitt : ∀ f, νt (.lit f) = some f)
    (hν : ∀ z f, νs z = some f → νt (M.nv z) = some f) :
    GraphImg (fun j => aneDom P x j = true) M.node M.handle (Graph.ofState (tplNums νs) S IS x b)
      (Graph.ofState (concrete νt) S IS y b') :=
  graphImg_of hr (agree_tpl hr S hlitt hν) hb fun _ hj => aneDom_spec hj

/-- **The target's graph at its server carries the template's read literally**, on `aneDom`: no
hypothesis beyond the relation. -/
theorem graphImg_lit {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y)
    {S : KernelSources} {IS : FfiAneEval.InPlaceSources} {b b' : BSt} (hb : BRel M x.nnext y.nnext b b')
    (C : CSrv) :
    GraphImg (fun j => aneDom P x j = true) M.node M.handle (Graph.ofState (tplNums litVal) S IS x b)
      (Graph.ofState (concrete C.val) S IS y b') :=
  graphImg_tpl hr hb (fun _ => rfl) fun z f hz => by
    cases z with
    | lit g => cases hz; rfl
    | ref _ => cases hz

/-- **The full world's graph transfer** with the bridge active, at a band-free `P`: the target's graph at
its server carries the template's read literally on `aneDom`. -/
theorem graphImg_full {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (hr : FullRXD P NB M n x y)
    (hb : P.NL = P.N0) (hact : (bridgeOf x).active = true) (S : KernelSources) (IS : FfiAneEval.InPlaceSources)
    (C : CSrv) :
    GraphImg (fun j => aneDom P (mlxOf x) j = true) M.node M.handle
      (Graph.ofState (tplNums litVal) S IS (mlxOf x) (bridgeOf x))
      (Graph.ofState (concrete C.val) S IS (mlxOf y) (bridgeOf y)) := by
  have hrr := (hr.top hb).1
  have hbA : BridgeA M x y := by
    rcases hrr.bridge with h | ⟨-, h⟩
    · rw [h.2] at hact; cases hact
    · exact h
  exact (graphImg_lit hrr.load.mlx hbA.rel C).mono fun j hj => aneDom_raise hb _ hj

end Host.Ts.Sim.Full
