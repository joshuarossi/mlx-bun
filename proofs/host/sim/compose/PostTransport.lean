import host.sim.compose.PostCut
import host.sim.template.a4pre_d1_input.Property
set_option Elab.async false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

theorem Book.grow {T cap n : Nat} {tk : Nat → Nat} {π γ : List Nat}
    {M M' : Map} {ν : Nat → F64} {K : Ctx} {t t' : St FF.S} {C C' : CSrv}
    (h : Book T tk cap π γ ⟨M, ν, K, t, C⟩) (he : Ext M M' n)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi)) (hc : CSrv.Le C C') :
    Book T tk cap π γ ⟨M', ν, K, t', C'⟩ := by
  refine ⟨h.nonempty, h.vocab, h.lastRows, h.rowsLength, h.rowsVocab, h.valuation,
    h.promptValue, h.rowValue, h.offsetValue, h.capValue, h.context, h.prompt, h.reserved, ?_, ?_⟩
  · exact (congrFun he.a 2590).trans h.emittedAnchor
  · have hi : SetupD1Input.InputAt γ (M.node 15235) t C := h.input
    change SetupD1Input.InputAt γ (M'.node 15235) t' C'
    rw [he.node]
    exact hi.grow hg hc

theorem Book.ext {T cap n : Nat} {tk : Nat → Nat} {π γ : List Nat}
    {M M' : Map} {ν : Nat → F64} {K : Ctx} {t : St FF.S} {C : CSrv}
    (h : Book T tk cap π γ ⟨M, ν, K, t, C⟩) (he : Ext M M' n) :
    Book T tk cap π γ ⟨M', ν, K, t, C⟩ :=
  h.grow he (Host.Mlx.Ffi.NGrow.refl _) (CSrv.Le.refl C)

end Host.Ts.Sim.Compose.Post
