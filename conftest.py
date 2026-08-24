# Root conftest: async test support via hookimpl
# Works around broken pytest-asyncio in nix store path isolation.
#
# Strategy:
#   - pytest-asyncio runs in "strict" mode (only handles @pytest.mark.asyncio).
#   - This hook converts all OTHER async tests (without the marker) to sync
#     by wrapping them with asyncio.run().
#   - We deliberately avoid functools.wraps because it copies __wrapped__,
#     which makes inspect.iscoroutinefunction() follow the chain back to the
#     original async function on Python 3.12+, causing pytest-asyncio to
#     re-detect the wrapper as async.
import asyncio
import inspect

import pytest


def pytest_collection_modifyitems(items):
    """Convert unmarked async test functions to sync by wrapping with asyncio.run()."""
    for item in items:
        if not isinstance(item, pytest.Function):
            continue
        if not inspect.iscoroutinefunction(item.obj):
            continue
        # Skip tests that are explicitly marked for pytest-asyncio handling
        if item.get_closest_marker("asyncio") is not None:
            continue

        orig = item.obj

        def wrapper(*args, _fn=orig, **kwargs):
            return asyncio.run(_fn(*args, **kwargs))

        wrapper.__name__ = orig.__name__
        wrapper.__qualname__ = orig.__qualname__

        item.obj = wrapper
