import host.sim.template.growth.Shift
import host.sim.template.FactsGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The facts of case `GROWTH` the loop induction consumes (`LoopCase`, apart from the
checked run): the token reference, the end counters, freshness of `var 17`, the
substitution, the end control, the framed arrays' growth, and the counter deltas. -/

kernel_rfl GROWTH.num79 : GROWTH.σ.num 79 = .ref GROWTH.S153.tab.length
kernel_rfl GROWTH.hE_check : Nat.blt GROWTH.s153.ffi.mlx.next 131072 = true
theorem GROWTH.hE : GROWTH.s153.ffi.mlx.next < 131072 := Nat.le_of_ble_eq_true GROWTH.hE_check
kernel_rfl GROWTH.noVarTab_check : GROWTH.S153.tab.all (SymE.noVar 17) = true
kernel_rfl GROWTH.noVarOr_check : GROWTH.S153.oracle.all (Ans.noVar 17) = true
theorem GROWTH.noVarTab : ∀ e ∈ GROWTH.S153.tab, e.noVar 17 = true := List.all_eq_true.mp GROWTH.noVarTab_check
theorem GROWTH.noVarOr : ∀ q ∈ GROWTH.S153.oracle, q.noVar 17 = true := List.all_eq_true.mp GROWTH.noVarOr_check
kernel_rfl GROWTH.theta_low : (List.range 18).all (fun j => decide (GROWTH.θ j = loopTheta true 17 j)) = true
kernel_rfl GROWTH.theta_keys : GROWTH.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem GROWTH.theta : ∀ j, GROWTH.θ j = loopTheta true 17 j := theta_eq GROWTH.theta_low GROWTH.theta_keys
kernel_rfl GROWTH.ctl_check : notRetB GROWTH.s153.ctl = true
theorem GROWTH.ctl_notRet : ∀ v, GROWTH.s153.ctl ≠ .ret v := notRet_of GROWTH.ctl_check

/-- The forwarded array's appended elements. -/
noncomputable def GROWTH.xs : List Val := (arrOf GROWTH.s153 2673447).drop (arrOf Base.s0 2673447).length
kernel_rfl GROWTH.xs_eq : GROWTH.xs = [.num (.ref 79)]
kernel_rfl GROWTH.fwd_get : GROWTH.s153.heap.get 2673447 = some (.obj (objOf GROWTH.s153 2673447))
kernel_rfl GROWTH.fwd_kind : (objOf GROWTH.s153 2673447).kind = .array (arrOf Base.s0 2673447 ++ GROWTH.xs)
kernel_rfl GROWTH.emit_get : GROWTH.s153.heap.get 12502 = some (.obj (objOf GROWTH.s153 12502))
kernel_rfl GROWTH.emit_kind : (objOf GROWTH.s153 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)])
theorem GROWTH.fwd : ∃ o, GROWTH.s153.heap.get 2673447 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 2673447 ++ GROWTH.xs) :=
  ⟨_, GROWTH.fwd_get, GROWTH.fwd_kind⟩
theorem GROWTH.emit : ∃ o, GROWTH.s153.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)]) :=
  ⟨_, GROWTH.emit_get, GROWTH.emit_kind⟩
kernel_rfl GROWTH.fix_check : loopFix.all (fun a => Nat.beq (GROWTH.σ.a a) a) = true
theorem GROWTH.fix : ∀ a ∈ loopFix, GROWTH.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp GROWTH.fix_check a ha
  simpa using this

-- counters and their per-iteration deltas
kernel_rfl GROWTH.dJ : GROWTH.s153.next - Base.s0.next = 151053
kernel_rfl GROWTH.dH : GROWTH.s153.ffi.mlx.next - Base.s0.ffi.mlx.next = 3738
kernel_rfl GROWTH.dN : GROWTH.s153.ffi.mlx.nnext - Base.s0.ffi.mlx.nnext = 2445

end Host.Load.Run.Tpl
