const std = @import("std");
const io = std.io;

const MAX_RED = 12;
const MAX_GREEN = 13;
const MAX_BLUE = 14;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    var total = try partTwo(reader);
    std.debug.print("Total: {d}\n", .{total});
}

pub fn partOne(reader: anytype) !i32 {
    var buf = try std.BoundedArray(u8, 4096).init(0);
    var total: i32 = 0;
    rounds: while (true) {
        reader.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        var line = buf.slice();
        var it = std.mem.splitScalar(u8, line, ':');
        var game_it = std.mem.splitScalar(u8, it.next().?, ' ');
        // Skip "Game"
        _ = game_it.next();
        var game_num = game_it.next() orelse continue;
        var game = it.next() orelse continue;
        var sets = std.mem.splitScalar(u8, game, ';');
        while (sets.next()) |set| {
            var tokens = std.mem.splitScalar(u8, set, ' ');
            var number: u16 = undefined;
            var reds: i32 = 0;
            var greens: i32 = 0;
            var blues: i32 = 0;
            while (tokens.next()) |token| {
                if (token.len == 0) continue;
                if (std.mem.startsWith(u8, token, "red")) {
                    reds += number;
                } else if (std.mem.startsWith(u8, token, "green")) {
                    greens += number;
                } else if (std.mem.startsWith(u8, token, "blue")) {
                    blues += number;
                } else {
                    number = try std.fmt.parseInt(u16, token, 10);
                }
            }

            if (reds > MAX_RED or greens > MAX_GREEN or blues > MAX_BLUE) {
                try buf.resize(0);
                continue :rounds;
            }
        }

        // Round is valid
        total += try std.fmt.parseInt(i32, game_num, 10);

        // "Empty" the bounded array.
        try buf.resize(0);
    }

    return total;
}

pub fn partTwo(reader: anytype) !i32 {
    var buf = try std.BoundedArray(u8, 4096).init(0);
    var total: i32 = 0;
    while (true) {
        reader.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        var line = buf.slice();
        var it = std.mem.splitScalar(u8, line, ':');
        var game_it = std.mem.splitScalar(u8, it.next().?, ' ');
        // Skip "Game"
        _ = game_it.next();
        // var game_num = game_it.next() orelse continue;
        var game = it.next() orelse continue;
        var sets = std.mem.splitScalar(u8, game, ';');
        var max_red: i32 = 0;
        var max_blue: i32 = 0;
        var max_green: i32 = 0;
        while (sets.next()) |set| {
            var tokens = std.mem.splitScalar(u8, set, ' ');
            var number: u16 = undefined;
            var reds: i32 = 0;
            var greens: i32 = 0;
            var blues: i32 = 0;
            while (tokens.next()) |token| {
                if (token.len == 0) continue;
                if (std.mem.startsWith(u8, token, "red")) {
                    max_red = @max(number, max_red);
                    reds += number;
                } else if (std.mem.startsWith(u8, token, "green")) {
                    max_green = @max(number, max_green);
                    greens += number;
                } else if (std.mem.startsWith(u8, token, "blue")) {
                    max_blue = @max(number, max_blue);
                    blues += number;
                } else {
                    number = try std.fmt.parseInt(u16, token, 10);
                }
            }
        }

        var power = max_red * max_blue * max_green;

        // Round is valid
        total += power;

        // "Empty" the bounded array.
        try buf.resize(0);
    }

    return total;
}
