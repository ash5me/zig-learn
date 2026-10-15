const std = @import("std");

const PlayerState = enum {
    idle,
    moving,
    attacking,
    dead,
};

const Player = struct {
    health: i32,
    x: f32,
    y: f32,
    state: PlayerState = PlayerState.idle,
    fn takeDamage(self: *Player, damage: i32) void {
        if (damage < 0) {
            return;
        }

        if (self.health <= damage) {
            self.health = 0;
            self.state = PlayerState.dead;
            return;
        }

        self.health -= damage;
    }
    fn heal(self: *Player, amount: i32) void {
        if (self.health <= 0 or amount < 0) {
            return;
        }
        self.health += amount;

        if (self.health > 100) {
            self.health = 100;
            return;
        }
    }
    fn isAlive(self: *const Player) bool {
        return self.health > 0;
    }
    fn move(self: *Player, dx: f32, dy: f32) void {
        if (!self.isAlive()) {
            return;
        }
        self.x += dx;
        self.y += dy;
        self.state = PlayerState.moving;
    }
    fn reset(self: *Player) void {
        self.health = 100;
        self.x = 0.0;
        self.y = 0.0;
        self.state = PlayerState.idle;
    }
    fn getStateMessage(self: *const Player) []const u8 {
        // Use a switch on self.state
        const player_state = switch (self.state) {
            .idle => "Player is idle",
            .moving => "Player is moving",
            .attacking => "Player is attacking",
            .dead => "Player is dead",
        };
        return player_state;
    }
};

pub fn main() void {
    var player = Player{ .health = 30, .x = 0, .y = 0 };
    player.takeDamage(30);
    const player_life = player.isAlive();
    std.debug.print("Player is alive : {any}\n", .{player_life});
    player.move(3.5, -2.0);
    player.heal(60);
    std.debug.print("Player position : {d},{d}\n", .{ player.x, player.y });
    std.debug.print("Remaining health: {d}\n", .{player.health});
    std.debug.print("Player state: {s}\n", .{@tagName(player.state)});
    std.debug.print("{s}\n", .{player.getStateMessage()});
    player.reset();
    std.debug.print("Player position after reset : {d},{d}\n", .{ player.x, player.y });
    std.debug.print("Remaining health after reset : {d}\n", .{player.health});
}
