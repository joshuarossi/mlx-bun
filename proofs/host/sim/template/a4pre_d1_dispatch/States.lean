import host.sim.template.a4pre_d1_dispatch.States2
namespace Host.Load.Run.Tpl
/-- The chunk's length the chain reads as a literal (`D1Input`'s `litLens`); a change here reaches the modules that read its stream. -/
def D1Input.chunkLength : Nat := 1
end Host.Load.Run.Tpl
