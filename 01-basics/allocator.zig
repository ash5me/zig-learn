const std = @import("std");

const Allocator = std.mem.Allocator;
const page_alloc = std.heap.page_allocator;

fn makeBuffer(
    heap: Allocator,
    length: usize,
    fail: bool,
) ![]u8 {
    const buffer = try heap.alloc(u8, length);
    errdefer heap.free(buffer);

    @memset(buffer, 0);

    if (fail) {
        return error.InitializationFailed;
    }

    return buffer;
}

test "makeBuffer initializes bytes to zero" {
    const allocator = std.testing.allocator;

    const buffer = try makeBuffer(allocator, 16, false);
    defer allocator.free(buffer);
    //length
    try std.testing.expectEqual(@as(usize, 16), buffer.len);
    //zero check
    for (buffer) |byte| {
        try std.testing.expectEqual(@as(u8, 0), byte);
    }
}

test "makeBuffer cleans up on initialization failure" {
    const allocator = std.testing.allocator;
    // Error message
    try std.testing.expectError(error.InitializationFailed, makeBuffer(allocator, 16, true));
}

fn makeTwoBuffers(
    allocator: Allocator,
    fail: bool,
) ![][]u8 {
    // outer slice
    const combined_slice: [][]u8 = try allocator.alloc([]u8, 2);
    errdefer allocator.free(combined_slice);

    // first buffer
    const buffer = try allocator.alloc(u8, 16);
    errdefer allocator.free(buffer);
    @memset(buffer, 0);

    // second buffer
    const second_buffer = try allocator.alloc(u8, 32);
    errdefer allocator.free(second_buffer);
    @memset(second_buffer, 0);

    // storing in outer slice
    combined_slice[0] = buffer;
    combined_slice[1] = second_buffer;

    //error cleanups
    if (fail) {
        return error.InitializationFailed;
    }
    return combined_slice;
}

test "makeTwoBuffers initializes bytes to zero" {
    const allocator = std.testing.allocator;

    const buffers = try makeTwoBuffers(allocator, false);

    defer allocator.free(buffers);
    defer allocator.free(buffers[1]);
    defer allocator.free(buffers[0]);

    // length
    try std.testing.expectEqual(@as(usize, 2), buffers.len);

    try std.testing.expectEqual(@as(usize, 16), buffers[0].len);

    try std.testing.expectEqual(@as(usize, 32), buffers[1].len);

    //zero
    for (buffers[0]) |byte| {
        try std.testing.expectEqual(@as(u8, 0), byte);
    }

    for (buffers[1]) |byte| {
        try std.testing.expectEqual(@as(u8, 0), byte);
    }
}

test "makeTwoBuffers cleans up on initialization failure" {
    const allocator = std.testing.allocator;
    try std.testing.expectError(error.InitializationFailed, makeTwoBuffers(allocator, true));
}

pub fn main() void {
    const buffer = makeBuffer(page_alloc, 16, false) catch {
        std.debug.print("Allocation failed\n", .{});
        return;
    };

    defer page_alloc.free(buffer);

    std.debug.print("Buffer length: {d}\n", .{buffer.len});

    const second_buffer = makeBuffer(page_alloc, 16, true) catch |err| {
        std.debug.print("Initialization failed: {s}\n", .{@errorName(err)});
        return;
    };

    defer page_alloc.free(second_buffer);
}
