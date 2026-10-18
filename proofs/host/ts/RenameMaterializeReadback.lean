import host.ts.RenameMaterializeState
import host.ts.RenameReadback
import host.ts.RenameWrites
set_option maxRecDepth 1000000
namespace Host.Ts

private theorem mlxFfi_call_eq : Host.Mlx.Ffi.ffi.call = Host.Mlx.Ffi.call := by
  unfold Host.Mlx.Ffi.ffi
  exact ffi_call_mk Host.Mlx.Ffi.St Host.Mlx.Ffi.call Host.Mlx.Ffi.read
    (fun _ => 4096) Host.Mlx.Ffi.back

theorem materializeNative_nodeId (C : CSrv) (s : Host.Mlx.Ffi.St) (h : Nat) :
    (materializeNative C s).nodeId? h = s.nodeId? h := rfl

theorem materializeNative_node (C : CSrv) (s : Host.Mlx.Ffi.St) (h : Nat) :
    (materializeNative C s).node? h = (s.node? h).map (materializer C).nativeNode := by
  unfold Host.Mlx.Ffi.St.node?
  change (s.arrs.get h).bind (s.nodes.map (materializer C).nativeNode).get = _
  cases hi : s.arrs.get h with
  | none => rfl
  | some i => simp only [Option.bind_some, PTrie.get_map]

theorem materializeNative_recordRead (C : CSrv) (s : Host.Mlx.Ffi.St) (i : Nat) (t : NumV) (ts : List NumV) :
    materializeNative C { s with tokens := ts, items := s.items.set i t } =
      { materializeNative C s with
        tokens := ts.map (materializer C).num
        items := (materializeNative C s).items.set i ((materializer C).num t) } := by
  unfold materializeNative
  dsimp only
  rw [PTrie.map_set]

end Host.Ts

namespace Host.Mlx.Ffi
open Host.Ts

theorem itemU32_first_pure (s : St) (b off : Nat) (bs : List Byte)
    (handle node : Nat) (n : Node) (token : NumV) (tail : List NumV)
    (hid : s.nodeId? handle = some node) (hn : s.node? handle = some n)
    (hd : Nat.beq n.dtype dtUint32 = true) (hm : s.items.get node = none)
    (ht : s.tokens = token :: tail) :
    call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, .big (Int.ofNat handle)] =
      M.pure (some ({ s with tokens := tail, items := s.items.set node token }, status0,
        [(b, off, cellParts .u32 (.num token) 4 0)])) := by
  rw [call_itemU32_eq]
  simp only [argNat_big_nat, Option.bind_some, hid, hn, hd, Bool.cond_true, hm, ht, okW]

/-- Actual native readback commutes with numeric materialization, including the
memoized item, consumed queue head, buffer write and complete remaining native state. -/
theorem call_itemU32_materialize (C : CSrv) (s : St) (b off : Nat) (bs : List Byte)
    (handle node : Nat) (n : Node) (token : NumV) (tail : List NumV)
    (hid : s.nodeId? handle = some node) (hn : s.node? handle = some n)
    (hd : Nat.beq n.dtype dtUint32 = true) (hm : s.items.get node = none)
    (ht : s.tokens = token :: tail) :
    let u := { s with tokens := tail, items := s.items.set node token }
    call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, .big (Int.ofNat handle)] =
        M.pure (some (u, status0, [(b, off, cellParts .u32 (.num token) 4 0)])) ∧
      call (materializeNative C s) chars!"mlx_array_item_uint32"
        [.jsPtr b off (bs.map (materializer C).byte), .big (Int.ofNat handle)] =
        M.pure (some (materializeNative C u, status0,
          [(b, off, cellParts .u32 (.num ((materializer C).num token)) 4 0)])) := by
  dsimp only
  have hn' : (materializeNative C s).node? handle = some ((materializer C).nativeNode n) := by
    rw [materializeNative_node, hn]
    rfl
  have hm' : (materializeNative C s).items.get node = none := by
    change (s.items.map (materializer C).num).get node = none
    rw [PTrie.get_map, hm]
    rfl
  have ht' : (materializeNative C s).tokens =
      (materializer C).num token :: tail.map (materializer C).num := by
    change s.tokens.map (materializer C).num = _
    rw [ht]
    rfl
  constructor
  · exact itemU32_first_pure s b off bs handle node n token tail hid hn hd hm ht
  · rw [materializeNative_recordRead]
    apply itemU32_first_pure (materializeNative C s) b off (bs.map (materializer C).byte)
      handle node ((materializer C).nativeNode n)
      ((materializer C).num token) (tail.map (materializer C).num)
    · simp only [materializeNative_nodeId]
      exact hid
    · exact hn'
    · exact hd
    · exact hm'
    · exact ht'

