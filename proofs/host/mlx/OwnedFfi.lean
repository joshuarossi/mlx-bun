import host.ts.RenameOwnedState
import host.ts.RenameOwnedBuffer
import host.ts.RenameOutputs

set_option maxRecDepth 1000000
set_option Elab.async false

namespace Host.Mlx.Ffi.Owned
open Host.Ts Host.Ts.Owned

theorem call_ndim (s : St) (h : Nat) (n : Node) (hn : s.node? h = some n) :
    call s chars!"mlx_array_ndim" [.big (Int.ofNat h)] =
      M.pure (some (s, Ret.big (len n.shape), [])) := by
  have hs : symOf chars!"mlx_array_ndim" = some .arrayNdim := by decide +kernel
  unfold call
  rw [hs]
  simp only [argNat_big_nat, Option.bind_some, hn, ok]

theorem call_shape (s : St) (h : Nat) (n : Node) (hn : s.node? h = some n) :
    call s chars!"mlx_array_shape" [.big (Int.ofNat h)] =
      M.pure (some (s, Ret.ptr (4*h) 0, [])) := by
  have hs : symOf chars!"mlx_array_shape" = some .arrayShape := by decide +kernel
  unfold call
  rw [hs]
  simp only [argNat_big_nat, hn, ok]

theorem call_dtype (s : St) (h : Nat) (n : Node) (hn : s.node? h = some n) :
    call s chars!"mlx_array_dtype" [.big (Int.ofNat h)] =
      M.pure (some (s, Ret.num (.lit (F64.ofNat n.dtype)), [])) := by
  have hs : symOf chars!"mlx_array_dtype" = some .arrayDtype := by decide +kernel
  unfold call
  rw [hs]
  simp only [argNat_big_nat, Option.bind_some, hn, ok]

