const std = @import("std");
const Template = @import("template.zig").Template;

pub const TokenType = enum {
    String,
    Identifier,
};

pub const Token = struct {
    type: TokenType,
    value: []const u8,
};

pub const Parser = struct {
    const Self = @This();

    temp: *Template,
    pos: u64,
    allocator: std.mem.Allocator,

    pub fn init(temp: *Template, allocator: std.mem.Allocator) Parser {
        return Self{ .pos = 0, .temp = temp, .allocator = allocator };
    }

    pub fn parse(self: *Self) anyerror![]Token {
        var tokens = std.ArrayList(Token).init(self.allocator);

        while (!self.isEnd()) {
            switch (self.current()) {
                '{' => {
                    if (self.getChar(self.pos + 1) == '{') {
                        const token = self.handleIdentifier();
                        try tokens.append(token);
                    } else {
                        self.next();
                    }
                },
                else => {
                    const token = self.handleString();
                    try tokens.append(token);
                },
            }
        }

        return tokens.items;
    }

    pub fn handleString(self: *Self) Token {
        var identifier = std.ArrayList(u8).init(self.allocator);

        while (self.current() != '{' and !self.isEnd()) {
            identifier.append(self.current()) catch |err| {
                std.debug.print("ban: {any}\n", .{err});
            };
            self.next();
        }

        return Token{ .type = TokenType.String, .value = identifier.items };
    }

    pub fn handleIdentifier(self: *Self) Token {
        var identifier = std.ArrayList(u8).init(self.allocator);
        while (!self.isEnd()) {
            // exit
            if (self.current() == '}' and self.getChar(self.pos + 1) == '}') {
                self.next();
                self.next();
                break;
            }

            switch (self.current()) {
                'a'...'z', 'A'...'Z' => {
                    identifier.append(self.current()) catch |err| {
                        std.debug.print("ban: {any}\n", .{err});
                    };
                },
                else => {},
            }

            self.next();
        }
        return Token{ .type = TokenType.Identifier, .value = identifier.items };
    }

    pub fn isEnd(self: *Self) bool {
        return self.pos >= self.temp.template.len - 1;
    }
    pub fn current(self: *Self) u8 {
        return self.temp.template[self.pos];
    }
    pub fn next(self: *Self) void {
        if (self.pos >= self.temp.template.len - 1) {
            return;
        } else {
            self.pos += 1;
        }
    }
    pub fn getChar(self: *Self, index: usize) u8 {
        return self.temp.template[index];
    }
};
