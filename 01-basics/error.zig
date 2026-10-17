const std = @import("std");

const MathError = error{
    DivisionByZero,
    NegativeInput,
    Overflow,
};

fn safeDivide(a: i32, b: i32) MathError!i32 {
    if (a < 0 or b < 0) {
        return error.NegativeInput;
    }
    if (b == 0) {
        return error.DivisionByZero;
    }
    return @divTrunc(a, b);
}

fn safeMultiply(a: i32, b: i32) MathError!i32 {
    //@mulWithOverflow returns a struct: { result, overflow_flag }
    const result = @mulWithOverflow(a, b);

    // res[1] is non-zero if an overflow occurred
    if (result[1] != 0) {
        return error.Overflow;
    }

    return result[0];
}

fn calculateExpression(a: i32, b: i32, c: i32) MathError!i32 {
    const quotient = try safeDivide(a, b);

    return try safeMultiply(quotient, c);
}

fn calculate() !i32 {
    //const result = try safeDivide(-10, 2);
    const result = try calculateExpression(2_000_000_000, 1, 2);
    return result;
}

pub fn main() void {
    // const result = safeDivide(10, 5) catch -1;
    // std.debug.print("Safe division: {any}\n", .{result});
    // const error_result = safeDivide(10, 0) catch |err| blk: {
    //     std.debug.print("Error: {s}\n", .{@errorName(err)});
    //     break :blk -1;
    // };
    // std.debug.print("Result: {any}\n", .{error_result});

    //try
    const value = calculate() catch |err| blk: {
        std.debug.print("Error: {s}\n", .{@errorName(err)});
        break :blk -1;
    };
    std.debug.print("Calculate result: {any}\n", .{value});
}
