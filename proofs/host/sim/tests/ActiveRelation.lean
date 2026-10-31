import host.load.boot.ld.Full
import host.sim.full.BridgeRaise
import host.sim.tests.ActiveRelationDense
set_option Elab.async false
set_option maxRecDepth 1000000

/-! # The active bridge relation is inhabited

`FullRX`'s active half is only reached through a surface wrap. This module takes the boot's real state at
`loadDone`, related to itself by `Ld.rel_full`, and the program's first wrap (`ActiveRelationData`), and checks
that the wrap's result is related with the bridge active. It stops compiling if the active half becomes
unsatisfiable, as it was when `BridgeA.dense` demanded node 0, which `Ffi.init` never creates.

`active_of_wrap` is over abstract states, so that its use unfolds no state data. -/

namespace Host.Ts.Sim.Full.ActiveRelation
open Host.Ts Host.Ts.Sim _root_.Host.Load.Layers

theorem wrap_active {b b1 : Host.Mlx.FfiAne.St} {s s1 : Host.Mlx.Ffi.St} {as : List Arg} {r : Ret}
    (h : Host.Mlx.FfiAne.wrap b s as = some (s1, b1, r)) : b1.active = true := by
  unfold Host.Mlx.FfiAne.wrap at h
  repeat' split at h
  all_goals first
    | (simp only [Bool.cond_eq_ite] at h
       split at h
       · simp only [Option.some.injEq, Prod.mk.injEq] at h
         obtain ⟨-, rfl, -⟩ := h
         rfl
       · cases h)
    | cases h

theorem wrap_programs {b b1 : Host.Mlx.FfiAne.St} {s s1 : Host.Mlx.Ffi.St} {as : List Arg} {r : Ret}
    (h : Host.Mlx.FfiAne.wrap b s as = some (s1, b1, r)) : b1.programs = b.programs := by
  unfold Host.Mlx.FfiAne.wrap at h
  repeat' split at h
  all_goals first
    | (simp only [Bool.cond_eq_ite] at h
       split at h
       · simp only [Option.some.injEq, Prod.mk.injEq] at h
         obtain ⟨-, rfl, -⟩ := h
         rfl
       · cases h)
    | cases h

/-- A clean inactive-or-active relation, a present wrap and its checks give the relation with the bridge active. -/
theorem active_of_wrap {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {as : List Arg} (hsrv : Srv M ν S C) (hr : FullRX P NB M S.tab.length x y)
    (hm : _root_.Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = true)
    (hsym : Host.Mlx.Ffi.symOf name = none) (hok : wrapOk P (mlxOf x) as = true)
    (hclean : bridgeClean (bridgeOf x) = true) (hdense : denseB (mlxOf x) = true)
    (hsome : (Host.Mlx.FfiAne.wrap (bridgeOf x) (mlxOf x) as).isSome = true) :
    ∃ (M' : Map) (n : Nat) (x1 y1 : FF.S), (bridgeOf x1).active = true ∧ FullRX P NB M' n x1 y1 ∧
      (bridgeOf x1).programs = (bridgeOf x).programs := by
  obtain ⟨⟨s1, b1, r⟩, hq⟩ := Option.isSome_iff_exists.mp hsome
  have hsim := fullWrapSim hsrv hr hm hp hsym hok (.inr ⟨hclean, hdense⟩)
  have hrun : interpS (FF.call x name as).run S =
      some (liftF x name as (some (⟨{ x.1.1.base with mlx := s1 }, b1⟩, r, [])), S) := by
    rw [full_call_wrap x hm hp]
    rw [show Host.Mlx.FfiAne.wrap x.1.1.bridge x.1.1.base.mlx as = some (s1, b1, r) from hq]
    rfl
  obtain ⟨M', b, C', -, -, hcr⟩ := MSim.run hsim _ _ hrun
  rw [liftF_some] at hcr
  rcases b with _ | ⟨y1, r1, ws1⟩
  · exact hcr.elim
  · exact ⟨M', _, _, y1, wrap_active hq, hcr.1, wrap_programs hq⟩

/-- `active_of_wrap` at a state given by its fields, the bridge by an equation. -/
theorem active_of_fields {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {l : _root_.Host.Load.LSt} {b b' : Host.Mlx.FfiAne.St} {v : Option _} {k : Option _} {as : List Arg}
    (hx : x = ((⟨l, b⟩, v), k)) (hb : b = b') (hsrv : Srv M ν S C) (hr : FullRX P NB M S.tab.length x y)
    (hok : wrapOk P l.mlx as = true) (hclean : bridgeClean b' = true) (hdense : denseB l.mlx = true)
    (hsome : (Host.Mlx.FfiAne.wrap b' l.mlx as).isSome = true) :
    ∃ (M' : Map) (n : Nat) (x1 y1 : FF.S), (bridgeOf x1).active = true ∧ FullRX P NB M' n x1 y1 ∧
      (bridgeOf x1).programs = b'.programs := by
  subst hx hb
  exact active_of_wrap hsrv hr is_mlx is_wrap no_sym hok hclean hdense hsome

set_option maxHeartbeats 0 in
/-- **The full world's relation with the bridge active holds of a real state**: the result of the
program's first wrap at `loadDone`, which holds the boot's programs. -/
theorem active_inhabited_programs :
    ∃ (M : Map) (n : Nat) (x y : FF.S), (bridgeOf x).active = true ∧ FullRX P0 15235 M n x y ∧
      (bridgeOf x).programs = bridgeLit.programs :=
  have hrel := _root_.Host.Load.Run.Prompt.Ld.rel_full P0 15235 ⟨by decide, by decide⟩ ⟨by decide, by decide⟩
    ⟨rfl, rfl⟩ ⟨by decide, by decide⟩ (Nat.le_refl _) (fun _ => F64.ofNat 1) P0.lo P0.E (by decide) [] []
  active_of_fields
    ((congrArg (fun s => St.ffi s) _root_.Host.Load.Run.Tpl.PRE_setup_early_r0.start_eq).symm.trans V.ffi_eq)
    bridge_lit hrel.srv hrel.ffi.toX wrap_ok clean_lit dense_view wrap_some

theorem active_inhabited :
    ∃ (M : Map) (n : Nat) (x y : FF.S), (bridgeOf x).active = true ∧ FullRX P0 15235 M n x y := by
  obtain ⟨M, n, x, y, ha, h, -⟩ := active_inhabited_programs
  exact ⟨M, n, x, y, ha, h⟩

/-- The same at the prefill's relation. -/
theorem active_inhabited_XD :
    ∃ (M : Map) (n : Nat) (x y : FF.S), (bridgeOf x).active = true ∧ FullRXD P0 15235 M n x y := by
  obtain ⟨M, n, x, y, ha, h⟩ := active_inhabited
  exact ⟨M, n, x, y, ha, h.toXD⟩

end Host.Ts.Sim.Full.ActiveRelation
