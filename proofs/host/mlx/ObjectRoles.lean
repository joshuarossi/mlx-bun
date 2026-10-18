import host.mlx.InferenceRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- A Metal configuration retains ordinary labels and dtype codes while its
shape, grid, scalar, and initialization fields carry numeric occurrence roles. -/
structure CfgR (NR : NumV → NumV → Prop) (c c' : Cfg) : Prop where
  outs : ListR (fun a b : List Dim × Nat => Parametric.ShapeR NR a.1 b.1 ∧ b.2 = a.2) c.outs c'.outs
  grid : ListR NR c.grid c'.grid
  group : ListR NR c.group c'.group
  ints : ListR (fun a b : List Char × NumV => b.1 = a.1 ∧ NR a.2 b.2) c.ints c'.ints
  dtypes : c'.dtypes = c.dtypes
  init : OptionR NR c.init c'.init

structure TraceR (R : Ren) (t t' : Trace) : Prop where
  ins : t'.ins = t.ins.map R.node
  outs : t'.outs = t.outs.map R.node
  order : t'.order = t.order.map R.node

inductive CloR (NR : NumV → NumV → Prop) (R : Ren) : Clo → Clo → Prop where
  | empty : CloR NR R .empty .empty
  | fn (cb : Nat) {payload payload' : Arg} :
      Host.Ts.Owned.Parametric.TreeR NR R (Host.Ts.Owned.Parametric.arg payload)
        (Host.Ts.Owned.Parametric.arg payload') →
      CloR NR R (.fn cb payload) (.fn (R.region cb) payload')
  | compiled (cb : Nat) (shapeless : Bool) {payload payload' : Arg} {ts ts' : List Trace} :
      Host.Ts.Owned.Parametric.TreeR NR R (Host.Ts.Owned.Parametric.arg payload)
        (Host.Ts.Owned.Parametric.arg payload') →
      ListR (TraceR R) ts ts' →
      CloR NR R (.compiled cb payload shapeless ts) (.compiled (R.region cb) payload' shapeless ts')

/-- Primitive parameters use their own roles. Native IDs in kernel/replay
positions are resource IDs, rather than ordinary integers of equal value. -/
inductive PrimR (NR : NumV → NumV → Prop) (R : Ren) : Prim → Prim → Prop where
  | data {bs bs' : List Byte} : ListR (Host.Ts.Owned.Parametric.ByteR NR R) bs bs' →
      PrimR NR R (.data bs) (.data bs')
  | load (file key : List Char) : PrimR NR R (.load file key) (.load file key)
  | tracer (i : Nat) : PrimR NR R (.tracer i) (.tracer i)
  | zeros : PrimR NR R .zeros .zeros
  | arange {a a' b b' c c' : NumV} : NR a a' → NR b b' → NR c c' →
      PrimR NR R (.arange a b c) (.arange a' b' c')
  | reshape {s s' : List Dim} : Parametric.ShapeR NR s s' → PrimR NR R (.reshape s) (.reshape s')
  | transpose (axes : List Nat) : PrimR NR R (.transpose axes) (.transpose axes)
  | slice {a a' b b' c c' : List Dim} :
      Parametric.ShapeR NR a a' → Parametric.ShapeR NR b b' → Parametric.ShapeR NR c c' →
      PrimR NR R (.slice a b c) (.slice a' b' c')
  | sliceUpdate {a a' b b' c c' : List Dim} :
      Parametric.ShapeR NR a a' → Parametric.ShapeR NR b b' → Parametric.ShapeR NR c c' →
      PrimR NR R (.sliceUpdate a b c) (.sliceUpdate a' b' c')
  | sliceDynamic (axes : List Nat) {sizes sizes' : List Dim} : Parametric.ShapeR NR sizes sizes' →
      PrimR NR R (.sliceDynamic axes sizes) (.sliceDynamic axes sizes')
  | concat (axis : Nat) : PrimR NR R (.concat axis) (.concat axis)
  | unary (op : List Char) : PrimR NR R (.unary op) (.unary op)
  | binary (op : List Char) : PrimR NR R (.binary op) (.binary op)
  | astype (dt : Nat) : PrimR NR R (.astype dt) (.astype dt)
  | contiguous : PrimR NR R .contiguous .contiguous
  | rmsNorm {eps eps' : NumV} : NR eps eps' → PrimR NR R (.rmsNorm eps) (.rmsNorm eps')
  | rope (dims : Nat) (traditional : Bool) {base base' : Arg} {scale scale' offset offset' : NumV} :
      Host.Ts.Owned.Parametric.TreeR NR R (Host.Ts.Owned.Parametric.arg base)
        (Host.Ts.Owned.Parametric.arg base') → NR scale scale' → NR offset offset' →
      PrimR NR R (.rope dims traditional base scale offset) (.rope dims traditional base' scale' offset')
  | sdpa (mask : List Char) {scale scale' : NumV} : NR scale scale' →
      PrimR NR R (.sdpa scale mask) (.sdpa scale' mask)
  | qmm (tr : Bool) (group bits : Nat) (mode : List Char) :
      PrimR NR R (.qmm tr group bits mode) (.qmm tr group bits mode)
  | dequantize (group bits : Nat) (mode : List Char) (dt : Option Nat) :
      PrimR NR R (.dequantize group bits mode dt) (.dequantize group bits mode dt)
  | take (axis : Nat) : PrimR NR R (.take axis) (.take axis)
  | conv1d (stride pad dil groups : Nat) :
      PrimR NR R (.conv1d stride pad dil groups) (.conv1d stride pad dil groups)
  | logsumexp (axis : Nat) (keep : Bool) : PrimR NR R (.logsumexp axis keep) (.logsumexp axis keep)
  | kernel (k out : Nat) {c c' : Cfg} : CfgR NR c c' →
      PrimR NR R (.kernel k c out) (.kernel (R.handle k) c' out)
  | replayed (cls : Nat) {p p' : Prim} : PrimR NR R p p' →
      PrimR NR R (.replayed cls p) (.replayed (R.handle cls) p')

inductive ObjectR (NR : NumV → NumV → Prop) (R : Ren) : Obj → Obj → Prop where
  | stream : ObjectR NR R .stream .stream
  | str (s : List Char) : ObjectR NR R (.str s) (.str s)
  | vec (ns : List Nat) : ObjectR NR R (.vec ns) (.vec (ns.map R.node))
  | vstr (n : Nat) : ObjectR NR R (.vstr n) (.vstr n)
  | kernel (name source header : List Char) (nIn nOut : Nat) :
      ObjectR NR R (.kernel name source header nIn nOut) (.kernel name source header nIn nOut)
  | cfg {c c' : Cfg} : CfgR NR c c' → ObjectR NR R (.cfg c) (.cfg c')
  | clo {c c' : Clo} : CloR NR R c c' → ObjectR NR R (.clo c) (.clo c')
  | amap (file : Option (List Char)) : ObjectR NR R (.amap file) (.amap file)
  | smap : ObjectR NR R .smap .smap
  | device : ObjectR NR R .device .device
  | dinfo : ObjectR NR R .dinfo .dinfo

private theorem listMono {p q : α → β → Prop} {xs : List α} {ys : List β}
    (h : ListR p xs ys) (m : ∀ a b, p a b → q a b) : ListR q xs ys := by
  induction h with
  | nil => exact .nil
  | cons h _ ih => exact .cons (m _ _ h) ih

theorem CfgR.empty (NR : NumV → NumV → Prop) : CfgR NR .empty .empty :=
  ⟨.nil,.nil,.nil,.nil,rfl,.none⟩

theorem CfgR.mono {NR NR' : NumV → NumV → Prop} {c c' : Cfg}
    (h : CfgR NR c c') (m : ∀ a b, NR a b → NR' a b) : CfgR NR' c c' := by
  refine ⟨listMono h.outs ?_, listMono h.grid m, listMono h.group m,
    listMono h.ints ?_, h.dtypes, h.init.mono m⟩
  · intro a b hr; exact ⟨listMono hr.1 (fun _ _ hn => m _ _ hn), hr.2⟩
  · intro a b hr; exact ⟨hr.1,m _ _ hr.2⟩

theorem CfgR.output {NR : NumV → NumV → Prop} {c c' : Cfg} (h : CfgR NR c c')
    {shape shape' : List Dim} (dt : Nat) (hs : Parametric.ShapeR NR shape shape') :
    CfgR NR { c with outs := c.outs ++ [(shape,dt)] } { c' with outs := c'.outs ++ [(shape',dt)] } :=
  { h with outs := h.outs.append (.cons ⟨hs,rfl⟩ .nil) }

theorem CfgR.setGrid {NR : NumV → NumV → Prop} {c c' : Cfg} (h : CfgR NR c c')
    {xs xs' : List NumV} (hx : ListR NR xs xs') :
    CfgR NR { c with grid := xs } { c' with grid := xs' } := { h with grid := hx }

theorem CfgR.setGroup {NR : NumV → NumV → Prop} {c c' : Cfg} (h : CfgR NR c c')
    {xs xs' : List NumV} (hx : ListR NR xs xs') :
    CfgR NR { c with group := xs } { c' with group := xs' } := { h with group := hx }

theorem CfgR.setInit {NR : NumV → NumV → Prop} {c c' : Cfg} (h : CfgR NR c c')
    {x x' : NumV} (hx : NR x x') :
    CfgR NR { c with init := some x } { c' with init := some x' } := { h with init := .some hx }

theorem CfgR.addInt {NR : NumV → NumV → Prop} {c c' : Cfg} (h : CfgR NR c c')
    (name : List Char) {x x' : NumV} (hx : NR x x') :
    CfgR NR { c with ints := c.ints ++ [(name,x)] } { c' with ints := c'.ints ++ [(name,x')] } :=
  { h with ints := h.ints.append (.cons ⟨rfl,hx⟩ .nil) }

theorem CfgR.addDtype {NR : NumV → NumV → Prop} {c c' : Cfg} (h : CfgR NR c c')
    (name : List Char) (dt : Nat) :
    CfgR NR { c with dtypes := c.dtypes ++ [(name,dt)] } { c' with dtypes := c'.dtypes ++ [(name,dt)] } :=
  { h with dtypes := congrArg (· ++ [(name,dt)]) h.dtypes }

theorem CloR.mono {NR NR' : NumV → NumV → Prop} {R : Ren} {c c' : Clo}
    (h : CloR NR R c c') (m : ∀ a b, NR a b → NR' a b) : CloR NR' R c c' := by
  cases h with
  | empty => exact .empty
  | fn cb hp => exact .fn cb (hp.mono m)
  | compiled cb sl hp ht => exact .compiled cb sl (hp.mono m) ht

theorem ObjectR.mono {NR NR' : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') (m : ∀ a b, NR a b → NR' a b) : ObjectR NR' R o o' := by
  cases h with
  | stream => exact .stream
  | str s => exact .str s
  | vec ns => exact .vec ns
  | vstr n => exact .vstr n
  | kernel n s h i o => exact .kernel n s h i o
  | cfg h => exact .cfg (h.mono m)
  | clo h => exact .clo (h.mono m)
  | amap f => exact .amap f
  | smap => exact .smap
  | device => exact .device
  | dinfo => exact .dinfo

theorem PrimR.mono {NR NR' : NumV → NumV → Prop} {R : Ren} {p p' : Prim}
    (h : PrimR NR R p p') (m : ∀ a b, NR a b → NR' a b) : PrimR NR' R p p' := by
  induction h with
  | data h => exact .data (listMono h (fun _ _ hb => hb.mono m))
  | load f k => exact .load f k
  | tracer i => exact .tracer i
  | zeros => exact .zeros
  | arange a b c => exact .arange (m _ _ a) (m _ _ b) (m _ _ c)
  | reshape s => exact .reshape (listMono s (fun _ _ hd => m _ _ hd))
  | transpose ax => exact .transpose ax
  | slice a b c =>
    exact .slice (listMono a (fun _ _ hd => m _ _ hd))
      (listMono b (fun _ _ hd => m _ _ hd)) (listMono c (fun _ _ hd => m _ _ hd))
  | sliceUpdate a b c =>
    exact .sliceUpdate (listMono a (fun _ _ hd => m _ _ hd))
      (listMono b (fun _ _ hd => m _ _ hd)) (listMono c (fun _ _ hd => m _ _ hd))
  | sliceDynamic ax s => exact .sliceDynamic ax (listMono s (fun _ _ hd => m _ _ hd))
  | concat a => exact .concat a
  | unary op => exact .unary op
  | binary op => exact .binary op
  | astype d => exact .astype d
  | contiguous => exact .contiguous
  | rmsNorm eps => exact .rmsNorm (m _ _ eps)
  | rope ds tr base scale offset => exact .rope ds tr (base.mono m) (m _ _ scale) (m _ _ offset)
  | sdpa mask scale => exact .sdpa mask (m _ _ scale)
  | qmm tr g b mode => exact .qmm tr g b mode
  | dequantize g b mode dt => exact .dequantize g b mode dt
  | take ax => exact .take ax
  | conv1d st pd di gr => exact .conv1d st pd di gr
  | logsumexp ax keep => exact .logsumexp ax keep
  | kernel k out cfg => exact .kernel k out (cfg.mono m)
  | replayed cls _ ih => exact .replayed cls ih

theorem NodeR.numeric_mono {NR NR' : NumV → NumV → Prop} {R : Ren}
    {boundary : Nat → Prop} {i : Nat} {n n' : Node}
    (h : NodeR NR R (PrimR NR R) boundary i n n') (m : ∀ a b, NR a b → NR' a b) :
    NodeR NR' R (PrimR NR' R) boundary i n n' := by
  refine ⟨listMono h.shape (fun _ _ hd => m _ _ hd), h.dtype, ?_⟩
  rcases h.graph with hb | ⟨hp,hi⟩
  · exact .inl hb
  · exact .inr ⟨hp.mono m,hi⟩

end Host.Mlx.Ffi.NativeRoles
