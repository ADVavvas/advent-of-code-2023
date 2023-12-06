const std = @import("std");
const io = std.io;

pub fn partOne(reader: anytype) !i32 {
    // Read into BoundedArray
    var buf = try std.BoundedArray(u8, 4096).init(0);
    var total: i32 = 0;
    while (true) {
        reader.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        // std.debug.print("Line: {s}\n", .{buf.slice()});
        var line = buf.slice();

        var buffer: [1024]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        const allocator = fba.allocator();
        var string = std.ArrayList(u8).init(allocator);
        var i: usize = 0;
        while (i < line.len) {
            if (std.ascii.isDigit(line[i])) {
                try string.append(line[i]);
                break;
            }
            i += 1;
        }

        var end: usize = i;
        i = line.len - 1;
        while (i >= end) {
            if (std.ascii.isDigit(line[i])) {
                try string.append(line[i]);
                break;
            }
            i -= 1;
        }

        var number: i32 = std.fmt.parseInt(i32, string.items, 10) catch |err| {
            std.debug.print("Line: {s}\n", .{line});
            return err;
        };

        total += number;
        // "Empty" the bounded array.
        try buf.resize(0);
    }
    return total;
}

pub fn partTwo(reader: anytype) !i32 {
    const String = []const u8;

    const nums = [_]String{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
    var buf = try std.BoundedArray(u8, 4096).init(0);
    var total: i32 = 0;
    while (true) {
        reader.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        var line = buf.slice();

        var buffer: [1024]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        const allocator = fba.allocator();
        var string = std.ArrayList(u8).init(allocator);
        var i: usize = 0;
        outer: while (i < line.len) {
            if (std.ascii.isDigit(line[i])) {
                try string.append(line[i]);
                break;
            } else {
                for (nums, 0..) |num, index| {
                    if (i + num.len > line.len) continue;
                    var j: usize = 0;
                    var match: bool = true;
                    while (j < num.len) {
                        if (num[j] != line[i + j]) {
                            match = false;
                            break;
                        }
                        j += 1;
                    }
                    if (match and j == num.len) {
                        var t: u8 = @truncate(index + 1 + 48);
                        try string.append(t);
                        break :outer;
                    }
                }
            }
            i += 1;
        }

        var end: usize = i;
        i = line.len - 1;
        outer: while (i >= end) {
            if (std.ascii.isDigit(line[i])) {
                try string.append(line[i]);
                break;
            } else {
                for (nums, 0..) |num, index| {
                    if (i - num.len < 0) continue;
                    var j: usize = 0;
                    var match: bool = true;
                    while (j < num.len) {
                        if (num[num.len - j - 1] != line[i - j]) {
                            match = false;
                            break;
                        }
                        j += 1;
                    }
                    if (match and j == num.len) {
                        var t: u8 = @truncate(index + 1 + 48);
                        try string.append(t);
                        break :outer;
                    }
                }
            }
            i -= 1;
        }

        var number: i32 = std.fmt.parseInt(i32, string.items, 10) catch |err| {
            std.debug.print("Len: {d}\n", .{string.items.len});
            std.debug.print("Items: {s}\n", .{string.items});
            std.debug.print("Line: {s}\n", .{line});
            return err;
        };

        total += number;
        // "Empty" the bounded array.
        try buf.resize(0);
    }
    return total;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    var total = try partTwo(reader);
    std.debug.print("Total: {d}\n", .{total});
}
