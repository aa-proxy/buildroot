#!/usr/bin/env python3
# User Guide
# 1.python memory_display.py memmap.py memmap.txt
import sys
import math
import importlib.util
import os
import argparse

def import_class_from_path(file_path, class_name):
    if not os.path.isfile(file_path):
        raise FileNotFoundError(f"The file '{file_path}' does not exist.")
    if not os.access(file_path, os.R_OK):
        raise PermissionError(f"The file '{file_path}' is not accessible.")
    spec = importlib.util.spec_from_file_location("module_name", file_path)
    module = importlib.util.module_from_spec(spec)
    sys.modules["module_name"] = module
    spec.loader.exec_module(module)
    try:
        return getattr(module, class_name)
    except AttributeError:
        raise ImportError(f"The class '{class_name}' is not found in '{file_path}'.")


def calculate_endings(memory_map_class):
    attrs = dir(memory_map_class)
    for attr in attrs:
        if attr.endswith("_ADDR"):
            base_name = attr[:-5]  # Remove '_ADDR' from the end
            size_attr = f"{base_name}_SIZE"
            if size_attr in attrs:
                addr = getattr(memory_map_class, attr)
                size = getattr(memory_map_class, size_attr)
                end_attr = f"{base_name}_END"
                setattr(memory_map_class, end_attr, addr + size)


def display_all(memory_map_class):
    calculate_endings(memory_map_class)  # Calculate the _END attributes before displaying
    data = []  # Initialize an empty list to collect data
    attrs = dir(memory_map_class)
    for attr in attrs:
        if attr.endswith("_ADDR"):
            base_name = attr[:-5]  # Remove '_ADDR' from the end
            size_attr = f"{base_name}_SIZE"
            end_attr = f"{base_name}_END"
            if size_attr in attrs:
                start_address = math.floor(getattr(memory_map_class, attr))
                size = math.floor(getattr(memory_map_class, size_attr))
                end_address = math.floor(getattr(memory_map_class, end_attr))
            else:
                start_address = math.floor(getattr(memory_map_class, attr))
                size = 0
                end_address = start_address
            if size & 0xfffff == 0:
                size_str = "{}M".format(size >> 20)
            elif size & 0x3ff == 0:
                size_str = "{}K".format(size >> 10)
            else:
                size_str = "{}B".format(size)
            data.append({
                "Name": base_name,
                "Start Address": hex(start_address) if isinstance(start_address, int) else start_address,
                "End Address": hex(end_address) if isinstance(end_address, int) else end_address,
                "Size": hex(size) if isinstance(size, int) else size,
                "Size(M/K/B)": size_str
            })
    return data


def sort_and_save_vertical_table(data, stage, output_filename):
    def address_to_int(addr):
        if addr == "-":
            return float('-inf')
        return int(addr, 16)

    data.sort(key=lambda x: address_to_int(x["Start Address"]))

    columns = [key for key in data[0].keys() if key != 'len']

    output = ""
    for item in data:
        item['len'] = max(10, len(item['Name']))

    for column in columns:
        output += f"| {column: <13} |"
        for item in data:
            output += f" {item[column]: <{item['len']}} |"
        output += "\n"

    output += "-" * (len(output) // 5 - 1) + "\n"
    if stage == 1:
        with open(output_filename, 'w') as file:
            file.write('FBSL stage:\n')
            file.write(output)
            file.write('\n')
    elif stage == 2:
        with open(output_filename, 'a') as file:
            file.write('uboot stage:\n')
            file.write(output)
            file.write('\n')
    elif stage == 3:
        with open(output_filename, 'a') as file:
            file.write('kernel stage:\n')
            file.write(output)
            file.write('\n')
            file.write('PS: When the kernel is booted, it will overwrite the FSBL and uboot memory space\n')


def filter_first_stage(data):
    prefixes = ("FREERTOS", "UIMAG", "MONITOR", "OPENSBI", "FSBL", "ALIOS")
    first_stage = [item for item in data if item["Name"].startswith(prefixes)]
    return first_stage


def filter_second_stage(data):
    prefixes = ("BOOTLOGO", "CVI_UPDATE", "UIMAG", "CVI_MMC_SKIP_TUNING", "CONFIG_SYS_INIT_SP", "MONITOR", "OPENSBI", "FREERTOS", "ALIOS")
    second_stage = [item for item in data if item["Name"].startswith(prefixes)]
    return second_stage


def filter_third_stage(data):
    prefixes = ("KERNEL", "MONITOR", "OPENSBI", "FREERTOS", "H26X", "ION",
                "ISP", "FRAMEBUFFER", "ALIOS", "SHARE", "PQBIN")
    third_stage = [item for item in data if item["Name"].startswith(prefixes)]
    return third_stage

def parse_args():
    parser = argparse.ArgumentParser(description='Display memory map')
    parser.add_argument('mem_path', type=str, help='The path to the .py file')
    parser.add_argument('out_path', type=str, help='The path to output file')
    return parser.parse_args()

def main():
    args = parse_args()

    class_name = 'MemoryMap'
    try:
        MyClass = import_class_from_path(args.mem_path, class_name)
        my_instance = MyClass()
        print(f"Successfully created an instance of '{class_name}' from '{args.mem_path}'.")
        data = display_all(my_instance)
        first_stage = filter_first_stage(data)
        sort_and_save_vertical_table(first_stage, 1, args.out_path)

        second_stage = filter_second_stage(data)
        sort_and_save_vertical_table(second_stage, 2, args.out_path)

        third_stage = filter_third_stage(data)
        sort_and_save_vertical_table(third_stage, 3, args.out_path)
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    main()
