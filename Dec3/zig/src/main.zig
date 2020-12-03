const std = @import("std");
const print = @import("std").debug.print;
const heap = @import("std").heap;

const raw_input = @embedFile("../../input.dat");
const raw_input_length : usize = raw_input.len;

fn count_trees_on_path(map: [][]const u8, start_pos: usize, dir_x: usize, dir_y: u32) u64 {
    var col: usize = start_pos;
    var nr_trees: u32 = 0;
    var skip: u32 = 0;
    for (map) |row, i| {
        if (skip != 0) {
            skip -= 1;
            continue;
        }
        skip = dir_y - 1;
        if (row[col] == '#') {
            nr_trees += 1;
        }
        col += dir_x;
        col = col % (row.len);
    }
    return nr_trees;
}

fn init_map(input: []const u8, map: [][]const u8) void {
    var curr_row: usize = 0;
    var start_index: usize = 0;
    for (input) |byte, i| {
        if (byte == '\n') {
            map[curr_row] = input[start_index..i];
            start_index = i+1;
            curr_row += 1;
        }
    }
}

fn rows_in_input(input: []const u8) usize {
    var rows: usize = 0;
    for (input) |char| {
        if (char == '\n') {
            rows += 1;
        }
    }
    return rows;
}

const alloc_config = heap.Config{};

pub fn main() anyerror!void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(!gpa.deinit());
    const allocator = &gpa.allocator;

    const nr_rows = rows_in_input(raw_input[0..]);

    var map = try allocator.alloc([]const u8, nr_rows);
    defer allocator.free(map);

    init_map(raw_input[0..], map);

    const i : usize = 2;
    const j : usize = 5;
    print(" Char value at '{}','{}': {} from '{}'\n",
        .{i,
          j,
          map[i][j],
          map[i],
        });

    const nr_trees1_1 = count_trees_on_path(map[0..], 0, 1, 1);
    const nr_trees3_1 = count_trees_on_path(map[0..], 0, 3, 1);
    const nr_trees5_1 = count_trees_on_path(map[0..], 0, 5, 1);
    const nr_trees7_1 = count_trees_on_path(map[0..], 0, 7, 1);
    const nr_trees1_2 = count_trees_on_path(map[0..], 0, 1, 2);

    const answer = nr_trees1_1 * nr_trees3_1 * nr_trees5_1 * nr_trees7_1 * nr_trees1_2;

    print(" Day: {} \n answer: '{}'\n nr trees 1,1: '{}'\n nr trees 3,1: '{}'\n nr trees 5,1: '{}'\n nr trees 7,1: '{}'\n nr trees 1,2: '{}'\n",
        .{3,
          answer,
          nr_trees1_1,
          nr_trees3_1,
          nr_trees5_1,
          nr_trees7_1,
          nr_trees1_2,
        });

}
