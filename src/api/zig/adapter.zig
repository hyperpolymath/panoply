// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Unified API adapter (Zig). Panoply has no HTTP/gateway surface yet.
// This module is the Interface Law API layer stub: Zig, not Rust/C.
// Callers must not treat a successful build as a safety envelope.

const std = @import("std");

pub const AdapterError = error{NotImplemented};

/// Envelope-aware entry: refuse to claim guarantees without a manifest.
pub fn dispatch(_: []const u8) AdapterError!void {
    return error.NotImplemented;
}

test "adapter refuses silent success" {
    try std.testing.expectError(error.NotImplemented, dispatch("ping"));
}
