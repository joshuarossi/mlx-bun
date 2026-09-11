"""CPU-only, no weights/downloads: demonstrate GPTQ block indexing errors.

Run with the mlx-lm reference environment's Python. This checks the installed
implementation and constructs an in-memory version with both indices fixed.
"""
import argparse
import importlib.util
import inspect
import json
from importlib.metadata import version

import mlx.core as mx

mx.set_default_device(mx.cpu)

import mlx.nn as nn
from mlx_lm.quant import gptq

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--upstream-file', help='Optional pinned upstream gptq.py to execute instead of the installed module')
args = parser.parse_args()
if args.upstream_file:
    spec = importlib.util.spec_from_file_location('gptq_repro_upstream', args.upstream_file)
    assert spec and spec.loader
    gptq = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(gptq)

source = inspect.getsource(gptq.gptq_quantize)
bad_window = 'W[..., k : k + j] -= e @ Hinv[k : k + 1, k : k + j]'
bad_index = 'err[..., k : k + 1] = e'
assert bad_window in source and bad_index in source, 'Installed GPTQ differs; review the source before using this reproduction.'
fixed_source = source.replace(bad_window, 'W[..., k : j] -= e @ Hinv[k : k + 1, k : j]').replace(bad_index, 'err[..., k - i : k - i + 1] = e')
namespace = dict(vars(gptq))
exec(compile(fixed_source, '<gptq with both block indices fixed>', 'exec'), namespace)

# A group-local buffer cannot store a global column index in later groups.
i, k, group_size = 32, 32, 32
err = mx.zeros((1, group_size))
err[..., k:k + 1] = mx.ones((1, 1))
mx.eval(err)
assert mx.sum(err).item() == 0
err[..., k - i:k - i + 1] = mx.ones((1, 1))
assert mx.sum(err).item() == 1

# In the first group, k=1 already propagates into the next group. The later
# err @ Hinv block update then visits that column again.
k, j = 1, 32
assert list(range(k, k + j))[-1] == j
assert list(range(k, j))[-1] == j - 1

# Execute the actual quantizer, with and without the two-line correction.
class Model(nn.Module):
    def __init__(self, weight):
        super().__init__()
        self.proj = nn.Linear(weight.shape[1], weight.shape[0], bias=False)
        self.proj.weight = weight

    def __call__(self, x):
        return self.proj(x)

mx.random.seed(7)
weight = mx.random.normal((4, 128))
calibration = mx.random.normal((256, 128))
# Correlated columns exercise compensation across group boundaries.
calibration = calibration + 0.3 * mx.sum(calibration, axis=-1, keepdims=True)
mx.eval(weight, calibration)
kwargs = dict(data=calibration, bits=4, group_size=32,
              fallback_bits=4, fallback_group_size=32, batch_size=32)
original, _ = gptq.gptq_quantize(Model(mx.array(weight)), **kwargs)
corrected, _ = namespace['gptq_quantize'](Model(mx.array(weight)), **kwargs)
mx.eval(original.parameters(), corrected.parameters())
different_words = mx.sum(original.proj.weight != corrected.proj.weight).item()
assert different_words > 0, 'This fixture did not expose a packed-weight difference.'
print(json.dumps({'mlx': version('mlx'), 'mlx_lm': version('mlx-lm'),
                  'device': 'cpu', 'later_group_global_write_sum': 0,
                  'later_group_local_write_sum': 1,
                  'packed_weight_words_changed': different_words}, indent=2))
