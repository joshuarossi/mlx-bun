import host.sim.native.Dispatch
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Proof of `FfiSim Host.Load.ffi (LoadR P) (okCall P) okBack` -/

theorem SA.of_supp {A : Nat → Prop} {n : Nat} {a : Arg} (h : Supp.arg A n a) (ho : NativeOk.notOther a = true) :
    SA (· < n) a := by
  cases a with
  | num x => exact SN.of_supp (A := A) h
  | jsPtr b o bs => exact SBs.of_supp h.2
  | other _ => cases ho
  | _ => trivial

section
variable {P : LoadP} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P M S.tab.length x y)
include hs hr

local notation "SIM" args => MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name args)
  (Host.Mlx.Ffi.call y name (List.map (Map.arg M) args))

theorem mlx_sim (s : Host.Mlx.Ffi.Sym) (hsym : Host.Mlx.Ffi.symOf name = some s) (args : List Arg)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hok : NativeOk.sym P x name s args = true) :
    SIM args := by
  have sup : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a := hsupp
  cases s
  case arrayNew =>
    cases args with
    | nil => exact sim_arrayNew hs hr hsym
    | cons _ _ => cases hok
  case arrayFree =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.free at hok; split at hok
    · exact sim_arrayFree hs hr hsym hok
    · cases hok
  case arrayEval =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.node1 at hok; split at hok
    · exact sim_arrayEval hs hr hsym hok
    · cases hok
  case arrayNdim =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.ndim at hok; split at hok
    · rename_i a
      simp only [Bool.and_eq_true] at hok
      refine sim_arrayNdim hs hr hsym hok.1 fun nd hn => ?_
      have := hok.2; rw [hn] at this; simpa using this
    · cases hok
  case arrayShape =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.node1 at hok; split at hok
    · exact sim_arrayShape hs hr hsym hok
    · cases hok
  case arrayDtype =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.node1 at hok; split at hok
    · exact sim_arrayDtype hs hr hsym hok
    · cases hok
  case arraySize =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.size at hok; split at hok
    · rename_i a
      simp only [Bool.and_eq_true] at hok
      refine sim_arraySize hs hr hsym hok.1 fun nd hn ds hd => ?_
      have := hok.2; rw [hn] at this; simp only [hd] at this; exact this
    · cases hok
  case vecNew =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.new0 at hok; split at hok
    · exact sim_vecNew hs hr hsym (by simpa [NativeOk.room1] using hok)
    · cases hok
  case vecFree =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.any1 at hok; split at hok
    · exact sim_vecFree hs hr hsym _
    · cases hok
  case vecSize =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.vsize at hok; split at hok
    · rename_i v
      simp only [Bool.and_eq_true] at hok
      refine sim_vecSize hs hr hsym hok.1 fun ns hn => ?_
      have := hok.2; rw [hn] at this; simpa using this
    · cases hok
  case vecGet =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.vget at hok; split at hok
    · simp only [Bool.and_eq_true, NativeOk.room1, decide_eq_true_eq] at hok
      exact sim_vecGet hs hr hsym hok.1.1.1 hok.1.1.2 hok.1.2 hok.2
    · cases hok
  case vecNewData =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.vdata at hok; split at hok
    · simp only [Bool.and_eq_true, NativeOk.room1, decide_eq_true_eq] at hok
      exact sim_vecNewData hs hr hsym hok.1 hok.2
    · cases hok
  case asyncEval =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.vec1 at hok; split at hok
    · exact sim_asyncEval hs hr hsym hok
    · cases hok
  case cfgNew =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.new0 at hok; split at hok
    · exact sim_cfgNew hs hr hsym (by simpa [NativeOk.room1] using hok)
    · cases hok
  case cfgFree =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.any1 at hok; split at hok
    · exact sim_cfgFree hs hr hsym _
    · cases hok
  case cfgOutput =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.cout at hok; split at hok
    · simp only [Bool.and_eq_true] at hok
      exact sim_cfgOutput hs hr hsym hok.1.1.1 hok.1.1.2 hok.1.2 hok.2
    · cases hok
  case cfgGrid =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.cnums at hok; split at hok
    · rename_i c a b d
      exact sim_cfgGrid hs hr hsym hok (SN.of_supp (A := fun _ => True) (sup (.num a) (by simp)))
        (SN.of_supp (A := fun _ => True) (sup (.num b) (by simp))) (SN.of_supp (A := fun _ => True) (sup (.num d) (by simp)))
    · cases hok
  case cfgGroup =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.cnums at hok; split at hok
    · rename_i c a b d
      exact sim_cfgGroup hs hr hsym hok (SN.of_supp (A := fun _ => True) (sup (.num a) (by simp)))
        (SN.of_supp (A := fun _ => True) (sup (.num b) (by simp))) (SN.of_supp (A := fun _ => True) (sup (.num d) (by simp)))
    · cases hok
  case cfgInt =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.cint at hok; split at hok
    · rename_i c nm v
      exact sim_cfgInt hs hr hsym hok (SN.of_supp (A := fun _ => True) (sup (.num v) (by simp)))
    · cases hok
  case cfgDtype =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.cdtype at hok; split at hok
    · simp only [Bool.and_eq_true] at hok
      exact sim_cfgDtype hs hr hsym hok.1 hok.2
    · cases hok
  case kernelApply =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.kapply at hok; split at hok
    · rename_i o k v c e
      simp only [Bool.and_eq_true, NativeOk.room1, decide_eq_true_eq] at hok
      refine sim_kernelApply hs hr hsym hok.1.1.1.1.1 hok.1.1.1.1.2 hok.1.1.1.2 hok.1.1.2 hok.1.2 fun cf hc => ?_
      have := hok.2; rw [hc] at this; simpa using this
    · cases hok
  case arrayNewData =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.newData at hok; split at hok
    · rename_i b0 o0 bytes sh nd dt
      simp only [Bool.and_eq_true, NativeOk.room1, NativeOk.nroom1, decide_eq_true_eq] at hok
      exact sim_arrayNewData hs hr hsym hok.1.1.1.1 hok.1.1.1.2 hok.1.1.2 hok.1.2 hok.2
        (SBs.of_supp (A := fun _ => True) (sup (.jsPtr b0 o0 bytes) (by simp)).2)
    · cases hok
  case zeros =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.zeros at hok; split at hok
    · simp only [Bool.and_eq_true, NativeOk.room1, NativeOk.nroom1, decide_eq_true_eq] at hok
      exact sim_zeros hs hr hsym hok.1.1.1.1.1 hok.1.1.1.1.2 hok.1.1.1.2 hok.1.1.2 hok.1.2 hok.2
    · cases hok
  case itemU32 =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.item at hok; split at hok
    · exact sim_itemU32 hs hr hsym hok
    · cases hok
  case reshape =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.reshape at hok; split at hok
    · rename_i o a sh m e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨ha, hd⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a] <;> cases h2 : Host.Mlx.Ffi.dimsArg sh m <;>
        simp only [h1, h2, reduceCtorEq] at hm
      exact sim_reshape hs hr hsym ha hd h1 h2 hm
    · cases hok
  case transpose =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.transpose at hok; split at hok
    · rename_i o a ax m e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨ha, hd⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a] <;> cases h2 : Host.Mlx.Ffi.dimsArg ax m <;>
        simp only [h1, h2, reduceCtorEq] at hm
      rename_i ds
      cases h3 : Host.Mlx.Ffi.natsOfDims ds <;> simp only [h3, reduceCtorEq] at hm
      exact sim_transpose hs hr hsym ha hd h1 h2 h3 hm
    · cases hok
  case slice =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.slice at hok; split at hok
    · rename_i o a st n1 sp n2 sr n3 e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨ha, k1⟩, k2⟩, k3⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a] <;> cases e1 : Host.Mlx.Ffi.dimsArg st n1 <;>
        cases e2 : Host.Mlx.Ffi.dimsArg sp n2 <;> cases e3 : Host.Mlx.Ffi.dimsArg sr n3 <;>
        simp only [h1, e1, e2, e3, reduceCtorEq] at hm
      exact sim_slice hs hr hsym ha k1 k2 k3 h1 e1 e2 e3 hm
    · cases hok
  case sliceUpdate =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.sliceUpdate at hok; split at hok
    · rename_i o a u st n1 sp n2 sr n3 e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨ha, hu⟩, k1⟩, k2⟩, k3⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a, u] <;> cases e1 : Host.Mlx.Ffi.dimsArg st n1 <;>
        cases e2 : Host.Mlx.Ffi.dimsArg sp n2 <;> cases e3 : Host.Mlx.Ffi.dimsArg sr n3 <;>
        simp only [h1, e1, e2, e3, reduceCtorEq] at hm
      exact sim_sliceUpdate hs hr hsym ha hu k1 k2 k3 h1 e1 e2 e3 hm
    · cases hok
  case sliceDynamic =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.sliceDynamic at hok; split at hok
    · rename_i o a st ax n1 sz n2 e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨ha, hst⟩, k1⟩, k2⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a, st] <;> cases e1 : Host.Mlx.Ffi.dimsArg ax n1 <;>
        cases e2 : Host.Mlx.Ffi.dimsArg sz n2 <;> simp only [h1, e1, e2, reduceCtorEq] at hm
      rename_i d1 _
      cases e1' : Host.Mlx.Ffi.natsOfDims d1 <;> simp only [e1', reduceCtorEq] at hm
      exact sim_sliceDynamic hs hr hsym ha hst k1 k2 h1 e1 e1' e2 hm
    · cases hok
  case concat =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.concat at hok; split at hok
    · rename_i o v ax e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨hv, hax⟩, hm⟩ := hok
      split at hm
      · rename_i i rest h3
        cases hn : x.nodes.get i <;> cases hai : Host.Mlx.Ffi.argInt ax <;>
          simp only [hn, hai, reduceCtorEq] at hm
        rename_i nd a
        cases hb : Host.Mlx.Ffi.axisOf a (len nd.shape) <;> simp only [hb, reduceCtorEq] at hm
        exact sim_concat hs hr hsym hv hax h3 hn hai hb hm
      · cases hm
    · cases hok
  case unary =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.unary at hok; split at hok
    · rename_i o a e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨ha, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a] <;> simp only [h1, reduceCtorEq] at hm
      exact sim_unary hs hr hsym ha h1 hm
    · cases hok
  case binary =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.binary at hok; split at hok
    · rename_i o a b e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨ha, hb⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a, b] <;> simp only [h1, reduceCtorEq] at hm
      exact sim_binary hs hr hsym ha hb h1 hm
    · cases hok
  case rmsNorm =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.rms at hok; split at hok
    · rename_i o a w eps e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨ha, hw⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a, w] <;> simp only [h1, reduceCtorEq] at hm
      exact sim_rmsNorm hs hr hsym ha hw (SN.of_supp (A := fun _ => True) (sup (.num eps) (by simp))) h1 hm
    · cases hok
  case rope =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.rope at hok; split at hok
    · rename_i o a dims tr base scale off freqs e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hf⟩, hno⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a] <;> cases hd : F64.toInt? dims <;>
        simp only [h1, hd, reduceCtorEq] at hm
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hm
      exact sim_rope hs hr hsym ha hf (SA.of_supp (sup base (by simp)) hno)
        (SN.of_supp (A := fun _ => True) (sup (.num scale) (by simp))) (SN.of_supp (A := fun _ => True) (sup (.num off) (by simp))) h1 hd hm.1 hm.2
    · cases hok
  case sdpa =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.sdpa at hok; split at hok
    · rename_i o q k v scale mask mk sk e1 e2
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨hq, hk⟩, hv⟩, hmk⟩, hsk⟩, hm⟩ := hok
      split at hm
      · rename_i ins m h1 hcm h0 h0'
        exact sim_sdpa hs hr hsym hq hk hv hmk hsk (SN.of_supp (A := fun _ => True) (sup (.num scale) (by simp))) h1 hcm h0 h0' hm
      · cases hm
    · cases hok
  case qmm =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.qmm at hok; split at hok
    · rename_i o a w sc bi tr g b mode e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨⟨ha, hw⟩, hsc⟩, hbi⟩, hg⟩, hb⟩, hm⟩ := hok
      split at hm
      · rename_i ins gv bv m h1 eg eb hcm
        exact sim_qmm hs hr hsym ha hw hsc hbi hg hb h1 eg eb hcm hm
      · cases hm
    · cases hok
  case dequantize =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.dequantize at hok; split at hok
    · rename_i o w sc bi g b mode gs dt e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨⟨⟨hw, hsc⟩, hbi⟩, hg⟩, hb⟩, hgs⟩, hdt⟩, hm⟩ := hok
      split at hm
      · rename_i ins gv bv m dv h1 eg eb hcm egs edt
        exact sim_dequantize hs hr hsym hw hsc hbi hg hb hgs hdt h1 eg eb hcm egs edt hm
      · cases hm
    · cases hok
  case take =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.take at hok; split at hok
    · rename_i o a i ax e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, hi⟩, hax⟩, hm⟩ := hok
      split at hm
      · rename_i ins av nd h1 eax hn
        cases hb : Host.Mlx.Ffi.axisOf av (len nd.shape) <;> simp only [hb, reduceCtorEq] at hm
        exact sim_take hs hr hsym ha hi hax h1 eax hn hb hm
      · cases hm
    · cases hok
  case conv1d =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.conv1d at hok; split at hok
    · rename_i o a w st pd dl gr e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨⟨ha, hw⟩, k1⟩, k2⟩, k3⟩, k4⟩, hm⟩ := hok
      split at hm
      · rename_i ins v1 v2 v3 v4 h1 e1 e2 e3 e4
        exact sim_conv1d hs hr hsym ha hw k1 k2 k3 k4 e1 e2 e3 e4 h1 hm
      · cases hm
    · cases hok
  case clearCache =>
    cases args with
    | nil => exact sim_clearCache hs hr hsym
    | cons _ _ => cases hok
  case synchronize =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.any1 at hok; split at hok
    · exact sim_synchronize hs hr hsym _
    · cases hok
  case setWiredLimit =>
    simp only [NativeOk.sym] at hok; unfold NativeOk.wired at hok; split at hok
    · simp only [Bool.and_eq_true] at hok
      exact sim_setWiredLimit hs hr hsym hok.1 hok.2
    · cases hok
  all_goals (unfold NativeOk.sym at hok; cases hok)
end

/-- **The native-call simulation of the load world.** -/
theorem loadFfiSim (P : LoadP) : FfiSim Host.Load.ffi (LoadR P) (okCall P) okBack where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp
    simp only [okCall, Bool.and_eq_true] at hok
    obtain ⟨hm, hok⟩ := hok
    cases hsym : Host.Mlx.Ffi.symOf name with
    | none => rw [hsym] at hok; cases hok
    | some s =>
      rw [hsym] at hok
      exact mlx_lift hr hm (mlx_sim hsrv hr.mlx s hsym args hsupp hok)
  back := by intro M ν S C x y a _ _ hok; cases hok
  read := fun _ _ _ _ _ _ _ _ hr hx => loadR_read hr hx

end Host.Ts.Sim
