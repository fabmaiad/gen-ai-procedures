import logging
import sys
import os
from File_Handler import FileHandler
from ProcedureExtractor import ProcedureExtractor
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(name)s - [%(filename)s:%(lineno)d] - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',)
logger = logging.getLogger()

class DescriptionGenerator:
    def __init__(self, api_key, system, system_content, model="gpt-4-turbo-preview", temperature=0.1):
        self.api_key = api_key
        self.system = system
        self.system_content = system_content
        self.model = model
        self.temperature = temperature

    def generate_description(self, prompt, prompt_content, accumulated_content=""):
        try:
            chat = ChatOpenAI(
                temperature=self.temperature, 
                openai_api_key=self.api_key, 
                model=self.model, 
                verbose=True)
            messages = [
                SystemMessage(content=self.system),
                SystemMessage(content=self.system_content),
                HumanMessage(content=prompt)
            ]

            if accumulated_content:
                messages.append(SystemMessage(content=accumulated_content))
            for content in prompt_content:
                messages.append(HumanMessage(content=content))
            
            #messages.append(HumanMessage(content=prompt_content))
            response = chat.invoke(messages)
            #new_description = response.content
            new_description = [resp.content for resp in response]
            updated_accumulated_content = accumulated_content + "\n" + "\n".join(new_description)

            return new_description, updated_accumulated_content
        except Exception as e:
            sys.exit(f"Error generating description: {e}")

class DocumentationGenerator:
    def __init__(self, config):
        self.file_handler = FileHandler()
        self.extractor = ProcedureExtractor()
        system_content = self.file_handler.read_file(config['system_file_path'])
        self.generator = DescriptionGenerator(config['api_key'], config['system'], system_content)

    def generate_documentation(self, config):
        for prompt_file_name in os.listdir(config['prompt_directory']):
            prompt_file_path = os.path.join(config['prompt_directory'], prompt_file_name)
            prompt_content = self.file_handler.read_file(prompt_file_path)
            procedures = self.extractor.extract_procedures(prompt_content)
            accumulated_documentation = ""

            batch_size = 50
            for i in range(0, len(procedures), batch_size):
               batch = procedures[i:i+batch_size]
               #for p, procedure_content in enumerate(batch):
               logger.info(f"Generating documentation for procedure {i + 1} in file {prompt_file_path}...")
               new_description, accumulated_documentation = self.generator.generate_description(
                    config['prompt'], batch, accumulated_documentation)
            ########
            # for i, procedure_content in enumerate(procedures):
            #     logger.info(f"Generating documentation file {prompt_file_path} for procedure {i+1}...")
            #     new_description, accumulated_documentation = self.generator.generate_description(
            #         config['prompt'], procedure_content, accumulated_documentation)
            if accumulated_documentation:
               output_base_path = os.path.join('output', os.path.splitext(prompt_file_name)[0])
               self.file_handler.save_description(output_base_path, config['output_file_name'], accumulated_documentation)
               logger.info(f"Documentation saved to {output_base_path}.{config['output_file_name']}")
            else:
               logger.info("No documentation generated.")