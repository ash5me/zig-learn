const std = @import("std");

// pub fn main() void {
//     const numbers: [5]i32 = .{ 10, 20, 30, 40, 50 };

//     std.debug.print("length = {}\n", .{numbers.len});
//     std.debug.print("first = {}\n", .{numbers[0]});
//     std.debug.print("last = {}\n", .{numbers[4]});
// }
// Solution : length = 5; first = 10; last 50;

//slices
// pub fn main() void {
//     //array
//     const numbers: [5]i32 = .{ 10, 20, 30, 40, 50 };
//     //slice - doesn't copy rather creates a view of 1 to 4
//     const slice: []const i32 = numbers[1..4];

//     std.debug.print("length = {}\n", .{slice.len});
//     std.debug.print("first = {}\n", .{slice[0]});
//     std.debug.print("last = {}\n", .{slice[2]});
// }
// Solution : The slice contains [20,30,40]
// length = 5; first 20; last = 40;

// Zig's documentation describes a slice as a pointer + length,
// and a slice created from a mutable array is itself mutable
// even if the slice variable is declared const

pub fn main() void {
    var numbers: [5]i32 = .{ 10, 20, 30, 40, 50 };

    // const slice: []i32 = numbers[1..4]; // allowed

    const slice: []const i32 = numbers[1..4]; // error: cannot assign to constant

    slice[0] = 200; //slice is mutable despite const keyword

    std.debug.print("first slice el :{d}\n", .{slice[0]});
}
