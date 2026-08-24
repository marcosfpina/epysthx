"""Test fixtures for API tests — ensures clean global store state."""

import hashlib
import os

import pytest


@pytest.fixture(autouse=True)
def _reset_stores():
    """Reset global stores before each test to prevent state leaks."""
    # Lazy imports — test files set env vars at module level, and conftest
    # is processed first, so we must not import neutron.api at module level.

    # -- Auth store --
    from neutron.api.auth import DEFAULT_ADMIN_USERNAME, Role, User, get_auth_store

    store = get_auth_store()
    store.users.clear()
    store.api_keys.clear()
    store.refresh_tokens.clear()
    # Re-create default admin user using the CURRENT env value
    admin_password = os.getenv("ADMIN_PASSWORD", "neutron_admin_2026")
    admin_hash = hashlib.sha256(admin_password.encode()).hexdigest()
    store.users[DEFAULT_ADMIN_USERNAME] = User(
        username=DEFAULT_ADMIN_USERNAME,
        password_hash=admin_hash,
        role=Role.ADMIN,
    )

    # -- Policy store --
    from neutron.api.policy_store import get_policy_store

    policy_store = get_policy_store()
    policy_store.policies.clear()
    policy_store._init_default_policies()

    # -- Rate limiter buckets (server.py _rate_limit_buckets) --
    from neutron.api import server

    server._rate_limiter._buckets.clear()
