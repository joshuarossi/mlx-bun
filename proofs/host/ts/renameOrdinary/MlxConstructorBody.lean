import host.ts.RenameParametricConstructorBody
import host.ts.renameOrdinary.MlxClassPath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.MlxBody380
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s80
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s81
noncomputable def sourceEnv : Env := match input.stack with | .k (.ctorBody _ _ env _)::_ => env | _ => []
noncomputable def sourceTail : List Frame := input.stack.tail
theorem source_control : input.ctl = .ret .undef := by host_kernel_rfl
theorem source_frame : input.stack = .k (.ctorBody (.obj 3126703) Sources.Mlx.Array.ast_n20 sourceEnv [.big (Int.ofNat 29372)])::sourceTail := by host_kernel_rfl
theorem source_bound : input.next+1+(paramNames Sources.Mlx.Array.ast_n20).length ≤ 2^64 := by decide +kernel
theorem source_run (C : CSrv) : interpC (step P.F input).run C = some (output,C) := by host_kernel_rfl

/-- The actual MlxArray constructor enters its real closure and preserves the
owned handle as its first parameter argument under the constructor boundary. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (bound : s.next+1+(paramNames Sources.Mlx.Array.ast_n20).length ≤ 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (ConstructorBodyLive live input.next Sources.Mlx.Array.ast_n20) framed before after old old' output result ∧
      constructorParameterArgument result.stack = constructorArgument s := by
  obtain ⟨r₀,r,hr₀,hr,hs,harg⟩ := step_constructor_body_from_source P.F NR FR R C₀ C live framed before after old old' input s h
    .undef (.obj 3126703) Sources.Mlx.Array.ast_n20 sourceEnv [.big (Int.ofNat 29372)] sourceTail source_control source_frame source_bound bound
  rw [source_run] at hr₀
  have he := congrArg Prod.fst (Option.some.inj hr₀)
  dsimp only at he
  subst r₀
  exact ⟨r,hr,hs,harg⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.MlxBody380
