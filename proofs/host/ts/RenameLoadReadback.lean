import host.ts.RenameMaterializeReadback
import host.load.World
set_option maxRecDepth 1000000
namespace Host.Load
open Host.Ts

/-- Numeric specialization of the actual whole-process world. The environment,
files and other host facts are retained; only numeric MLX values are materialized. -/
def materializeWorld (C : CSrv) (s : LSt) : LSt :=
  { s with mlx := materializeNative C s.mlx }

theorem call_itemU32_materialize (C : CSrv) (s : LSt) (b off : Nat) (bs : List Byte)
    (handle node : Nat) (n : Host.Mlx.Ffi.Node) (token : NumV) (tail : List NumV)
    (hid : s.mlx.nodeId? handle = some node) (hn : s.mlx.node? handle = some n)
    (hd : Nat.beq n.dtype Host.Mlx.Ffi.dtUint32 = true) (hm : s.mlx.items.get node = none)
    (ht : s.mlx.tokens = token :: tail) :
    let u := { s with mlx := { s.mlx with tokens := tail, items := s.mlx.items.set node token } }
    call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, .big (Int.ofNat handle)] =
        M.pure (some (u, Host.Mlx.Ffi.status0, [(b, off, cellParts .u32 (.num token) 4 0)])) ∧
      call (materializeWorld C s) chars!"mlx_array_item_uint32"
        [.jsPtr b off (bs.map (materializer C).byte), .big (Int.ofNat handle)] =
        M.pure (some (materializeWorld C u, Host.Mlx.Ffi.status0,
          [(b, off, cellParts .u32 (.num ((materializer C).num token)) 4 0)])) := by
  dsimp only
  have h := Host.Mlx.Ffi.call_itemU32_materialize C s.mlx b off bs handle node n token tail hid hn hd hm ht
  have hmlx : isMlx chars!"mlx_array_item_uint32" = true := by decide +kernel
  constructor
  · funext β k
    simp only [call, hmlx, Bool.cond_true, h.1, M.bind, M.pure]
  · funext β k
    simp only [call, hmlx, Bool.cond_true, materializeWorld, h.2, M.bind, M.pure]

private theorem ffi_call_eq : ffi.call = call := by
  unfold ffi
  exact ffi_call_mk LSt call read (fun _ => 4096) back

/-- The complete native read step at the source generator's ordinary cut, using
the actual load-world dispatcher. It retains all host facts and real pending MLX
buffers while consuming the current read and recording its uint32 write. -/
theorem step_itemU32_materialize (C : CSrv) (s : St LSt)
    (fn types b off handle node : Nat) (returns : Name) (fo to bo : Obj) (bs : List Byte)
    (n : Host.Mlx.Ffi.Node) (token : NumV) (tail : List NumV)
    (hc : s.ctl = .call (.obj fn) .undef [.ptr (.js b) off, .big (Int.ofNat handle)])
    (hfn : s.obj? fn = some fo)
    (hfk : fo.kind = .fn (.native (.ffi .symbol)
      [.str chars!"mlx_array_item_uint32", .obj types, .str returns]))
    (ht : s.obj? types = some to) (htk : to.kind = .array [.str chars!"ptr", .str chars!"u64"])
    (hb : s.obj? b = some bo) (hbk : bo.kind = .buf bs)
    (hid : s.ffi.mlx.nodeId? handle = some node) (hn : s.ffi.mlx.node? handle = some n)
    (hd : Nat.beq n.dtype Host.Mlx.Ffi.dtUint32 = true) (hm : s.ffi.mlx.items.get node = none)
    (hqueue : s.ffi.mlx.tokens = token :: tail) :
    let native := { s.ffi with mlx := { s.ffi.mlx with tokens := tail, items := s.ffi.mlx.items.set node token } }
    let args := [Arg.jsPtr b off (bs.drop off), .big (Int.ofNat handle)]
    let u := (s.setFfi native).setObj b { bo with
      kind := .buf (bs.take off ++ cellParts .u32 (.num token) 4 0 ++ bs.drop (off + 4)) }
    let t := (u.setTrace (⟨chars!"mlx_array_item_uint32", args, Host.Mlx.Ffi.status0⟩ :: u.trace)).ret (.num zeroN)
    step ffi s = M.pure t ∧
      step ffi (materializeStateWith materializeWorld C s) =
        M.pure (materializeStateWith materializeWorld C t) := by
  dsimp only
  let native := { s.ffi with mlx := { s.ffi.mlx with tokens := tail, items := s.ffi.mlx.items.set node token } }
  let writes := [(b, off, cellParts .u32 (.num token) 4 0)]
  let u := (s.setFfi native).setObj b { bo with
    kind := .buf (bs.take off ++ cellParts .u32 (.num token) 4 0 ++ bs.drop (off + 4)) }
  have hcall := call_itemU32_materialize C s.ffi b off (bs.drop off)
    handle node n token tail hid hn hd hm hqueue
  have hcall0 : ffi.call s.ffi chars!"mlx_array_item_uint32"
      [Arg.jsPtr b off (bs.drop off), .big (Int.ofNat handle)] =
      M.pure (some (native, Host.Mlx.Ffi.status0, writes)) := by
    rw [ffi_call_eq]
    exact hcall.1
  have hcall1 : ffi.call (materializeWorld C s.ffi) chars!"mlx_array_item_uint32"
      [.jsPtr b off ((bs.map (materializer C).byte).drop off), .big (Int.ofNat handle)] =
      M.pure (some (materializeWorld C native, Host.Mlx.Ffi.status0, writes.map (materializer C).write)) := by
    rw [ffi_call_eq]
    dsimp only [ffi]
    simpa only [native, writes, NameMap.write, List.map_cons, List.map_nil, List.map_drop,
      NameMap.cellParts, NameMap.cell, materializer, id_eq] using hcall.2
  have hbuf := bufBytes_of_obj ffi s b bo bs hb hbk
  have hbo : (materializeStateWith materializeWorld C s).obj? b = some ((materializer C).obj bo) := by
    rw [materializeStateWith_obj, hb]
    rfl
  have hkind : ((materializer C).obj bo).kind = .buf (bs.map (materializer C).byte) := by
    change (materializer C).kind bo.kind = _
    rw [hbk]
  have hbuf' := bufBytes_of_obj ffi (materializeStateWith materializeWorld C s) b
    ((materializer C).obj bo) (bs.map (materializer C).byte) hbo hkind
  have hw : applyWrites ffi (s.setFfi native) writes = some u := by
    exact applyWrites_one_buffer ffi (s.setFfi native) b off (cellParts .u32 (.num token) 4 0)
      bs bo (show (s.setFfi native).obj? b = some bo from hb) hbk
  exact step_ffi_ptr_u64_materialize ffi materializeWorld C s u fn types b off (Int.ofNat handle)
    chars!"mlx_array_item_uint32" returns fo to bs native writes hc hfn hfk ht htk hbuf hbuf' hw hcall0 hcall1

end Host.Load
