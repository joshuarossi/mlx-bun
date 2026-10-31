import host.sim.compose.a4b.D1InputValues
import host.sim.template.a4pre_d1_input.Native
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split.ND.Input
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
open Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Layers Host.Load.Run.Tpl.D1InputNative
open Host.Mlx.Ffi (Dim Node)
theorem shape_value {M : Map} {ν : Nat → F64} {C : CSrv}
    (hs : Srv M ν ND.ndSrv C) (hv : ν 9 = F64.ofNat 1) :
    C.val (M.num 18) = some (F64.ofNat 1) := by
  have h := hs.num 18 _ Values.ref18
  simpa only [SymE.eval, hv, show F64.un .int32 (F64.ofNat 1) = F64.ofNat 1 from rfl] using h

theorem copied {M : Map} {ν : Nat → F64} {C : CSrv} {π : List Nat}
    (hs : Srv M ν ND.ndSrv C) (hv : ν 9 = F64.ofNat 1) (hlen : π.length = 1) :
    copy (M.dims [.lit 1, .sym (.ref 18)]) 7 (D1Typed.bytes π) = D1Typed.bytes π := by
  have dv : DV M C (.sym (.ref 18)) 1 := .inr ⟨18, rfl, shape_value hs hv⟩
  change copy [Dim.lit 1, M.dim (.sym (.ref 18))] 7 (D1Typed.bytes π) = _
  rcases dv.dim (by decide) with he | ⟨j, he, _⟩ <;> rw [he]
  · cases π with
    | nil => cases hlen
    | cons k ks =>
      cases ks with
      | nil => rfl
      | cons l ls => simp at hlen
  · rfl



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
      some (M.dims [.lit 1, .sym (.ref 18)]) := hr.dimsArg_map hdims Values.shape
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
  refine ⟨Nat.lt_succ_self _, D1Typed.bytes π, M.dims [.lit 1, .sym (.ref 18)], ?_, bytes_read hvc C, ?_⟩
  · change ((mlxOf y).nodes.set (mlxOf y).nnext
      ⟨.data (copy (M.dims [.lit 1, .sym (.ref 18)]) 7 (D1Typed.bytes π)), [],
        M.dims [.lit 1, .sym (.ref 18)], 7⟩).get (mlxOf y).nnext = _
    rw [PTrie.gs _ _ _ hr.ynnext_lt, ite_eq_left rfl, copied hs hv hlen]
    rfl
  · change [Host.Mlx.Ffi.Dim.lit 1, Host.Mlx.Ffi.dimOf (M.num 18)].mapM (concrete C.val).d = _
    simp only [List.mapM_cons, List.mapM_nil]
    rw [concrete_dimOf C.val (fun _ => rfl), show (concrete C.val).dim (M.num 18) = some 1 from by
      change (C.val (M.num 18)).bind F64.toInt? = some 1
      rw [shape_value hs hv]; rfl]
    rfl

end Host.Ts.Sim.Compose.D1Split.ND.Input
