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

const Example = struct {
    a: u8,
    b: u32,
};

const LayoutExample = struct {
    a: u8,
    c: u8,
    b: u32,
};

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
//     var items: [3]Example = undefined;
//     const ptr: [*]Example = &items;
// }

// ----------------------------------------------------** ARENA ALLOCATOR **---------------------------------------------------//

test "arena allocates multiple buffers" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const first = try allocator.alloc(u8, 16);
    const second = try allocator.alloc(u8, 32);
    const third = try allocator.alloc(u8, 64);

    @memset(first, 1);
    @memset(second, 2);
    @memset(third, 3);

    try std.testing.expectEqual(@as(usize, 16), first.len);
    try std.testing.expectEqual(@as(usize, 32), second.len);
    try std.testing.expectEqual(@as(usize, 64), third.len);
}

test "arena allocator reset" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const first = try allocator.alloc(u8, 16);
    @memset(first, 1);

    const reset_succeeded = arena.reset(.free_all);
    try std.testing.expect(reset_succeeded);

    const second = try allocator.alloc(u8, 32);

    try std.testing.expectEqual(@as(usize, 32), second.len);
}

test "inspect type sizes and alignment" {
    try std.testing.expect(@sizeOf(u8) == 1);

    std.debug.print(
        "u8: size={}, alignment={}\n",
        .{ @sizeOf(u8), @alignOf(u8) },
    );

    std.debug.print(
        "u32: size={}, alignment={}\n",
        .{ @sizeOf(u32), @alignOf(u32) },
    );

    std.debug.print(
        "Example: size={}, alignment={}\n",
        .{ @sizeOf(Example), @alignOf(Example) },
    );
}

// {Address of element } i = {Base address} + i times {size of element}
// For a properly aligned array, the element size is a multiple of the element alignment.

// test "array alignment" {
//     const items: [3]Example = undefined;

//     std.debug.print(
//         "Element size: {}\n",
//         .{@sizeOf(Example)},
//     );

//     std.debug.print(
//         "Element alignment: {}\n",
//         .{@alignOf(Example)},
//     );

//     std.debug.print(
//         "Array size: {}\n",
//         .{@sizeOf(@TypeOf(items))},
//     );

//     std.debug.print(
//         "Array alignment: {}\n",
//         .{@alignOf(@TypeOf(items))},
//     );
// }

// {Address}({ptr}+n) = {Address}({ptr})+n times operatorname{sizeof}(T)

test "inspect struct memory layout" {
    std.debug.print("Size: {}\n", .{@sizeOf(LayoutExample)});
    std.debug.print("Alignment: {}\n", .{@alignOf(LayoutExample)});

    std.debug.print("Offset of a: {}\n", .{@offsetOf(LayoutExample, "a")});
    std.debug.print("Offset of b: {}\n", .{@offsetOf(LayoutExample, "b")});
    std.debug.print("Offset of c: {}\n", .{@offsetOf(LayoutExample, "c")});
}

test "allocator.create automatic space and alignment allocation" {
    const allocator = std.testing.allocator;
    const ptr = try allocator.create(LayoutExample);
    const result = @intFromPtr(ptr) % @alignOf(LayoutExample);
    try std.testing.expectEqual(@as(usize, 0), result);
    std.debug.print("Address : {}\n", .{result});
    defer allocator.destroy(ptr);
}

test "allocator.create automatic allocation of an array of fixed size" {
    const allocator = std.testing.allocator;
    const items = try allocator.alloc(LayoutExample, 10);
    const result = @intFromPtr(items.ptr) % @alignOf(LayoutExample);
    try std.testing.expectEqual(@as(usize, 0), result);
    try std.testing.expectEqual(@as(usize, 10), items.len); // check no. of elements
    defer allocator.free(items);
}
