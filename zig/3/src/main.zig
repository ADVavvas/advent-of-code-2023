const std = @import("std");
const io = std.io;

const dirs = [_][2]i32{
    [_]i32{ -1, -1 },
    [_]i32{ -1, 0 },
    [_]i32{ -1, 1 },
    [_]i32{ 0, -1 },
    [_]i32{ 0, 1 },
    [_]i32{ 1, -1 },
    [_]i32{ 1, 0 },
    [_]i32{ 1, 1 },
};

pub fn main() !void {
    const file = @embedFile("input.txt");

    var total = try partTwo(file);
    std.debug.print("Total: {d}\n", .{total});
}

pub fn partOne(file: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, file, '\n');
    var total: u32 = 0;
    var y: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();

    while (lines.next()) |line| {
        try list.append(line);
    }

    y = 0;
    while (y < list.items.len) : (y += 1) {
        var i: usize = 0;
        while (i < list.items[y].len) : (i += 1) {
            if (std.ascii.isDigit(list.items[y][i])) {
                var is_part = false;
                var start = i;

                if (i > 0 and !std.ascii.isDigit(list.items[y][i - 1]) and list.items[y][i - 1] != '.') {
                    is_part = true;
                }
                if (i > 0 and y > 0 and !std.ascii.isDigit(list.items[y - 1][i - 1]) and list.items[y - 1][i - 1] != '.') {
                    is_part = true;
                }

                if (i > 0 and y < list.items.len - 1 and !std.ascii.isDigit(list.items[y + 1][i - 1]) and list.items[y + 1][i - 1] != '.') {
                    is_part = true;
                }

                while (i < list.items[y].len and std.ascii.isDigit(list.items[y][i])) : (i += 1) {
                    if (y > 0 and !std.ascii.isDigit(list.items[y - 1][i]) and list.items[y - 1][i] != '.') {
                        is_part = true;
                    }
                    if (y < list.items.len - 1 and !std.ascii.isDigit(list.items[y + 1][i]) and list.items[y + 1][i] != '.') {
                        is_part = true;
                    }
                }
                var end = i;
                std.debug.print("end: {}\n", .{end});

                if (i < list.items[y].len - 1 and !std.ascii.isDigit(list.items[y][i]) and list.items[y][i] != '.') {
                    is_part = true;
                }
                if (i < list.items[y].len - 1 and y > 0 and !std.ascii.isDigit(list.items[y - 1][i]) and list.items[y - 1][i] != '.') {
                    is_part = true;
                }

                if (i < list.items[y].len - 1 and y < list.items.len - 1 and !std.ascii.isDigit(list.items[y + 1][i]) and list.items[y + 1][i] != '.') {
                    is_part = true;
                }

                if (is_part) {
                    var num = try std.fmt.parseInt(u16, list.items[y][start..end], 10);
                    std.debug.print("{}\n", .{num});
                    total += num;
                }
            }
        }
    }

    return total;
}

pub fn partTwo(file: []const u8) !u64 {
    var lines = std.mem.tokenizeScalar(u8, file, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();

    while (lines.next()) |line| {
        try list.append(line);
    }

    var total: u32 = 0;
    var i: usize = 0;

    while (i < list.items.len) : (i += 1) {
        var j: usize = 0;
        while (j < list.items[i].len) : (j += 1) {
            if (list.items[i][j] != '*') continue;

            var adj = std.ArrayList([]const u8).init(allocator);
            defer adj.deinit();

            for (dirs) |dir| {
                var nx: i32 = @as(i32, @intCast(j)) + dir[0];
                var ny: i32 = @as(i32, @intCast(i)) + dir[1];

                if (nx < 0 or ny < 0) {
                    continue;
                }

                var x: usize = @intCast(nx);
                var y: usize = @intCast(ny);

                if (x < list.items[y].len and y < list.items.len) {
                    if (!std.ascii.isDigit(list.items[y][x])) continue;
                    var candidate = expandNumber(list, x, y);
                    if (candidate.len == 0) continue;
                    var unique: bool = true;
                    for (adj.items) |other| {
                        if (std.mem.eql(u8, other, candidate)) {
                            unique = false;
                        }
                    }
                    if (unique) {
                        try adj.append(candidate);
                    }
                }
            }

            if (adj.items.len != 2) continue;
            var gear1 = try parseSlice(adj.items[0]);
            var gear2 = try parseSlice(adj.items[1]);

            total += gear1 * gear2;
        }
    }

    return total;
}

pub fn expandNumber(list: std.ArrayList([]const u8), x: usize, y: usize) []const u8 {
    var start: usize = x;
    while (start > 0 and std.ascii.isDigit(list.items[y][start - 1])) {
        start -= 1;
    }
    var end = x;
    while (end < list.items[y].len and std.ascii.isDigit(list.items[y][end])) {
        end += 1;
    }

    return list.items[y][start..end];
}

pub fn parseSlice(slice: []const u8) !u32 {
    return try std.fmt.parseInt(u32, slice, 10);
}
