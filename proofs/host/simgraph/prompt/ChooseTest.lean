import host.simgraph.Choose
import host.simgraph.CommandTest
import host.simgraph.prompt.PromptTest
namespace Host.Mlx.SimGraph.ChooseTest
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph

/-! The chooser's search (`domainNodes`, `chooseD`) at both dimension types, on the synthetic
templates whose certificates are kernel-checked elsewhere: the decode template of `CommandTest`
read with `clsOf table 9` (`SDim`), and the multi-row template of `PromptTest` read with the
classifier `clsOfP table box` (`PDim`). The template domain keeps nodes from 2 and the rope base
`7`. Each search finds the checked certificate. -/

def sdimNodes : Array (Option (RNode SDim InKey)) :=
  domainNodes (symNums (clsOf CommandTest.table 9)) 0 2 [7] CommandTest.state

def pdimNodes : Array (Option (RNode PDim InKey)) :=
  domainNodes (symNumsD (clsOfP PromptTest.table PromptTest.box) PDim.lit) 0 2 [7] PromptTest.state

#guard (chooseD sdimNodes CommandTest.expected CommandTest.inputs 2).toOption == some CommandTest.cert
#guard (chooseD pdimNodes PromptTest.expected PromptTest.inputs 2).toOption == some PromptTest.cert

end Host.Mlx.SimGraph.ChooseTest
