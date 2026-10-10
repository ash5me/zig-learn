const std = @import("std");

// pub fn main() void {
//     const numbers: [5]i32 = .{ 10, 20, 30, 40, 50 };

//     std.debug.print("length = {}\n", .{numbers.len});
//     std.debug.print("first = {}\n", .{numbers[0]});
//     std.debug.print("last = {}\n", .{numbers[4]});
// }
// Solution : length = 5; first = 10; last 50;
//
// ------------------------------------------------------------------------------------------ //

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

// pub fn main() void {
//     var numbers: [5]i32 = .{ 10, 20, 30, 40, 50 };

//     // const slice: []i32 = numbers[1..4]; // allowed

//     const slice: []const i32 = numbers[1..4]; // error: cannot assign to constant // read-only

//     slice[0] = 200; //slice is mutable despite const keyword

//     std.debug.print("first slice el :{d}\n", .{slice[0]});
// }

// --------------------------------------------------------------------------//
// function with slice

fn print_numbers(numbers: []const i32) void {
    for (numbers) |number| {
        std.debug.print("{} ", .{number});
    }

    std.debug.print("\n", .{});
}

fn find_max(numbers: []const i32) i32 {
    var max: i32 = numbers[0];
    for (numbers) |number| {
        // check if number > max, then max = number
        if (number > max) {
            max = number;
        }
    }
    return max;
}

fn count_positive(numbers: []const i32) usize {
    //check if number is greater than zero, then count. return count
    var count: usize = 0; // usize - Unsigned integer sized for the target's pointer width; used for Array length, index, count
    for (numbers) |number| {
        if (number > 0) {
            count += 1;
        }
    }
    return count;
}

fn find_min(numbers: []const i32) i32 {
    var min: i32 = numbers[0];
    for (numbers) |number| {
        if (number < min) {
            min = number;
        }
    }
    return min;
}

//find just the index
// fn find_max_index(numbers: []const i32) usize {
//     const max_number = find_max(numbers);

//     for (numbers, 0..) |number, index| {
//         if (number == max_number) {
//             return index;
//         }
//     }

//     unreachable;
// }

//find the last index
fn find_max_index(numbers: []const i32) usize {
    // find the max number
    const max_number: i32 = find_max(numbers);
    // find the last index of that number, by leaving return statement outside of the loop
    var last_index: usize = 0;
    for (numbers, 0..) |number, index| {
        if (number == max_number) {
            last_index = index;
        }
    }
    return last_index;
}

// Count max occurences
fn count_max_occurrences(numbers: []const i32) usize {
    const max_number: i32 = find_max(numbers);
    var count: usize = 0;
    for (numbers) |number| {
        if (number == max_number) {
            count += 1;
        }
    }
    return count;
}

fn second_largest(numbers: []const i32) ?i32 {
    const max_number: i32 = find_max(numbers);
    var second_max_number: ?i32 = null;
    //var numbers_not_max: [5]i32 = undefined;
    for (numbers) |number| {
        if (number == max_number) {
            continue;
        }
        if (second_max_number == null or number > second_max_number.?) {
            // checked for null before safely orelse unwrapping using .?
            // store it in an array excluding first max number
            second_max_number = number;
        }
    }
    return second_max_number;
}

pub fn main() void {
    const numbers = [_]i32{ 5, 12, 7, 12, 3 };

    //print_numbers(numbers[1..4]); // function can accept slice without need to know array's size at comptime. The slices can be different sizes still be accepted by sum()
    //const result = find_max(numbers[1..4]);
    // std.debug.print("max : {d}\n", .{result});
    //
    // const count = count_positive(numbers[1..5]);
    //
    // const result = find_min(numbers[1..4]);
    // std.debug.print("Minimum number : {d}\n", .{result});
    // const result = find_max_index(numbers[1..4]); // finding max within the given slice and then return its index value of the first maximum
    //const result = count_max_occurrences(numbers[1..4]); // find the count of all occurrences of max number
    const result = second_largest(numbers[0..]);
    std.debug.print("second largest number: {?}\n", .{result});
}
//++++++++++++++++++++++++ NOTE : [_] means “compiler, figure out the array's length by counting the elements.” +++++++++++++++++++//
