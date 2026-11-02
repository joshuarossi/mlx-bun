import host.sim.compose.a4b.x4_L8.InputValues
import host.sim.template.a4pre_d1_input.Native
import host.sim.compose.a4b.VWInputProperty
import host.mlx.NativeSizeGeometry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8.ND.Input
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
open Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Layers Host.Load.Run.Tpl.D1InputNative
open Host.Mlx.Ffi (Dim Node)
theorem tokenBytes_length (π : List Nat) : (tokenBytes π).length = π.length * 4 := by
  induction π with
  | nil => rfl
  | cons k ks ih =>
    change (cellParts .i32 (Disp.i32Cell (F64.ofNat k)) 4 0 ++ tokenBytes ks).length = (ks.length + 1) * 4
    simp only [List.length_append, cellParts, List.length_cons, List.length_nil, ih]
    omega

theorem copied {M : Map} {π : List Nat} (hlen : π.length = 7) :
    copy (M.dims [.lit 1, .lit 7]) 7 (tokenBytes π) = tokenBytes π := by
  change copy [Dim.lit 1, Dim.lit 7] 7 (tokenBytes π) = _
  have hds : Host.Mlx.Ffi.natsOfDims [Dim.lit 1, Dim.lit 7] = some [1, 7] :=
    Host.Mlx.Ffi.Annotated.natsOfDims_natural [1, 7]
  unfold copy
  rw [hds]
  change (tokenBytes π).take ((1 * (7 * 1)) * 4) = tokenBytes π
  simp only [Nat.mul_one, Nat.one_mul]
  rw [← hlen, ← tokenBytes_length π, List.take_length]

theorem call_input {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {C C' : CSrv}
    {y y' : FF.S} {π : List Nat} {ret : Ret} {ws : List (Nat × Nat × List Byte)}
    (hs : Srv M ν ND.ndSrv C)
    (hr : G.MR P NB M ND.ndSrv.tab.length (mlxOf PRE_first_tail_x4_L8_r0.s33.ffi) (mlxOf y))
    (hi : (bridgeOf y).active = false)
    (hok : G.dataOk P (mlxOf PRE_first_tail_x4_L8_r0.s33.ffi) ND.ndArgs = true)
    (hv : ν 1008 = F64.ofNat π.length) (hsmall : π.length < 2 ^ 31) (hlen : π.length = 7) (hvc : ∀ k ∈ π, k < 248320)
    (hc : interpC (FF.call y chars!"mlx_array_new_data"
      (.jsPtr (M.a VWFrames.buffer) 0 (tokenBytes π) :: ND.ndArgs.map M.arg)).run C =
        some (some (y', ret, ws), C')) :
    M.node 15235 < (mlxOf y').nnext ∧
      HostInt32 (concrete C'.val) (mlxOf y') (M.node 15235) (π.map Int.ofNat) [1, π.length] := by
  let sh := nthD (Arg.big 0) ND.ndArgs 0
  let nd := nthD (Arg.big 0) ND.ndArgs 1
  let dt := nthD (Arg.big 0) ND.ndArgs 2
  have ea : ND.ndArgs = [sh, nd, dt] := Values.args
  rw [ea] at hok
  simp only [G.dataOk, Bool.and_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨⟨⟨hdims, hdt⟩, -⟩, -⟩, -⟩ := hok
  have hs' : Host.Mlx.Ffi.dimsArg (M.arg sh) (M.arg nd) =
      some (M.dims [.lit 1, .lit 7]) := hr.dimsArg_map hdims Values.shape
  have hd' : Host.Mlx.Ffi.argNat (M.arg dt) = some 7 :=
    (hr.natOk_argNat hdt).trans Values.dtype
  obtain ⟨z, hz, he⟩ := full_call y (M.a VWFrames.buffer) (tokenBytes π)
    (M.arg sh) (M.arg nd) (M.arg dt) _ 7 hi hs' hd'
  rw [ea] at hc
  change interpC (FF.call y chars!"mlx_array_new_data" [Arg.jsPtr (M.a VWFrames.buffer) 0 (tokenBytes π), M.arg sh, M.arg nd, M.arg dt]).run C = some (some (y', ret, ws), C') at hc
  rw [he] at hc
  change some (some (z, Ret.big (Int.ofNat (mlxOf y).next), []), C) = some (some (y', ret, ws), C') at hc
  cases hc
  have ej : M.node 15235 = (mlxOf y).nnext := by
    simpa only [Values.pre_nnext] using hr.node_next
  rw [ej, hz]
  refine ⟨Nat.lt_succ_self _, tokenBytes π, M.dims [.lit 1, .lit 7], ?_, (show (tokenBytes π).mapM (concrete C.val).byte = some (cellsBytes (π.map Int.ofNat)) from bytes_read hvc C), ?_⟩
  · change ((mlxOf y).nodes.set (mlxOf y).nnext
      ⟨.data (copy (M.dims [.lit 1, .lit 7]) 7 (tokenBytes π)), [],
        M.dims [.lit 1, .lit 7], 7⟩).get (mlxOf y).nnext = _
    rw [PTrie.gs _ _ _ hr.ynnext_lt, ite_eq_left rfl, copied hlen]
    rfl
  · rw [hlen]
    rfl

end Host.Ts.Sim.Compose.VWFirst.X4_L8.ND.Input