/-- Shape metadata is returned as ordinary integer data. The same integer
may occur elsewhere as a native handle without imposing a role on this rank. -/
theorem ndim_roles {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (hr : LiveNative R H N O tail s s') (h : Nat) (hh : H h) (n : Node)
    (hn : s.node? h = some n) :
    ∃ n', s'.node? (R.handle h) = some n' ∧
      call s chars!"mlx_array_ndim" [.big (Int.ofNat h)] =
        M.pure (some (s, Ret.big (len n.shape), [])) ∧
      call s' chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle h))] =
        M.pure (some (s', Ret.big (len n'.shape), [])) ∧
      RetR R (.big (len n.shape)) (.big (len n'.shape)) := by
  obtain ⟨n', hn', hshape, _⟩ := hr.node? hh hn
  refine ⟨n', hn', call_ndim s h n hn, call_ndim s' _ n' hn', ?_⟩
  rw [hshape, len_map]
  exact .ordinaryBig _

theorem shape_roles {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (hr : LiveNative R H N O tail s s') (h : Nat) (hh : H h) (n : Node)
    (hn : s.node? h = some n) (hregion : R.region (4*h) = 4 * R.handle h) :
    call s chars!"mlx_array_shape" [.big (Int.ofNat h)] =
        M.pure (some (s, Ret.ptr (4*h) 0, [])) ∧
      call s' chars!"mlx_array_shape" [.big (Int.ofNat (R.handle h))] =
        M.pure (some (s', Ret.ptr (4 * R.handle h) 0, [])) ∧
      RetR R (.ptr (4*h) 0) (.ptr (4 * R.handle h) 0) := by
  obtain ⟨n', hn', _, _⟩ := hr.node? hh hn
  refine ⟨call_shape s h n hn, call_shape s' _ n' hn', ?_⟩
  rw [← hregion]
  exact .ptr _ _

theorem dtype_roles {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (hr : LiveNative R H N O tail s s') (h : Nat) (hh : H h) (n : Node)
    (hn : s.node? h = some n) :
    ∃ n', s'.node? (R.handle h) = some n' ∧
      call s chars!"mlx_array_dtype" [.big (Int.ofNat h)] =
        M.pure (some (s, Ret.num (.lit (F64.ofNat n.dtype)), [])) ∧
      call s' chars!"mlx_array_dtype" [.big (Int.ofNat (R.handle h))] =
        M.pure (some (s', Ret.num (.lit (F64.ofNat n'.dtype)), [])) ∧
      RetR R (.num (.lit (F64.ofNat n.dtype))) (.num (.lit (F64.ofNat n'.dtype))) := by
  obtain ⟨n', hn', _, hdt⟩ := hr.node? hh hn
  refine ⟨n', hn', call_dtype s h n hn, call_dtype s' _ n' hn', ?_⟩
  rw [hdt]
  exact .num _

theorem read_shape (s : St) (h : Nat) (n : Node) (hn : s.node? h = some n) (off count : Nat) :
    read s (4*h) off count = some (((shapeBytes n.shape).drop off).take count) := by
  have hm : 4*h % 4 = 0 := by omega
  have hd : 4*h / 4 = h := by omega
  simp only [read, hm, hd, hn, Option.map_some]

theorem cellBytes_roles {R : Ren} {cs cs' : List Cell} (k : EltK)
    (h : ListR (CellR R) cs cs') : ListR (ByteR R) (cellBytes k cs) (cellBytes k cs') := by
  induction h with
  | nil => exact .nil
  | cons hc _ ih => exact (cellParts_related hc k k.size 0).append ih

theorem shapeBytes_roles (R : Ren) (shape : List Dim) :
    ListR (ByteR R) (shapeBytes shape) (shapeBytes (shape.map R.dim)) := by
  apply cellBytes_roles
  induction shape with
  | nil => exact .nil
  | cons d ds ih =>
    simp only [List.map_cons]
    rw [Ren.dim_num]
    exact .cons (.num _) ih

/-- The real native memory read returns the carrier's dimensions, including
symbolic dimension numbers; it does not substitute a fixed capacity literal. -/
theorem read_shape_roles {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (hr : LiveNative R H N O tail s s') (h : Nat) (hh : H h) (n : Node)
    (hn : s.node? h = some n) (off count : Nat) :
    ∃ bs bs', read s (4*h) off count = some bs ∧
      read s' (4 * R.handle h) off count = some bs' ∧ ListR (ByteR R) bs bs' := by
  obtain ⟨n', hn', hshape, _⟩ := hr.node? hh hn
  refine ⟨_, _, read_shape s h n hn off count, read_shape s' _ n' hn' off count, ?_⟩
  rw [hshape]
  exact ((shapeBytes_roles R n.shape).drop off).take count

theorem cellBytes_nth (k : EltK) : ∀ (cs : List Cell) (i : Nat) (c : Cell),
    nth? cs i = some c →
    ((cellBytes k cs).drop (i*k.size)).take k.size = cellParts k c k.size 0
  | [], i, _, hn => by cases i <;> cases hn
  | a :: cs, 0, c, hn => by
    have he : a = c := Option.some.inj hn
    subst c
    simp only [Nat.zero_mul, List.drop_zero, cellBytes]
    exact List.take_left' (cellParts_length k a k.size 0)
  | a :: cs, i+1, c, hn => by
    have hd : (cellParts k a k.size 0 ++ cellBytes k cs).drop k.size = cellBytes k cs :=
      List.drop_left' (cellParts_length k a k.size 0)
    simp only [cellBytes, Nat.succ_mul, Nat.add_comm (i*k.size), ← List.drop_drop, hd]
    exact cellBytes_nth k cs i c hn

/-- One int32 read exposes exactly the chosen carrier dimension. Both literal
and symbolic dimensions are covered; capacity is supplied by the carrier. -/
theorem read_shape_dimension (s : St) (h : Nat) (n : Node) (hn : s.node? h = some n)
    (i : Nat) (d : Dim) (hi : nth? n.shape i = some d) :
    read s (4*h) (i*4) 4 = some (cellParts .i32 (.num d.num) 4 0) := by
  rw [read_shape s h n hn]
  apply congrArg some
  have hm := nth?_map (fun d : Dim => Cell.num d.num) n.shape i
  rw [hi] at hm
  exact cellBytes_nth .i32 _ i (.num d.num) hm

private theorem len_eq_length (xs : List α) : len xs = xs.length := by
  have h : ∀ (xs : List α) (n : Nat), lenL xs n = xs.length + n := by
    intro xs
    induction xs with
    | nil => intro n; simp only [lenL, List.length_nil, Nat.zero_add]
    | cons x xs ih => intro n; simp only [lenL, List.length_cons, ih]; omega
  simpa only [len, Nat.add_zero] using h xs 0

theorem shapeBytes_length (shape : List Dim) :
    (shapeBytes shape).length = len shape * 4 := by
  have h : ∀ cs : List Cell, (cellBytes .i32 cs).length = cs.length * 4 := by
    intro cs
    induction cs with
    | nil => rfl
    | cons c cs ih =>
      simp only [cellBytes, List.length_append, cellParts_length, ih, List.length_cons]
      change 4 + cs.length * 4 = (cs.length+1) * 4
      omega
  rw [shapeBytes, h, List.length_map, len_eq_length]

theorem read_shape_full (s : St) (h : Nat) (n : Node) (hn : s.node? h = some n) :
    read s (4*h) 0 (len n.shape * 4) = some (shapeBytes n.shape) := by
  rw [read_shape s h n hn, List.drop_zero, ← shapeBytes_length, List.take_length]

inductive WriteR (R : Ren) : (Nat × Nat × List Byte) → (Nat × Nat × List Byte) → Prop where
  | buffer {bs bs' : List Byte} (b off : Nat) : ListR (ByteR R) bs bs' →
      WriteR R (b, off, bs) (R.a b, off, bs')

theorem u64Write_roles (R : Ren) (b off h : Nat) :
    WriteR R (u64Write b off h) (u64Write (R.a b) off (R.handle h)) :=
  .buffer b off (cellParts_related (.handle h) .u64 8 0)

inductive ResultR (R : Ren) (State : St → St → Prop) :
    Option (St × Ret × List (Nat × Nat × List Byte)) →
    Option (St × Ret × List (Nat × Nat × List Byte)) → Prop where
  | rejected : ResultR R State none none
  | returned {s s' : St} {r r' : Ret} {ws ws' : List (Nat × Nat × List Byte)} :
      State s s' → RetR R r r' → ListR (WriteR R) ws ws' →
      ResultR R State (some (s, r, ws)) (some (s', r', ws'))

def CreatedR (R : Ren) (H N O : Nat → Prop) (tail : List NumV) (s u u' : St) : Prop :=
  u.next = s.next+1 ∧ u.nnext = s.nnext+1 ∧
    LiveNative R (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i)
      (fun i => i ≠ s.nnext ∧ O i) tail u u'

theorem create_node_roles {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (hr : LiveNative R H N O tail s s') (n n' : Node) (hnodes : NodeR R False n n')
    (hn : s.nnext / 4096 < 4^31) (hn' : s'.nnext / 4096 < 4^31)
    (hh : s.next / 4096 < 4^31) (hh' : s'.next / 4096 < 4^31) :
    CreatedR R H N O tail s ((s.addNode n).2.setArr 0 s.nnext).2
      ((s'.addNode n').2.setArr 0 s'.nnext).2 := by
  have hnode := hr.addNode n n' hnodes hn hn'
  have hhandle := hnode.setArr_zero s.nnext (.inl rfl) hh hh'
  have hf : R.node s.nnext = s'.nnext := by simpa using hr.nodeFresh 0
  rw [hf] at hhandle
  exact ⟨rfl, rfl, hhandle⟩

/-- A real leaf constructor creates matching fresh graph nodes and handles.
The uint64 output slot is related using its handle role. -/
theorem leafOut_zero_roles {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (hr : LiveNative R H N O tail s s') (o o' : Arg) (b off : Nat)
    (p : Prim) (shape : List Dim) (dt : Nat)
    (ho : slotOf o = some (b, off, 0)) (ho' : slotOf o' = some (R.a b, off, 0))
    (hn : s.nnext / 4096 < 4^31) (hn' : s'.nnext / 4096 < 4^31)
    (hh : s.next / 4096 < 4^31) (hh' : s'.next / 4096 < 4^31) :
    ComputationR R (ResultR R (CreatedR R H N O tail s))
      (leafOut s o p shape dt) (leafOut s' o' (R.prim p) (shape.map R.dim) dt) := by
  let n : Node := ⟨p, [], shape, dt⟩
  let n' : Node := ⟨R.prim p, [], shape.map R.dim, dt⟩
  have hnodes : NodeR R False n n' := ⟨rfl, rfl, .inr ⟨rfl, rfl⟩⟩
  have hs := create_node_roles hr n n' hnodes hn hn' hh hh'
  have hf : R.handle s.next = s'.next := by simpa using hr.handleFresh 0
  have hw := u64Write_roles R b off s.next
  rw [hf] at hw
  unfold leafOut
  rw [ho, ho']
  apply ComputationR.pure
  exact .returned hs (.num zeroN) (.cons hw .nil)

end Host.Mlx.Ffi.Owned

namespace Host.Load.Owned
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi

/-- The load-world dispatcher retains the complete host state on metadata calls. -/
theorem call_shape (s : LSt) (h : Nat) (n : Node) (hn : s.mlx.node? h = some n) :
    Host.Load.call s chars!"mlx_array_shape" [.big (Int.ofNat h)] =
      M.pure (some (s, Ret.ptr (4*h) 0, [])) := by
  have hm : isMlx chars!"mlx_array_shape" = true := by decide +kernel
  have hc := Host.Mlx.Ffi.Owned.call_shape s.mlx h n hn
  funext β k
  simp only [Host.Load.call, hm, Bool.cond_true, hc, M.bind, M.pure]

theorem call_ndim (s : LSt) (h : Nat) (n : Node) (hn : s.mlx.node? h = some n) :
    Host.Load.call s chars!"mlx_array_ndim" [.big (Int.ofNat h)] =
      M.pure (some (s, Ret.big (len n.shape), [])) := by
  have hm : isMlx chars!"mlx_array_ndim" = true := by decide +kernel
  have hc := Host.Mlx.Ffi.Owned.call_ndim s.mlx h n hn
  funext β k
  simp only [Host.Load.call, hm, Bool.cond_true, hc, M.bind, M.pure]

theorem read_shape (s : LSt) (h : Nat) (n : Node) (hn : s.mlx.node? h = some n)
    (off count : Nat) :
    Host.Load.read s (4*h) off count = some (((shapeBytes n.shape).drop off).take count) := by
  have hm : (4*h) % 4 = 0 := by omega
  simp only [Host.Load.read, hm]
  exact Host.Mlx.Ffi.Owned.read_shape s.mlx h n hn off count

theorem read_shape_dimension (s : LSt) (h : Nat) (n : Node) (hn : s.mlx.node? h = some n)
    (i : Nat) (d : Dim) (hi : nth? n.shape i = some d) :
    Host.Load.read s (4*h) (i*4) 4 = some (cellParts .i32 (.num d.num) 4 0) := by
  rw [read_shape s h n hn]
  have hm := nth?_map (fun d : Dim => Cell.num d.num) n.shape i
  rw [hi] at hm
  exact congrArg some (Host.Mlx.Ffi.Owned.cellBytes_nth .i32 _ i (.num d.num) hm)

theorem bufBytes_shape (s : Host.Ts.St LSt) (b h : Nat) (bo : Host.Ts.Obj) (n : Node)
    (ho : s.obj? b = some bo)
    (hk : bo.kind = .extBuf (4*h) 0 (len n.shape * 4)) (hn : s.ffi.mlx.node? h = some n) :
    bufBytes ffi s b = some (shapeBytes n.shape) := by
  obtain ⟨kind, proto, props, priv, ext⟩ := bo
  dsimp only at hk
  subst kind
  change (match s.obj? b with
    | some ⟨.buf bs, _, _, _, _⟩ => some bs
    | some ⟨.extBuf r off count, _, _, _, _⟩ => Host.Load.read s.ffi r off count
    | _ => none) = _
  rw [ho]
  change Host.Load.read s.ffi (4*h) 0 (len n.shape * 4) = _
  rw [read_shape s.ffi h n hn, List.drop_zero, ← Host.Mlx.Ffi.Owned.shapeBytes_length,
    List.take_length]

/-- The actual int32 shape view returns the selected native carrier dimension
as a JavaScript number, before the source capacity comparison. -/
theorem typedGet_shape_dimension (s : Host.Ts.St LSt) (b h i : Nat) (bo : Host.Ts.Obj)
    (n : Node) (d : Dim) (ho : s.obj? b = some bo)
    (hk : bo.kind = .extBuf (4*h) 0 (len n.shape * 4)) (hn : s.ffi.mlx.node? h = some n)
    (hi : nth? n.shape i = some d) (hb : Nat.blt i (len n.shape) = true) :
    typedGet ffi s .i32 b 0 (len n.shape) i =
      M.pure (some (.data (.num d.num) true true)) := by
  have hbuf := bufBytes_shape s b h bo n ho hk hn
  have hm := nth?_map (fun d : Dim => Cell.num d.num) n.shape i
  rw [hi] at hm
  have hs := Host.Mlx.Ffi.Owned.cellBytes_nth .i32 _ i (.num d.num) hm
  change ((shapeBytes n.shape).drop (i*4)).take 4 = cellParts .i32 (.num d.num) 4 0 at hs
  have hr : readCell .i32 ((shapeBytes n.shape).drop (i*4)) = some (.num d.num) := by
    unfold readCell
    change (match wholeCell .i32 (((shapeBytes n.shape).drop (i*4)).take 4) 4 with
      | some c => some c
      | none => _) = _
    rw [hs]
    rfl
  simp only [typedGet, hb, Bool.cond_true, hbuf, Nat.zero_add, show EltK.i32.size = 4 from rfl, hr, cellVal]

end Host.Load.Owned

namespace Host.Ts.Owned

/-- The actual Bun buffer conversion allocates a view over native shape
memory. Offset and byte count are explicit arguments, with their real decoders. -/
theorem ffiN_toArrayBuffer_ext (F : Ffi) (s : St F.S) (this : Val) (data : List Val)
    (r origin off count : Nat) (offV countV : Val)
    (ho : offsetArg offV = M.pure off) (hc : offsetArg countV = M.pure count) :
    ffiN F s this [.ptr (.ext r) origin, offV, countV] data .toArrayBuffer =
      let (b, u) := s.allocObj (.extBuf r (origin+off) count) (.obj aArrayBufferProto) []
      retS F u (.obj b) := by
  simp only [ffiN, arg, nthD, ho, hc]
  rfl

end Host.Ts.Owned
