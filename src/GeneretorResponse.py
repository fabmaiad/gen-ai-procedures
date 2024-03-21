from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import (
    ChatPromptTemplate,
)
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI
from File_Handler import FileHandler
import logging
import os

# 
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(name)s - [%(filename)s:%(lineno)d] - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',)
logger = logging.getLogger()


class DescriptionGenerator:
    def __init__(self, api_key, system, system_content, model="gpt-4-turbo-preview", temperature=0.1) -> None:
        self.api_key = api_key
        self.system = system
        self.system_content = system_content
        self.model = model
        self.temperature = temperature
        
    
    def generate_description(self, prompt, prompt_content):
        try:
            logger.info("GeneretorDocumentation")
            chat = ChatOpenAI(
                openai_api_key=self.api_key,
                model=self.model,
                temperature=self.temperature,
                verbose=True
            )
            prompt = f"{prompt}\n\n{prompt_content}"
            system = f"{self.system}\n\n{self.system_content}"
            messages = ([
               SystemMessage(content=system),
               HumanMessage(content=prompt),
            ])
            # print("#############################")
            # print(self.system)
            # print(self.system_content)
            # print(prompt)
            # print(prompt_content)
            print("#############################")
            chain = messages | chat | StrOutputParser()
            print("#############################4")
            chain.batch(messages)
            print("#############################2")
            #print(response)
            return "OK"
        except Exception as e:
             f"Calling tool with arguments:\n\nraised the following error:\n\n{type(e)}: {e}"

class DocumentationGenerator:
    def __init__(self, config):
        self.file_handler = FileHandler
        system_content = self.file_handler.read_file(config['system_file_path'])
        self.prompt_directory = config['prompt_directory']
        self.prompt = config['prompt']
        self.output_file_name = config['output_file_name']
        self.generetor = DescriptionGenerator(config['api_key'], config['system'], system_content)
    # GeneretorDocumentation

    def generate_documentation(self):
        for prompt_file_name in os.listdir(self.prompt_directory):
            prompt_file_path = os.path.join(self.prompt_directory, prompt_file_name)
            prompt_content = self.file_handler.read_file(prompt_file_path)

            description = self.generetor.generate_description(
                prompt=self.prompt,
                prompt_content=prompt_content
            )
            output_base_name = os.path.splitext(prompt_file_name)[0]
            output_base_path = os.path.join('output', output_base_name)
            self.file_handler.save_description(output_base_path, self.output_file_name, description)
            logger.info(f"Documentation saved to {output_base_path}/{self.output_file_name}")