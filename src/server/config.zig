const std = @import("std");

const FILENAME = "zcached.conf";

pub const Config = struct {
    address: std.net.Ip4Address = std.net.Ip4Address.init(.{ 127, 0, 0, 1 }, 7556),
    max_connections: u16 = 512,

    _arena: std.heap.ArenaAllocator,

    pub fn deinit(config: *Config) void {
        config._arena.deinit();
    }

    pub fn load(allocator: std.mem.Allocator) !Config {
        var config = Config{ ._arena = std.heap.ArenaAllocator.init(allocator) };

        const file = std.fs.cwd().openFile(FILENAME, .{ .mode = .read_only }) catch |err| {
            // if the file doesn't exist, just return the default config
            if (err == error.FileNotFound) return config;
            return err;
        };
        defer file.close();

        const file_size = (try file.stat()).size;
        var buffer = try config._arena.allocator().alloc(u8, file_size);
        defer config._arena.allocator().free(buffer);

        const readed_size = try file.read(buffer);
        if (readed_size != file_size) return error.InvalidInput;

        var iter = std.mem.split(u8, buffer, "\n");
        while (iter.next()) |line| {
            // # is comment, _ is for internal use, like _allocator
            if (line.len == 0 or line[0] == '#' or line[0] == '_') continue;

            const key_value = try process_line(config._arena.allocator(), line);
            defer key_value.deinit();

            // Special case for address port because `std.net.Address` is struct with address and port
            if (std.mem.eql(u8, key_value.items[0], "port")) {
                if (key_value.items[1].len == 0) return error.InvalidInput;
                const parsed = try std.fmt.parseInt(u16, key_value.items[1], 10);
                config.address.setPort(parsed);
                continue;
            }

            try assign_field_value(&config, key_value);
        }

        return config;
    }

    fn process_line(allocator: std.mem.Allocator, line: []const u8) !std.ArrayList([]const u8) {
        var result = std.ArrayList([]const u8).init(allocator);

        var iter = std.mem.split(u8, line, "=");
        const key = iter.next();
        const value = iter.next();
        if (key == null or value == null) return error.InvalidInput;

        try result.append(key.?);
        try result.append(value.?);

        return result;
    }

    fn assign_field_value(config: *Config, key_value: std.ArrayList([]const u8)) !void {
        // I don't like how many nested things are here, but there is no other way
        inline for (std.meta.fields(Config)) |field| {
            if (std.mem.eql(u8, field.name, key_value.items[0])) {
                var value = try config._arena.allocator().alloc(u8, key_value.items[1].len);
                std.mem.copy(u8, value, key_value.items[1]);

                switch (field.type) {
                    u16 => {
                        const parsed = try std.fmt.parseInt(u16, value, 10);
                        @field(config, field.name) = parsed;
                    },
                    std.net.Ip4Address => {
                        const parsed = try std.net.Ip4Address.parse(value, 0);
                        @field(config, field.name) = parsed;
                    },
                    else => unreachable,
                }
            }
        }
    }
};

test "config default values" {
    var config = try Config.load(std.testing.allocator);
    defer config.deinit();

    const address = std.net.Ip4Address.init(.{ 127, 0, 0, 1 }, 7556);
    try std.testing.expectEqual(config.address, address);
}

test "config load" {
    const file_content = "address=192.168.0.1\nport=1234\n";
    // create file
    const file = try std.fs.cwd().createFile(FILENAME, .{});
    try file.writeAll(file_content);
    defer file.close();

    var config = try Config.load(std.testing.allocator);
    defer config.deinit();

    const address = std.net.Ip4Address.init(.{ 192, 168, 0, 1 }, 1234);
    try std.testing.expectEqual(config.address, address);

    // delete file
    try std.fs.cwd().deleteFile(FILENAME);
}