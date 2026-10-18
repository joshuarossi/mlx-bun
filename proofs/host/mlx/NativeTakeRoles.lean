import host.mlx.NativeProducerInputs
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem node?_of_producer_head (s : St) (handle input : Nat) (handles inputs : List Nat) (node : Node)
    (producer : nodesOf s (handle::handles) = some (input::inputs))
    (sourceNode : s.nodes.get input = some node) : s.node? handle = some node := by
  cases hh : s.nodeId? handle with
  | none => simp only [nodesOf,hh,Option.bind_none] at producer; cases producer
  | some i =>
    cases ht : nodesOf s handles with
    | none => simp only [nodesOf,hh,Option.bind_some,ht,Option.map_none] at producer; cases producer
    | some rest =>
      simp only [nodesOf,hh,Option.bind_some,ht,Option.map_some] at producer
      cases producer
      simp only [St.node?,nodeId_some_array s handle input hh,Option.bind_some,sourceNode]

def takeNode (x y axis : Nat) (xn yn : Node) : Node :=
  ⟨.take axis,[x,y],xn.shape.take axis ++ yn.shape ++ xn.shape.drop (axis+1),xn.dtype⟩

theorem call_take_null (s : St) (out stream : Arg) (b off hx hy x y axis : Nat)
    (axisValue : F64) (axisInt : Int) (xn yn : Node)
    (slot : slotOf out = some (b,off,0))
    (producers : arrIns s [.big (Int.ofNat hx),.big (Int.ofNat hy)] = some [x,y])
    (input : s.node? hx = some xn)
    (metadata : shapesOf s [x,y] = some [(xn.shape,xn.dtype),(yn.shape,yn.dtype)])
    (axisDecode : F64.toInt? axisValue = some axisInt) (normalize : axisOf axisInt (len xn.shape) = some axis)
    (bounds : Nat.blt axis (len xn.shape) = true) (integer : isInteger yn.dtype = true) :
    Ffi.call s chars!"mlx_take_axis" [out,.big (Int.ofNat hx),.big (Int.ofNat hy),.num (.lit axisValue),stream] =
      okW (createZero s (takeNode x y axis xn yn)) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_take_axis" = some .take := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [producers,argInt,axisDecode,argNat_big_nat,Option.bind_some,input,normalize]
  exact opOut_node_zero s out b off (.take axis) [x,y] _ _ xn.dtype slot metadata
    (by simp only [infer,bounds,integer,Bool.and_true,Bool.cond_true])

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def takeShape (x y : Shape) (axis : Nat) : Shape := x.take axis ++ y ++ x.drop (axis+1)

theorem takeShape_holds {ν : Nat → F64} {C : CSrv} {x y : Shape} {xs ys : List Dim}
    (hx : Shape.Holds ν C x xs) (hy : Shape.Holds ν C y ys) (axis : Nat) :
    Shape.Holds ν C (takeShape x y axis) (xs.take axis ++ ys ++ xs.drop (axis+1)) :=
  ((hx.take axis).append hy).append (hx.drop (axis+1))

theorem takeShape_subst (θ : Nat → SymE) (x y : Shape) (axis : Nat) :
    Shape.subst θ (takeShape x y axis) = takeShape (Shape.subst θ x) (Shape.subst θ y) axis := by
  simp only [takeShape,Shape.subst,List.map_append,List.map_take,List.map_drop]

def takeRole (roles : Nat → GraphNode) (x y axis : Nat) : GraphNode :=
  ⟨takeShape (roles x).shape (roles y).shape axis,(roles x).dtype,some (.take axis,[x,y])⟩

theorem take_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {x y fresh : Nat} {xn xn' yn yn' : Node}
    (axis : Nat) (hx : NodeRel roles ν₀ ν C₀ C R boundary x xn xn')
    (hy : NodeRel roles ν₀ ν C₀ C R boundary y yn yn') :
    NodeRel (nodeWrite roles fresh (takeRole roles x y axis)) ν₀ ν C₀ C R boundary fresh
      (takeNode x y axis xn yn) (takeNode (R.node x) (R.node y) axis xn' yn') := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (takeRole roles x y axis).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨takeShape_holds hx.source.shape hy.source.shape axis,hx.source.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.take axis,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (takeRole roles x y axis).Holds ν C R _
    refine ⟨takeShape_holds hx.target.shape hy.target.shape axis,hx.target.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.take axis,rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem take_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off hx hy x y axis : Nat) (axisValue : F64) (axisInt : Int) (xn yn : Node)
    (handlesLive : listSupport H [hx,hy]) (producers : Ffi.nodesOf s [hx,hy] = some [x,y])
    (sourceX : s.nodes.get x = some xn) (sourceY : s.nodes.get y = some yn)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (axisDecode : F64.toInt? axisValue = some axisInt)
    (normalize : axisOf axisInt (len (roles x).shape) = some axis)
    (bounds : Nat.blt axis (len (roles x).shape) = true) (integer : isInteger (roles y).dtype = true)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ xn' yn',
      Ffi.call s chars!"mlx_take_axis" [out,.big (Int.ofNat hx),.big (Int.ofNat hy),.num (.lit axisValue),stream] =
        okW (NativeRoles.createZero s (takeNode x y axis xn yn)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_take_axis" [out',.big (Int.ofNat (R.handle hx)),.big (Int.ofNat (R.handle hy)),.num (.lit axisValue),stream'] =
        okW (NativeRoles.createZero s' (takeNode (R.node x) (R.node y) axis xn' yn')) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (takeRole roles x y axis)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (takeNode x y axis xn yn))
        (NativeRoles.createZero s' (takeNode (R.node x) (R.node y) axis xn' yn')) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [hx,hy] [x,y] handlesLive producers
  obtain ⟨xn',hx',hrx⟩ := h.node_view support.1 sourceX
  obtain ⟨yn',hy',hry⟩ := h.node_view support.2.1 sourceY
  have producer' := h.nodesOf [hx,hy] [x,y] handlesLive producers
  have metadata : Ffi.shapesOf s [x,y] = some [(xn.shape,xn.dtype),(yn.shape,yn.dtype)] := by
    simp only [Ffi.shapesOf,sourceX,sourceY,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node x,R.node y] = some [(xn'.shape,xn'.dtype),(yn'.shape,yn'.dtype)] := by
    simp only [Ffi.shapesOf,hx',hy',Option.bind_some,Option.map_some]
  exact ⟨xn',yn',call_take_null s out stream b off hx hy x y axis axisValue axisInt xn yn sourceSlot ha
      (node?_of_producer_head s hx x [hy] [y] xn producers sourceX) metadata axisDecode
      (by simpa only [← hrx.source.shape.len_eq] using normalize)
      (by simpa only [← hrx.source.shape.len_eq] using bounds) (by simpa only [hry.source.dtype] using integer),
    call_take_null s' out' stream' (R.a b) off (R.handle hx) (R.handle hy) (R.node x) (R.node y) axis axisValue axisInt xn' yn'
      targetSlot ha' (node?_of_producer_head s' _ _ _ _ xn' producer' hx') metadata' axisDecode
      (by simpa only [← hrx.target.shape.len_eq] using normalize)
      (by simpa only [← hrx.target.shape.len_eq] using bounds) (by simpa only [hry.target.dtype] using integer),
    h.createZeroRoles _ _ (take_created axis hrx hry)
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
