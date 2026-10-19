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
