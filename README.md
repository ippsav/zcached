# zcached - A Lightweight In-Memory Cache System

Welcome to `zcached`, a nimble and efficient in-memory caching system resembling databases like Redis. This README acts as a comprehensive guide, aiding in comprehension, setup, and optimal utilization.

## Introduction
`zcached` aims to offer rapid, in-memory caching akin to widely-used databases such as Redis. Its focus lies in user-friendliness, efficiency, and agility, making it suitable for various applications requiring swift data retrieval and storage.

Crafted using Zig, a versatile, modern, compiled programming language, `zcached` prides itself on a zero-dependency architecture. This unique feature enables seamless compilation and execution across systems equipped with a Zig compiler, ensuring exceptional portability and deployment ease.

## Features
- **Zero-Dependency Architecture**: Entirely built using Zig, ensuring seamless execution across systems with a Zig compiler, enhancing portability.
- **Lightweight Design**: Engineered for efficiency, `zcached` boasts a small memory footprint and minimal CPU usage, optimizing performance while conserving resources.
- **Optimized Efficiency**: Prioritizing swift data handling, `zcached` ensures prompt operations to cater to diverse application needs.
- **Diverse Data Type Support**: Accommodates various data structures like strings, integers, floats, and lists, enhancing utility across different use cases.

## Installation
### Prerequisites
- [Zig](https://ziglang.org/download/) (0.11.0 or newer)

### Building from Source
1. Clone the repository
```bash
git clone
```
2. Build the project
```bash
zig build
```
3. Run the executable
```bash
./zcached
```

## Running Tests
Run this command in the root directory of the project:
```bash
zig test --main-pkg-path .. tests.zig
```

## Usage
While `zcached` lacks a CLI, you can utilize nc (netcat) from the terminal to send commands to the server.

### Example Commands
#### SET
Set a key to hold the string value. If key already holds a value, it is overwritten, regardless of its type.
```bash
echo "*3\r\n\$3\r\nSET\r\n\$9\r\nmycounter\r\n:42\r\n" | netcat -N localhost 7556
```


#### Command Breakdown:
- `*3\r\n` - number of elements in the array (commands are always arrays)
- `\$3\r\nSET\r\n` - `$3` denotes the following string as 3 bytes long, SET is the command
- `\$9\r\nmycounter\r\n` - `$9` means that the next string is 9 bytes long, `mycounter` is the key
- `:42\r\n` - `:` indicates the next string is a number, `42` is the value

#### GET
Retrieve the value of a key. If the key doesn’t exist, `-not found` is returned. GET only accepts strings as keys.
```bash
echo "*2\r\n\$3\r\nGET\r\n\$9\r\nmycounter\r\n" | netcat -N localhost 7556
```

## Todo
- [ ] Support for more data types eg. Hashes, Sets, Sorted Sets.
- [ ] Create CLI Interface.
- [ ] Add `SAVE` command.
- [ ] Ability to set a TTL for a key.
- [ ] Logging commands (to be able to replay data inside the server if it crashes).
- [ ] Server events logging.
- [ ] Configurable server (port, max clients, max memory, etc.).
- [ ] Client side library.

## Release History
* 0.0.1
	* Initial release

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.