const std = @import("std");

fn safeDivide(a: i32, b: i32) !i32 {
    if (b == 0) {
        return error.DivisionByZero;
    }
    return @divTrunc(a, b);
}

fn calculate() !i32 {
    const result = try safeDivide(10, 2);
    return result * 3;
}

pub fn main() void {
    const result = safeDivide(10, 5) catch -1;
    std.debug.print("Safe division: {any}\n", .{result});
    const error_result = safeDivide(10, 0) catch |err| blk: {
        std.debug.print("Error: {s}\n", .{@errorName(err)});
        break :blk -1;
    };
    std.debug.print("Result: {any}\n", .{error_result});

    //try
    const value = calculate() catch |err| blk: {
        std.debug.print("Error: {s}\n", .{@errorName(err)});
        break :blk -1;
    };
    std.debug.print("Calculate result: {any}\n", .{value});
}
