const std = @import("std");
const template = @import("template.zig").Template;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var t = try template.loadFromFile(allocator, "test/index.html");

    for (t.tokens) |token| {
        std.debug.print("{s}", .{token.value});
    }
    std.debug.print("\n", .{});

    const value = try t.render(.{ .lang = "ru" });
    std.debug.print("{s}\n", .{value});
}
