import chardet
import logging
import sys
import os

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(name)s - [%(filename)s:%(lineno)d] - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',)
logger = logging.getLogger()


# Class to read and write files
class FileHandler:
    @staticmethod
    def read_file(file_path):
        try:
            with open(file_path, 'rb') as file:
                data = file.read()
            encoding = chardet.detect(data)['encoding']
            logger.info(f"Detected encoding: {encoding}")
            return data.decode(encoding)
        except FileNotFoundError:
            sys.exit(f"Error: File not found at {file_path}")
        except Exception as e:
            sys.exit(f"Error reading file at {file_path}: {e}")
    @staticmethod
    def save_description(base_path, file_path, description):
        os.makedirs(base_path, exist_ok=True)
        full_path = os.path.join(base_path, file_path)
        try:
            with open(full_path, 'w', encoding='utf-8') as file:
                file.write(description)
            logger.info(f"File saved successfully at {full_path}")
        except Exception as e:
            sys.exit(f"Error writing to file at {full_path}: {e}")