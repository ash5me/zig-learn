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

fn second_largest(numbers: []const i32) struct { ?i32, ?i32 } {
    var max_number: ?i32 = null;
    var second_max_number: ?i32 = null;
    for (numbers) |number| {
        if (max_number == null) {
            max_number = number;
        } else if (number > max_number.?) {
            second_max_number = max_number;
            max_number = number;
        } else if (number < max_number.?) {
            if (second_max_number == null or number > second_max_number.?) {
                second_max_number = number;
            }
        }
    }
    return .{ second_max_number, max_number };
}

// pub fn main() void {
//     const numbers = [_]i32{ 5, 12, 7, 12, 3 };

//     //print_numbers(numbers[1..4]); // function can accept slice without need to know array's size at comptime. The slices can be different sizes still be accepted by sum()
//     //const result = find_max(numbers[1..4]);
//     // std.debug.print("max : {d}\n", .{result});
//     //
//     // const count = count_positive(numbers[1..5]);
//     //
//     // const result = find_min(numbers[1..4]);
//     // std.debug.print("Minimum number : {d}\n", .{result});
//     // const result = find_max_index(numbers[1..4]); // finding max within the given slice and then return its index value of the first maximum
//     //const result = count_max_occurrences(numbers[1..4]); // find the count of all occurrences of max number
//     const result = second_largest(numbers[0..]);
//     std.debug.print("Second max: {}\n", .{result[0] orelse 0});
//     std.debug.print("Max: {}\n", .{result[1] orelse 0});
// }

// ----------------------------------------------------------------------------------------------------------------------- //
// Write a function that removes an element at a given index while preserving the order of the remaining elements.
fn removeAt(numbers: []i32, index: usize) []i32 {
    std.debug.assert(index < numbers.len);
    var i: usize = index;
    while (i + 1 < numbers.len) : (i += 1) {
        numbers[i] = numbers[i + 1];
    }
    return numbers[0 .. numbers.len - 1];
}

fn insertAt(numbers: []i32, length: usize, index: usize, value: i32) usize {
    std.debug.assert(length < numbers.len);
    std.debug.assert(index <= length);

    var i = length; // set i value to 3, the first unused slot
    while (i > index) : (i -= 1) {
        numbers[i] = numbers[i - 1];
    }

    numbers[index] = value;
    return length + 1; // since length is now after adding a value
}

pub fn main() void {
    // var numbers = [_]i32{ 10, 20, 30, 40, 50 };
    // const result = removeAt(numbers[0..], 2); // Valid input 0 to 4, 5 triggers your assertion because index < numbers.len is false
    // std.debug.print("remaining elements: {any}\n", .{result});
    var numbers = [_]i32{ 10, 20, 30, 0, 0 };

    const new_length = insertAt(numbers[0..], 3, 1, 99);

    // Take a slice containing only the four valid elements.
    const result = numbers[0..new_length];

    std.debug.print("Elements: {any}\n", .{result});
}
//++++++++++++++++++++++++ NOTE : [_] means “compiler, figure out the array's length by counting the elements.” +++++++++++++++++++//
