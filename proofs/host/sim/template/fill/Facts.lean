import host.sim.template.fill.Shift
import host.sim.template.FactsGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The facts of case `FILL` the loop induction consumes (`LoopCase`, apart from the
checked run): the token reference, the end counters, freshness of `var 17`, the
substitution, the end control, the framed arrays' growth, and the counter deltas. -/

kernel_rfl FILL.num79 : FILL.σ.num 79 = .ref FILL.S150.tab.length
kernel_rfl FILL.hE_check : Nat.blt FILL.s150.ffi.mlx.next 131072 = true
theorem FILL.hE : FILL.s150.ffi.mlx.next < 131072 := Nat.le_of_ble_eq_true FILL.hE_check
kernel_rfl FILL.noVarTab_check : FILL.S150.tab.all (SymE.noVar 17) = true
kernel_rfl FILL.noVarOr_check : FILL.S150.oracle.all (Ans.noVar 17) = true
theorem FILL.noVarTab : ∀ e ∈ FILL.S150.tab, e.noVar 17 = true := List.all_eq_true.mp FILL.noVarTab_check
theorem FILL.noVarOr : ∀ q ∈ FILL.S150.oracle, q.noVar 17 = true := List.all_eq_true.mp FILL.noVarOr_check
kernel_rfl FILL.theta_low : (List.range 18).all (fun j => decide (FILL.θ j = loopTheta false 17 j)) = true
kernel_rfl FILL.theta_keys : FILL.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem FILL.theta : ∀ j, FILL.θ j = loopTheta false 17 j := theta_eq FILL.theta_low FILL.theta_keys
kernel_rfl FILL.ctl_check : notRetB FILL.s150.ctl = true
theorem FILL.ctl_notRet : ∀ v, FILL.s150.ctl ≠ .ret v := notRet_of FILL.ctl_check

/-- The forwarded array's appended elements. -/
noncomputable def FILL.xs : List Val := (arrOf FILL.s150 2673447).drop (arrOf Base.s0 2673447).length
kernel_rfl FILL.xs_eq : FILL.xs = [.num (.ref 79)]
kernel_rfl FILL.fwd_get : FILL.s150.heap.get 2673447 = some (.obj (objOf FILL.s150 2673447))
kernel_rfl FILL.fwd_kind : (objOf FILL.s150 2673447).kind = .array (arrOf Base.s0 2673447 ++ FILL.xs)
kernel_rfl FILL.emit_get : FILL.s150.heap.get 12502 = some (.obj (objOf FILL.s150 12502))
kernel_rfl FILL.emit_kind : (objOf FILL.s150 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)])
theorem FILL.fwd : ∃ o, FILL.s150.heap.get 2673447 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 2673447 ++ FILL.xs) :=
  ⟨_, FILL.fwd_get, FILL.fwd_kind⟩
theorem FILL.emit : ∃ o, FILL.s150.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)]) :=
  ⟨_, FILL.emit_get, FILL.emit_kind⟩
kernel_rfl FILL.fix_check : loopFix.all (fun a => Nat.beq (FILL.σ.a a) a) = true
theorem FILL.fix : ∀ a ∈ loopFix, FILL.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp FILL.fix_check a ha
  simpa using this

-- counters and their per-iteration deltas
kernel_rfl FILL.dJ : FILL.s150.next - Base.s0.next = 147917
kernel_rfl FILL.dH : FILL.s150.ffi.mlx.next - Base.s0.ffi.mlx.next = 3642
kernel_rfl FILL.dN : FILL.s150.ffi.mlx.nnext - Base.s0.ffi.mlx.nnext = 2349

end Host.Load.Run.Tpl
