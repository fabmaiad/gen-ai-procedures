import sys
import os
import datetime
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
import openai


def read_file(file_path):
    try:
        with open(file_path, 'r') as file:
            return file.read()
    except FileNotFoundError:
        sys.exit(f"Error: File not found at {file_path}")
    except Exception as e:
        sys.exit(f"Error reading file at {file_path}: {e}")


def generate_description(api_key, system, system_content, prompt, prompt_content):
    try:
        chat = ChatOpenAI(
            temperature=0, openai_api_key=api_key, model="gpt-4", verbose=True)
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

        # Split the prompt_content into smaller chunks based on token count
        chunk_size = 1000  # You can adjust this based on the token limit
        chunks = []
        current_chunk = ""

        for token in prompt_content.split():
            if len(current_chunk.split()) + len(token.split()) <= chunk_size:
                current_chunk += token + " "
            else:
                chunks.append(current_chunk.strip())
                current_chunk = token + " "

        if current_chunk:
            chunks.append(current_chunk.strip())

        # Send each chunk to the LangChain API
        for chunk in chunks:
            messages.append(HumanMessage(content=chunk))

        response = chat.invoke(messages)

        print(response)

        return response.content
    except openai.error.Timeout as e:
        print(f"OpenAI API request timed out: {e}")
        pass
    except openai.error.APIError as e:
        print(f"OpenAI API returned an API Error: {e}")
        pass
    except openai.error.APIConnectionError as e:
        print(f"OpenAI API request failed to connect: {e}")
        pass
    except openai.error.InvalidRequestError as e:
        print(f"OpenAI API request was invalid: {e}")
        pass
    except openai.error.AuthenticationError as e:
        print(f"OpenAI API request was not authorized: {e}")
        pass
    except openai.error.PermissionError as e:
        print(f"OpenAI API request was not permitted: {e}")
        pass
    except openai.error.RateLimitError as e:
        print(f"OpenAI API request exceeded rate limit: {e}")
        pass


# Save the description to a file

def save_description(file_path, description, prompt_file_path):
    #current_time = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    prompt_file_path = prompt_file_path.split("/")[-1].split('.')[0]
    base_path = os.path.join('output', prompt_file_path)
    os.makedirs(base_path, exist_ok=True)
    file_path = os.path.join(base_path, file_path)
    try:
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(description)
        print(f"File saved successfully at {file_path}")
    except Exception as e:
        sys.exit(f"Error writing to file at {file_path}: {e}")

# Main function
        
def main():
    if len(sys.argv) != 7:
        print("Usage: python script.py <OpenAIKey> <System> <System_File_Path> <Prompt> <Prompt_File_Path> <Output_File_Path>")
        sys.exit(1)

    api_key, system, system_file_path, prompt, prompt_directory, output_file_path = sys.argv[
        1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
    print(api_key, system, system_file_path, prompt, prompt_directory, output_file_path)
    system_content = ""

    if os.path.isfile(system_file_path):
        system_content = read_file(system_file_path)


    for prompt_file_name in os.listdir(prompt_directory):
        prompt_file_path = os.path.join(prompt_directory, prompt_file_name)
        if os.path.isfile(prompt_file_path):
            # Lê o conteúdo do arquivo de prompt
            prompt_content = read_file(prompt_file_path)
        
        description = generate_description(api_key, system, system_content, prompt, prompt_content)
        save_description(output_file_path, description, prompt_file_path)
        print(f"{output_file_path} saved.")


if __name__ == "__main__":
    main()
