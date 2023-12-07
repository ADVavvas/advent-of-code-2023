const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input.txt");

    var total = try partTwo(file);
    std.debug.print("Total: {d}\n", .{total});
}

pub fn partOne(file: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var cards = std.mem.tokenizeScalar(u8, file, '\n');

    var total: u32 = 0;

    while (cards.next()) |card| {
        var components = std.mem.splitScalar(u8, card, ':');
        _ = components.next();
        var game = std.mem.splitScalar(u8, components.next().?, '|');
        var player_nums = std.mem.tokenizeScalar(u8, game.next().?, ' ');
        var winning_nums = std.mem.tokenizeScalar(u8, game.next().?, ' ');

        var map = std.AutoHashMap(u32, bool).init(allocator);

        while (player_nums.next()) |str| {
            var num = try std.fmt.parseInt(u32, str, 10);
            try map.put(num, true);
        }

        var counter: u5 = 0;
        while (winning_nums.next()) |str| {
            var num = try std.fmt.parseInt(u32, str, 10);
            if (map.get(num) != null) {
                counter += 1;
            }
        }
        if (counter == 0) continue;
        var score: u32 = 1;

        total += score << (counter - 1);
    }
    return total;
}

pub fn partTwo(file: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const lines = std.mem.count(u8, file, "\n");

    var cards = std.mem.tokenizeScalar(u8, file, '\n');

    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit();
    try list.appendNTimes(1, lines);

    var total: u32 = 0;

    var i: usize = 0;

    while (cards.next()) |card| {
        var components = std.mem.splitScalar(u8, card, ':');
        _ = components.next();
        var game = std.mem.splitScalar(u8, components.next().?, '|');
        var player_nums = std.mem.tokenizeScalar(u8, game.next().?, ' ');
        var winning_nums = std.mem.tokenizeScalar(u8, game.next().?, ' ');

        var map = std.AutoHashMap(u32, bool).init(allocator);
        defer map.deinit();

        while (player_nums.next()) |str| {
            var num = try std.fmt.parseInt(u32, str, 10);
            try map.put(num, true);
        }

        var counter: u5 = 0;
        while (winning_nums.next()) |str| {
            var num = try std.fmt.parseInt(u32, str, 10);
            if (map.get(num) != null) {
                counter += 1;
            }
        }

        var j = i + 1;
        while (j < lines and j <= i + counter) {
            var new_cards = 1 * list.items[i];
            (&list.items[j]).* = list.items[j] + new_cards;
            j += 1;
        }

        total += list.items[i];
        i += 1;
    }
    return total;
}
