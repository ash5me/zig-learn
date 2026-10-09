const std = @import("std");

pub fn main() void {
    const name: []const u8 = "Ash";
    std.std.log.debug("name :{s}/n", .{name});
}
