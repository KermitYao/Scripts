import os
import argparse

def get_sorted_files(directory):
    """获取指定目录下的所有文件，并按修改时间排序"""
    files = [os.path.join(directory, f) for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]
    sorted_files = sorted(files, key=os.path.getmtime, reverse=True)
    return sorted_files

def retain_latest_files(directory, n):
    """保留最新的n个文件，其余文件删除"""
    sorted_files = get_sorted_files(directory)
    files_to_keep = sorted_files[:n]
    
    files_to_delete = sorted_files[n:]
    
    for file in files_to_delete:
        os.remove(file)
        print(f"Deleted: {file}")

def main():
    parser = argparse.ArgumentParser(description='Delete old files in a directory while keeping the latest n files.')
    parser.add_argument('directory', type=str, help='The directory to clean up')
    parser.add_argument('n', type=int, help='Number of latest files to keep')
    
    args = parser.parse_args()
    
    if not os.path.isdir(args.directory):
        print(f"Error: Directory {args.directory} does not exist.")
        return
    
    if args.n < 1:
        print("Error: The number of files to keep should be at least 1.")
        return
    
    retain_latest_files(args.directory, args.n)

if __name__ == "__main__":
    main()
