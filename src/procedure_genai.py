import sys
import os
import logging
import chardet
import re
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
import openai


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(name)s - [%(filename)s:%(lineno)d] - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',)
logger = logging.getLogger()

def read_file(file_path):
    try:
        with open(file_path, 'rb') as file:
            data = file.read()
        encoding = chardet.detect(data)['encoding']
        #print(f"Detected encoding: {encoding}")
        logger.info(f"Detected encoding: {encoding}")

        return data.decode(encoding)
    except FileNotFoundError:
        sys.exit(f"Error: File not found at {file_path}")
    except Exception as e:
        sys.exit(f"Error reading file at {file_path}: {e}")


def extract_procedures(sql_text):
    try:
        #TODO: Ajuste esta expressão regular
        pattern = re.compile(r'(?is)(BEGIN\s+.*?;\s*END;)')
        procedures = pattern.findall(sql_text)
        return procedures
    except Exception as e:
        sys.exit(f"Error extracting procedures from SQL: {e}")


# Generate the description

def generate_description(api_key, system, system_content, prompt, prompt_content, accumulated_content=""):
    try:
        chat = ChatOpenAI(
            temperature=0.1, openai_api_key=api_key, model="gpt-4-turbo-preview", verbose=True)
        messages = [
            SystemMessage(
                content=f"{system}"
            ),
            SystemMessage(
                content=f"{system_content}"
            ),
            HumanMessage(
                content=f"{prompt}"
            )
        ]

        if accumulated_content:
            messages.append(SystemMessage(content=accumulated_content))

        messages.append(HumanMessage(content=f"{prompt}"))

        # Aqui você adiciona a nova parte
        messages.append(HumanMessage(content=prompt_content))

        # Envie a requisição para a API
        response = chat.invoke(messages)

        # Atualize a descrição acumulada com a nova descrição
        new_description = response.content
        updated_accumulated_content = accumulated_content + "\n" + new_description

        # Return the description
        return new_description, updated_accumulated_content
    except Exception as e:
        sys.exit(f"Error generating description: {e}")

# Save the description to a file

def save_description(file_path, description, prompt_file_path):
    prompt_file_path = prompt_file_path.split("/")[-1].split('.')[0]
    base_path = os.path.join('output', prompt_file_path)
    os.makedirs(base_path, exist_ok=True)
    file_path = os.path.join(base_path, file_path)
    try:
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(description)
        logger.info(f"File saved successfully at {file_path}")
    except Exception as e:
        sys.exit(f"Error writing to file at {file_path}: {e}")

# Main function

def main():
    if len(sys.argv) != 7:
        print("Usage: python script.py <OpenAIKey> <System> <System_File_Path> <Prompt> <Prompt_File_Path> <Output_File_Path>")
        sys.exit(1)

    api_key, system, system_file_path, prompt, prompt_directory, output_file_path = sys.argv[
        1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
    logger.info("CONFIG:\n"
                "API Key: %s\n"
                "System: %s\n"
                "System File Path: %s\n"
                "Prompt: %s\n"
                "Prompt Directory: %s\n"
                "Output File Path: %s\n",
                api_key, system, system_file_path, prompt, prompt_directory, output_file_path)
    system_content   = ""
    prompt_file_path = ""
    if os.path.isfile(system_file_path):
        system_content = read_file(system_file_path)

    #
    accumulated_documentation = ""
    # Extract the procedures from the SQL
    for prompt_file_name in os.listdir(prompt_directory):
        prompt_file_path = os.path.join(prompt_directory, prompt_file_name)

        prompt_content = read_file(prompt_file_path)
        procedures = extract_procedures(prompt_content)
        for i, procedure_content in enumerate(procedures):
            # Generate the description
            logger.info(f"Generating documentation for procedure {i+1}...")
            #
            new_description, accumulated_documentation = generate_description(
                api_key, system, system_content, prompt, procedure_content, accumulated_documentation)
    # Save the description to a file
    if accumulated_documentation:
        save_description(output_file_path, accumulated_documentation, prompt_file_path)



if __name__ == "__main__":
    main()