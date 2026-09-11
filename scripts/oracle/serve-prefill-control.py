"""Explicit MLX-LM serving control for matching whole-prompt prefill boundaries.

Delegates tokenization, model execution, sampling and HTTP handling to the
pinned MLX-LM server. Its default thinking/system segmentation is replaced
with one prompt segment; BatchGenerator still reserves the final token.
This is a benchmark policy control, not the stock server's default behavior.
Upstream: mlx-lm 0.31.3, mlx_lm/server.py, ResponseGenerator._tokenize (MIT).
"""
import sys

from mlx_lm import server

_tokenize = server.ResponseGenerator._tokenize


def whole_prompt(self, tokenizer, request, args):
    prompt, segments, segment_types, initial_state = _tokenize(
        self, tokenizer, request, args
    )
    if request.request_type == "chat":
        return prompt, [prompt], ["assistant"], initial_state
    return prompt, segments, segment_types, initial_state


server.ResponseGenerator._tokenize = whole_prompt
print("benchmark control: whole-prompt prefill; stock server segmentation disabled", file=sys.stderr)
if len(sys.argv) > 1 and sys.argv[1] == "--optiq":
    del sys.argv[1]
    from optiq.cli import cli

    cli()
else:
    server.main()
