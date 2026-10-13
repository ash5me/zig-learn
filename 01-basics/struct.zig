const std = @import("std");

const Player = struct {
    health: i32,
    x: f32,
    y: f32,
    fn takeDamage(self: *Player, damage: i32) void {
        if (damage < 0) {
            return;
        }
        if (self.health < damage) {
            self.health = 0;
            return;
        }
        self.health -= damage;
    }
    fn heal(self: *Player, amount: i32) void {}
};
pub fn main() void {
    var player = Player{ .health = 100, .x = 0, .y = 0 };
    player.takeDamage(-101);
    std.debug.print("Remaining health: {d}\n", .{player.health});
}
