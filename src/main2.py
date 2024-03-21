import logging
import sys
from GeneretorResponse import DocumentationGenerator

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(name)s - [%(filename)s:%(lineno)d] - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',)
logger = logging.getLogger()

def main():
    if len(sys.argv) != 7:
        print("Usage: python script.py <OpenAIKey> <System> <System_File_Path> <Prompt> <Prompt_File_Path> <Output_File_Path>")
        sys.exit(1)
    config = {
        'api_key': sys.argv[1],
        'system': sys.argv[2],
        'system_file_path': sys.argv[3],
        'prompt': sys.argv[4],
        'prompt_directory': sys.argv[5],
        'output_file_name': sys.argv[6]
    }
    logger.info(f"CONFIG:\n{config}")
    doc_generator = DocumentationGenerator(config)
    doc_generator.generate_documentation()

if __name__ == "__main__":
    main()