end Host.Mlx.Ffi

namespace Host.Ts

/-- A complete actual interpreter step for the native uint32 readback, from the
JS function lookup through argument decoding, the real MLX call, buffer mutation,
trace event, and status return. Numeric materialization preserves its entire result. -/
theorem step_itemU32_materialize (C : CSrv) (s : St Host.Mlx.Ffi.St)
    (fn types b off handle node : Nat) (returns : Name) (fo to bo : Obj) (bs : List Byte)
    (n : Host.Mlx.Ffi.Node) (token : NumV) (tail : List NumV)
    (hc : s.ctl = .call (.obj fn) .undef [.ptr (.js b) off, .big (Int.ofNat handle)])
    (hfn : s.obj? fn = some fo)
    (hfk : fo.kind = .fn (.native (.ffi .symbol)
      [.str chars!"mlx_array_item_uint32", .obj types, .str returns]))
    (ht : s.obj? types = some to) (htk : to.kind = .array [.str chars!"ptr", .str chars!"u64"])
    (hb : s.obj? b = some bo) (hbk : bo.kind = .buf bs)
    (hid : s.ffi.nodeId? handle = some node) (hn : s.ffi.node? handle = some n)
    (hd : Nat.beq n.dtype Host.Mlx.Ffi.dtUint32 = true) (hm : s.ffi.items.get node = none)
    (hqueue : s.ffi.tokens = token :: tail) :
    let native := { s.ffi with tokens := tail, items := s.ffi.items.set node token }
    let writes := [(b, off, cellParts .u32 (.num token) 4 0)]
    let args := [Arg.jsPtr b off (bs.drop off), .big (Int.ofNat handle)]
    let u := (s.setFfi native).setObj b { bo with
      kind := .buf (bs.take off ++ cellParts .u32 (.num token) 4 0 ++ bs.drop (off + 4)) }
    let t := (u.setTrace (⟨chars!"mlx_array_item_uint32", args, Host.Mlx.Ffi.status0⟩ :: u.trace)).ret (.num zeroN)
    step Host.Mlx.Ffi.ffi s = M.pure t ∧
      step Host.Mlx.Ffi.ffi (materializeState C s) = M.pure (materializeState C t) := by
  dsimp only
  let native := { s.ffi with tokens := tail, items := s.ffi.items.set node token }
  let writes := [(b, off, cellParts .u32 (.num token) 4 0)]
  let args := [Arg.jsPtr b off (bs.drop off), .big (Int.ofNat handle)]
  let u := (s.setFfi native).setObj b { bo with
    kind := .buf (bs.take off ++ cellParts .u32 (.num token) 4 0 ++ bs.drop (off + 4)) }
  have hcall := Host.Mlx.Ffi.call_itemU32_materialize C s.ffi b off (bs.drop off)
    handle node n token tail hid hn hd hm hqueue
  have hcall0 : Host.Mlx.Ffi.ffi.call s.ffi chars!"mlx_array_item_uint32"
      [Arg.jsPtr b off (bs.drop off), .big (Int.ofNat handle)] =
      M.pure (some (native, Host.Mlx.Ffi.status0, writes)) := by
    rw [mlxFfi_call_eq]
    exact hcall.1
  have hbuf := bufBytes_of_obj Host.Mlx.Ffi.ffi s b bo bs hb hbk
  have hw : applyWrites Host.Mlx.Ffi.ffi (s.setFfi native) writes = some u := by
    have hb' : (s.setFfi native).obj? b = some bo := hb
    exact applyWrites_one_buffer Host.Mlx.Ffi.ffi (s.setFfi native) b off
      (cellParts .u32 (.num token) 4 0) bs bo hb' hbk
  have hdone := ffiDone_status0_materialize Host.Mlx.Ffi.ffi materializeNative C s u native
    chars!"mlx_array_item_uint32" args writes hw
  have hcs : (materializeState C s).ctl =
      .call (.obj fn) .undef [.ptr (.js b) off, .big (Int.ofNat handle)] := by
    change (materializer C).ctl s.ctl = _
    rw [hc]
    rfl
  have hfn' : (materializeState C s).obj? fn = some ((materializer C).obj fo) := by
    rw [materializeStateWith_obj, hfn]
    rfl
  have hfk' : ((materializer C).obj fo).kind = .fn (.native (.ffi .symbol)
      [.str chars!"mlx_array_item_uint32", .obj types, .str returns]) := by
    change (materializer C).kind fo.kind = _
    rw [hfk]
    rfl
  have ht' : (materializeState C s).obj? types = some ((materializer C).obj to) := by
    rw [materializeStateWith_obj, ht]
    rfl
  have htk' : ((materializer C).obj to).kind = .array [.str chars!"ptr", .str chars!"u64"] := by
    change (materializer C).kind to.kind = _
    rw [htk]
    rfl
  have hb' : (materializeState C s).obj? b = some ((materializer C).obj bo) := by
    rw [materializeStateWith_obj, hb]
    rfl
  have hbk' : ((materializer C).obj bo).kind = .buf (bs.map (materializer C).byte) := by
    change (materializer C).kind bo.kind = _
    rw [hbk]
  have hbuf' := bufBytes_of_obj Host.Mlx.Ffi.ffi (materializeState C s) b ((materializer C).obj bo)
    (bs.map (materializer C).byte) hb' hbk'
  constructor
  · rw [step_ffi_ptr_u64 Host.Mlx.Ffi.ffi s fn types b off (Int.ofNat handle)
      chars!"mlx_array_item_uint32" returns fo to bs native Host.Mlx.Ffi.status0 writes hc hfn hfk ht htk hbuf hcall0]
    exact hdone.1
  · have hcall' : Host.Mlx.Ffi.ffi.call (materializeState C s).ffi chars!"mlx_array_item_uint32"
        [.jsPtr b off ((bs.map (materializer C).byte).drop off), .big (Int.ofNat handle)] =
        M.pure (some (materializeNative C native, Host.Mlx.Ffi.status0, writes.map (materializer C).write)) := by
      rw [mlxFfi_call_eq]
      rw [materializeStateWith_ffi]
      dsimp only [Host.Mlx.Ffi.ffi]
      simpa only [native, writes, NameMap.write, List.map_cons, List.map_nil, List.map_drop,
        NameMap.cellParts, NameMap.cell, materializer, id_eq] using hcall.2
    rw [step_ffi_ptr_u64 Host.Mlx.Ffi.ffi (materializeState C s) fn types b off (Int.ofNat handle)
      chars!"mlx_array_item_uint32" returns ((materializer C).obj fo) ((materializer C).obj to)
      (bs.map (materializer C).byte) (materializeNative C native) Host.Mlx.Ffi.status0
      (writes.map (materializer C).write) hcs hfn' hfk' ht' htk' hbuf' hcall']
    dsimp only [Host.Mlx.Ffi.ffi] at hdone ⊢
    simpa only [native, u, args, materializeState, List.map_cons, List.map_nil, NameMap.arg,
      List.map_drop, materializer, id_eq] using hdone.2

end Host.Ts
