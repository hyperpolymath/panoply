// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// Panoply FFI Integration Tests
//
// Exercises the exported C-ABI surface of src/main.zig (imported here as
// the "panoply" module, per build.zig) directly from Zig, verifying that
// the FFI correctly implements the Idris2 ABI declared in src/abi/Foreign.idr.

const std = @import("std");
const panoply = @import("panoply");

test "lifecycle: init and free a handle" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    try std.testing.expect(panoply.panoply_is_initialized(handle) == 1);
}

test "lifecycle: free is safe with a null handle" {
    panoply.panoply_free(null);
}

test "operations: process with a valid handle" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    const result = panoply.panoply_process(handle, 42);
    try std.testing.expectEqual(panoply.Result.ok, result);
}

test "operations: process with a null handle returns null_pointer" {
    const result = panoply.panoply_process(null, 0);
    try std.testing.expectEqual(panoply.Result.null_pointer, result);
}

test "operations: process_array with a valid buffer" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    const buf = [_]u8{ 1, 2, 3, 4 };
    const result = panoply.panoply_process_array(handle, &buf, buf.len);
    try std.testing.expectEqual(panoply.Result.ok, result);
}

test "operations: process_array with a null buffer returns null_pointer" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    const result = panoply.panoply_process_array(handle, null, 0);
    try std.testing.expectEqual(panoply.Result.null_pointer, result);
}

test "operations: process_array with a null handle returns null_pointer" {
    const buf = [_]u8{1};
    const result = panoply.panoply_process_array(null, &buf, buf.len);
    try std.testing.expectEqual(panoply.Result.null_pointer, result);
}

test "strings: get_string returns a value that can be freed" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    const str = panoply.panoply_get_string(handle);
    defer if (str) |s| panoply.panoply_free_string(s);

    try std.testing.expect(str != null);
    if (str) |s| {
        try std.testing.expect(std.mem.span(s).len > 0);
    }
}

test "strings: get_string with a null handle returns null" {
    const str = panoply.panoply_get_string(null);
    try std.testing.expect(str == null);
}

test "strings: free_string is safe with a null pointer" {
    panoply.panoply_free_string(null);
}

test "version: returns a non-empty version string" {
    const ver = panoply.panoply_version();
    const ver_str = std.mem.span(ver);
    try std.testing.expect(ver_str.len > 0);
}

test "version: build_info returns a non-empty string" {
    const info = panoply.panoply_build_info();
    const info_str = std.mem.span(info);
    try std.testing.expect(info_str.len > 0);
}

test "errors: last_error is null after a successful call" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    _ = panoply.panoply_process(handle, 0);
    try std.testing.expect(panoply.panoply_last_error() == null);
}

test "errors: last_error is set after a null-handle call" {
    _ = panoply.panoply_process(null, 0);
    const err = panoply.panoply_last_error();
    try std.testing.expect(err != null);
}

test "callbacks: register_callback with a valid handle and callback" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    const cb: panoply.Callback = struct {
        fn f(a: u64, b: u32) callconv(.c) u32 {
            return @as(u32, @truncate(a)) + b;
        }
    }.f;

    const result = panoply.panoply_register_callback(handle, cb);
    try std.testing.expectEqual(panoply.Result.ok, result);
}

test "callbacks: register_callback with a null callback returns null_pointer" {
    const handle = panoply.panoply_init() orelse return error.InitFailed;
    defer panoply.panoply_free(handle);

    const result = panoply.panoply_register_callback(handle, null);
    try std.testing.expectEqual(panoply.Result.null_pointer, result);
}

test "utility: is_initialized is false for a null handle" {
    try std.testing.expect(panoply.panoply_is_initialized(null) == 0);
}
