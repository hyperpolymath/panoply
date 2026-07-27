// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Panoply FFI Build Configuration (Zig 0.16+)

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Main FFI module (src/main.zig) — links libc because it uses
    // std.heap.c_allocator.
    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addLibrary(.{
        .name = "panoply",
        .linkage = .static,
        .root_module = main_mod,
    });
    b.installArtifact(lib);

    // Unit tests embedded in src/main.zig
    const main_tests = b.addTest(.{ .root_module = main_mod });
    const run_main_tests = b.addRunArtifact(main_tests);

    // Integration tests (test/integration_test.zig) — imports the main
    // module by name and exercises the exported FFI surface directly.
    const integration_mod = b.createModule(.{
        .root_source_file = b.path("test/integration_test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "panoply", .module = main_mod },
        },
    });

    const integration_tests = b.addTest(.{ .root_module = integration_mod });
    const run_integration_tests = b.addRunArtifact(integration_tests);

    const test_step = b.step("test", "Run unit and integration tests");
    test_step.dependOn(&run_main_tests.step);
    test_step.dependOn(&run_integration_tests.step);
}
