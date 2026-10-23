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

// positive case
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

// negative case
test "makeBuffer cleans up on initialization failure" {
    const allocator = std.testing.allocator;
    // Error message
    try std.testing.expectError(error.InitializationFailed, makeBuffer(allocator, 16, true));
}

// encapsulating ownership
const TwoBuffers = struct {
    allocator: Allocator,
    buffers: [][]u8,
    //init : should own allocation, frees, zero initialization, then transfer ownership to the returned TwoBuffers value
    fn init(allocator: Allocator) !TwoBuffers {
        // outer slice
        const combined_slice: [][]u8 = try allocator.alloc([]u8, 2);
        errdefer allocator.free(combined_slice);

        // first buffer
        const buffer = try allocator.alloc(u8, 16);
        errdefer allocator.free(buffer);

        // second buffer
        const second_buffer = try allocator.alloc(u8, 32);
        errdefer allocator.free(second_buffer);

        // zero initialization
        @memset(buffer, 0);
        @memset(second_buffer, 0);

        // storing in outer slice
        combined_slice[0] = buffer;
        combined_slice[1] = second_buffer;

        return .{ .allocator = allocator, .buffers = combined_slice };
    }
    //self: *TwoBuffers parameter gives the method access to the struct's fields
    fn deinit(self: *TwoBuffers) void {
        if (self.buffers.len == 0) return;
        const buffers = self.buffers;
        defer self.allocator.free(buffers);
        defer self.allocator.free(buffers[1]);
        defer self.allocator.free(buffers[0]);
        self.buffers = &.{};
    }
    fn take(self: *TwoBuffers) TwoBuffers {
        const result = TwoBuffers{
            .allocator = self.allocator,
            .buffers = self.buffers,
        };
        //Clear self.buffers so self no longer owns the allocations.
        self.buffers = &.{};
        return result;
    }
};

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

// positive case
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

// negative case
test "makeTwoBuffers cleans up on initialization failure" {
    const allocator = std.testing.allocator;
    try std.testing.expectError(error.InitializationFailed, makeTwoBuffers(allocator, true));
}

// out of memory case
test "makeTwoBuffers handles allocation failure" {
    var failing_allocator = std.testing.FailingAllocator.init(
        std.testing.allocator,
        .{ .fail_index = 2 },
    );

    const allocator = failing_allocator.allocator();

    // TODO: call makeTwoBuffers with this allocator
    // TODO: expect error.OutOfMemory
    try std.testing.expectError(error.OutOfMemory, makeTwoBuffers(allocator, false)); // don't use try, it exits the test before your expectError runs
}

test "makeTwoBuffers handles all allocation failures" {
    try std.testing.checkAllAllocationFailures(
        std.testing.allocator,
        testMakeTwoBuffers,
        .{},
    );
}

test "TwoBuffers owns and frees its buffers" {
    const allocator = std.testing.allocator;

    var data = try TwoBuffers.init(allocator);
    defer data.deinit();

    try std.testing.expectEqual(@as(usize, 2), data.buffers.len);
    try std.testing.expectEqual(@as(usize, 16), data.buffers[0].len);
    try std.testing.expectEqual(@as(usize, 32), data.buffers[1].len);
}

test "TwoBuffers handles allocation failures" {
    try std.testing.checkAllAllocationFailures(
        std.testing.allocator,
        testTwoBuffersInit,
        .{},
    );
}

test "TwoBuffers transfers ownership with take" {
    const allocator = std.testing.allocator;

    var first = try TwoBuffers.init(allocator);
    defer first.deinit();

    var second = first.take();
    defer second.deinit();

    try std.testing.expectEqual(@as(usize, 0), first.buffers.len);
    try std.testing.expectEqual(@as(usize, 2), second.buffers.len);

    try std.testing.expectEqual(@as(usize, 16), second.buffers[0].len);
    try std.testing.expectEqual(@as(usize, 32), second.buffers[1].len);
}

//+++++++++++++++++++++++++++++ Test helpers +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
fn testMakeTwoBuffers(allocator: Allocator) !void {
    const buffers = try makeTwoBuffers(allocator, false);

    defer allocator.free(buffers);
    defer allocator.free(buffers[1]);
    defer allocator.free(buffers[0]);

    try std.testing.expectEqual(@as(usize, 2), buffers.len);
    try std.testing.expectEqual(@as(usize, 16), buffers[0].len);
    try std.testing.expectEqual(@as(usize, 32), buffers[1].len);
}

fn testTwoBuffersInit(allocator: Allocator) !void {
    var data = try TwoBuffers.init(allocator);
    defer data.deinit();
}
//+++++++++++++++++++++++++++++ Test helpers +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

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

// pub fn main() void {
//     const allocator = std.testing.allocator;
//     var first = try TwoBuffers.init(allocator);
//     var second = first;
// }
