import host.sim.compose.a4b.D1InputValues
import host.sim.template.a4pre_d1_input.Native
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split.ND.Input
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
open Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Layers Host.Load.Run.Tpl.D1InputNative
open Host.Mlx.Ffi (Dim Node)
theorem copied {M : Map} {π : List Nat} (hlen : π.length = 1) :
    copy (M.dims [.lit 1, .lit 1]) 7 (D1Typed.bytes π) = D1Typed.bytes π := by
  change copy [Dim.lit 1, Dim.lit 1] 7 (D1Typed.bytes π) = _
  cases π with
  | nil => cases hlen
  | cons k ks =>
    cases ks with
    | nil => rfl
    | cons l ls => simp at hlen

theorem call_input {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {C C' : CSrv}
    {y y' : FF.S} {π : List Nat} {ret : Ret} {ws : List (Nat × Nat × List Byte)}
    (hs : Srv M ν ND.ndSrv C)
    (hr : G.MR P NB M ND.ndSrv.tab.length (mlxOf D1StageSplit.s15.ffi) (mlxOf y))
    (hi : (bridgeOf y).active = false)
    (hok : G.dataOk P (mlxOf D1StageSplit.s15.ffi) ND.ndArgs = true)
    (hv : ν 9 = F64.ofNat 1) (hlen : π.length = 1) (hvc : ∀ k ∈ π, k < 248320)
    (hc : interpC (FF.call y chars!"mlx_array_new_data"
      (.jsPtr (M.a D1Frames.buffer) 0 (D1Typed.bytes π) :: ND.ndArgs.map M.arg)).run C =
        some (some (y', ret, ws), C')) :
    M.node 15235 < (mlxOf y').nnext ∧
      HostInt32 (concrete C'.val) (mlxOf y') (M.node 15235) (π.map Int.ofNat) [1,1] := by
  let sh := nthD (Arg.big 0) ND.ndArgs 0
  let nd := nthD (Arg.big 0) ND.ndArgs 1
  let dt := nthD (Arg.big 0) ND.ndArgs 2
  have ea : ND.ndArgs = [sh, nd, dt] := Values.args
  rw [ea] at hok
  simp only [G.dataOk, Bool.and_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨⟨⟨hdims, hdt⟩, -⟩, -⟩, -⟩ := hok
  have hs' : Host.Mlx.Ffi.dimsArg (M.arg sh) (M.arg nd) =
      some (M.dims [.lit 1, .lit 1]) := hr.dimsArg_map hdims Values.shape
  have hd' : Host.Mlx.Ffi.argNat (M.arg dt) = some 7 :=
    (hr.natOk_argNat hdt).trans Values.dtype
  obtain ⟨z, hz, he⟩ := full_call y (M.a D1Frames.buffer) (D1Typed.bytes π)
    (M.arg sh) (M.arg nd) (M.arg dt) _ 7 hi hs' hd'
  rw [ea] at hc
  change interpC (FF.call y chars!"mlx_array_new_data" [Arg.jsPtr (M.a D1Frames.buffer) 0 (D1Typed.bytes π), M.arg sh, M.arg nd, M.arg dt]).run C = some (some (y', ret, ws), C') at hc
  rw [he] at hc
  change some (some (z, Ret.big (Int.ofNat (mlxOf y).next), []), C) = some (some (y', ret, ws), C') at hc
  cases hc
  have ej : M.node 15235 = (mlxOf y).nnext := by
    simpa only [Values.pre_nnext] using hr.node_next
  rw [ej, hz]
  refine ⟨Nat.lt_succ_self _, D1Typed.bytes π, M.dims [.lit 1, .lit 1], ?_, bytes_read hvc C, ?_⟩
  · change ((mlxOf y).nodes.set (mlxOf y).nnext
      ⟨.data (copy (M.dims [.lit 1, .lit 1]) 7 (D1Typed.bytes π)), [],
        M.dims [.lit 1, .lit 1], 7⟩).get (mlxOf y).nnext = _
    rw [PTrie.gs _ _ _ hr.ynnext_lt, ite_eq_left rfl, copied hlen]
    rfl
  · rfl

end Host.Ts.Sim.Compose.D1Split.ND.Input
